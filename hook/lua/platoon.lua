--WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset platoon.lua' )

local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')



local PlatoonExists = moho.aibrain_methods.PlatoonExists
local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits
local IsUnitState = moho.unit_methods.IsUnitState
local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition
local GetBrain = moho.platoon_methods.GetBrain
local PlatoonCategoryCount = moho.platoon_methods.PlatoonCategoryCount

local SWARMCOPY = table.copy
local SWARMSORT = table.sort
local SWARMTIME = GetGameTimeSeconds
local SWARMFLOOR = math.floor
local SWARMENTITY = EntityCategoryContains
local SWARMINSERT = table.insert
local SWARMCAT = table.cat

local VDist2Sq = VDist2Sq
local VDist3 = VDist3

local ForkThread = ForkThread
local ForkTo = ForkThread

local KillThread = KillThread


SwarmPlatoonClass = Platoon
Platoon = Class(SwarmPlatoonClass) {

-- For AI Patch V8 (Patched) if eng:IsUnitState('BlockCommandQueue') then
    ProcessBuildCommand = function(eng, removeLastBuild)
        if not eng or eng.Dead or not eng.PlatoonHandle then
            return
        end
        local aiBrain = eng.PlatoonHandle:GetBrain()

        if not aiBrain or eng.Dead or not eng.EngineerBuildQueue or table.getn(eng.EngineerBuildQueue) == 0 then
            if aiBrain:PlatoonExists(eng.PlatoonHandle) then
                --LOG("* AI-DEBUG: ProcessBuildCommand: Disbanding Engineer Platoon in ProcessBuildCommand top " .. eng.Sync.id)
                if not eng.AssistSet and not eng.AssistPlatoon and not eng.UnitBeingAssist then
                    eng.PlatoonHandle:PlatoonDisband()
                end
            end
            if eng then eng.ProcessBuild = nil end
            return
        end

        -- it wasn't a failed build, so we just finished something
        if removeLastBuild then
            --LOG('* AI-DEBUG: ProcessBuildCommand: table.remove(eng.EngineerBuildQueue, 1) removeLastBuild')
            table.remove(eng.EngineerBuildQueue, 1)
        end

        eng.ProcessBuildDone = false
        IssueClearCommands({eng})
        local commandDone = false
        while not eng.Dead and not commandDone and table.getn(eng.EngineerBuildQueue) > 0  do
            local whatToBuild = eng.EngineerBuildQueue[1][1]
            local buildLocation = {eng.EngineerBuildQueue[1][2][1], 0, eng.EngineerBuildQueue[1][2][2]}
            local buildRelative = eng.EngineerBuildQueue[1][3]
            --LOG('* AI-DEBUG: ProcessBuildCommand: whatToBuild = '..repr(whatToBuild))
            if not eng.NotBuildingThread then
                eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuilding)
            end
            -- see if we can move there first
            if AIUtils.EngineerMoveWithSafePath(aiBrain, eng, buildLocation) then
                if not eng or eng.Dead or not eng.PlatoonHandle or not aiBrain:PlatoonExists(eng.PlatoonHandle) then
                    if eng then eng.ProcessBuild = nil end
                    return
                end

                -- check to see if we need to reclaim or capture...
                AIUtils.EngineerTryReclaimCaptureArea(aiBrain, eng, buildLocation)
                    -- check to see if we can repair
                AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, buildLocation)
                        -- otherwise, go ahead and build the next structure there
                aiBrain:BuildStructure(eng, whatToBuild, {buildLocation[1], buildLocation[3], 0}, buildRelative)
                if not eng.NotBuildingThread then
                    eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuilding)
                end
                commandDone = true
            else
                -- we can't move there, so remove it from our build queue
                table.remove(eng.EngineerBuildQueue, 1)
            end
        end

        -- final check for if we should disband
        if not eng or eng.Dead or table.getn(eng.EngineerBuildQueue) <= 0 then
            if eng.PlatoonHandle and aiBrain:PlatoonExists(eng.PlatoonHandle) then
                eng.PlatoonHandle:PlatoonDisband()
            end
            if eng then eng.ProcessBuild = nil end
            return
        end
        if eng then eng.ProcessBuild = nil end
    end,
-- For AI Patch V8 (Patched) fixed issue with AI cdr not building at game start
    WatchForNotBuilding = function(eng)
        coroutine.yield(10)
        local aiBrain = eng:GetAIBrain()

        while not eng.Dead and (eng.GoingHome or eng.UnitBeingBuiltBehavior or eng.ProcessBuild != nil or not eng:IsIdleState()) do
            coroutine.yield(30)
        end

        eng.NotBuildingThread = nil
        if not eng.Dead and eng:IsIdleState() and table.getn(eng.EngineerBuildQueue) != 0 and eng.PlatoonHandle then
            eng.PlatoonHandle.SetupEngineerCallbacks(eng)
            if not eng.ProcessBuild then
                eng.ProcessBuild = eng:ForkThread(eng.PlatoonHandle.ProcessBuildCommand, true)
            end
        end
    end,
    
-- Swarm Stuff: ------------------------------------------------------------------------------------

    -- Hook for Mass RepeatBuild
    PlatoonDisband = function(self)
        local aiBrain = self:GetBrain()
        if not self.Swarm then
            return SwarmPlatoonClass.PlatoonDisband(self)
        end
--        LOG('* AI-Swarm: PlatoonDisband = '..repr(self.PlatoonData.Construction.BuildStructures))
--        LOG('* AI-Swarm: PlatoonDisband = '..repr(self.PlatoonData.Construction))
        if self.PlatoonData.Construction.RepeatBuild then
