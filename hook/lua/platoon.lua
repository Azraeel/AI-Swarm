WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset platoon.lua' )

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii(true)
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
local AIUtils = import('/lua/ai/aiutilities.lua')
local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')
local MABC = import('/lua/editor/MarkerBuildConditions.lua')
local ALLBPS = __blueprints
local HERODEBUGSwarm = false
local CHAMPIONDEBUGswarm = false 
local MarkerSwitchDist = 20
local MarkerSwitchDistEXP = 40

local PlatoonExists = moho.aibrain_methods.PlatoonExists
local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
local GetThreatsAroundPosition = moho.aibrain_methods.GetThreatsAroundPosition
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits
local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition
local PlatoonCategoryCount = moho.platoon_methods.PlatoonCategoryCount
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local IsUnitState = moho.unit_methods.IsUnitState
local GetBrain = moho.platoon_methods.GetBrain

local SWARMCOPY = table.copy
local SWARMGETN = table.getn
local SWARMSORT = table.sort
local SWARMEMPTY = table.empty
local SWARMCOUNT = table.count
local SWARMINSERT = table.insert
local SWARMCAT = table.cat
local SWARMREMOVE = table.remove
local SWARMWAIT = coroutine.yield
local SWARMFLOOR = math.floor
local SWARMATAN2 = math.atan2
local SWARMRANDOM = math.random
local SWARMMIN = math.min
local SWARMCEIL = math.ceil
local SWARMMAX = math.max
local SWARMSIN = math.sin
local SWARMCOS = math.cos
local SWARMENTITY = EntityCategoryContains
local SWARMTIME = GetGameTimeSeconds

local VDist2 = VDist2
local VDist2Sq = VDist2Sq
local VDist3 = VDist3

local ForkThread = ForkThread
local ForkTo = ForkThread

local KillThread = KillThread


SwarmPlatoonClass = Platoon
Platoon = Class(SwarmPlatoonClass) {

    -- One New Function for Air (AirHuntAISwarm) - Authored by Relent0r
    -- Replaces old rundown Uveso Air Function
    AirHuntAISwarm = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local data = self.PlatoonData
        local categoryList = {}
        local atkPri = {}
        local target
        local startX, startZ = aiBrain:GetArmyStartPos()
        local homeBaseLocation = aiBrain.BuilderManagers['MAIN'].Position
        local currentPlatPos
        local distSq
        local avoidBases = data.AvoidBases or false
        local platoonLimit = self.PlatoonData.PlatoonLimit or 24
        local defensive = data.Defensive or false
        if data.PrioritizedCategories then
            for k,v in data.PrioritizedCategories do
                SWARMINSERT(atkPri, v)
                if type(v) == 'string' then
                    SWARMINSERT(categoryList, ParseEntityCategory(v))
                else
                    SWARMINSERT(categoryList, v)
                end
            end
        else
            SWARMINSERT(atkPri, categories.MOBILE * categories.AIR)
            SWARMINSERT(categoryList, categories.MOBILE * categories.AIR)
        end
        local platoonUnits = GetPlatoonUnits(self)
        for k, v in platoonUnits do
            if not v.Dead and v:TestToggleCaps('RULEUTC_StealthToggle') then
                v:SetScriptBit('RULEUTC_StealthToggle', false)
            end
            if not v.Dead and v:TestToggleCaps('RULEUTC_CloakToggle') then
                v:SetScriptBit('RULEUTC_CloakToggle', false)
            end
        end


        self:SetPrioritizedTargetList('Attack', categoryList)
        local maxRadius = data.SearchRadius or 1000
        local threatCountLimit = 0

        while PlatoonExists(aiBrain, self) do
            local currentPlatPos = GetPlatoonPosition(self)
            local platoonThreat = self:CalculatePlatoonThreat('Air', categories.ALLUNITS)
            if not target or target.Dead then
                if defensive then
                    target = AIUtils.AIFindBrainTargetInRangeSwarm(aiBrain, self, 'Attack', maxRadius, atkPri, avoidBases)
                    if not PlatoonExists(aiBrain, self) then
                        return
                    end
                else
                    local mult = { 1,10,25 }
                    for _,i in mult do
                        target = AIUtils.AIFindBrainTargetInRangeSwarm(aiBrain, self, 'Attack', maxRadius * i, atkPri, avoidBases)
                        if target then
                            break
                        end
                        SWARMWAIT(10) --DUNCAN - was 3
                        if not PlatoonExists(aiBrain, self) then
                            return
                        end
                    end
                end
            end

            if target then
                local targetPos = target:GetPosition()
                local platoonCount = SWARMGETN(GetPlatoonUnits(self))

                if (threatCountLimit < 5 ) and (VDist2Sq(currentPlatPos[1], currentPlatPos[2], startX, startZ) < 22500) and (GetThreatAtPosition(aiBrain, targetPos, aiBrain.IMAPConfigSwarm.Rings, true, 'AntiAir') * 1.3 > platoonThreat) and platoonCount < platoonLimit then
                    --LOG('Target air threat too high')
                    threatCountLimit = threatCountLimit + 1
                    self:MoveToLocation(homeBaseLocation, false)
                    SWARMWAIT(80)
                    self:Stop()
                    self:MergeWithNearbyPlatoonsSwarm('AirHuntAISwarm', 60, 20)
                    continue
                end

                --LOG ('Target has'..GetThreatAtPosition(aiBrain, targetPos, 0, true, 'AntiAir')..' platoon threat is '..platoonThreat)
                --LOG('threatCountLimit is'..threatCountLimit)
                self:Stop()
                --LOG('* AI-Swarm: Attacking Target')
                --LOG('* AI-Swarm: AirHunt Target is at :'..repr(target:GetPosition()))
                self:AttackTarget(target)

                while PlatoonExists(aiBrain, self) do
                    currentPlatPos = GetPlatoonPosition(self)
                    if aiBrain.EnemyStartLocations then
                        if SWARMGETN(aiBrain.EnemyStartLocations) > 0 then
                            for e, pos in aiBrain.EnemyStartLocations do
                                if VDist2Sq(targetPos[1],  targetPos[3], pos[1], pos[3]) < 10000 then
                                    --LOG('AirHuntAI target within enemy start range, return to base')
                                    target = false
                                    if PlatoonExists(aiBrain, self) then
                                        self:Stop()
                                        self:MoveToLocation(homeBaseLocation, false)
                                        --LOG('Air Unit Return to base provided position :'..repr(bestBase.Position))
                                        while PlatoonExists(aiBrain, self) do
                                            currentPlatPos = self:GetPlatoonPosition()
                                            --LOG('Air Unit Distance from platoon to bestBase position for Air units is'..VDist2Sq(currentPlatPos[1], currentPlatPos[3], bestBase.Position[1], bestBase.Position[3]))
                                            --LOG('Air Unit Platoon Position is :'..repr(currentPlatPos))
                                            distSq = VDist2Sq(currentPlatPos[1], currentPlatPos[3], homeBaseLocation[1], homeBaseLocation[3])
                                            if distSq < 6400 then
                                                break
                                            end
                                            SWARMWAIT(20)
                                            target = AIUtils.AIFindBrainTargetInRangeSwarm(aiBrain, self, 'Attack', maxRadius, atkPri, avoidBases)
                                            if target then
                                                return self:SetAIPlan('AirHuntAISwarm')
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    SWARMWAIT(20)
                    if (target.Dead or not target or target:BeenDestroyed()) then
                        --LOG('* AI-Swarm: Target Dead or not or Destroyed, breaking loop')
                        break
                    end

                end
                SWARMWAIT(20)
            end

            if not PlatoonExists(aiBrain, self) then
                return
            else
                SWARMWAIT(2)
                currentPlatPos = GetPlatoonPosition(self)
            end

            if (target.Dead or not target or target:BeenDestroyed()) and VDist2Sq(currentPlatPos[1], currentPlatPos[3], startX, startZ) > 6400 then
                --LOG('* AI-Swarm: No Target Returning to base')
                if PlatoonExists(aiBrain, self) then
                    self:Stop()
                    self:MoveToLocation(homeBaseLocation, false)
                    --LOG('Air Unit Return to base provided position :'..repr(bestBase.Position))
                    while PlatoonExists(aiBrain, self) do
                        currentPlatPos = self:GetPlatoonPosition()
                        --LOG('Air Unit Distance from platoon to bestBase position for Air units is'..VDist2Sq(currentPlatPos[1], currentPlatPos[3], bestBase.Position[1], bestBase.Position[3]))
                        --LOG('Air Unit Platoon Position is :'..repr(currentPlatPos))
                        distSq = VDist2Sq(currentPlatPos[1], currentPlatPos[3], homeBaseLocation[1], homeBaseLocation[3])
                        if distSq < 6400 then
                            break
                        end
                        SWARMWAIT(20)
                        target = AIUtils.AIFindBrainTargetInRangeSwarm(aiBrain, self, 'Attack', maxRadius, atkPri, avoidBases)
                        if target then
                            self:SetAIPlan('AirHuntAISwarm')
                        end
                    end
                end
            end

            SWARMWAIT(25)
        end
    end,

    StrikeForceAISwarm = function(self)
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local data = self.PlatoonData
        local categoryList = {}
        local atkPri = {}
        if data.TargetSearchPriorities then
            --LOG('TargetSearch present for '..self.BuilderName)
            for k,v in data.TargetSearchPriorities do
                SWARMINSERT(atkPri, v)
            end
        else
            if data.PrioritizedCategories then
                for k,v in data.PrioritizedCategories do
                    SWARMINSERT(atkPri, v)
                end
            end
        end
        if data.PrioritizedCategories then
            for k,v in data.PrioritizedCategories do
                SWARMINSERT(categoryList, v)
            end
        end
        self:SetPrioritizedTargetList('Attack', categoryList)
        local target = false
        local oldTarget = false
        local blip = false
        local maxRadius = data.SearchRadius or 50
        local mergeRequired = false
        local platoonPosition
        local platoonLimit = self.PlatoonData.PlatoonLimit or 18
        local platoonCount = 0
        local movingToScout = false
        local avoidBases = data.AvoidBases or false
        local defensive = data.Defensive or false
        local mainBasePos = aiBrain.BuilderManagers['MAIN'].Position
        AIAttackUtils.GetMostRestrictiveLayer(self)
        local myThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)
        while aiBrain:PlatoonExists(self) do

            if not target or target.Dead or not target:GetPosition() then

                if defensive then
                    target = AIUtils.AIFindBrainTargetInRangeSwarm(aiBrain, self, 'Attack', maxRadius, atkPri, avoidBases)
                    if not PlatoonExists(aiBrain, self) then
                        return
                    end
                else
                    local mult = { 1,10,25 }
                    for _,i in mult do
                        target = AIUtils.AIFindBrainTargetInRangeSwarm(aiBrain, self, 'Attack', maxRadius * i, atkPri, avoidBases)
                        if target then
                            break
                        end
                        SWARMWAIT(10) --DUNCAN - was 3
                        if not PlatoonExists(aiBrain, self) then
                            return
                        end
                    end
                end

                -- Check for experimentals but don't attack if they have strong antiair threat unless close to base.
                local newtarget
                if AIAttackUtils.GetSurfaceThreatOfUnits(self) > 0 then
                    newtarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.EXPERIMENTAL * (categories.LAND + categories.NAVAL + categories.STRUCTURE))
                elseif AIAttackUtils.GetAirThreatOfUnits(self) > 0 then
                    newtarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.EXPERIMENTAL * categories.AIR)
                end

                if newtarget then
                    local targetExpPos
                    local targetExpThreat
                    if self.MovementLayer == 'Air' then
                        targetExpPos = newtarget:GetPosition()
                        targetExpThreat = GetThreatAtPosition(aiBrain, targetExpPos, aiBrain.IMAPConfigSwarm.Rings, true, 'AntiAir')
                        --LOG('Target Air Threat is '..targetExpThreat)
                        --LOG('My Air Threat is '..myThreat)
                        if myThreat > targetExpThreat then
                            target = newtarget
                        elseif VDist2Sq(targetExpPos[1], targetExpPos[3], mainBasePos[1], mainBasePos[3]) < 22500 then
                            target = newtarget
                        end
                    else
                        target = newtarget
                    end
                end

                if not target and platoonCount < platoonLimit then
                    --LOG('StrikeForceAI mergeRequired set true')
                    mergeRequired = true
                end

                if target and not target.Dead then
                    if self.MovementLayer == 'Air' then
                        local targetPosition = target:GetPosition()
                        platoonPosition = GetPlatoonPosition(self)
                        platoonCount = SWARMGETN(GetPlatoonUnits(self))
                        local targetDistance = VDist2Sq(platoonPosition[1], platoonPosition[3], targetPosition[1], targetPosition[3])
                        local path = false
                        if targetDistance < 10000 then
                            self:Stop()
                            self:AttackTarget(target)
                        else
                            local path, reason, totalThreat = AIAttackUtils.PlatoonGenerateSafePathToSwarm(aiBrain, self.MovementLayer, platoonPosition, targetPosition, 10 , 10000)
                            self:Stop()
                            if path then
                                local pathLength = SWARMGETN(path)
                                if not totalThreat then
                                    totalThreat = 1
                                end
                                --LOG('Total Threat for air is '..totalThreat)
                                local averageThreat = totalThreat / pathLength
                                local pathDistance
                                --LOG('StrikeForceAI average path threat is '..averageThreat)
                                --LOG('StrikeForceAI platoon threat is '..myThreat)
                                if averageThreat < myThreat or platoonCount >= platoonLimit then
                                    --LOG('StrikeForce air assigning path')
                                    for i=1, pathLength do
                                        self:MoveToLocation(path[i], false)
                                        while PlatoonExists(aiBrain, self) do
                                            platoonPosition = GetPlatoonPosition(self)
                                            targetPosition = target:GetPosition()
                                            targetDistance = VDist2Sq(platoonPosition[1], platoonPosition[3], targetPosition[1], targetPosition[3])
                                            if targetDistance < 10000 then
                                                --LOG('strikeforce air attack command on target')
                                                self:Stop()
                                                self:AttackTarget(target)
                                                break
                                            end
                                            pathDistance = VDist2Sq(path[i][1], path[i][3], platoonPosition[1], platoonPosition[3])
                                            if pathDistance < 900 then
                                                -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                                                self:Stop()
                                                break
                                            end
                                            --LOG('Waiting to reach target loop')
                                            SWARMWAIT(10)
                                        end
                                        if not target or target.Dead then
                                            target = false
                                            --LOG('Target dead or lost during strikeforce')
                                            break
                                        end
                                    end
                                else
                                    --LOG('StrikeForceAI Path threat is too high, waiting and merging')
                                    mergeRequired = true
                                    target = false
                                    SWARMWAIT(30)
                                end
                            else
                                self:AttackTarget(target)
                            end
                        end
                    end
                elseif data.Defensive then 
                    SWARMWAIT(30)
                    return self:SetAIPlan('ReturnToBaseAISwarm', true)
                elseif target.Dead then
                    --LOG('Strikeforce Target Dead performing loop')
                    target = false
                    SWARMWAIT(10)
                    continue
                else
                    --LOG('Strikeforce No Target we should be returning to base')
                    SWARMWAIT(30)
                    return self:SetAIPlan('ReturnToBaseAISwarm', true)
                end
            end
            SWARMWAIT(30)
            if not target and self.MovementLayer == 'Air' and mergeRequired then
                --LOG('StrkeForce Air AI Attempting Merge')
                self:MoveToLocation(mainBasePos, false)
                local baseDist
                --LOG('StrikefoceAI Returning to base')
                myThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)
                while PlatoonExists(aiBrain, self) do
                    platoonPosition = GetPlatoonPosition(self)
                    baseDist = VDist2Sq(platoonPosition[1], platoonPosition[3], mainBasePos[1], mainBasePos[3])
                    if baseDist < 6400 then
                        break
                    end
                    --LOG('StrikeforceAI base distance is '..baseDist)
                    SWARMWAIT(50)
                end
                --LOG('MergeRequired, performing merge')
                self:Stop()
                self:MergeWithNearbyPlatoonsSwarm('StrikeForceAISwarm', 60, 20, true)
                mergeRequired = false
            end
        end
    end,
    
    ACUChampionPlatoonSwarm = function(self)
        --AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        self.MovementLayer = 'Land'
        local aiBrain = self:GetBrain()
        -- table for target and debug information
        aiBrain.ACUChampionSwarm = {}
        -- save the cration time, we want to wait 10 seconds before we issue any enhancement or platoon disband
        self.created = SWARMTIME()
        -- removing the debug function thread for line drawing
        --if not CHAMPIONDEBUGswarm then
        --    aiBrain.ACUChampionSwarm.RemoveDebugDrawThread = true
        --end
        local PlatoonUnits = self:GetPlatoonUnits()
        local cdr = PlatoonUnits[1]
        -- There should be only the commander inside this platoon. Check it.
        if not cdr or not SWARMENTITY(categories.COMMAND, cdr) then
            cdr = false
            WARN('* AI-Swarm: ACUChampionSwarmPlatoon: Platoon formed but Commander unit not found!')
            for k,v in self:GetPlatoonUnits() or {} do
                if SWARMENTITY(categories.COMMAND, v) then
                    WARN('* AI-Swarm: ACUChampionSwarmPlatoon: Commander found in platoon on index: '..k)
                    cdr = v
                else
                    WARN('* AI-Swarm: ACUChampionSwarmPlatoon: Platoon unit Index '..k..' is not a commander!')
                end
            end
            if not cdr then
                WARN('* AI-Swarm: ACUChampionSwarmPlatoon: PlatoonDisband (no ACU in platoon).')
                self:PlatoonDisband()
                return
            end
        end
        -- ACU is in Support squad, but we want it in Attack squad
        aiBrain:AssignUnitsToPlatoon(self, {cdr}, 'Attack', 'None')

        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                SWARMINSERT(MoveToCategories, v )
            end
        else
            WARN('* AI-Swarm: * ACUChampionSwarmPlatoon: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                SWARMINSERT(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        -- switch the automatic overcharge off
        cdr:SetAutoOvercharge(false)
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local maxRadius = self.PlatoonData.SearchRadius or 512
        local DoNotDisband = self.PlatoonData.DoNotDisband
        -- make sure maxRadius is not over 512
        maxRadius = SWARMMIN( 512, maxRadius )
        local OverchargeWeapon
        cdr.CDRHome = aiBrain.BuilderManagers['MAIN'].Position
        cdr.smartPos = cdr:GetPosition()
        cdr.position = cdr.smartPos
--        cdr.HealthOLD = 100
        cdr.LastDamaged = 0
        cdr.LastMoved = SWARMTIME()

        local UnitBlueprint = cdr:GetBlueprint()
        for _, weapon in UnitBlueprint.Weapon or {} do
            -- filter dummy weapons
            if weapon.Damage == 0
            or weapon.WeaponCategory == 'Missile'
            or weapon.WeaponCategory == 'Anti Navy'
            or weapon.WeaponCategory == 'Anti Air'
            or weapon.WeaponCategory == 'Defense'
            or weapon.WeaponCategory == 'Teleport' then
                continue
            end
            -- check if the weapon is only enabled by an enhancment
            if weapon.EnabledByEnhancement then
                WeaponEnabled = false
                -- check if we have the enhancement
                for k, v in SimUnitEnhancements[cdr.EntityId] or {} do
                    if v == weapon.EnabledByEnhancement then
                        -- enhancement is installed, the weapon is valid
                        WeaponEnabled = true
                        --LOG('* AI-Swarm: * ACUChampionSwarmPlatoon: Weapon: '..weapon.EnabledByEnhancement..' - is installed by an enhancement!')
                        -- no need to search for other enhancements
                        break
                    end
                end
                -- if the wepon is not installed, continue with the next weapon
                if not WeaponEnabled then
                    --LOG('* AI-Swarm: * ACUChampionSwarmPlatoon: Weapon: '..weapon.EnabledByEnhancement..' - is not installed.')
                    continue
                end
            end
            --WARN('* AI-Swarm: * ACUChampionSwarmPlatoon: Weapon: '..weapon.DisplayName..' - WeaponCategory: '..weapon.WeaponCategory..' - MaxRadius:'..weapon.MaxRadius..'')
            if weapon.OverChargeWeapon then
                OverchargeWeapon = weapon
            end
            if not cdr.MaxWeaponRange or cdr.MaxWeaponRange < weapon.MaxRadius then
                cdr.MaxWeaponRange = weapon.MaxRadius
            end
        end
        UnitBlueprint = nil
        --WARN('* AI-Swarm: * ACUChampionSwarmPlatoon: cdr.MaxWeaponRange: '..cdr.MaxWeaponRange)

        -- set playablearea so we know where the map border is.
        local playablearea
        if ScenarioInfo.MapData.PlayableRect then
            playablearea = ScenarioInfo.MapData.PlayableRect
        else
            playablearea = {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
        end

        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        local Braveness = 0
        local RangeToBase
        local MainBaseTargetWithPath
        local MainBaseTargetWithPathPos
        local MoveToTarget
        local MoveToTargetPos
        local OverchargeTarget
        local OverchargeTargetPos
        local FocusTarget
        local FocusTargetPos
        local ACUCloseRange
        local ACUCloseRangePos
        local TargetCloseRange
        local TargetCloseRangePos
        local smartPos = {}
        local PlatoonCenterPosition
        local unitPos
        local alpha
        local NavigatorGoal
        local UnderAttackSwarm
        local CDRHealth
        local InstalledEnhancementsCount = 0
        local UnitT1, UnitT2, UnitT3, UnitT4, Threat, Shielded
        local EnemyBehindMe, ReachedBase
        local BraveDEBUG = {}
        
        local DebugText, LastDebugText
        -- count enhancements
        for i, name in SimUnitEnhancements[cdr.EntityId] or {} do
            InstalledEnhancementsCount = InstalledEnhancementsCount + 1
            --WARN('* AI-Swarm: * ACUChampionSwarmPlatoon: Found enhancement: '..name..' - InstalledEnhancementsCount = '..InstalledEnhancementsCount..'')
        end

        -- Make a seperate Thread for base targets
        self:ForkThread(self.ACUChampionSwarmBaseTargetThread, aiBrain, cdr)

        -- Main platoon loop
        while aiBrain:PlatoonExists(self) and not cdr.Dead do
            -- wait here to prevent deadloops and heavy CPU load
            SWARMWAIT(30) -- not working with 1, 2, 3, works good with 10, 
            cdr.position = cdr:GetPosition()
            if CHAMPIONDEBUGswarm then
                aiBrain.ACUChampion.CDRposition = {cdr.position, cdr.MaxWeaponRange}
            end
            --------------------------------------------------------------------------------------------------------------------------------
            -- Braveness decides if the ACU will attack or withdraw. Positive numbers lead to attack, negative lead to fall back to base. --
            --------------------------------------------------------------------------------------------------------------------------------

            Braveness = 0
            Shielded = false
            BraveDEBUG = {}
            -- We gain 1 Braveness if we have full health -------------------------------------------------------------------------------------------------------------------------
            CDRHealth = SwarmUtils.ComHealth(cdr)
            if CDRHealth == 100 then
                Braveness = Braveness + 1
                BraveDEBUG['Health100%'] = 1
            end

            -- We gain 1 Braveness for every 7% health we have over 30% health (+10 on 100% health) -------------------------------------------------------------------------------
            CDRHealth = SwarmUtils.ComHealth(cdr)
            Braveness = Braveness + SWARMFLOOR( (CDRHealth - 30) / 7 )
            BraveDEBUG['Health'] = SWARMFLOOR( (CDRHealth - 30)  / 7 )

            -- We gain 1 Braveness (max +3) for every 5 friendly T1 units nearby --------------------------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH1, cdr.position, 25, 'Ally' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH2, cdr.position, 25, 'Ally' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH3, cdr.position, 25, 'Ally' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.EXPERIMENTAL, cdr.position, 25, 'Ally' )
            -- Tech1 ~25 dps -- Tech2 ~90 dps = 3 x T1 -- Tech3 ~333 dps = 13 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 3 + UnitT3 * 13 + UnitT4 * 80
            if Threat > 0 then
                Braveness = Braveness + SWARMMIN( 3, SWARMFLOOR(Threat / 5) )
                BraveDEBUG['Ally'] = SWARMMIN( 3, SWARMFLOOR(Threat / 5) )
            end

            -- We gain 0.5 Braveness if we have at least 5 Anti Air units in close range --------------------------------------------------------------------------------------------
            Threat = aiBrain:GetNumUnitsAroundPoint( categories.MOBILE * categories.ANTIAIR, cdr.position, 30, 'Ally' )
            if Threat > 0 then
                Braveness = Braveness + 0.5
                BraveDEBUG['AllyAA'] = 0.5
            end

            -- We gain 1 Braveness if overcharge is available ---------------------------------------------------------------------------------------------------------------------
            if OverchargeWeapon then
                if aiBrain:GetEconomyStored('ENERGY') >= OverchargeWeapon.EnergyRequired then
                    Braveness = Braveness + 1
                    BraveDEBUG['OC'] = 1
                end
            end

            -- We gain 1 Braveness for every enhancement --------------------------------------------------------------------------------------------------------------------------
            Braveness = Braveness + InstalledEnhancementsCount * 0.5
            BraveDEBUG['Enhance'] = InstalledEnhancementsCount * 0.5

            -- We gain 0.1 Braveness for every tactical missile defense nearby ----------------------------------------------------------------------------------------------------
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2, cdr.position, 28, 'Ally' )
            if UnitT2 > 0 then
                Braveness = Braveness + UnitT2 * 0.1
                Shielded = true
                BraveDEBUG['TMD'] = UnitT2 * 0.1
            end

            -- We gain 0.5 Braveness for every Tech2 and 1 Braveness for every tech3 shield nearby --------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.MOBILE * categories.SHIELD * (categories.TECH2 + categories.TECH3), cdr.position, 12, 'Ally' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD * categories.TECH2, cdr.position, 12, 'Ally' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD * categories.TECH3, cdr.position, 21, 'Ally' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL, cdr.position, 30, 'Ally' )
            Threat = UnitT1 * 0.5 + UnitT2 * 0.5 + UnitT3 * 1 + UnitT4 * 2
            if Threat > 0 then
                Braveness = Braveness + Threat
                Shielded = true
                BraveDEBUG['Shield'] = Threat
            end


            -- We lose 1 Braveness for every 2 t1 enemy units in close range ------------------------------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH1, cdr.position, 40, 'Enemy' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH2, cdr.position, 40, 'Enemy' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH3, cdr.position, 40, 'Enemy' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.EXPERIMENTAL, cdr.position, 40, 'Enemy' )
            -- Tech1 ~25 dps -- Tech2 ~90 dps = 3 x T1 -- Tech3 ~333 dps = 13 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 3 + UnitT3 * 13 + UnitT4 * 80
            if Threat > 0 then
                Braveness = Braveness - SWARMFLOOR(Threat / 2)
                BraveDEBUG['Enemy'] = - SWARMFLOOR(Threat / 2)
            end

            -- We lose 5 Braveness for every additional enemy ACU nearby (-0 for 1 ACU, -5 for 2 ACUs, -10 for 3 ACUs
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.COMMAND, cdr.position, 60, 'Enemy' )
            Threat = UnitT1 - 1
            if Threat > 0 then
                Braveness = Braveness - SWARMFLOOR(Threat * 5)
                BraveDEBUG['EnemyACU'] = - SWARMFLOOR(Threat * 5)
            end

            -- We lose 6 Braveness for every T2 Point Defense nearby
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.TECH1, cdr.position, 40, 'Enemy' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.TECH2, cdr.position, 65, 'Enemy' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.TECH3, cdr.position, 85, 'Enemy' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.DEFENSE * categories.EXPERIMENTAL, cdr.position, 120, 'Enemy' )
            -- Tech1 ~150 dps -- Tech2 ~130 dps = 1 x T1 -- Tech3 ~260 dps = 2 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 1 + UnitT3 * 2 + UnitT4 * 13
            if Threat > 0 then
                Braveness = Braveness - SWARMFLOOR(Threat * 6)
                BraveDEBUG['PD'] = - SWARMFLOOR(Threat * 6)
            end

            -- We lose 1 Braveness if we got damaged in the last 4 seconds --------------------------------------------------------------------------------------------------------
            UnderAttackSwarm = SwarmUtils.UnderAttackSwarm(cdr)
            if UnderAttackSwarm then
                Braveness = Braveness - 1
                BraveDEBUG['Hitted'] = - 1
            end

            -- We lose 1 Braveness for every 20 map units that we are away from the main base (a 5x5 map has 256x256 map units) ---------------------------------------------------
            RangeToBase = VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3])
            Braveness = Braveness - SWARMFLOOR(RangeToBase/20)
            BraveDEBUG['Range'] = - SWARMFLOOR(RangeToBase/20)

            -- We lose 3 bravness in range of an enemy tactical missile launcher, we lose 10 in case we are at low health
            if aiBrain.ACUChampionSwarm.EnemyTMLPos then
                CDRHealth = SwarmUtils.ComHealth(cdr)
                if CDRHealth > 60 then
                    Braveness = Braveness - 3
                    BraveDEBUG['TML'] = - 3
                else
                    Braveness = Braveness - 10
                    BraveDEBUG['TML'] = - 10
                end
            end

            -- We lose 10 bravness in case the enemy has more than 5 Tech2/3 bomber or gunships
            if aiBrain.ACUChampionSwarm.numAirEnemyUnits > 5 then
                Braveness = Braveness - 10
                BraveDEBUG['Bomber'] = 10
            end

            -- We lose all Braveness if we have under 30% health -------------------------------------------------------------------------------------------------------------------------
            CDRHealth = SwarmUtils.ComHealth(cdr)
            if CDRHealth < 30 then
                Braveness = -20
            end

             -- We lose half Braveness if we have passed 20 Minutes -----------------------------------------------------------------------------------------------------------------------
            if SWARMTIME() > 1200 then
                Braveness = -10
            end

            ---------------
            -- Targeting --
            ---------------
            MoveToTarget = false
            MoveToTargetPos = false
            -- Targets from the ACUChampionSwarmBaseTargetThread
            MainBaseTargetWithPath = aiBrain.ACUChampionSwarm.MainBaseTargetWithPath
            MainBaseTargetWithPathPos = aiBrain.ACUChampionSwarm.MainBaseTargetWithPathPos[2]
            FocusTarget = aiBrain.ACUChampionSwarm.FocusTarget
            FocusTargetPos = aiBrain.ACUChampionSwarm.FocusTargetPos[2]
            OverchargeTarget = aiBrain.ACUChampionSwarm.OverchargeTarget
            OverchargeTargetPos = aiBrain.ACUChampionSwarm.OverchargeTargetPos[2]
            TargetCloseRange = aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange
            TargetCloseRangePos = aiBrain.ACUChampionSwarm.MainBaseTargetCloseRangePos[2]
            ACUCloseRange = aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRange
            ACUCloseRangePos = aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRangePos[2]

            -- start micro only if the ACU is closer to our base than any other enemy unit
            if FocusTarget then
                MoveToTarget = FocusTarget
                MoveToTargetPos = FocusTargetPos
            -- we don't have a dfocussed target, is there a enemy ACU in close range ? 
            elseif ACUCloseRange then
                MoveToTarget = ACUCloseRange
                MoveToTargetPos = ACUCloseRangePos
            -- do we have a target with path and a target with ignored pathing? What target is closer ?
            elseif MainBaseTargetWithPathPos and TargetCloseRangePos then
                -- is the TargetWithPath closer than the TargetCloseRange 
                if VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) < VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) then
                    -- is the TargetWithPath further away than our ACU to our base ?
                    if VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                        MoveToTarget = MainBaseTargetWithPath
                        MoveToTargetPos = MainBaseTargetWithPathPos
                    end
                -- TargetCloseRange is closer than the TargetWithPath 
                else
                    -- is the TargetCloseRange further away than our ACU to our base ?
                    if VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                        MoveToTarget = TargetCloseRange
                        MoveToTargetPos = TargetCloseRangePos
                    end
                end
            -- Do we have a target with path and is the target not closer to my base then me ?
            elseif MainBaseTargetWithPathPos and VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                MoveToTarget = MainBaseTargetWithPath
                MoveToTargetPos = MainBaseTargetWithPathPos
            -- Do we have a target without path and is the target not closer to my base then me ?
            elseif TargetCloseRange and VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) > VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] ) then
                MoveToTarget = TargetCloseRange
                MoveToTargetPos = TargetCloseRangePos
            end

            ------------------
            -- Enhancements --
            ------------------

            -- check if we are close to Main base, then decide if we can enhance
            if VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) < 75 then
                -- only upgrade if we are good at health
                local check = true
                if SWARMTIME() <= 600 and aiBrain.AggressiveCommander == false then
                    check = false
                else
                end
                if self.created + 10 > SWARMTIME() then
                    check = false
                else
                end
                if CDRHealth < 40 then
                    check = false
                end
                if UnderAttackSwarm then
                    check = false
                end
                if FocusTarget then
                    check = false
                end
                if aiBrain.ACUChampionSwarm.EnemyInArea > 0 then
                    check = false
                end
                if aiBrain.ACUChampionSwarm.EnemyTMLPos and not Shielded then
                    check = false
                end
                -- Only upgrade with almost full Energy storage
                if aiBrain:GetEconomyStoredRatio('ENERGY') < 0.90 then
                    check = false
                end
                -- First enhancement needs at least +200 energy
                if aiBrain:GetEconomyTrend('ENERGY')*10 < 200 then
                    check = false
                end
                -- Enhancement 3 and all other should only be done if we have good eco. (Black Ops ACU!)
                if InstalledEnhancementsCount >= 2 and (aiBrain:GetEconomyStoredRatio('MASS') < 0.40 or not Shielded) then
                    check = false
                end
                if check then
                    -- in case we have engineers inside the platoon, let them assist the ACU
                    for _, unit in self:GetPlatoonUnits() do
                        if unit.Dead then continue end
                        -- exclude the ACU
                        if unit.CDRHome then
                            continue
                        end
                        if SWARMENTITY(categories.ENGINEER, unit) then
                            --LOG('Engineer ASSIST ACU')
                            -- NOT working for enhancements
                            IssueGuard({unit}, cdr)
                        end
                        
                    end
                    -- will only start enhancing if ECO is good
                    local InstalledEnhancement = self:BuildACUEnhancements(cdr, InstalledEnhancementsCount < 1)
                    --local InstalledEnhancement = self:BuildACUEnhancements(cdr, false)
                    -- do we have succesfull installed the enhancement ?
                    if InstalledEnhancement then
                        SPEW('* AI-Swarm: * ACUChampionSwarmPlatoon: enhancement '..InstalledEnhancement..' installed')
                        -- count enhancements
                        InstalledEnhancementsCount = 0
                        for i, name in SimUnitEnhancements[cdr.EntityId] or {} do
                            InstalledEnhancementsCount = InstalledEnhancementsCount + 1
                            SPEW('* AI-Swarm: * ACUChampionSwarmPlatoon: Found enhancement: '..name..' - InstalledEnhancementsCount = '..InstalledEnhancementsCount..'')
                        end
                        -- check if we have installed a weapon
                        local tempEnhanceBp = cdr:GetBlueprint().Enhancements[InstalledEnhancement]
                        -- Is it a weapon with a new max range ?
                        if tempEnhanceBp.NewMaxRadius then
                            -- set the new max range
                            if not cdr.MaxWeaponRange or cdr.MaxWeaponRange < tempEnhanceBp.NewMaxRadius then
                                cdr.MaxWeaponRange = tempEnhanceBp.NewMaxRadius -- maxrange minus 10%
                                SPEW('* AI-Swarm: * ACUChampionSwarmPlatoon: New cdr.MaxWeaponRange: '..cdr.MaxWeaponRange..' ['..InstalledEnhancement..']')
                            end
                        else
                            --DebugArray(tempEnhanceBp)
                        end
                    end
                end
            end

            --------------
            -- Movement --
            --------------
