WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aiarchetype-managerloader.lua' )

local import = import
local type = type

local SWARMGETN = table.getn
local SWARMDEEPCOPY = table.deepcopy
local SWARMWAIT = coroutine.yield
local SWARMMAX = math.max
local SWARMFLOOR = math.floor
local SWARMTIME = GetGameTimeSeconds

local VDist2 = VDist2

local ForkThread = ForkThread

local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetFractionComplete = moho.entity_methods.GetFractionComplete
local GetAIBrain = moho.unit_methods.GetAIBrain

local BuffSwarm = import('/lua/sim/Buff.lua')
local HighestThreat = {}

SwarmExecutePlanFunction = ExecutePlan

function ExecutePlan(aiBrain)

    if aiBrain.Swarm then
        --aiBrain:ForkThread(MarkerGridThreatManagerThreadSwarm, aiBrain) -- Starts at Minute 1
        aiBrain:ForkThread(BaseTargetManagerThreadSwarm, aiBrain) -- Starts at Minute 2
        aiBrain:ForkThread(TimedCheatThreadSwarm, aiBrain) -- Starts at AIEternalDelay [Refer to -> LobbyOptions]
    end

    return SwarmExecutePlanFunction(aiBrain)

end

function TimedCheatThreadSwarm(aiBrain)
    while SWARMTIME() < ScenarioInfo.Options.AIEternalDelay * 60 + aiBrain:GetArmyIndex() do
        SWARMWAIT(10)
    end

    local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
    aiBrain.CheatMult = tonumber(ScenarioInfo.Options.CheatMult)
    aiBrain.BuildMult = tonumber(ScenarioInfo.Options.BuildMult)
    if aiBrain.CheatMult ~= aiBrain.BuildMult then
        aiBrain.CheatMult = SWARMMAX(aiBrain.CheatMult,aiBrain.BuildMult)
        aiBrain.BuildMult = SWARMMAX(aiBrain.CheatMult,aiBrain.BuildMult)
    end

    --LOG('* AI-Swarm: Function TimedCheatThreadSwarm() started! CheatFactor:('..repr(aiBrain.CheatMult)..') - BuildFactor:('..repr(aiBrain.BuildMult)..') ['..aiBrain.Nickname..']')
    local paragons = {}
    local lastCall = 0
    local ParaComplete

    local function SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
        LOG('Setting new values for aiBrain.CheatMult:'..aiBrain.CheatMult..' - aiBrain.BuildMult:'..aiBrain.BuildMult)
        local BuffSwarm = BuffSwarm
        
        -- Modify Buildrate buff
        local buffDef = Buffs['CheatBuildRate']
        local buffAffects = buffDef.Affects
        buffAffects.BuildRate.Mult = BuildMult
    
        -- Modify CheatIncome buff
        buffDef = Buffs['CheatIncome']
        buffAffects = buffDef.Affects
        buffAffects.EnergyProduction.Mult = CheatMult
        buffAffects.MassProduction.Mult = CheatMult
    
        allUnits = aiBrain:GetListOfUnits(categories.ALLUNITS, false, false)
        for _, unit in allUnits do
            -- Remove old build rate and income buffs
            BuffSwarm.RemoveBuff(unit, 'CheatIncome', true) -- true = removeAllCounts
            BuffSwarm.RemoveBuff(unit, 'CheatBuildRate', true) -- true = removeAllCounts
            -- Apply new build rate and income buffs
            BuffSwarm.ApplyBuff(unit, 'CheatIncome', true)
            BuffSwarm.ApplyBuff(unit, 'CheatBuildRate', true)
        end
    end
    
    while aiBrain.Result ~= "defeat" do
        --LOG('* AI-Swarm: Function TimedCheatThreadSwarm() beat. ['..aiBrain.Nickname..']')

        SWARMWAIT(1)

        -- Cheatbuffs
        if personality == 'swarmeternal' then
            --LOG('* AI-Swarm: SwarmEternal beat. ['..aiBrain.Nickname..']')

            paragons = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC * categories.ENERGYPRODUCTION * categories.MASSPRODUCTION, false, false)
            ParaComplete = 0

            for unitNum, unit in paragons do
                if unit:GetFractionComplete() >= 1 then
                    ParaComplete = ParaComplete + 1
                end
            end

            if ParaComplete >= 1 then
                aiBrain.HasParagon = true
            else
                aiBrain.HasParagon = false
            end

            -- I do not know why but the Cheat works... however it does not work at the same time.
            -- I always wondered why Eternal's Cheat was so fucked. It was rapidly go up and down for no reason.
            -- I need to farther debug this to figure out what is causing this.

            -- Check every 60 seconds

            if lastCall + 60 < SWARMTIME() then
                lastCall = SWARMTIME()
                --LOG('What is our current LastCall ' .. repr(lastCall))
                aiBrain.CheatMult = aiBrain.CheatMult + ScenarioInfo.Options.AIEternalIncrease  -- with the default of 0.025, +0.1 after 4 min. +1.0 after 40 min.
                aiBrain.BuildMult = aiBrain.BuildMult + ScenarioInfo.Options.AIEternalIncrease
                if aiBrain.CheatMult > 8 then aiBrain.CheatMult = 8 end
                if aiBrain.BuildMult > 8 then aiBrain.BuildMult = 8 end
                --LOG('Setting new values for aiBrain.CheatMult:'..aiBrain.CheatMult..' - aiBrain.BuildMult:'..aiBrain.BuildMult)
                SetArmyPoolBuffSwarm(aiBrain, aiBrain.CheatMult, aiBrain.BuildMult)
            end
        end
    end