--            LOG('* AI-Swarm: Repeat build = '..repr(self.PlatoonData.Construction.BuildStructures[1]))
            -- only repeat build if less then 10% of all structures are extractors
            local UCBC = import('/lua/editor/UnitCountBuildConditions.lua')
            if UCBC.HaveUnitRatioVersusCapSwarm(aiBrain, 0.10, '<', categories.STRUCTURE * categories.MASSEXTRACTION) then
                -- only repeat if we have a free mass spot
                local MABC = import('/lua/editor/MarkerBuildConditions.lua')
                if MABC.CanBuildOnMassSwarm(aiBrain, 'MAIN', 1000, -500, 1, 0, 'AntiSurface', 1) then  -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
                    self:SetAIPlan('EngineerBuildAI')
                    return
                end
            end
            -- delete the repeat flag so the engineer will not repeat on its next task
            self.PlatoonData.Construction.RepeatBuild = nil
            self:MoveToLocation(aiBrain.BuilderManagers['MAIN'].Position, false)
            return
        end
        SwarmPlatoonClass.PlatoonDisband(self)
    end,

    InterceptorAISwarm = function(self)

        AIAttackUtils.GetMostRestrictiveLayer(self) 

        local aiBrain = self:GetBrain()

        local platoonUnits = self:GetPlatoonUnits()

        local PlatoonStrength = table.getn(platoonUnits)

        local maxrange = 0	-- this will be set when a target is selected and will be used to keep the platoon from wandering too far
        local mythreat = 0
        local threatcompare = 'AntiAir'
        local mult = { 1, 1.75, 2.5 }				-- this multiplies the range of the platoon when searching for targets
	    local difficulty = { .7, 1, 1.2 }   		-- this multiplies the threat of the platoon so that easier targets are selected first
        local minrange = 0

    local rangemult, threatmult, strikerange

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
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * InterceptorAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
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
        local maxRadius = math.max(maxradius, (maxradius * aiBrain.MyAirRatio) )
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
            coroutine.yield(1)
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
                    coroutine.yield(10)
                else
                    target = nil
                end
            end
            coroutine.yield(10)
        end
    end,

    LandAttackAISwarm = function(self)
        if 1==1 then
            self:HeroFightPlatoonSwarm()
            return
        end 
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = table.getn(platoonUnits)
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
                    if EntityCategoryContains(categories.EXPERIMENTAL, v) then
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
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * LandAttackAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        -- Set the target list to all platoon units
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
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

            self.MergeWithNearbyPlatoonsSwarm( self, aiBrain, 'LandAttackAISwarm', 30, false, 40)


            local OriginalSurfaceThreat = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)
            local mystrength = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)

            if mystrength <= (OriginalSurfaceThreat * .40) then
					self.MergeIntoNearbyPlatoons( self, aiBrain, 'LandAttackAISwarm', 100, false)
					return self:SetAIPlan('ReturnToBaseAISwarm',aiBrain)
				end	

            PlatoonPos = self:GetPlatoonPosition()
            -- only get a new target and make a move command if the target is dead or after 10 seconds
            if not target or target.Dead then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRangeSwarm(aiBrain, self, 'Attack', PlatoonPos, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    losttargetnum = 0
                    self:Stop()
                    target = UnitWithPath
                    LastTargetPos = table.copy(target:GetPosition())
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
        if 1==1 then
            self:HeroFightPlatoonSwarm()
            return
        end 
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = table.getn(platoonUnits)
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
                    if EntityCategoryContains(categories.EXPERIMENTAL, v) then
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
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * NavalAttackAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        -- Set the target list to all platoon units
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
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
                    LastTargetPos = table.copy(target:GetPosition())
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
                    -- check if the target is not in a nuke blast area
                    self:SetPlatoonFormationOverride('AttackFormation')
                    self:AttackTarget(target)
                    WaitSeconds(2)
                end
            end
            WaitSeconds(1)
        end
    end,
    
    ACUAttackAISwarm = function(self)
        --LOG('* AI-Swarm: * ACUAttackAISwarm: START '..self.BuilderName)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local aiBrain = self:GetBrain()
        local PlatoonUnits = self:GetPlatoonUnits()
        local cdr = PlatoonUnits[1]
        -- There should be only the commander inside this platoon. Check it.
        if not cdr then
            WARN('* ACUAttackAISwarm: Platoon formed but Commander unit not found!')
            coroutine.yield(1)
            for k,v in self:GetPlatoonUnits() or {} do
                if EntityCategoryContains(categories.COMMAND, v) then
                    WARN('* ACUAttackAISwarm: Commander found in platoon on index: '..k)
                    cdr = v
                else
                    WARN('* ACUAttackAISwarm: Platoon unit Index '..k..' is not a commander!')
                end
            end
            if not cdr then
                self:PlatoonDisband()
                return
            end
        end
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        cdr.HealthOLD = 100
        cdr.CDRHome = aiBrain.BuilderManagers['MAIN'].Position
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * ACUAttackAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        -- prevent ACU from reclaiming while attack moving
        cdr:RemoveCommandCap('RULEUCC_Reclaim')
        cdr:RemoveCommandCap('RULEUCC_Repair')
        local TargetUnit, DistanceToTarget
        local PlatoonPos = self:GetPlatoonPosition()
        -- land and air units are assigned to mainbase
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local GetTargetsFrom = cdr.CDRHome
        local LastTargetCheck
        local DistanceToBase = 0
        local UnitsInACUBaseRange
        local ReturnToBaseAfterGameTime = self.PlatoonData.ReturnToBaseAfterGameTime or false
        local DoNotLeavePlatoonUnderHealth = self.PlatoonData.DoNotLeavePlatoonUnderHealth or 30
        local maxRadius
        local maxTimeRadius
        local SearchRadius = self.PlatoonData.SearchRadius or 250
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        while aiBrain:PlatoonExists(self) do
            if cdr.Dead then break end
            cdr.position = self:GetPlatoonPosition()
            -- leave the loop and disband this platton in time
            if ReturnToBaseAfterGameTime and ReturnToBaseAfterGameTime < GetGameTimeSeconds()/60 then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: ReturnToBaseAfterGameTime:'..ReturnToBaseAfterGameTime..' >= '..GetGameTimeSeconds()/60)
                SwarmUtils.CDRParkingHome(self,cdr)
                break
            end
            -- the maximum radis that the ACU can be away from base
            maxRadius = (SwarmUtils.ComHealth(cdr)-65)*7 -- If the comanders health is 100% then we have a maxtange of ~250 = (100-65)*7
            maxTimeRadius = 240 - GetGameTimeSeconds()/60*6 -- reduce the radius by 6 map units per minute. After 30 minutes it's (240-180) = 60
            if maxRadius > maxTimeRadius then 
                maxRadius = math.max( 60, maxTimeRadius ) -- IF maxTimeRadius < 60 THEN maxTimeRadius = 60
            end
            if maxRadius > SearchRadius then
                maxRadius = SearchRadius
            end
            UnitsInACUBaseRange = aiBrain:GetUnitsAroundPoint( TargetSearchCategory, cdr.CDRHome, maxRadius, 'Enemy')
            -- get the position of this platoon (ACU)
            if not GetTargetsFromBase then
                -- we don't get out targets relativ to base position. Use the ACU position
                GetTargetsFrom = cdr.position
            end
            ----------------------------------------------
            --- This is the start of the main ACU loop ---
            ----------------------------------------------
            if aiBrain:GetEconomyStoredRatio('ENERGY') > 0.95 and SwarmUtils.ComHealth(cdr) < 100 then
                cdr:SetAutoOvercharge(true)
            else
                cdr:SetAutoOvercharge(false)
            end
           
            -- in case we have no Factory left, recover!
            if not aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY, false)[1] then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: exiting attack function. RECOVER')
                self:PlatoonDisband()
                return
            -- check if we are further away from base then the closest enemy
            elseif SwarmUtils.CDRRunHomeEnemyNearBase(self,cdr,UnitsInACUBaseRange) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: CDRRunHomeEnemyNearBase')
                TargetUnit = false
            -- check if we get actual damage, then move home
            elseif SwarmUtils.CDRRunHomeAtDamage(self,cdr) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: CDRRunHomeAtDamage')
                TargetUnit = false
            -- check how much % health we have and go closer to our base
            elseif SwarmUtils.CDRRunHomeHealthRange(self,cdr,maxRadius) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: CDRRunHomeHealthRange')
                TargetUnit = false
            -- can we upgrade ?
            elseif table.getn(UnitsInACUBaseRange) <= 0 and VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) < 60 and self:BuildACUEnhancementsSwarm(cdr) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancementsSwarm')
                -- Do nothing if BuildACUEnhancementsSwarm is true. we are upgrading!
            -- only get a new target and make a move command if the target is dead
            else
               --LOG('* AI-Swarm: * ACUAttackAISwarm: ATTACK')
                -- ToDo: scann for enemy COM and change target if needed
                TargetUnit, _, _, _ = AIUtils.AIFindNearestCategoryTargetInRangeSwarmCDRSwarm(aiBrain, GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false)
                -- if we have a target, move to the target and attack
                if TargetUnit then
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: ATTACK TargetUnit')
                    if aiBrain:PlatoonExists(self) and TargetUnit and not TargetUnit.Dead and not TargetUnit:BeenDestroyed() then
                        local targetPos = TargetUnit:GetPosition()
                        local cdrNewPos = {}
                        cdr:GetNavigator():AbortMove()
                        cdrNewPos[1] = targetPos[1] + Random(-3, 3)
                        cdrNewPos[2] = targetPos[2]
                        cdrNewPos[3] = targetPos[3] + Random(-3, 3)
                        self:MoveToLocation(cdrNewPos, false)
                        coroutine.yield(1)
                        if TargetUnit and not TargetUnit.Dead and not TargetUnit:BeenDestroyed() then
                            self:AttackTarget(TargetUnit)
                        end
                    end
                -- if we have no target, move to base. If we are at base, dance. (random moves)
                elseif SwarmUtils.CDRForceRunHome(self,cdr) then
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: CDRForceRunHome true. we are running home')
                -- we are at home, dance if we have nothing to do.
                else
                    -- There is nothing to fight; so we left the attack function and see if we can build something
                    --LOG('* AI-Swarm: * ACUAttackAISwarm:We are at home and dancing')
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: exiting attack function')
                    self:PlatoonDisband()
                    return
                end
            end
            --DrawCircle(cdr.CDRHome, maxRadius, '00FFFF')
            coroutine.yield(10)
            --------------------------------------------
            --- This is the end of the main ACU loop ---
            --------------------------------------------
        end
        --LOG('* AI-Swarm: * ACUAttackAISwarm: END '..self.BuilderName)
        self:PlatoonDisband()
    end,
    
    BuildACUEnhancementsSwarm = function(platoon,cdr)
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
            ['xnl0001'] = {'Capacitor', 'GunUpgrade', 'MovementSpeedIncrease', 'DoubleGuns'},

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
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancementsSwarm: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgradeSwarm(cdr, wantedEnhancementBP) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancementsSwarm: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --LOG('* AI-Swarm: * ACUAttackAISwarm: *** Set as Enhancememnt: '..NextEnhancement)
                end
            else
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancementsSwarm: Eco is bad for '..enhancement)
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
            --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancementsSwarm Building '..NextEnhancement)
            if platoon:BuildEnhancementSwarm(cdr, NextEnhancement) then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancementsSwarm returned true'..NextEnhancement)
                return true
            else
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildACUEnhancementsSwarm returned false'..NextEnhancement)
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
        --LOG('* AI-Swarm: cdr:GetBuildRate() '..BuildRate..'')
        local drainMass = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostMass
        local drainEnergy = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostEnergy
        --LOG('* AI-Swarm: drain: m'..drainMass..'  e'..drainEnergy..'')
        --LOG('* AI-Swarm: Pump: m'..math.floor(aiBrain:GetEconomyTrend('MASS')*10)..'  e'..math.floor(aiBrain:GetEconomyTrend('ENERGY')*10)..'')
        if aiBrain.HasParagon then
            return true
        elseif aiBrain:GetEconomyTrend('MASS')*10 >= drainMass and aiBrain:GetEconomyTrend('ENERGY')*10 >= drainEnergy
        and aiBrain:GetEconomyStoredRatio('MASS') > 0.05 and aiBrain:GetEconomyStoredRatio('ENERGY') > 0.95 then
            return true
        end
        return false
    end,
    
    BuildEnhancementSwarm = function(platoon,cdr,enhancement)
        --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildEnhancementSwarm '..enhancement)
        local aiBrain = platoon:GetBrain()

        IssueStop({cdr})
        IssueClearCommands({cdr})
        
        if not cdr:HasEnhancement(enhancement) then
            
            local tempEnhanceBp = cdr:GetBlueprint().Enhancements[enhancement]
            local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(cdr.EntityId)
            -- Do we have already a enhancment in this slot ?
            if unitEnhancements[tempEnhanceBp.Slot] and unitEnhancements[tempEnhanceBp.Slot] ~= tempEnhanceBp.Prerequisite then
                -- remove the enhancement
                --LOG('* AI-Swarm: * ACUAttackAISwarm: Found enhancement ['..unitEnhancements[tempEnhanceBp.Slot]..'] in Slot ['..tempEnhanceBp.Slot..']. - Removing...')
                local order = { TaskName = "EnhanceTask", Enhancement = unitEnhancements[tempEnhanceBp.Slot]..'Remove' }
                IssueScript({cdr}, order)
                coroutine.yield(10)
            end
            --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildEnhancementSwarm: '..platoon:GetBrain().Nickname..' IssueScript: '..enhancement)
            local order = { TaskName = "EnhanceTask", Enhancement = enhancement }
            IssueScript({cdr}, order)
        end
        while not cdr.Dead and not cdr:HasEnhancement(enhancement) do
            if SwarmUtils.ComHealth(cdr) < 60 then
                --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildEnhancementSwarm: '..platoon:GetBrain().Nickname..' Emergency!!! low health, canceling Enhancement '..enhancement)
                IssueStop({cdr})
                IssueClearCommands({cdr})
                return false
            end
            coroutine.yield(10)
        end
        --LOG('* AI-Swarm: * ACUAttackAISwarm: BuildEnhancementSwarm: '..platoon:GetBrain().Nickname..' Upgrade finished '..enhancement)
        return true
    end,

    MoveWithTransportSwarm = function(self, aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
        local TargetPosition = table.copy(target:GetPosition())
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
        local TargetPosition = table.copy(target:GetPosition())
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
            if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
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
            coroutine.yield(10)
        end
    end,

    MovePathSwarm = function(self, aiBrain, path, bAggroMove, target)
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local AirCUT = 0
        if self.MovementLayer == 'Air' then
            AirCUT = 3
        end
        local PathNodesCount = table.getn(path)
        local ATTACKFORMATION = false
        for i=1, PathNodesCount - AirCUT do
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
            while aiBrain:PlatoonExists(self) do
                PlatoonPosition = self:GetPlatoonPosition() or path[i]
                dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                local platoonUnitscheck = self:GetPlatoonUnits()
                if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
                    --LOG('* AI-Swarm: * MovePathSwarm: unit in platoon destroyed!!!')
                    self:SetPlatoonFormationOverride('AttackFormation')
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
                        --LOG('* AI-Swarm: * MovePathSwarm: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                        self:Stop()
                        break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                    end
                end
                -- If we lose our target, stop moving to it.
                if not target or target.Dead then
                    --LOG('* AI-Swarm: * MovePathSwarm: Lost target while moving to Waypoint. '..repr(path[i]))
                    return
                end
                coroutine.yield(10)
            end
        end
    end,

    MoveToLocationInclTransportSwarm = function(self, target, TargetPosition, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon)
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        if not TargetPosition then
            TargetPosition = table.copy(target:GetPosition())
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
                if table.getn(path) > 1 then
                    --LOG('* AI-Swarm: * MoveToLocationInclTransportSwarm: table.getn(path): '..table.getn(path))
                end
                local PathNodesCount = table.getn(path)
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
                        if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
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
                        coroutine.yield(10)
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
                            coroutine.yield(10)
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
            if not v.Dead and EntityCategoryContains(categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD, v) then
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
            if FractionComplete < 1 and table.getn(v:GetGuards()) < 1 then
                self:Stop()
                IssueRepair(self:GetPlatoonUnits(), v)
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
        -- Disband this platoon, it's no longer needed.
        self:PlatoonDisbandNoAssign()
    end,

    ExtractorUpgradeAISwarm = function(self)
        --LOG('* AI-Swarm: +++ ExtractorUpgradeAISwarm: START')
        local aiBrain = self:GetBrain()
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        while aiBrain:PlatoonExists(self) do
            local ratio = 0.10
            if aiBrain.HasParagon then
                -- if we have a paragon, upgrade mex as fast as possible. Mabye we lose the paragon and need mex again.
                ratio = 1.0
            elseif aiBrain:GetEconomyIncome('MASS') > 500 then
                --LOG('* AI-Swarm: Mass over 500. Eco running with 50%')
                ratio = 0.50
            elseif GetGameTimeSeconds() > 1800 then -- 30 * 60
                ratio = 0.35
            elseif GetGameTimeSeconds() > 1200 then -- 20 * 60
                ratio = 0.25
            elseif GetGameTimeSeconds() > 900 then -- 15 * 60
                ratio = 0.20
            elseif GetGameTimeSeconds() > 600 then -- 10 * 60
                ratio = 0.15
            elseif GetGameTimeSeconds() > 300 then -- 5 * 60
                ratio = 0.10
            elseif GetGameTimeSeconds() <= 300 then -- 5 * 50 run the first 5 minutes with 0% Eco and 100% Army
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
            coroutine.yield(10)
            -- find dead units inside the platoon and disband if we find one
            for k,v in self:GetPlatoonUnits() do
                if not v or v.Dead or v:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    --LOG('* AI-Swarm: +++ ExtractorUpgradeAISwarm: Found Dead unit, self:PlatoonDisbandNoAssign()')
                    -- needs PlatoonDisbandNoAssign, or extractors will stop upgrading if the platton is disbanded
                    coroutine.yield(1)
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
            coroutine.yield(10)
        end
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
        coroutine.yield(30)
        self:PlatoonDisband()
    end,

    ForceReturnToNavalBaseAISwarm = function(self, aiBrain, basePosition)
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Water' , self:GetPlatoonPosition(), basePosition, 1000, 512)
        -- clear commands, so we don't get stuck if we have an unreachable destination
        IssueClearCommands(self:GetPlatoonUnits())
        if path then
            if table.getn(path) > 1 then
                --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: table.getn(path): '..table.getn(path))
            end
            --LOG('* AI-Swarm: * ForceReturnToNavalBaseAISwarm: moving to destination by path.')
            for i=1, table.getn(path) do
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
                    coroutine.yield(10)
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
        coroutine.yield(30)
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
            coroutine.yield(50)
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
                            coroutine.yield(1)
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
            coroutine.yield(100)
            NukeLaunched = false
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
                    table.insert(LauncherFull, Launcher)
                end
                if NukeSiloAmmoCount > 0 and EntityCategoryContains(categories.NUKE * categories.EXPERIMENTAL, Launcher) then
                    table.insert(ExperimentalLauncherReady, Launcher)
                    MissileCount = MissileCount + NukeSiloAmmoCount
                elseif NukeSiloAmmoCount > 0 then
                    table.insert(LauncherReady, Launcher)
                    MissileCount = MissileCount + NukeSiloAmmoCount
                end
                LauncherCount = LauncherCount + 1
                -- count experimental launcher seraphim
            end
            EnemyAntiMissile = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * ((categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL)), Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            if NUKEDEBUG then
                LOG('* AI-Swarm: ************************************************************************************************')
                LOG('* AI-Swarm: * NukePlatoonAISwarm: Checking for Targets. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - EnemyAntiMissile:('..table.getn(EnemyAntiMissile)..')')
            end
            -- Don't check all nuke functions if we have no missile.
            if LauncherCount < 1 or ( table.getn(LauncherReady) < 1 and table.getn(LauncherFull) < 1 ) then
                continue
            end
            ---------------------------------------------------------------------------------------------------
            -- PrimaryTarget, launch a single nuke on primary targets.
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) Experimental PrimaryTarget ')
            end
            if 1 == 1 and aiBrain.PrimaryTarget and table.getn(LauncherReady) > 0 and EntityCategoryContains(categories.EXPERIMENTAL, aiBrain.PrimaryTarget) then
                -- Only shoot if the target is not protected by antimissile or experimental shields
                if not self:IsTargetNukeProtectedSwarm(aiBrain.PrimaryTarget, EnemyAntiMissile) then
                    -- Lead target function
                    TargetPos = self:LeadNukeTargetSwarm(aiBrain.PrimaryTarget)
                    if not TargetPos then
                        -- Our Target is dead. break
                        break
                    end
                    -- Only shoot if we are not damaging our own structures
                    if aiBrain:GetNumUnitsAroundPoint(categories.STRUCTURE, TargetPos, 50 , 'Ally') <= 0 then
                        if not self:NukeSingleAttackSwarm(HighMissileCountLauncherReady, TargetPos) then
                            if self:NukeSingleAttackSwarm(LauncherReady, TargetPos) then
                                if NUKEDEBUG then
                                    LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) Experimental PrimaryTarget FIRE LauncherReady!')
                                end
                                NukeLaunched = true
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
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) EnemyUnits. Checking enemy units: '..table.getn(EnemyUnits))
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
                    table.insert(EnemyTargetPositions, EnemyTargetPos)
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have unprotected targets, shot at it
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Unprotected) EnemyUnits: Unprotected enemy units: '..table.getn(EnemyTargetPositions))
            end
            if 1 == 1 and table.getn(EnemyTargetPositions) > 0 and table.getn(LauncherReady) > 0 then
                -- loopß over all targets
                self:NukeJerichoAttackSwarm(LauncherReady, EnemyTargetPositions, false)
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
            if 1 == 1 and MissileCount > 8 and table.getn(EnemyAntiMissile) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: (Overwhelm) MissileCount, EnemyAntiMissile  [ '..MissileCount..', '..table.getn(EnemyAntiMissile)..' ]')
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
                    EnemyProtectorsNum = table.getn(ProtectorUnits)
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
                table.insert(EnemyTargetPositions, EnemyTargetPos)
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have more launchers ready then targets start Jericho bombardment
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Jericho) Checking for Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - Enemy Targets:('..table.getn(EnemyTargetPositions)..')')
            end
            if 1 == 1 and table.getn(LauncherReady) >= table.getn(EnemyTargetPositions) and table.getn(EnemyTargetPositions) > 0 and table.getn(LauncherFull) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: Jericho!')
                end
                -- loopß over all targets
                self:NukeJerichoAttackSwarm(LauncherReady, EnemyTargetPositions, false)
                NukeLaunched = true
            end
            ---------------------------------------------------------------------------------------------------
            -- If we have an launcher with 5 missiles fire one.
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Checking for Full Launchers. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..')')
            end
            if 1 == 1 and table.getn(LauncherFull) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) - Launcher is full!')
                end
                EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.EXPERIMENTAL, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                if table.getn(EnemyUnits) > 0 then
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Experimental Buildings: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.TECH3 , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy TECH3 Buildings: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.MOBILE * categories.EXPERIMENTAL - categories.AIR, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Experimental Units: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Buildings: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.MOBILE - categories.AIR, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Enemy Mobile Units: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) > 0 then
                    if NUKEDEBUG then
                        LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) MissileCount ('..MissileCount..') > EnemyUnits ('..table.getn(EnemyUnits)..')')
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
                        table.insert(EnemyTargetPositions, EnemyTargetPos)
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have targets, shot at it
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: (Launcher Full) Attack only with full Launchers. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - Enemy Targets:('..table.getn(EnemyTargetPositions)..')')
            end
            if 1 == 1 and table.getn(EnemyTargetPositions) > 0 and table.getn(LauncherFull) > 0 then
                self:NukeJerichoAttackSwarm(LauncherFull, EnemyTargetPositions, true)
                NukeLaunched = true
            end
            if NUKEDEBUG then
                LOG('* AI-Swarm: * NukePlatoonAISwarm: END. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:'..table.getn(LauncherFull)..' - Missiles:('..MissileCount..')')
            end
            if NukeLaunched == true then
                --LOG('* AI-Swarm: Fired nuke(s), waiting...')
                coroutine.yield(450)-- wait 45 seconds for the missile flight, then get new targets
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
            coroutine.yield(10)
            -- 2nd position of target after 1 second
            TargetPos = target:GetPosition()
            Target1SecPos = {TargetPos[1], 0, TargetPos[3]}
            XmovePerSec = (TargetStartPosition[1] - Target1SecPos[1])
            YmovePerSec = (TargetStartPosition[3] - Target1SecPos[3])
            coroutine.yield(10)
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
        --LOG('* AI-Swarm: ** NukeSingleAttackSwarm: Launcher count: '..table.getn(Launchers))
        if table.getn(Launchers) <= 0 then
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

    NukeJerichoAttackSwarm = function(self, Launchers, EnemyTargetPositions, LaunchAll)
        --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: Launcher: '..table.getn(Launchers))
        if table.getn(Launchers) <= 0 then
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
                    self:PlatoonDisbandNoAssign()
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
            --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: Launcher after shoot: '..table.getn(Launchers))
            if table.getn(Launchers) < 1 then
                --LOG('* AI-Swarm: * NukeJerichoAttackSwarm: All Launchers are bussy! Break!')
                -- stop seraching for targets, we don't hava a launcher ready.
                break -- for _, ActualTargetPos in EnemyTargetPositions do
            end
        end
        if table.getn(Launchers) > 0 and LaunchAll == true then
            self:NukeJerichoAttackSwarm(Launchers, EnemyTargetPositions, true)
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
        coroutine.yield(50)
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
                coroutine.yield(1)
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
                    coroutine.yield(1)
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
            coroutine.yield(50)
        end
        --
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Swarm: * SACUTeleportAISwarm: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
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
            coroutine.yield(50)
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
                    coroutine.yield(2)
                    IssueTeleport({unit}, SwarmUtils.RandomizePosition(TargetPosition))
                end
            end
        else
            --LOG('* AI-Swarm: SACUTeleportAISwarm: No target, disbanding platoon!')
            self:PlatoonDisband()
            return
        end
        coroutine.yield(30)
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
            coroutine.yield(10)
        end        
        -- Fight
        coroutine.yield(1)
        for k, unit in platoonUnits do
            if not unit.Dead then
                IssueStop({unit})
                coroutine.yield(2)
                IssueMove({unit}, TargetPosition)
            end
        end
        coroutine.yield(50)
        self:LandAttackAISwarm()
        self:PlatoonDisband()
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
            if EntityCategoryContains(categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM, v) then
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
            aiBrain:BuildScoutLocations()
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

                elseif table.getn(unknownThreats) > 0 and unknownThreats[1][3] > 25 then
                    aiBrain:AddScoutArea({unknownThreats[1][1], 0, unknownThreats[1][2]})

                elseif aiBrain.IntelData.AirHiPriScouts < aiBrain.NumOpponents and aiBrain.IntelData.AirLowPriScouts < 1
                and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                    aiBrain.IntelData.AirHiPriScouts = aiBrain.IntelData.AirHiPriScouts + 1

                    highPri = true

                    targetData = aiBrain.InterestList.HighPriority[1]
                    targetData.LastScouted = GetGameTimeSeconds()
                    targetArea = targetData.Position

                    aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)


                elseif aiBrain.IntelData.AirLowPriScouts < 1 and table.getn(aiBrain.InterestList.LowPriority) > 0 then
                    aiBrain.IntelData.AirHiPriScouts = 0
                    aiBrain.IntelData.AirLowPriScouts = aiBrain.IntelData.AirLowPriScouts + 1

                    targetData = aiBrain.InterestList.LowPriority[1]
                    targetData.LastScouted = GetGameTimeSeconds()
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

                        coroutine.yield(50)
                    end
                else
                    coroutine.yield(10)
                end
                coroutine.yield(1)
            end
        end
    end,

    LandScoutingAISwarm = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self)

        local aiBrain = self:GetBrain()
        local scout = self:GetPlatoonUnits()[1]


        if not aiBrain.InterestList then
            aiBrain:BuildScoutLocations()
        end


        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:SetScriptBit('RULEUTC_CloakToggle', false)
        end

        while not scout.Dead do

            local targetData = false


            if aiBrain.IntelData.HiPriScouts < aiBrain.NumOpponents and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                targetData = aiBrain.InterestList.HighPriority[1]
                aiBrain.IntelData.HiPriScouts = aiBrain.IntelData.HiPriScouts + 1
                targetData.LastScouted = GetGameTimeSeconds()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)

            elseif table.getn(aiBrain.InterestList.LowPriority) > 0 then
                targetData = aiBrain.InterestList.LowPriority[1]
                aiBrain.IntelData.HiPriScouts = 0
                targetData.LastScouted = GetGameTimeSeconds()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            else

                aiBrain.IntelData.HiPriScouts = 0
            end


            if targetData then

                local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, scout:GetPosition(), targetData.Position, 400) --DUNCAN - Increase threatwieght from 100

                IssueClearCommands(self)

                if path then
                    local pathLength = table.getn(path)
                    for i=1, pathLength-1 do
                        self:MoveToLocation(path[i], false)
                    end
                end

                self:MoveToLocation(targetData.Position, false)


                while not scout.Dead and not scout:IsIdleState() do
                    coroutine.yield(25)
                end
            end

            coroutine.yield(10)
        end
    end,

    -- Function: MergeWithNearbyPlatoons
    --    self - the single platoon to run the AI on
    --    planName - AI plan to merge with
    --    radius - merge with platoons in this radius 
    --    planmatchrequired     - if true merge platoons only with same builder name AND the same plan
    --                          - if false then merging will be done with all platoons using same plan
    --    mergelimit - if set, the merge can only be taken upto that size
    --
    -- Finds platoon nearby (when self platoon is not near a base) and merge with them if they're a good fit.
    --      Dont allow smaller platoons to merge larger platoons into themselves
    --   Returns:  
    --       nil if no merge was done, true if a merge was done
    
    -- NOTE: The platoon executing this function will 'grab' units
    --      from the allied platoons - so in effect, it's reinforcing itself

    -- 90% of This Work is from Sprouto

    MergeWithNearbyPlatoonsSwarm = function( self, aiBrain, planName, radius, planmatchrequired, mergelimit )

        if self.UsingTransport then
        
            return false
            
        end
        
        if not PlatoonExists(aiBrain,self) then
        
            return false
            
        end

        local platoonUnits = GetPlatoonUnits(self)
        local platooncount = 0

        for _,v in platoonUnits do
        
            if not v.Dead then
            
                platooncount = platooncount + 1
                
            end
            
        end

        if (mergelimit and platooncount > mergelimit) or platooncount < 1 then
        
            return false
            
        end
        
        local platPos = SWARMCOPY(GetPlatoonPosition(self))
        local radiusSq = radius*radius  -- maximum range to check allied platoons --

        -- we cant be within 1/3 that range to our own base --