--function IsNukeBlastAreaSwarm(aiBrain, TargetPosition)

            if not aiBrain:PlatoonExists(self) or cdr.Dead then
                self:PlatoonDisband()
                return
            end
            -- is any enemy closer to our base then our ACU ?
            if TargetCloseRangePos then
                EnemyBehindMe = VDist2( cdr.CDRHome[1], cdr.CDRHome[3], TargetCloseRangePos[1], TargetCloseRangePos[3] ) < VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] )
                if EnemyBehindMe then
                    BraveDEBUG['Behind'] = 1
                end
            elseif MainBaseTargetWithPathPos then
                EnemyBehindMe = VDist2( cdr.CDRHome[1], cdr.CDRHome[3], MainBaseTargetWithPathPos[1], MainBaseTargetWithPathPos[3] ) < VDist2( cdr.CDRHome[1], cdr.CDRHome[3], cdr.position[1], cdr.position[3] )
                if EnemyBehindMe then
                    BraveDEBUG['Behind'] = 2
                end
            else
                EnemyBehindMe = false
                BraveDEBUG['Behind'] = 0
            end
            NavigatorGoal = cdr:GetNavigator():GetGoalPos()
            -- Run away from experimentals. (move out of experimental wepon range)
            -- MKB Max distance to experimental DistBase/2 or EnemyExperimentalWepRange + 100. whatever is bigger
            if aiBrain.ACUChampionSwarm.EnemyExperimentalPos and VDist2( cdr.position[1], cdr.position[3], aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][1], aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][3] ) < aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange + 100 then
                alpha = SWARMATAN2(aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][3] - cdr.position[3] ,aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][1] - cdr.position[1])
                x = aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][1] - SWARMCOS(alpha) * (aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange + 100)
                y = aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][3] - SWARMSIN(alpha) * (aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange + 100)
                smartPos = { x, GetTerrainHeight( x, y), y }
                BraveDEBUG['Reason'] = 'Evade from EXPERIMENTAL'
            -- Move to the enemy if Braveness is positive or if we are inside our base
            elseif not EnemyBehindMe and Braveness >= 0 and MoveToTargetPos then
                ReachedBase = false
                BraveDEBUG['ReachedBase'] = 0
                -- if the target has moved or we got a new target, delete the Weapon Blocked flag.
                if cdr.LastMoveToTargetPos ~= MoveToTargetPos then
                    cdr.WeaponBlocked = false
                    cdr.LastMoveToTargetPos = MoveToTargetPos
                end
                -- Set different move destination if weapon fire is blocked
                if cdr.WeaponBlocked then
                    -- Weapoon fire is blocked, move to the target as close as possible.
                    smartPos = { MoveToTargetPos[1], MoveToTargetPos[2], MoveToTargetPos[3] }
                    BraveDEBUG['Reason'] = 'Weapon Blocked'
                else
                    -- go closeer to the target depending on ACU health
                    local RangeMod = CDRHealth/10
                    if RangeMod < 0 then RangeMod = 0 end
                    if RangeMod > 10 then RangeMod = 10 end
                    -- Weapoon fire is not blocked, move to the target at Max Weapon Range.
                    alpha = SWARMATAN2(MoveToTargetPos[3] - cdr.position[3] ,MoveToTargetPos[1] - cdr.position[1])
                    x = MoveToTargetPos[1] - SWARMCOS(alpha) * (cdr.MaxWeaponRange * 0.9 - RangeMod)
                    y = MoveToTargetPos[3] - SWARMSIN(alpha) * (cdr.MaxWeaponRange * 0.9 - RangeMod)
                    smartPos = { x, GetTerrainHeight( x, y), y }
                    BraveDEBUG['Reason'] = 'Attack target'
                end
            -- Back to base if Braveness is negative
            else
                -- decide if we move to our base or if we need to evade
                if VDist2( cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3] ) > 30 and not ReachedBase then
                    -- move to main base
                    smartPos = cdr.CDRHome
                    BraveDEBUG['Reason'] = 'go home >30'
                -- evade from focus target
                elseif not EnemyBehindMe and CDRHealth > 30 and FocusTargetPos and MoveToTargetPos then
                    ReachedBase = true
                    BraveDEBUG['ReachedBase'] = 1
                    alpha = SWARMATAN2(MoveToTargetPos[3] - cdr.position[3] ,MoveToTargetPos[1] - cdr.position[1])
                    x = MoveToTargetPos[1] - SWARMCOS(alpha) * (50)
                    y = MoveToTargetPos[3] - SWARMSIN(alpha) * (50)
                    smartPos = { x, GetTerrainHeight( x, y), y }
                    BraveDEBUG['Reason'] = 'Evade from FocusTarget'
                -- in case we got attacked but don't have a target to shoot at or low health
                elseif CDRHealth < 30 or aiBrain.ACUChampionSwarm.EnemyInArea then
                    ReachedBase = true
                    BraveDEBUG['ReachedBase'] = 1
                    local lessEnemyAreaPos
                    if (aiBrain.ACUChampionSwarm.EnemyInArea > 0 or FocusTargetPos) and aiBrain.ACUChampionSwarm.AreaTable then
                        local MostEnemyAreaIndex
                        local MostEnemyArea
                        for index, pos in aiBrain.ACUChampionSwarm.AreaTable do
                            if not MostEnemyArea or MostEnemyArea < aiBrain.ACUChampionSwarm.AreaTable[index][4] then
                                MostEnemyArea = aiBrain.ACUChampionSwarm.AreaTable[index][4]
                                MostEnemyAreaIndex = index
                            end
                        end
                        local countMin = false
                        local mirrorIndex
                        for index = 4, 3, -1 do
                            mirrorIndex = MostEnemyAreaIndex + index
                            if mirrorIndex > 8 then mirrorIndex = mirrorIndex - 8 end
                            if not countMin or countMin > aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][4] then
                                countMin = aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][4]
                                lessEnemyAreaPos = {aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][1], aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][2], aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][3]}
                                --LOG('lessEnemyAreaPos + = mirrorIndex: '..mirrorIndex..' - countMin:'..countMin)
                            end
                            mirrorIndex = MostEnemyAreaIndex - index
                            if mirrorIndex < 1 then mirrorIndex = mirrorIndex + 8 end
                            if not countMin or countMin > aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][4] then
                                countMin = aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][4]
                                lessEnemyAreaPos = {aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][1], aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][2], aiBrain.ACUChampionSwarm.AreaTable[mirrorIndex][3]}
                                --LOG('lessEnemyAreaPos - = mirrorIndex: '..mirrorIndex..' - countMin:'..countMin)
                            end
                        end
                    end
                    if lessEnemyAreaPos then
                        smartPos = lessEnemyAreaPos
                        BraveDEBUG['Reason'] = 'Evade to lessEnemyAreaPos'
                    else
                        ReachedBase = false
                        smartPos = SwarmUtils.RandomizePositionSwarm(cdr.CDRHome)
                        BraveDEBUG['Reason'] = 'Evade to cdr.CDRHom'
                    end
                else
                    ReachedBase = true
                    BraveDEBUG['ReachedBase'] = 1
                    if VDist2( cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3] ) > 30 then
                        smartPos = cdr.CDRHome
                        BraveDEBUG['Reason'] = 'dance go home'
                    elseif VDist2( cdr.position[1], cdr.position[3], NavigatorGoal[1], NavigatorGoal[3] ) <= 0.7 then
                        -- we are at home and not under attack, dance
                        smartPos = SwarmUtils.RandomizePositionSwarm(cdr.CDRHome)
                        BraveDEBUG['Reason'] = 'dance at home'
                    else
                        BraveDEBUG['Reason'] = 'dance at home Navigator'
                    end
                end
            end

            if CHAMPIONDEBUGswarm then
                cdr:SetCustomName('Braveness: '..Braveness..' - '..BraveDEBUG['Reason'])
                DebugText = 'Full:'..(BraveDEBUG['Health100%'] or "--")..' '
                DebugText = DebugText..'Heal:'..(BraveDEBUG['Health'] or "--")..' '
                DebugText = DebugText..'Ally:'..(BraveDEBUG['Ally'] or "--")..' '
                DebugText = DebugText..'AlAA:'..(BraveDEBUG['AllyAA'] or "--")..' '
                DebugText = DebugText..'Over:'..(BraveDEBUG['OC'] or "--")..' '
                DebugText = DebugText..'Enh:'..(BraveDEBUG['Enhance'] or "--")..' '
                DebugText = DebugText..'TMD:'..(BraveDEBUG['TMD'] or "--")..' '
                DebugText = DebugText..'Shield:'..(BraveDEBUG['Shield'] or "--")..' '
                DebugText = DebugText..'Enemy:'..(BraveDEBUG['Enemy'] or "--")..' '
                DebugText = DebugText..'PD:'..(BraveDEBUG['PD'] or "--")..' '
                DebugText = DebugText..'EnemyACU:'..(BraveDEBUG['EnemyACU'] or "--")..' '   -- -0 -5
                DebugText = DebugText..'Behind:'..(BraveDEBUG['Behind'] or "--")..' '
                DebugText = DebugText..'Hitted:'..(BraveDEBUG['Hitted'] or "--")..' '
                DebugText = DebugText..'Range:'..(BraveDEBUG['Range'] or "--")..' '         -- -0 -12
                DebugText = DebugText..'TML:'..(BraveDEBUG['TML'] or "--")..' '
                DebugText = DebugText..'Bomber:'..(BraveDEBUG['Bomber'] or "--")..' '
                DebugText = DebugText..'RBase:'..(BraveDEBUG['ReachedBase'] or "--")..' '
                DebugText = DebugText..'Braveness: '..Braveness..' - '
                DebugText = DebugText..'ACTION: '..(BraveDEBUG['Reason'] or "--")..' '
                if DebugText != LastDebugText then
                    LastDebugText = DebugText
                    LOG(DebugText)
                end
            end
            
            -- clear move commands if we have queued more than 2
            if SWARMGETN(cdr:GetCommandQueue()) > 2 then
                IssueClearCommands({cdr})
                --WARN('* AI-Swarm: ACUChampionSwarmPlatoon: IssueClearCommands({cdr}) ) 2'..SWARMGETN(cdr:GetCommandQueue()))
            end

            -- fire overcharge
            if OverchargeWeapon then
                -- Do we have the energy in general to overcharge ?
                if aiBrain:GetEconomyStored('ENERGY') >= OverchargeWeapon.EnergyRequired then
                    -- full energy (max damage) or when in danger
                    if aiBrain:GetEconomyStored('ENERGY') > 6000 or CDRHealth < 95 then
                        if OverchargeTarget and not OverchargeTarget.Dead and not OverchargeTarget:BeenDestroyed() then
                            IssueOverCharge({cdr}, OverchargeTarget)
                        end
                    end
                end
            end

            -- in case we are in range of an enemy TMl, always move to different positions
            if aiBrain.ACUChampionSwarm.EnemyTMLPos or UnderAttackSwarm then
                smartPos = SwarmUtils.RandomizePositionTMLSwarm(smartPos)
            end
            -- in case we are not moving for 4 seconds, force moving (maybe blocked line of sight)
            if not cdr:IsUnitState("Moving") then
                if cdr.LastMoved + 4 < SWARMTIME() then
                    smartPos = SwarmUtils.RandomizePositionTMLSwarm(smartPos)
                    cdr.LastMoved = SWARMTIME()
                end
            else
                cdr.LastMoved = SWARMTIME()
            end

            -- check if we have already a move position
            if not smartPos[1] then
                smartPos = cdr.position
            end
            -- Validate move position, make sure it's not out of map
            if smartPos[1] < playablearea[1] then
                smartPos[1] = playablearea[1]
            elseif smartPos[1] > playablearea[3] then
                smartPos[1] = playablearea[3]
            end
            if smartPos[3] < playablearea[2] then
                smartPos[3] = playablearea[2]
            elseif smartPos[3] > playablearea[4] then
                smartPos[3] = playablearea[4]
            end
            -- check if the move position is new, then issue a move command
            -- ToDo in case we are under fire we should move in zig-zag to evade
            if VDist2( smartPos[1], smartPos[3], NavigatorGoal[1], NavigatorGoal[3] ) > 0.7 then
                IssueClearCommands({cdr})
                IssueMove({cdr}, smartPos )
                if CHAMPIONDEBUGswarm then
                    aiBrain.ACUChampionSwarm.moveto = {cdr.position, smartPos}
                end
            elseif VDist2( cdr.position[1], cdr.position[3], NavigatorGoal[1], NavigatorGoal[3] ) <= 0.7 then
                if CHAMPIONDEBUGswarm then
                    aiBrain.ACUChampionSwarm.moveto = false
                end
            end

            -- fire primary weapon
            if FocusTargetPos and aiBrain:CheckBlockingTerrain(cdr.position, FocusTargetPos, 'low') then
                cdr.WeaponBlocked = true
            else
                cdr.WeaponBlocked = false
            end
            if not cdr.WeaponBlocked and FocusTarget and not FocusTarget.Dead and not FocusTarget:BeenDestroyed() then
                IssueAttack({cdr}, FocusTarget)
            end

            -- At home, no target and not under attack ? Then we can maybe disband
            if VDist2( cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3] ) < 30 and not MoveToTarget and not UnderAttackSwarm then
                -- in case we have no Factory left, recover!
                if not aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY, false)[1] then
                    --WARN('* AI-Swarm: ACUChampionSwarmPlatoon: PlatoonDisband (no HQ Factory)')
                    aiBrain.ACUChampionSwarm.CDRposition = false
                    aiBrain.ACUChampionSwarm.moveto = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetWithPath = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetWithPathPos = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetCloseRangePos = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRange = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRangePos = false
                    aiBrain.ACUChampionSwarm.OverchargeTargetPos = false
                    aiBrain.ACUChampionSwarm.FocusTarget = false
                    aiBrain.ACUChampionSwarm.FocusTargetPos = false
                    aiBrain.ACUChampionSwarm.EnemyTMLPos = false
                    aiBrain.ACUChampionSwarm.EnemyExperimentalPos = false
                    aiBrain.ACUChampionSwarm.AreaTable = false
                    aiBrain.ACUChampionSwarm.numAirEnemyUnits = false
                    aiBrain.ACUChampionSwarm.OverchargeTarget = false
                    aiBrain.ACUChampionSwarm.Assistees = false
                    if CHAMPIONDEBUGswarm then
                        cdr:SetCustomName('Engineer Recover')
                    end
                    self:PlatoonDisband()
                    return
                end

                -- no target in platoon max range ? Disband; Maybe another platoon has more max range
                if self.created + 30 < SWARMTIME() and Braveness > 0 and CDRHealth >= 100 and not aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange and not DoNotDisband then
                    --WARN('* AI-Swarm: ACUChampionSwarmPlatoon: PlatoonDisband (no targets in range)')
                    aiBrain.ACUChampionSwarm.CDRposition = false
                    aiBrain.ACUChampionSwarm.moveto = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetWithPath = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetWithPathPos = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetCloseRangePos = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRange = false
                    aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRangePos = false
                    aiBrain.ACUChampionSwarm.OverchargeTargetPos = false
                    aiBrain.ACUChampionSwarm.FocusTarget = false
                    aiBrain.ACUChampionSwarm.FocusTargetPos = false
                    aiBrain.ACUChampionSwarm.EnemyTMLPos = false
                    aiBrain.ACUChampionSwarm.EnemyExperimentalPos = false
                    aiBrain.ACUChampionSwarm.AreaTable = false
                    aiBrain.ACUChampionSwarm.numAirEnemyUnits = false
                    aiBrain.ACUChampionSwarm.OverchargeTarget = false
                    aiBrain.ACUChampionSwarm.Assistees = false
                    if CHAMPIONDEBUGswarm then
                        cdr:SetCustomName('Engineer')
                    end
                    self:PlatoonDisband()
                    return
                end
            end
            ----------------------------------------------
            -- Second micro part for cover/shield units --
            ----------------------------------------------
            PlatoonCenterPosition = self:GetPlatoonPosition()
            aiBrain.ACUChampionSwarm.Assistees = {}
            local debugIndex = 0
            local DistToACU = 0
            for index, unit in self:GetPlatoonUnits() do
                if unit.Dead then continue end
                -- exclude the ACU
                if unit.CDRHome then
                    continue
                end
                -- check and save if a unit has shield or stealth or cloak, so we can place the unit behind the ACU
                if not unit.HasShield then
                    UnitBlueprint = unit:GetBlueprint()
                    -- We need to cover other units with the shield, so only count non personal shields.
                    if UnitBlueprint.CategoriesHash.SHIELD and not UnitBlueprint.Defense.Shield.PersonalShield then
                        unit.HasShield = 1
                    elseif UnitBlueprint.Intel.RadarStealthField then
                        unit.HasShield = 1
                    elseif UnitBlueprint.Intel.CloakField then
                        unit.HasShield = 1
                    else
                        unit.HasShield = 0
                    end
                end
                -- Positive numbers will move units behind the ACU, negative numbers in front of the ACU
                if unit.HasShield == 1 then
                    -- Shield units
                    DistToACU = 5
                elseif SWARMENTITY(categories.LAND * categories.ANTIAIR, unit) then
                    -- Mobile Land Anti Air
                    DistToACU = 20
                elseif SWARMENTITY(categories.AIR, unit) then
                    -- Air units
                    DistToACU = 1
                elseif SWARMENTITY(categories.ENGINEER, unit) then
                    DistToACU = 10
                else
                    -- land units -6 means the unit will stay in front of the ACU
                    DistToACU = -6
                end
                --LOG('Valid Unit in ACU platoon: '..unit.UnitId)
                unitPos = unit:GetPosition()
                -- for debug lines
                debugIndex = debugIndex + 1
                aiBrain.ACUChampionSwarm.Assistees[debugIndex] = {unitPos, cdr.position }
                if not unit.smartPos then
                    unit.smartPos = unitPos
                end
                -- calculate a position behind the unit we want to cover (behind unit from enemy view)
                if NavigatorGoal and FocusTargetPos then
                    -- if we have a target, then move behind the ACU
                    alpha = SWARMATAN2(NavigatorGoal[3] - FocusTargetPos[3] ,NavigatorGoal[1] - FocusTargetPos[1])
                    x = cdr.smartPos[1] + SWARMCOS(alpha) * DistToACU
                    y = cdr.smartPos[3] + SWARMSIN(alpha) * DistToACU
                    smartPos = { x, GetTerrainHeight( x, y), y }
                else
                    -- Move so the ACU is between units and Base
                    --alpha = SWARMATAN2(cdr.position[3] - cdr.CDRHome[3] ,cdr.position[1] - cdr.CDRHome[1])
                    -- Move so our support units are between ACU and base
                    alpha = SWARMATAN2(cdr.CDRHome[3] - cdr.position[3] ,cdr.CDRHome[1] - cdr.position[1])
                    x = cdr.smartPos[1] + SWARMCOS(alpha) * DistToACU
                    y = cdr.smartPos[3] + SWARMSIN(alpha) * DistToACU
                    smartPos = { x, GetTerrainHeight( x, y), y }
                end
                -- check if the move position is new
                if VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 then
                    -- clear move commands if we have queued more than 2
                    if SWARMGETN(unit:GetCommandQueue()) > 1 then
                        IssueClearCommands({unit})
                    end
                    IssueMove({unit}, smartPos )
                    unit.smartPos = smartPos
                end
            end

        end
    end,

    ACUChampionSwarmBaseTargetThread = function(platoon, aiBrain, cdr)
        local MoveToCategories = {}
        if platoon.PlatoonData.MoveToCategories then
            for k,v in platoon.PlatoonData.MoveToCategories do
                SWARMINSERT(MoveToCategories, v )
            end
        end
        local SearchRadius = platoon.PlatoonData.SearchRadius or 250
        local TargetSearchCategory = platoon.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local SelfArmyIndex = aiBrain:GetArmyIndex()
        local ValidUnit, NavigatorGoal, FocusTarget, TargetsInACURange, blip
        local EnemyACU, EnemyACUPos, EnemyUnit, EnemyUnitPos, OverchargeVictims, MostUnitAround
        local playablearea
        if ScenarioInfo.MapData.PlayableRect then
            playablearea = ScenarioInfo.MapData.PlayableRect
        else
            playablearea = {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
        end

        while aiBrain:PlatoonExists(platoon) and not cdr.Dead do
            -- wait here to prevent deadloops and heavy CPU load
            SWARMWAIT(1)

            -- get the closest target to mainbase with path
            ValidUnit = false
            UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, platoon, 'Attack', cdr.CDRHome, SearchRadius, {TargetSearchCategory}, TargetSearchCategory, false )
            if UnitWithPath then
                blip = UnitWithPath:GetBlip(SelfArmyIndex)
                if blip then
                    if blip:IsOnRadar(SelfArmyIndex) or blip:IsSeenEver(SelfArmyIndex) then
                        if not blip:BeenDestroyed() and not blip:IsKnownFake(SelfArmyIndex) and not blip:IsMaybeDead(SelfArmyIndex) then
                            aiBrain.ACUChampionSwarm.MainBaseTargetWithPath = UnitWithPath
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampionSwarm.MainBaseTargetWithPath = false
            end
            -- draw a line from base to the base target
            if aiBrain.ACUChampionSwarm.MainBaseTargetWithPath then
                aiBrain.ACUChampionSwarm.MainBaseTargetWithPathPos = {cdr.CDRHome, aiBrain.ACUChampionSwarm.MainBaseTargetWithPath:GetPosition()}
            else
                aiBrain.ACUChampionSwarm.MainBaseTargetWithPathPos = false
            end

            -- get the closest target to mainbase ignoring path
            ValidUnit = false
            UnitCloseRange = AIUtils.AIFindNearestCategoryTargetInCloseRangeSwarm(platoon, aiBrain, 'Attack', cdr.CDRHome, SearchRadius, {TargetSearchCategory}, TargetSearchCategory, false)
            if UnitCloseRange then
                blip = UnitCloseRange:GetBlip(SelfArmyIndex)
                if blip then
                    if blip:IsOnRadar(SelfArmyIndex) or blip:IsSeenEver(SelfArmyIndex) then
                        if not blip:BeenDestroyed() and not blip:IsKnownFake(SelfArmyIndex) and not blip:IsMaybeDead(SelfArmyIndex) then
                            aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange = UnitCloseRange
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange = false
            end
            -- draw a line from base to the base target
            if aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange then
                aiBrain.ACUChampionSwarm.MainBaseTargetCloseRangePos = {cdr.CDRHome, aiBrain.ACUChampionSwarm.MainBaseTargetCloseRange:GetPosition()}
            else
                aiBrain.ACUChampionSwarm.MainBaseTargetCloseRangePos = false
            end
            
            -- get the closest ACU target to mainbase ignoring path
            -- get units around point, acu wiht lowest health = target
            ValidUnit = false
            ACUCloseRange = AIUtils.AIFindNearestCategoryTargetInCloseRangeSwarm(platoon, aiBrain, 'Attack', cdr.position, cdr.MaxWeaponRange, {categories.COMMAND}, categories.COMMAND, false)
            if ACUCloseRange then
                blip = ACUCloseRange:GetBlip(SelfArmyIndex)
                if blip then
                    if blip:IsOnRadar(SelfArmyIndex) or blip:IsSeenEver(SelfArmyIndex) then
                        if not blip:BeenDestroyed() and not blip:IsKnownFake(SelfArmyIndex) and not blip:IsMaybeDead(SelfArmyIndex) then
                            aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRange = ACUCloseRange
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRange = false
            end
            -- draw a line from base to the base target
            if aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRange then
                aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRangePos = {cdr.CDRHome, aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRange:GetPosition()}
            else
                aiBrain.ACUChampionSwarm.MainBaseTargetACUCloseRangePos = false
            end
            -- get the closest target to the ACU
            EnemyACU = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.COMMAND)
            if EnemyACU then
                EnemyACUPos = EnemyACU:GetPosition()
                -- out of range ?
                if VDist2( cdr.position[1], cdr.position[3], EnemyACUPos[1], EnemyACUPos[3] ) > cdr.MaxWeaponRange then
                    EnemyACU = false
                end
            end
            EnemyUnit = platoon:FindClosestUnit('Attack', 'Enemy', true, TargetSearchCategory)
            if EnemyUnit then
                EnemyUnitPos = EnemyUnit:GetPosition()
                -- out of range ?
                if VDist2( cdr.position[1], cdr.position[3], EnemyUnitPos[1], EnemyUnitPos[3] ) > cdr.MaxWeaponRange then
                    EnemyUnit = false
                end 
            end
            if EnemyACU then
                aiBrain.ACUChampionSwarm.FocusTarget = EnemyACU
                aiBrain.ACUChampionSwarm.FocusTargetPos = {cdr.position, EnemyACU:GetPosition()}
            elseif EnemyUnit then
                aiBrain.ACUChampionSwarm.FocusTarget = EnemyUnit
                aiBrain.ACUChampionSwarm.FocusTargetPos = {cdr.position, EnemyUnit:GetPosition()}
            else
                aiBrain.ACUChampionSwarm.FocusTarget = false
                aiBrain.ACUChampionSwarm.FocusTargetPos = false
            end
            -- get target for overcharge 
            TargetsInACURange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, cdr.position, cdr.MaxWeaponRange, 'Enemy')
            OverchargeVictims = {}
            for i, Target in TargetsInACURange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                if VDist2( cdr.position[1], cdr.position[3], TargetPosition[1], TargetPosition[3] ) < cdr.MaxWeaponRange then
                    SWARMINSERT(OverchargeVictims, {Target, TargetPosition, 0})
                end
            end
            -- count the unit with most units around (overcharge splat radius = 2.5)
            ValidUnit = false
            MostUnitAround = 0
            for IndexA, UnitA in OverchargeVictims do
                for IndexB, UnitB in OverchargeVictims do
                    if IndexA ~= IndexB and VDist2( UnitA[2][1], UnitA[2][3], UnitB[2][1], UnitB[2][3] ) < 2.5 then
                        UnitA[3] = UnitA[3] + 1
                        if UnitA[3] > MostUnitAround then
                            MostUnitAround = UnitA[3]
                            aiBrain.ACUChampionSwarm.OverchargeTarget = UnitA[1]
                            ValidUnit = true
                        end
                    end
                end
            end
            if not ValidUnit then
                aiBrain.ACUChampionSwarm.OverchargeTarget = false
            end
            -- draw a line for overcharge target
            if aiBrain.ACUChampionSwarm.OverchargeTarget then
                aiBrain.ACUChampionSwarm.OverchargeTargetPos = {cdr.position, aiBrain.ACUChampionSwarm.OverchargeTarget:GetPosition()}
            else
                aiBrain.ACUChampionSwarm.OverchargeTargetPos = false
            end
            
            -- Find free spots around the ACU for evading
            local AreaTable = {
                {cdr.position[1]-12, cdr.position[2], cdr.position[3]-30}, -- 1
                {cdr.position[1]+12, cdr.position[2], cdr.position[3]-30}, -- 2
                {cdr.position[1]+30, cdr.position[2], cdr.position[3]-12}, -- 4         1 2
                {cdr.position[1]+30, cdr.position[2], cdr.position[3]+12}, -- 6       3     4
                {cdr.position[1]+12, cdr.position[2], cdr.position[3]+30}, -- 8       5     6
                {cdr.position[1]-12, cdr.position[2], cdr.position[3]+30}, -- 7         7 8
                {cdr.position[1]-30, cdr.position[2], cdr.position[3]+12}, -- 5
                {cdr.position[1]-30, cdr.position[2], cdr.position[3]-12}, -- 3
            }
            aiBrain.ACUChampionSwarm.EnemyInArea = 0
            for index, pos in AreaTable do
                UnitT1 = aiBrain:GetNumUnitsAroundPoint( categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.DEFENSE, pos, 25, 'Enemy' )
                aiBrain.ACUChampionSwarm.EnemyInArea = aiBrain.ACUChampionSwarm.EnemyInArea + UnitT1
                -- mimic the map border as enemy units, so the ACU will not get to close to the border
                if pos[1] <= playablearea[1] + 1 then                  -- left border
                    UnitT1 = 1
                elseif pos[1] >= playablearea[3] -1 then               -- right border
                    UnitT1 = 1
                end
                if pos[3] <= playablearea[2] + 1then                   -- top border
                    UnitT1 = 1
                elseif pos[3] >= playablearea[4] -1 then               -- bottom border
                    UnitT1 = 1
                end
                AreaTable[index][4] = UnitT1
            end
            aiBrain.ACUChampionSwarm.AreaTable = AreaTable

            -- Enemy tactical missile threat
            local EnemyTML = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.TACTICALMISSILEPLATFORM)
            if EnemyTML then
                local EnemyTMLPos = EnemyTML:GetPosition()
                -- in range ?
                if VDist2( cdr.position[1], cdr.position[3], EnemyTMLPos[1], EnemyTMLPos[3] ) < 256 then
                    --aiBrain.ACUChampionSwarm.EnemyTML = EnemyTML
                    aiBrain.ACUChampionSwarm.EnemyTMLPos = {EnemyTMLPos, cdr.position}
                else
                    aiBrain.ACUChampionSwarm.EnemyTMLPos = false
                end
            end

            -- Enemy Experimental threat
            local EnemyExperimental = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.MOBILE * categories.EXPERIMENTAL)
            if EnemyExperimental then
                local EnemyExperimentalPos = EnemyExperimental:GetPosition()
                local UnitBlueprint = EnemyExperimental:GetBlueprint()
                local MaxWeaponRange
                for _, weapon in UnitBlueprint.Weapon or {} do
                    -- filter dummy weapons
                    if weapon.Damage == 0 or weapon.WeaponCategory == 'Missile' or weapon.WeaponCategory == 'Teleport' then
                        continue
                    end
                    if not MaxWeaponRange or MaxWeaponRange < weapon.MaxRadius then
                        MaxWeaponRange = weapon.MaxRadius
                    end
                end
                -- in range ?
                aiBrain.ACUChampionSwarm.EnemyExperimentalPos = {EnemyExperimentalPos, cdr.position}
                aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange = MaxWeaponRange
            else
                aiBrain.ACUChampionSwarm.EnemyExperimentalPos = false
                aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange = false
            end

            -- Enemy Bomber/gunship threat
            local numAirEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categories.MOBILE * categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) - categories.TECH1, Vector(playablearea[3]/2,0,playablearea[4]/2), playablearea[3]+playablearea[4] , 'Enemy')
            aiBrain.ACUChampionSwarm.numAirEnemyUnits = numAirEnemyUnits
        end
    end,

    -- call with self:DebugPlatoonSquads()
    DebugPlatoonSquads = function(self)
        local squadTypes = {'Unassigned', 'Attack', 'Artillery', 'Support', 'Scout', 'Guard'}
        for i, typ in squadTypes do
            LOG('Checking Squad: '..typ)
            local squadUnits = self:GetSquadUnits(typ)
            if squadUnits then
                for k, v in squadUnits do
                    LOG('Squad: '..typ..' - unit: '..repr(v.UnitId))
                end
            end
        end
    end,
    
    BuildACUEnhancementsSwarm = function(platoon, cdr, force)
        local EnhancementsByUnitID = {
            -- UEF
            ['uel0001'] = {'HeavyAntiMatterCannon', 'DamageStabilization', 'Shield', 'ShieldGeneratorField'},
            -- Aeon
            ['ual0001'] = {'HeatSink', 'CrysalisBeam', 'Shield', 'ShieldHeavy'},
            -- Cybran
            ['url0001'] = {'CoolingUpgrade', 'StealthGenerator', 'MicrowaveLaserGenerator', 'CloakingGenerator'},
            -- Seraphim
            ['xsl0001'] = {'RateOfFire', 'DamageStabilization', 'BlastAttack', 'DamageStabilizationAdvanced'},
            -- Nomads
            ['xnl0001'] = {'GunUpgrade', 'Capacitor', 'MovementSpeedIncrease', 'DoubleGuns'},

            -- UEF - Black Ops ACU
            ['eel0001'] = {'GatlingEnergyCannon', 'CombatEngineering', 'ShieldBattery', 'AutomaticBarrelStabalizers', 'AssaultEngineering', 'ImprovedShieldBattery', 'EnhancedPowerSubsystems', 'ApocalypticEngineering', 'AdvancedShieldBattery'},
            -- Aeon
            ['eal0001'] = {'PhasonBeamCannon', 'CombatEngineering', 'ShieldBattery', 'DualChannelBooster', 'AssaultEngineering', 'ImprovedShieldBattery', 'EnergizedMolecularInducer', 'ApocalypticEngineering', 'AdvancedShieldBattery'},
            -- Cybram
            ['erl0001'] = {'EMPArray', 'CombatEngineering', 'ArmorPlating', 'AdjustedCrystalMatrix', 'AssaultEngineering', 'StructuralIntegrityFields', 'EnhancedLaserEmitters', 'ApocalypticEngineering', 'CompositeMaterials'},
            -- Seraphim
            ['esl0001'] = {'PlasmaGatlingCannon', 'CombatEngineering', 'ElectronicsEnhancment', 'PhasedEnergyFields', 'AssaultEngineering', 'PersonalTeleporter', 'SecondaryPowerFeeds', 'ApocalypticEngineering', 'CloakingSubsystems'},
        }
        local CRDBlueprint = cdr:GetBlueprint()
        --LOG('* AI-Swarm: BlueprintId '..repr(CRDBlueprint.BlueprintId))
        local ACUUpgradeList = EnhancementsByUnitID[CRDBlueprint.BlueprintId]
        --LOG('* AI-Swarm: ACUUpgradeList '..repr(ACUUpgradeList))
        local NextEnhancement = false
        local HaveEcoForEnhancement = false
        for _,enhancement in ACUUpgradeList or {} do
            local wantedEnhancementBP = CRDBlueprint.Enhancements[enhancement]
            --LOG('* AI-Swarm: wantedEnhancementBP '..repr(wantedEnhancementBP))
            if not wantedEnhancementBP then
                SPEW('* AI-Swarm: ACUAttackAISwarm: no enhancement found for  = '..repr(enhancement))
            elseif cdr:HasEnhancement(enhancement) then
                NextEnhancement = false
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancements: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgradeSwarm(cdr, wantedEnhancementBP) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancements: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: *** Set as Enhancememnt: '..NextEnhancement)
                end
            elseif force then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancements: Eco is bad for '..enhancement..' - Ignoring eco requirement!')
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                end
            else
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancements: Eco is bad for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = false
                    -- if we don't have the eco for this ugrade, stop the search
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: canceled search. no eco available')
                    break
                end
            end
        end
        if NextEnhancement and HaveEcoForEnhancement then
            --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancements Building '..NextEnhancement)
            if platoon:BuildEnhancementSwarm(cdr, NextEnhancement) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancements returned true'..NextEnhancement)
                return NextEnhancement
            else
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancements returned false'..NextEnhancement)
                return false
            end
        end
        return false
    end,
    
    EcoGoodForUpgradeSwarm = function(platoon,cdr,enhancement)
        local aiBrain = platoon:GetBrain()
        local BuildRate = cdr:GetBuildRate()
        if not enhancement.BuildTime then
            WARN('* AI-Swarm: EcoGoodForUpgradeSwarm: Enhancement has no buildtime: '..repr(enhancement))
        end
        local drainMass = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostMass
        local drainEnergy = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostEnergy
        if aiBrain.HasParagon then
            return true
        elseif aiBrain:GetEconomyTrend('MASS')*10 >= drainMass and aiBrain:GetEconomyTrend('ENERGY')*10 >= drainEnergy then
            return true
        end
        return false
    end,
    
    BuildEnhancement = function(platoon,cdr,enhancement)
        --LOG('* AI-Swarm: BuildEnhancement: '..enhancement)
        local aiBrain = platoon:GetBrain()

        IssueStop({cdr})
        IssueClearCommands({cdr})
        
        if not cdr:HasEnhancement(enhancement) then
            
            local tempEnhanceBp = cdr:GetBlueprint().Enhancements[enhancement]
            local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(cdr.EntityId)
            -- Do we have already a enhancment in this slot ?
            if unitEnhancements[tempEnhanceBp.Slot] and unitEnhancements[tempEnhanceBp.Slot] ~= tempEnhanceBp.Prerequisite then
                -- remove the enhancement
                --LOG('* AI-Swarm: BuildEnhancement: Found enhancement ['..unitEnhancements[tempEnhanceBp.Slot]..'] in Slot ['..tempEnhanceBp.Slot..']. - Removing...')
                local order = { TaskName = "EnhanceTask", Enhancement = unitEnhancements[tempEnhanceBp.Slot]..'Remove' }
                IssueScript({cdr}, order)
                SWARMWAIT(10)
            end
            SPEW('* AI-Swarm: BuildEnhancement: '..platoon:GetBrain().Nickname..' IssueScript: '..enhancement)
            local order = { TaskName = "EnhanceTask", Enhancement = enhancement }
            IssueScript({cdr}, order)
        end
        while aiBrain:PlatoonExists(platoon) and not cdr.Dead and not cdr:HasEnhancement(enhancement) do
            if SwarmUtils.ComHealth(cdr) < 50 and SwarmUtils.UnderAttackSwarm(cdr) and cdr.WorkProgress < 0.90 then
                SPEW('* AI-Swarm: BuildEnhancement: '..platoon:GetBrain().Nickname..' Emergency!!! low health < 50% and under attack, canceling Enhancement '..enhancement)
                IssueStop({cdr})
                IssueClearCommands({cdr})
                return false
            end
            if cdr.WorkProgress < 0.30 and SwarmUtils.UnderAttackSwarm(cdr) then
                SPEW('* AI-Swarm: BuildEnhancement: '..platoon:GetBrain().Nickname..' Emergency!!! WorkProgress < 30% and under attack, canceling Enhancement '..enhancement)
                IssueStop({cdr})
                IssueClearCommands({cdr})
                return false
            end
            

            SWARMWAIT(3)
        end
        SPEW('* AI-Swarm: BuildEnhancement: '..platoon:GetBrain().Nickname..' Upgrade finished '..enhancement)
        return true
    end,


    MoveWithTransportSwarm = function(self, aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, EnemyThreatCategory)
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local TargetPosition = SWARMCOPY(target:GetPosition())
        local usedTransports = false
        if not aiBrain:PlatoonExists(self) then
            WARN('* AI-Swarm: MoveWithTransportSwarm: platoon does not exist')
            return
        end
        local PlatoonPosition = self:GetPlatoonPosition()
        if not PlatoonPosition then
            WARN('* AI-Swarm: MoveWithTransportSwarm: PlatoonPosition is NIL')
            return
        end
        -- see if we are in danger, fight units that are close to the platoon
        if bAggroMove then
            numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 20 , 'Enemy')
            if numEnemyUnits > 0 then
                return
            end
        end
        self:SetPlatoonFormationOverride('NoFormation')
        --LOG('* AI-Swarm: * MoveWithTransportSwarm: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
        if not ExperimentalInPlatoon and aiBrain:PlatoonExists(self) then
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, TargetPosition, true, false)
        end
        if not usedTransports then
            --LOG('* AI-Swarm: * MoveWithTransportSwarm: SendPlatoonWithTransportsNoCheckSwarm failed.')
            local PlatoonPos = self:GetPlatoonPosition() or TargetPosition
            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if DistanceToBase < DistanceToTarget or DistanceToTarget > 50 then
                --LOG('* AI-Swarm: * MoveWithTransportSwarm: base is nearer then distance to target or distance to target over 50. Return To base')
                self:SimpleReturnToBaseSwarm(basePosition)
            else
                --LOG('* AI-Swarm: * MoveWithTransportSwarm: Direct move to Target')
                if bAggroMove then
                    self:AggressiveMoveToLocation(TargetPosition)
                else
                    self:MoveToLocation(TargetPosition, false)
                end
            end
        else
            --LOG('* AI-Swarm: * MoveWithTransportSwarm: We got a transport!!')
        end
    end,

    MoveDirectSwarm = function(self, aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, EnemyThreatCategory)
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local TargetPosition = SWARMCOPY(target:GetPosition())
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        local ATTACKFORMATION = false
        local numEnemyUnits
        if bAggroMove then
            self:AggressiveMoveToLocation(TargetPosition)
        else
            self:MoveToLocation(TargetPosition, false)
        end
        while aiBrain:PlatoonExists(self) do
            PlatoonPosition = self:GetPlatoonPosition() or TargetPosition
            dist = VDist2( TargetPosition[1], TargetPosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            if not bAggroMove then
                local platoonUnitscheck = self:GetPlatoonUnits()
                if SWARMGETN(platoonUnits) > SWARMGETN(platoonUnitscheck) then
                    --LOG('* AI-Swarm: * MoveDirectSwarm: unit in platoon destroyed!!!')
                    ATTACKFORMATION = true
                    self:SetPlatoonFormationOverride('AttackFormation')
                    return
                end
            end
            --LOG('* AI-Swarm: * MoveDirectSwarm: dist to next Waypoint: '..dist)
            --LOG('* AI-Swarm: * MoveDirectSwarm: dist to target: '..dist)
            if not ATTACKFORMATION and dist < 80 then
                ATTACKFORMATION = true
                --LOG('* AI-Swarm: * MoveDirectSwarm: dist < 80 '..dist)
                self:SetPlatoonFormationOverride('AttackFormation')
            end
            if dist < 20 then
                return
            end
            -- Do we move ?
            if Lastdist ~= dist then
                Stuck = 0
                Lastdist = dist
            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
            else
                Stuck = Stuck + 1
                if Stuck > 20 then
                    --LOG('* AI-Swarm: * MoveDirectSwarm: Stucked while moving to target. Stuck='..Stuck)
                    self:Stop()
                    return
                end
            end
            -- If we lose our target, stop moving to it.
            if not target or target.Dead then
                --LOG('* AI-Swarm: * MoveDirectSwarm: Lost target while moving to target. ')
                return
            end
            -- see if we are in danger, fight units that are close to the platoon
            if bAggroMove then
                numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 20 , 'Enemy')
                if numEnemyUnits > 0 then
                    return
                end
            end
            SWARMWAIT(10)
        end
    end,

    MovePathSwarm = function(self, aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, EnemyThreatCategory, ExperimentalInPlatoon)
        local distEnd
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local MarkerSwitchDistance = MarkerSwitchDist
        if ExperimentalInPlatoon then
            MarkerSwitchDistance = MarkerSwitchDistEXP
        end
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local PathNodesCount = SWARMGETN(path)
        if self.MovementLayer == 'Air' then
            -- Air units should not follow the path for the last 4 hops.
            if PathNodesCount - 4 > 0 then
                PathNodesCount = PathNodesCount - 4
            -- if we have a short path, just use the destination as waypoint
            else
                path[1] = path[PathNodesCount]
                PathNodesCount = 1
            end
        end
        if not path[1] then
            if target and not target.Dead and not target:BeenDestroyed() then 
                path =  {SWARMCOPY(target:GetPosition())}
            else
                return
            end
        end
        local ATTACKFORMATION = false
        for i=1, PathNodesCount do
            local PlatoonPosition
            local Lastdist
            local dist
            local Stuck = 0
            --LOG('* AI-Swarm: * MovePathSwarm: moving to destination. i: '..i..' coords '..repr(path[i]))
            if bAggroMove then
                self:AggressiveMoveToLocation(path[i])
            else
                self:MoveToLocation(path[i], false)
            end
            if HERODEBUGSwarm then
                self:RenamePlatoonSwarm('MovePathSwarm: moving to path['..i..'] '..repr(path[i]))
            end
            while aiBrain:PlatoonExists(self) do
                PlatoonPosition = self:GetPlatoonPosition() or path[i]
                dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                if not bAggroMove then
                    local platoonUnitscheck = self:GetPlatoonUnits()
                    if SWARMGETN(platoonUnits) > SWARMGETN(platoonUnitscheck) then
                        --LOG('* AI-Swarm: * MovePathSwarm: unit in platoon destroyed!!!')
                        self:SetPlatoonFormationOverride('AttackFormation')
                    end
                end
                --LOG('* AI-Swarm: * MovePathSwarm: dist to next Waypoint: '..dist)
                distEnd = VDist2( path[PathNodesCount][1], path[PathNodesCount][3], PlatoonPosition[1], PlatoonPosition[3] )
                --LOG('* AI-Swarm: * MovePathSwarm: dist to Path End: '..distEnd)
                if not ATTACKFORMATION and distEnd < 80 then
                    ATTACKFORMATION = true
                    --LOG('* AI-Swarm: * MovePathSwarm: distEnd < 50 '..distEnd)
                    self:SetPlatoonFormationOverride('AttackFormation')
                end
                -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                if dist < MarkerSwitchDistance then
                    -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                    self:Stop()
                    break
                end
                -- Do we move ?
                if Lastdist ~= dist then
                    Stuck = 0
                    Lastdist = dist
                -- No, we are not moving, wait 20 ticks then break and use the next weaypoint
                else
                    Stuck = Stuck + 1
                    if Stuck > 20 then
                        --LOG('* AI-Swarm: * MovePathSwarm: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                        self:Stop()
                        break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                    end
                end
                -- If we lose our target, stop moving to it.
                if not target or target.Dead then
                    if HERODEBUGSwarm then
                        self:RenamePlatoonSwarm('MovePathSwarm: Lost target while moving to Waypoint ')
                    end
                    --LOG('* AI-Swarm: * MovePathSwarm: Lost target while moving to Waypoint. '..repr(path[i]))
                    return
                end
                -- see if we are in danger, fight units that are close to the platoon
                if bAggroMove then
                    numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 20 , 'Enemy')
                    if numEnemyUnits > 0 then
                        if HERODEBUGSwarm then
                            self:RenamePlatoonSwarm('MovePathSwarm: cancel move, enemies nearby')
                        end
                        return
                    end
                end
                SWARMWAIT(10)
            end
        end
        if HERODEBUGSwarm then
            self:RenamePlatoonSwarm('MovePathSwarm: destination reached; dist:'..distEnd)
        end
    end,

    MoveToLocationInclTransportSwarm = function(self, target, TargetPosition, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, EnemyThreatCategory)
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local MarkerSwitchDistance = MarkerSwitchDist
        if ExperimentalInPlatoon then
            MarkerSwitchDistance = MarkerSwitchDistEXP
        end
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        if not TargetPosition then
            TargetPosition = SWARMCOPY(target:GetPosition())
        end
        local aiBrain = self:GetBrain()
        local PlatoonPosition = self:GetPlatoonPosition()
        -- this will be true if we got our units transported to the destination
        local usedTransports = false
        local TransportNotNeeded, bestGoalPos
        -- check, if we can reach the destination without a transport
        local unit = AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Land' , PlatoonPosition, TargetPosition, 1000, 512)
        if not aiBrain:PlatoonExists(self) then
            return
        end
        -- don't use a transporter if we have a path and the target is closer then 100 map units
        if path and VDist2( PlatoonPosition[1], PlatoonPosition[3], TargetPosition[1], TargetPosition[3] ) < 100 then
            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: no transporter used for target distance '..VDist2( PlatoonPosition[1], PlatoonPosition[3], TargetPosition[1], TargetPosition[3] ) )
        -- use a transporter if we don't have a path, or if we want a transport
        elseif not ExperimentalInPlatoon and ((not path and reason ~= 'NoGraph') or WantsTransport)  then
            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: SendPlatoonWithTransportsNoCheck')
            if HERODEBUGSwarm then
                self:RenamePlatoonSwarm('SendPlatoonWithTransportsNoCheck')
                SWARMWAIT(1)
            end
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, TargetPosition, true, false)
        end
        -- if we don't got a transport, try to reach the destination by path or directly
        if not usedTransports then
            if HERODEBUGSwarm then
                self:RenamePlatoonSwarm('usedTransports = false')
                SWARMWAIT(1)
            end
            -- clear commands, so we don't get stuck if we have an unreachable destination
            IssueClearCommands(self:GetPlatoonUnits())
            if path then
                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: No transport used, and we dont need it.')
                if SWARMGETN(path) > 1 then
                    --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: SWARMGETN(path): '..SWARMGETN(path))
                end
                local PathNodesCount = SWARMGETN(path)
                local ATTACKFORMATION = false
                if HERODEBUGSwarm then
                    self:RenamePlatoonSwarm('PathNodesCount: '..repr(PathNodesCount))
                    SWARMWAIT(1)
                end
                for i=1, PathNodesCount do
                    if HERODEBUGSwarm then
                        self:RenamePlatoonSwarm('move to : path['..i..']')
                        SWARMWAIT(1)
                    end
                    --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: moving to destination. i: '..i..' coords '..repr(path[i]))
                    if bAggroMove then
                        self:AggressiveMoveToLocation(path[i])
                    else
                        self:MoveToLocation(path[i], false)
                    end
                    local PlatoonPosition
                    local Lastdist
                    local dist
                    local Stuck = 0
                    while aiBrain:PlatoonExists(self) do
                        PlatoonPosition = self:GetPlatoonPosition() or nil
                        if not PlatoonPosition then break end
                        dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                        if not bAggroMove then
                            local platoonUnitscheck = self:GetPlatoonUnits()
                            if SWARMGETN(platoonUnits) > SWARMGETN(platoonUnitscheck) then
                                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: unit in platoon destroyed!!!')
                                self:SetPlatoonFormationOverride('AttackFormation')
                            end
                        end
                        --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: dist to next Waypoint: '..dist)
                        distEnd = VDist2( path[PathNodesCount][1], path[PathNodesCount][3], PlatoonPosition[1], PlatoonPosition[3] )
                        --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: dist to Path End: '..distEnd)
                        if not ATTACKFORMATION and distEnd < 80 then
                            ATTACKFORMATION = true
                            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: distEnd < 50 '..distEnd)
                            self:SetPlatoonFormationOverride('AttackFormation')
                        end
                        -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                        if dist < MarkerSwitchDistance then
                            -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                            self:Stop()
                            break
                        end
                        -- Do we move ?
                        if Lastdist ~= dist then
                            Stuck = 0
                            Lastdist = dist
                        -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                        else
                            Stuck = Stuck + 1
                            if Stuck > 20 then
                                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                self:Stop()
                                break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                            end
                        end
                        -- If we lose our target, stop moving to it.
                        if not target then
                            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: Lost target while moving to Waypoint. '..repr(path[i]))
                            self:Stop()
                            if HERODEBUGSwarm then
                                self:RenamePlatoonSwarm('Lost target')
                                SWARMWAIT(1)
                            end
                            return
                        end
                        -- see if we are in danger, fight units that are close to the platoon
                        if bAggroMove then
                            numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 30 , 'Enemy')
                            if numEnemyUnits > 0 then
                                if HERODEBUGSwarm then
                                    self:RenamePlatoonSwarm('enemy nearby')
                                    SWARMWAIT(1)
                                end
                                return
                            end
                        end
                        SWARMWAIT(10)
                    end
                end
            else
                if HERODEBUGSwarm then
                    self:RenamePlatoonSwarm('nopath: '..repr(reason))
                    SWARMWAIT(1)
                end
                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: No transport used, and we have no Graph to reach the destination. Checking CanPathTo()')
                if reason == 'NoGraph' then
                    local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, TargetPosition)
                    if success then
                        --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: No transport used, found a way with CanPathTo(). moving to destination')
                        if bAggroMove then
                            self:AggressiveMoveToLocation(bestGoalPos)
                        else
                            self:MoveToLocation(bestGoalPos, false)
                        end
                        local PlatoonPosition
                        local Lastdist
                        local dist
                        local Stuck = 0
                        while aiBrain:PlatoonExists(self) do
                            PlatoonPosition = self:GetPlatoonPosition() or nil
                            if not PlatoonPosition then continue end
                            dist = VDist2( bestGoalPos[1], bestGoalPos[3], PlatoonPosition[1], PlatoonPosition[3] )
                            if dist < 20 then
                                break
                            end
                            -- Do we move ?
                            if Lastdist ~= dist then
                                Stuck = 0
                                Lastdist = dist
                            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                            else
                                Stuck = Stuck + 1
                                if Stuck > 20 then
                                    --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: Stucked while moving to target. Stuck='..Stuck)
                                    self:Stop()
                                    break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                                end
                            end
                            -- If we lose our target, stop moving to it.
                            if not target then
                                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: Lost target while moving to target. ')
                                self:Stop()
                                return
                            end
                            SWARMWAIT(10)
                        end
                    else
                        --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheckSwarm.')
                        if not ExperimentalInPlatoon then
                            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, TargetPosition, true, false)
                        end
                        if not usedTransports then
                            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: CanPathTo() and SendPlatoonWithTransportsNoCheckSwarm failed. SimpleReturnToBase!')
                            local PlatoonPos = self:GetPlatoonPosition()
                            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
                            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                            if DistanceToBase < DistanceToTarget and DistanceToTarget > 50 then
                                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: base is nearer then distance to target and distance to target over 50. Return To base')
                                self:SimpleReturnToBaseSwarm(basePosition)
                            else
                                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: Direct move to Target')
                                if bAggroMove then
                                    self:AggressiveMoveToLocation(TargetPosition)
                                else
                                    self:MoveToLocation(TargetPosition, false)
                                end
                            end
                        else
                            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: CanPathTo() failed BUT we got an transport!!')
                        end

                    end
                else
                    --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: We have no path but there is a Graph with markers. So why we don\'t get a path ??? (Island or threat too high?) - reason: '..repr(reason))
                end
            end
        else
            if HERODEBUGSwarm then
                self:RenamePlatoonSwarm('TRANSPORTED')
                SWARMWAIT(1)
            end
            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: TRANSPORTED.')
        end
    end,

    TransferAISwarm = function(self)
        local aiBrain = self:GetBrain()
        if not aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType] then
            --LOG('* AI-Swarm: * TransferAISwarm: Location ('..self.PlatoonData.MoveToLocationType..') has no BuilderManager!')
            self:PlatoonDisband()
            return
        end
        local eng = self:GetPlatoonUnits()[1]
        if eng and not eng.Dead and eng.BuilderManagerData.EngineerManager then
            --LOG('* AI-Swarm: * TransferAISwarm: '..repr(self.BuilderName))
            eng.BuilderManagerData.EngineerManager:RemoveUnit(eng)
            --LOG('* AI-Swarm: * TransferAISwarm: AddUnit units to - BuilderManagers: '..self.PlatoonData.MoveToLocationType..' - ' .. aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) )
            aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:AddUnit(eng, true)
            -- Move the unit to the desired base after transfering BuilderManagers to the new LocationType
            local basePosition = aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].Position
            --LOG('* AI-Swarm: * TransferAISwarm: Moving transfer-units to - ' .. self.PlatoonData.MoveToLocationType)
            self:MoveToLocationInclTransportSwarm(true, basePosition, false, false, basePosition, false)
        end
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    ReclaimAISwarm = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local eng
        for k, v in platoonUnits do
            if not v.Dead and SWARMENTITY(categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD, v) then
                eng = v
                break
            end
        end
        if eng then
            eng.UnitBeingBuilt = eng
            SwarmUtils.ReclaimSwarmAIThread(self,eng,aiBrain)
            eng.UnitBeingBuilt = nil
        end
        self:PlatoonDisband()
    end,

    -------------------------------------------------------
    --   Function: EngineerBuildAI
    --   Args:
    --       self - the single-engineer platoon to run the AI on
    --   Description:
    --       a single-unit platoon made up of an engineer, this AI will determine
    --       what needs to be built (based on platoon data set by the calling
    --       abstraction, and then issue the build commands to the engineer
    --   Returns:
    --       nil (tail calls into a behavior function)
    -------------------------------------------------------
    EngineerBuildAISwarm = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local armyIndex = aiBrain:GetArmyIndex()
        local x,z = aiBrain:GetArmyStartPos()
        local cons = self.PlatoonData.Construction
        local buildingTmpl, buildingTmplFile, baseTmpl, baseTmplFile, baseTmplDefault
        local eng
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.ENGINEER - categories.STATIONASSISTPOD, v) then --DUNCAN - was construction
                IssueClearCommands({v})
                if not eng then
                    eng = v
                else
                    IssueGuard({v}, eng)
                end
            end
        end

        if not eng or eng.Dead then
            SWARMWAIT(1)
            self:PlatoonDisband()
            return
        end

        --DUNCAN - added
        if eng:IsUnitState('Building') or eng:IsUnitState('Upgrading') or eng:IsUnitState("Enhancing") then
           return
        end

        local FactionToIndex  = { UEF = 1, AEON = 2, CYBRAN = 3, SERAPHIM = 4, NOMADS = 5}
        local factionIndex = cons.FactionIndex or FactionToIndex[eng.factionCategory]

        buildingTmplFile = import(cons.BuildingTemplateFile or '/lua/BuildingTemplates.lua')
        baseTmplFile = import(cons.BaseTemplateFile or '/lua/BaseTemplates.lua')
        baseTmplDefault = import('/lua/BaseTemplates.lua')
        buildingTmpl = buildingTmplFile[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
        baseTmpl = baseTmplFile[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]

        --LOG('*AI DEBUG: EngineerBuild AI ' .. eng.Sync.id)

        if self.PlatoonData.NeedGuard then
            eng.NeedGuard = true
        end

        -------- CHOOSE APPROPRIATE BUILD FUNCTION AND SETUP BUILD VARIABLES --------
        local reference = false
        local refName = false
        local buildFunction
        local closeToBuilder
        local relative
        local baseTmplList = {}

        -- if we have nothing to build, disband!
        if not cons.BuildStructures then
            SWARMWAIT(1)
            self:PlatoonDisband()
            return
        end
        if cons.NearUnitCategory then
            self:SetPrioritizedTargetList('support', {ParseEntityCategory(cons.NearUnitCategory)})
            local unitNearBy = self:FindPrioritizedUnit('support', 'Ally', false, self:GetPlatoonPosition(), cons.NearUnitRadius or 50)
            --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." attempt near: ", cons.NearUnitCategory)
            if unitNearBy then
                reference = SWARMCOPY(unitNearBy:GetPosition())
                -- get commander home position
                --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." Near unit: ", cons.NearUnitCategory)
                if cons.NearUnitCategory == 'COMMAND' and unitNearBy.CDRHome then
                    reference = unitNearBy.CDRHome
                end
            else
                reference = SWARMCOPY(eng:GetPosition())
            end
            relative = false
            buildFunction = AIBuildStructures.AIExecuteBuildStructureSwarm
            SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
        elseif cons.OrderedTemplate then
            local relativeTo = table.copy(eng:GetPosition())
            --LOG('relativeTo is'..repr(relativeTo))
            relative = true
            local tmpReference = aiBrain:FindPlaceToBuild('T2EnergyProduction', 'uab1201', baseTmplDefault['BaseTemplates'][factionIndex], relative, eng, nil, relativeTo[1], relativeTo[3])
            if tmpReference then
                reference = eng:CalculateWorldPositionFromRelative(tmpReference)
            else
                return
            end
            --LOG('reference is '..repr(reference))
            --LOG('World Pos '..repr(tmpReference))
            buildFunction = AIBuildStructures.AIBuildBaseTemplateOrderedSwarm
            SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            --LOG('baseTmpList is :'..repr(baseTmplList))
        elseif cons.Wall then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100
            relative = false
            reference = AIUtils.GetLocationNeedingWalls(aiBrain, 200, 4, 'STRUCTURE - WALLS', cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            SWARMINSERT(baseTmplList, 'Blank')
            buildFunction = AIBuildStructures.WallBuilder
        elseif cons.NearBasePatrolPoints then
            relative = false
            reference = AIUtils.GetBasePatrolPoints(aiBrain, cons.Location or 'MAIN', cons.Radius or 100)
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            for k,v in reference do
                SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, v))
            end
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            buildFunction = AIBuildStructures.AIBuildBaseTemplateOrderedSwarm
        elseif cons.FireBase and cons.FireBaseRange then
            --DUNCAN - pulled out and uses alt finder
            reference, refName = AIUtils.AIFindFirebaseLocation(aiBrain, cons.LocationType, cons.FireBaseRange, cons.NearMarkerType,
                                                cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType,
                                                cons.MarkerUnitCount, cons.MarkerUnitCategory, cons.MarkerRadius)
            if not reference or not refName then
                self:PlatoonDisband()
                return
            end

        elseif cons.NearMarkerType and cons.ExpansionBase then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100

            if cons.NearMarkerType == 'Expansion Area' then
                reference, refName = AIUtils.AIFindExpansionAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                    return
                end
            elseif cons.NearMarkerType == 'Naval Area' then
                reference, refName = AIUtils.AIFindNavalAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                    return
                end
            else
                --DUNCAN - use my alternative expansion finder on large maps below a certain time
                local mapSizeX, mapSizeZ = GetMapSize()
                if GetGameTimeSeconds() <= 780 and mapSizeX > 512 and mapSizeZ > 512 then
                    reference, refName = AIUtils.AIFindFurthestStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                    if not reference or not refName then
                        reference, refName = AIUtils.AIFindStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                            (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                    end
                else
                    reference, refName = AIUtils.AIFindStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                end
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                    return
                end
            end

            -- If moving far from base, tell the assisting platoons to not go with
            if cons.FireBase or cons.ExpansionBase then
                local guards = eng:GetGuards()
                for k,v in guards do
                    if not v.Dead and v.PlatoonHandle then
                        v.PlatoonHandle:PlatoonDisband()
                    end
                end
            end

            if not cons.BaseTemplate and (cons.NearMarkerType == 'Naval Area' or cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, eng, cons)
            end
            relative = false
            if reference and aiBrain:GetThreatAtPosition(reference , 1, true, 'AntiSurface') > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            --buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
            buildFunction = AIBuildStructures.AIBuildBaseTemplate
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindDefensivePointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructureSwarm
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Naval Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindNavalDefensivePointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructureSwarm
        elseif cons.NearMarkerType and (cons.NearMarkerType == 'Rally Point' or cons.NearMarkerType == 'Protected Experimental Construction') then
            --DUNCAN - add so experimentals build on maps with no markers.
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if not reference then
                reference = pos
            end
            SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            buildFunction = AIBuildStructures.AIExecuteBuildStructureSwarm
        elseif cons.NearMarkerType then
            --WARN('*Data weird for builder named - ' .. self.BuilderName)
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            if not cons.BaseTemplate and (cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, (cons.ExpansionRadius or 100), cons.ExpansionTypes, nil, cons)
            end
            if reference and aiBrain:GetThreatAtPosition(reference, 1, true) > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            SWARMINSERT(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            buildFunction = AIBuildStructures.AIExecuteBuildStructureSwarm
        elseif cons.AvoidCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager.Location
            local cat = cons.AdjacencyCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(cat) == 'string' then
                cat = ParseEntityCategory(cat)
            end
            local avoidCat = cons.AvoidCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(avoidCat) == 'string' then
                avoidCat = ParseEntityCategory(avoidCat)
            end
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                SWARMWAIT(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.FindUnclutteredArea(aiBrain, cat, pos, radius, cons.maxUnits, cons.maxRadius, avoidCat)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            SWARMINSERT(baseTmplList, baseTmpl)
        elseif cons.AdjacencyPriority then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager.Location
            local cats = {}
            --LOG('setting up adjacencypriority... cats are '..repr(cons.AdjacencyPriority))
            for _,v in cons.AdjacencyPriority do
                SWARMINSERT(cats,v)
            end
            reference={}
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            for i,cat in cats do
                -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
                if type(cat) == 'string' then
                    cat = ParseEntityCategory(cat)
                end
                local radius = (cons.AdjacencyDistance or 50)
                local refunits=AIUtils.GetOwnUnitsAroundPoint(aiBrain, cat, pos, radius, cons.ThreatMin,cons.ThreatMax, cons.ThreatRings)
                SWARMINSERT(reference,refunits)
                --LOG('cat '..i..' had '..repr(SWARMGETN(refunits))..' units')
            end
            buildFunction = AIBuildStructures.AIBuildAdjacencyPrioritySwarm
            SWARMINSERT(baseTmplList, baseTmpl)
        elseif cons.AdjacencyCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager.Location
            local cat = cons.AdjacencyCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(cat) == 'string' then
                cat = ParseEntityCategory(cat)
            end
            local radius = (cons.AdjacencyDistance or 50)
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                SWARMWAIT(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.GetOwnUnitsAroundPoint(aiBrain, cat, pos, radius, cons.ThreatMin,
                                                        cons.ThreatMax, cons.ThreatRings)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            SWARMINSERT(baseTmplList, baseTmpl)
        else
            SWARMINSERT(baseTmplList, baseTmpl)
            relative = true
            reference = true
            buildFunction = AIBuildStructures.AIExecuteBuildStructureSwarm
        end
        if cons.BuildClose then
            closeToBuilder = eng
        end
        if cons.BuildStructures[1] == 'T1Resource' or cons.BuildStructures[1] == 'T2Resource' or cons.BuildStructures[1] == 'T3Resource' then
            relative = true
            closeToBuilder = eng
            local guards = eng:GetGuards()
            for k,v in guards do
                if not v.Dead and v.PlatoonHandle and aiBrain:PlatoonExists(v.PlatoonHandle) then
                    v.PlatoonHandle:PlatoonDisband()
                end
            end
        end

        --LOG("*AI DEBUG: Setting up Callbacks for " .. eng.Sync.id)
        self.SetupEngineerCallbacksSwarm(eng)

        -------- BUILD BUILDINGS HERE --------
        for baseNum, baseListData in baseTmplList do
            for k, v in cons.BuildStructures do
                if aiBrain:PlatoonExists(self) then
                    if not eng.Dead then
                        local faction = SUtils.GetEngineerFaction(eng)
                        if aiBrain.CustomUnits[v] and aiBrain.CustomUnits[v][faction] then
                            local replacement = SUtils.GetTemplateReplacement(aiBrain, v, faction, buildingTmpl)
                            if replacement then
                                buildFunction(aiBrain, eng, v, closeToBuilder, relative, replacement, baseListData, reference, cons)
                            else
                                buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons)
                            end
                        else
                            buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons)
                        end
                    else
                        if aiBrain:PlatoonExists(self) then
                            SWARMWAIT(1)
                            self:PlatoonDisband()
                            return
                        end
                    end
                end
            end
        end

        -- wait in case we're still on a base
        local count = 0
        while not eng.Dead and eng:IsUnitState('Attached') and count < 2 do
            SWARMWAIT(60)
            count = count + 1
        end

        if not eng.Dead and not eng:IsUnitState('Building') then
            return self.ProcessBuildCommandSwarm(eng, false)
        end
    end,

    SetupEngineerCallbacksSwarm = function(eng)
        if eng and not eng.Dead and not eng.BuildDoneCallbackSet and eng.PlatoonHandle and PlatoonExists(eng:GetAIBrain(), eng.PlatoonHandle) then
            import('/lua/ScenarioTriggers.lua').CreateUnitBuiltTrigger(eng.PlatoonHandle.EngineerBuildDoneSwarm, eng, categories.ALLUNITS)
            eng.BuildDoneCallbackSet = true
        end
        if eng and not eng.Dead and not eng.CaptureDoneCallbackSet and eng.PlatoonHandle and PlatoonExists(eng:GetAIBrain(), eng.PlatoonHandle) then
            import('/lua/ScenarioTriggers.lua').CreateUnitStopCaptureTrigger(eng.PlatoonHandle.EngineerCaptureDoneSwarm, eng)
            eng.CaptureDoneCallbackSet = true
        end
        if eng and not eng.Dead and not eng.ReclaimDoneCallbackSet and eng.PlatoonHandle and PlatoonExists(eng:GetAIBrain(), eng.PlatoonHandle) then
            import('/lua/ScenarioTriggers.lua').CreateUnitStopReclaimTrigger(eng.PlatoonHandle.EngineerReclaimDoneSwarm, eng)
            eng.ReclaimDoneCallbackSet = true
        end
        if eng and not eng.Dead and not eng.FailedToBuildCallbackSet and eng.PlatoonHandle and PlatoonExists(eng:GetAIBrain(), eng.PlatoonHandle) then
            import('/lua/ScenarioTriggers.lua').CreateOnFailedToBuildTrigger(eng.PlatoonHandle.EngineerFailedToBuildSwarm, eng)
            eng.FailedToBuildCallbackSet = true
        end
    end,

    EngineerBuildDoneSwarm = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAISwarm' then return end
        --LOG("*AI DEBUG: Build done " .. unit.Sync.id)
        if not unit.ProcessBuild then
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSwarm, true)
            unit.ProcessBuildDone = true
        end
    end,
    EngineerCaptureDoneSwarm = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAISwarm' then return end
        --LOG("*AI DEBUG: Capture done" .. unit.Sync.id)
        if not unit.ProcessBuild then
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSwarm, false)
        end
    end,
    EngineerReclaimDoneSwarm = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAISwarm' then return end
        --LOG("*AI DEBUG: Reclaim done" .. unit.Sync.id)
        if not unit.ProcessBuild then
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSwarm, false)
        end
    end,
    EngineerFailedToBuildSwarm = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAISwarm' then return end
        if unit.UnitBeingBuiltBehavior then
            if unit.ProcessBuild then
                KillThread(unit.ProcessBuild)
                unit.ProcessBuild = nil
            end
            return
        end
        if unit.ProcessBuildDone and unit.ProcessBuild then
            KillThread(unit.ProcessBuild)
            unit.ProcessBuild = nil
        end
        if not unit.ProcessBuild then
            --LOG("*AI DEBUG: Failed to build" .. unit.Sync.id)
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSwarm, false) 
        end
    end,

    -------------------------------------------------------
    --   Function: ProcessBuildCommand
    --   Args:
    --       eng - the engineer that's gone through EngineerBuildAI
    --   Description:
    --       Run after every build order is complete/fails.  Sets up the next
    --       build order in queue, and if the engineer has nothing left to do
    --       will return the engineer back to the army pool by disbanding the
    --       the platoon.  Support function for EngineerBuildAI
    --   Returns:
    --       nil (tail calls into a behavior function)
    -------------------------------------------------------
    ProcessBuildCommandSwarm = function(eng, removeLastBuild)
        if not eng or eng.Dead or not eng.PlatoonHandle then
            return
        end
        local aiBrain = eng.PlatoonHandle:GetBrain()
        local engPos = eng:GetPosition()

        if not aiBrain or eng.Dead or not eng.EngineerBuildQueue or SWARMEMPTY(eng.EngineerBuildQueue) then
            if aiBrain:PlatoonExists(eng.PlatoonHandle) then
                if not eng.AssistSet and not eng.AssistPlatoon and not eng.UnitBeingAssist then
                    eng.PlatoonHandle:PlatoonDisband()
                end
            end
            if eng then eng.ProcessBuild = nil end
            return
        end

        -- it wasn't a failed build, so we just finished something
        if removeLastBuild then
            SWARMREMOVE(eng.EngineerBuildQueue, 1)
        end

        eng.ProcessBuildDone = false
        IssueClearCommands({eng})
        local commandDone = false
        local PlatoonPos
        while not eng.Dead and not commandDone and not SWARMEMPTY(eng.EngineerBuildQueue)  do
            local whatToBuild = eng.EngineerBuildQueue[1][1]
            local buildLocation = {eng.EngineerBuildQueue[1][2][1], 0, eng.EngineerBuildQueue[1][2][2]}
            if GetTerrainHeight(buildLocation[1], buildLocation[3]) > GetSurfaceHeight(buildLocation[1], buildLocation[3]) then
                --land
                buildLocation[2] = GetTerrainHeight(buildLocation[1], buildLocation[3])
            else
                --water
                buildLocation[2] = GetSurfaceHeight(buildLocation[1], buildLocation[3])
            end
            local buildRelative = eng.EngineerBuildQueue[1][3]
            if not eng.NotBuildingThread then
                eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuildingSwarm)
            end
            -- see if we can move there first
            if AIUtils.EngineerMoveWithSafePathSwarm(aiBrain, eng, buildLocation) then
                if not eng or eng.Dead or not eng.PlatoonHandle or not aiBrain:PlatoonExists(eng.PlatoonHandle) then
                    if eng then eng.ProcessBuild = nil end
                    return
                end
                -- issue buildcommand to block other engineers from caping mex/hydros or to reserve the buildplace
                aiBrain:BuildStructure(eng, whatToBuild, {buildLocation[1], buildLocation[3], 0}, buildRelative)
                -- wait until we are close to the buildplace so we have intel
                local engStuckCount = 0
                local Lastdist
                local dist
                while not eng.Dead do
                    PlatoonPos = eng:GetPosition()
                    dist = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, buildLocation[1] or 0, buildLocation[3] or 0)
                    if dist < 12 then
                        break
                    end
                    if Lastdist ~= dist then
                        engStuckCount = 0
                        Lastdist = dist
                    else
                        engStuckCount = engStuckCount + 1
                        --LOG('* AI-Swarm: * EngineerBuildAISwarm: has no moved during move to build position look, adding one, current is '..engStuckCount)
                        if engStuckCount > 40 and not eng:IsUnitState('Building') then
                            --LOG('* AI-Swarm: * EngineerBuildAISwarm: Stuck while moving to build position. Stuck='..engStuckCount)
                            break
                        end
                    end
                    if (whatToBuild == 'ueb1103' or whatToBuild == 'uab1103' or whatToBuild == 'urb1103' or whatToBuild == 'xsb1103') then
                        if aiBrain:GetNumUnitsAroundPoint(categories.STRUCTURE * categories.MASSEXTRACTION, buildLocation, 1, 'Ally') > 0 then
                            --LOG('Extractor already present with 1 radius, return')
                            eng.PlatoonHandle:Stop()
                            return
                        end
                    end
                    if eng:IsUnitState("Moving") or eng:IsUnitState("Capturing") then
                        if GetNumUnitsAroundPoint(aiBrain, categories.LAND * categories.ENGINEER * (categories.TECH1 + categories.TECH2), PlatoonPos, 10, 'Enemy') > 0 then
                            local enemyEngineer = GetUnitsAroundPoint(aiBrain, categories.LAND * categories.ENGINEER * (categories.TECH1 + categories.TECH2), PlatoonPos, 10, 'Enemy')
                            if enemyEngineer then
                                local enemyEngPos
                                for _, unit in enemyEngineer do
                                    if unit and not unit.Dead and unit:GetFractionComplete() == 1 then
                                        enemyEngPos = unit:GetPosition()
                                        if VDist2Sq(PlatoonPos[1], PlatoonPos[3], enemyEngPos[1], enemyEngPos[3]) < 100 then
                                            IssueStop({eng})
                                            IssueClearCommands({eng})
                                            IssueReclaim({eng}, enemyEngineer[1])
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if eng.Upgrading or eng.Combat then
                        return
                    end
                    SWARMWAIT(7)
                end
                if not eng or eng.Dead or not eng.PlatoonHandle or not aiBrain:PlatoonExists(eng.PlatoonHandle) then
                    if eng then eng.ProcessBuild = nil end
                    return
                end
                -- cancel all commands, also the buildcommand for blocking mex to check for reclaim or capture
                eng.PlatoonHandle:Stop()
                -- check to see if we need to reclaim or capture...
                SwarmUtils.EngineerTryReclaimCaptureAreaSwarm(aiBrain, eng, buildLocation)
                -- check to see if we can repair
                AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, buildLocation)
                -- otherwise, go ahead and build the next structure there
                aiBrain:BuildStructure(eng, whatToBuild, {buildLocation[1], buildLocation[3], 0}, buildRelative)
                -- Credit to Chp2001/Relent0r for this block of code
                if (whatToBuild == 'ueb1103' or whatToBuild == 'uab1103' or whatToBuild == 'urb1103' or whatToBuild == 'xsb1103') and eng.PlatoonHandle.PlatoonData.Construction.RepeatBuild then
                    --LOG('What to build was a mass extractor')
                    if EntityCategoryContains(categories.ENGINEER - categories.COMMAND, eng) then
                        local MexQueueBuild, MassMarkerTable = MABC.CanBuildOnMassEngSwarm(aiBrain, buildLocation, 30)
                        if MexQueueBuild then
                            --LOG('We can build on a mass marker within 30')
                            --LOG(repr(MassMarkerTable))
                            for _, v in MassMarkerTable do
                                SwarmUtils.EngineerTryReclaimCaptureAreaSwarm(aiBrain, eng, v.MassSpot.position, 5)
                                AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, v.MassSpot.position)
                                aiBrain:BuildStructure(eng, whatToBuild, {v.MassSpot.position[1], v.MassSpot.position[3], 0}, buildRelative)
                                local newEntry = {whatToBuild, {v.MassSpot.position[1], v.MassSpot.position[3], 0}, buildRelative}
                                SWARMINSERT(eng.EngineerBuildQueue, newEntry)
                            end
                        else
                            --LOG('Cant find mass within distance')
                        end
                    end
                end
                if not eng.NotBuildingThread then
                    eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuildingSwarm)
                end
                commandDone = true
            else
                -- we can't move there, so remove it from our build queue
                SWARMREMOVE(eng.EngineerBuildQueue, 1)
            end
            SWARMWAIT(2)
        end
        --LOG('EnginerBuildQueue : '..SWARMGETN(eng.EngineerBuildQueue)..' Contents '..repr(eng.EngineerBuildQueue))
        -- Credit to Chp2001/Relent0r for this block of code
        if not eng.Dead and SWARMGETN(eng.EngineerBuildQueue) <= 0 and eng.PlatoonHandle.PlatoonData.Construction.RepeatBuild then
            --LOG('Starting RepeatBuild')
            local engpos = eng:GetPosition()
            if eng.PlatoonHandle.PlatoonData.Construction.RepeatBuild and eng.PlatoonHandle.PlanName then
                --LOG('Repeat Build is set for :'..eng.Sync.id)
                if eng.PlatoonHandle.PlatoonData.Construction.Type == 'Mass' then
                    eng.PlatoonHandle:EngineerBuildAISwarm()
                else
                    WARN('Invalid Construction Type or Distance, Expected : Mass, number')
                end
            end
        end

        -- final check for if we should disband
        if not eng or eng.Dead or SWARMEMPTY(eng.EngineerBuildQueue) then
            if eng.PlatoonHandle and PlatoonExists(aiBrain, eng.PlatoonHandle) and not eng.PlatoonHandle.UsingTransport then
                if eng.PlatoonHandle.Construction.Construction.RepeatBuild and eng.PlatoonHandle.PlanName then
                    eng:SetAIPlan( platoon.PlanName, aiBrain)
                    return
                else
                    eng.PlatoonHandle:PlatoonDisband()
                end
            end
        end
        if eng then eng.ProcessBuild = nil end
    end,

    WatchForNotBuildingSwarm = function(eng)
        SWARMWAIT(10)
        local aiBrain = eng:GetAIBrain()
        local engPos = eng:GetPosition()

        while not eng.Dead and not eng.PlatoonHandle.UsingTransport and (eng.GoingHome or eng.UnitBeingBuiltBehavior or eng.ProcessBuild != nil or not eng:IsIdleState()) do
            SWARMWAIT(30)
            if eng:IsUnitState("Moving") or eng:IsUnitState("Capturing") then
                if GetNumUnitsAroundPoint(aiBrain, categories.LAND * categories.ENGINEER * (categories.TECH1 + categories.TECH2), engPos, 10, 'Enemy') > 0 then
                    local enemyEngineer = GetUnitsAroundPoint(aiBrain, categories.LAND * categories.ENGINEER * (categories.TECH1 + categories.TECH2), engPos, 10, 'Enemy')
                    local enemyEngPos = enemyEngineer[1]:GetPosition()
                    if VDist2Sq(engPos[1], engPos[3], enemyEngPos[1], enemyEngPos[3]) < 100 then
                        IssueStop({eng})
                        IssueClearCommands({eng})
                        IssueReclaim({eng}, enemyEngineer[1])
                    end
                end
            end
        end

        eng.NotBuildingThread = nil
        if not eng.Dead and eng:IsIdleState() and not SWARMEMPTY(eng.EngineerBuildQueue) and eng.PlatoonHandle and not eng.WaitingForTransport then
            eng.PlatoonHandle.SetupEngineerCallbacksSwarm(eng)
            if not eng.ProcessBuild then
                --LOG('Forking Process Build Command with table remove')
                eng.ProcessBuild = eng:ForkThread(eng.PlatoonHandle.ProcessBuildCommandSwarm, true)
            end
        end
    end,

    -- Credit to Chp2001 for this function 
    -- Improved Function so it was not full of stuff that wasn't needed
    MexBuildAISwarm = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = GetPlatoonUnits(self)
        local cons = self.PlatoonData.Construction
        local buildingTmpl, buildingTmplFile, baseTmpl, baseTmplFile, baseTmplDefault
        local eng=platoonUnits[1]
        local VDist2Sq = VDist2Sq
        self:Stop()
        if not eng or eng.Dead then
            SWARMWAIT(1)
            self:PlatoonDisband()
            return
        end

        if not eng.EngineerBuildQueue then  -- this is the first time we're getting to this engineer in this platoon so we need to reset the queue and build history table (if it exists)  -- added by brute51 [140805]  [140808] [140810] [140811] [140815] [140816] [140817] [140818] [140819] [140904]  -- also added by brute51 to fix a bug where the build history table was not being reset when engineers were reassigned to other platoons
            eng.EngineerBuildQueue={}
            if eng.EngineerBuildHistory then  -- this is the first time we're getting to this engineer in this platoon so we need to reset the queue and build history table (if it exists)  -- added by brute51 [140805]  [140808] [140810] [140811] [140815] [140816] [140817] [140818] [140819] [140904]  -- also added by brute51 to fix a bug where the build history table was not being reset when engineers were reassigned to other platoons
                eng.EngineerBuildHistory={}
            end
        end

        local factionIndex = aiBrain:GetFactionIndex()
        buildingTmplFile = import(cons.BuildingTemplateFile or '/lua/BuildingTemplates.lua')
        buildingTmpl = buildingTmplFile[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]

        --LOG("*AI DEBUG: Setting up Callbacks for " .. eng.Sync.id)
        --self.SetupEngineerCallbacksSwarm(eng)
        local whatToBuild = aiBrain:DecideWhatToBuild(eng, 'T1Resource', buildingTmpl)
        -- wait in case we're still on a base
        if not eng.Dead then
            local count = 0
            while eng:IsUnitState('Attached') and count < 2 do
                SWARMWAIT(60)
                count = count + 1
            end
        end

        --LOG('MexBuild Platoon Checking for expansion mex')

        while PlatoonExists(aiBrain, self) and eng and not eng.Dead do

            local platoonPos=self:GetPlatoonPosition()

            local currentmexpos=nil

            if not aiBrain.expansionMex then  -- this is the first time we're getting to this platoon so we need to reset the queue and build history table (if it exists)  -- added by brute51 [140805]  [140808] [140810] [140811] [140815] [140816] [140817] [140818] [140819] [140904]  -- also added by brute51 to fix a bug where the build history table was not being reset when engineers were reassigned to other platoons
                aiBrain.expansionMex={}
            end
            local markerTable=SWARMCOPY(aiBrain.expansionMex)

            SWARMSORT(markerTable,function(a,b) return VDist2Sq(a.Position[1],a.Position[3],platoonPos[1],platoonPos[3])/VDist3Sq(aiBrain.emanager.enemy.Position,a.Position)/a.priority/a.priority<VDist2Sq(b.Position[1],b.Position[3],platoonPos[1],platoonPos[3])/VDist3Sq(aiBrain.emanager.enemy.Position,b.Position)/b.priority/b.priority end)

            for _,v in markerTable do
                if aiBrain:CanBuildStructureAt('ueb1103', v.Position) then
                    currentmexpos=v.Position
                    break
                end
            end

            if not currentmexpos then self:PlatoonDisband() end

            --LOG('currentmexpos has data')

            if not AIUtils.EngineerMoveWithSafePathSwarmAdvanced(aiBrain, eng, currentmexpos, whatToBuild) then
                SWARMREMOVE(markerTable) 
                --LOG('No path to currentmexpos')
                --eng:SetCustomName('MexBuild Platoon has no path to aiBrain.currentmexpos, removing and moving to next')
                continue 
            end

            local firstmex=currentmexpos

            for _=0,3,1 do

                if not currentmexpos then break end

                local bool,markers=MABC.CanBuildOnMassEngSwarm(aiBrain, currentmexpos, 30)

                if bool then

                    --LOG('We can build on a mass marker within 30')

                    for _,massMarker in markers do

                        SwarmUtils.EngineerTryReclaimCaptureAreaSwarm(aiBrain, eng, massMarker.Position, 5)

                        AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, massMarker.Position)

                        --eng:SetCustomName('MexBuild Platoon attempting to build in for loop')

                        --LOG('MexBuild Platoon Checking for expansion mex')

                        aiBrain:BuildStructure(eng, whatToBuild, {massMarker.Position[1], massMarker.Position[3], 0}, false)

                        local newEntry = {whatToBuild, {massMarker.Position[1], massMarker.Position[3], 0}, false}
                        SWARMINSERT(eng.EngineerBuildQueue, newEntry)
                    end
                else
                    break
                end
            end

            while not eng.Dead and 0<SWARMGETN(eng:GetCommandQueue()) or eng:IsUnitState('Building') or eng:IsUnitState("Moving") do
                if eng:IsUnitState("Moving") and VDist3Sq(self:GetPlatoonPosition(),firstmex)<12*12 then
                    IssueClearCommands({eng})
                    for _,v in eng.EngineerBuildQueue do
                        SwarmUtils.EngineerTryReclaimCaptureAreaSwarm(aiBrain, eng, v.Position, 5)
                        AIUtils.EngineerTryRepair(aiBrain, eng, v[1], v.Position)
                        --eng:SetCustomName('MexBuild Platoon attempting to build in while loop')
                        --LOG('MexBuild Platoon Checking for expansion mex')
                        aiBrain:BuildStructure(eng, v[1],v[2],v[3])
                    end
                end

                SWARMWAIT(20)

            end

            --eng:SetCustomName('Reset EngineerBuildQueue')

            --LOG('Reset EngineerBuildQueue')

            eng.EngineerBuildQueue={}

        end

    end,

    -- 100% Relent0r's Work 
    ManagerEngineerAssistAISwarm = function(self)
        local aiBrain = self:GetBrain()
        local eng = GetPlatoonUnits(self)[1]
        self:EconAssistBodySwarm()
        SWARMWAIT(10)
        if eng.Upgrading or eng.Combat then
            --LOG('eng.Upgrading is True at start of assist function')
        end
        -- do we assist until the building is finished ?
        if self.PlatoonData.Assist.AssistUntilFinished then
            local guardedUnit
            if eng.UnitBeingAssist then
                guardedUnit = eng.UnitBeingAssist
            else 
                guardedUnit = eng:GetGuardedUnit()
            end
            -- loop as long as we are not dead and not idle
            while eng and not eng.Dead and PlatoonExists(aiBrain, self) and not eng:IsIdleState() do
                if not guardedUnit or guardedUnit.Dead or guardedUnit:BeenDestroyed() then
                    break
                end
                -- stop if our target is finished
                if guardedUnit:GetFractionComplete() == 1 and not guardedUnit:IsUnitState('Upgrading') then
                    --LOG('* ManagerEngineerAssistAI: Engineer Builder ['..self.BuilderName..'] - ['..self.PlatoonData.Assist.AssisteeType..'] - Target unit ['..guardedUnit:GetBlueprint().BlueprintId..'] ('..guardedUnit:GetBlueprint().Description..') is finished')
                    break
                end
                -- wait 1.5 seconds until we loop again
                if eng.Upgrading or eng.Combat then
                    --LOG('eng.Upgrading is True inside Assist function for assistuntilfinished')
                end
                SWARMWAIT(30)
            end
        else
            if eng.Upgrading or eng.Combat then
                --LOG('eng.Upgrading is True inside Assist function for assist time')
            end
            SWARMWAIT(self.PlatoonData.Assist.Time or 60)
        end
        if not PlatoonExists(aiBrain, self) then
            return
        end
        self.AssistPlatoon = nil
        eng.UnitBeingAssist = nil
        self:Stop()
        if eng.Upgrading then
            --LOG('eng.Upgrading is True')
        end
        self:PlatoonDisband()
    end,

    -- 100% Relent0r's Work 
    EconAssistBodySwarm = function(self)
        local aiBrain = self:GetBrain()
        local eng = GetPlatoonUnits(self)[1]
        if not eng or eng:IsUnitState('Building') or eng:IsUnitState('Upgrading') or eng:IsUnitState("Enhancing") then
           return
        end
        local assistData = self.PlatoonData.Assist
        if not assistData.AssistLocation then
            WARN('*AI WARNING: Builder '..repr(self.BuilderName)..' is missing AssistLocation')
            return
        end
        if not assistData.AssisteeType then
            WARN('*AI WARNING: Builder '..repr(self.BuilderName)..' is missing AssisteeType')
            return
        end
        eng.AssistPlatoon = self
        local assistee = false
        local assistRange = assistData.AssistRange or 80
        local platoonPos = self:GetPlatoonPosition()
        local beingBuilt = assistData.BeingBuiltCategories or { categories.ALLUNITS }
        local assisteeCat = assistData.AssisteeCategory or categories.ALLUNITS
        if type(assisteeCat) == 'string' then
            assisteeCat = ParseEntityCategory(assisteeCat)
        end

        -- loop through different categories we are looking for
        for _,category in beingBuilt do
            -- Track all valid units in the assist list so we can load balance for builders
            local assistList = SwarmUtils.GetAssisteesSwarm(aiBrain, assistData.AssistLocation, assistData.AssisteeType, category, assisteeCat)
            if SWARMGETN(assistList) > 0 then
                -- only have one unit in the list; assist it
                local low = false
                local bestUnit = false
                for k,v in assistList do
                    --DUNCAN - check unit is inside assist range 
                    local unitPos = v:GetPosition()
                    local UnitAssist = v.UnitBeingBuilt or v.UnitBeingAssist or v
                    local NumAssist = SWARMGETN(UnitAssist:GetGuards())
                    local dist = VDist2(platoonPos[1], platoonPos[3], unitPos[1], unitPos[3])
                    -- Find the closest unit to assist
                    if assistData.AssistClosestUnit then
                        if (not low or dist < low) and NumAssist < 20 and dist < assistRange then
                            low = dist
                            bestUnit = v
                        end
                    -- Find the unit with the least number of assisters; assist it
                    else
                        if (not low or NumAssist < low) and NumAssist < 20 and dist < assistRange then
                            low = NumAssist
                            bestUnit = v
                        end
                    end
                end
                assistee = bestUnit
                break
            end
        end
        -- assist unit
        if assistee  then
            self:Stop()
            eng.AssistSet = true
            eng.UnitBeingAssist = assistee.UnitBeingBuilt or assistee.UnitBeingAssist or assistee
            --LOG('* EconAssistBody: Assisting now: ['..eng.UnitBeingAssist:GetBlueprint().BlueprintId..'] ('..eng.UnitBeingAssist:GetBlueprint().Description..')')
            IssueGuard({eng}, eng.UnitBeingAssist)
        else
            self.AssistPlatoon = nil
            eng.UnitBeingAssist = nil
            if eng.Upgrading then
                --LOG('eng.Upgrading is True')
            end
            -- stop the platoon from endless assisting
            self:PlatoonDisband()
        end
    end,

    FinisherAISwarm = function(self)
        local aiBrain = self:GetBrain()
        if not self.PlatoonData or not self.PlatoonData.LocationType then
            self:PlatoonDisband()
            return
        end
        local eng = self:GetPlatoonUnits()[1]
        local engineerManager = aiBrain.BuilderManagers[self.PlatoonData.LocationType].EngineerManager
        if not engineerManager then
            self:PlatoonDisband()
            return
        end
        local unfinishedUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE + categories.EXPERIMENTAL, engineerManager.Location, engineerManager.Radius, 'Ally')
        for k,v in unfinishedUnits do
            local FractionComplete = v:GetFractionComplete()
            if FractionComplete < 1 and SWARMGETN(v:GetGuards()) < 1 then
                self:Stop()
                if not v.Dead and not v:BeenDestroyed() then -- Finisher AI would try to finish a dead or destoryed building.
                    IssueRepair(self:GetPlatoonUnits(), v)
                end
                break
            end
        end
        local count = 0
        repeat
            SWARMWAIT(20)
            if not aiBrain:PlatoonExists(self) then
                return
            end
            count = count + 1
            if eng:IsIdleState() then break end
        until count >= 30
        self:PlatoonDisband()
    end,

    SwarmPlatoonMerger = function(self)
        --LOG('* AI-Swarm: * SwarmPlatoonMerger: called from Builder: '..(self.BuilderName or 'Unknown'))
        local aiBrain = self:GetBrain()
        local PlatoonPlan = self.PlatoonData.AIPlan
        --LOG('* AI-Swarm: * SwarmPlatoonMerger: AIPlan: '..(PlatoonPlan or 'Unknown'))
        if not PlatoonPlan then
            return
        end
        -- Get all units from the platoon
        local platoonUnits = self:GetPlatoonUnits()
        -- check if we have already a Platoon with this AIPlan
        local AlreadyMergedPlatoon
        local PlatoonList = aiBrain:GetPlatoonsList()
        for _,Platoon in PlatoonList do
            if Platoon:GetPlan() == PlatoonPlan then
                --LOG('* AI-Swarm: * SwarmPlatoonMerger: Found Platton with plan '..PlatoonPlan)
                AlreadyMergedPlatoon = Platoon
                break
            end
            --LOG('* AI-Swarm: * SwarmPlatoonMerger: Found '..repr(Platoon:GetPlan()))
        end
        -- If we dont have already a platton for this AIPlan, create one.
        if not AlreadyMergedPlatoon then
            AlreadyMergedPlatoon = aiBrain:MakePlatoon( PlatoonPlan..'Platoon', PlatoonPlan )
            AlreadyMergedPlatoon.PlanName = PlatoonPlan
            AlreadyMergedPlatoon.BuilderName = PlatoonPlan..'Platoon'