end

function BaseTargetManagerThreadSwarm(aiBrain)
    --        LOG('location manager '..repr(aiBrain.NukedArea))
    while SWARMTIME() < 60*2 + aiBrain:GetArmyIndex() do
       SWARMWAIT(10)
    end
    --LOG('* AI-Swarm: Function BaseTargetManagerThread() started. ['..aiBrain.Nickname..']')
    local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()
    local targets = {}
    local baseposition, radius
    local ClosestTarget
    local distance
    local armyIndex = aiBrain:GetArmyIndex()
    while aiBrain.Result ~= "defeat" do
        --LOG('* AI-Swarm: Function BaseTargetManagerThread() beat. ['..aiBrain.Nickname..']')
        ClosestTarget = nil
        distance = 8192
        SWARMWAIT(50)
        if not baseposition then
            if aiBrain:PBMHasPlatoonList() then
                for k,v in aiBrain.PBM.Locations do
                    if v.LocationType == 'MAIN' then
                        baseposition = v.Location
                        radius = v.Radius
                        break
                    end
                end
            elseif aiBrain.BuilderManagers['MAIN'] then
                baseposition = aiBrain.BuilderManagers['MAIN'].FactoryManager.Location
                radius = aiBrain.BuilderManagers['MAIN'].FactoryManager:GetLocationRadius()
            end
            if not baseposition then
                    continue
            end
        end
        -- Search for experimentals in BasePanicZone
        targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL - categories.AIR - categories.INSIGNIFICANTUNIT, baseposition, 120, 'Enemy')
        for _, unit in targets do
            if not unit.Dead then
                if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                local TargetPosition = unit:GetPosition()
                local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                if targetRange < distance then
                    distance = targetRange
                    ClosestTarget = unit
                end
            end
        end
        SWARMWAIT(1)
        -- Search for experimentals in BaseMilitaryZone
        if not ClosestTarget then
            targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL - categories.AIR - categories.INSIGNIFICANTUNIT, baseposition, BaseMilitaryZone, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                    end
                end
            end
        end
        SWARMWAIT(1)
        -- Search for Paragons in EnemyZone
        if not ClosestTarget then
            targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL * categories.ECONOMIC, baseposition, BaseEnemyZone, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                    end
                end
            end
        end
        SWARMWAIT(1)
        -- Search for High Threat Area
        if not ClosestTarget and HighestThreat[armyIndex].TargetLocation then
            -- search for any unit in this area
            targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL + categories.TECH3 + categories.ALLUNITS, HighestThreat[armyIndex].TargetLocation, 60, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                        -- we only need a single unit for targeting this area
                        --LOG('High Threat Area: '.. repr(HighestThreat[armyIndex].TargetThreat)..' - '..repr(HighestThreat[armyIndex].TargetLocation))
                        break --for _, unit in targets do
                    end
                end
            end
        end
        SWARMWAIT(1)
        -- Search for Shields in EnemyZone
        if not ClosestTarget then
            targets = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.SHIELD, baseposition, BaseEnemyZone, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                    end
                end
            end
        end
        SWARMWAIT(1)
        -- Search for experimentals in EnemyZone
        if not ClosestTarget then
            targets = aiBrain:GetUnitsAroundPoint(categories.EXPERIMENTAL - categories.AIR - categories.INSIGNIFICANTUNIT, baseposition, BaseEnemyZone, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                    end
                end
            end
        end
        SWARMWAIT(1)
        -- Search for T3 Factories / Gates in EnemyZone
        if not ClosestTarget then
            targets = aiBrain:GetUnitsAroundPoint((categories.STRUCTURE * categories.GATE) + (categories.STRUCTURE * categories.FACTORY * categories.TECH3 - categories.SUPPORTFACTORY), baseposition, BaseEnemyZone, 'Enemy')
            for _, unit in targets do
                if not unit.Dead then
                    if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then continue end
                    local TargetPosition = unit:GetPosition()
                    local targetRange = VDist2(baseposition[1], baseposition[3], TargetPosition[1], TargetPosition[3])
                    if targetRange < distance then
                        distance = targetRange
                        ClosestTarget = unit
                    end
                end
            end
        end
        aiBrain.PrimaryTarget = ClosestTarget
    end
end

--OLD: - Highest:0.023910 - Average:0.017244
--NEW: - Highest:0.002929 - Average:0.002018
function MarkerGridThreatManagerThreadSwarm(aiBrain)
    while SWARMTIME() < 60*1 + aiBrain:GetArmyIndex() do
        SWARMWAIT(10)
    end
    --LOG('* AI-Swarm: Function MarkerGridThreatManagerThread() started. ['..aiBrain.Nickname..']')
    local AIAttackUtils = import('/lua/ai/aiattackutilities.lua')
    local numTargetTECH123 = 0
    local numTargetTECH4 = 0
    local numTargetCOM = 0
    local armyIndex = aiBrain:GetArmyIndex()
    local PathGraphs = AIAttackUtils.GetPathGraphs()
    local vector
    if not (PathGraphs['Land'] or PathGraphs['Amphibious'] or PathGraphs['Air'] or PathGraphs['Water']) then
        WARN('* AI-Swarm: Function MarkerGridThreatManagerThread() No AI path markers found on map. Threat handling diabled!  '..ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality)
        -- end this forked thead
        return
    end
    while aiBrain.Result ~= "defeat" do
        HighestThreat[armyIndex] = HighestThreat[armyIndex] or {}
        HighestThreat[armyIndex].ThreatCount = 0
        --LOG('* AI-Swarm: Function MarkerGridThreatManagerThread() beat. ['..aiBrain.Nickname..']')
        for Layer, LayerMarkers in PathGraphs do
            for graph, GraphMarkers in LayerMarkers do
                for nodename, markerInfo in GraphMarkers do
-- possible options for GetThreatAtPosition
--  Overall
--  OverallNotAssigned
--  StructuresNotMex
--  Structures
--  Naval
--  Air
--  Land
--  Experimental
--  Commander
--  Artillery
--  AntiAir
--  AntiSurface
--  AntiSub
--  Economy
--  Unknown
                    local Threat = 0
                    vector = Vector(markerInfo.position[1],markerInfo.position[2],markerInfo.position[3])
                    if markerInfo.layer == 'Land' then
                        Threat = aiBrain:GetThreatAtPosition(vector, 0, true, 'AntiSurface')
                    elseif markerInfo.layer == 'Amphibious' then
                        Threat = aiBrain:GetThreatAtPosition(vector, 0, true, 'AntiSurface')
                        Threat = Threat + aiBrain:GetThreatAtPosition(vector, 0, true, 'AntiSub')
                    elseif markerInfo.layer == 'Water' then
                        Threat = aiBrain:GetThreatAtPosition(vector, 0, true, 'AntiSurface')
                        Threat = Threat + aiBrain:GetThreatAtPosition(vector, 0, true, 'AntiSub')
                    elseif markerInfo.layer == 'Air' then
                        Threat = aiBrain:GetThreatAtPosition(vector, 1, true, 'AntiAir')
                        Threat = Threat + aiBrain:GetThreatAtPosition(vector, 0, true, 'Structures')
                    end
                    --LOG('* MarkerGridThreatManagerThread: 1='..numTargetTECH1..'  2='..numTargetTECH2..'  3='..numTargetTECH123..'  4='..numTargetTECH4..' - Threat='..Threat..'.' )
                    Scenario.MasterChain._MASTERCHAIN_.Markers[nodename][armyIndex] = Threat
                    if Threat > HighestThreat[armyIndex].ThreatCount then
                        HighestThreat[armyIndex].ThreatCount = Threat
                        HighestThreat[armyIndex].Location = vector
                    end
                end
            end
            -- Wait after checking a layer, so we need 0.4 seconds for all 4 layers.
            SWARMWAIT(1)
        end
        if HighestThreat[armyIndex].ThreatCount > 1 then
            HighestThreat[armyIndex].TargetThreat = HighestThreat[armyIndex].ThreatCount
            HighestThreat[armyIndex].TargetLocation = HighestThreat[armyIndex].Location
        end
    end
end 


-- Unused Functions -- 

--[[ function DisableUnitsSwarm(aiBrain, Category, UnitType)
    local Units = aiBrain:GetListOfUnits(Category, false, false) -- also gets unbuilded units (planed to build)
    for _, unit in Units do
        if unit.Dead then continue end
        if unit:GetFractionComplete() ~= 1 then continue end
        -- Units that only needs to be set on pause
        if UnitType == 'Nuke' or UnitType == 'AntiNuke' then
            if not unit:IsPaused() then
                --LOG('*DisableUnitsSwarm: Unit :SetPaused true'..UnitType..' - '..unit:GetBlueprint().BlueprintId..' - '..aiBrain.Name)
                unit:SetPaused( true )
                -- now return, we only want do disable one unit per loop
                return true
            end
        end
        -- Maintenance -- for units that are usually "on": radar, mass extractors, etc.
        if unit.MaintenanceConsumption == true then
            unit:OnProductionPaused()
            --LOG('*DisableUnitsSwarm: Unit OnProductionPaused '..UnitType..' - '..unit:GetBlueprint().BlueprintId..' - '..aiBrain.Name)
            return true
        end
        -- Active -- when upgrading, constructing, or something similar.
        if unit.ActiveConsumption == true then
            unit:SetActiveConsumptionInactive()
            --LOG('*DisableUnitsSwarm: Unit SetActiveConsumptionInactive '..UnitType..' - '..unit:GetBlueprint().BlueprintId..' - '..aiBrain.Name)
            return true
        end
    end
    return false
end

function EnableUnitsSwarm(aiBrain, Category, UnitType)
    local Units = aiBrain:GetListOfUnits(Category, false, false) -- also gets unbuilded units (planed to build)
    for _, unit in Units do
        if unit.Dead then continue end
        if unit:GetFractionComplete() ~= 1 then continue end
        -- Units that only needs to be set on pause
        if UnitType == 'Nuke' or UnitType == 'AntiNuke' then
            if unit:IsPaused() then
                --LOG('*EnableUnitsSwarm: Unit :SetPaused false '..UnitType..' - '..unit:GetBlueprint().BlueprintId..' - '..aiBrain.Name)
                unit:SetPaused( false )
                -- now return, we only want do disable one unit per loop
                return true
            end
        end
        -- Maintenance -- for units that are usually "on": radar, mass extractors, etc.
        if unit.MaintenanceConsumption == false then
            unit:OnProductionUnpaused()
            --LOG('*EnableUnitsSwarm: Unit OnProductionUnpaused '..UnitType..' - '..unit:GetBlueprint().BlueprintId..' - '..aiBrain.Name)
            return true
        end
        -- Active -- when upgrading, constructing, or something similar.
        if unit.ActiveConsumption == false then
            unit:SetActiveConsumptionActive()
            --LOG('*EnableUnitsSwarm: Unit SetActiveConsumptionActive '..UnitType..' - '..unit:GetBlueprint().BlueprintId..' - '..aiBrain.Name)
            return true
        end
    end
    return false
end ]]--
