WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset platoon.lua' )

local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')
local HERODEBUGSwarm = false
local CHAMPIONDEBUGswarm = false 
local UseHeroPlatoonswarm = true

local PlatoonExists = moho.aibrain_methods.PlatoonExists
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
local SWARMINSERT = table.insert
local SWARMCAT = table.cat
local SWARMWAIT = coroutine.yield
local SWARMFLOOR = math.floor
local SWARMMIN = math.min
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

    PlatoonDisband = function(self)
        local aiBrain = self:GetBrain()
        if not aiBrain.Swarm then
            return SwarmPlatoonClass.PlatoonDisband(self)
        end
        if self.PlatoonData.Construction.RepeatBuild then
            
            local UCBC = import('/lua/editor/UnitCountBuildConditions.lua')

            if UCBC.HaveUnitRatioVersusCapSwarm(aiBrain, 0.10, '<', categories.STRUCTURE * categories.MASSEXTRACTION) then

                if aiBrain:GetEconomyStoredRatio('ENERGY') > 0.50 then
                    local MABC = import('/lua/editor/MarkerBuildConditions.lua')
                    if MABC.CanBuildOnMassSwarm(aiBrain, 'MAIN', 1000, -500, 2, 1, 'AntiSurface', 1) then 
                        self:SetAIPlan('EngineerBuildAI')
                        return
                    end
                end

            end
    
            self:AggressiveMoveToLocation(aiBrain.BuilderManagers['MAIN'].Position)

            SWARMWAIT(10)

            local count = 1
            local eng = self:GetPlatoonUnits()[1]

            while eng and not eng.Dead and not (eng:IsIdleState()) and aiBrain:PlatoonExists(self) and count < 120 do
                SWARMWAIT(10)
                count = count + 1
                if aiBrain:GetEconomyStoredRatio('ENERGY') > 0.50 then
                    local MABC = import('/lua/editor/MarkerBuildConditions.lua')
                    if MABC.CanBuildOnMassSwarm(aiBrain, 'MAIN', 1000, -500, 2, 1, 'AntiSurface', 1) then 
                        --LOG("Ooga Booga RepeatBuild is " .. repr(self.BuilderName) .. " " .. repr(self.PlatoonData.Construction.RepeatBuild))
                        self:SetAIPlan('EngineerBuildAI')
                        return
                    end
                end
            end

            self.PlatoonData.Construction.RepeatBuild = nil

        end
        --LOG("Ooga Booga RepeatBuild is " .. repr(self.BuilderName) .. " " .. repr(self.PlatoonData.Construction.RepeatBuild))
        SwarmPlatoonClass.PlatoonDisband(self)
        
    end, 

    BaseManagersDistressAI  = function(self)
        -- Only use this with AI-Swarm
        local aiBrain = self:GetBrain()
        if not aiBrain.Swarm then
            return SwarmPlatoonClass.BaseManagersDistressAI(self)
        end
        SWARMWAIT(10)
        -- We are leaving this forked thread here because we don't need it.
        -- This shit is annoying!
        -- Want to get this properly working with Swarm One Day.
        KillThread(CurrentThread())
     end,

    InterceptorAISwarm = function(self)
        --if UseHeroPlatoonswarm then
        --    self:HeroFightPlatoonSwarm()
        --    return
        --end
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
            LOG('* AI-Swarm: * InterceptorAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
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
        local maxRadius = self.PlatoonData.SearchRadius or 100
        --local maxRadius = SWARMMAX(maxRadius, (maxRadius * aiBrain.MyAirRatio) ) -- Whoops, this doesn't work :)
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
        local maxRadius = SWARMMAX(maxRadius, (maxRadius * aiBrain.MyAirRatio) )
        while aiBrain:PlatoonExists(self) do
            PlatoonPos = self:GetPlatoonPosition()
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonPos
            else
                DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                if DistanceToBase > maxRadius then
                    target = nil
                end
            end
            -- only get a new target and make a move command if the target is dead
            if not target or target.Dead or target:BeenDestroyed() then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    --LOG('* AI-Swarm: *InterceptorAISwarm: found UnitWithPath')
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
                    --LOG('* AI-Swarm: *InterceptorAISwarm: found UnitNoPath')
                    self:Stop()
                    target = UnitNoPath
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        self:AttackTarget(UnitNoPath)
                    else
                        self:SimpleReturnToBaseSwarm(basePosition)
                    end
                else
                    --LOG('* AI-Swarm: *InterceptorAISwarm: no target found '..repr(reason))
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
                            self:InterceptorAISwarm()
                        else
                            self:SimpleReturnToBaseSwarm(basePosition)
                        end
                    end
                end
            -- targed exists and is not dead
            end
            SWARMWAIT(1)
            if aiBrain:PlatoonExists(self) and target and not target.Dead then
                LastTargetPos = target:GetPosition()
                -- check if we are still inside the attack radius and be sure the area is not a nuke blast area
                if VDist2(basePosition[1] or 0, basePosition[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < maxRadius then
                    self:Stop()
                    if self.PlatoonData.IgnorePathing or VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < 60 then
                        self:AttackTarget(target)
                    else
                        self:MoveToLocation(LastTargetPos, false)
                    end
                    SWARMWAIT(10)
                else
                    target = nil
                end
            end
            SWARMWAIT(10)
        end
    end,

    BomberGunshipAISwarm = function(self)
        --if 1==1 then
        --    self:HeroFightPlatoonSwarm()
        --    return
        --end 
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
            LOG('* AI-Swarm: * InterceptorAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
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
        local maxRadius = self.PlatoonData.SearchRadius or 100
        --local maxRadius = SWARMMAX(maxRadius, (maxRadius * aiBrain.MyAirRatio) ) -- Whoops, this doesn't work :)
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
        local maxRadius = SWARMMAX(maxRadius, (maxRadius * aiBrain.MyAirRatio) )
        while aiBrain:PlatoonExists(self) do
            PlatoonPos = self:GetPlatoonPosition()
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonPos
            else
                DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                if DistanceToBase > maxRadius then
                    target = nil
                end
            end
            -- only get a new target and make a move command if the target is dead
            if not target or target.Dead or target:BeenDestroyed() then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    --LOG('* AI-Swarm: *InterceptorAISwarm: found UnitWithPath')
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
                    --LOG('* AI-Swarm: *InterceptorAISwarm: found UnitNoPath')
                    self:Stop()
                    target = UnitNoPath
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        self:AttackTarget(UnitNoPath)
                    else
                        self:SimpleReturnToBaseSwarm(basePosition)
                    end
                else
                    --LOG('* AI-Swarm: *InterceptorAISwarm: no target found '..repr(reason))
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
                            self:InterceptorAISwarm()
                        else
                            self:SimpleReturnToBaseSwarm(basePosition)
                        end
                    end
                end
            -- targed exists and is not dead
            end
            SWARMWAIT(1)
            if aiBrain:PlatoonExists(self) and target and not target.Dead then
                LastTargetPos = target:GetPosition()
                -- check if we are still inside the attack radius and be sure the area is not a nuke blast area
                if VDist2(basePosition[1] or 0, basePosition[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < maxRadius then
                    self:Stop()
                    if self.PlatoonData.IgnorePathing or VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < 60 then
                        self:AttackTarget(target)
                    else
                        self:MoveToLocation(LastTargetPos, false)
                    end
                    SWARMWAIT(10)
                else
                    target = nil
                end
            end
            SWARMWAIT(10)
        end
    end,

    --Currently in Development.

    HuntAISwarm = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local target
        local blip
        while aiBrain:PlatoonExists(self) do

            target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.SCOUT - categories.WALL)

            if target then
                blip = target:GetBlip(armyIndex)
                self:Stop()
                self:AggressiveMoveToLocation(SWARMCOPY(target:GetPosition()))
                --DUNCAN - added to try and stop AI getting stuck.
                --local position = AIUtils.RandomLocation(target:GetPosition()[1],target:GetPosition()[3])
                --self:MoveToLocation(position, false)
                SWARMWAIT(150)
            else
                -- merge with nearby platoons
                local DidIMerge = self:MergeWithNearbyPlatoonsSwarm('HuntAISwarm', 100, 50)
            end
            SWARMWAIT(30)
        end
    end,

    LandAttackAISwarm = function(self)
        --if UseHeroPlatoonswarm then
        --    self:HeroFightPlatoonSwarm()
        --    return
        --end
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
        while aiBrain:PlatoonExists(self) do

            PlatoonPos = self:GetPlatoonPosition()
            -- only get a new target and make a move command if the target is dead or after 10 seconds
            if not target or target.Dead then

                self:MergeWithNearbyPlatoonsSwarm('LandAttackAISwarm', 100, 40)

                SWARMWAIT(10)

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
                    WaitSeconds(2)
                end
            end
            WaitSeconds(1)
        end
    end,

    NavalAttackAISwarm = function(self)
        --if UseHeroPlatoonswarm then
        --    self:HeroFightPlatoonSwarm()
        --    return
        --end
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
                    WaitSeconds(2)
                end
            end
            WaitSeconds(1)
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

            -- We gain 1 Braveness (max +3) for every 12 friendly T1 units nearby --------------------------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH1, cdr.position, 25, 'Ally' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH2, cdr.position, 25, 'Ally' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH3, cdr.position, 25, 'Ally' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.EXPERIMENTAL, cdr.position, 25, 'Ally' )
            -- Tech1 ~25 dps -- Tech2 ~90 dps = 3 x T1 -- Tech3 ~333 dps = 13 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 3 + UnitT3 * 13 + UnitT4 * 80
            if Threat > 0 then
                Braveness = Braveness + SWARMMIN( 3, SWARMFLOOR(Threat / 12) )
                BraveDEBUG['Ally'] = SWARMMIN( 3, SWARMFLOOR(Threat / 12) )
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


            -- We lose 1 Braveness for every 3 t1 enemy units in close range ------------------------------------------------------------------------------------------------------
            UnitT1 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH1, cdr.position, 40, 'Enemy' )
            UnitT2 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH2, cdr.position, 40, 'Enemy' )
            UnitT3 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.TECH3, cdr.position, 40, 'Enemy' )
            UnitT4 = aiBrain:GetNumUnitsAroundPoint( (categories.DIRECTFIRE + categories.INDIRECTFIRE) * categories.EXPERIMENTAL, cdr.position, 40, 'Enemy' )
            -- Tech1 ~25 dps -- Tech2 ~90 dps = 3 x T1 -- Tech3 ~333 dps = 13 x T1 -- Tech4 ~2000 dps = 80 x T1
            Threat = UnitT1 + UnitT2 * 3 + UnitT3 * 13 + UnitT4 * 80
            if Threat > 0 then
                Braveness = Braveness - SWARMFLOOR(Threat / 3)
                BraveDEBUG['Enemy'] = - SWARMFLOOR(Threat / 3)
            end

            -- We lose 5 Braveness for every additional enemy ACU nearby (+0 for 1 ACU, +5 for 2 ACUs, +10 for 3 ACUs
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

            -- We lose 10 bravness in case the enemy has more than 8 Tech2/3 bomber or gunships
            if aiBrain.ACUChampionSwarm.numAirEnemyUnits > 8 then
                Braveness = Braveness - 10
                BraveDEBUG['Bomber'] = 10
            end

            -- We lose all Braveness if we have under 20% health -------------------------------------------------------------------------------------------------------------------------
            CDRHealth = SwarmUtils.ComHealth(cdr)
            if CDRHealth < 20 then
                Braveness = -20
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
            if VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) < 60 then
                -- only upgrade if we are good at health
                local check = true
                if self.created + 10 > SWARMTIME() then
                    check = false
                else
                end
                if CDRHealth < 20 then
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
                -- Only upgrade with full Energy storage
                if aiBrain:GetEconomyStoredRatio('ENERGY') < 1.00 then
                    check = false
                end
                -- First enhancement needs at least +300 energy
                if aiBrain:GetEconomyTrend('ENERGY')*10 < 300 then
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
            if aiBrain.ACUChampionSwarm.EnemyExperimentalPos and VDist2( cdr.position[1], cdr.position[3], aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][1], aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][3] ) < aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange + 30 then
                alpha = math.atan2 (aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][3] - cdr.position[3] ,aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][1] - cdr.position[1])
                x = aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][1] - SWARMCOS(alpha) * (aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange + 30)
                y = aiBrain.ACUChampionSwarm.EnemyExperimentalPos[1][3] - SWARMSIN(alpha) * (aiBrain.ACUChampionSwarm.EnemyExperimentalWepRange + 30)
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
                    alpha = math.atan2 (MoveToTargetPos[3] - cdr.position[3] ,MoveToTargetPos[1] - cdr.position[1])
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
                    alpha = math.atan2 (MoveToTargetPos[3] - cdr.position[3] ,MoveToTargetPos[1] - cdr.position[1])
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
                        smartPos = SwarmUtils.RandomizePosition(cdr.CDRHome)
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
                        smartPos = SwarmUtils.RandomizePosition(cdr.CDRHome)
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
                    -- only shoot when we have low mass (then we don't need energy) or at full energy (max damage) or when in danger
                    if aiBrain:GetEconomyStoredRatio('MASS') < 0.05 or aiBrain:GetEconomyStored('ENERGY') > 6000 or CDRHealth < 60 then
                        if OverchargeTarget and not OverchargeTarget.Dead and not OverchargeTarget:BeenDestroyed() then
                            IssueOverCharge({cdr}, OverchargeTarget)
                        end
                    end
                end
            end

            -- in case we are in range of an enemy TMl, always move to different positions
            if aiBrain.ACUChampionSwarm.EnemyTMLPos or UnderAttackSwarm then
                smartPos = SwarmUtils.RandomizePositionTML(smartPos)
            end
            -- in case we are not moving for 4 seconds, force moving (maybe blocked line of sight)
            if not cdr:IsUnitState("Moving") then
                if cdr.LastMoved + 4 < SWARMTIME() then
                    smartPos = SwarmUtils.RandomizePositionTML(smartPos)
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
                    alpha = math.atan2 (NavigatorGoal[3] - FocusTargetPos[3] ,NavigatorGoal[1] - FocusTargetPos[1])
                    x = cdr.smartPos[1] + SWARMCOS(alpha) * DistToACU
                    y = cdr.smartPos[3] + SWARMSIN(alpha) * DistToACU
                    smartPos = { x, GetTerrainHeight( x, y), y }
                else
                    -- Move so the ACU is between units and Base
                    --alpha = math.atan2 (cdr.position[3] - cdr.CDRHome[3] ,cdr.position[1] - cdr.CDRHome[1])
                    -- Move so our support units are between ACU and base
                    alpha = math.atan2 (cdr.CDRHome[3] - cdr.position[3] ,cdr.CDRHome[1] - cdr.position[1])
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
            ['ual0001'] = {'CrysalisBeam', 'HeatSink', 'Shield', 'ShieldHeavy'},
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
                SPEW('* AI-Swarm: ACUAttackAIUveso: no enhancement found for  = '..repr(enhancement))
            elseif cdr:HasEnhancement(enhancement) then
                NextEnhancement = false
                --LOG('* AI-Swarm: * ACUAttackAIUveso: BuildACUEnhancements: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgradeSwarm(cdr, wantedEnhancementBP) then
                --LOG('* AI-Swarm: * ACUAttackAIUveso: BuildACUEnhancements: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --LOG('* AI-Swarm: * ACUAttackAIUveso: *** Set as Enhancememnt: '..NextEnhancement)
                end
            elseif force then
                --LOG('* AI-Swarm: * ACUAttackAIUveso: BuildACUEnhancements: Eco is bad for '..enhancement..' - Ignoring eco requirement!')
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                end
            else
                --LOG('* AI-Swarm: * ACUAttackAIUveso: BuildACUEnhancements: Eco is bad for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = false
                    -- if we don't have the eco for this ugrade, stop the search
                    --LOG('* AI-Swarm: * ACUAttackAIUveso: canceled search. no eco available')
                    break
                end
            end
        end
        if NextEnhancement and HaveEcoForEnhancement then
            --LOG('* AI-Swarm: * ACUAttackAIUveso: BuildACUEnhancements Building '..NextEnhancement)
            if platoon:BuildEnhancementSwarm(cdr, NextEnhancement) then
                --LOG('* AI-Swarm: * ACUAttackAIUveso: BuildACUEnhancements returned true'..NextEnhancement)
                return NextEnhancement
            else
                --LOG('* AI-Swarm: * ACUAttackAIUveso: BuildACUEnhancements returned false'..NextEnhancement)
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


    MoveWithTransportSwarm = function(self, aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
        local TargetPosition = SWARMCOPY(target:GetPosition())
        local usedTransports = false
        self:SetPlatoonFormationOverride('NoFormation')
        --LOG('* AI-Swarm: * MoveWithTransportSwarm: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
        if not ExperimentalInPlatoon and aiBrain:PlatoonExists(self) then
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        if not usedTransports then
            --LOG('* AI-Swarm: * MoveWithTransportSwarm: SendPlatoonWithTransportsNoCheck failed.')
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

    MoveDirectSwarm = function(self, aiBrain, bAggroMove, target)
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local TargetPosition = SWARMCOPY(target:GetPosition())
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        local ATTACKFORMATION = false
        if bAggroMove then
            self:AggressiveMoveToLocation(TargetPosition)
        else
            self:MoveToLocation(TargetPosition, false)
        end
        while aiBrain:PlatoonExists(self) do
            PlatoonPosition = self:GetPlatoonPosition() or TargetPosition
            dist = VDist2( TargetPosition[1], TargetPosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            local platoonUnitscheck = self:GetPlatoonUnits()
            if SWARMGETN(platoonUnits) > SWARMGETN(platoonUnitscheck) then
                --LOG('* AI-Swarm: * MoveDirectSwarm: unit in platoon destroyed!!!')
                self:SetPlatoonFormationOverride('AttackFormation')
            end
            --LOG('* AI-Swarm: * MoveDirectSwarm: dist to next Waypoint: '..dist)
            --LOG('* AI-Swarm: * MoveDirectSwarm: dist to target: '..dist)
            if not ATTACKFORMATION and dist < 80 then
                ATTACKFORMATION = true
                --LOG('* AI-Swarm: * MoveDirectSwarm: dist < 50 '..dist)
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
            SWARMWAIT(10)
        end
    end,

    MovePathSwarm = function(self, aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, EnemyThreatCategory)
        local distEnd
        local MaxPlatoonWeaponRange = MaxPlatoonWeaponRange or 30
        local EnemyThreatCategory = EnemyThreatCategory or categories.ALLUNITS
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local PathNodesCount = SWARMGETN(path)
        if self.MovementLayer == 'Air' then
            -- Air units should not follow the path for the last 3 hops.
            if PathNodesCount - 3 > 0 then
                PathNodesCount = PathNodesCount - 3
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
            --LOG('* AI-Swarm: * MovePath: moving to destination. i: '..i..' coords '..repr(path[i]))
            if bAggroMove then
                self:AggressiveMoveToLocation(path[i])
            else
                self:MoveToLocation(path[i], false)
            end
            while aiBrain:PlatoonExists(self) do
                PlatoonPosition = self:GetPlatoonPosition() or path[i]
                dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                if not bAggroMove then
                    local platoonUnitscheck = self:GetPlatoonUnits()
                    if SWARMGETN(platoonUnits) > SWARMGETN(platoonUnitscheck) then
                        --LOG('* AI-Swarm: * MovePath: unit in platoon destroyed!!!')
                        self:SetPlatoonFormationOverride('AttackFormation')
                    end
                end
                --LOG('* AI-Swarm: * MovePath: dist to next Waypoint: '..dist)
                distEnd = VDist2( path[PathNodesCount][1], path[PathNodesCount][3], PlatoonPosition[1], PlatoonPosition[3] )
                --LOG('* AI-Swarm: * MovePath: dist to Path End: '..distEnd)
                if not ATTACKFORMATION and distEnd < 80 then
                    ATTACKFORMATION = true
                    --LOG('* AI-Swarm: * MovePath: distEnd < 50 '..distEnd)
                    self:SetPlatoonFormationOverride('AttackFormation')
                end
                -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                if dist < 20 then
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
                        --LOG('* AI-Swarm: * MovePath: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                        self:Stop()
                        break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                    end
                end
                -- If we lose our target, stop moving to it.
                if not target or target.Dead then
                    --LOG('* AI-Swarm: * MovePath: Lost target while moving to Waypoint. '..repr(path[i]))
                    return
                end
                -- see if we are in danger, fight units that are close to the platoon
                if bAggroMove then
                    numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(EnemyThreatCategory, PlatoonPosition, MaxPlatoonWeaponRange + 30 , 'Enemy')
                    if numEnemyUnits > 0 then
                        return
                    end
                end
                SWARMWAIT(10)
            end
        end
    end,

    MoveToLocationInclTransportSwarm = function(self, target, TargetPosition, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, EnemyThreatCategory)
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
            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: no trasnporter used for target distance '..VDist2( PlatoonPosition[1], PlatoonPosition[3], TargetPosition[1], TargetPosition[3] ) )
        -- use a transporter if we don't have a path, or if we want a transport
        elseif not ExperimentalInPlatoon and ((not path and reason ~= 'NoGraph') or WantsTransport)  then
            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: SendPlatoonWithTransportsNoCheck')
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        -- if we don't got a transport, try to reach the destination by path or directly
        if not usedTransports then
            -- clear commands, so we don't get stuck if we have an unreachable destination
            IssueClearCommands(self:GetPlatoonUnits())
            if path then
                --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: No transport used, and we dont need it.')
                if SWARMGETN(path) > 1 then
                    --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: SWARMGETN(path): '..SWARMGETN(path))
                end
                local PathNodesCount = SWARMGETN(path)
                local ATTACKFORMATION = false
                for i=1, PathNodesCount do
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
                        local platoonUnitscheck = self:GetPlatoonUnits()
                        if SWARMGETN(platoonUnits) > SWARMGETN(platoonUnitscheck) then
                            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: unit in platoon destroyed!!!')
                            self:SetPlatoonFormationOverride('AttackFormation')
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
                            return
                        end
                        SWARMWAIT(10)
                    end
                end
            else
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
                        --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
                        if not ExperimentalInPlatoon then
                            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
                        end
                        if not usedTransports then
                            --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: CanPathTo() and SendPlatoonWithTransportsNoCheck failed. SimpleReturnToBaseSwarm!')
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
            SwarmUtils.ReclaimAIThreadSwarm(self,eng,aiBrain)
            eng.UnitBeingBuilt = nil
        end
        self:PlatoonDisband()
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
            WaitSeconds(2)
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
                LOG("*AI DEBUG: Merging platoons " .. self.BuilderName .. ": (" .. platPos[1] .. ", " .. platPos[3] .. ") and " .. aPlat.BuilderName .. ": (" .. allyPlatPos[1] .. ", " .. allyPlatPos[3] .. ")")
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

    ExtractorUpgradeAISwarm = function(self)
        --LOG('* AI-Swarm: +++ ExtractorUpgradeAISwarm: START')
        local aiBrain = self:GetBrain()
        --local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        while aiBrain:PlatoonExists(self) do
            local ratio = 0.10
            if aiBrain.HasParagon then
                -- if we have a paragon, upgrade mex as fast as possible. Mabye we lose the paragon and need mex again.
                ratio = 1.0
            elseif aiBrain:GetEconomyIncome('MASS') > 1000 then
                --LOG('* AI-Swarm: Mass over 1000. Eco running with 75%')
                ratio = 0.75
            elseif (SWARMTIME() > 600 and aiBrain.SelfAllyExtractor > aiBrain.MassMarker / 1.5) then -- 12 * 60
                ratio = 0.50
            elseif SWARMTIME() > 1500 then -- 32 * 60
                ratio = 0.50
            elseif SWARMTIME() > 1200 then -- 22 * 60
                ratio = 0.40
            elseif SWARMTIME() > 900 then -- 17 * 60
                ratio = 0.30
            elseif SWARMTIME() > 600 then -- 12 * 60
                ratio = 0.20
            elseif SWARMTIME() > 240 then -- 4 * 60
                ratio = 0.10
            elseif SWARMTIME() <= 240 then -- 4 * 60 run the first 4 minutes with 0% Eco and 100% Army
                ratio = 0.00
            end
            local platoonUnits = self:GetPlatoonUnits()
            local MassExtractorUnitList = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3), false, false)
            -- Check if we can pause/unpause TECH3 Extractors (for more energy)
            if not SwarmUtils.ExtractorPauseSwarm( self, aiBrain, MassExtractorUnitList, ratio, 'TECH3') then
                -- Check if we can pause/unpause TECH2 Extractors
                if not SwarmUtils.ExtractorPauseSwarm( self, aiBrain, MassExtractorUnitList, ratio, 'TECH2') then
                    -- Check if we can pause/unpause TECH1 Extractors
                    if not SwarmUtils.ExtractorPauseSwarm( self, aiBrain, MassExtractorUnitList, ratio, 'TECH1') then
                        -- We have nothing to pause or unpause, lets upgrade more extractors
                        -- if we have 10% TECH1 extractors left (and 90% TECH2), then upgrade TECH2 to TECH3
                        if SwarmUtils.HaveUnitRatio( aiBrain, 0.90, categories.MASSEXTRACTION * categories.TECH1, '<=', categories.MASSEXTRACTION * categories.TECH2 ) then
                            -- Try to upgrade a TECH2 extractor.
                            if not SwarmUtils.ExtractorUpgradeSwarm(self, aiBrain, MassExtractorUnitList, ratio, 'TECH2', UnitUpgradeTemplates, StructureUpgradeTemplates) then
                                -- We can't upgrade a TECH2 extractor. Try to upgrade from TECH1 to TECH2
                                SwarmUtils.ExtractorUpgradeSwarm(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                            end
                        else
                            -- We have less than 90% TECH2 extractors compared to TECH1. Upgrade more TECH1
                            SwarmUtils.ExtractorUpgradeSwarm(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                        end
                    end
                end
            end
            -- Check the Eco every x Ticks
            SWARMWAIT(10)
            -- find dead units inside the platoon and disband if we find one
            for k,v in self:GetPlatoonUnits() do
                if v.Dead then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    --LOG('* AI-Swarm: +++ ExtractorUpgradeAISwarm: Found Dead unit, self:PlatoonDisbandNoAssign()')
                    -- needs PlatoonDisbandNoAssign, or extractors will stop upgrading if the platton is disbanded
                    SWARMWAIT(1)
                    self:PlatoonDisbandNoAssign()
                    return
                end
            end
        end
        -- No return here. We will never reach this position. After disbanding this platoon, the forked 'ExtractorUpgradeAISwarm' thread will be terminated from outside.
    end,

    SimpleReturnToBaseSwarm = function(self, basePosition)
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
                --LOG('* AI-Swarm: * SimpleReturnToBaseSwarm: no Platoon Position')
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
        if aiBrain:PlatoonExists(self) then -- Platoons were getting really stuck with this.
            self:PlatoonDisband()
        end
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
        SWARMWAIT(30)
        if aiBrain:PlatoonExists(self) then -- Platoons were getting really stuck with this.
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
                WaitSeconds(5)
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
            WaitSeconds(5)
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
                    WaitSeconds(5)
                end
            end
            -- Reaching this point means we have no special target and our arty is using it's own weapon target priorities.
            -- So we are still attacking targets at this point.
            WaitSeconds(5)
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
                            table.remove(LauncherReady, k)
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
                table.remove(Launchers, k)
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
                    IssueTeleport({unit}, SwarmUtils.RandomizePosition(TargetPosition))
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
        self:LandAttackAISwarm()
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


    TacticalAISwarm = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local platoonUnits = self:GetPlatoonUnits()
        local unit

        if not aiBrain:PlatoonExists(self) then return end

        --GET THE Launcher OUT OF THIS PLATOON
        for k, v in platoonUnits do
            if SWARMENTITY(categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM, v) then
                unit = v
                break
            end
        end

        if not unit then return end

        local bp = unit:GetBlueprint()
        local weapon = bp.Weapon[1]
        local maxRadius = weapon.MaxRadius
        local minRadius = weapon.MinRadius
        unit:SetAutoMode(true)

        --DUNCAN - commented out
        --local atkPri = { 'COMMAND', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE', 'CONSTRUCTION', 'EXPERIMENTAL MOBILE LAND', 'TECH3 MOBILE LAND',
        --    'TECH2 MOBILE LAND', 'TECH1 MOBILE LAND', 'ALLUNITS' }

        --DUNCAN - added energy production, removed construction, repriotised.
        self:SetPrioritizedTargetList('Attack', {
            categories.COMMAND,
            categories.EXPERIMENTAL,
            categories.MASSEXTRACTION * categories.TECH3,
            categories.ENERGYPRODUCTION * categories.TECH3,
            categories.MASSEXTRACTION * categories.TECH2,
            categories.ENERGYPRODUCTION * categories.TECH2,
            categories.STRUCTURE,
            categories.TECH3 * categories.MOBILE})
        while aiBrain:PlatoonExists(self) do
            local target = false
            local blip = false
            while unit:GetTacticalSiloAmmoCount() < 1 or not target do
                WaitSeconds(7)
                target = false
                while not target do

                    --DUNCAN - Commented out
                    --if aiBrain:GetCurrentEnemy() and aiBrain:GetCurrentEnemy().Result == "defeat" then
                    --    aiBrain:PickEnemyLogic()
                    --end
                    --target = AIUtils.AIFindBrainTargetInRange(aiBrain, self, 'Attack', maxRadius, atkPri, aiBrain:GetCurrentEnemy())

                    if not target then
                        target = self:FindPrioritizedUnit('Attack', 'Enemy', true, unit:GetPosition(), maxRadius)
                    end
                    if target then
                        break
                    end
                    WaitSeconds(3)
                    if not aiBrain:PlatoonExists(self) then
                        return
                    end
                end
            end
            if not target.Dead then
                --LOG('*AI DEBUG: Firing Tactical Missile at enemy swine!')
                IssueTactical({unit}, target)
            end
            WaitSeconds(3)
        end
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
            local patrolTime = self.PlatoonData.PatrolTime or 30
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
                local rng = math.random(1,3)
                if rng == 1 then
                    patrolPositionX = (estartX + startX) / 2.2
                    patrolPositionZ = (estartZ + startZ) / 2.2
                elseif rng == 2 then
                    patrolPositionX = (estartX + startX) / 2
                    patrolPositionZ = (estartZ + startZ) / 2
                    patrolPositionX = (patrolPositionX + startX) / 2
                    patrolPositionZ = (patrolPositionZ + startZ) / 2
                elseif rng == 3 then
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
                WaitSeconds(patrolTime)
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
                                       table.remove(aiBrain.InterestList.MustScout, idx)
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
        AIAttackUtils.GetMostRestrictiveLayer(self)

        local aiBrain = self:GetBrain()
        local scout = self:GetPlatoonUnits()[1]


        if not aiBrain.InterestList then
            aiBrain:BuildScoutLocationsSwarm()
        end


        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:SetScriptBit('RULEUTC_CloakToggle', false)
        end

        while not scout.Dead do

            local targetData = false


            if aiBrain.IntelData.HiPriScouts < aiBrain.NumOpponents and SWARMGETN(aiBrain.InterestList.HighPriority) > 0 then
                targetData = aiBrain.InterestList.HighPriority[1]
                aiBrain.IntelData.HiPriScouts = aiBrain.IntelData.HiPriScouts + 1
                targetData.LastScouted = SWARMTIME()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)

            elseif SWARMGETN(aiBrain.InterestList.LowPriority) > 0 then
                targetData = aiBrain.InterestList.LowPriority[1]
                aiBrain.IntelData.HiPriScouts = 0
                targetData.LastScouted = SWARMTIME()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            else

                aiBrain.IntelData.HiPriScouts = 0
            end


            if targetData then

                local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, scout:GetPosition(), targetData.Position, 400) --DUNCAN - Increase threatwieght from 100

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
            end

            SWARMWAIT(10)
        end
    end,

    GuardMarkerSwarm = function(self)
        local aiBrain = self:GetBrain()

        local platLoc = self:GetPlatoonPosition()

        if not aiBrain:PlatoonExists(self) or not platLoc then
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
        -----------------------------------------------------------------------


        AIAttackUtils.GetMostRestrictiveLayer(self)
        self:SetPlatoonFormationOverride(PlatoonFormation)
        local markerLocations = AIUtils.AIGetMarkerLocations(aiBrain, markerType)

        local bestMarker = false

        if not self.LastMarker then
            self.LastMarker = {nil,nil}
        end

        -- look for a random marker
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
                if self:AvoidsBasesSorian(marker.Position, bAvoidBases, avoidBasesRadius) then
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
                local enemyThreat
                markerThreat = aiBrain:GetThreatAtPosition(marker.Position, 0, true, 'Economy', enemyIndex)
                enemyThreat = aiBrain:GetThreatAtPosition(marker.Position, 1, true, 'AntiSurface', enemyIndex)
                --LOG('Best pre calculation marker threat is '..markerThreat..' at position'..repr(marker.Position))
                --LOG('Surface Threat at marker is '..enemyThreat..' at position'..repr(marker.Position))
                if enemyThreat > 1 and markerThreat then
                    markerThreat = markerThreat / enemyThreat
                end
                --LOG('Best marker threat is '..markerThreat..' at position'..repr(marker.Position))
                local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])
    
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

        else
            -- if we didn't want random or threat, assume closest (but avoid ping-ponging)
            local bestDistSq = 99999999
            if SWARMGETN(markerLocations) <= 2 then
                self.LastMarker[1] = nil
                self.LastMarker[2] = nil
            end
            for _,marker in markerLocations do
                local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])
                if self:AvoidsBasesSorian(marker.Position, bAvoidBases, avoidBasesRadius) and distSq > (avoidClosestRadius * avoidClosestRadius) then
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
            --LOG("GuardMarker: Attacking " .. bestMarker.Name)
            local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, self:GetPlatoonPosition(), bestMarker.Position, 200)
            --local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, bestMarker.Position)
            IssueClearCommands(self:GetPlatoonUnits())
            if path then
                local position = self:GetPlatoonPosition()
                if VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 512 then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsSorian(aiBrain, self, bestMarker.Position, true, false, false)
                elseif VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 256 then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsSorian(aiBrain, self, bestMarker.Position, false, false, false)
                end
                if not usedTransports then
                    local pathLength = SWARMGETN(path)
                    for i=1, pathLength-1 do
                        if bAggroMove then
                            self:AggressiveMoveToLocation(path[i])
                        else
                            self:MoveToLocation(path[i], false)
                        end
                    end
                end
            elseif (not path and reason == 'NoPath') then
                usedTransports = AIAttackUtils.SendPlatoonWithTransportsSorian(aiBrain, self, bestMarker.Position, true, false, true)
            else
                self:PlatoonDisband()
                return
            end

            if not path and not usedTransports then
                self:PlatoonDisband()
                return
            end

            if moveNext == 'None' then
                -- guard
                IssueGuard(self:GetPlatoonUnits(), bestMarker.Position)
                -- guard forever
                if guardTimer <= 0 then return end
            else
                -- otherwise, we're moving to the location
                self:AggressiveMoveToLocation(bestMarker.Position)
            end

            -- wait till we get there
            local oldPlatPos = self:GetPlatoonPosition()
            local StuckCount = 0
            repeat
                WaitSeconds(5)
                platLoc = self:GetPlatoonPosition()
                if VDist3(oldPlatPos, platLoc) < 1 then
                    StuckCount = StuckCount + 1
                else
                    StuckCount = 0
                end
                if StuckCount > 5 then
                    return self:GuardMarkerSwarm()
                end
                oldPlatPos = platLoc
            until VDist2Sq(platLoc[1], platLoc[3], bestMarker.Position[1], bestMarker.Position[3]) < 64 or not aiBrain:PlatoonExists(self)

            -- if we're supposed to guard for some time
            if moveNext == 'None' then
                -- this won't be 0... see above
                WaitSeconds(guardTimer)
                self:PlatoonDisband()
                return
            end

            if moveNext == 'Guard Base' then
                return self:GuardBaseSwarm()
            end

            -- we're there... wait here until we're done
            local numGround = aiBrain:GetNumUnitsAroundPoint((categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 15, 'Enemy')
            while numGround > 0 and aiBrain:PlatoonExists(self) do
                WaitSeconds(Random(5,10))
                numGround = aiBrain:GetNumUnitsAroundPoint((categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 15, 'Enemy')
            end

            if not aiBrain:PlatoonExists(self) then
                return
            end

            -- set our MoveFirst to our MoveNext
            self.PlatoonData.MoveFirst = moveNext
            return self:GuardMarkerSwarm()
        else
            -- no marker found, disband!
            self:PlatoonDisband()
        end
    end,

    

    GuardBaseSwarm = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local target = false
        local basePosition = false
        AIAttackUtils.GetMostRestrictiveLayer(self)

        if self.PlatoonData.LocationType and self.PlatoonData.LocationType != 'NOTMAIN' then
            basePosition = aiBrain.BuilderManagers[self.PlatoonData.LocationType].Position
        else
            local platoonPosition = GetPlatoonPosition(self)
            if platoonPosition then
                basePosition = aiBrain:FindClosestBuilderManagerPosition(GetPlatoonPosition(self))
            end
        end

        if not basePosition then
            return
        end

        --DUNCAN - changed from 75, added home radius
        local guardRadius = self.PlatoonData.GuardRadius or 200
        local homeRadius = self.PlatoonData.HomeRadius or 200

        local guardType = self.PlatoonData.GuardType

        while aiBrain:PlatoonExists(self) do
            if self.MovementLayer == 'Air' then
                target = self:FindClosestUnit('Attack', 'Enemy', true, categories.MOBILE * categories.AIR - categories.WALL)
            else
                target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.WALL)
            end

            if target and not target.Dead and VDist3(target:GetPosition(), basePosition) < guardRadius then
                if guardType == 'AntiAir' then
                    self:Stop()
                    self:AggressiveMoveToLocation(target:GetPosition())
                elseif guardType == 'Bomber' then
                    self:Stop()
                    self:AttackTarget(target)
                else
                    self:Stop()
                    self:AggressiveMoveToLocation(target:GetPosition())
                end
            else
                return self:SimpleReturnToBaseSwarm(true)
                --local PlatoonPosition = GetPlatoonPosition(self)
                --if PlatoonPosition and VDist3(basePosition, PlatoonPosition) > homeRadius then
                    --DUNCAN - still try to move closer to the base if outside the radius
                    --local position = AIUtils.RandomLocation(basePosition[1],basePosition[3])
                    --self:Stop()
                    --self:MoveToLocation(position, false)
                --end
            end
            SWARMWAIT(20)
        end
    end,

    AttackForceAISwarm = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()

        -- get units together
        if not self:GatherUnits() then
            return
        end

        -- Setup the formation based on platoon functionality

        local platoonUnits = GetPlatoonUnits(self)
        local numberOfUnitsInPlatoon = SWARMGETN(platoonUnits)
        local oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
        local stuckCount = 0

        self.PlatoonAttackForce = true
        -- formations have penalty for taking time to form up... not worth it here
        -- maybe worth it if we micro
        --self:SetPlatoonFormationOverride('GrowthFormation')
        local PlatoonFormation = self.PlatoonData.UseFormation or 'NoFormation'
        self:SetPlatoonFormationOverride(PlatoonFormation)

        while aiBrain:PlatoonExists(self) do
            local pos = GetPlatoonPosition(self) -- update positions; prev position done at end of loop so not done first time

            -- if we can't get a position, then we must be dead
            if not pos then
                break
            end


            -- if we're using a transport, wait for a while
            if self.UsingTransport then
                SWARMWAIT(100)
                continue
            end

            self:MergeWithNearbyPlatoonsSwarm('AttackForceAISwarm', 100, 50)


            -- rebuild formation
            platoonUnits = GetPlatoonUnits(self)
            numberOfUnitsInPlatoon = SWARMGETN(platoonUnits)
            -- if we have a different number of units in our platoon, regather
            if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
                self:StopAttack()
                self:SetPlatoonFormationOverride(PlatoonFormation)
            end
            oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon

            -- deal with lost-puppy transports
            local strayTransports = {}
            for k,v in platoonUnits do
                if SWARMENTITY(categories.TRANSPORTATION, v) then
                    SWARMINSERT(strayTransports, v)
                end
            end
            if SWARMGETN(strayTransports) > 0 then
                local dropPoint = pos
                dropPoint[1] = dropPoint[1] + Random(-3, 3)
                dropPoint[3] = dropPoint[3] + Random(-3, 3)
                IssueTransportUnload(strayTransports, dropPoint)
                SWARMWAIT(100)
                local strayTransports = {}
                for k,v in platoonUnits do
                    local parent = v:GetParent()
                    if parent and SWARMENTITY(categories.TRANSPORTATION, parent) then
                        SWARMINSERT(strayTransports, parent)
                        break
                    end
                end
                if SWARMGETN(strayTransports) > 0 then
                    local MAIN = aiBrain.BuilderManagers.MAIN
                    if MAIN then
                        dropPoint = MAIN.Position
                        IssueTransportUnload(strayTransports, dropPoint)
                        SWARMWAIT(300)
                    end
                end
                self.UsingTransport = false
                AIUtils.ReturnTransportsToPool(strayTransports, true)
                platoonUnits = GetPlatoonUnits(self)
            end


            --Disband platoon if it's all air units, so they can be picked up by another platoon
            local mySurfaceThreat = AIAttackUtils.GetSurfaceThreatOfUnits(self)
            if mySurfaceThreat == 0 and AIAttackUtils.GetAirThreatOfUnits(self) > 0 then
                self:PlatoonDisband()
                return
            end

            local cmdQ = {}
            -- fill cmdQ with current command queue for each unit
            for k,v in platoonUnits do
                if not v.Dead then
                    local unitCmdQ = v:GetCommandQueue()
                    for cmdIdx,cmdVal in unitCmdQ do
                        SWARMINSERT(cmdQ, cmdVal)
                        break
                    end
                end
            end

            -- if we're on our final push through to the destination, and we find a unit close to our destination
            local closestTarget = self:FindClosestUnit('attack', 'enemy', true, categories.ALLUNITS)
            local nearDest = false
            local oldPathSize = SWARMGETN(self.LastAttackDestination)
            if self.LastAttackDestination then
                nearDest = oldPathSize == 0 or VDist3(self.LastAttackDestination[oldPathSize], pos) < 20
            end

            -- if we're near our destination and we have a unit closeby to kill, kill it
            if SWARMGETN(cmdQ) <= 1 and closestTarget and VDist3(closestTarget:GetPosition(), pos) < 20 and nearDest then
                self:StopAttack()
                if PlatoonFormation != 'No Formation' then
                    IssueFormAttack(platoonUnits, closestTarget, PlatoonFormation, 0)
                else
                    IssueAttack(platoonUnits, closestTarget)
                end
                cmdQ = {1}
            -- if we have nothing to do, try finding something to do
            elseif SWARMGETN(cmdQ) == 0 then
                self:StopAttack()
                cmdQ = AIAttackUtils.AIPlatoonSquadAttackVector(aiBrain, self)
                stuckCount = 0
            -- if we've been stuck and unable to reach next marker? Ignore nearby stuff and pick another target
            elseif self.LastPosition and VDist2Sq(self.LastPosition[1], self.LastPosition[3], pos[1], pos[3]) < (self.PlatoonData.StuckDistance or 16) then
                stuckCount = stuckCount + 1
                if stuckCount >= 2 then
                    self:StopAttack()
                    cmdQ = AIAttackUtils.AIPlatoonSquadAttackVector(aiBrain, self)
                    stuckCount = 0
                end
            else
                stuckCount = 0
            end

            self.LastPosition = pos

            if SWARMGETN(cmdQ) == 0 then
                -- if we have a low threat value, then go and defend an engineer or a base
                if mySurfaceThreat < 4
                    and mySurfaceThreat > 0
                    and not self.PlatoonData.NeverGuard
                    and not (self.PlatoonData.NeverGuardEngineers and self.PlatoonData.NeverGuardBases)
                then
                    --LOG('*DEBUG: Trying to guard')
                    return self:GuardBase(self.AttackForceAISwarm)
                end

                -- we have nothing to do, so find the nearest base and disband
                if not self.PlatoonData.NeverMerge then
                    return self:SimpleReturnToBaseSwarm()
                end
                SWARMWAIT(50)
            else
                -- wait a little longer if we're stuck so that we have a better chance to move
                WaitSeconds(Random(5,11) + 2 * stuckCount)
            end
            SWARMWAIT(1)
        end
    end,

    StrikeForceAISwarm = function(self)
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local data = self.PlatoonData
        local categoryList = {}
        local atkPri = {}
        if data.PrioritizedCategories then
            for k,v in data.PrioritizedCategories do
                SWARMINSERT(atkPri, v)
                SWARMINSERT(categoryList, ParseEntityCategory(v))
            end
        end
        SWARMINSERT(atkPri, 'ALLUNITS')
        SWARMINSERT(categoryList, categories.ALLUNITS)
        self:SetPrioritizedTargetList('Attack', categoryList)
        local target
        local blip = false
        local maxRadius = data.SearchRadius or 50
        local movingToScout = false
        while aiBrain:PlatoonExists(self) do
            if not target or target.Dead then
                if aiBrain:GetCurrentEnemy() and aiBrain:GetCurrentEnemy().Result == "defeat" then
                    aiBrain:PickEnemyLogic()
                end
                local mult = { 1,10,25 }
                for _,i in mult do
                    target = AIUtils.AIFindBrainTargetInRange(aiBrain, self, 'Attack', maxRadius * i, atkPri, aiBrain:GetCurrentEnemy())
                    if target then
                        break
                    end
                    WaitSeconds(1) --DUNCAN - was 3
                    if not aiBrain:PlatoonExists(self) then
                        return
                    end
                end

                --target = self:FindPrioritizedUnit('Attack', 'Enemy', true, self:GetPlatoonPosition(), maxRadius)

                --DUNCAN - added to target experimentals if they exist.
                local newtarget
                if AIAttackUtils.GetSurfaceThreatOfUnits(self) > 0 then
                    newtarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.EXPERIMENTAL * (categories.LAND + categories.NAVAL + categories.STRUCTURE))
                elseif AIAttackUtils.GetAirThreatOfUnits(self) > 0 then
                    newtarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.EXPERIMENTAL * categories.AIR)
                end
                if newtarget then
                    target = newtarget
                end

                if target then
                    self:Stop()
                    if not data.UseMoveOrder then
                        self:AttackTarget(target)
                    else
                        self:MoveToLocation(SWARMCOPY(target:GetPosition()), false)
                    end
                    movingToScout = false
                elseif not movingToScout then
                    movingToScout = true
                    self:Stop()
                    for k,v in AIUtils.AIGetSortedMassLocations(aiBrain, 10, nil, nil, nil, nil, self:GetPlatoonPosition()) do
                        if v[1] < 0 or v[3] < 0 or v[1] > ScenarioInfo.size[1] or v[3] > ScenarioInfo.size[2] then
                            --LOG('*AI DEBUG: STRIKE FORCE SENDING UNITS TO WRONG LOCATION - ' .. v[1] .. ', ' .. v[3])
                        end
                        self:MoveToLocation((v), false)
                    end
                end
            end
            WaitSeconds(7)
        end
    end,

    MassRaidSwarm = function(self)
        local aiBrain = self:GetBrain()
        --LOG('Platoon ID is : '..self:GetPlatoonUniqueName())
        local platLoc = GetPlatoonPosition(self)

        if not aiBrain:PlatoonExists(self) or not platLoc then
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

        -----------------------------------------------------------------------
        local markerLocations

        AIAttackUtils.GetMostRestrictiveLayer(self)
        self:SetPlatoonFormationOverride(PlatoonFormation)
        
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

        if aiBrain:GetCurrentEnemy() then
           enemyIndex = aiBrain:GetCurrentEnemy():GetArmyIndex()
            --LOG('Enemy Index is '..enemyIndex)
        end
        -- find best threat at the closest distance
        for _,marker in markerLocations do
            local markerThreat
            local enemyThreat
            markerThreat = aiBrain:GetThreatAtPosition(marker.Position, 0, true, 'Economy', enemyIndex)
            enemyThreat = aiBrain:GetThreatAtPosition(marker.Position, 1, true, 'AntiSurface', enemyIndex)
            --LOG('Best pre calculation marker threat is '..markerThreat..' at position'..repr(marker.Position))
            --LOG('Surface Threat at marker is '..enemyThreat..' at position'..repr(marker.Position))
            if enemyThreat > 1 and markerThreat then
                markerThreat = markerThreat / enemyThreat
            end
            --LOG('Best marker threat is '..markerThreat..' at position'..repr(marker.Position))
            local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])

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

        --LOG('* AI-RNG: Best Marker Selected is at position'..repr(bestMarker.Position))
        
        if bestMarker.Position == nil and SWARMTIME() > 900 then
            --LOG('Best Marker position was nil and game time greater than 15 mins, switch to hunt ai')
            return self:LandAttackAISwarm()
        elseif bestMarker.Position == nil then
            --LOG('Best Marker position was nil, select random')
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
        end

        local usedTransports = false

        if bestMarker then
            self.LastMarker[2] = self.LastMarker[1]
            self.LastMarker[1] = bestMarker.Position

            --LOG("GuardMarker: Attacking " .. bestMarker.Name)
            local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, GetPlatoonPosition(self), bestMarker.Position, 100 , maxPathDistance)
            local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, bestMarker.Position)
            IssueClearCommands(GetPlatoonUnits(self))
            if path then

                self:MergeWithNearbyPlatoonsSwarm('MassRaidSwarm', 100, 30)

                SWARMWAIT(10)

                local position = GetPlatoonPosition(self)
                if not success or VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 512 then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, bestMarker.Position, true)
                elseif VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 256 then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, bestMarker.Position, false)
                end
                if not usedTransports then
                    local pathLength = SWARMGETN(path)
                    for i=1, pathLength - 1 do
                        --LOG('* AI-RNG: * MassRaidRNG: moving to destination. i: '..i..' coords '..repr(path[i]))
                        if bAggroMove then
                            self:AggressiveMoveToLocation(path[i])
                        else
                            self:MoveToLocation(path[i], false)
                        end
                        --LOG('* AI-RNG: * MassRaidRNG: moving to Waypoint')
                        local PlatoonPosition
                        local Lastdist
                        local dist
                        local Stuck = 0
                        while aiBrain:PlatoonExists(self) do
                            PlatoonPosition = GetPlatoonPosition(self) or nil
                            if not PlatoonPosition then break end
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
                                    --LOG('* AI-RNG: * MassRaidRNG: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                    self:Stop()
                                    break
                                end
                            end
                            WaitTicks(15)
                        end
                    end
                end
            elseif (not path and reason == 'NoPath') then
                --LOG('Guardmarker requesting transports')
                local foundTransport = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, bestMarker.Position, true)
                --DUNCAN - if we need a transport and we cant get one the disband
                if not foundTransport then
                    --LOG('Guardmarker no transports')
                    self:PlatoonDisband()
                    return
                end
                --LOG('Guardmarker found transports')
            else
                self:PlatoonDisband()
                return
            end

            if (not path or not success) and not usedTransports then
                self:PlatoonDisband()
                return
            end

            self:AggressiveMoveToLocation(bestMarker.Position)

            -- wait till we get there
            local oldPlatPos = GetPlatoonPosition(self)
            local StuckCount = 0
            repeat
                WaitTicks(50)
                platLoc = GetPlatoonPosition(self)
                if VDist3(oldPlatPos, platLoc) < 1 then
                    StuckCount = StuckCount + 1
                else
                    StuckCount = 0
                end
                if StuckCount > 5 then
                    --LOG('MassRaidAI stuck count over 5, restarting')
                    return self:MassRaidSwarm()
                end
                oldPlatPos = platLoc
            until VDist2Sq(platLoc[1], platLoc[3], bestMarker.Position[1], bestMarker.Position[3]) < 64 or not aiBrain:PlatoonExists(self)

            -- we're there... wait here until we're done
            local numGround = aiBrain:GetNumUnitsAroundPoint((categories.ENGINEER + categories.STRUCTURE), bestMarker.Position, 35, 'Enemy')
            while numGround > 0 and aiBrain:PlatoonExists(self) do
                WaitTicks(30)
                --LOG('Still enemy stuff around marker position')
                numGround = aiBrain:GetNumUnitsAroundPoint((categories.ENGINEER + categories.STRUCTURE), bestMarker.Position, 35, 'Enemy')
            end

            if not aiBrain:PlatoonExists(self) then
                return
            end
            --LOG('MassRaidAI restarting')
            return self:MassRaidSwarm()
        else
            -- no marker found, disband!
            self:PlatoonDisband()
        end
    end,

    PlatoonCallForHelpAISwarm = function(self)
        local aiBrain = self:GetBrain()
        local checkTime = self.PlatoonData.DistressCheckTime or 7
        local pos = self:GetPlatoonPosition()
        while aiBrain:PlatoonExists(self) and pos do
            if not self.DistressCall then
                local threat = aiBrain:GetThreatAtPosition(pos, 0, true, 'AntiSurface')
                if threat and threat > 1 then
                    --LOG('*AI DEBUG: Platoon Calling for help')
                    aiBrain:BaseMonitorPlatoonDistress(self, threat)
                    self.DistressCall = true
                end
            end
            WaitSeconds(checkTime)
        end
    end,

    DistressResponseAISwarm = function(self)
        local aiBrain = self:GetBrain()
        while aiBrain:PlatoonExists(self) do
            -- In the loop so they may be changed by other platoon things
            local distressRange = self.PlatoonData.DistressRange or aiBrain.BaseMonitor.DefaultDistressRange
            local reactionTime = self.PlatoonData.DistressReactionTime or aiBrain.BaseMonitor.PlatoonDefaultReactionTime
            local threatThreshold = self.PlatoonData.ThreatSupport or 1
            local platoonPos = self:GetPlatoonPosition()
            if platoonPos and not self.DistressCall then
                -- Find a distress location within the platoons range
                local distressLocation = aiBrain:BaseMonitorDistressLocation(platoonPos, distressRange, threatThreshold)
                local moveLocation

                -- We found a location within our range! Activate!
                if distressLocation then
                    --LOG('*AI DEBUG: ARMY '.. aiBrain:GetArmyIndex() ..': --- DISTRESS RESPONSE AI ACTIVATION ---')

                    -- Backups old ai plan
                    local oldPlan = self:GetPlan()
                    if self.AiThread then
                        self.AIThread:Destroy()
                    end

                    -- Continue to position until the distress call wanes
                    repeat
                        moveLocation = distressLocation
                        self:Stop()
                        local cmd = self:AggressiveMoveToLocation(distressLocation)
                        repeat
                            WaitSeconds(reactionTime)
                            if not aiBrain:PlatoonExists(self) then
                                return
                            end
                        until not self:IsCommandsActive(cmd) or aiBrain:GetThreatAtPosition(moveLocation, 0, true, 'Overall') <= threatThreshold


                        platoonPos = self:GetPlatoonPosition()
                        if platoonPos then
                            -- Now that we have helped the first location, see if any other location needs the help
                            distressLocation = aiBrain:BaseMonitorDistressLocation(platoonPos, distressRange)
                            if distressLocation then
                                self:AggressiveMoveToLocation(distressLocation)
                            end
                        end
                    -- If no more calls or we are at the location; break out of the function
                    until not distressLocation or (distressLocation[1] == moveLocation[1] and distressLocation[3] == moveLocation[3])

                    --LOG('*AI DEBUG: '..aiBrain.Name..' DISTRESS RESPONSE AI DEACTIVATION - oldPlan: '..oldPlan)
                    self:SetAIPlan(oldPlan)
                end
            end
            WaitSeconds(11)
        end
    end,


    -- HeroFightPlatoon Function is extremely slow, leading to platoons which use this function having awful and insanely slow reactions.
    -- Most likely will be using this less and less.
    HeroFightPlatoonSwarm = function(self)
        local aiBrain = self:GetBrain()
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')

        -- this will set self.MovementLayer to the platoon
        AIAttackUtils.GetMostRestrictiveLayer(self)

        -- get categories where we want to move this platoon - (primary platoon targets)
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                SWARMINSERT(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * HeroFightPlatoon: MoveToCategories missing in platoon '..self.BuilderName)
        end

        -- get categories at what we want a unit to shoot at - (primary unit targets)
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                SWARMINSERT(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)

        -- calcuate maximum weapon range for every unit inside this platoon
        -- also switch on things like stealth and cloak
        local MaxPlatoonWeaponRange
        local ExperimentalInPlatoon = false
        local UnitBlueprint
        local YawMin = 0
        local YawMax = 0
        local TargetHug = self.PlatoonData.TargetHug
        for _, unit in self:GetPlatoonUnits() do
            -- continue with the next unit if this unit is dead
            if unit.Dead then continue end
            UnitBlueprint = unit:GetBlueprint()
            -- remove INSIGNIFICANTUNIT units from the platoon (drones, buildbots etc)
            if UnitBlueprint.CategoriesHash.INSIGNIFICANTUNIT then
                --SPEW('* AI-Swarm: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a INSIGNIFICANTUNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- remove POD units from the platoon
            if UnitBlueprint.CategoriesHash.POD then
                --SPEW('* AI-Swarm: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a POD UNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- remove DRONE units from the platoon
            if UnitBlueprint.CategoriesHash.DRONE then
                --SPEW('* AI-Swarm: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a DRONE UNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- Seraphim Experimentals should always move close to the target
            if UnitBlueprint.CategoriesHash.EXPERIMENTAL and UnitBlueprint.CategoriesHash.SERAPHIM then
                TargetHug = true
            end
            -- get the maximum weapopn range of this unit
            for _, weapon in UnitBlueprint.Weapon or {} do
                -- filter dummy weapons
                if weapon.Damage == 0 then
                    continue
                end
                if UnitBlueprint.CategoriesHash.EXPERIMENTAL and UnitBlueprint.Physics.StandUpright then
                    -- for Experiemtnals with 2 legs
                    unit.HasRearWeapon = false
                    --LOG('* AI-Swarm: Unit ['..unit.UnitId..'] can StandUpright! -> removing rear weapopn flag')
                else
                    -- check weapon angle    pitch ^    yaw >
                    YawMin = false
                    YawMax = false
                    if weapon.HeadingArcCenter and weapon.HeadingArcRange then
                        YawMin = weapon.HeadingArcCenter - weapon.HeadingArcRange
                        YawMax = weapon.HeadingArcCenter + weapon.HeadingArcRange
                    elseif weapon.TurretYaw and weapon.TurretYawRange then
                        YawMin = weapon.TurretYaw - weapon.TurretYawRange
                        YawMax = weapon.TurretYaw + weapon.TurretYawRange
                    end
                    if YawMin and YawMax then
                        -- front unit side
                        if YawMin <= -180 and YawMax >= 180 then
                            --LOG('* AI-Swarm: Unit ['..unit.UnitId..'] can fire 360° front')
                            unit.HasRearWeapon = true
                        end
                        -- left unit side
                        if YawMin <= -225 and YawMax >= -135 then
                            --LOG('* AI-Swarm: Unit ['..unit.UnitId..'] can fire 90° rear (left)')
                            unit.HasRearWeapon = true
                        end
                        -- right unit side
                        if YawMin <= 135 and YawMax >= 225 then
                            --LOG('* AI-Swarm: Unit ['..unit.UnitId..'] can fire 90° rear (right)')
                            unit.HasRearWeapon = true
                        end
                        -- back unit side
                        if YawMin <= -202.5 and YawMax >= 202.5 then
                            --LOG('* AI-Swarm: Unit ['..unit.UnitId..'] can fire 45° rear')
                            unit.HasRearWeapon = true
                        end
                    end
                end
                -- unit can have MaxWeaponRange entry from the last platoon
                if not unit.MaxWeaponRange or weapon.MaxRadius < unit.MaxWeaponRange then
                    -- exclude missiles with range 100 and above
                    if weapon.WeaponCategory ~= 'Missile' or weapon.MaxRadius < 100 then
                        -- save the weaponrange 
                        unit.MaxWeaponRange = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                        -- save the weapon balistic arc, we need this later to check if terrain is blocking the weapon line of sight
                        if weapon.BallisticArc == 'RULEUBA_LowArc' then
                            unit.WeaponArc = 'low'
                        elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                            unit.WeaponArc = 'high'
                        else
                            unit.WeaponArc = 'none'
                        end
                    else
                        -- save a backup weapon in case we have only missiles or longrange weapons
                        unit.MaxWeaponRangeBackup = weapon.MaxRadius * 0.9 -- maxrange minus 10%
                        if weapon.BallisticArc == 'RULEUBA_LowArc' then
                            unit.WeaponArcBackup = 'low'
                        elseif weapon.BallisticArc == 'RULEUBA_HighArc' then
                            unit.WeaponArcBackup = 'high'
                        else
                            unit.WeaponArcBackup = 'none'
                        end
                    end
                end
                -- check for the overall range of the platoon
                if not MaxPlatoonWeaponRange or MaxPlatoonWeaponRange > unit.MaxWeaponRange then
                    MaxPlatoonWeaponRange = unit.MaxWeaponRange
                end
            end
            -- in case we have not a normal weapons, use the backupweapon if available
            if not unit.MaxWeaponRange and unit.MaxWeaponRangeBackup then
                unit.MaxWeaponRange = unit.MaxWeaponRangeBackup
                unit.WeaponArc = unit.WeaponArcBackup
            end
            -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
            if unit:TestToggleCaps('RULEUTC_StealthToggle') then
                unit:SetScriptBit('RULEUTC_StealthToggle', false)
            end
            if unit:TestToggleCaps('RULEUTC_CloakToggle') then
                unit:SetScriptBit('RULEUTC_CloakToggle', false)
            end
            -- search if we have an experimental inside the platoon so we can't use transports
            if not ExperimentalInPlatoon and SWARMENTITY(categories.EXPERIMENTAL, unit) then
                ExperimentalInPlatoon = true
            end
            -- prevent units from reclaiming while attack moving (maybe not working !?!)
            unit:RemoveCommandCap('RULEUCC_Reclaim')
            unit:RemoveCommandCap('RULEUCC_Repair')
            -- create a table for individual unit position
            unit.smartPos = {0,0,0}
            unit.UnitMassCost = UnitBlueprint.Economy.BuildCostMass
            -- we have no weapon; check if we have a shield, stealth field or cloak field
            if not unit.MaxWeaponRange then
                -- does the unit has no weapon but a shield ?
                if UnitBlueprint.CategoriesHash.SHIELD then
                    --LOG('* AI-Swarm: Scanning: unit ['..repr(unit.UnitId)..'] Is a IsShieldOnlyUnit')
                    unit.IsShieldOnlyUnit = true
                end
                if UnitBlueprint.Intel.RadarStealthField then
                    --LOG('* AI-Swarm: Scanning: unit ['..repr(unit.UnitId)..'] Is a RadarStealthField Unit')
                    unit.IsShieldOnlyUnit = true
                end
                if UnitBlueprint.Intel.CloakField then
                    --LOG('* AI-Swarm: Scanning: unit ['..repr(unit.UnitId)..'] Is a CloakField Unit')
                    unit.IsShieldOnlyUnit = true
                end
            end
            -- debug for modded units that have no weapon and no shield or stealth/cloak
            -- things like seraphim restauration field
            if not unit.MaxWeaponRange and not unit.IsShieldOnlyUnit then
                WARN('* AI-Swarm: Scanning: unit ['..repr(unit.UnitId)..'] has no MaxWeaponRange and no stealth/cloak - '..repr(self.BuilderName))
            end
            unit.IamLost = 0
        end
        if not MaxPlatoonWeaponRange then
            if aiBrain:PlatoonExists(self) then
                self:PlatoonDisband()
            end
            return
        end
        -- we only see targets from this targetcategories.
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory
        if not TargetSearchCategory then
            WARN('* AI-Swarm: Missing TargetSearchCategory in builder: '..repr(self.BuilderName))
            TargetSearchCategory = categories.ALLUNITS
        end
        -- additional variables we need inside the platoon loop
        local TargetInPlatoonRange
        local target
        local TargetPos
        local LastTargetPos
        local UnitWithPath
        local UnitNoPath
        local path
        local reason
        local unitPos
        local alpha
        local x
        local y
        local smartPos = {}
        local UnitToCover = nil
        local CoverIndex = 0
        local UnitMassCost = {}
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local WantsTransport = self.PlatoonData.RequireTransport
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local DirectMoveEnemyBase = self.PlatoonData.DirectMoveEnemyBase
        local basePosition
        local PlatoonCenterPosition = self:GetPlatoonPosition()
        local bAggroMove = self.PlatoonData.AggressiveMove
        if TargetHug then
            bAggroMove = false
        end
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonCenterPosition
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFrom = basePosition
        if DirectMoveEnemyBase then
            local ClosestEnemyBaseDistance
            local ClosestEnemyBaseLocation
            for index, brain in ArmyBrains do
                if brain.BuilderManagers['MAIN'] then
                    if brain.BuilderManagers['MAIN'].FactoryManager.Location then
                        local Baselocation = aiBrain.BuilderManagers['MAIN'].Position
                        local EnemyBaseLocation = brain.BuilderManagers['MAIN'].Position
                        local dist = VDist2( Baselocation[1], Baselocation[3], EnemyBaseLocation[1], EnemyBaseLocation[3] )
                        if dist < 10 then continue end
                        if not ClosestEnemyBaseDistance or ClosestEnemyBaseDistance > dist then
                            ClosestEnemyBaseLocation = EnemyBaseLocation
                            ClosestEnemyBaseDistance = dist
                        end
                    end
                end
            end
            if ClosestEnemyBaseLocation then
                GetTargetsFrom = ClosestEnemyBaseLocation
            end
        end
        -- platoon loop
        --self:RenamePlatoon('MAIN loop')
        while aiBrain:PlatoonExists(self) do
            -- remove the Blocked flag from all unts. (at this point we don't have a target or the target is dead or we clean a leftover from the last platoon call)
            for _, unit in self:GetPlatoonUnits() or {} do
                unit.Blocked = false
            end
            -- wait a bit here, so continue commands can't deadloop/freeze the game
            SWARMWAIT(3)
            if self.UsingTransport then
                continue
            end
            PlatoonCenterPosition = self:GetPlatoonPosition()
            if not PlatoonCenterPosition[1] then
                if aiBrain:PlatoonExists(self) then
                    self:PlatoonDisband()
                end
                return
            end
            -- set target search center position
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonCenterPosition
            end
            -- Search for a target (don't remove the :BeenDestroyed() call!)
            if not target or target.Dead or target:BeenDestroyed() then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                target = UnitWithPath or UnitNoPath
            end
            -- remove target, if we are out of base range
            DistanceToBase = VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if GetTargetsFromBase and DistanceToBase > maxRadius then
                target = nil
                path = nil
                if HERODEBUGSwarm then
                    self:RenamePlatoon('target to far from base')
                    SWARMWAIT(1)
                end
           end
            -- check if the platoon died while the targetting function was searching for targets
            if not aiBrain:PlatoonExists(self) then
                return
            end
            -- move to the target
            if target and not target.Dead and not target:BeenDestroyed() then
                LastTargetPos = SWARMCOPY(target:GetPosition())
                -- are we outside weaponrange ? then move to the target
                if VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ) > MaxPlatoonWeaponRange + 30 then
                    --self:RenamePlatoon('move to target -> out of weapon range')
                    -- if we have a path then use the waypoints 
                    if UnitWithPath and path and not self.PlatoonData.IgnorePathing then
                        --self:RenamePlatoon('move to target -> with waypoints')
                        -- move to the target with waypoints
                        if self.MovementLayer == 'Air' then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('MovePath (Air)')
                                SWARMWAIT(1)
                            end
                            self:MovePath(aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        elseif self.MovementLayer == 'Water' then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('MovePath (Water)')
                                SWARMWAIT(1)
                            end
                            self:MovePath(aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        else
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('MovePath with transporter layer('..self.MovementLayer..')')
                                SWARMWAIT(1)
                            end
                            self:MoveToLocationInclTransportSwarm(target, LastTargetPos, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, TargetSearchCategory)
                        end
                    -- if we don't have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                    elseif UnitWithPath then
                        --self:RenamePlatoon('move to target -> without waypoints')
                        -- move to the target without waypoints
                        if self.MovementLayer == 'Air' then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('UWP MoveDirect (Air)')
                                SWARMWAIT(1)
                            end
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        elseif self.MovementLayer == 'Water' then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('UWP MoveDirect (Water)')
                                SWARMWAIT(1)
                            end
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        else
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('UWP MoveDirect with transporter layer('..self.MovementLayer..')')
                                SWARMWAIT(1)
                            end
                            self:MoveToLocationInclTransportSwarm(target, LastTargetPos, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, TargetSearchCategory)
                        end
                    -- move to the target without waypoints using a transporter
                    elseif UnitNoPath then
                        -- we have a target but no path, Air can flight to it
                        if self.MovementLayer == 'Air' then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('UNP MoveDirect (Air)')
                                SWARMWAIT(1)
                            end
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        -- we have a target but no path, Naval can never reach it
                        elseif self.MovementLayer == 'Water' then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('UNP No Naval path (Water)')
                                SWARMWAIT(1)
                            end
                            target = nil
                            path = nil
                        else
                            self:Stop()
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('UWP MoveOnlyWithTransport layer('..self.MovementLayer..')')
                                SWARMWAIT(1)
                            end
                            --self:RenamePlatoon('MoveOnlyWithTransport')
                            self:MoveWithTransport(aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, TargetSearchCategory)
                        end
                    end
                end
            else
                target = nil
                path = nil
                -- no target, land units just wait for new targets, air and naval units return to their base
                if HERODEBUGSwarm then
                    self:RenamePlatoon('No target returning home')
                    SWARMWAIT(1)
                end
                if self.MovementLayer == 'Air' then
                    --self:RenamePlatoon('move to base')
                    if VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 40 then
                        self:SetPlatoonFormationOverride('NoFormation')
                        self:SimpleReturnToBaseSwarm(basePosition)
                        if HERODEBUGSwarm then
                            self:RenamePlatoon('returning (Air)')
                            SWARMWAIT(10)
                        end
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                        end
                        return
                    else
                        -- we are at home and we don't have a target. Disband!
                        if aiBrain:PlatoonExists(self) then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('PlatoonDisband 1')
                            end
                            self:PlatoonDisband()
                            return
                        end
                    end
                elseif self.MovementLayer == 'Water' then
                    --self:RenamePlatoon('move to base')
                    if VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 40 then
                        if HERODEBUGSwarm then
                            self:RenamePlatoon('returning (Water)')
                            SWARMWAIT(10)
                        end
                        self:SetPlatoonFormationOverride('NoFormation')
                        self:ForceReturnToNearestBaseAISwarm()
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                        end
                        return
                    else
                    -- we are at home and we don't have a target. Disband!
                        if aiBrain:PlatoonExists(self) then
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('PlatoonDisband 2')
                            end
                            self:PlatoonDisband()
                            return
                        end
                    end
                else
                    -- if we get targets from base then we are here to protect the base. Return to cover the base.
                    if GetTargetsFromBase then
                        if HERODEBUGSwarm then
                            self:RenamePlatoon('No BaseTarget, returning Home')
                            SWARMWAIT(1)
                        end
                        self:ForceReturnToNearestBaseAISwarm()
                        return
                    else
                        if HERODEBUGSwarm then
                            self:RenamePlatoon('move to New targets')
                            SWARMWAIT(1)
                        end
                        -- no more targets found with platoonbuilder template settings. Set new targets to the platoon and continue
                        --self.PlatoonData.SearchRadius = 10000
                        maxRadius = 10000
                        self.PlatoonData.AttackEnemyStrength = 1000000
                        --self.PlatoonData.GetTargetsFromBase = false
                        GetTargetsFromBase = false
                        self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.COMMAND, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                        MoveToCategories = {}
                        for k,v in self.PlatoonData.MoveToCategories do
                            SWARMINSERT(MoveToCategories, v )
                        end
                        self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.COMMAND, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                        self.PlatoonData.TargetSearchCategory = categories.ALLUNITS - categories.AIR
                        TargetSearchCategory = categories.ALLUNITS - categories.AIR
                        self:SetPrioritizedTargetList('Attack', categories.ALLUNITS - categories.AIR)
                        continue
                    end
                end
            end
            -- in case we are using a transporter, do nothing. Wait for the transport!
            if self.UsingTransport then
                if HERODEBUGSwarm then
                    self:RenamePlatoon('Waiting for Transport')
                    SWARMWAIT(1)
                end
                continue
            end
            -- stop the platoon, now we are moving units instead of the platoon
            if aiBrain:PlatoonExists(self) then
                self:Stop()
                SWARMWAIT(1)
                if LastTargetPos then
                    self:Patrol(LastTargetPos)
                else
                    self:Patrol(basePosition)
                end
            else
                return
            end
            -- fight
            if HERODEBUGSwarm then
                self:RenamePlatoon('moved, now fighting')
            end
            SWARMWAIT(1)
            LastTargetPos = nil
            --self:RenamePlatoon('MICRO loop')
            while aiBrain:PlatoonExists(self) do
                if HERODEBUGSwarm then
                    self:RenamePlatoon('microing in 5 ticks')
                end
                -- wait a bit here, so continue commands can't deadloop/freeze the game
                SWARMWAIT(10)
                --LOG('* AI-Swarm: * HeroFightPlatoon: Starting micro loop')
                PlatoonCenterPosition = self:GetPlatoonPosition()
                if not PlatoonCenterPosition then
                    --WARN('* AI-Swarm: PlatoonCenterPosition not existent')
                    if aiBrain:PlatoonExists(self) then
                        if HERODEBUGSwarm then
                            self:RenamePlatoon('PlatoonDisband 3')
                        end
                        self:PlatoonDisband()
                    end
                    return
                end
                if HERODEBUGSwarm then
                    self:RenamePlatoon('AIFindNearestCategoryTargetInCloseRangeSwarm')
                end

                -- get a target on every loop, so we can see targets that are moving closer
                if TargetHug then
                    TargetInPlatoonRange = self:FindClosestUnit('Attack', 'Enemy', true, TargetSearchCategory)
                else
                    TargetInPlatoonRange = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS)
                end

                -- check if the target is in range
                if TargetInPlatoonRange then
                    LastTargetPos = TargetInPlatoonRange:GetPosition()
                    if self.MovementLayer == 'Air' then
                        if VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ) > MaxPlatoonWeaponRange + 60 then
                            -- Air target is to far away, remove it and lets get a new main target 
                            TargetInPlatoonRange = false
                        end
                    else
                        if VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ) > MaxPlatoonWeaponRange + 35 then
                            -- land/naval target is to far away, remove it and lets get a new main target 
                            TargetInPlatoonRange = false
                        end
                    end
                end

                if HERODEBUGSwarm then
                    if TargetInPlatoonRange then
                        if TargetInPlatoonRange.Dead then
                            self:RenamePlatoon('TargetInPlatoonRange = Dead')
                        else
                            self:RenamePlatoon('TargetInPlatoonRange true')
                        end
                    else
                        self:RenamePlatoon('TargetInPlatoonRange = NIL')
                    end
                end

                if TargetInPlatoonRange and not TargetInPlatoonRange.Dead then
                    --LOG('* AI-Uveso: * HeroFightPlatoon: TargetInPlatoonRange: ['..repr(TargetInPlatoonRange.UnitId)..']')
                    if AIUtils.IsNukeBlastAreaSwarm(aiBrain, LastTargetPos) then
                        -- continue the "while aiBrain:PlatoonExists(self) do" loop
                        continue
                    end
                    if self.MovementLayer == 'Air' then
                        -- remove target, if we are out of base range
                        DistanceToBase = VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                        if GetTargetsFromBase and DistanceToBase > maxRadius then
                            TargetInPlatoonRange = nil
                            if HERODEBUGSwarm then
                                self:RenamePlatoon('micro attack AIR DistanceToBase > maxRadius')
                                SWARMWAIT(1)
                            end
                            break
                        end
                        -- else attack
                        if HERODEBUGSwarm then
                            self:RenamePlatoon('micro attack AIR')
                            SWARMWAIT(1)
                        end
                        self:AttackTarget(TargetInPlatoonRange)
                    else
                        if HERODEBUGSwarm then
                            self:RenamePlatoon('micro attack Land')
                            SWARMWAIT(1)
                        end
                        --LOG('* AI-Swarm: * HeroFightPlatoon: Fight micro LAND start')
                        --self:RenamePlatoon('Fight micro LAND start')
                        -- bring all platoon units in optimal range to the target
                        UnitMassCost = {}
                        ------------------------------------------------------------------------------
                        -- First micro turn for attack untis, second turn is for cover/shield units --
                        ------------------------------------------------------------------------------
                        for _, unit in self:GetPlatoonUnits() or {} do
                            if unit.Dead then
                                continue
                            end
                            -- don't move shield units in the first turn
                            if unit.IsShieldOnlyUnit then
                                continue
                            end
                            -- clear move commands if we have queued more than 2
                            if SWARMGETN(unit:GetCommandQueue()) > 1 then
                                IssueClearCommands({unit})
                            end
                            unitPos = unit:GetPosition()
                            if unit.Blocked then
                                -- Weapoon fire is blocked, move to the target as close as possible.
                                smartPos = { LastTargetPos[1] + (Random(-5, 5)/10), LastTargetPos[2], LastTargetPos[3] + (Random(-5, 5)/10) }
                            else
                                alpha = math.atan2 (LastTargetPos[3] - unitPos[3] ,LastTargetPos[1] - unitPos[1])
                                x = LastTargetPos[1] - SWARMCOS(alpha) * (unit.MaxWeaponRange or MaxPlatoonWeaponRange)
                                y = LastTargetPos[3] - SWARMSIN(alpha) * (unit.MaxWeaponRange or MaxPlatoonWeaponRange)
                                smartPos = { x, GetTerrainHeight( x, y), y }
                            end
                            -- if we need to get as close to the target as possible, then just run to the target position
                            if TargetHug then
                                IssueMove({unit}, { LastTargetPos[1] + Random(-1, 1), LastTargetPos[2], LastTargetPos[3] + Random(-1, 1) } )
                            -- check if the move position is new or target has moved
                            -- if we don't have a rear weapon then attack (will move in circles otherwise)
                            elseif not unit.HasRearWeapon and VDist2( unitPos[1], unitPos[3], LastTargetPos[1], LastTargetPos[3] ) > (unit.MaxWeaponRange or MaxPlatoonWeaponRange) then
                                if HERODEBUGSwarm then
                                    self:RenamePlatoon('micro attack Land No RearWeapon')
                                    SWARMWAIT(1)
                                end
                                if not TargetInPlatoonRange.Dead then
                                    IssueAttack({unit}, TargetInPlatoonRange)
                                end
                            elseif unit.HasRearWeapon and ( VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 or unit.TargetPos ~= LastTargetPos ) then
                                if HERODEBUGSwarm then
                                    self:RenamePlatoon('micro attack Land has RearWeapon')
                                end
                                -- in case we have a new target, delete the Blocked flag
                                if unit.TargetPos ~= LastTargetPos then
                                    unit.Blocked = false
                                end
                                -- check if we are far away fromthe platoon. maybe we have a stucked unit here
                                -- can also be a unit that needs to deploy for weapon fire
                                if VDist2( unitPos[1], unitPos[3], PlatoonCenterPosition[1], PlatoonCenterPosition[3] ) > 100.0 then
                                    if not unit:IsMoving() then
                                        unit.IamLost = unit.IamLost + 1
                                    end
                                else
                                    unit.IamLost = 0
                                end
                                if unit.IamLost > 5 then
                                    WARN('* AI-Swarm: We have a LOST (stucked) unit. Killing it!!! Distance to platoon: '..SWARMFLOOR(VDist2( unitPos[1], unitPos[3], PlatoonCenterPosition[1], PlatoonCenterPosition[3]))..' pos: ( '..SWARMFLOOR(unitPos[1])..' , '..SWARMFLOOR(unitPos[3])..' )' )
                                    -- stucked units can't be unstucked, even with a forked thread and hammering movement commands. Let's kill it !!!
                                    unit:Kill()
                                end
                                IssueMove({unit}, smartPos )
                                if HERODEBUGSwarm then
                                    unit:SetCustomName('Fight micro moving')
                                    SWARMWAIT(1)
                                end
                                unit.smartPos = smartPos
                                unit.TargetPos = LastTargetPos
                            -- in case we don't move, check if we can fire at the target
                            else
                                if aiBrain:CheckBlockingTerrain(unitPos, LastTargetPos, unit.WeaponArc) then
                                    if HERODEBUGSwarm then
                                        unit:SetCustomName('WEAPON BLOCKED!!! ['..repr(TargetInPlatoonRange.UnitId)..']')
                                        SWARMWAIT(1)
                                    end
                                    unit.Blocked = true
                                else
                                    if HERODEBUGSwarm then
                                        unit:SetCustomName('SHOOTING ['..repr(TargetInPlatoonRange.UnitId)..']')
                                    end
                                    unit.Blocked = false
                                    if not TargetInPlatoonRange.Dead then
                                        -- set the target as focus, we are in range, the unit will shoot without attack command
                                        unit:SetFocusEntity(TargetInPlatoonRange)
                                    end
                                end
                            end
                            -- use this table later to decide what unit we want to cover with shields
                            SWARMINSERT(UnitMassCost, {UnitMassCost = unit.UnitMassCost, smartPos = unit.smartPos, TargetPos = unit.TargetPos})
                        end -- end micro first turn 
                        if not UnitMassCost[1] then
                            -- we can just disband the platoon everywhere on the map.
                            -- the location manager will return these units to the nearest base for reassignment.
                            --self:RenamePlatoon('no Fighters -> Disbanded')
                            if aiBrain:PlatoonExists(self) then
                                if HERODEBUGSwarm then
                                    self:RenamePlatoon('PlatoonDisband 4')
                                    SWARMWAIT(1)
                                end
                                self:PlatoonDisband()
                            end
                            return
                        end
                        SWARMSORT(UnitMassCost, function(a, b) return a.UnitMassCost > b.UnitMassCost end)
                        ----------------------------------------------
                        -- Second micro turn for cover/shield units --
                        ----------------------------------------------
                        UnitToCover = nil
                        CoverIndex = 0
                        for _, unit in self:GetPlatoonUnits() do
                            if unit.Dead then continue end
                            -- don't use attack units here
                            if not unit.IsShieldOnlyUnit then
                                continue
                            end
                            unitPos = unit:GetPosition()
                            -- select a unit we want to cover. units with high mass cost first
                            CoverIndex = CoverIndex + 1
                            if not UnitMassCost[CoverIndex] then
                                if CoverIndex ~= 1 then
                                    CoverIndex = 1
                                end
                            end
                            UnitToCover = UnitMassCost[CoverIndex]
                            -- calculate a position behind the unit we want to cover (behind unit from enemy view)
                            if UnitToCover.smartPos and UnitToCover.TargetPos then
                                alpha = math.atan2 (UnitToCover.smartPos[3] - UnitToCover.TargetPos[3] ,UnitToCover.smartPos[1] - UnitToCover.TargetPos[1])
                                x = UnitToCover.smartPos[1] + SWARMCOS(alpha) * 4
                                y = UnitToCover.smartPos[3] + SWARMSIN(alpha) * 4
                                smartPos = { x, GetTerrainHeight( x, y), y }
                            else
                                smartPos = PlatoonCenterPosition
                            end
                            -- check if the move position is new or target has moved
                            if VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 then
                                -- clear move commands if we have queued more than 2
                                if SWARMGETN(unit:GetCommandQueue()) > 2 then
                                    IssueClearCommands({unit})
                                    SWARMWAIT(3)
                                end
                                -- if our target is dead, jump out of the "for _, unit in self:GetPlatoonUnits() do" loop
                                IssueMove({unit}, smartPos )
                                --unit:SetCustomName('Shield micro moving')
                                unit.smartPos = smartPos
                            else
                                --unit:SetCustomName('Shield micro CoveringPosition')
                            end

                        end
                    end
                else
                    if HERODEBUGSwarm then
                        self:RenamePlatoon('no micro target')
                        SWARMWAIT(1)
                    end
                    --LOG('* AI-Swarm: * HeroFightPlatoon: Fight micro No Target')
                    self:Stop()
                    -- break the fight loop and get new targets
                    break
                end
           end  -- fight end
        end
        if HERODEBUGSwarm then
            self:RenamePlatoon('PlatoonExists = false')
        end

        if aiBrain:PlatoonExists(self) then
            if HERODEBUGSwarm then
                self:RenamePlatoon('PlatoonDisband 5')
            end
            self:PlatoonDisband()
        end
    end,
}

--T4 Kanonenbot
--Speed 0.8
--High 12
--Impact after 18 map units

--Schüssel
--Speed 0.8
--High 25
--Impact after 26 map units

--T4 Bomber
--Speed 2.0
--High 25
--Impact after 60

--T3 Bomber
--Speed 1.6
--High 20
--Impact after 

--T2 Kanonenbot
--Speed 1.2
--High 10
--Impact after 12  map units