--[[
        for _, base in aiBrain.BuilderManagers do
        
            if VDist2Sq( platPos[1],platPos[3], base.Position[1],base.Position[3] ) <= ( radiusSq / 3 ) then
            
                return false
                
            end 
            
        end
--]]

        -- get a list of all the platoons for this brain
        local GetPlatoonsList = moho.aibrain_methods.GetPlatoonsList
        local AlliedPlatoons = SWARMCOPY(GetPlatoonsList(aiBrain))
        
        SWARMSORT(AlliedPlatoons, function(a,b) return VDist2Sq(GetPlatoonPosition(a)[1],GetPlatoonPosition(a)[3], platPos[1],platPos[3]) < VDist2Sq(GetPlatoonPosition(b)[1],GetPlatoonPosition(b)[3], platPos[1],platPos[3]) end)
        
        local mergedunits = false
        local allyPlatoonSize, validUnits, counter = 0
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." checking MERGE WITH for "..repr(table.getn(AlliedPlatoons)))
        
        local count = 0
        
        -- loop thru all the platoons in the list
        for _,aPlat in AlliedPlatoons do
    
            -- ignore yourself
            if aPlat == self then
                continue
            end
        
            count = count + 1

            -- if allied platoon is busy (not necessarily transports - this is really a general 'busy' flag --
            if aPlat.UsingTransport then
            
                continue
                
            end
            
            -- not only the plan must match but the buildername as well
            if planmatchrequired and aPlat.BuilderName != self.BuilderName then
            
                continue
                
            end
            
            -- otherwise it must a least have the same plan
            if aPlat.PlanName != planName then
            
                continue
                
            end
            
            -- and be on the same movement layer
            if self.MovementLayer != aPlat.MovementLayer then
            
                continue
                
            end
            
            -- check distance of allied platoon -- as soon as we hit one farther away then we're done
            if VDist2Sq(platPos[1],platPos[3], GetPlatoonPosition(aPlat)[1],GetPlatoonPosition(aPlat)[3]) > radiusSq then
            
                break
                
            end
            
            -- get the allied platoons size
            allyPlatoonSize = 0
            
            -- mark the allied platoon as being busy
            aPlat.UsingTransport = true
            
            local aPlatUnits = GetPlatoonUnits(aPlat)
            
            validUnits = {}
            counter = 0
            
            -- count and check validity of allied units
            for _,u in aPlatUnits do
            
                if not u.Dead then
                
                    allyPlatoonSize = allyPlatoonSize + 1

                    if not IsUnitState(u,'Attached' )then
                
                        -- if we have space in our platoon --
                        if (counter + platooncount) <= mergelimit then
                        
                            validUnits[counter+1] = u
                            counter = counter + 1
                            
                        end
                        
                    end
                    
                end
                
            end

            -- if no valid units or we are smaller than the allied platoon then dont allow
            if counter < 1 or platooncount < allyPlatoonSize or allyPlatoonSize == 0 then
            
                continue
                
            end

            -- otherwise we do the merge
            if ScenarioInfo.PlatoonMergeDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." MERGE_WITH "..repr(self.BuilderName).." takes "..counter.." units from "..aPlat.BuilderName.." now has "..platooncount+counter)
            end
            
            -- unmark the allied platoon
            aPlat.UsingTransport = false
            
            -- assign the valid units to us - this may end the allied platoon --
            AssignUnitsToPlatoon( aiBrain, self, validUnits, 'Attack', 'none' )
            
            -- add the new units to our count --
            platooncount = platooncount + counter
            
            -- flag that we did a merge --
            mergedunits = true
            
        end

        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." checked "..count.." platoons")
        return mergedunits
        
    end,

    ReturnToBaseAISwarm = function( self, aiBrain )
	
		-- since RTB always deals with MOBILE units we use the Entity based GetPosition
		local GetPosition = moho.entity_methods.GetPosition
		local GetCommandQueue = moho.unit_methods.GetCommandQueue
		
		local VDist3 = VDist3
		local VDist2 = VDist2
		
		if not aiBrain then
		
			aiBrain = GetBrain(self)
			
		end

		if self == aiBrain.ArmyPool or not PlatoonExists(aiBrain, self) then
		
			WARN("*AI DEBUG ArmyPool or nil in RTB")
			return
			
		end
		
		if self.DistressResponseAIRunning then
		
			self.DistressResponseAIRunning = false
			
		end

		if self.MoveThread then

			self:KillMoveThread()
			
		end
		
		if not self.MovementLayer then
		
			GetMostRestrictiveLayer(self)
			
		end
		
		-- assume platoon is dead 
		local platoonDead = true

		-- set the desired RTBLocation (specified base, source base or false)
        local RTBLocation = self.RTBLocation or self.LocationType or false

		-- flag for experimentals (no air transports)
		local experimental = PlatoonCategoryCount(self, categories.EXPERIMENTAL) > 0
		
		-- assume no engineer in platoon
		local engineer = false

		-- process the units to identify engineers and the CDR
		-- and to determine which base to RTB to
		for k,v in GetPlatoonUnits(self) do
		
			-- set the 'platoonDead' to false
			if not v.Dead then
			
				platoonDead = false
                
				-- set the 'engineer' flag
				if SWARMENTITY( categories.ENGINEER, v ) then
				
					engineer = v

					-- Engineer naming
                    if v.BuilderName and ScenarioInfo.NameEngineers then
					
						if not SWARMENTITY( categories.COMMAND, v ) then
						
							v:SetCustomName("Eng "..v.Sync.id.." RTB from "..v.BuilderName.." to "..v.LocationType )
							
						end
						
                    end
					
					-- force CDR to disband - he never leaves home
	                if SWARMENTITY( categories.COMMAND, v ) then
					
						self:PlatoonDisband( aiBrain )
						return
						
					end
					
					RTBLocation = v.LocationType
					
				end
				
				-- if no platoon RTBLocation then force one
				if not RTBLocation or RTBLocation == "Any" then
				
					-- if the unit has a LocationType and it exists -- we might use that for the platoon
					if v.LocationType then
					
						if RTBLocation != "Any" and aiBrain.BuilderManagers[v.LocationType].EngineerManager.Active then
						
							self.LocationType = v.LocationType
							RTBLocation = v.LocationType
							
						else
						
							-- find the closest manager 
							if self.MovementLayer == "Land" then
							
								-- dont use naval bases for land --
								LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." seeks ONLY Land Bases")
								
								self.LocationType = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(self), false, false )
								RTBLocation = self.LocationType
								
							else
							
								if self.MovementLayer == "Air" or self.MovementLayer == "Amphibious" then
								
									-- use any kind of base --
									self.LocationType = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(self), true, false )
									RTBLocation = self.LocationType
									
								else
								
									-- use only naval bases for 'Sea' platoons
									LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.Buildername).." seeks ONLY Naval bases")
									
									self.LocationType = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(self), true, true )
									RTBLocation = self.LocationType
									
								end
								
							end
							
							LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." using RTBLocation "..repr(RTBLocation))
							
						end
						
					end
					
				end
				
				-- default attached processing (something is not doing this properly)
				if v:IsUnitState('Attached') then
				
					v:DetachFrom()
					v:SetCanTakeDamage(true)
					v:SetDoNotTarget(false)
					v:SetReclaimable(true)
					v:SetCapturable(true)
					v:ShowBone(0, true)
					v:MarkWeaponsOnTransport(v, false)
					
				end
				
			end
			
        end

		-- exit if no units --
		if platoonDead then
		
            return 
			
		end
		
		if ScenarioInfo.PlatoonDialog then
			LOG("*AI DEBUG Platoon "..aiBrain.Nickname.." "..repr(self.BuilderName).." begins RTB to "..repr(RTBLocation) )
		end
		
       	IssueClearCommands( GetPlatoonUnits(self) )
        
        local platPos = SWARMCOPY(GetPlatoonPosition(self))
		local lastpos = SWARMCOPY(GetPlatoonPosition(self))
        
		local transportLocation = false	
        local baseName, base
        local bestBase = false
        local bestBaseName = ""
        local bestDistance = 99999999
		local distance = 0
		
		local bases = aiBrain.BuilderManagers
		
		-- confirm RTB location exists or pick closest
		if bases and platPos then
		
			-- if specified base exists and is active - use it
			-- otherwise locate nearest suitable base as RTBLocation
			if RTBLocation and bases[RTBLocation].EngineerManager.Active then
				
				bestBase = bases[RTBLocation]
				bestBaseName = RTBLocation
                RTBLocation = bestBase.Position
			
			else
				
				RTBLocation = 'Any'
				
				-- loop thru all existing 'active' bases and use the closest suitable base --
				-- if no base -- use 'MAIN' --
				for baseName, base in bases do
				
					-- if the base is active --
					if base.EngineerManager.Active then
					
						-- record distance to base
						distance = VDist2Sq( platPos[1],platPos[3], base.Position[1],base.Position[3] )                
				
						-- is this base suitable for this platoon 
						if (distance < bestDistance) and ( (RTBLocation == 'Any') or (not engineer and not RTBLocation) ) then
                
							-- dont allow RTB to Naval Bases for Land --
							-- and dont allow RTB to anything BUT Naval for Water
							if (self.MovementLayer == 'Land' and base.BaseType == "Sea") or
							   (self.MovementLayer == 'Water' and base.BaseType != "Sea") then
							   
								continue
						
							else
							
								bestBase = base
								bestBaseName = baseName
								RTBLocation = bestBase.Position
								bestDistance = distance    
								
							end
							
						end
						
					end
					
				end
            
				if not bestBase then
			
					LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..repr(self.BuilderName).." Couldn't find base "..repr(RTBLocation).." - using MAIN")
				
					bestBase = aiBrain.BuilderManagers['MAIN']
					bestBaseName = 'MAIN'
					RTBLocation = bestBase.Position
					
				end
				
			end

			-- set transportlocation - engineers always use base centre	
			if bestBase.Position then
			
				transportLocation = table.copy(bestBase.Position)
				
			else
				
				LOG("*AI DEBUG "..aiBrain.Nickname.." RTB cant locate a bestBase")
				
				return self:PlatoonDisband(aiBrain)
				
			end
			
			-- others will seek closest rally point of that base
			if not engineer then
			
				-- use the base generated rally points
				local rallypoints = table.copy(bestBase.RallyPoints)
				
				-- sort the rallypoints for closest to the platoon --
				SWARMSORT( rallypoints, function(a,b) return VDist2Sq( a[1],a[3], platPos[1],platPos[3] ) < VDist2Sq( b[1],b[3], platPos[1],platPos[3] ) end )

				transportLocation = table.copy(rallypoints[1])
				
				-- if cannot find rally marker - use base centre
				if not transportLocation then
				
					transportLocation = table.copy(bestBase.Position)
					
				end
				
			end

            RTBLocation[2] = GetTerrainHeight( RTBLocation[1], RTBLocation[3] )
			transportLocation[2] = GetTerrainHeight(transportLocation[1],transportLocation[3])
		
		else
		
            LOG("*AI DEBUG "..aiBrain.Nickname.." RTB reports no platoon position or no bases")
			
			return self:PlatoonDisband(aiBrain)
			
        end

		
		distance = VDist2Sq( platPos[1],platPos[3], RTBLocation[1],RTBLocation[3] )

		-- Move the platoon to the transportLocation either by ground, transport or teleportation (engineers only)
		-- NOTE: distance is calculated above - it's always distance from the base (RTBLocation) - not from the transport location - 
        -- NOTE: When the platoon is within 75 of the base we just bypass this code
        if platPos and transportLocation and distance > (60*60) then
        
            local mythreat = self:CalculatePlatoonThreat('Overall', categories.ALLUNITS)
            
            if mythreat < 10 then
			
				mythreat = 10
				
            end
			
			-- set marker radius for path finding
			local markerradius = 150
			
			if self.MovementLayer == 'Air' or self.MovementLayer == 'Water' then
			
				markerradius = 200
				
			end
			
            -- we use normal threat first
            local path, reason = self.PlatoonGenerateSafePathToSwarm( aiBrain, self, self.MovementLayer, platPos, transportLocation, mythreat, markerradius )
			
			-- then we'll try elevated threat
			if not path then
			-- we use an elevated threat value to help insure that we'll get a path
				path, reason = self.PlatoonGenerateSafePathToSwarm( aiBrain, self, self.MovementLayer, platPos, transportLocation, mythreat * 3, markerradius )
			end
            
			-- engineer teleportation
			if engineer and engineer:HasEnhancement('Teleporter') then
			
				path = {transportLocation}
				distance = 1
				IssueTeleport( {engineer}, transportLocation )
				
			end

			-- if there is no path try transport call
			if (not path) and PlatoonExists(aiBrain, self) then
            
				local usedTransports = false
				
				-- try to use transports --
				if (self.MovementLayer == 'Land' or self.MovementLayer == 'Amphibious') and not experimental then
				
					usedTransports = self:SendPlatoonWithTransportsSwarm( aiBrain, transportLocation, 4, false )
					
				end
				
				-- if no transport reply resubmit LAND platoons, others will set a direct path
				if not usedTransports and PlatoonExists(aiBrain,self) then
				
					if self.MovementLayer == 'Land' then

                        --LOG("*AI DEBUG "..aiBrain.Nickname.." No path "..reason.." and no transport during RTB to "..repr(RTBLocation).." - reissuing RTB for "..repr(self.BuilderName).." lifetime stats "..repr( self:GetPlatoonLifetimeStats() ).." Creation Time was "..repr(self.CreationTime).." Currently "..repr(LOUDTIME()))
						
						coroutine.yield(35)
						
						return self:SetAIPlan('ReturnToBaseAI',aiBrain)
						
					else
					
                        self:Stop()
						
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." No path - Moving directly to transportLocation "..repr(transportLocation).." in RTB - distance "..repr(math.sqrt(distance)))
						
						path = { transportLocation }
						
					end
				
				end
			
			end

			-- execute the path movement
			if path then
			
				if PlatoonExists(aiBrain, self) then
				
					self.MoveThread = self:ForkThread( self.MovePlatoon, path, 'GrowthFormation', false)

				end
			
			end
			
		else
		
			-- closer than 75 - move directly --
			if platPos and transportLocation then
			
                --self:Stop()
				self:MoveToLocation(transportLocation, true)		
				
			end
			
		end
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..repr(self.BuilderName).." Moving to transportLocation - distance "..repr(math.sqrt(distance)))

		
		-- At this point the platoon is on its way back to base (or may be there)
		local count = false
		local StuckCount = 0
		local nocmdactive = false	-- this will bypass the nocmdactive check the first time
		
        local timer = SWARMTIME()
        local StartMoveTime = SWARMFLOOR(timer)
		
		local calltransport = 3	-- make immediate call for transport --
		
		-- Monitor the platoons distance to the base watching for death, stuck or idle, and checking for transports
        while (not count) and PlatoonExists(aiBrain, self) and distance > (60*60) do
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..repr(self.BuilderName).." watching travel - RTBLocation is "..repr(RTBLocation).." distance is "..repr(math.sqrt(distance)))
            
			-- check units for idle or stuck --
            for _,v in GetPlatoonUnits(self) do
				
				if not v.Dead then
					
					if nocmdactive then
					
						if SWARMGETN(GetCommandQueue(v)) > 0 or (not v:IsIdleState()) then
						
							nocmdactive = false
							
						else
						
							--LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." has "..LOUDGETN(GetCommandQueue(v)).." CMD queue - Idle State is "..repr(v:IsIdleState()))
							
						end
						
					end
					
					-- look for stuck units after 90 seconds
					if (SWARMTIME() - StartMoveTime) > 90 then
					
						local unitpos = SWARMCOPY(GetPosition(v))
						
						-- if the unit hasn't gotten within range of the platoon
						if VDist2Sq( platPos[1],platPos[3], unitpos[1],unitpos[3] ) > (80*80)  then
					
							if not SWARMENTITY(categories.EXPERIMENTAL,v) then
						
								if not v.WasWarped then
								
									WARN("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." Unit warped in RTB to "..repr(platPos))
									
									Warp( v, platPos )
									IssueMove( {v}, RTBLocation)
									v.WasWarped = true
									
								else
								
									WARN("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." Unit at "..repr(unitpos).." from platoon at "..repr(platPos).." Killed in RTB")
									
									v:Kill()
									
								end
								
							end
							
						end
						
					end
					
				end
				
            end
			
			-- while moving - check distance and call for transport --
			if PlatoonExists(aiBrain, self) then
			
				-- get either a position or use the destination (trigger an end)
				platPos = SWARMCOPY(GetPlatoonPosition(self) or RTBLocation)
				
				distance = VDist2Sq( platPos[1],platPos[3], RTBLocation[1],RTBLocation[3] )
				
				usedTransports = false

				-- call for transports for those platoons that need it -- standard or if stuck
				if (not experimental) and (self.MovementLayer == 'Land' or self.MovementLayer == 'Amphibious')  then
				
					if ( distance > (300*300) or StuckCount > 5 ) and platPos and transportLocation and PlatoonExists(aiBrain, self) then
				
						-- if calltransport counter is 3 check for transport and reset the counter
						-- thru this mechanism we only call for tranport every 4th loop (40 seconds)
						if calltransport > 2 then

							usedTransports = self:SendPlatoonWithTransportsSwarm( aiBrain, transportLocation, 1, false )
							
							calltransport = 0
							
							-- if we used tranports we need to update position and distance
							if usedTransports then
							
								platPos = SWARMCOPY(GetPlatoonPosition(self))
								
								distance = VDist2Sq( platPos[1],platPos[3], RTBLocation[1],RTBLocation[3] )
								
								usedTransports = false
								
							end
							
						else
						
							calltransport = calltransport + 1
							
						end
						
					end
					
				end
				
			end
			
			-- while moving - check for proximity to base (not transportlocation) --
			if PlatoonExists(aiBrain, self) and RTBLocation then
			
				-- proximity to base --
				if distance <= (75*75) then
				
					count = true -- we are near the base - trigger the end of the loop
                    break
					
				end
				
				-- proximity to transportlocation --
                if transportLocation and VDist2Sq( platPos[1],platPos[3], transportLocation[1],transportLocation[3]) < (35*35) then
				
                    count = true
                    break
					
                end
				
				-- if haven't moved much -- 
				if not count and ( lastpos and VDist2Sq( lastpos[1],lastpos[3], platPos[1],platPos[3] ) < 0.15 ) then
				
					StuckCount = StuckCount + 1
					
				else
				
					lastpos = LOUDCOPY(platPos)
					StuckCount = 0
					
				end
				
			end

			-- if platoon idle or base is now inactive -- resubmit platoon if not dead --
			if PlatoonExists(aiBrain, self) and (StuckCount > 10 or nocmdactive or (not aiBrain.BuilderManagers[bestBaseName])) then
				
				if self.MoveThread then
				
					self:KillMoveThread()
					
				end
				
				local platooncount = 0
				
				-- count units and clear out dead
				for k,v in GetPlatoonUnits(self) do
				
					if not v.Dead then
					
						platooncount = platooncount + 1
						
					end
					
				end
                
				-- dead platoon
                if platooncount == 0 then
				
                	return
					
                end                
                
				-- if there is only one unit -- just move it - otherwise resubmit to RTB
                if platooncount == 1 and aiBrain.BuilderManagers[bestBaseName] then
					
                    IssueMove( GetPlatoonUnits(self), RTBLocation)
                    StuckCount = 0
                    count = false
                
				else
				
					local units = GetPlatoonUnits(self)
					
                	IssueClearCommands( units )
					
                    local ident = Random(1,999999)
					
					returnpool = aiBrain:MakePlatoon('ReturnToBase '..tostring(ident), 'none' )
					
                    returnpool.PlanName = 'ReturnToBaseAI'
                    returnpool.BuilderName = 'RTBStuck'
                    returnpool.BuilderLocation = self.LocationType or false
					returnpool.RTBLocation = self.RTBLocation or false
					returnpool.MovementLayer = self.MovementLayer
					
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(nocmdactive).." "..repr(StuckCount).." from "..repr(self.BuilderLocation).." at "..repr(GetPlatoonPosition(returnpool)).." Stuck in RTB to "..repr(self.BuilderLocation).." "..math.sqrt(distance))					
					
					for _,u in units do
					
						if not u.Dead then
						
							if math.sqrt(distance) > 150 then 
						
								AssignUnitsToPlatoon( aiBrain, returnpool, {u}, 'Unassigned', 'None' )
								u.PlatoonHandle = {returnpool}
								u.PlatoonHandle.PlanName = 'ReturnToBaseAI'
								
							else
								
								IssueMove( {u}, RTBLocation )
								
							end
							
						end
						
					end



					if not returnpool.BuilderLocation then
					
						GetMostRestrictiveLayer(returnpool)
						
						if returnpool.MovementLayer == "Land" then
						
							-- dont use naval bases for land --
							returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(returnpool), false )
							
						else
						
							if returnpool.MovementLayer == "Air" or returnpool.PlatoonLayer == "Amphibious" then
							
								-- use any kind of base --
								returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(returnpool), true, false )
								
							else
							
								-- use only naval bases --
								returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(returnpool), true, true )
								
							end
							
						end
						
						returnpool.RTBLocation = returnpool.BuilderLocation	-- this should insure the RTB to a particular base
						
						--LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..repr(returnpool.BuilderName).." submitted to "..repr(returnpool.BuilderLocation))
						
					end
					
                    count = true -- signal the end of the primary loop

					-- send the new platoon off to RTB
					returnpool:SetAIPlan('ReturnToBaseAI', aiBrain)

					coroutine.yield(2)
					break
					
				end
				
			end

			nocmdactive = true	-- this will trigger the nocmdactive check on the next pass

			coroutine.yield(55)

        end
        
		if PlatoonExists(aiBrain, self) then
		
			if self.MoveThread then

				self:KillMoveThread()
				
			end
			
			-- all units are spread out to the rally points except engineers (we want them back to work ASAP)
			if not engineer then
			
				import('/lua/AI/swarmutilities.lua').DisperseUnitsToRallyPoints( aiBrain, GetPlatoonUnits(self), RTBLocation, aiBrain.BuilderManagers[bestBaseName].RallyPoints or false )
				
			else
			
				-- without this, engineers will continue right to the heart of the base
				self:Stop()
				
			end
        
			self:PlatoonDisband(aiBrain)
	
		end
		
    end,

    PlatoonGenerateSafePathToSwarm = function( aiBrain, platoon, platoonLayer, start, destination, threatallowed, MaxMarkerDist)

		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions
		
		local VDist2Sq = VDist2Sq
		local VDist2 = VDist2
		
		-- types of threat to look at based on composition of platoon
		local ThreatTable = { Land = 'AntiSurface', Water = 'AntiSurface', Amphibious = 'AntiSurface', Air = 'AntiAir', }
		local threattype = ThreatTable[platoonLayer]

		-- threatallowed controls how much threat is considered acceptable at any point
		local threatallowed = threatallowed or 5
		
		-- step size is used when making DestinationBetweenPoints checks
		-- the value of 70 is relatively safe to use to avoid intervening terrain issues
		local stepsize = 100

		-- air platoons can look much further off the line since they generally ignore terrain anyway
		-- this larger step makes looking for destination much less costly in processing
		if platoonLayer == 'Air' then
			stepsize = 240
		end
		
		if start and destination then
	
			local distance = VDist2( start[1],start[3], destination[1],destination[3] )
		
			if distance <= stepsize then
			
				return {destination}, 'Direct', distance
				
			elseif platoonLayer == 'Amphibious' then
			
				stepsize = 125
				
				if distance <= stepsize then
					return {destination}, 'Direct', distance
				end
				
			elseif platoonLayer == 'Water' then
			
				stepsize = 175
				
				if distance <= stepsize then
					return {destination}, 'Direct', distance
				end
				
			elseif platoonLayer == 'Air' then
			
				stepsize = 250
				
				if distance <= stepsize or GetThreatBetweenPositions( aiBrain, start, destination, nil, threattype) < threatallowed then
					return {destination}, 'Direct', distance
				end

			end
			
		else
		
			if not destination then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." Generate Safe Path "..platoonLayer.." had a bad destination "..repr(destination))
				return false, 'Badlocations', 0
				
			else
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName).." Generate Safe Path "..platoonLayer.." had a bad start "..repr(start))
				return {destination}, 'Direct', 9999
			end
			
		end

		-- MaxMarkerDist controls the range we look for markers AND the range we use when making threat checks
		local MaxMarkerDist = MaxMarkerDist or 160
		local radiuscheck = MaxMarkerDist * MaxMarkerDist
		local threatradius = MaxMarkerDist * .33
		
		local stepcheck = stepsize * stepsize
		
		-- get all the layer markers -- table format has 5 values (posX,posY,posZ, nodeName, graph)
		local markerlist = ScenarioInfo.PathGraphs['RawPaths'][platoonLayer] or false

		
		--** A Whole set of localized function **--
		-------------------------------------------
		local AIGetThreatLevelsAroundPoint = function( position, threatradius )
	
			if threattype == 'AntiAir' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'AntiAir')	--airthreat
			elseif threattype == 'AntiSurface' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'AntiSurface')	--surthreat
			elseif threattype == 'AntiSub' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'AntiSub')	--subthreat
			elseif threattype == 'Economy' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'Economy')	--ecothreat
			else
				return aiBrain:GetThreatAtPosition( position, 0, true, 'Overall')	--airthreat + ecothreat + surthreat + subthreat
			end
	
		end

		-- checks if destination is somewhere between two points
		local DestinationBetweenPoints = function( destination, start, finish )

			-- using the distance between two nodes
			-- calc how many steps there will be in the line
			local steps = SWARMFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize )
	
			if steps > 0 then
			
				-- and the size of each step
				local xstep = (start[1] - finish[1]) / steps
				local ystep = (start[3] - finish[3]) / steps
	
				-- check the steps from start to one less than then destination
				for i = 1, steps - 1 do
				
					-- if we're within the stepcheck ogrids of the destination then we found it
					if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < stepcheck then
					
						return true
						
					end
					
				end	
				
			end
			
			return false
			
		end

		-- this function will return a 3D position and a named marker
		local GetClosestSafePathNodeInRadiusByLayerLOUD = function( location, seeksafest, goalseek, threatmodifier )
	
			if markerlist then
			
				local positions = {}
				local counter = 0
			
				local VDist3Sq = VDist3Sq
				
				-- sort the table by closest to the given location
				SWARMSORT(markerlist, function(a,b) return VDist3Sq( a.position, location ) < VDist3Sq( b.position, location ) end)
	
				-- traverse the list and make a new list of those with allowable threat and within range
				-- since the source table is already sorted by range, the output table will be created in a sorted order
				for nodename,v in markerlist do
			
					-- process only those entries within the radius
					if VDist3Sq( v.position, location ) <= radiuscheck then
			
						-- add only those with acceptable threat to the new list
						-- if seeksafest or goalseek flag is set we'll build a table of points with allowable threats
						-- otherwise we'll just take the closest one
						if AIGetThreatLevelsAroundPoint( v.position, threatradius) <= (threatallowed * threatmodifier) then

							if seeksafest or goalseek then
						
								positions[counter+1] = { AIGetThreatLevelsAroundPoint( v.position, threatradius), v.node, v.position }
								counter = counter + 1
							
							else
						
								return ScenarioInfo.PathGraphs[platoonLayer][v.node], v.node or GetPathGraphs()[platoonLayer][v.node], v.node
							
							end
						
						end
					
					end
				
				end
			
				-- resort positions to be closest to goalseek position
				-- just a note here -- the goalseek position is often sent WITHOUT a vertical indication so I had to use VDIST2 rather than VDIST 3 to be sure
				if goalseek then
			
					SWARMSORT(positions, function(a,b) return VDist2Sq( a[3][1],a[3][3], goalseek[1],goalseek[3] ) < VDist2Sq( b[3][1],b[3][3], goalseek[1],goalseek[3] ) end)
				
				end
			
				--LOG("*AI DEBUG Sorted positions for destination "..repr(goalseek).." are "..repr(positions))
			
				local bestThreat = (threatallowed * threatmodifier)
				local bestMarker = positions[1][2]	-- defalut to the one closest to goal 	--false
			
				-- loop thru to find one with lowest threat	-- if all threats are equal we'll end up with the closest
				if seeksafest then
			
					for _,v in positions do
				
						if v[1] < bestThreat then
							bestThreat = v[1]
							bestMarker = v[2]
						end
					
					end
				
				end

				if bestMarker then
			
					return ScenarioInfo.PathGraphs[platoonLayer][bestMarker],bestMarker or GetPathGraphs()[platoonLayer][bestMarker],bestMarker
				
				end
				
			end
			
			return false, false
			
		end	

		local AddBadPath = function( layer, startnode, endnode )

			if not ScenarioInfo.BadPaths[layer][startnode] then
			
				ScenarioInfo.BadPaths[layer][startnode] = {}
				
			end

			if not ScenarioInfo.BadPaths[layer][startnode][endnode] then
	
				ScenarioInfo.BadPaths[layer][startnode][endnode] = {}

				if not ScenarioInfo.BadPaths[layer][endnode] then
					ScenarioInfo.BadPaths[layer][endnode] = {}
				end
		
				ScenarioInfo.BadPaths[layer][endnode][startnode] = {}
				
			end
			
		end

		-- this flag is set but passed into the path generator
		-- was originally used to allow the path generator to 'cut corners' on final step
		local testPath = true
		
		if platoonLayer == 'Air' or platoonLayer == 'Amphibious' then
		
			testPath = true
			
		end
	
		-- Get the closest safe node at platoon position which is closest to the destination
		local startNode, startNodeName = GetClosestSafePathNodeInRadiusByLayer( start, false, destination, 2 )

		if not startNode and platoonLayer == 'Amphibious' then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." GenerateSafePath "..platoon.BuilderName.." "..threatallowed.." fails no safe "..platoonLayer.." startnode within "..MaxMarkerDist.." of "..repr(start).." - trying Land")
			platoonLayer = 'Land'
			startNode, startNodeName = GetClosestSafePathNodeInRadiusByLayer( start, false, destination, 2 )
			
		end
	
		if not startNode then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." GenerateSafePath "..repr(platoon.BuilderName).." "..threatallowed.." finds no safe "..platoonLayer.." startnode within "..MaxMarkerDist.." of "..repr(start).." - failing")
			coroutine.yield(1)
			return false, 'NoPath'
			
		end
		
		if DestinationBetweenPoints( destination, start, startNode.position ) then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName).." finds destination between current position and startNode")
			return {destination}, 'Direct', 0.9
			
		end			
    
		-- Get the closest safe node at the destination which is cloest to the start
		local endNode, endNodeName = GetClosestSafePathNodeInRadiusByLayer( destination, true, false, 1 )

		if not endNode then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." GenerateSafePath "..repr(platoon.BuilderName).." "..threatallowed.." finds no safe "..platoonLayer.." endnode within "..MaxMarkerDist.." of "..repr(destination).." - failing")
			coroutine.yield(1)
			return false, 'NoPath'
			
		end
		
		if startNodeName == endNodeName then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName).." GenerateSafePath has same start and end node "..repr(startNodeName))
			return {destination}, 'Direct', 1
			
		end
		
		local path = false
		local pathlength = VDist2(start[1],start[3],startNode.position[1],startNode.position[3])
	
		local BadPath = ScenarioInfo.BadPaths[platoonLayer]
	
		-- if the nodes are not in the bad path cache generate a path for them
		-- Generate the safest path between the start and destination nodes
		if not BadPath[startNodeName][endNodeName] then
			
			-- add the platoons request for a path to the respective path generator for that layer
			SWARMINSERT(aiBrain.PathRequests[platoonLayer], {
															Dest = destination,
															EndNode = endNode,
															Location = start,
															Platoon = platoon, 
															StartNode = startNode,
															Stepsize = stepsize,
															Testpath = testPath,
															ThreatLayer = threattype,
															ThreatWeight = threatallowed,
			} )

			aiBrain.PathRequests['Replies'][platoon] = false
			
            
            local Replies = aiBrain.PathRequests['Replies']
			
			local waitcount = 1
		
			
			-- loop here until reply or 90 seconds
			while waitcount < 100 do
			
				coroutine.yield(3)

				waitcount = waitcount + 1
				
				if Replies[platoon].path then
				
					break
					
				end
				
			end
		
			if waitcount < 100 then
			
				path = Replies[platoon].path
				pathlength = pathlength + Replies[platoon].length
				
			else
			
				Replies[platoon] = false
				return false, 'NoResponse',0
				
			end

			Replies[platoon] = false
			
		end

		if not path or path == 'NoPath' then
	
			-- if no path can be found (versus too much threat or no reply) then add to badpath cache
			if path == 'NoPath' and not BadPath[startNodeName][endNodeName] then
			
				ForkTo(AddBadPath, platoonLayer, startNodeName, endNodeName )
				
			end
	
			return false, 'NoPath', 0
			
		end
	
		path[table.getn(path)+1] = destination
	
		return path, 'Pathing', pathlength
		
	end,

	SendPlatoonWithTransportsSwarm = function( self, aiBrain, destination, attempts, bSkipLastMove )

		if self.MovementLayer == 'Land' or self.MovementLayer == 'Amphibious' then
		
			local AIGetMarkersAroundLocation = import('ai/aiutilities.lua').AIGetMarkersAroundLocation
			
			local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
			local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint			
			
			local PlatoonGenerateSafePathToSwarm = self.PlatoonGenerateSafePathToSwarm
		
			local surthreat, airthreat
			local mythreat
    
			-- prohibit LAND platoons from traveling to water locations
			if self.MovementLayer == 'Land' then
			
				if GetTerrainHeight(destination[1], destination[3]) < GetSurfaceHeight(destination[1], destination[3]) - 2 then 
				
					LOG("*AI DEBUG SendPlatWTrans says Water")
					return false
					
				end
				
			end
			
			-- a local function to get the real surface and air threat at a position based on known units rather than using the threat map
			-- we also pull the value from the threat map so we can get an idea of how often it's a better value
			-- I'm thinking of mixing the two values so that it will error on the side of caution
			local GetRealThreatAtPosition = function( position, range )
			
				local s = 0 
				local a = 0
				
				local sfake = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiSurface' )
				local afake = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiAir' )
			
				local eunits = GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.FACTORY - categories.ECONOMIC - categories.SHIELD - categories.WALL , position, range,  'Enemy')
			
				if eunits then
			
					for _,u in eunits do
				
						if not u.Dead then
					
							local bp = __blueprints[u.BlueprintID].Defense
						
							a = a + bp.AirThreatLevel
							s = s + bp.SurfaceThreatLevel

						end
					
					end

				end
				
				if sfake > 0 and sfake > s then
				
					s = (s + sfake) * .5
					
				end
				
				if afake > 0 and afake > a then
				
					a = (a + afake) * .5
					
				end
				
				return s, a
			
			end

			-- a local function to find an alternate Drop point which satisfies both transports and self for threat and a path to the goal
			local FindSafeDropZoneWithPath = function( self, transportplatoon, markerTypes, markerrange, destination, threatMax, airthreatMax, threatType, layer)

				local markerlist = {}
				local path, reason, pathlength
	
				-- locate the requested markers within markerrange of the supplied location	that the platoon can safely land at
				for _,v in markerTypes do
				
					markerlist = SWARMCAT( markerlist, AIGetMarkersAroundLocation(aiBrain, v, destination, markerrange, 0, threatMax, 0, 'AntiSurface') )
					
				end
				
				-- sort the markers by closest distance to final destination
				SWARMSORT( markerlist, function(a,b) return VDist2Sq( a.Position[1],a.Position[3], destination[1],destination[3] ) < VDist2Sq( b.Position[1],b.Position[3], destination[1],destination[3] )  end )

				-- loop thru each marker -- see if you can form a safe path on the surface 
				-- and a safe path for the transports -- use the first one that satisfies both
				for _, v in markerlist do

					-- test the real values for that position
					local stest, atest = GetRealThreatAtPosition( v.Position, 75 )
		
					if stest <= threatMax and atest <= airthreatMax then
					
						--LOG("*AI DEBUG "..aiBrain.Nickname.." FINDSAFEDROP for "..repr(destination).." is testing "..repr(v.Position).." "..v.Name)
						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." Position "..repr(v.Position).." says Surface threat is "..stest.." vs "..threatMax.." and Air threat is "..atest.." vs "..airthreatMax )
						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." drop distance is "..repr( VDist3(destination, v.Position) ) )
			
						-- can the self path safely from this marker to the final destination 
						path, reason, pathlength = PlatoonGenerateSafePathToSwarm(aiBrain, self, layer, destination, v.Position, threatMax, 160 )
	
						-- can the transports reach that marker ?
						if path then
						
							--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." can path from "..repr(v.Position).." to "..repr(destination))
							
							path, reason, pathlength = PlatoonGenerateSafePathToSwarm( aiBrain, transportplatoon, 'Air', v.Position, self:GetPlatoonPosition(), airthreatMax, 240 )
						
							if path then
							
								--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." finds SAFEDROP at "..repr(v.Position))
							
								return v.Position, v.Name
							
							end

						end
					
					end
					
				end

				
				--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." NO safe drop for "..repr(destination).." using "..layer)
				
				return false, nil
				
			end
	
			local counter = 0
			local bUsedTransports = false
			local transportplatoon = false
			local IsEngineer = PlatoonCategoryCount( self, categories.ENGINEER ) > 0
			
			-- make the requested number of attempts to get transports
			for counter = 1, attempts do
			
				if PlatoonExists( aiBrain, self ) then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." call transports attempt "..counter)
					
					-- check if we can get enough transport and how many transports we are using
					-- this call will return the # of units transported (true) or false, if true, the self holding the transports or false
					bUsedTransports, transportplatoon = GetTransports( self, aiBrain )
			
					if bUsedTransports or counter == attempts then
					
						break 
						
					end

					coroutine.yield(120)

				end
				
			end

			-- if we didnt use transports
			if (not bUsedTransports) then

				if transportplatoon then
				
					ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
					
				end

				return false
				
			end

			--LOG("*AI DEBUG "..aiBrain.Nickname.." assigns "..transportplatoon.BuilderName.." to "..self.BuilderName)
	
			-- ===================================
			-- FIND A DROP ZONE FOR THE TRANSPORTS
			-- ===================================
			-- this is based upon the threat at the destination and the threat sensitivity of the land units and the transports
			
			-- a threat value for the transports based upon the number of transports
			local transportcount = SWARMGETN( GetPlatoonUnits(transportplatoon))
			
			local airthreatMax = transportcount * 8
			
			airthreatMax = airthreatMax + ( airthreatMax * math.log10(transportcount))
			
			--LOG("*AI DEBUG "..aiBrain.Nickname.." airthreatMax for "..transportcount.." unit transport platoon is "..repr(airthreatMax).." calc is "..math.log10(transportcount) )
			
			-- this is the desired drop location
			local transportLocation = SWARMCOPY(destination)

			-- our own threat
			local mythreat = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)
			
			if not mythreat then 
				mythreat = 1
			end
			
			-- get the real known threat at the destination within 75 grids
			surthreat, airtheat = GetRealThreatAtPosition( destination, 75 )

			-- if the destination doesn't look good, use alternate or false
			if surthreat > mythreat or airthreat > airthreatMax then
			
				-- we'll look for a drop zone at least half as close as we already are
				local markerrange = VDist3( self:GetPlatoonPosition(), destination ) * .5
				
				--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." seeking alternate landing zone within "..markerrange.." of destination "..repr(destination))
			
				transportLocation = false

				-- If destination is too hot -- locate the nearest movement marker that is safe
				if self.MovementLayer == 'Amphibious' then
				
					transportLocation = FindSafeDropZoneWithPath( self, transportplatoon, {'Amphibious Path Node','Land Path Node','Transport Marker'}, markerrange, destination, mythreat, airthreatMax, 'AntiSurface', self.MovementLayer)
					
				else
				
					transportLocation = FindSafeDropZoneWithPath( self, transportplatoon, {'Land Path Node','Transport Marker'}, markerrange, destination, mythreat, airthreatMax, 'AntiSurface', self.MovementLayer)
					
				end
				
				if transportLocation then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." finds alternate landing position at "..repr(transportLocation))
					
					ForkTo( AISendPing, transportLocation, 'alert', aiBrain.ArmyIndex )
				
				end
			
			end
		
			-- if no alternate, or either self has died, return the transports and abort transport
			if not transportLocation or (not PlatoonExists(aiBrain, self)) or (not PlatoonExists(aiBrain,transportplatoon)) then
				
				if PlatoonExists(aiBrain,transportplatoon) then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." cannot find safe transport position to "..repr(destination).." - "..self.MovementLayer.." - aborting transport")
					
					ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
					
				end

				return false
				
			end

			-- correct drop location for surface height
			transportLocation[2] = GetSurfaceHeight(transportLocation[1], transportLocation[3])

			if self.MoveThread then
			
				-- if the platoon has a movement thread this should kill it 
				-- before we pick the platoon up -- 
				self:KillMoveThread()
				
			end

			
			-- LOAD THE TRANSPORTS AND DELIVER
			-- we stay in this function until we load, move and arrive or die
			-- will get a false if entire self cannot be used
			-- note how we pass the IsEngineer flag -- alters the behaviour of the transport
			bUsedTransports = UseTransports( aiBrain, transportplatoon, transportLocation, self, IsEngineer )
			
			-- if self died or we couldn't use transports --
			if (not self) or (not PlatoonExists(aiBrain, self)) or (not bUsedTransports) then
			
				-- if transports RTB them --
				if PlatoonExists(aiBrain,transportplatoon) then
				
					ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
					
				end
				
				
				return false
				
			end

			-- PROCESS THE PLATOON AFTER LANDING 
			-- if we used transports then process any unlanded units
			-- seriously though - UseTransports should have dealt with that
			-- anyhow - forcibly detach the unit and re-enable standard conditions
			local units = GetPlatoonUnits(self)

			for _,v in units do
			
				if not v.Dead and IsUnitState( v, 'Attached' ) then
				
					v:DetachFrom()
					v:SetCanTakeDamage(true)
					v:SetDoNotTarget(false)
					v:SetReclaimable(true)
					v:SetCapturable(true)
					v:ShowBone(0, true)
					v:MarkWeaponsOnTransport(v, false)
					
				end
				
			end
		
			-- set path to destination if we landed anywhere else but the destination
			-- All platoons except engineers (which move themselves) get this behavior
			if (not IsEngineer) and GetPlatoonPosition(self) != destination then
		
				if not PlatoonExists( aiBrain, self ) or not GetPlatoonPosition(self) then
				
					return false
					
				end

				-- path from where we are to the destination - use inflated threat to get there --
				local path = PlatoonGenerateSafePathToSwarm(aiBrain, self, self.MovementLayer, GetPlatoonPosition(self), destination, mythreat * 1.25, 160)
				
				local AggroMove = true
				
				if PlatoonExists( aiBrain, self ) then
				
					-- if no path then fail otherwise use it
					if not path and destination != nil then

						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." transport failed and/or no path to destination ")
						
						return false
				
					elseif path then

						self.MoveThread = self:ForkThread( self.MovePlatoon, path, 'AttackFormation', AggroMove )

					end
					
				end
				
			end
			
		end
    
		return PlatoonExists( aiBrain, self )
		
	end,

	--  Function: MergeIntoNearbyPlatoons
	--  This is a variation of the MergeWithNearbyPlatoons 
	--	this one will 'insert' units into another platoon.
	--  used when a depleted platoon would otherwise retreat

    MergeIntoNearbyPlatoons = function( self, aiBrain, planName, radius, planmatchrequired, mergelimit )
	
        if self.UsingTransport then 
            return false
        end		
		
		if not PlatoonExists(aiBrain,self) then
			return false
		end

        local platPos = GetPlatoonPosition(self) or false
		
		if not platPos then
			return false
		end
		
        local radiusSq = radius*radius
		
        for _, base in aiBrain.BuilderManagers do
		
            if VDist2Sq( platPos[1],platPos[3], base.Position[1],base.Position[3] ) <= ( radiusSq / 2 ) then
			
                return false
				
            end 
			
        end
		
        -- get all the platoons
		local GetPlatoonsList = moho.aibrain_methods.GetPlatoonsList
        local AlliedPlatoons = GetPlatoonsList(aiBrain)
		
		SWARMSORT(AlliedPlatoons, function(a,b) return VDist2Sq(GetPlatoonPosition(a)[1],GetPlatoonPosition(a)[3], platPos[1],platPos[3]) < VDist2Sq(GetPlatoonPosition(b)[1],GetPlatoonPosition(b)[3], platPos[1],platPos[3]) end)

        for _,aPlat in AlliedPlatoons do

            if aPlat == self then
                continue
            end
			
			if VDist2Sq(platPos[1],platPos[3], GetPlatoonPosition(aPlat)[1],GetPlatoonPosition(aPlat)[3]) > radiusSq then
				break
			end
			
            if aPlat.UsingTransport then
                continue
            end
			
			if planmatchrequired and aPlat.BuilderName != self.BuilderName then
				continue
			end
			
            if aPlat.PlanName != planName then
                continue
            end
			
            if self.MovementLayer != aPlat.MovementLayer then
                continue
            end
			
            local validUnits = {}
			local counter = 0
			local units = GetPlatoonUnits(self)

			for _,u in units do
			
                if (not u.Dead) and (not u:IsUnitState( 'Attached' )) then
				
                    validUnits[counter+1] = u
					counter = counter + 1
					
                end
				
            end

            if counter > 0 then
			
				if ScenarioInfo.PlatoonMergeDialog then
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." with "..counter.." units MERGE_INTO "..repr(aPlat.BuilderName))
				end			

				AssignUnitsToPlatoon( aiBrain, aPlat, validUnits, 'Attack', 'GrowthFormation' )

				IssueMove( validUnits, aPlat:GetPlatoonPosition() )
			
				return true
			
			end
			
        end

		return false
		
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
            if table.getn(markerLocations) <= 2 then
                self.LastMarker[1] = nil
                self.LastMarker[2] = nil
            end
            for _,marker in RandomIter(markerLocations) do
                if table.getn(markerLocations) <= 2 then
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
            if table.getn(markerLocations) <= 2 then
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
                    local pathLength = table.getn(path)
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
            coroutine.yield(20)
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
        local numberOfUnitsInPlatoon = table.getn(platoonUnits)
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
                coroutine.yield(100)
                continue
            end

            self.MergeWithNearbyPlatoonsSwarm( self, aiBrain, 'AttackForceAISwarm', 30, false, 100)


            local OriginalSurfaceThreat = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)
            local mystrength = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)

            if mystrength <= (OriginalSurfaceThreat * .40) then
					self.MergeIntoNearbyPlatoons( self, aiBrain, 'AttackForceAISwarm', 100, false)
					return self:SetAIPlan('ReturnToBaseAISwarm',aiBrain)
				end	

            -- rebuild formation
            platoonUnits = GetPlatoonUnits(self)
            numberOfUnitsInPlatoon = table.getn(platoonUnits)
            -- if we have a different number of units in our platoon, regather
            if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
                self:StopAttack()
                self:SetPlatoonFormationOverride(PlatoonFormation)
            end
            oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon

            -- deal with lost-puppy transports
            local strayTransports = {}
            for k,v in platoonUnits do
                if EntityCategoryContains(categories.TRANSPORTATION, v) then
                    table.insert(strayTransports, v)
                end
            end
            if table.getn(strayTransports) > 0 then
                local dropPoint = pos
                dropPoint[1] = dropPoint[1] + Random(-3, 3)
                dropPoint[3] = dropPoint[3] + Random(-3, 3)
                IssueTransportUnload(strayTransports, dropPoint)
                coroutine.yield(100)
                local strayTransports = {}
                for k,v in platoonUnits do
                    local parent = v:GetParent()
                    if parent and EntityCategoryContains(categories.TRANSPORTATION, parent) then
                        table.insert(strayTransports, parent)
                        break
                    end
                end
                if table.getn(strayTransports) > 0 then
                    local MAIN = aiBrain.BuilderManagers.MAIN
                    if MAIN then
                        dropPoint = MAIN.Position
                        IssueTransportUnload(strayTransports, dropPoint)
                        coroutine.yield(300)
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
                        table.insert(cmdQ, cmdVal)
                        break
                    end
                end
            end

            -- if we're on our final push through to the destination, and we find a unit close to our destination
            local closestTarget = self:FindClosestUnit('attack', 'enemy', true, categories.ALLUNITS)
            local nearDest = false
            local oldPathSize = table.getn(self.LastAttackDestination)
            if self.LastAttackDestination then
                nearDest = oldPathSize == 0 or VDist3(self.LastAttackDestination[oldPathSize], pos) < 20
            end

            -- if we're near our destination and we have a unit closeby to kill, kill it
            if table.getn(cmdQ) <= 1 and closestTarget and VDist3(closestTarget:GetPosition(), pos) < 20 and nearDest then
                self:StopAttack()
                if PlatoonFormation != 'No Formation' then
                    IssueFormAttack(platoonUnits, closestTarget, PlatoonFormation, 0)
                else
                    IssueAttack(platoonUnits, closestTarget)
                end
                cmdQ = {1}
            -- if we have nothing to do, try finding something to do
            elseif table.getn(cmdQ) == 0 then
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

            if table.getn(cmdQ) == 0 then
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
                coroutine.yield(50)
            else
                -- wait a little longer if we're stuck so that we have a better chance to move
                WaitSeconds(Random(5,11) + 2 * stuckCount)
            end
            coroutine.yield(1)
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
                table.insert(atkPri, v)
                table.insert(categoryList, ParseEntityCategory(v))
            end
        end
        table.insert(atkPri, 'ALLUNITS')
        table.insert(categoryList, categories.ALLUNITS)
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
                        self:MoveToLocation(table.copy(target:GetPosition()), false)
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
        
        if bestMarker.Position == nil and GetGameTimeSeconds() > 900 then
            --LOG('Best Marker position was nil and game time greater than 15 mins, switch to hunt ai')
            return self:LandAttackAISwarm()
        elseif bestMarker.Position == nil then
            --LOG('Best Marker position was nil, select random')
            if table.getn(markerLocations) <= 2 then
                self.LastMarker[1] = nil
                self.LastMarker[2] = nil
            end
            for _,marker in RandomIter(markerLocations) do
                if table.getn(markerLocations) <= 2 then
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
                local position = GetPlatoonPosition(self)
                if not success or VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 512 then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, bestMarker.Position, true)
                elseif VDist2(position[1], position[3], bestMarker.Position[1], bestMarker.Position[3]) > 256 then
                    usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, bestMarker.Position, false)
                end
                if not usedTransports then
                    local pathLength = table.getn(path)
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
            local numGround = aiBrain:GetNumUnitsAroundPoint((categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 15, 'Enemy')
            while numGround > 0 and aiBrain:PlatoonExists(self) do
                WaitTicks(Random(50,100))
                --LOG('Still enemy stuff around marker position')
                numGround = aiBrain:GetNumUnitsAroundPoint((categories.LAND + categories.NAVAL + categories.STRUCTURE), bestMarker.Position, 15, 'Enemy')
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
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Uveso: * HeroFightPlatoon: MoveToCategories missing in platoon '..self.BuilderName)
        end

        -- get categories at what we want a unit to shoot at - (primary unit targets)
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
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
        for _, unit in self:GetPlatoonUnits() do
            UnitBlueprint = unit:GetBlueprint()
            -- continue with the next unit if this unit is dead
            if unit.Dead then continue end
            -- remove INSIGNIFICANTUNIT units from the platoon (drones, buildbots etc)
            if UnitBlueprint.CategoriesHash.INSIGNIFICANTUNIT then
                --SPEW('* AI-Uveso: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a INSIGNIFICANTUNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- remove POD units from the platoon
            if UnitBlueprint.CategoriesHash.POD then
                --SPEW('* AI-Uveso: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a POD UNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- remove DRONE units from the platoon
            if UnitBlueprint.CategoriesHash.DRONE then
                --SPEW('* AI-Uveso: HeroFightPlatoon: -- unit ['..repr(unit.UnitId)..'] is a DRONE UNIT.  Removing from platoon...  - '..repr( unit:GetBlueprint().General.UnitName or "Unknown" )..' ('..repr( unit:GetBlueprint().Description or "Unknown" )..'')
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
                continue
            end
            -- get the maximum weapopn range of this unit
            for _, weapon in UnitBlueprint.Weapon or {} do
                -- filter dummy weapons
                if weapon.Damage == 0 then
                    continue
                end
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
                        --LOG('Unit can fire 360° front')
                        unit.HasRearWeapon = true
                    end
                    -- left unit side
                    if YawMin <= -225 and YawMax >= -135 then
                        --LOG('Unit can fire 90° rear (left)')
                        unit.HasRearWeapon = true
                    end
                    -- right unit side
                    if YawMin <= 135 and YawMax >= 225 then
                        --LOG('Unit can fire 90° rear (right)')
                        unit.HasRearWeapon = true
                    end
                    -- back unit side
                    if YawMin <= -202.5 and YawMax >= 202.5 then
                        --LOG('Unit can fire 45° rear')
                        unit.HasRearWeapon = true
                    end
                end
                -- unit can have MaxWeaponRange entry from the last platoon
                if not unit.MaxWeaponRange or weapon.MaxRadius > unit.MaxWeaponRange then
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
                end
                -- check for the overall range of the platoon
                if not MaxPlatoonWeaponRange or MaxPlatoonWeaponRange < unit.MaxWeaponRange then
                    MaxPlatoonWeaponRange = unit.MaxWeaponRange
                end
            end
            -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
            if unit:TestToggleCaps('RULEUTC_StealthToggle') then
                unit:SetScriptBit('RULEUTC_StealthToggle', false)
            end
            if unit:TestToggleCaps('RULEUTC_CloakToggle') then
                unit:SetScriptBit('RULEUTC_CloakToggle', false)
            end
            -- search if we have an experimental inside the platoon so we can't use transports
            if not ExperimentalInPlatoon and EntityCategoryContains(categories.EXPERIMENTAL, unit) then
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
                    --LOG('Scanning: unit ['..repr(unit.UnitId)..'] Is a IsShieldOnlyUnit')
                    unit.IsShieldOnlyUnit = true
                end
                if UnitBlueprint.Intel.RadarStealthField then
                    --LOG('Scanning: unit ['..repr(unit.UnitId)..'] Is a RadarStealthField Unit')
                    unit.IsShieldOnlyUnit = true
                end
                if UnitBlueprint.Intel.CloakField then
                    --LOG('Scanning: unit ['..repr(unit.UnitId)..'] Is a CloakField Unit')
                    unit.IsShieldOnlyUnit = true
                end
            end
            -- debug for modded units that have no weapon and no shield or stealth/cloak
            -- things like seraphim restauration field
            if not unit.MaxWeaponRange and not unit.IsShieldOnlyUnit then
                WARN('Scanning: unit ['..repr(unit.UnitId)..'] has no MaxWeaponRange - '..repr(self.BuilderName))
            end
            unit.IamLost = 0
        end
        if not MaxPlatoonWeaponRange then
            return
        end
        -- we only see targets from this targetcategories.
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory
        if not TargetSearchCategory then
            WARN('Missing TargetSearchCategory in builder: '..repr(self.BuilderName))
        end
        -- additional variables we need inside the platoon loop
        local TargetInPlatoonRange
        local target
        local TargetPos
        local LastTargetPos
        local unitPos
        local alpha
        local x
        local y
        local smartPos
        local UnitToCover = nil
        local CoverIndex = 0
        local UnitMassCost = {}
        local bAggroMove = self.PlatoonData.AggressiveMove
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local WantsTransport = self.PlatoonData.RequireTransport
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local basePosition
        local PlatoonCenterPosition = self:GetPlatoonPosition()
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonCenterPosition
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFrom = basePosition
        -- platoon loop
        --self:RenamePlatoon('MAIN loop')
        while aiBrain:PlatoonExists(self) do
            -- remove the Blcked flag from all unts. (at this point we don't have a target or the target is dead or we clean a leftover from the last platoon call)
            for _, unit in self:GetPlatoonUnits() or {} do
                unit.Blocked = false
            end
            -- wait a bit here, so continue commands can't deadloop/freeze the game
            coroutine.yield(5)
            if self.UsingTransport then
                --self:RenamePlatoon('Wait for Transport')
                continue
            end
            PlatoonCenterPosition = self:GetPlatoonPosition()
            -- set target search center position
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonCenterPosition
            end
            -- Search for a target
            if not target or target.Dead then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', PlatoonCenterPosition, maxRadius, MoveToCategories, TargetSearchCategory, false )
                target = UnitWithPath or UnitNoPath
            else
                if target:BeenDestroyed() then
                    WARN('* HeroFightPlatoon: MAIN target is not dead but destroyed !!!')
                    continue
                end
            end
            -- remove target, if we are out of base range
            DistanceToBase = VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if GetTargetsFromBase and DistanceToBase > maxRadius then
                target = nil
            end
            -- check if the platoon died while the targetting function was searching for targets
            if not aiBrain:PlatoonExists(self) then
                return
            end
            -- move to the target
            if target and not target.Dead then
                LastTargetPos = table.copy(target:GetPosition())
                -- are we outside weaponrange ? then move to the target
                if VDist2( PlatoonCenterPosition[1], PlatoonCenterPosition[3], LastTargetPos[1], LastTargetPos[3] ) > MaxPlatoonWeaponRange + 30 then
                    --self:RenamePlatoon('move to target -> out of weapon range')
                    -- if we have a path then use the waypoints 
                    if UnitWithPath and path and not self.PlatoonData.IgnorePathing then
                        --self:RenamePlatoon('move to target -> with waypoints')
                        -- move to the target with waypoints
                        if self.MovementLayer == 'Air' then
                            self:MovePath(aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        elseif self.MovementLayer == 'Water' then
                            self:MovePath(aiBrain, path, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        else
                            self:MoveToLocationInclTransport(target, LastTargetPos, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, TargetSearchCategory)
                        end
                    -- if we don't have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                    elseif UnitWithPath then
                        --self:RenamePlatoon('move to target -> without waypoints')
                        -- move to the target without waypoints
                        if self.MovementLayer == 'Air' then
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        elseif self.MovementLayer == 'Water' then
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        else
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        end
                    -- move to the target without waypoints using a transporter
                    elseif UnitNoPath then
                        -- we have a target but no path, Air can flight to it
                        if self.MovementLayer == 'Air' then
                            --self:RenamePlatoon('AIR MoveDirect')
                            self:MoveDirect(aiBrain, bAggroMove, target, MaxPlatoonWeaponRange, TargetSearchCategory)
                        -- we have a target but no path, Naval can never reach it
                        elseif self.MovementLayer == 'Water' then
                            --self:RenamePlatoon('No Naval path')
                            target = nil
                        else
                            self:Stop()
                            --self:RenamePlatoon('MoveOnlyWithTransport')
                            self:MoveWithTransport(aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon, MaxPlatoonWeaponRange, TargetSearchCategory)
                        end
                    end
                end
            else
                -- no target, land units just wait for new targets, air and naval units return to their base
                if self.MovementLayer == 'Air' then
                    --self:RenamePlatoon('move to base')
                    if VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 40 then
                        self:SetPlatoonFormationOverride('NoFormation')
                        self:MoveToLocation(basePosition, false)
                    else
                        -- we are at home and we don't have a target. Disband!
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                            return
                        end
                    end
                elseif self.MovementLayer == 'Water' then
                    --self:RenamePlatoon('move to base')
                    if VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 40 then
                        self:SetPlatoonFormationOverride('NoFormation')
                        self:MoveToLocation(basePosition, false)
                    else
                    -- we are at home and we don't have a target. Disband!
                        if aiBrain:PlatoonExists(self) then
                            self:PlatoonDisband()
                            return
                        end
                    end
                else
                    -- if we get targets from base then we are here to protect the base. Return to cover the base.
                    if GetTargetsFromBase then
                        --self:RenamePlatoon('No Target, returning Home')
                        self:ForceReturnToNearestBaseAIUveso()
                    else
                        --self:RenamePlatoon('move to New targets')
                        -- no more targets found with platoonbuilder template settings. Set new targets to the platoon and continue
                        self.PlatoonData.SearchRadius = 10000
                        maxRadius = 10000
                        self.PlatoonData.AttackEnemyStrength = 1000
                        self.PlatoonData.GetTargetsFromBase = false
                        GetTargetsFromBase = false
                        self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.COMMAND, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                        self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.COMMAND, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                        self.PlatoonData.TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT
                        TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT
                    end
                end
            end
            -- in case we are using a transporter, do nothing. Wait for the transport!
            if self.UsingTransport then
                --self:RenamePlatoon('Wait for Transport')
                continue
            end
            -- stop the platoon, now we are moving units instead of the platoon
            if aiBrain:PlatoonExists(self) then
                self:Stop()
            else
                return
            end
            -- fight
            coroutine.yield(5)
            --self:RenamePlatoon('MICRO loop')
            while aiBrain:PlatoonExists(self) do
                -- wait a bit here, so continue commands can't deadloop/freeze the game
                coroutine.yield(5)
                --LOG('* AI-Uveso: * HeroFightPlatoon: Starting micro loop')
                PlatoonCenterPosition = self:GetPlatoonPosition()
                if not PlatoonCenterPosition then
                    --WARN('PlatoonCenterPosition not existent')
                    if aiBrain:PlatoonExists(self) then
                        self:PlatoonDisband()
                    end
                    return
                end
                -- get a target on every loop, so we can see targets that are moving closer
                TargetInPlatoonRange = AIUtils.AIFindNearestCategoryTargetInCloseRange(aiBrain, PlatoonCenterPosition, MaxPlatoonWeaponRange + 30 , {TargetSearchCategory}, TargetSearchCategory, false)
                if TargetInPlatoonRange and not TargetInPlatoonRange.Dead then
                    --LOG('* AI-Uveso: * HeroFightPlatoon: TargetInPlatoonRange: ['..repr(TargetInPlatoonRange.UnitId)..']')
                    LastTargetPos = TargetInPlatoonRange:GetPosition()
                    if AIUtils.IsNukeBlastArea(aiBrain, LastTargetPos) then
                        -- break out of the "while aiBrain:PlatoonExists(self) do" loop
                        break
                    end
                    if self.MovementLayer == 'Air' then
                        --self:RenamePlatoon('Fight micro AIR start')
                        -- remove target, if we are out of base range
                        DistanceToBase = VDist2(PlatoonCenterPosition[1] or 0, PlatoonCenterPosition[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                        if GetTargetsFromBase and DistanceToBase > maxRadius then
                            TargetInPlatoonRange = nil
                            break
                        end
                        -- else attack
                        self:AttackTarget(TargetInPlatoonRange)
                    else
                        --LOG('* AI-Uveso: * HeroFightPlatoon: Fight micro LAND start')
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
                            unitPos = unit:GetPosition()
                            if unit.Blocked then
                                -- Weapoon fire is blocked, move to the target as close as possible.
                                smartPos = { LastTargetPos[1] + (Random(-5, 5)/10), LastTargetPos[2], LastTargetPos[3] + (Random(-5, 5)/10) }
                            else
                                alpha = math.atan2 (LastTargetPos[3] - unitPos[3] ,LastTargetPos[1] - unitPos[1])
                                x = LastTargetPos[1] - math.cos(alpha) * (unit.MaxWeaponRange or MaxPlatoonWeaponRange)
                                y = LastTargetPos[3] - math.sin(alpha) * (unit.MaxWeaponRange or MaxPlatoonWeaponRange)
                                smartPos = { x, GetTerrainHeight( x, y), y }
                            end
                            -- check if the move position is new or target has moved
                            -- if we don't have a rear weapon, stay a bit longer before moving
                            if (not unit.HasRearWeapon and VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 30)
                            or (unit.HasRearWeapon and (VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 or unit.TargetPos ~= LastTargetPos) ) then
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
                                    WARN('We have a LOST (stucked) unit. Killing it!!! dist: '..repr(VDist2( unitPos[1], unitPos[3], PlatoonCenterPosition[1], PlatoonCenterPosition[3]))..' '..repr(unitPos))
                                    -- stucked units can't be unstucked, even with a forked thread and hammering movement commands. Let's kill it !!!
                                    unit:Kill()
                                end
                                -- clear move commands if we have queued more than 4
                                if table.getn(unit:GetCommandQueue()) > 2 then
                                    IssueClearCommands({unit})
                                    coroutine.yield(3)
                                end
                                -- if our target is dead, jump out of the "for _, unit in self:GetPlatoonUnits() do" loop
                                IssueMove({unit}, smartPos )
                                if not TargetInPlatoonRange.Dead then
                                    IssueAttack({unit}, TargetInPlatoonRange)
                                end
                                --unit:SetCustomName('Fight micro moving')
                                unit.smartPos = smartPos
                                unit.TargetPos = LastTargetPos
                            -- in case we don't move, check if we can fire at the target
                            else
                                if aiBrain:CheckBlockingTerrain(unitPos, LastTargetPos, unit.WeaponArc) then
                                    unit:SetCustomName('WEAPON BLOCKED!!! ['..repr(TargetInPlatoonRange.UnitId)..']')
                                    unit.Blocked = true
                                else
                                    unit.Blocked = false
                                    unit:SetCustomName('SHOOTING ['..repr(TargetInPlatoonRange.UnitId)..']')
                                end
                            end
                            -- use this table later to decide what unit we want to cover with shields
                            table.insert(UnitMassCost, {UnitMassCost = unit.UnitMassCost, smartPos = unit.smartPos, TargetPos = unit.TargetPos})
                        end -- end micro first turn 
                        if not UnitMassCost[1] then
                            -- we can just disband the platoon everywhere on the map.
                            -- the location manager will return these units to the nearest base for reassignment.
                            --self:RenamePlatoon('no Fighters -> Disbanded')
                            if aiBrain:PlatoonExists(self) then
                                self:PlatoonDisband()
                            end
                            return
                        end
                        table.sort(UnitMassCost, function(a, b) return a.UnitMassCost > b.UnitMassCost end)
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
                                x = UnitToCover.smartPos[1] + math.cos(alpha) * 4
                                y = UnitToCover.smartPos[3] + math.sin(alpha) * 4
                                smartPos = { x, GetTerrainHeight( x, y), y }
                            else
                                smartPos = PlatoonCenterPosition
                            end
                            -- check if the move position is new or target has moved
                            if VDist2( smartPos[1], smartPos[3], unit.smartPos[1], unit.smartPos[3] ) > 0.7 then
                                -- clear move commands if we have queued more than 4
                                if table.getn(unit:GetCommandQueue()) > 2 then
                                    IssueClearCommands({unit})
                                    coroutine.yield(3)
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
                    --LOG('* AI-Uveso: * HeroFightPlatoon: Fight micro No Target')
                    --self:RenamePlatoon('Fight micro No Target')
                    -- move units to the middle of the platoon
                    self:Stop()
                    -- break the fight loop and get new targets
                    break
                end
            end  -- fight end
        end
        if aiBrain:PlatoonExists(self) then
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