--            AlreadyMergedPlatoon:UniquelyNamePlatoon(PlatoonPlan)
        end
        -- Add our unit(s) to the platoon
        aiBrain:AssignUnitsToPlatoon( AlreadyMergedPlatoon, platoonUnits, 'support', 'none' )
        -- transfer platoondata
        AlreadyMergedPlatoon.PlatoonData.SearchRadius = self.PlatoonData.SearchRadius
        AlreadyMergedPlatoon.PlatoonData.GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        AlreadyMergedPlatoon.PlatoonData.IgnorePathing = self.PlatoonData.IgnorePathing
        AlreadyMergedPlatoon.PlatoonData.DirectMoveEnemyBase = self.PlatoonData.DirectMoveEnemyBase
        AlreadyMergedPlatoon.PlatoonData.RequireTransport = self.PlatoonData.RequireTransport
        AlreadyMergedPlatoon.PlatoonData.AggressiveMove = self.PlatoonData.AggressiveMove
        AlreadyMergedPlatoon.PlatoonData.AttackEnemyStrength = self.PlatoonData.AttackEnemyStrength
        AlreadyMergedPlatoon.PlatoonData.TargetSearchCategory = self.PlatoonData.TargetSearchCategory
        AlreadyMergedPlatoon.PlatoonData.MoveToCategories = self.PlatoonData.MoveToCategories
        AlreadyMergedPlatoon.PlatoonData.WeaponTargetCategories = self.PlatoonData.WeaponTargetCategories
        AlreadyMergedPlatoon.PlatoonData.TargetHug = self.PlatoonData.TargetHug
        -- Disband this platoon, it's no longer needed.
        self:PlatoonDisbandNoAssign()
    end,

    -------------------------------------------------------
    --   Function: MergeWithNearbyPlatoons
    --   Args:
    --       self - the single platoon to run the AI on
    --       planName - AI plan to merge with
    --       radius - check to see if we should merge with platoons in this radius
    --   Description:
    --       Finds platoons nearby (when self platoon is not near a base) and merge
    --       with them if they're a good fit.
    --   Returns:
    --       nil
    -------------------------------------------------------
    MergeWithNearbyPlatoonsSwarm = function(self, planName, radius, maxMergeNumber)
        -- check to see we're not near an ally base
        local aiBrain = self:GetBrain()
        if not aiBrain then
            return
        end

        if self.UsingTransport then
            return
        end

        local platPos = self:GetPlatoonPosition()
        if not platPos then
            return
        end

        local platUnits = GetPlatoonUnits(self)
        local platCount = 0

        for _, u in platUnits do
            if not u.Dead then
                platCount = platCount + 1
            end
        end

        if (maxMergeNumber and platCount > maxMergeNumber) or platCount < 1 then
            return
        end 

        local radiusSq = radius*radius
        -- if we're too close to a base, forget it
        if aiBrain.BuilderManagers then
            for baseName, base in aiBrain.BuilderManagers do
                if VDist2Sq(platPos[1], platPos[3], base.Position[1], base.Position[3]) <= radiusSq then
                    return
                end
            end
        end

        AlliedPlatoons = aiBrain:GetPlatoonsList()
        local bMergedPlatoons = false
        for _,aPlat in AlliedPlatoons do
            if aPlat:GetPlan() != planName then
                continue
            end
            if aPlat == self then
                continue
            end

            if aPlat.UsingTransport then
                continue
            end

            local allyPlatPos = aPlat:GetPlatoonPosition()
            if not allyPlatPos or not aiBrain:PlatoonExists(aPlat) then
                continue
            end

            AIAttackUtils.GetMostRestrictiveLayer(self)
            AIAttackUtils.GetMostRestrictiveLayer(aPlat)

            -- make sure we're the same movement layer type to avoid hamstringing air of amphibious
            if self.MovementLayer != aPlat.MovementLayer then
                continue
            end

            if  VDist2Sq(platPos[1], platPos[3], allyPlatPos[1], allyPlatPos[3]) <= radiusSq then
                local units = aPlat:GetPlatoonUnits()
                local validUnits = {}
                local bValidUnits = false
                for _,u in units do
                    if not u.Dead and not u:IsUnitState('Attached') then
                        SWARMINSERT(validUnits, u)
                        bValidUnits = true
                    end
                end
                if not bValidUnits then
                    continue
                end
                --LOG("*AI DEBUG: Merging platoons " .. self.BuilderName .. ": (" .. platPos[1] .. ", " .. platPos[3] .. ") and " .. aPlat.BuilderName .. ": (" .. allyPlatPos[1] .. ", " .. allyPlatPos[3] .. ")")
                aiBrain:AssignUnitsToPlatoon(self, validUnits, 'Attack', 'GrowthFormation')
                bMergedPlatoons = true
            end
        end
        if bMergedPlatoons then
            self:StopAttack()
            return true
        end

        return false
    end,

    SimpleReturnToBaseSwarm = function(self, basePosition)
        if not basePosition or type(basePosition) ~= 'table' then
            WARN('* AI-Swarm: SimpleReturnToBaseSwarm: basePosition nil or not a table ['..repr(basePosition)..']')
            return
        end
        local aiBrain = self:GetBrain()
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        self:Stop()
        self:MoveToLocation(basePosition, false)
        while aiBrain:PlatoonExists(self) do
            PlatoonPosition = self:GetPlatoonPosition()
            if not PlatoonPosition then
                --LOG('* AI-Swarm: SimpleReturnToBaseSwarm: no Platoon Position')
                break
            end
            dist = VDist2( basePosition[1], basePosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            if dist < 20 then
                break
            end
            -- Do we move ?
            if Lastdist ~= dist then
                Stuck = 0
                Lastdist = dist
            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
            else
                Stuck = Stuck + 1
                if Stuck > 20 then
                    self:Stop()
                    break
                end
            end
            SWARMWAIT(10)
        end
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    ReturnToBaseAISwarm = function(self, mainBase)

        local aiBrain = self:GetBrain()

        if not PlatoonExists(aiBrain, self) or not GetPlatoonPosition(self) then
            return
        end

        local bestBase = false
        local bestBaseName = ""
        local bestDistSq = 999999999
        local platPos = GetPlatoonPosition(self)
        AIAttackUtils.GetMostRestrictiveLayer(self)

        if not mainBase then
            for baseName, base in aiBrain.BuilderManagers do
                local distSq = VDist2Sq(platPos[1], platPos[3], base.Position[1], base.Position[3])

                if distSq < bestDistSq then
                    bestBase = base
                    bestBaseName = baseName
                    bestDistSq = distSq
                end
            end
        else
            bestBase = aiBrain.BuilderManagers['MAIN']
        end
        
        if bestBase then
            if self.MovementLayer == 'Air' then
                self:Stop()
                self:MoveToLocation(bestBase.Position, false)
                --LOG('Air Unit Return to base provided position :'..repr(bestBase.Position))
                while PlatoonExists(aiBrain, self) do
                    local currentPlatPos = self:GetPlatoonPosition()
                    --LOG('Air Unit Distance from platoon to bestBase position for Air units is'..VDist2Sq(currentPlatPos[1], currentPlatPos[3], bestBase.Position[1], bestBase.Position[3]))
                    --LOG('Air Unit Platoon Position is :'..repr(currentPlatPos))
                    local distSq = VDist2Sq(currentPlatPos[1], currentPlatPos[3], bestBase.Position[1], bestBase.Position[3])
                    if distSq < 6400 then
                        break
                    end
                    WaitTicks(15)
                end
            else
                local path, reason = AIAttackUtils.PlatoonGenerateSafePathToSwarm(aiBrain, self.MovementLayer, GetPlatoonPosition(self), bestBase.Position, 10)
                IssueClearCommands(self)
                if path then
                    local pathLength = SWARMGETN(path)
                    for i=1, pathLength-1 do
                        self:MoveToLocation(path[i], false)
                        local oldDistSq = 0
                        while PlatoonExists(aiBrain, self) do
                            platPos = GetPlatoonPosition(self)
                            local distSq = VDist2Sq(platPos[1], platPos[3], bestBase.Position[1], bestBase.Position[3])
                            if distSq < 400 then
                                self:PlatoonDisband()
                                return
                            end
                            -- if we haven't moved in 10 seconds... go back to attacking
                            if (distSq - oldDistSq) < 25 then
                                break
                            end
                            oldDistSq = distSq
                            WaitTicks(20)
                        end
                    end
                end
                self:MoveToLocation(bestBase.Position, false)
            end
        end
        -- return 
        self:PlatoonDisband()
    end,

    ForceReturnToNearestBaseAISwarm = function(self)
        local platPos = self:GetPlatoonPosition() or false
        if not platPos then
            return
        end
        local aiBrain = self:GetBrain()
        local nearestbase = false
        for k,v in aiBrain.BuilderManagers do
            -- check if we can move to this base
            if not AIUtils.ValidateLayerSwarm(v.FactoryManager.Location,self.MovementLayer) then
                --LOG('* AI-Swarm: ForceReturnToNearestBaseAISwarm Can\'t return to This base. Wrong movementlayer: '..repr(v.FactoryManager.LocationType))
                continue
            end
            local dist = VDist2( platPos[1], platPos[3], v.FactoryManager.Location[1], v.FactoryManager.Location[3] )
            if not nearestbase or nearestbase.dist > dist then
                nearestbase = {}
                nearestbase.Pos = v.FactoryManager.Location
                nearestbase.dist = dist
            end
        end
        if not nearestbase then
            return
        end
        self:Stop()
        self:MoveToLocationInclTransportSwarm(true, nearestbase.Pos, false, false, nearestbase.Pos, false)
        -- Disband the platoon so the locationmanager can assign a new task to the units.
        if HERODEBUGSwarm then
            self:RenamePlatoonSwarm('Disbanding in 3 sec.')
        end
        SWARMWAIT(30)
        if HERODEBUGSwarm then
            self:RenamePlatoonSwarm('Disbanded')
        end
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    ForceReturnToNavalBaseAISwarm = function(self, aiBrain, basePosition)
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Water' , self:GetPlatoonPosition(), basePosition, 1000, 512)
        -- clear commands, so we don't get stuck if we have an unreachable destination
        IssueClearCommands(self:GetPlatoonUnits())
        if path then
            if SWARMGETN(path) > 1 then
                --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: SWARMGETN(path): '..SWARMGETN(path))
            end
            --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: moving to destination by path.')
            for i=1, SWARMGETN(path) do
                --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: moving to destination. i: '..i..' coords '..repr(path[i]))
                self:MoveToLocation(path[i], false)
                --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: moving to Waypoint')
                local PlatoonPosition
                local Lastdist
                local dist
                local Stuck = 0
                while aiBrain:PlatoonExists(self) do
                    PlatoonPosition = self:GetPlatoonPosition()
                    dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                    -- are we closer then 15 units from the next marker ? Then break and move to the next marker
                    if dist < 20 then
                        -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                        self:Stop()
                        break
                    end
                    -- Do we move ?
                    if Lastdist ~= dist then
                        Stuck = 0
                        Lastdist = dist
                    -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                    else
                        Stuck = Stuck + 1
                        if Stuck > 15 then
                            --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                            self:Stop()
                            break
                        end
                    end
                    SWARMWAIT(10)
                end
            end
        else
            --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: we have no Graph to reach the destination. Checking CanPathTo()')
            if reason == 'NoGraph' then
                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, basePosition)
                if success then
                    --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: found a way with CanPathTo(). moving to destination')
                    self:MoveToLocation(basePosition, false)
                else
                    --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: CanPathTo() failed for '..repr(basePosition)..'.')
                end
            end
        end
        local oldDist = 100000
        local platPos = self:GetPlatoonPosition() or basePosition
        local Stuck = 0
        while aiBrain:PlatoonExists(self) do
            self:MoveToLocation(basePosition, false)
            --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: Waiting for moving to base')
            platPos = self:GetPlatoonPosition() or basePosition
            dist = VDist2(platPos[1], platPos[3], basePosition[1], basePosition[3])
            if dist < 20 then
                --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: We are home! disband!')
                -- Wait some second, so all platoon units have time to reach the base.
                SWARMWAIT(50)
                self:Stop()
                break
            end
            -- if we haven't moved in 5 seconds... leave the loop
            if oldDist - dist < 0 then
                break
            end
            oldDist = dist
            Stuck = Stuck + 1
            if Stuck > 4 then
                self:Stop()
                break
            end
            SWARMWAIT(50)
        end
        -- Disband the platoon so the locationmanager can assign a new task to the units.
        SWARMWAIT(30)
        self:PlatoonDisband()
    end,

    S3AntiNukeAI = function(self)
        local aiBrain = self:GetBrain()
        while aiBrain:PlatoonExists(self) do
            local platoonUnits = self:GetPlatoonUnits()
            -- find dead units inside the platoon and disband if we find one
            for k,unit in platoonUnits do
                if not unit or unit.Dead or unit:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                    self:PlatoonDisbandNoAssign()
                    --LOG('* AI-Swarm: * U3AntiNukeAI: PlatoonDisband')
                    return
                else
                    unit:SetAutoMode(true)
                end
            end
            SWARMWAIT(50)
        end
    end,

    S34ArtilleryAI = function(self)
        local aiBrain = self:GetBrain()
        local ClosestTarget = nil
        local LastTarget = nil
        while aiBrain:PlatoonExists(self) do
            -- Primary Target
            ClosestTarget = nil
            -- We always use the PrimaryTarget from the targetmanager first:
            if aiBrain.PrimaryTarget and not aiBrain.PrimaryTarget.Dead then
                ClosestTarget = aiBrain.PrimaryTarget
            else
                -- We have no PrimaryTarget from the tagetmanager.
                -- That means there is no paragon, no experimental and no Tech3 Factories left as target.
                -- No need to search for any of this here.
            end
            -- in case we found a target, attack it until it's dead or we have another Primary Target
            if ClosestTarget == LastTarget then
                --LOG('* AI-Swarm: * U34ArtilleryAI: ClosestTarget == LastTarget')
            elseif ClosestTarget and not ClosestTarget.Dead then
                local BlueprintID = ClosestTarget:GetBlueprint().BlueprintId
                LastTarget = ClosestTarget
                -- Wait until the target is dead
                while ClosestTarget and not ClosestTarget.Dead do
                    -- leave the loop if the primary target has changed
                    if aiBrain.PrimaryTarget and aiBrain.PrimaryTarget ~= ClosestTarget then
                        break
                    end
                    platoonUnits = self:GetPlatoonUnits()
                    for _, Arty in platoonUnits do
                        if not Arty or Arty.Dead then
                            return
                        end
                        local Target = Arty:GetTargetEntity()
                        if Target == ClosestTarget then
                            --Arty:SetCustomName('continue '..BlueprintID)
                        else
                            --Arty:SetCustomName('Attacking '..BlueprintID)
                            --IssueStop({v})
                            IssueClearCommands({Arty})
                            SWARMWAIT(1)
                            if ClosestTarget and not ClosestTarget.Dead then
                                IssueAttack({Arty}, ClosestTarget)
                            end
                        end
                    end
                    SWARMWAIT(50)
                end
            end
            -- Reaching this point means we have no special target and our arty is using it's own weapon target priorities.
            -- So we are still attacking targets at this point.
            SWARMWAIT(50)
        end
    end,

    NukePlatoonAISwarm = function(self)
        local NUKEDEBUG = false
        local aiBrain = self:GetBrain()
        local ECOLoopCounter = 0
        local mapSizeX, mapSizeZ = GetMapSize()
        local platoonUnits
        local LauncherFull
        local LauncherReady
        local ExperimentalLauncherReady
        local LauncherCount
        local EnemyAntiMissile
        local EnemyUnits
        local EnemyTargetPositions
        local MissileCount
        local EnemyTarget
        local NukeSiloAmmoCount
        local TargetPosition

        while aiBrain:PlatoonExists(self) do
            ---------------------------------------------------------------------------------------------------
            -- Count Launchers, set them to automode, count stored missiles
            ---------------------------------------------------------------------------------------------------
            platoonUnits = self:GetPlatoonUnits()
            LauncherFull = {}
            LauncherReady = {}
            ExperimentalLauncherReady = {}
            HighMissileCountLauncherReady = {}
            MissileCount = 0
            LauncherCount = 0
            HighestMissileCount = 0
            NukeSiloAmmoCount = 0
            NukeLaunched = false
            SWARMWAIT(100)
            platoonUnits = self:GetPlatoonUnits()
            for _, Launcher in platoonUnits do
                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    self:PlatoonDisbandNoAssign()
                    return
                end
                Launcher:SetAutoMode(true)
                IssueClearCommands({Launcher})
                NukeSiloAmmoCount = Launcher:GetNukeSiloAmmoCount() or 0
                if not HighMissileCountLauncherReady.MissileCount or HighMissileCountLauncherReady.MissileCount < NukeSiloAmmoCount then
                    HighMissileCountLauncherReady = Launcher
                    HighMissileCountLauncherReady.MissileCount = NukeSiloAmmoCount
                end
                -- check if the launcher is full:
                local bp = Launcher:GetBlueprint()
                local weapon = bp.Weapon[1]
                local MaxLoad = weapon.MaxProjectileStorage or 5
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: launcher can load '..MaxLoad..' missiles ')
                end

                if NukeSiloAmmoCount >= MaxLoad then
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: launcher can load '..MaxLoad..' missiles and has '..NukeSiloAmmoCount..' = FULL ')
                    end
                    SWARMINSERT(LauncherFull, Launcher)
                end
                if NukeSiloAmmoCount > 0 and SWARMENTITY(categories.NUKE * categories.EXPERIMENTAL, Launcher) then
                    SWARMINSERT(ExperimentalLauncherReady, Launcher)
                    MissileCount = MissileCount + NukeSiloAmmoCount
                elseif NukeSiloAmmoCount > 0 then
                    SWARMINSERT(LauncherReady, Launcher)
                    MissileCount = MissileCount + NukeSiloAmmoCount
                end
                LauncherCount = LauncherCount + 1
                -- count experimental launcher seraphim
            end
            EnemyAntiMissile = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * ((categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL)), Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            if NUKEDEBUG then
                LOG('* AI-Swarm: ************************************************************************************************')
                LOG('* AI-Swarm: * NukePlatoonAISwarm: Checking for Targets. Launcher:('..LauncherCount..') Ready:('..SWARMGETN(LauncherReady)..') Full:('..SWARMGETN(LauncherFull)..') - Missiles:('..MissileCount..') - EnemyAntiMissile:('..SWARMGETN(EnemyAntiMissile)..')')
            end
            -- Don't check all nuke functions if we have no missile.
            if LauncherCount < 1 or ( SWARMGETN(LauncherReady) < 1 and SWARMGETN(LauncherFull) < 1 ) then
                continue
            end
            ---------------------------------------------------------------------------------------------------
            -- PrimaryTarget, launch a single nuke on primary targets.
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) Experimental PrimaryTarget ')
            end
            if 1 == 1 and aiBrain.PrimaryTarget and SWARMGETN(LauncherReady) > 0 and SWARMENTITY(categories.EXPERIMENTAL, aiBrain.PrimaryTarget) then
                -- Only shoot if the target is not protected by antimissile or experimental shields
                if not self:IsTargetNukeProtectedSwarm(aiBrain.PrimaryTarget, EnemyAntiMissile) then
                    -- Lead target function
                    if TargetPos then
                        -- Only shoot if we are not damaging our own structures
                        if aiBrain:GetNumUnitsAroundPoint(categories.STRUCTURE, TargetPos, 50 , 'Ally') <= 0 then
                            if not self:NukeSingleAttack(HighMissileCountLauncherReady, TargetPos) then
                                if self:NukeSingleAttack(LauncherReady, TargetPos) then
                                    if NUKEDEBUG then
                                        LOG('* AI-Swarm: * NukePlatoonAI: (Unprotected) Experimental PrimaryTarget FIRE LauncherReady!')
                                    end
                                    NukeLaunched = true
                                end
                            end
                        else
                            if NUKEDEBUG then
                                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) Experimental PrimaryTarget FIRE HighMissileCountLauncherReady!')
                            end
                            NukeLaunched = true
                        end
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- first try to target all targets that are not protected from enemy anti missile
            ---------------------------------------------------------------------------------------------------
            EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE - categories.MASSEXTRACTION - categories.TECH1 - categories.TECH2 , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            EnemyTargetPositions = {}
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) EnemyUnits. Checking enemy units: '..SWARMGETN(EnemyUnits))
            end
            for _, EnemyTarget in EnemyUnits do
                -- get position of the possible next target
                local EnemyTargetPos = EnemyTarget:GetPosition() or nil
                if not EnemyTargetPos then continue end
                local ToClose = false
                -- loop over all already attacked targets
                for _, ETargetPosition in EnemyTargetPositions do
                    -- Check if the target is closeer then 40 to an already attacked target
                    if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                        ToClose = true
                        break -- break out of the EnemyTargetPositions loop
                    end
                end
                if ToClose then
                    continue -- Skip this enemytarget and check the next
                end
                -- Check if the target is not protected by an antinuke
                if not self:IsTargetNukeProtectedSwarm(EnemyTarget, EnemyAntiMissile) then
                    SWARMINSERT(EnemyTargetPositions, EnemyTargetPos)
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have unprotected targets, shot at it
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) EnemyUnits: Unprotected enemy units: '..SWARMGETN(EnemyTargetPositions))
            end
            if 1 == 1 and SWARMGETN(EnemyTargetPositions) > 0 and SWARMGETN(LauncherReady) > 0 then
                -- loopß over all targets
                self:NukeJerichoAttackSwarm(aiBrain, LauncherReady, EnemyTargetPositions, false)
                NukeLaunched = true
            end
            ---------------------------------------------------------------------------------------------------
            -- Try to overwhelm anti nuke, search for targets
            ---------------------------------------------------------------------------------------------------
            EnemyProtectorsNum = 0
            TargetPosition = false
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Check for MissileCount > 8  [ '..MissileCount..' > 8 ]')
            end
            if 1 == 1 and MissileCount > 8 and SWARMGETN(EnemyAntiMissile) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) MissileCount, EnemyAntiMissile  [ '..MissileCount..', '..SWARMGETN(EnemyAntiMissile)..' ]')
                end
                local AntiMissileRanger = {}
                -- get a list with all antinukes and distance to each other
                for MissileIndex, AntiMissileSTART in EnemyAntiMissile do
                    AntiMissileRanger[MissileIndex] = 0
                    -- get the location of AntiMissile
                    local AntiMissilePosSTART = AntiMissileSTART:GetPosition() or nil
                    if not AntiMissilePosSTART then break end
                    for _, AntiMissileEND in EnemyAntiMissile do
                        local AntiMissilePosEND = AntiMissileSTART:GetPosition() or nil
                        if not AntiMissilePosEND then continue end
                        local dist = VDist2(AntiMissilePosSTART[1],AntiMissilePosSTART[3],AntiMissilePosEND[1],AntiMissilePosEND[3])
                        AntiMissileRanger[MissileIndex] = AntiMissileRanger[MissileIndex] + dist
                    end
                end
                -- find the least protected anti missile
                local HighestDistance = 0
                local HighIndex = false
                for MissileIndex, MissileRange in AntiMissileRanger do
                    if MissileRange > HighestDistance then
                        HighestDistance = MissileRange
                        HighIndex = MissileIndex
                    end
                end
                if HighIndex and EnemyAntiMissile[HighIndex] and not EnemyAntiMissile[HighIndex].Dead then
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Antimissile with highest distance to other antimissiles has HighIndex = '..HighIndex)
                    end
                    -- kill the launcher will all missiles we have
                    EnemyTarget = EnemyAntiMissile[HighIndex]
                    TargetPosition = EnemyTarget:GetPosition() or false
                elseif EnemyAntiMissile[1] and not EnemyAntiMissile[1].Dead then
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Targetting Antimissile[1]')
                    end
                    EnemyTarget = EnemyAntiMissile[1]
                    TargetPosition = EnemyTarget:GetPosition() or false
                end
                -- Scan how many antinukes are protecting the least defended target:
                local ProtectorUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * ((categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL)), TargetPosition, 90, 'Enemy')
                if ProtectorUnits then
                    EnemyProtectorsNum = SWARMGETN(ProtectorUnits)
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Try to overwhelm anti nuke, search for targets
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) missiles > antimissiles  [ '..MissileCount..' > '..(EnemyProtectorsNum * 8)..' ]')
            end
            if 1 == 1 and EnemyTarget and TargetPosition and EnemyProtectorsNum > 0 and MissileCount > EnemyProtectorsNum * 8 then
                -- Fire as long as the target exists
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) while EnemyTarget do ')
                end
                while EnemyTarget and not EnemyTarget.Dead do
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Loop!')
                    end
                    local missile = false
                    for k, Launcher in platoonUnits do
                        if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                            -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                            -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                            self:PlatoonDisbandNoAssign()
                            return
                        end
                        if NUKEDEBUG then
                            LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Fireing Nuke: '..repr(k))
                        end
                        if Launcher:GetNukeSiloAmmoCount() > 0 then
                            if Launcher:GetNukeSiloAmmoCount() > 1 then
                                missile = true
                            end
                            IssueNuke({Launcher}, TargetPosition)
                            SWARMREMOVE(LauncherReady, k)
                            MissileCount = MissileCount - 1
                            NukeLaunched = true
                        end
                        if not EnemyTarget or EnemyTarget.Dead then
                            if NUKEDEBUG then
                                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Target is dead. break fire loop')
                            end
                            break -- break the "for Index, Launcher in platoonUnits do" loop
                        end
                    end
                    if not missile then
                        if NUKEDEBUG then
                            LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Nukes are empty')
                        end
                        break -- break the "while EnemyTarget do" loop
                    end
                    if NukeLaunched then
                        if NUKEDEBUG then
                            LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) Nukes launched')
                        end
                        break -- break the "while EnemyTarget do" loop
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Jericho! Check if we can attack all targets at the same time
            ---------------------------------------------------------------------------------------------------
            EnemyTargetPositions = {}
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Jericho) Searching for EnemyTargetPositions')
            end
            for _, EnemyTarget in EnemyUnits do
                -- get position of the possible next target
                local EnemyTargetPos = EnemyTarget:GetPosition() or nil
                if not EnemyTargetPos then continue end
                local ToClose = false
                -- loop over all already attacked targets
                for _, ETargetPosition in EnemyTargetPositions do
                    -- Check if the target is closer then 40 to an already attacked target
                    if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                        ToClose = true
                        break -- break out of the EnemyTargetPositions loop
                    end
                end
                if ToClose then
                    continue -- Skip this enemytarget and check the next
                end
                SWARMINSERT(EnemyTargetPositions, EnemyTargetPos)
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have more launchers ready then targets start Jericho bombardment
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Jericho) Checking for Launcher:('..LauncherCount..') Ready:('..SWARMGETN(LauncherReady)..') Full:('..SWARMGETN(LauncherFull)..') - Missiles:('..MissileCount..') - Enemy Targets:('..SWARMGETN(EnemyTargetPositions)..')')
            end
            if 1 == 1 and SWARMGETN(LauncherReady) >= SWARMGETN(EnemyTargetPositions) and SWARMGETN(EnemyTargetPositions) > 0 and SWARMGETN(LauncherFull) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: Jericho!')
                end
                -- loopß over all targets
                self:NukeJerichoAttackSwarm(aiBrain, LauncherReady, EnemyTargetPositions, false)
                NukeLaunched = true
            end
            ---------------------------------------------------------------------------------------------------
            -- If we have an launcher with 5 missiles fire one.
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Checking for Full Launchers. Launcher:('..LauncherCount..') Ready:('..SWARMGETN(LauncherReady)..') Full:('..SWARMGETN(LauncherFull)..') - Missiles:('..MissileCount..')')
            end
            if 1 == 1 and SWARMGETN(LauncherFull) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) - Launcher is full!')
                end
                EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.EXPERIMENTAL, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                if SWARMGETN(EnemyUnits) > 0 then
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Experimental Buildings: ('..SWARMGETN(EnemyUnits)..')')
                    end
                end
                if SWARMGETN(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.TECH3 , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy TECH3 Buildings: ('..SWARMGETN(EnemyUnits)..')')
                    end
                end
                if SWARMGETN(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.MOBILE * categories.EXPERIMENTAL - categories.AIR, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Experimental Units: ('..SWARMGETN(EnemyUnits)..')')
                    end
                end
                if SWARMGETN(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Buildings: ('..SWARMGETN(EnemyUnits)..')')
                    end
                end
                if SWARMGETN(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.MOBILE - categories.AIR, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Mobile Units: ('..SWARMGETN(EnemyUnits)..')')
                    end
                end
                if SWARMGETN(EnemyUnits) > 0 then
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) MissileCount ('..MissileCount..') > EnemyUnits ('..SWARMGETN(EnemyUnits)..')')
                    end
                    EnemyTargetPositions = {}
                    -- get enemy target positions
                    for _, EnemyTarget in EnemyUnits do
                        -- get position of the possible next target
                        local EnemyTargetPos = EnemyTarget:GetPosition() or nil
                        if not EnemyTargetPos then continue end
                        local ToClose = false
                        -- loop over all already attacked targets
                        for _, ETargetPosition in EnemyTargetPositions do
                            -- Check if the target is closeer then 40 to an already attacked target
                            if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                                ToClose = true
                                break -- break out of the EnemyTargetPositions loop
                            end
                        end
                        if ToClose then
                            continue -- Skip this enemytarget and check the next
                        end
                        SWARMINSERT(EnemyTargetPositions, EnemyTargetPos)
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have targets, shot at it
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Attack only with full Launchers. Launcher:('..LauncherCount..') Ready:('..SWARMGETN(LauncherReady)..') Full:('..SWARMGETN(LauncherFull)..') - Missiles:('..MissileCount..') - Enemy Targets:('..SWARMGETN(EnemyTargetPositions)..')')
            end
            if 1 == 1 and SWARMGETN(EnemyTargetPositions) > 0 and SWARMGETN(LauncherFull) > 0 then
                self:NukeJerichoAttackSwarm(aiBrain, LauncherFull, EnemyTargetPositions, true)
                NukeLaunched = true
            end
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: END. Launcher:('..LauncherCount..') Ready:('..SWARMGETN(LauncherReady)..') Full:'..SWARMGETN(LauncherFull)..' - Missiles:('..MissileCount..')')
            end
            if NukeLaunched == true then
                --LOG('* AI-Swarm: Fired nuke(s), waiting...')
                SWARMWAIT(450)-- wait 45 seconds for the missile flight, then get new targets
            end
        end -- while aiBrain:PlatoonExists(self) do
    end,
    
    LeadNukeTargetSwarm = function(self, target)
        local TargetPos
        -- Get target position in 1 second intervals.
        -- This allows us to get speed and direction from the target
        local TargetStartPosition=0
        local Target1SecPos=0
        local Target2SecPos=0
        local XmovePerSec=0
        local YmovePerSec=0
        local XmovePerSecCheck=-1
        local YmovePerSecCheck=-1
        -- Check if the target is runing straight or circling
        -- If x/y and xcheck/ycheck are equal, we can be sure the target is moving straight
        -- in one direction. At least for the last 2 seconds.
        local LoopSaveGuard = 0
        while target and not target.Dead and (XmovePerSec ~= XmovePerSecCheck or YmovePerSec ~= YmovePerSecCheck) and LoopSaveGuard < 10 do
            if not target or target.Dead then return false end
            -- 1st position of target
            TargetPos = target:GetPosition()
            TargetStartPosition = {TargetPos[1], 0, TargetPos[3]}
            SWARMWAIT(10)
            -- 2nd position of target after 1 second
            TargetPos = target:GetPosition()
            Target1SecPos = {TargetPos[1], 0, TargetPos[3]}
            XmovePerSec = (TargetStartPosition[1] - Target1SecPos[1])
            YmovePerSec = (TargetStartPosition[3] - Target1SecPos[3])
            SWARMWAIT(10)
            -- 3rd position of target after 2 seconds to verify straight movement
            TargetPos = target:GetPosition()
            Target2SecPos = {TargetPos[1], TargetPos[2], TargetPos[3]}
            XmovePerSecCheck = (Target1SecPos[1] - Target2SecPos[1])
            YmovePerSecCheck = (Target1SecPos[3] - Target2SecPos[3])
            --We leave the while-do check after 10 loops (20 seconds) and try collateral damage
            --This can happen if a player try to fool the targetingsystem by circling a unit.
            LoopSaveGuard = LoopSaveGuard + 1
        end
        if not target or target.Dead then return false end
        local MissileImpactTime = 25
        -- Create missile impact corrdinates based on movePerSec * MissileImpactTime
        local MissileImpactX = Target2SecPos[1] - (XmovePerSec * MissileImpactTime)
        local MissileImpactY = Target2SecPos[3] - (YmovePerSec * MissileImpactTime)
        return {MissileImpactX, Target2SecPos[2], MissileImpactY}
    end,

    NukeSingleAttackSwarm = function(self, Launchers, EnemyTargetPosition)
        --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: Launcher count: '..SWARMGETN(Launchers))
        if SWARMGETN(Launchers) <= 0 then
            --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: No Launcher ready.')
            return false
        end
        -- loop over all nuke launcher
        for k, Launcher in Launchers do
            if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: Found destroyed launcher inside platoon. Disbanding...')
                self:PlatoonDisbandNoAssign()
                return
            end
            -- check if the target is closer then 20000
            LauncherPos = Launcher:GetPosition() or nil
            if not LauncherPos then
                --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: no Launcher Pos. Skiped')
                continue
            end
            if not EnemyTargetPosition then
                --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: no Target Pos. Skiped')
                continue
            end
            if VDist2(LauncherPos[1],LauncherPos[3],EnemyTargetPosition[1],EnemyTargetPosition[3]) > 20000 then
                --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: Target out of range. Skiped')
                -- Target is out of range, skip this launcher
                continue
            end
            -- Attack the target
            --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: Attacking Enemy Position!')
            IssueNuke({Launcher}, EnemyTargetPosition)
            -- stop seraching for available launchers and check the next target
            return true
        end
    end,

    NukeJerichoAttackSwarm = function(self, aiBrain, Launchers, EnemyTargetPositions, LaunchAll)
        --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: Launcher: '..SWARMGETN(Launchers))
        if SWARMGETN(Launchers) <= 0 then
            --LOG('* AI-Swarm: * NukeSingleAttackSwarm: Launcher empty')
            return false
        end
        for _, ActualTargetPos in EnemyTargetPositions do
            -- loop over all nuke launcher
            for k, Launcher in Launchers do
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                    --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: Found destroyed launcher inside platoon. Disbanding...')
                    if aiBrain:PlatoonExists(self) then
                        self:PlatoonDisbandNoAssign()
                    end
                    return
                end
                -- check if the target is closer then 20000
                LauncherPos = Launcher:GetPosition() or nil
                if not LauncherPos then
                    --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: no Launcher Pos. Skiped')
                    continue
                end
                if not ActualTargetPos then
                    --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: no Target Pos. Skiped')
                    continue
                end
                if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                    --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: Target out of range. Skiped')
                    -- Target is out of range, skip this launcher
                    continue
                end
                -- Attack the target
                --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: Attacking Enemy Position!')
                IssueNuke({Launcher}, ActualTargetPos)
                -- remove the launcher from the table, so it can't be used for the next target
                SWARMREMOVE(Launchers, k)
                -- stop seraching for available launchers and check the next target
                break -- for k, Launcher in Launcher do
            end
            --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: Launcher after shoot: '..SWARMGETN(Launchers))
            if SWARMGETN(Launchers) < 1 then
                --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: All Launchers are bussy! Break!')
                -- stop seraching for targets, we don't hava a launcher ready.
                break -- for _, ActualTargetPos in EnemyTargetPositions do
            end
        end
        if SWARMGETN(Launchers) > 0 and LaunchAll == true then
            self:NukeJerichoAttackSwarm(aiBrain, Launchers, EnemyTargetPositions, true)
        end
    end,

    IsTargetNukeProtectedSwarm = function(self, Target, EnemyAntiMissile)
        TargetPos = Target:GetPosition() or nil
        if not TargetPos then
            -- we don't have a target position, so we return ture like we have a protected target.
            return true
        end
        for _, AntiMissile in EnemyAntiMissile do
            if not AntiMissile or AntiMissile.Dead or AntiMissile:BeenDestroyed() then continue end
            -- if the launcher is still in build, don't count it.
            local FractionComplete = AntiMissile:GetFractionComplete() or nil
            if not FractionComplete then continue end
            if FractionComplete < 1 then
                --LOG('* AI-Swarm: * IsTargetNukeProtectedSwarm: Target TAntiMissile:GetFractionComplete() < 1')
                continue
            end
            -- get the location of AntiMissile
            local AntiMissilePos = AntiMissile:GetPosition() or nil
            if not AntiMissilePos then
               --LOG('* AI-Swarm: * IsTargetNukeProtectedSwarm: Target AntiMissilePos NIL')
                continue 
            end
            -- Check if our target is inside range of an antimissile
            if VDist2(TargetPos[1],TargetPos[3],AntiMissilePos[1],AntiMissilePos[3]) < 90 then
                --LOG('* AI-Swarm: * IsTargetNukeProtectedSwarm: Target in range of Nuke Anti Missile. Skiped')
                return true
            end
        end
        return false
    end,

    SACUTeleportAISwarm = function(self)
        --LOG('* AI-Swarm: * SACUTeleportAISwarm: Start ')
        -- SACU need to move out of the gate first
        SWARMWAIT(50)
        local aiBrain = self:GetBrain()
        local platoonUnits
        local platoonPosition = self:GetPlatoonPosition()
        local TargetPosition
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- start upgrading all SubCommanders as teleporter
        while aiBrain:PlatoonExists(self) do
            local allEnhanced = true
            platoonUnits = self:GetPlatoonUnits()
            for k, unit in platoonUnits do
                IssueStop({unit})
                IssueClearCommands({unit})
                SWARMWAIT(1)
                if not unit.Dead then
                    for k, Assister in platoonUnits do
                        if not Assister.Dead and Assister ~= unit then
                            -- only assist if we have the energy for it
                            if aiBrain:GetEconomyTrend('ENERGY')*10 > 5000 or aiBrain.HasParagon then
                                --LOG('* AI-Swarm: * SACUTeleportAISwarm: IssueGuard({Assister}, unit) ')
                                IssueGuard({Assister}, unit)
                            end
                        end
                    end
                    self:BuildSACUEnhancementsSwarm(unit)
                    SWARMWAIT(1)
                    if not unit:HasEnhancement('Teleporter') then
                        --LOG('* AI-Swarm: * SACUTeleportAISwarm: Not teleporter enhanced')
                        allEnhanced = false
                    else
                        --LOG('* AI-Swarm: * SACUTeleportAISwarm: Has teleporter installed')
                    end
                end
            end
            if allEnhanced == true then
                --LOG('* AI-Swarm: * SACUTeleportAISwarm: allEnhanced == true ')
                break
            end
            SWARMWAIT(50)
        end
        --
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                SWARMINSERT(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * SACUTeleportAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                SWARMINSERT(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local maxRadius = SWARMMAX(maxRadius, (maxRadius * aiBrain.MyLandRatio) )
        -- search for a target
        local Target
        while not Target do
            SWARMWAIT(50)
            Target, _, _, _ = AIUtils.AIFindNearestCategoryTeleportLocationSwarm(aiBrain, platoonPosition, maxRadius, MoveToCategories, TargetSearchCategory, false)
        end
        platoonUnits = self:GetPlatoonUnits()
        if Target and not Target.Dead then
            TargetPosition = Target:GetPosition()
            for k, unit in platoonUnits do
                if not unit.Dead then
                    if not unit:HasEnhancement('Teleporter') then
                        --WARN('* AI-Swarm: * SACUTeleportAISwarm: Unit has no transport enhancement!')
                        continue
                    end
                    --IssueStop({unit})
                    SWARMWAIT(2)
                    IssueTeleport({unit}, SwarmUtils.RandomizePositionSwarm(TargetPosition))
                end
            end
        else
            --LOG('* AI-Swarm: SACUTeleportAISwarm: No target, disbanding platoon!')
            self:PlatoonDisband()
            return
        end
        SWARMWAIT(30)
        -- wait for the teleport of all unit
        local count = 0
        local UnitTeleporting = 0
        while aiBrain:PlatoonExists(self) do
            platoonUnits = self:GetPlatoonUnits()
            UnitTeleporting = 0
            for k, unit in platoonUnits do
                if not unit.Dead then
                    if unit:IsUnitState('Teleporting') then
                        UnitTeleporting = UnitTeleporting + 1
                    end
                end
            end
            --LOG('* AI-Swarm: SACUTeleportAISwarm: Units Teleporting :'..UnitTeleporting )
            if UnitTeleporting == 0 then
                break
            end
            SWARMWAIT(10)
        end        
        -- Fight
        SWARMWAIT(1)
        for k, unit in platoonUnits do
            if not unit.Dead then
                IssueStop({unit})
                SWARMWAIT(2)
                IssueMove({unit}, TargetPosition)
            end
        end
        SWARMWAIT(50)
        self:HuntAIPATHSwarm()
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    BuildSACUEnhancementsSwarm = function(platoon,unit)
        local EnhancementsByUnitID = {
            -- UEF
            ['uel0301'] = {'xxx', 'xxx', 'xxx'},
            -- Aeon
            ['ual0301'] = {'StabilitySuppressant', 'Teleporter'},
            -- Cybram
            ['url0301'] = {'xxx', 'xxx', 'xxx'},
            -- Seraphim
            ['xsl0301'] = {'DamageStabilization', 'Shield', 'Teleporter'},
            -- Nomads
            ['xnl0301'] = {'xxx', 'xxx', 'xxx'},
        }
        local CRDBlueprint = unit:GetBlueprint()
        --LOG('* AI-Swarm: BlueprintId RAW:'..repr(CRDBlueprint.BlueprintId))
        --LOG('* AI-Swarm: BlueprintId clean: '..repr(string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")))
        local ACUUpgradeList = EnhancementsByUnitID[string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")]
        --LOG('* AI-Swarm: ACUUpgradeList '..repr(ACUUpgradeList))
        local NextEnhancement = false
        local HaveEcoForEnhancement = false
        for _,enhancement in ACUUpgradeList or {} do
            local wantedEnhancementBP = CRDBlueprint.Enhancements[enhancement]
            --LOG('* AI-Swarm: wantedEnhancementBP '..repr(wantedEnhancementBP))
            if not wantedEnhancementBP then
                SPEW('* AI-Swarm: BuildSACUEnhancementsSwarm: no enhancement found for ('..string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")..') = '..repr(enhancement))
            elseif unit:HasEnhancement(enhancement) then
                NextEnhancement = false
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildSACUEnhancementsSwarm: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgradeSwarm(unit, wantedEnhancementBP) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildSACUEnhancementsSwarm: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: *** Set as Enhancememnt: '..NextEnhancement)
                end
            else
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildSACUEnhancementsSwarm: Eco is bad for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = false
                    -- if we don't have the eco for this ugrade, stop the search
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: canceled search. no eco available')
                end
            end
        end
        if NextEnhancement and HaveEcoForEnhancement then
            --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildSACUEnhancementsSwarm Building '..NextEnhancement)
            if platoon:BuildEnhancementSwarm(unit, NextEnhancement) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildSACUEnhancementsSwarm returned true'..NextEnhancement)
            else
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildSACUEnhancementsSwarm returned false'..NextEnhancement)
            end
            return
        end
        --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildSACUEnhancementsSwarm returned false')
        return
    end,
    
    -- 90% of this Relent0r's Work  --Scouting--
    ScoutingAISwarm = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self)

        if self.MovementLayer == 'Air' then
            return self:AirScoutingAISwarm()
        else
            return self:LandScoutingAISwarm()
        end
    end,

    AirScoutingAISwarm = function(self)
        local patrol = self.PlatoonData.Patrol or false
        local scout = self:GetPlatoonUnits()[1]
        if not scout then
            return
        end
        local aiBrain = self:GetBrain()

        if not aiBrain.InterestList then
            aiBrain:BuildScoutLocationsSwarm()
        end

        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:EnableUnitIntel('Toggle', 'Cloak')
        end

        if patrol == true then
            local patrolTime = self.PlatoonData.PatrolTime or 300
            local estartX = nil
            local estartZ = nil
            local startX = nil
            local startZ = nil
            local patrolPositionX = nil
            local patrolPositionZ = nil
            while not scout.Dead do
                if aiBrain:GetCurrentEnemy() then
                    estartX, estartZ = aiBrain:GetCurrentEnemy():GetArmyStartPos()
                end
                startX, startZ = aiBrain:GetArmyStartPos()
                local SWARM = SWARMRANDOM(1,3)
                if SWARM == 1 then
                    patrolPositionX = (estartX + startX) / 2.2
                    patrolPositionZ = (estartZ + startZ) / 2.2
                elseif SWARM == 2 then
                    patrolPositionX = (estartX + startX) / 2
                    patrolPositionZ = (estartZ + startZ) / 2
                    patrolPositionX = (patrolPositionX + startX) / 2
                    patrolPositionZ = (patrolPositionZ + startZ) / 2
                elseif SWARM == 3 then
                    patrolPositionX = (estartX + startX) / 2
                    patrolPositionZ = (estartZ + startZ) / 2
                end
                patrolLocation1 = AIUtils.RandomLocation(patrolPositionX, patrolPositionZ)
                patrolLocation2 = AIUtils.RandomLocation(patrolPositionX, patrolPositionZ)
                self:MoveToLocation({patrolPositionX, 0, patrolPositionZ}, false)
                local patrolunits = self:GetPlatoonUnits()
                IssuePatrol(patrolunits, AIUtils.RandomLocation(patrolPositionX, patrolPositionZ))
                IssuePatrol(patrolunits, AIUtils.RandomLocation(patrolPositionX, patrolPositionZ))
                IssuePatrol(patrolunits, AIUtils.RandomLocation(patrolPositionX, patrolPositionZ))
                SWARMWAIT(patrolTime)
                self:MoveToLocation({startX, 0, startZ}, false)
                self:PlatoonDisband()
                return
            end
        else
            while not scout.Dead do
                local targetArea = false
                local highPri = false

                local mustScoutArea, mustScoutIndex = aiBrain:GetUntaggedMustScoutArea()
                local unknownThreats = aiBrain:GetThreatsAroundPosition(scout:GetPosition(), 16, true, 'Unknown')
                if mustScoutArea then
                    mustScoutArea.TaggedBy = scout
                    targetArea = mustScoutArea.Position

                elseif SWARMGETN(unknownThreats) > 0 and unknownThreats[1][3] > 25 then
                    aiBrain:AddScoutArea({unknownThreats[1][1], 0, unknownThreats[1][2]})

                elseif aiBrain.IntelData.AirHiPriScouts < aiBrain.NumOpponents and aiBrain.IntelData.AirLowPriScouts < 1
                and SWARMGETN(aiBrain.InterestList.HighPriority) > 0 then
                    aiBrain.IntelData.AirHiPriScouts = aiBrain.IntelData.AirHiPriScouts + 1

                    highPri = true

                    targetData = aiBrain.InterestList.HighPriority[1]
                    targetData.LastScouted = SWARMTIME()
                    targetArea = targetData.Position

                    aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)


                elseif aiBrain.IntelData.AirLowPriScouts < 1 and SWARMGETN(aiBrain.InterestList.LowPriority) > 0 then
                    aiBrain.IntelData.AirHiPriScouts = 0
                    aiBrain.IntelData.AirLowPriScouts = aiBrain.IntelData.AirLowPriScouts + 1

                    targetData = aiBrain.InterestList.LowPriority[1]
                    targetData.LastScouted = SWARMTIME()
                    targetArea = targetData.Position

                    aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
                else

                    aiBrain.IntelData.AirLowPriScouts = 0
                    aiBrain.IntelData.AirHiPriScouts = 0
                end


                if targetArea then
                    self:Stop()

                    local vec = self:DoAirScoutVecs(scout, targetArea)

                    while not scout.Dead and not scout:IsIdleState() do


                        if VDist2Sq(vec[1], vec[3], scout:GetPosition()[1], scout:GetPosition()[3]) < 15625 then
                           if mustScoutArea then

                                for idx,loc in aiBrain.InterestList.MustScout do
                                    if loc == mustScoutArea then
                                        SWARMREMOVE(aiBrain.InterestList.MustScout, idx)
                                       break
                                    end
                                end
                            end

                            break
                        end

                        if VDist3(scout:GetPosition(), targetArea) < 25 then
                            break
                        end

                        SWARMWAIT(50)
                    end
                else
                    SWARMWAIT(10)
                end
                SWARMWAIT(1)
            end
        end
    end,

    LandScoutingAISwarm = function(self)

        local aiBrain = self:GetBrain()

        local scout = self:GetPlatoonUnits()[1]

        if not aiBrain.InterestList then 
            aiBrain:BuildScoutLocationsSwarm()
        end

        if scout:TestToggleCaps('RULEUTC_CloakToggle') then 
            scout:SetScriptBit('RULEUTC_CloakToggle', false)
        end

        local numLoiter = SWARMCEIL(SWARMCOUNT(self)/3) 
        local numMoving = SWARMCOUNT(self) - numLoiter 

        while not scout.Dead do

            local targetData = false

            if SWARMGETN(aiBrain.InterestList.HighPriority) > 0 then 
                targetData = aiBrain.InterestList.HighPriority[1]
                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)
            elseif SWARMGETN(aiBrain.InterestList.LowPriority) > 0 then 
                targetData = aiBrain.InterestList.LowPriority[1]
                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            else

                return self:SetAIPlan('ReturnToBaseAISwarm',aiBrain)
            end

            local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, scout:GetPosition(), targetData.Position, 400) 

            IssueClearCommands(self)

            if path then
                local pathLength = SWARMGETN(path)
                for i=1, pathLength-1 do
                    self:MoveToLocation(path[i], false)
                end
            end

            self:MoveToLocation(targetData.Position, false)

            while not scout.Dead and not scout:IsIdleState() do
                SWARMWAIT(25)
            end

            if numMoving > 0 then 
                local targetData = false

                if SWARMGETN(aiBrain.InterestList.HighPriority) > 0 then 
                    targetData = aiBrain.InterestList.HighPriority[1]
                    aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)
                elseif SWARMGETN(aiBrain.InterestList.LowPriority) > 0 then 
                    targetData = aiBrain.InterestList.LowPriority[1]
                    aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
                else

                    return self:SetAIPlan('ReturnToBaseAISwarm',aiBrain)
                end

                local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, scout:GetPosition(), targetData.Position, 400) 

                IssueClearCommands(self)

                if path then
                    local pathLength = SWARMGETN(path)
                    for i=1, pathLength-1 do
                        self:MoveToLocation(path[i], false)
                    end
                end

                self:MoveToLocation(targetData.Position, false)

            end 

            numMoving = numMoving - 1 
        end
    end,

    GuardMarkerSwarm = function(self)
        local aiBrain = self:GetBrain()

        local platLoc = GetPlatoonPosition(self)

        if not PlatoonExists(aiBrain, self) or not platLoc then
            return
        end

        -----------------------------------------------------------------------
        -- Platoon Data
        -----------------------------------------------------------------------
        -- type of marker to guard
        -- Start location = 'Start Location'... see MarkerTemplates.lua for other types
        local markerType = self.PlatoonData.MarkerType or 'Expansion Area'

        -- what should we look for for the first marker?  This can be 'Random',
        -- 'Threat' or 'Closest'
        local moveFirst = self.PlatoonData.MoveFirst or 'Threat'

        -- should our next move be no move be (same options as before) as well as 'None'
        -- which will cause the platoon to guard the first location they get to
        local moveNext = self.PlatoonData.MoveNext or 'None'

        -- Minimum distance when looking for closest
        local avoidClosestRadius = self.PlatoonData.AvoidClosestRadius or 0

        -- set time to wait when guarding a location with moveNext = 'None'
        local guardTimer = self.PlatoonData.GuardTimer or 0

        -- threat type to look at
        local threatType = self.PlatoonData.ThreatType or 'AntiSurface'

        -- should we look at our own threat or the enemy's
        local bSelfThreat = self.PlatoonData.SelfThreat or false

        -- if true, look to guard highest threat, otherwise,
        -- guard the lowest threat specified
        local bFindHighestThreat = self.PlatoonData.FindHighestThreat or false

        -- minimum threat to look for
        local minThreatThreshold = self.PlatoonData.MinThreatThreshold or -1
        -- maximum threat to look for
        local maxThreatThreshold = self.PlatoonData.MaxThreatThreshold  or 99999999

        -- Avoid bases (true or false)
        local bAvoidBases = self.PlatoonData.AvoidBases or false

        -- Radius around which to avoid the main base
        local avoidBasesRadius = self.PlatoonData.AvoidBasesRadius or 0

        -- Use Aggresive Moves Only
        local bAggroMove = self.PlatoonData.AggressiveMove or false

        local PlatoonFormation = self.PlatoonData.UseFormation or 'NoFormation'
        
        -- Ignore markers with friendly structure threatlevels
        local IgnoreFriendlyBase = self.PlatoonData.IgnoreFriendlyBase or false

        local maxPathDistance = self.PlatoonData.MaxPathDistance or 200

        local safeZone = self.PlatoonData.SafeZone or false

        -----------------------------------------------------------------------
        local markerLocations

        AIAttackUtils.GetMostRestrictiveLayer(self)
        self:SetPlatoonFormationOverride(PlatoonFormation)
        local enemyRadius = 40
        local MaxPlatoonWeaponRange
        local unitPos
        local alpha
        local x
        local y
        local smartPos
        local platoonUnits = GetPlatoonUnits(self)
        local rangeModifier = 0
        local atkPri = {}
        local platoonThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)

        if platoonUnits > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if EntityCategoryContains(categories.SCOUT, v) then
                        self.ScoutPresent = true
                    end
                    for _, weapon in ALLBPS[v.UnitId].Weapon or {} do
                        -- unit can have MaxWeaponRange entry from the last platoon
                        if not v.MaxWeaponRange or weapon.MaxRadius > v.MaxWeaponRange then
                            -- save the weaponrange 
                            v.MaxWeaponRange = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                            -- save the weapon balistic arc, we need this later to check if terrain is blocking the weapon line of sight
                            if weapon.BallisticArc == 'RULEUBA_LowArc' then
                                v.WeaponArc = 'low'
                            elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                                v.WeaponArc = 'high'
                            else
                                v.WeaponArc = 'none'
                            end
                        end
                        if not MaxPlatoonWeaponRange or MaxPlatoonWeaponRange < v.MaxWeaponRange then
                            MaxPlatoonWeaponRange = v.MaxWeaponRange
                        end
                    end
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                    v.smartPos = {0,0,0}
                    if not v.MaxWeaponRange then
                        --WARN('Scanning: unit ['..repr(v.UnitId)..'] has no MaxWeaponRange - '..repr(self.BuilderName))
                    end
                end
            end
        end

        if self.PlatoonData.PrioritizedCategories then
            for k,v in self.PlatoonData.PrioritizedCategories do
                SWARMGETN(atkPri, v)
            end
            SWARMGETN(atkPri, 'ALLUNITS')
        end
        
        if IgnoreFriendlyBase then
            --LOG('* AI-Swarm: ignore friendlybase true')
            local markerPos = AIUtils.AIGetMarkerLocationsNotFriendlySwarm(aiBrain, markerType)
            markerLocations = markerPos
        else
            --LOG('* AI-Swarm: ignore friendlybase false')
            local markerPos = AIUtils.AIGetMarkerLocations(aiBrain, markerType)
            markerLocations = markerPos
        end
        
        local bestMarker = false

        if not self.LastMarker then
            self.LastMarker = {nil,nil}
        end

        -- look for a random marker
        --[[Marker table examples for better understanding what is happening below 
        info: Marker Current{ Name="Mass7", Position={ 189.5, 24.240200042725, 319.5, type="VECTOR3" } }
        info: Marker Last{ { 374.5, 20.650400161743, 154.5, type="VECTOR3" } }
        ]] 
        if moveFirst == 'Random' then
            if SWARMGETN(markerLocations) <= 2 then
                self.LastMarker[1] = nil
                self.LastMarker[2] = nil
            end
            for _,marker in RandomIter(markerLocations) do
                if SWARMGETN(markerLocations) <= 2 then
                    self.LastMarker[1] = nil
                    self.LastMarker[2] = nil
                end
                if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) then
                    if self.LastMarker[1] and marker.Position[1] == self.LastMarker[1][1] and marker.Position[3] == self.LastMarker[1][3] then
                        continue
                    end
                    if self.LastMarker[2] and marker.Position[1] == self.LastMarker[2][1] and marker.Position[3] == self.LastMarker[2][3] then
                        continue
                    end
                    bestMarker = marker
                    break
                end
            end
        elseif moveFirst == 'Threat' then
            --Guard the closest least-defended marker
            local bestMarkerThreat = 0
            if not bFindHighestThreat then
                bestMarkerThreat = 99999999
            end

            local bestDistSq = 99999999


            -- find best threat at the closest distance
            for _,marker in markerLocations do
                local markerThreat
                if bSelfThreat then
                    markerThreat = GetThreatAtPosition(aiBrain, marker.Position, 0, true, threatType, aiBrain:GetArmyIndex())
                else
                    markerThreat = GetThreatAtPosition(aiBrain, marker.Position, 0, true, threatType)
                end
                local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])

                if distSq > 100 then
                    if markerThreat >= minThreatThreshold and markerThreat <= maxThreatThreshold then
                        if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) then
                            if self.IsBetterThreat(bFindHighestThreat, markerThreat, bestMarkerThreat) then
                                bestDistSq = distSq
                                bestMarker = marker
                                bestMarkerThreat = markerThreat
                            elseif markerThreat == bestMarkerThreat then
                                if distSq < bestDistSq then
                                    bestDistSq = distSq
                                    bestMarker = marker
                                    bestMarkerThreat = markerThreat
                                end
                            end
                        end
                    end
                end
            end

        else
            -- if we didn't want random or threat, assume closest (but avoid ping-ponging)
            local bestDistSq = 99999999
            if SWARMGETN(markerLocations) <= 2 then
                self.LastMarker[1] = nil
                self.LastMarker[2] = nil
            end
            for _,marker in markerLocations do
                local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])
                if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) and distSq > (avoidClosestRadius * avoidClosestRadius) then
                    if distSq < bestDistSq then
                        if self.LastMarker[1] and marker.Position[1] == self.LastMarker[1][1] and marker.Position[3] == self.LastMarker[1][3] then
                            continue
                        end
                        if self.LastMarker[2] and marker.Position[1] == self.LastMarker[2][1] and marker.Position[3] == self.LastMarker[2][3] then
                            continue
                        end
                        bestDistSq = distSq
                        bestMarker = marker
                    end
                end
            end
        end


        -- did we find a threat?
        local usedTransports = false
        if bestMarker then
            self.LastMarker[2] = self.LastMarker[1]
            self.LastMarker[1] = bestMarker.Position
            --LOG('* AI-Swarm: GuardMarker: Attacking '' .. bestMarker.Name)
            local path, reason = AIAttackUtils.PlatoonGenerateSafePathToSwarm(aiBrain, self.MovementLayer, GetPlatoonPosition(self), bestMarker.Position, 10, maxPathDistance)
            local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, bestMarker.Position)
            IssueClearCommands(GetPlatoonUnits(self))
            if path then
                local position = GetPlatoonPosition(self)
                if not success or VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 512 then
                    --LOG('* AI-Swarm: GuardMarkerSwarm marker position > 512')
                    if safeZone then
                        --LOG('* AI-Swarm: GuardMarkerSwarm Safe Zone is true')
                    end
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, bestMarker.Position, true, false, safeZone)
                elseif VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 256 then
                    --LOG('* AI-Swarm: GuardMarkerSwarm marker position > 256')
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, bestMarker.Position, false, false, safeZone)
                end
                if not usedTransports then
                    local pathLength = SWARMGETN(path)
                    local prevpoint = position or false
                    --LOG('* AI-Swarm: GuardMarkerSwarm movement logic')
                    for i=1, pathLength-1 do
                        local direction = SwarmUtils.GetDirectionInDegrees( prevpoint, path[i] )
                        if bAggroMove then
                            --self:AggressiveMoveToLocation(path[i])
                            IssueFormAggressiveMove( self:GetPlatoonUnits(), path[i], PlatoonFormation, direction)
                        else
                            --self:MoveToLocation(path[i], false)
                            if self:GetSquadUnits('Attack') and SWARMGETN(self:GetSquadUnits('Attack')) > 0 then
                                IssueFormMove( self:GetSquadUnits('Attack'), path[i], PlatoonFormation, direction)
                            end
                            if self:GetSquadUnits('Artillery') and SWARMGETN(self:GetSquadUnits('Artillery')) > 0 then
                                IssueFormAggressiveMove( self:GetSquadUnits('Artillery'), path[i], PlatoonFormation, direction)
                            end
                        end
                        while PlatoonExists(aiBrain, self) do
                            platoonPosition = GetPlatoonPosition(self)
                            pathDistance = VDist2Sq(path[i][1], path[i][3], platoonPosition[1], platoonPosition[3])
                            if pathDistance < 400 then
                                -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                                self:Stop()
                                break
                            end
                            --LOG('Waiting to reach target loop')
                            SWARMWAIT(15)
                        end
                        prevpoint = SWARMCOPY(path[i])
                    end
                end
            elseif (not path and reason == 'NoPath') then
                --LOG('* AI-Swarm: Guardmarker NoPath requesting transports')
                usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, bestMarker.Position, true, false, safeZone)
                --DUNCAN - if we need a transport and we cant get one the disband
                if not usedTransports then
                    --LOG('* AI-Swarm: Guardmarker no transports available disbanding')
                    self:PlatoonDisband()
                    return
                end
                --LOG('* AI-Swarm: Guardmarker found transports')
            else
                --LOG('* AI-Swarm: GuardmarkerSwarm bad path response disbanding')
                self:PlatoonDisband()
                return
            end

            if (not path or not success) and not usedTransports then
                --LOG('* AI-Swarm: GuardmarkerSwarm not path or not success and not usedTransports. Disbanding')
                self:PlatoonDisband()
                return
            end

            if moveNext == 'None' then
                -- guard
                IssueGuard(GetPlatoonUnits(self), bestMarker.Position)
                -- guard forever
                if guardTimer <= 0 then return end
            else
                -- otherwise, we're moving to the location
                self:AggressiveMoveToLocation(bestMarker.Position)
            end

            -- wait till we get there
            local oldPlatPos = GetPlatoonPosition(self)
            local StuckCount = 0
            repeat
                SWARMWAIT(50)
                platLoc = GetPlatoonPosition(self)
                if VDist3(oldPlatPos, platLoc) < 1 then
                    StuckCount = StuckCount + 1
                else
                    StuckCount = 0
                end
                if StuckCount > 5 then
                    --LOG('* AI-Swarm: GuardMarkerSwarm detected stuck. Restarting.')
                    return self:SetAIPlan('GuardMarkerSwarm')
                end
                oldPlatPos = platLoc
            until VDist2Sq(platLoc[1], platLoc[3], bestMarker.Position[1], bestMarker.Position[3]) < 900 or not PlatoonExists(aiBrain, self)

            -- if we're supposed to guard for some time
            if moveNext == 'None' then
                -- this won't be 0... see above
                WaitSeconds(guardTimer)
                --LOG('Move Next set to None, disbanding')
                self:PlatoonDisband()
                return
            end

            -- we're there... wait here until we're done
            --LOG('Checking if GuardMarker platoon has enemy units around marker position')
            local numGround = GetNumUnitsAroundPoint(aiBrain, (categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 30, 'Enemy')
            while numGround > 0 and PlatoonExists(aiBrain, self) do
                --LOG('GuardMarker has enemy units around marker position, looking for target')
                local target, acuInRange, acuUnit = AIUtils.AIFindBrainTargetInCloseRangeSwarm(aiBrain, self, bestMarker.Position, 'Attack', enemyRadius, (categories.LAND + categories.NAVAL + categories.STRUCTURE), atkPri, false)
                --target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.NAVAL - categories.AIR - categories.SCOUT - categories.WALL)
                local attackSquad = self:GetSquadUnits('Attack')
                IssueClearCommands(attackSquad)
                while PlatoonExists(aiBrain, self) do
                    --LOG('Micro target Loop '..debugloop)
                    --debugloop = debugloop + 1
                    if target and not target.Dead then
                        --LOG('Activating GuardMarker Micro')
                        platoonThreat = self:CalculatePlatoonThreat('Surface', categories.DIRECTFIRE)
                        if acuUnit and platoonThreat > 30 then
                            --LOG('ACU is close and we have decent threat')
                            target = acuUnit
                            rangeModifier = 5
                        end
                        local targetPosition = target:GetPosition()
                        local microCap = 50
                        for _, unit in attackSquad do
                            microCap = microCap - 1
                            if microCap <= 0 then break end
                            if unit.Dead then continue end
                            if not unit.MaxWeaponRange then
                                continue
                            end
                            unitPos = unit:GetPosition()
                            alpha = SWARMATAN2 (targetPosition[3] - unitPos[3] ,targetPosition[1] - unitPos[1])
                            x = targetPosition[1] - SWARMCOS(alpha) * (unit.MaxWeaponRange - rangeModifier or MaxPlatoonWeaponRange)
                            y = targetPosition[3] - SWARMSIN(alpha) * (unit.MaxWeaponRange - rangeModifier or MaxPlatoonWeaponRange)
                            smartPos = { x, GetTerrainHeight( x, y), y }
                            -- check if the move position is new or target has moved
                            if VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 or unit.TargetPos ~= targetPosition then
                                -- clear move commands if we have queued more than 4
                                if SWARMGETN(unit:GetCommandQueue()) > 2 then
                                    IssueClearCommands({unit})
                                    coroutine.yield(3)
                                end
                                -- if our target is dead, jump out of the "for _, unit in self:GetPlatoonUnits() do" loop
                                IssueMove({unit}, smartPos )
                                if target.Dead then break end
                                IssueAttack({unit}, target)
                                --unit:SetCustomName('Fight micro moving')
                                unit.smartPos = smartPos
                                unit.TargetPos = targetPosition
                            -- in case we don't move, check if we can fire at the target
                            else
                                local dist = VDist2( unit.smartPos[1], unit.smartPos[3], unit.TargetPos[1], unit.TargetPos[3] )
                                if aiBrain:CheckBlockingTerrain(unitPos, targetPosition, unit.WeaponArc) then
                                    --unit:SetCustomName('Fight micro WEAPON BLOCKED!!! ['..repr(target.UnitId)..'] dist: '..dist)
                                    IssueMove({unit}, targetPosition )
                                else
                                    --unit:SetCustomName('Fight micro SHOOTING ['..repr(target.UnitId)..'] dist: '..dist)
                                end
                            end
                        end
                    else
                        break
                    end
                    SWARMWAIT(10)
                end
                SWARMWAIT(Random(30,60))
                numGround = GetNumUnitsAroundPoint(aiBrain, (categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 30, 'Enemy')
            end

            if not PlatoonExists(aiBrain, self) then
                return
            end

            -- set our MoveFirst to our MoveNext
            self.PlatoonData.MoveFirst = moveNext
            return self:GuardMarkerSwarm()
        else
            -- no marker found, disband!
            --LOG('* AI-Swarm: GuardmarkerSwarm No best marker. Disbanding.')
            self:PlatoonDisband()
        end
    end,

    HuntAISwarm = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local target
        local blip
        local DEBUG = false
        local platoonUnits = GetPlatoonUnits(self)
        local platoonLimit = self.PlatoonData.PlatoonLimit or 12
        local LocationType = self.PlatoonData.LocationType or 'MAIN'
        local mainBasePos
        if LocationType then
            mainBasePos = aiBrain.BuilderManagers[LocationType].Position
        else
            mainBasePos = aiBrain.BuilderManagers['MAIN'].Position
        end
        local enemyRadius = 40
        local movingToScout = false
        local MaxPlatoonWeaponRange
        local unitPos
        local alpha
        local x
        local y
        local smartPos
        local scoutUnit
        AIAttackUtils.GetMostRestrictiveLayer(self)
        local function VariableKite(platoon,unit,target)
            local function KiteDist(pos1,pos2,distance)
                local vec={}
                local dist=VDist3(pos1,pos2)
                for i,k in pos2 do
                    if type(k)~='number' then continue end
                    vec[i]=k+distance/dist*(pos1[i]-k)
                end
                return vec
            end
            local function CheckRetreat(pos1,pos2,target)
                local vel = {}
                vel[1], vel[2], vel[3]=target:GetVelocity()
                --LOG('vel is '..repr(vel))
                --LOG(repr(pos1))
                --LOG(repr(pos2))
                local dotp=0
                for i,k in pos2 do
                    if type(k)~='number' then continue end
                    dotp=dotp+(pos1[i]-k)*vel[i]
                end
                return dotp<0
            end
            if target.Dead then return end
            if unit.Dead then return end
                
            local pos=unit:GetPosition()
            local tpos=target:GetPosition()
            local dest
            local mod=3
            if CheckRetreat(pos,tpos,target) then
                mod=8
            end
            if unit.MaxWeaponRange then
                dest=KiteDist(pos,tpos,unit.MaxWeaponRange-math.random(1,3)-mod)
            else
                dest=KiteDist(pos,tpos,self.MaxWeaponRange+5-math.random(1,3)-mod)
            end
            if VDist3Sq(pos,dest)>6 then
                IssueMove({unit},dest)
                SWARMWAIT(20)
                return
            else
                SWARMWAIT(20)
                return
            end
        end

        if platoonUnits > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if EntityCategoryContains(categories.SCOUT, v) then
                        self.ScoutPresent = true
                        scoutUnit = v
                    end
                    for _, weapon in ALLBPS[v.UnitId].Weapon or {} do
                        -- unit can have MaxWeaponRange entry from the last platoon
                        if not v.MaxWeaponRange or weapon.MaxRadius > v.MaxWeaponRange then
                            -- save the weaponrange 
                            v.MaxWeaponRange = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                            -- save the weapon balistic arc, we need this later to check if terrain is blocking the weapon line of sight
                            if weapon.BallisticArc == 'RULEUBA_LowArc' then
                                v.WeaponArc = 'low'
                            elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                                v.WeaponArc = 'high'
                            else
                                v.WeaponArc = 'none'
                            end
                        end
                        if not MaxPlatoonWeaponRange or MaxPlatoonWeaponRange < v.MaxWeaponRange then
                            MaxPlatoonWeaponRange = v.MaxWeaponRange
                        end
                    end
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                    v.smartPos = {0,0,0}
                    if not v.MaxWeaponRange then
                        --WARN('Scanning: unit ['..repr(v.UnitId)..'] has no MaxWeaponRange - '..repr(self.BuilderName))
                    end
                end
            end
        end
        while PlatoonExists(aiBrain, self) do
            target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.AIR - categories.SCOUT - categories.WALL - categories.NAVAL)
            if target then
                local threatAroundplatoon = 0

                local platoonThreat = self:GetPlatoonThreat('Surface', categories.MOBILE * categories.LAND)

                local targetPosition = target:GetPosition()

                local platoonPos = GetPlatoonPosition(self)

                if not AIAttackUtils.CanGraphToSwarm(platoonPos, targetPosition, self.MovementLayer) then return self:SetAIPlan('HuntAIPATHSwarm') end

                local platoonThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)


                self:Stop()
                self:AggressiveMoveToLocation(SWARMCOPY(target:GetPosition()))

                local position = AIUtils.RandomLocation(target:GetPosition()[1],target:GetPosition()[3])
                self:MoveToLocation(position, false)

                SWARMWAIT(30)
                platoonPos = GetPlatoonPosition(self)

                if scoutUnit and (not scoutUnit.Dead) then
                    IssueClearCommands({scoutUnit})
                    IssueMove({scoutUnit}, platoonPos)
                end

                if not platoonPos then break end
                local enemyUnitCount = GetNumUnitsAroundPoint(aiBrain, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, platoonPos, enemyRadius, 'Enemy')
                if enemyUnitCount > 0 then

                    target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.NAVAL - categories.AIR - categories.SCOUT - categories.WALL)
                    attackSquad = self:GetSquadUnits('Attack')
                    IssueClearCommands(attackSquad)

                    local platoonCount = SWARMGETN(GetPlatoonUnits(self))

                    if target then
                        local targetPosition = target:GetPosition()
                        local platoonPos = GetPlatoonPosition(self)
                        local targetThreat
                        if platoonThreat and platoonCount < platoonLimit then
                            self.PlatoonFull = false
                            --LOG('Merging with patoon count of '..platoonCount)
                            if VDist2Sq(platoonPos[1], platoonPos[3], mainBasePos[1], mainBasePos[3]) > 6400 then
                                targetThreat = GetThreatAtPosition(aiBrain, targetPosition, 0, true, 'Land')
                                --LOG('HuntAIPath targetThreat is '..targetThreat)
                                if targetThreat > platoonThreat then
                                    --LOG('HuntAIPath attempting merge and formation ')
                                    if DEBUG then
                                        for _, v in platoonUnits do
                                            if v and not v.Dead then
                                                v:SetCustomName('HuntAIPATH Trying to Merge')
                                            end
                                        end
                                    end
                                    self:Stop()
                                    local merged = self:MergeWithNearbyPlatoonsSwarm('HuntAISwarm', 25, 12)
                                    if merged then
                                        self:SetPlatoonFormationOverride('NoFormation')
                                        continue
                                    else
                                        --LOG('No merge done')
                                    end
                                end
                            end
                        else
                            --LOG('Setting platoon to full as platoonCount is greater than 15')
                            self.PlatoonFull = true
                        end

                        if EntityCategoryContains(categories.COMMAND, target) then
                            if platoonThreat < 30 then
                                self:Stop()
                                self:MoveToLocation(SwarmUtils.AvoidLocationSwarm(self:GetPosition(), targetPosition, 40), false)
                                --LOG('Target is ACU retreating')
                                --LOG('Threat Around platoon at 50 Radius = '..threatAroundplatoon)
                                --LOG('Platoon Threat = '..platoonThreat)
                                SWARMWAIT(40)
                                continue
                            end
                        end

                        while PlatoonExists(aiBrain, self) do
                            if not target.Dead then
                                --targetPosition = target:GetPosition()
                                local microCap = 50
                                for _, unit in attackSquad do
                                    microCap = microCap - 1
                                    if microCap <= 0 then break end
                                    if unit.Dead then continue end
                                    if not unit.MaxWeaponRange then
                                        continue
                                    end
                                    VariableKite(self,unit,target)
                                    if target.Dead then break end
                                end
                            else
                                break
                            end
                        SWARMWAIT(10)
                        end
                    end
                end

            elseif not movingToScout then
                movingToScout = true
                self:Stop()
                for k,v in AIUtils.AIGetSortedMassLocations(aiBrain, 10, nil, nil, nil, nil, GetPlatoonPosition(self)) do
                    if v[1] < 0 or v[3] < 0 or v[1] > ScenarioInfo.size[1] or v[3] > ScenarioInfo.size[2] then
                        --LOG('*AI DEBUG: STRIKE FORCE SENDING UNITS TO WRONG LOCATION - ' .. v[1] .. ', ' .. v[3])
                    end
                    self:MoveToLocation((v), false)
                end
            end
            
        SWARMWAIT(40)
        end
    end,

    HuntAIPATHSwarm = function(self)
        --LOG('* AI-Swarm: * HuntAIPATH: Starting')
        self:Stop()
        AIAttackUtils.GetMostRestrictiveLayer(self)
        local DEBUG = false
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local target, acuInRange
        local blip
        local categoryList = {}
        local atkPri = {}
        local platoonUnits = GetPlatoonUnits(self)
        local maxPathDistance = 250
        local enemyRadius = 40
        local data = self.PlatoonData
        local platoonLimit = self.PlatoonData.PlatoonLimit or 25
        local bAggroMove = self.PlatoonData.AggressiveMove
        local LocationType = self.PlatoonData.LocationType or 'MAIN'
        local maxRadius = data.SearchRadius or 250
        local mainBasePos
        local scoutUnit
        if LocationType then
            mainBasePos = aiBrain.BuilderManagers[LocationType].Position
        else
            mainBasePos = aiBrain.BuilderManagers['MAIN'].Position
        end
        local MaxPlatoonWeaponRange
        local unitPos
        local alpha
        local x
        local y
        local smartPos
        local rangeModifier = 0
        local platoonThreat = false
        
        if platoonUnits > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if EntityCategoryContains(categories.SCOUT, v) then
                        self.ScoutPresent = true
                        scoutUnit = v
                    end
                    for _, weapon in ALLBPS[v.UnitId].Weapon or {} do
                        -- unit can have MaxWeaponRange entry from the last platoon
                        if not v.MaxWeaponRange or weapon.MaxRadius > v.MaxWeaponRange then
                            -- save the weaponrange 
                            v.MaxWeaponRange = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                            -- save the weapon balistic arc, we need this later to check if terrain is blocking the weapon line of sight
                            if weapon.BallisticArc == 'RULEUBA_LowArc' then
                                v.WeaponArc = 'low'
                            elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                                v.WeaponArc = 'high'
                            else
                                v.WeaponArc = 'none'
                            end
                        end
                        if not MaxPlatoonWeaponRange or MaxPlatoonWeaponRange < v.MaxWeaponRange then
                            MaxPlatoonWeaponRange = v.MaxWeaponRange
                        end
                    end
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                    v.smartPos = {0,0,0}
                    if not v.MaxWeaponRange then
                        --WARN('Scanning: unit ['..repr(v.UnitId)..'] has no MaxWeaponRange - '..repr(self.BuilderName))
                    end
                end
            end
        end
        if data.TargetSearchPriorities then
            --LOG('TargetSearch present for '..self.BuilderName)
            for k,v in data.TargetSearchPriorities do
                SWARMINSERT(atkPri, v)
            end
        else
            if data.PrioritizedCategories then
                for k,v in data.PrioritizedCategories do
                    SWARMINSERT(atkPri, v)
                end
            end
        end
        if data.PrioritizedCategories then
            for k,v in data.PrioritizedCategories do
                SWARMINSERT(categoryList, v)
            end
        end

        SWARMINSERT(atkPri, categories.ALLUNITS)
        SWARMINSERT(categoryList, categories.ALLUNITS)
        self:SetPrioritizedTargetList('Attack', categoryList)

        --local debugloop = 0

        while PlatoonExists(aiBrain, self) do
            --LOG('* AI-Swarm: * HuntAIPATH:: Check for target')
            --target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.NAVAL - categories.AIR - categories.SCOUT - categories.WALL)
            if DEBUG then
                for _, v in platoonUnits do
                    if v and not v.Dead then
                        v:SetCustomName('HuntAIPATH Looking for Target')
                    end
                end
            end
            target = AIUtils.AIFindBrainTargetInRangeSwarm(aiBrain, self, 'Attack', maxRadius, atkPri)
            --[[if not target then
                LOG('No target on huntaipath loop')
                LOG('Max Radius is '..maxRadius)
                LOG('Debug loop is '..debugloop)
                debugloop = debugloop + 1
            end]]
            platoonThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)
            local platoonCount = SWARMGETN(GetPlatoonUnits(self))
            if target then
                local targetPosition = target:GetPosition()
                local platoonPos = GetPlatoonPosition(self)
                local targetThreat
                if platoonThreat and platoonCount < platoonLimit then
                    self.PlatoonFull = false
                    --LOG('Merging with patoon count of '..platoonCount)
                    if VDist2Sq(platoonPos[1], platoonPos[3], mainBasePos[1], mainBasePos[3]) > 6400 then
                        targetThreat = GetThreatAtPosition(aiBrain, targetPosition, 0, true, 'Land')
                        --LOG('HuntAIPath targetThreat is '..targetThreat)
                        if targetThreat > platoonThreat then
                            --LOG('HuntAIPath attempting merge and formation ')
                            if DEBUG then
                                for _, v in platoonUnits do
                                    if v and not v.Dead then
                                        v:SetCustomName('HuntAIPATH Trying to Merge')
                                    end
                                end
                            end
                            self:Stop()
                            local merged = self:MergeWithNearbyPlatoonsSwarm('HuntAIPATHSwarm', 25, 25)
                            if merged then
                                self:SetPlatoonFormationOverride('GrowthFormation') -- GrowthFormation is more organic and less impactful
                                SWARMWAIT(20)
                                --LOG('HuntAIPath merge and formation completed')
                                self:SetPlatoonFormationOverride('NoFormation')
                                continue
                            else
                                --LOG('No merge done')
                            end
                        end
                    end
                else
                    --LOG('Setting platoon to full as platoonCount is greater than 15')
                    self.PlatoonFull = true
                end
                --LOG('* AI-Swarm: * HuntAIPATH: Performing Path Check')
                --LOG('Details :'..' Movement Layer :'..self.MovementLayer..' Platoon Position :'..repr(GetPlatoonPosition(self))..' Target Position :'..repr(targetPosition))
                local path, reason = AIAttackUtils.PlatoonGenerateSafePathToSwarm(aiBrain, self.MovementLayer, GetPlatoonPosition(self), targetPosition, 10 , maxPathDistance)
                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, targetPosition)
                IssueClearCommands(GetPlatoonUnits(self))
                local usedTransports = false
                if path then
                    local threatAroundplatoon = 0
                    --LOG('* AI-Swarm: * HuntAIPATH:: Target Found')
                    if EntityCategoryContains(categories.COMMAND, target) then
                        platoonPos = GetPlatoonPosition(self)
                        targetPosition = target:GetPosition()
                        if platoonThreat < 30 then
                            local retreatPos = SwarmUtils.lerpy(platoonPos, targetPosition, {50, 1})
                            self:MoveToLocation(retreatPos, false)
                            --LOG('Target is ACU retreating')
                            SWARMWAIT(30)
                            continue
                        end
                    end
                    local attackUnits =  self:GetSquadUnits('Attack')
                    local attackUnitCount = SWARMGETN(attackUnits)
                    local guardUnits = self:GetSquadUnits('Guard')
                    
                    --LOG('* AI-Swarm: * HuntAIPATH: Path found')
                    local position = GetPlatoonPosition(self)
                    if not success or VDist2(position[1], position[3], targetPosition[1], targetPosition[3]) > 512 then
                        usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, targetPosition, true)
                    elseif VDist2(position[1], position[3], targetPosition[1], targetPosition[3]) > 256 then
                        usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, targetPosition, false)
                    end
                    
                    if not usedTransports then
                        local pathNodesCount = SWARMGETN(path)
                        for i=1, pathNodesCount do
                            local PlatoonPosition
                            local distEnd = false
                            if DEBUG then
                                for _, v in platoonUnits do
                                    if v and not v.Dead then
                                        v:SetCustomName('HuntAIPATH Performing Path Movement')
                                    end
                                end
                            end
                            if guardUnits then
                                local guardedUnit = 1
                                if attackUnitCount > 0 then
                                    while attackUnits[guardedUnit].Dead or attackUnits[guardedUnit]:BeenDestroyed() do
                                        guardedUnit = guardedUnit + 1
                                        SWARMWAIT(3)
                                        if guardedUnit > attackUnitCount then
                                            guardedUnit = false
                                            break
                                        end
                                    end
                                else
                                    return self:SetAIPlan('ReturnToBaseAISwarm')
                                end
                                IssueClearCommands(guardUnits)
                                if not guardedUnit then
                                    return self:SetAIPlan('ReturnToBaseAISwarm')
                                else
                                    IssueGuard(guardUnits, attackUnits[guardedUnit])
                                end
                            end
                            local currentLayerSeaBed = false
                            for _, v in attackUnits do
                                if v and not v.Dead then
                                    if v:GetCurrentLayer() ~= 'Seabed' then
                                        currentLayerSeaBed = false
                                        break
                                    else
                                        --LOG('Setting currentLayerSeaBed to true')
                                        currentLayerSeaBed = true
                                        break
                                    end
                                end
                            end
                            --LOG('* AI-Swarm: * HuntAIPATH:: moving to destination. i: '..i..' coords '..repr(path[i]))
                            if bAggroMove and attackUnits and (not currentLayerSeaBed) then
                                if distEnd and distEnd > 6400 then
                                    self:SetPlatoonFormationOverride('NoFormation')
                                    attackFormation = false
                                end
                                self:AggressiveMoveToLocation(path[i], 'Attack')
                            elseif attackUnits then
                                if distEnd and distEnd > 6400 then
                                    self:SetPlatoonFormationOverride('NoFormation')
                                    attackFormation = false
                                end
                                self:MoveToLocation(path[i], false, 'Attack')
                            end
                            --LOG('* AI-Swarm: * HuntAIPATH:: moving to Waypoint')
                            local Lastdist
                            local dist
                            local Stuck = 0
                            local retreatCount = 2
                            local attackFormation = false
                            while PlatoonExists(aiBrain, self) do
                                --LOG('Movement Loop '..debugloop)
                                --debugloop = debugloop + 1
                                local SquadPosition = self:GetSquadPosition('Attack') or nil
                                if not SquadPosition then break end
                                if scoutUnit and (not scoutUnit.Dead) then
                                    IssueClearCommands({scoutUnit})
                                    IssueMove({scoutUnit}, SquadPosition)
                                end
                                local enemyUnitCount = GetNumUnitsAroundPoint(aiBrain, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, SquadPosition, enemyRadius, 'Enemy')
                                if enemyUnitCount > 0 and (not currentLayerSeaBed) then
                                    if DEBUG then
                                        for _, v in platoonUnits do
                                            if v and not v.Dead then
                                                v:SetCustomName('HuntAIPATH Found close target, searching for target')
                                            end
                                        end
                                    end
                                    target, acuInRange, acuUnit = AIUtils.AIFindBrainTargetInCloseRangeSwarm(aiBrain, self, SquadPosition, 'Attack', enemyRadius, categories.LAND * (categories.STRUCTURE + categories.MOBILE), atkPri, false)
                                    --target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.NAVAL - categories.AIR - categories.SCOUT - categories.WALL)
                                    local attackSquad = self:GetSquadUnits('Attack')
                                    IssueClearCommands(attackSquad)
                                    while PlatoonExists(aiBrain, self) do
                                        --LOG('Micro target Loop '..debugloop)
                                        --debugloop = debugloop + 1
                                        platoonThreat = self:CalculatePlatoonThreat('Surface', categories.DIRECTFIRE)
                                        if target and not target.Dead then
                                            if DEBUG then
                                                for _, v in platoonUnits do
                                                    if v and not v.Dead then
                                                        v:SetCustomName('HuntAIPATH Target Found, attacking')
                                                    end
                                                end
                                            end
                                            if acuUnit and platoonThreat > 30 then
                                                --LOG('ACU is close and we have decent threat')
                                                target = acuUnit
                                                rangeModifier = 5
                                            end
                                            targetPosition = target:GetPosition()
                                            local microCap = 50
                                            for _, unit in attackSquad do
                                                microCap = microCap - 1
                                                if microCap <= 0 then break end
                                                if unit.Dead then continue end
                                                if not unit.MaxWeaponRange then
                                                    continue
                                                end
                                                unitPos = unit:GetPosition()
                                                alpha = SWARMATAN2 (targetPosition[3] - unitPos[3] ,targetPosition[1] - unitPos[1])
                                                x = targetPosition[1] - SWARMCOS(alpha) * (unit.MaxWeaponRange - rangeModifier or MaxPlatoonWeaponRange)
                                                y = targetPosition[3] - SWARMSIN(alpha) * (unit.MaxWeaponRange - rangeModifier or MaxPlatoonWeaponRange)
                                                smartPos = { x, GetTerrainHeight( x, y), y }
                                                -- check if the move position is new or target has moved
                                                if VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 or unit.TargetPos ~= targetPosition then
                                                    -- clear move commands if we have queued more than 4
                                                    if SWARMGETN(unit:GetCommandQueue()) > 2 then
                                                        IssueClearCommands({unit})
                                                        SWARMWAIT(3)
                                                    end
                                                    -- if our target is dead, jump out of the "for _, unit in self:GetPlatoonUnits() do" loop
                                                    IssueMove({unit}, smartPos )
                                                    if target.Dead then break end
                                                    IssueAttack({unit}, target)
                                                    --unit:SetCustomName('Fight micro moving')
                                                    unit.smartPos = smartPos
                                                    unit.TargetPos = targetPosition
                                                -- in case we don't move, check if we can fire at the target
                                                else
                                                    local dist = VDist2( unit.smartPos[1], unit.smartPos[3], unit.TargetPos[1], unit.TargetPos[3] )
                                                    if aiBrain:CheckBlockingTerrain(unitPos, targetPosition, unit.WeaponArc) then
                                                        --unit:SetCustomName('Fight micro WEAPON BLOCKED!!! ['..repr(target.UnitId)..'] dist: '..dist)
                                                        IssueMove({unit}, targetPosition )
                                                    else
                                                        --unit:SetCustomName('Fight micro SHOOTING ['..repr(target.UnitId)..'] dist: '..dist)
                                                    end
                                                end
                                            end
                                        else
                                            break
                                        end
                                        SWARMWAIT(10)
                                    end
                                end
                                distEnd = VDist2Sq(path[pathNodesCount][1], path[pathNodesCount][3], SquadPosition[1], SquadPosition[3] )
                                --LOG('* AI-Swarm: * MovePath: dist to Path End: '..distEnd)
                                if not attackFormation and distEnd < 6400 and enemyUnitCount == 0 then
                                    attackFormation = true
                                    --LOG('* AI-Swarm: * MovePath: distEnd < 6400 '..distEnd..' Switching to attack formation')
                                    self:SetPlatoonFormationOverride('AttackFormation')
                                end
                                dist = VDist2Sq(path[i][1], path[i][3], SquadPosition[1], SquadPosition[3])
                                -- are we closer then 15 units from the next marker ? Then break and move to the next marker
                                --LOG('* AI-Swarm: * HuntAIPATH: Distance to path node'..dist)
                                if dist < 400 then
                                    -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                                    self:Stop()
                                    break
                                end
                                if Lastdist ~= dist then
                                    Stuck = 0
                                    Lastdist = dist
                                -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                                else
                                    Stuck = Stuck + 1
                                    if Stuck > 15 then
                                        --LOG('* AI-Swarm: * HuntAIPATH: Stuck while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                        self:Stop()
                                        break
                                    end
                                end
                                --LOG('* AI-Swarm: * HuntAIPATH: End of movement loop, wait 10 ticks at :'..GetGameTimeSeconds())
                                SWARMWAIT(15)
                            end
                            --LOG('* AI-Swarm: * HuntAIPATH: Ending Loop at :'..GetGameTimeSeconds())
                        end
                    end
                elseif (not path and reason == 'NoPath') then
                    --LOG('* AI-Swarm: * HuntAIPATH: NoPath reason from path')
                    --LOG('Guardmarker requesting transports')
                    if DEBUG then
                        for _, v in platoonUnits do
                            if v and not v.Dead then
                                v:SetCustomName('HuntAIPATH Requesting Transport')
                            end
                        end
                    end
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, targetPosition, true)
                    --DUNCAN - if we need a transport and we cant get one the disband
                    if not usedTransports then
                        --LOG('* AI-Swarm: * HuntAIPATH: not used transports')
                        return self:SetAIPlan('ReturnToBaseAISwarm')
                    end
                    --LOG('Guardmarker found transports')
                else
                    --LOG('* AI-Swarm: * HuntAIPATH: No Path found, no reason')
                    return self:SetAIPlan('ReturnToBaseAISwarm')
                end

                if (not path or not success) and not usedTransports then
                    --LOG('* AI-Swarm: * HuntAIPATH: No Path found, no transports used')
                    return self:SetAIPlan('ReturnToBaseAISwarm')
                end
            elseif self.PlatoonData.GetTargetsFromBase then
                return self:SetAIPlan('ReturnToBaseAISwarm')
            end
            --LOG('* AI-Swarm: * HuntAIPATH: No target, waiting 5 seconds')
            SWARMWAIT(50)
        end
    end,

    MassRaidSwarm = function(self)
        local aiBrain = self:GetBrain()
        --LOG('Platoon ID is : '..self:GetPlatoonUniqueName())
        local platLoc = GetPlatoonPosition(self)
        if not PlatoonExists(aiBrain, self) or not platLoc then
            return
        end

        -----------------------------------------------------------------------
        -- Platoon Data
        -----------------------------------------------------------------------
        -- Include mass markers that are under water
        local includeWater = self.PlatoonData.IncludeWater or false

        local waterOnly = self.PlatoonData.WaterOnly or false

        -- Minimum distance when looking for closest
        local avoidClosestRadius = self.PlatoonData.AvoidClosestRadius or 0

        -- if true, look to guard highest threat, otherwise,
        -- guard the lowest threat specified
        local bFindHighestThreat = self.PlatoonData.FindHighestThreat or false

        -- minimum threat to look for
        local minThreatThreshold = self.PlatoonData.MinThreatThreshold or -1
        -- maximum threat to look for
        local maxThreatThreshold = self.PlatoonData.MaxThreatThreshold  or 99999999

        -- Avoid bases (true or false)
        local bAvoidBases = self.PlatoonData.AvoidBases or false

        -- Radius around which to avoid the main base
        local avoidBasesRadius = self.PlatoonData.AvoidBasesRadius or 0

        -- Use Aggresive Moves Only
        local bAggroMove = self.PlatoonData.AggressiveMove or false

        local PlatoonFormation = self.PlatoonData.UseFormation or 'NoFormation'

        local maxPathDistance = self.PlatoonData.MaxPathDistance or 200

        self.MassMarkerTable = self.planData.MassMarkerTable or false
        self.LoopCount = self.planData.LoopCount or 0

        -----------------------------------------------------------------------
        local markerLocations
        self.enemyRadius = 40
        local MaxPlatoonWeaponRange
        local scoutUnit = false
        local atkPri = {}
        local categoryList = {}
        local platoonThreat 
        local VDist2Sq = VDist2Sq
        local function VariableKite(platoon,unit,target)
            local function KiteDist(pos1,pos2,distance)
                local vec={}
                local dist=VDist3(pos1,pos2)
                for i,k in pos2 do
                    if type(k)~='number' then continue end
                    vec[i]=k+distance/dist*(pos1[i]-k)
                end
                return vec
            end
            local function CheckRetreat(pos1,pos2,target)
                local vel = {}
                vel[1], vel[2], vel[3]=target:GetVelocity()
                --LOG('vel is '..repr(vel))
                --LOG(repr(pos1))
                --LOG(repr(pos2))
                local dotp=0
                for i,k in pos2 do
                    if type(k)~='number' then continue end
                    dotp=dotp+(pos1[i]-k)*vel[i]
                end
                return dotp<0
            end
            if target.Dead then return end
            if unit.Dead then return end
                
            local pos=unit:GetPosition()
            local tpos=target:GetPosition()
            local dest
            local mod=3
            if CheckRetreat(pos,tpos,target) then
                mod=8
            end
            if unit.MaxWeaponRange then
                dest=KiteDist(pos,tpos,unit.MaxWeaponRange-SWARMRANDOM(1,3)-mod)
            else
                dest=KiteDist(pos,tpos,self.MaxWeaponRange+5-SWARMRANDOM(1,3)-mod)
            end
            if VDist3Sq(pos,dest)>6 then
                IssueMove({unit},dest)
                SWARMWAIT(20)
                return
            else
                SWARMWAIT(20)
                return
            end
        end

        AIAttackUtils.GetMostRestrictiveLayer(self)
        self:SetPlatoonFormationOverride(PlatoonFormation)
        local stageExpansion = false
        local platoonUnits = GetPlatoonUnits(self)
        local platoonThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)
        if platoonUnits > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if EntityCategoryContains(categories.SCOUT, v) then
                        self.ScoutPresent = true
                        self.scoutUnit = v
                    end
                    for _, weapon in ALLBPS[v.UnitId].Weapon or {} do
                        -- unit can have MaxWeaponRange entry from the last platoon
                        if not v.MaxWeaponRange or weapon.MaxRadius > v.MaxWeaponRange then
                            -- save the weaponrange 
                            v.MaxWeaponRange = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                            -- save the weapon balistic arc, we need this later to check if terrain is blocking the weapon line of sight
                            if weapon.BallisticArc == 'RULEUBA_LowArc' then
                                v.WeaponArc = 'low'
                            elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                                v.WeaponArc = 'high'
                            else
                                v.WeaponArc = 'none'
                            end
                        end
                        if not MaxPlatoonWeaponRange or MaxPlatoonWeaponRange < v.MaxWeaponRange then
                            MaxPlatoonWeaponRange = v.MaxWeaponRange
                        end
                    end
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                    v.smartPos = {0,0,0}
                    if not v.MaxWeaponRange then
                        --WARN('Scanning: unit ['..repr(v.UnitId)..'] has no MaxWeaponRange - '..repr(self.BuilderName))
                    end
                end
            end
        end

        if self.PlatoonData.TargetSearchPriorities then
            --LOG('TargetSearch present for '..self.BuilderName)
            for k,v in self.PlatoonData.TargetSearchPriorities do
                SWARMINSERT(atkPri, v)
            end
        else
            if self.PlatoonData.PrioritizedCategories then
                for k,v in self.PlatoonData.PrioritizedCategories do
                    SWARMINSERT(atkPri, v)
                end
            end
        end
        if self.PlatoonData.PrioritizedCategories then
            for k,v in self.PlatoonData.PrioritizedCategories do
                SWARMINSERT(categoryList, v)
            end
        end
        self:SetPrioritizedTargetList('Attack', categoryList)
        self.atkPri = atkPri

        if self.MovementLayer == 'Land' and not self.PlatoonData.EarlyRaid then
            local stageExpansion = SwarmUtils.QueryExpansionTableSwarm(aiBrain, platLoc, SWARMMIN(BaseMilitaryZone, 250), self.MovementLayer, 10)
            if stageExpansion then
                --LOG('Stage Position key returned for '..stageExpansion.Key..' Name is '..stageExpansion.Expansion.Name)
                platLoc = GetPlatoonPosition(self) or nil
                local path, reason = AIAttackUtils.PlatoonGenerateSafePathToSwarm(aiBrain, self.MovementLayer, platLoc, stageExpansion.Expansion.Position, 10 , maxPathDistance)
                if path then
                    --LOG('Found path to expansion, moving to position')
                    self:PlatoonMoveWithMicroSwarm(aiBrain, path, false)
                    aiBrain.ExpansionWatchTableSwarm[stageExpansion.Key].TimeStamp = GetGameTimeSeconds()
                    --LOG('Arrived at expansion, set timestamp to '..aiBrain.ExpansionWatchTableSwarm[stageExpansion.Key].TimeStamp)
                end
                platLoc = GetPlatoonPosition(self)
            end
        end

        markerLocations = SwarmUtils.AIGetMassMarkerLocations(aiBrain, includeWater, waterOnly)
        local bestMarker = false

        if not self.LastMarker then
            self.LastMarker = {nil,nil}
        end

        -- look for a random marker
        --[[Marker table examples for better understanding what is happening below 
        info: Marker Current{ Name="Mass7", Position={ 189.5, 24.240200042725, 319.5, type="VECTOR3" } }
        info: Marker Last{ { 374.5, 20.650400161743, 154.5, type="VECTOR3" } }
        ]] 

        local bestMarkerThreat = 0
        if not bFindHighestThreat then
            bestMarkerThreat = 99999999
        end

        local bestDistSq = 99999999
        -- find best threat at the closest distance
        for _,marker in markerLocations do
            local markerThreat
            local enemyThreat
            markerThreat = GetThreatAtPosition(aiBrain, marker.Position, aiBrain.IMAPConfigSwarm.Rings, true, 'Economy')
            if self.MovementLayer == 'Water' then
                enemyThreat = GetThreatAtPosition(aiBrain, marker.Position, aiBrain.IMAPConfigSwarm.Rings + 1, true, 'AntiSub')
            else
                enemyThreat = GetThreatAtPosition(aiBrain, marker.Position, aiBrain.IMAPConfigSwarm.Rings + 1, true, 'AntiSurface')
            end
            --LOG('Best pre calculation marker threat is '..markerThreat..' at position'..repr(marker.Position))
            --LOG('Surface Threat at marker is '..enemyThreat..' at position'..repr(marker.Position))
            if enemyThreat > 0 and markerThreat then
                markerThreat = markerThreat / enemyThreat
            end
            local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])

            if markerThreat >= minThreatThreshold and markerThreat <= maxThreatThreshold then
                if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) and distSq > (avoidClosestRadius * avoidClosestRadius) then
                    if self.IsBetterThreat(bFindHighestThreat, markerThreat, bestMarkerThreat) then
                        bestDistSq = distSq
                        bestMarker = marker
                        bestMarkerThreat = markerThreat
                    elseif markerThreat == bestMarkerThreat then
                        if distSq < bestDistSq then
                            bestDistSq = distSq
                            bestMarker = marker
                            bestMarkerThreat = markerThreat
                        end
                    end
                end
            end
        end
        --[[
        if waterOnly then
            if bestMarker then
                LOG('Water based best marker is  '..repr(bestMarker))
                LOG('Best marker threat is '..bestMarkerThreat)
            else
                LOG('Water based no best marker')
            end
        end]]

        --LOG('* AI-Swarm: Best Marker Selected is at position'..repr(bestMarker.Position))
        
        if bestMarker.Position == nil and GetGameTimeSeconds() > 600 and self.MovementLayer ~= 'Water' then
            --LOG('Best Marker position was nil and game time greater than 15 mins, switch to hunt ai')
            return self:SetAIPlan('HuntAIPATHSwarm')
        elseif bestMarker.Position == nil then
            
            
            if SWARMGETN(aiBrain.ExpansionWatchTableSwarm) > 0  and (not self.EarlyRaidSet) then
                for k, v in aiBrain.ExpansionWatchTableSwarm do
                    local distSq = VDist2Sq(v.Position[1], v.Position[3], platLoc[1], platLoc[3])
                    if distSq > (avoidClosestRadius * avoidClosestRadius) and AIAttackUtils.CanGraphToSwarm(platLoc, v.Position, self.MovementLayer) then
                        if not v.PlatoonAssigned then
                            bestMarker = v
                            aiBrain.ExpansionWatchTableSwarm[k].PlatoonAssigned = self
                            --LOG('Expansion Best marker selected is index '..k..' at '..repr(bestMarker.Position))
                            break
                        end
                    else
                        --LOG('Cant Graph to expansion marker location')
                    end
                    --LOG('Distance to marker '..k..' is '..VDist2(v.Position[1],v.Position[3],platLoc[1], platLoc[3]))
                end
            end
            if self.PlatoonData.EarlyRaid then
                self.EarlyRaidSet = true
            end
            if not bestMarker then
                --LOG('Best Marker position was nil, select random')
                if not self.MassMarkerTable then
                    self.MassMarkerTable = markerLocations
                else
                    --LOG('Found old marker table, using that')
                end
                if SWARMGETN(self.MassMarkerTable) <= 2 then
                    self.LastMarker[1] = nil
                    self.LastMarker[2] = nil
                end
                local startX, startZ = aiBrain:GetArmyStartPos()

                SWARMSORT(self.MassMarkerTable,function(a,b) return VDist2Sq(a.Position[1], a.Position[3],startX, startZ) / (VDist2Sq(a.Position[1], a.Position[3], platLoc[1], platLoc[3]) + SwarmUtils.EdgeDistance(a.Position[1],a.Position[3],ScenarioInfo.size[1])) > VDist2Sq(b.Position[1], b.Position[3], startX, startZ) / (VDist2Sq(b.Position[1], b.Position[3], platLoc[1], platLoc[3]) + SwarmUtils.EdgeDistance(b.Position[1],b.Position[3],ScenarioInfo.size[1])) end)
                --LOG('Sorted table '..repr(markerLocations))
                --LOG('Marker table is before loop is '..SWARMGETN(self.MassMarkerTable))

                for k,marker in self.MassMarkerTable do
                    if SWARMGETN(self.MassMarkerTable) <= 2 then
                        self.LastMarker[1] = nil
                        self.LastMarker[2] = nil
                        self.MassMarkerTable = false
                        return self:SetAIPlan('ReturnToBaseAISwarm')
                    end
                    local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])
                    if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) and distSq > (avoidClosestRadius * avoidClosestRadius) then
                        if self.LastMarker[1] and marker.Position[1] == self.LastMarker[1][1] and marker.Position[3] == self.LastMarker[1][3] then
                            continue
                        end
                        if self.LastMarker[2] and marker.Position[1] == self.LastMarker[2][1] and marker.Position[3] == self.LastMarker[2][3] then
                            continue
                        end

                        bestMarker = marker
                        --LOG('Delete Marker '..repr(marker))
                        SWARMREMOVE(self.MassMarkerTable, k)
                        break
                    end
                end
                SWARMWAIT(2)
                --LOG('Marker table is after loop is '..SWARMGETN(self.MassMarkerTable))
                --LOG('bestMarker is '..repr(bestMarker))
            end
        end

        local usedTransports = false

        if bestMarker then
            self.LastMarker[2] = self.LastMarker[1]
            self.LastMarker[1] = bestMarker.Position
            --LOG("MassRaid: Attacking " .. bestMarker.Name)
            local path, reason = AIAttackUtils.PlatoonGenerateSafePathToSwarm(aiBrain, self.MovementLayer, GetPlatoonPosition(self), bestMarker.Position, 10 , maxPathDistance)
            local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, bestMarker.Position)
            IssueClearCommands(GetPlatoonUnits(self))
            if path then
                
                platLoc = GetPlatoonPosition(self)
                if not success or VDist2Sq(platLoc[1], platLoc[3], bestMarker.Position[1], bestMarker.Position[3]) > 262144 then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, bestMarker.Position, true)
                elseif VDist2Sq(platLoc[1], platLoc[3], bestMarker.Position[1], bestMarker.Position[3]) > 65536 and (not self.PlatoonData.EarlyRaid) then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, bestMarker.Position, false)
                end
                if not usedTransports then
                    self:PlatoonMoveWithMicroSwarm(aiBrain, path, self.PlatoonData.Avoid)
                end
            elseif (not path and reason == 'NoPath') then
                --LOG('MassRaid requesting transports')
                if not self.PlatoonData.EarlyRaid then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheckSwarm(aiBrain, self, bestMarker.Position, true)
                end
                --DUNCAN - if we need a transport and we cant get one the disband
                if not usedTransports then
                    --LOG('MASSRAID no transports')
                    if self.MassMarkerTable then
                        if self.LoopCount > 15 then
                            --LOG('Loop count greater than 15, return to base')
                            return self:SetAIPlan('ReturnToBaseAISwarm')
                        end
                        local data = {}
                        data.MassMarkerTable = self.MassMarkerTable
                        self.LoopCount = self.LoopCount + 1
                        data.LoopCount = self.LoopCount
                        --LOG('No path and no transports to location, setting table data and restarting')
                        return self:SetAIPlan('MassRaidSwarm', nil, data)
                    end
                    --LOG('No path and no transports to location, return to base')
                    return self:SetAIPlan('ReturnToBaseAISwarm')
                end
                --LOG('Guardmarker found transports')
            else
                --LOG('Path error in MASSRAID')
                return self:SetAIPlan('ReturnToBaseAISwarm')
            end

            if (not path or not success) and not usedTransports then
                --LOG('not path or not success or not usedTransports MASSRAID')
                return self:SetAIPlan('ReturnToBaseAISwarm')
            end
            
            platLoc = GetPlatoonPosition(self)
            if aiBrain:CheckBlockingTerrain(platLoc, bestMarker.Position, 'none') then
                self:MoveToLocation(bestMarker.Position, false)
            else
                self:AggressiveMoveToLocation(bestMarker.Position)
            end

            -- wait till we get there
            local oldPlatPos = GetPlatoonPosition(self)
            local StuckCount = 0
            repeat
                SWARMWAIT(50)
                platLoc = GetPlatoonPosition(self)
                if VDist3(oldPlatPos, platLoc) < 1 then
                    StuckCount = StuckCount + 1
                else
                    StuckCount = 0
                end
                if StuckCount > 5 then
                    --LOG('MassRaidAI stuck count over 5, restarting')
                    return self:SetAIPlan('MassRaidSwarm')
                end
                oldPlatPos = platLoc
            until VDist2Sq(platLoc[1], platLoc[3], bestMarker.Position[1], bestMarker.Position[3]) < 64 or not PlatoonExists(aiBrain, self)

            -- we're there... wait here until we're done
            local numGround = GetNumUnitsAroundPoint(aiBrain, (categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 15, 'Enemy')
            while numGround > 0 and PlatoonExists(aiBrain, self) do
                local target, acuInRange = AIUtils.AIFindBrainTargetInCloseRangeSwarm(aiBrain, self, GetPlatoonPosition(self), 'Attack', 20, (categories.LAND + categories.NAVAL + categories.STRUCTURE), self.atkPri, false)
                --LOG('At mass marker and checking for enemy units/structures')
                platLoc = GetPlatoonPosition(self)
                platoonThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)
                local target, acuInRange, acuUnit, totalThreat = AIUtils.AIFindBrainTargetInCloseRangeSwarm(aiBrain, self, platLoc, 'Attack', 20, (categories.LAND + categories.NAVAL + categories.STRUCTURE), self.atkPri, false)
                local attackSquad = self:GetSquadUnits('Attack')
                --LOG('Mass raid at position platoonThreat is '..platoonThreat..' Enemy threat is '..totalThreat)
                if platoonThreat < totalThreat then
                    local alternatePos = false
                    local mergePlatoon = false
                    local targetPos = target:GetPosition()
                    --LOG('Attempt to run away from high threat')
                    self:Stop()
                    self:MoveToLocation(SwarmUtils.AvoidLocationSwarm(platLoc,targetPos,50), false)
                    SWARMWAIT(40)
                    platLoc = GetPlatoonPosition(self)
                    local massPoints = GetUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION, platLoc, 120, 'Enemy')
                    if massPoints then
                        --LOG('Try to run to masspoint')
                        local massPointPos
                        for _, v in massPoints do
                            if not v.Dead then
                                massPointPos = v:GetPosition()
                                if VDist2Sq(massPointPos[1], massPointPos[2],platLoc[1], platLoc[3]) < VDist2Sq(massPointPos[1], massPointPos[2],targetPos[1], targetPos[3]) then
                                    --LOG('Found a masspoint to run to')
                                    alternatePos = massPointPos
                                end
                            end
                        end
                    end
                    if alternatePos then
                        --LOG('Moving to masspoint alternative at '..repr(alternatePos))
                        self:MoveToLocation(alternatePos, false)
                    else
                        --LOG('No close masspoint try to find platoon to merge with')
                        mergePlatoon, alternatePos = self:GetClosestPlatoonSwarm('MassRaidSwarm')
                        if alternatePos then
                            self:MoveToLocation(alternatePos, false)
                        end
                    end
                    if alternatePos then
                        local Lastdist
                        local dist
                        local Stuck = 0
                        while PlatoonExists(aiBrain, self) do
                            --LOG('Moving to alternate position')
                            --LOG('We are '..VDist3(PlatoonPosition, alternatePos)..' from alternate position')
                            SWARMWAIT(10)
                            if mergePlatoon and PlatoonExists(aiBrain, mergePlatoon) then
                                --LOG('MergeWith Platoon position updated')
                                alternatePos = GetPlatoonPosition(mergePlatoon)
                            end
                            self:MoveToLocation(alternatePos, false)
                            platLoc = GetPlatoonPosition(self)
                            dist = VDist2Sq(alternatePos[1], alternatePos[3], platLoc[1], platLoc[3])
                            if dist < 225 then
                                self:Stop()
                                if mergePlatoon and PlatoonExists(aiBrain, mergePlatoon) then
                                    self:MergeWithNearbyPlatoonsSwarm('MassRaidSwarm', 50, 30)
                                end
                                --LOG('Arrived at either masspoint or friendly massraid')
                                break
                            end
                            if Lastdist ~= dist then
                                Stuck = 0
                                Lastdist = dist
                            else
                                Stuck = Stuck + 1
                                if Stuck > 15 then
                                    self:Stop()
                                    break
                                end
                            end
                            SWARMWAIT(30)
                            --LOG('End of movement loop we are '..VDist3(PlatoonPosition, alternatePos)..' from alternate position')
                        end
                    end
                end
                IssueClearCommands(attackSquad)
                while PlatoonExists(aiBrain, self) do
                    if target and not target.Dead then
                        local targetPosition = target:GetPosition()
                        local microCap = 50
                        for _, unit in attackSquad do
                            microCap = microCap - 1
                            if microCap <= 0 then break end
                            if unit.Dead then continue end
                            if not unit.MaxWeaponRange then
                                continue
                            end
                            IssueClearCommands({unit})
                            VariableKite(self,unit,target)
                        end
                    else
                        break
                    end
                    SWARMWAIT(10)
                end
                SWARMWAIT(Random(40,80))
                --LOG('Still enemy stuff around marker position')
                numGround = GetNumUnitsAroundPoint(aiBrain, (categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 15, 'Enemy')
            end

            if not PlatoonExists(aiBrain, self) then
                return
            end
            --LOG('MassRaidAI restarting')
            self:Stop()
            self:MergeWithNearbyPlatoonsSwarm('MassRaidSwarm', 60, 20)
            self:SetPlatoonFormationOverride('NoFormation')
            --LOG('MassRaid Merge attempted, restarting raid')
            if not self.RestartCount then
                self.RestartCount = 1
            else
                self.RestartCount = self.RestartCount + 1
            end
            if self.RestartCount > 50 then
                return self:SetAIPlan('HuntAIPATHSwarm')
            end
            return self:MassRaidSwarm()
        else
            -- no marker found, disband!
            --LOG('no marker found, disband MASSRAID')
            self:SetPlatoonFormationOverride('NoFormation')
            return self:SetAIPlan('HuntAIPATHSwarm')
        end
    end,

    PlatoonMoveWithMicroSwarm = function(self, aiBrain, path, avoid)
        -- I've tried to split out the platoon movement function as its getting too messy and hard to maintain
        -- I agree with Mr. Relly

        local function VariableKite(platoon,unit,target)
            local function KiteDist(pos1,pos2,distance)
                local vec={}
                local dist=VDist3(pos1,pos2)
                for i,k in pos2 do
                    if type(k)~='number' then continue end
                    vec[i]=k+distance/dist*(pos1[i]-k)
                end
                return vec
            end
            local function CheckRetreat(pos1,pos2,target)
                local vel = {}
                vel[1], vel[2], vel[3]=target:GetVelocity()
                --LOG('vel is '..repr(vel))
                --LOG(repr(pos1))
                --LOG(repr(pos2))
                local dotp=0
                for i,k in pos2 do
                    if type(k)~='number' then continue end
                    dotp=dotp+(pos1[i]-k)*vel[i]
                end
                return dotp<0
            end
            if target.Dead then return end
            if unit.Dead then return end
                
            local pos=unit:GetPosition()
            local tpos=target:GetPosition()
            local dest
            local mod=3
            if CheckRetreat(pos,tpos,target) then
                mod=8
            end
            if unit.MaxWeaponRange then
                dest=KiteDist(pos,tpos,unit.MaxWeaponRange-SWARMRANDOM(1,3)-mod)
            else
                dest=KiteDist(pos,tpos,self.MaxWeaponRange+5-SWARMRANDOM(1,3)-mod)
            end
            if VDist3Sq(pos,dest)>6 then
                IssueMove({unit},dest)
                SWARMWAIT(20)
                return
            else
                SWARMWAIT(20)
                return
            end
        end

        local pathLength = SWARMGETN(path)
        local platoonThreat
        for i=1, pathLength - 1 do
            --LOG('* AI-Swarm: * MassRaidSwarm: moving to destination. i: '..i..' coords '..repr(path[i]))
            if self.PlatoonData.AggressiveMove then
                self:AggressiveMoveToLocation(path[i])
            else
                self:MoveToLocation(path[i], false)
            end
            --LOG('* AI-Swarm: * MassRaidSwarm: moving to Waypoint')
            local PlatoonPosition
            local Lastdist
            local dist
            local Stuck = 0
            while PlatoonExists(aiBrain, self) do
                PlatoonPosition = GetPlatoonPosition(self) or nil
                if not PlatoonPosition then break end
                if self.scoutUnit and (not self.scoutUnit.Dead) then
                    IssueClearCommands({self.scoutUnit})
                    IssueMove({self.scoutUnit}, PlatoonPosition)
                end
                dist = VDist2Sq(path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3])
                -- are we closer then 15 units from the next marker ? Then break and move to the next marker
                if dist < 400 then
                    -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                    self:Stop()
                    break
                end
                -- Do we move ?
                if Lastdist ~= dist then
                    Stuck = 0
                    Lastdist = dist
                -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                else
                    Stuck = Stuck + 1
                    if Stuck > 15 then
                        --LOG('* AI-Swarm: * MassRaidSwarm: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                        self:Stop()
                        break
                    end
                end
                local enemyUnitCount = GetNumUnitsAroundPoint(aiBrain, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, PlatoonPosition, self.enemyRadius, 'Enemy')
                if enemyUnitCount > 0 then
                    local attackSquad = self:GetSquadUnits('Attack')
                    -- local target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.NAVAL - categories.AIR - categories.SCOUT - categories.WALL)
                    platoonThreat = self:CalculatePlatoonThreat('Surface', categories.ALLUNITS)
                    local target, acuInRange, acuUnit, totalThreat = AIUtils.AIFindBrainTargetInCloseRangeSwarm(aiBrain, self, PlatoonPosition, 'Attack', self.enemyRadius, categories.ALLUNITS - categories.NAVAL - categories.AIR - categories.SCOUT - categories.WALL, self.atkPri, false)
                    if acuInRange then
                        target = false
                        --LOG('ACU is in close range, we could avoid or do some other stuff')
                        if platoonThreat < 25 then
                            local alternatePos = false
                            local mergePlatoon = false
                            local acuPos = acuUnit:GetPosition()
                            --LOG('Attempt to run away from acu')
                            --LOG('we are now '..VDist3(PlatoonPosition, acuUnit:GetPosition())..' from acu')
                            self:Stop()
                            self:MoveToLocation(SwarmUtils.AvoidLocationSwarm(PlatoonPosition,acuPos,40), false)
                            SWARMWAIT(40)
                            PlatoonPosition = GetPlatoonPosition(self)
                            --LOG('after move wait we are now '..VDist3(PlatoonPosition, acuUnit:GetPosition())..' from acu')
                            local massPoints = GetUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION, PlatoonPosition, 120, 'Enemy')
                            if massPoints then
                                --LOG('Try to run to masspoint')
                                local massPointPos
                                for _, v in massPoints do
                                    if not v.Dead then
                                        massPointPos = v:GetPosition()
                                        if VDist2Sq(massPointPos[1], massPointPos[2],PlatoonPosition[1], PlatoonPosition[3]) < VDist2Sq(massPointPos[1], massPointPos[2],acuPos[1], acuPos[3]) then
                                            --LOG('Found a masspoint to run to')
                                            alternatePos = massPointPos
                                        end
                                    end
                                end
                            end
                            if not alternatePos then
                                mergePlatoon, alternatePos = self:GetClosestPlatoonSwarm('MassRaidSwarm')
                            end
                            if alternatePos then
                                while PlatoonExists(aiBrain, self) do
                                    --LOG('Moving to alternate position')
                                    --LOG('We are '..VDist3(PlatoonPosition, alternatePos)..' from alternate position')
                                    SWARMWAIT(10)
                                    if mergePlatoon and PlatoonExists(aiBrain, mergePlatoon) then
                                        --LOG('MergeWith Platoon position updated')
                                        alternatePos = GetPlatoonPosition(mergePlatoon)
                                    end
                                    self:MoveToLocation(alternatePos, false)
                                    PlatoonPosition = GetPlatoonPosition(self)
                                    dist = VDist2Sq(alternatePos[1], alternatePos[3], PlatoonPosition[1], PlatoonPosition[3])
                                    if dist < 225 then
                                        self:Stop()
                                        if mergePlatoon and PlatoonExists(aiBrain, mergePlatoon) then
                                            self:MergeWithNearbyPlatoonsSwarm('MassRaidSwarm', 50, 20)
                                        end
                                        --LOG('Arrived at either masspoint or friendly massraid')
                                        break
                                    end
                                    if Lastdist ~= dist then
                                        Stuck = 0
                                        Lastdist = dist
                                    else
                                        Stuck = Stuck + 1
                                        if Stuck > 15 then
                                            self:Stop()
                                            break
                                        end
                                    end
                                    SWARMWAIT(30)
                                    --LOG('End of movement loop we are '..VDist3(PlatoonPosition, alternatePos)..' from alternate position')
                                end
                            end
                        end
                    end
                    if avoid then
                        --LOG('We should be avoiding this unit if its threat is higher than ours')
                    end
                    --LOG('MoveWithMicro - platoon threat '..platoonThreat.. ' Enemy Threat '..totalThreat)
                    if avoid and totalThreat > platoonThreat then
                        --LOG('MoveWithMicro - Threat too high are we are in avoid mode')
                        local alternatePos = false
                        local mergePlatoon = false
                        if target and not target.Dead then
                            local unitPos = target:GetPosition() 
                            --LOG('Attempt to run away from unit')
                            --LOG('before run away we are  '..VDist3(PlatoonPosition, target:GetPosition())..' from enemy')
                            self:Stop()
                            self:MoveToLocation(SwarmUtils.AvoidLocationSwarm(PlatoonPosition,unitPos,40), false)
                            SWARMWAIT(40)
                            PlatoonPosition = GetPlatoonPosition(self)
                            --LOG('we are now '..VDist3(PlatoonPosition, target:GetPosition())..' from enemy')
                            local massPoints = GetUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION, PlatoonPosition, 120, 'Enemy')
                            if massPoints then
                                --LOG('Try to run to masspoint')
                                local massPointPos
                                for _, v in massPoints do
                                    if not v.Dead then
                                        massPointPos = v:GetPosition()
                                        if VDist2Sq(massPointPos[1], massPointPos[2],PlatoonPosition[1], PlatoonPosition[3]) < VDist2Sq(massPointPos[1], massPointPos[2],unitPos[1], unitPos[3]) then
                                            --LOG('Found a masspoint to run to')
                                            alternatePos = massPointPos
                                        end
                                    end
                                end
                            end
                            if not alternatePos then
                                --LOG('MoveWithMicro - No masspoint, look for closest platoon of massraidrng to run to')
                                mergePlatoon, alternatePos = self:GetClosestPlatoonSwarm('MassRaidSwarm')
                            end
                            if alternatePos then
                                --LOG('MoveWithMicro - We found either an extractor or platoon')
                                self:MoveToLocation(alternatePos, false)
                                while PlatoonExists(aiBrain, self) do
                                    --LOG('Moving to alternate position')
                                    --LOG('We are '..VDist3(PlatoonPosition, alternatePos)..' from alternate position')
                                    SWARMWAIT(10)
                                    if mergePlatoon and PlatoonExists(aiBrain, mergePlatoon) then
                                        --LOG('MergeWith Platoon position updated')
                                        alternatePos = GetPlatoonPosition(mergePlatoon)
                                    end
                                    self:MoveToLocation(alternatePos, false)
                                    PlatoonPosition = GetPlatoonPosition(self)
                                    dist = VDist2Sq(alternatePos[1], alternatePos[3], PlatoonPosition[1], PlatoonPosition[3])
                                    if dist < 400 then
                                        self:Stop()
                                        if mergePlatoon and PlatoonExists(aiBrain, mergePlatoon) then
                                            self:MergeWithNearbyPlatoonsSwarm('MassRaidSwarm', 50, 20)
                                        end
                                        --LOG('Arrived at either masspoint or friendly massraid')
                                        break
                                    end
                                    if Lastdist ~= dist then
                                        Stuck = 0
                                        Lastdist = dist
                                    else
                                        Stuck = Stuck + 1
                                        if Stuck > 15 then
                                            self:Stop()
                                            break
                                        end
                                    end
                                    SWARMWAIT(20)
                                    --LOG('End of movement loop we are '..VDist3(PlatoonPosition, alternatePos)..' from alternate position')
                                end
                            end
                        end
                    end
                    self:Stop()
                    while PlatoonExists(aiBrain, self) do
                        if target and not target.Dead then
                            local targetPosition = target:GetPosition()
                            attackSquad = self:GetSquadUnits('Attack')
                            local microCap = 50
                            for _, unit in attackSquad do
                                microCap = microCap - 1
                                if microCap <= 0 then break end
                                if unit.Dead then continue end
                                if not unit.MaxWeaponRange then
                                    continue
                                end
                                IssueClearCommands({unit})
                                VariableKite(self,unit,target)
                            end
                        else
                            self:MoveToLocation(path[i], false)
                            break
                        end
                        SWARMWAIT(10)
                    end
                end
                SWARMWAIT(15)
            end
        end
    end,

    GetClosestPlatoonSwarm = function(self, planName)
        local aiBrain = self:GetBrain()
        if not aiBrain then
            return
        end
        if self.UsingTransport then
            return
        end
        local platPos = GetPlatoonPosition(self)
        if not platPos then
            return
        end
        local closestPlatoon = false
        local closestDistance = 62,500
        local closestAPlatPos = false
        --LOG('Getting list of allied platoons close by')
        AlliedPlatoons = aiBrain:GetPlatoonsList()
        for _,aPlat in AlliedPlatoons do
            if aPlat.PlanName != planName then
                continue
            end
            if aPlat == self then
                continue
            end

            if aPlat.UsingTransport then
                continue
            end

            if aPlat.PlatoonFull then
                --LOG('Remote platoon is full, skip')
                continue
            end
            if not self.MovementLayer then
                AIAttackUtils.GetMostRestrictiveLayer(self)
            end
            if not aPlat.MovementLayer then
                AIAttackUtils.GetMostRestrictiveLayer(aPlat)
            end

            -- make sure we're the same movement layer type to avoid hamstringing air of amphibious
            if self.MovementLayer != aPlat.MovementLayer then
                continue
            end
            local aPlatPos = GetPlatoonPosition(aPlat)
            local aPlatDistance = VDist2Sq(platPos[1],platPos[3],aPlatPos[1],aPlatPos[3])
            if aPlatDistance < closestDistance then
                closestPlatoon = aPlat
                closestDistance = aPlatDistance
                closestAPlatPos = aPlatPos
            end
        end
        if closestPlatoon then
            --LOG('Found platoon checking if can graph')
            if AIAttackUtils.CanGraphToSwarm(platPos,closestAPlatPos,self.MovementLayer) then
                --LOG('Can graph to platoon, returning platoon and platoon location')
                return closestPlatoon, closestAPlatPos
            end
        end
        --LOG('No platoon found within 250 units')
        return false, false
    end,


    DistressResponseAISwarm = function(self)
        local aiBrain = self:GetBrain()
        while PlatoonExists(aiBrain, self) do
            if not self.UsingTransport then
                if aiBrain.BaseMonitor.AlertSounded or aiBrain.BaseMonitor.PlatoonAlertSounded then
                    -- In the loop so they may be changed by other platoon things
                    local distressRange = self.PlatoonData.DistressRange or aiBrain.BaseMonitor.DefaultDistressRange
                    local reactionTime = self.PlatoonData.DistressReactionTime or aiBrain.BaseMonitor.PlatoonDefaultReactionTime
                    local threatThreshold = self.PlatoonData.ThreatSupport or 1
                    local platoonPos = GetPlatoonPosition(self)
                    if platoonPos and not self.DistressCall then
                        -- Find a distress location within the platoons range
                        local distressLocation = aiBrain:BaseMonitorDistressLocationSwarm(platoonPos, distressRange, threatThreshold)
                        local moveLocation

                        -- We found a location within our range! Activate!
                        if distressLocation then
                            --LOG('*AI DEBUG: ARMY '.. aiBrain:GetArmyIndex() ..': --- DISTRESS RESPONSE AI ACTIVATION ---')
                            --LOG('Distress response activated')
                            --LOG('PlatoonDistressTable'..repr(aiBrain.BaseMonitor.PlatoonDistressTable))
                            --LOG('BaseAlertTable'..repr(aiBrain.BaseMonitor.AlertsTable))
                            -- Backups old ai plan
                            local oldPlan = self:GetPlan()
                            if self.AiThread then
                                self.AIThread:Destroy()
                            end

                            -- Continue to position until the distress call wanes
                            repeat
                                moveLocation = distressLocation
                                self:Stop()
                                --LOG('Platoon responding to distress at location '..repr(distressLocation))
                                self:SetPlatoonFormationOverride('NoFormation')
                                local cmd = self:AggressiveMoveToLocation(distressLocation)
                                repeat
                                    WaitSeconds(reactionTime)
                                    if not PlatoonExists(aiBrain, self) then
                                        return
                                    end
                                until not self:IsCommandsActive(cmd) or GetThreatAtPosition(aiBrain, moveLocation, 0, true, 'Overall') <= threatThreshold
                                --LOG('Initial Distress Response Loop finished')

                                platoonPos = GetPlatoonPosition(self)
                                if platoonPos then
                                    -- Now that we have helped the first location, see if any other location needs the help
                                    distressLocation = aiBrain:BaseMonitorDistressLocationSwarm(platoonPos, distressRange)
                                    if distressLocation then
                                        self:SetPlatoonFormationOverride('NoFormation')
                                        self:AggressiveMoveToLocation(distressLocation)
                                    end
                                end
                                SWARMWAIT(10)
                            -- If no more calls or we are at the location; break out of the function
                            until not distressLocation or (distressLocation[1] == moveLocation[1] and distressLocation[3] == moveLocation[3])

                            --LOG('*AI DEBUG: '..aiBrain.Name..' DISTRESS RESPONSE AI DEACTIVATION - oldPlan: '..oldPlan)
                            self:Stop()
                            self:SetAIPlan(oldPlan)
                        end
                    end
                end
            end
            SWARMWAIT(110)
        end
    end,

    ExtractorCallForHelpAISwarm = function(self, aiBrain)
        local checkTime = self.PlatoonData.DistressCheckTime or 4
        local pos = GetPlatoonPosition(self)
        while PlatoonExists(aiBrain, self) and pos do
            if not self.DistressCall then
                local threat = GetThreatAtPosition(aiBrain, pos, aiBrain.IMAPConfigSwarm.Rings, true, 'Land')
                --LOG('Threat at Extractor :'..threat)
                if threat and threat > 1 then
                    --LOG('*SwarmAI Mass Extractor Platoon Calling for help with '..threat.. ' threat')
                    aiBrain:BaseMonitorPlatoonDistressSwarm(self, threat)
                    self.DistressCall = true

                    -- add more area to scout for better efficiency of the platoon when calling for help 

                    local x1 = pos[1] - (aiBrain.IMAPConfigSwarm.RescueRadius / 2) 

                    local y1 = pos[3] - (aiBrain.IMAPConfigSwarm.RescueRadius / 2) 

                    local x2 = pos[1] + (aiBrain.IMAPConfigSwarm.RescueRadius / 2) 

                    local y2 = pos[3] + (aiBrain.IMAPConfigSwarm.RescueRadius / 2) 

                    aiBrain:AddScoutArea({x1, 0, y1}, false)  -- top left corner of the rescue area  

                    aiBrain:AddScoutArea({x2, 0, y2}, false)  -- bottom right corner of the rescue area  

                end
            end

            WaitSeconds(checkTime)

        end

    end,

    PlatoonDistressAISwarm = function(self)
        local aiBrain = self:GetBrain()
        while aiBrain:PlatoonExists(self) do
            local platoonUnits = self:GetPlatoonUnits()
            if not aiBrain.BaseMonitor.AlertSounded then return end

            -- Check for Platoon Death, once killed, remove all distress calls from base monitor and clear the distress call variable so platoon can request help again later.  This will allow us to re-use this platoons distress call in case of death without having to wait for it to be able to request help again later.  Also allows other platoons that are still alive and operating normally within range of the dead platoon's distress call to respond instead of waiting on new requests from other dead platoons.   -GBD

            if table.getn(platoonUnits) == 0 then
                --LOG('*AI DEBUG: Platoon Dead')
                aiBrain.BaseMonitor.PlatoonDistressTable[self.DistressCall] = nil
                self.DistressCall = false
            end

            local pos = self:GetPlatoonPosition()

            if not pos then return end

            local distressRange = aiBrain.BaseMonitor.PoolDistressRange or 200
            local threatatLocation = aiBrain:GetThreatAtPosition(pos, aiBrain.IMAPConfigSwarm.Rings, true, 'AntiSurface')

            if threatatLocation and threatatLocation > 5 then  -- If our current location is being attacked by more than X units at once... we need help! -GBD
                --LOG('*AI DEBUG: Platoon Calling for Help from Distress Call')
                aiBrain:BaseMonitorDistressLocationSwarm(pos, distressRange, 'AntiSurface', threatatLocation)
            end

            WaitSeconds(5)
        end
    end,

    BaseManagersDistressAISwarm = function(self)
        local aiBrain = self:GetBrain()
        while PlatoonExists(aiBrain, self) do
            local distressRange = aiBrain.BaseMonitor.PoolDistressRange
            local reactionTime = aiBrain.BaseMonitor.PoolReactionTime

            local platoonUnits = GetPlatoonUnits(self)

            for locName, locData in aiBrain.BuilderManagers do
                if not locData.DistressCall then
                    local position = locData.EngineerManager.Location
                    local radius = locData.EngineerManager.Radius
                    local distressRange = locData.BaseSettings.DistressRange or aiBrain.BaseMonitor.PoolDistressRange
                    local distressLocation = aiBrain:BaseMonitorDistressLocationSwarm(position, distressRange, aiBrain.BaseMonitor.PoolDistressThreshold)

                    -- Distress !
                    if distressLocation then
                        --LOG('*AI DEBUG: ARMY '.. aiBrain:GetArmyIndex() ..': --- POOL DISTRESS RESPONSE ---')

                        -- Grab the units at the location
                        local group = self:GetPlatoonUnitsAroundPoint(categories.MOBILE - categories.ENGINEER - categories.TRANSPORTFOCUS - categories.SONAR - categories.EXPERIMENTAL, position, radius)

                        -- Move the group to the distress location and then back to the location of the base
                        IssueClearCommands(group)
                        IssueAggressiveMove(group, distressLocation)
                        IssueMove(group, position)

                        -- Set distress active for duration
                        locData.DistressCall = true
                        self:ForkThread(self.UnlockBaseManagerDistressLocation, locData)
                    end
                end
            end
            WaitSeconds(aiBrain.BaseMonitor.PoolReactionTime)
        end
    end,

    RenamePlatoonSwarm = function(self, text)
        for k, v in self:GetPlatoonUnits() do
            if v and not v.Dead then
                v:SetCustomName(text..' '..math.floor(GetGameTimeSeconds()))
            end
        end
    end,

    --- --- --- --- --- --- --- --- --- --- ---
    --- OLD FUNCTIONS (SOME STILL IN USAGE) ---
    --- --- --- --- --- --- --- --- --- --- ---

    -- Exclusively Used for Experimentals
    AirAISwarm = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) 

        local aiBrain = self:GetBrain()

        local platoonUnits = self:GetPlatoonUnits()

        local PlatoonStrength = SWARMGETN(platoonUnits)

        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then

                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end

                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end

        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                SWARMINSERT(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * AirAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                SWARMINSERT(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local path
        local reason
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local basePosition
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonPos
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local GetTargetsFrom = basePosition
        local LastTargetCheck
        local DistanceToBase = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local maxradius = self.PlatoonData.SearchRadius or 100
        --local maxradius = SWARMMAX(maxRadiusMax, (maxRadiusMax * aiBrain.MyAirRatio) )
        --LOG("The Max Radius is " .. repr(maxradius))
        while aiBrain:PlatoonExists(self) do
            PlatoonPos = self:GetPlatoonPosition()
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonPos
            else
                DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                if DistanceToBase > maxradius then
                    target = nil
                end
            end
            -- only get a new target and make a move command if the target is dead
            if not target or target.Dead or target:BeenDestroyed() then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, self, 'Attack', GetTargetsFrom, maxradius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    --LOG('* AI-Swarm: *AirAISwarm: found UnitWithPath')
                    self:Stop()
                    target = UnitWithPath
                    if self.PlatoonData.IgnorePathing then
                        self:AttackTarget(UnitWithPath)
                    elseif path then
                        self:MovePathSwarm(aiBrain, path, bAggroMove, UnitWithPath)
                    -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                    else
                        self:MoveDirectSwarm(aiBrain, bAggroMove, UnitWithPath)
                    end
                    -- We moved to the target, attack it now if its still exists
                    if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead and not UnitWithPath:BeenDestroyed() then
                        self:AttackTarget(UnitWithPath)
                    end
                elseif UnitNoPath then
                    --LOG('* AI-Swarm: *AirAISwarm: found UnitNoPath')
                    self:Stop()
                    target = UnitNoPath
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        self:AttackTarget(UnitNoPath)
                    else
                        self:SimpleReturnToBaseSwarm(basePosition)
                    end
                else
                    --LOG('* AI-Swarm: *AirAISwarm: no target found '..repr(reason))
                    -- we have no target return to main base
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        if VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 30 then
                            self:MoveToLocation(basePosition, false)
                        else
                            -- we are at home and we don't have a target. Disband!
                            if aiBrain:PlatoonExists(self) then
                                self:PlatoonDisband()
                                return
                            end
                        end
                    else
                        if not self.SuicideMode then
                            self.SuicideMode = true
                            self.PlatoonData.AttackEnemyStrength = 1000
                            self.PlatoonData.GetTargetsFromBase = false
                            self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self:AirAISwarm()
                        else
                            self:SimpleReturnToBaseSwarm(basePosition)
                        end
                    end
                end
            -- targed exists and is not dead
            end
            SWARMWAIT(10)
            if aiBrain:PlatoonExists(self) and target and not target.Dead then
                LastTargetPos = target:GetPosition()
                -- check if we are still inside the attack radius and be sure the area is not a nuke blast area
                if VDist2(basePosition[1] or 0, basePosition[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < maxradius then
                    self:Stop()
                    if self.PlatoonData.IgnorePathing or VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < 80 then
                        self:AttackTarget(target)
                    elseif VDist2Sq(LastTargetPos[1],LastTargetPos[3], basePosition[1],basePosition [3]) > 6400 then 
                        self:MoveToLocation(LastTargetPos, false)
                    end
                    SWARMWAIT(50)
                else
                    target = nil
                end

            end
            SWARMWAIT(30)
        end
    end,

    -- Exclusively Used for Experimentals
    LandAttackAISwarm = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = SWARMGETN(platoonUnits)
        local ExperimentalInPlatoon = false
        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if IsDestroyed(v) then
                        WARN('Unit is not Dead but DESTROYED')
                    end
                    if v:BeenDestroyed() then
                        WARN('Unit is not Dead but DESTROYED')
                    end
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    if SWARMENTITY(categories.EXPERIMENTAL, v) then
                        ExperimentalInPlatoon = true
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                SWARMINSERT(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * LandAttackAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        -- Set the target list to all platoon units
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                SWARMINSERT(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local aiBrain = self:GetBrain()
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local WantsTransport = self.PlatoonData.RequireTransport
        local maxRadius = self.PlatoonData.SearchRadius
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local DistanceToTarget = 0
        local basePosition = aiBrain.BuilderManagers['MAIN'].Position
        local losttargetnum = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        --local maxRadius = SWARMMAX(maxRadius, (maxRadius * aiBrain.MyLandRatio) )
        while aiBrain:PlatoonExists(self) do

            PlatoonPos = self:GetPlatoonPosition()
            -- only get a new target and make a move command if the target is dead or after 10 seconds
            if not target or target.Dead then

                --self:MergeWithNearbyPlatoonsSwarm('LandAttackAISwarm', 40, 20)

                --SWARMWAIT(5)

                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, self, 'Attack', PlatoonPos, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    losttargetnum = 0
                    self:Stop()
                    target = UnitWithPath
                    LastTargetPos = SWARMCOPY(target:GetPosition())
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    if DistanceToTarget > 30 then
                        -- if we have a path then use the waypoints
                        if self.PlatoonData.IgnorePathing then
                            self:Stop()
                            self:SetPlatoonFormationOverride('AttackFormation')
                            self:AttackTarget(UnitWithPath)
                        elseif path then
                            self:MoveToLocationInclTransportSwarm(target, LastTargetPos, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon)
                        -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                        else
                            self:MoveDirectSwarm(aiBrain, bAggroMove, target)
                        end
                        -- We moved to the target, attack it now if its still exists
                        if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead and not UnitWithPath:BeenDestroyed() then
                            self:Stop()
                            self:SetPlatoonFormationOverride('AttackFormation')
                            self:AttackTarget(UnitWithPath)
                        end
                    end
                elseif UnitNoPath then
                    losttargetnum = 0
                    self:Stop()
                    target = UnitNoPath
                    self:MoveWithTransportSwarm(aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
                    -- We moved to the target, attack it now if its still exists
                    if aiBrain:PlatoonExists(self) and UnitNoPath and not UnitNoPath.Dead and not UnitNoPath:BeenDestroyed() then
                        self:SetPlatoonFormationOverride('AttackFormation')
                        self:AttackTarget(UnitNoPath)
                    end
                else
                    -- we have no target return to main base
                    losttargetnum = losttargetnum + 1
                    if losttargetnum > 2 then
                        if not self.SuicideMode then
                            self.SuicideMode = true
                            self.PlatoonData.AttackEnemyStrength = 1000
                            self.PlatoonData.GetTargetsFromBase = false
                            self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:LandAttackAISwarm()
                        else
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:ForceReturnToNearestBaseAISwarm()
                        end
                    end
                end
            else
                if aiBrain:PlatoonExists(self) and target and not target.Dead and not target:BeenDestroyed() then
                    LastTargetPos = target:GetPosition()
                    self:SetPlatoonFormationOverride('AttackFormation')
                    self:AttackTarget(target)
                    SWARMWAIT(20)
                end
            end
            SWARMWAIT(10)
        end
    end,

    NavalAttackAISwarm = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = SWARMGETN(platoonUnits)
        local ExperimentalInPlatoon = false
        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_JammingToggle') then
                        v:SetScriptBit('RULEUTC_JammingToggle', false)
                    end
                    if SWARMENTITY(categories.EXPERIMENTAL, v) then
                        ExperimentalInPlatoon = true
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                SWARMINSERT(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * NavalAttackAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        -- Set the target list to all platoon units
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                SWARMINSERT(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local aiBrain = self:GetBrain()
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local maxRadius = self.PlatoonData.SearchRadius or 250
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local DistanceToTarget = 0
        local basePosition = PlatoonPos   -- Platoons will be created near a base, so we can return to this position if we don't have targets.
        local losttargetnum = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        --local maxRadius = SWARMMAX(maxRadius, (maxRadius * aiBrain.MyNavalRatio) )
        while aiBrain:PlatoonExists(self) do
            PlatoonPos = self:GetPlatoonPosition()
            -- only get a new target and make a move command if the target is dead or after 10 seconds
            if not target or target.Dead then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, self, 'Attack', PlatoonPos, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    losttargetnum = 0
                    self:Stop()
                    target = UnitWithPath
                    LastTargetPos = SWARMCOPY(target:GetPosition())
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    if DistanceToTarget > 30 then
                        -- if we have a path then use the waypoints
                        if self.PlatoonData.IgnorePathing then
                            self:Stop()
                            self:AttackTarget(UnitWithPath)
                        elseif path then
                            self:MovePathSwarm(aiBrain, path, bAggroMove, target)
                        -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                        else
                            self:MoveDirectSwarm(aiBrain, bAggroMove, target)
                        end
                        -- We moved to the target, attack it now if its still exists
                        if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead and not UnitWithPath:BeenDestroyed() then
                            self:Stop()
                            self:AttackTarget(UnitWithPath)
                        end
                    end
                else
                    -- we have no target return to main base
                    losttargetnum = losttargetnum + 1
                    if losttargetnum > 2 then
                        if not self.SuicideMode then
                            self.SuicideMode = true
                            self.PlatoonData.AttackEnemyStrength = 1000
                            self.PlatoonData.GetTargetsFromBase = false
                            self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:NavalAttackAISwarm()
                        else
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:ForceReturnToNavalBaseAISwarm(aiBrain, basePosition)
                        end
                    end
                end
            else
                if aiBrain:PlatoonExists(self) and target and not target.Dead and not target:BeenDestroyed() then
                    LastTargetPos = target:GetPosition()
                    self:SetPlatoonFormationOverride('AttackFormation')
                    self:AttackTarget(target)
                    SWARMWAIT(20)
                end
            end
            SWARMWAIT(10)
        end
    end,
    
    --- --- --- --- --- --- --- --- --- --- ---
    --- OLD FUNCTIONS (SOME STILL IN USAGE) ---
    --- --- --- --- --- --- --- --- --- --- ---
}