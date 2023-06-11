--WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aiarchetype-managerloader.lua' )

local import = import
local type = type

local SWARMGETN = table.getn
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
local lastCall = SWARMTIME()
local HighestThreat = {}


SwarmExecutePlanFunction = ExecutePlan

function ExecutePlan(aiBrain)

    if aiBrain.Swarm then
        aiBrain:ForkThread(BaseTargetManagerThreadSwarm, aiBrain)
        aiBrain:ForkThread(EcoManagerThreadSwarm, aiBrain)
    end

    return SwarmExecutePlanFunction(aiBrain)

end

function SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
    -- Store the new mult inside options, so new builded units get the new mult automatically
    if tostring(CheatMult) == tostring(ScenarioInfo.Options.CheatMult) and tostring(BuildMult) == tostring(ScenarioInfo.Options.BuildMult) then
        --LOG('* SetArmyPoolBuffSwarm: CheatMult+BuildMult not changed. No buffing needed!')
        return
    end
    ScenarioInfo.Options.CheatMult = tostring(CheatMult)
    ScenarioInfo.Options.BuildMult = tostring(BuildMult)
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
        BuffSwarm.ApplyBuff(unit, 'CheatIncome')
        BuffSwarm.ApplyBuff(unit, 'CheatBuildRate')
    end
end

function EcoManagerThreadSwarm(aiBrain)
    while SWARMTIME() < 15 + aiBrain:GetArmyIndex() do
        SWARMWAIT(10)
    end
    local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
    local CheatMultOption = tonumber(ScenarioInfo.Options.CheatMult)
    local BuildMultOption = tonumber(ScenarioInfo.Options.BuildMult)
    local CheatMult = CheatMultOption
    local BuildMult = BuildMultOption
    if CheatMultOption ~= BuildMultOption then
        CheatMultOption = SWARMMAX(CheatMultOption,BuildMultOption)
        BuildMultOption = SWARMMAX(CheatMultOption,BuildMultOption)
        ScenarioInfo.Options.CheatMult = tostring(CheatMultOption)
        ScenarioInfo.Options.BuildMult = tostring(BuildMultOption)
    end
    --LOG('* AI-Swarm: Function EcoManagerThreadSwarm() started! CheatFactor:('..repr(CheatMultOption)..') - BuildFactor:('..repr(BuildMultOption)..') ['..aiBrain.Nickname..']')
    local Engineers = {}
    local paragons = {}
    local Factories = {}
    local lastCall = 0
    local ParaComplete
    local allyScore
    local enemyScore
    local MyArmyRatio
    local bussy
    while aiBrain.Result ~= "defeat" do
        --LOG('* AI-Swarm: Function EcoManagerThreadSwarm() beat. ['..aiBrain.Nickname..']')
        SWARMWAIT(5)
        Engineers = aiBrain:GetListOfUnits(categories.ENGINEER - categories.STATIONASSISTPOD - categories.COMMAND - categories.SUBCOMMANDER, false, false) -- also gets unbuilded units (planed to build)
        StationPods = aiBrain:GetListOfUnits(categories.STATIONASSISTPOD, false, false) -- also gets unbuilded units (planed to build)
        paragons = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC * categories.ENERGYPRODUCTION * categories.MASSPRODUCTION, false, false)
        Factories = aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY, false, false)
        ParaComplete = 0
        bussy = false
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
        -- Cheatbuffs
        if personality == 'swarmeternal' then
            -- Check every 30 seconds for new armyStats to change ECO
            if (SWARMTIME() > 60 * 1) and lastCall+10 < SWARMTIME() then
                local lastCall = SWARMTIME()
                --score of all players (unitcount)
                allyScore = 0
                enemyScore = 0
                for k, brain in ArmyBrains do
                    if ArmyIsCivilian(brain:GetArmyIndex()) then
                        --NOOP
                    elseif IsAlly( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then
                        --allyScore = allyScore + SWARMGETN(brain:GetListOfUnits( (categories.MOBILE + categories.DEFENSE) - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
                        allyScore = allyScore + SWARMGETN(brain:GetListOfUnits( categories.MOBILE - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
                    elseif IsEnemy( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then
                        --enemyScore = enemyScore + SWARMGETN(brain:GetListOfUnits( (categories.MOBILE + categories.DEFENSE) - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
                        enemyScore = enemyScore + SWARMGETN(brain:GetListOfUnits( categories.MOBILE - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
                    end
                end
                if enemyScore ~= 0 then
                    if allyScore == 0 then
                        allyScore = 1
                    end
                    MyArmyRatio = 100/enemyScore*allyScore
                else
                    MyArmyRatio = 100
                end

                -- Increase cheatfactor to +1.5 after 50 Minute gametime
                if SWARMTIME() > 60 * 50 then
                    CheatMult = CheatMult + 0.1
                    BuildMult = BuildMult + 0.1
                    if CheatMult < tonumber(CheatMultOption) then CheatMult = tonumber(CheatMultOption) end
                    if BuildMult < tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    if CheatMult > tonumber(CheatMultOption) + 1.5 then CheatMult = tonumber(CheatMultOption) + 1.5 end
                    if BuildMult > tonumber(BuildMultOption) + 1.5 then BuildMult = tonumber(BuildMultOption) + 1.5 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Increase cheatfactor to +0.2 after 8 Minute gametime
                elseif SWARMTIME() > 60 * 8 then
                    CheatMult = CheatMult + 0.1
                    BuildMult = BuildMult + 0.1
                    if CheatMult < tonumber(CheatMultOption) then CheatMult = tonumber(CheatMultOption) end
                    if BuildMult < tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    if CheatMult > tonumber(CheatMultOption) + 0.2 then CheatMult = tonumber(CheatMultOption) + 0.2 end
                    if BuildMult > tonumber(BuildMultOption) + 0.2 then BuildMult = tonumber(BuildMultOption) + 0.2 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Increase ECO if we have less than 40% of the enemy units
                elseif MyArmyRatio < 35 then
                    CheatMult = CheatMult + 0.4
                    BuildMult = BuildMult + 0.1
                    if CheatMult > tonumber(CheatMultOption) + 8 then CheatMult = tonumber(CheatMultOption) + 8 end
                    if BuildMult > tonumber(BuildMultOption) + 8 then BuildMult = tonumber(BuildMultOption) + 8 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                elseif MyArmyRatio < 55 then
                    CheatMult = CheatMult + 0.3
                    if CheatMult > tonumber(CheatMultOption) + 6 then CheatMult = tonumber(CheatMultOption) + 6 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Increase ECO if we have less than 85% of the enemy units
                elseif MyArmyRatio < 75 then
                    CheatMult = CheatMult + 0.2
                    if CheatMult > tonumber(CheatMultOption) + 4 then CheatMult = tonumber(CheatMultOption) + 4 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Decrease ECO if we have to much units
                elseif MyArmyRatio < 95 then
                    CheatMult = CheatMult + 0.1
                    if CheatMult > tonumber(CheatMultOption) + 3 then CheatMult = tonumber(CheatMultOption) + 3 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Decrease ECO if we have to much units
                elseif MyArmyRatio > 125 then
                    CheatMult = CheatMult - 0.5
                    BuildMult = BuildMult - 0.1
                    if CheatMult < 0.9 then CheatMult = 0.9 end
                    if BuildMult < 0.9 then BuildMult = 0.9 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                elseif MyArmyRatio > 105 then
                    CheatMult = CheatMult - 0.1
                    if CheatMult < 1.0 then CheatMult = 1.0 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Normal ECO
                else -- MyArmyRatio > 85  MyArmyRatio <= 100
                    if CheatMult > CheatMultOption then
                        CheatMult = CheatMult - 0.1
                        if CheatMult < tonumber(CheatMultOption) then CheatMult = tonumber(CheatMultOption) end
                    elseif CheatMult < CheatMultOption then
                        CheatMult = CheatMult + 0.1
                        if CheatMult > tonumber(CheatMultOption) then CheatMult = tonumber(CheatMultOption) end
                    end
                    if BuildMult > BuildMultOption then
                        BuildMult = BuildMult - 0.1
                        if BuildMult < tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    elseif BuildMult < BuildMultOption then
                        BuildMult = BuildMult + 0.1
                        if BuildMult > tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..SWARMFLOOR(MyArmyRatio)..'% - Build/CheatMult old: '..SWARMFLOOR(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..SWARMFLOOR(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..SWARMFLOOR(BuildMult*10)..' '..SWARMFLOOR(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                end
            end
        end


-- ECO for Assisting StationPods
        -- loop over assisting StationPods and manage pause / unpause
        for _, unit in StationPods do
            -- if the unit is dead, continue with the next unit
            if unit.Dead then continue end
            -- Do we have a Paragon like structure ?
            if aiBrain.HasParagon then
                if unit:IsPaused() then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            -- We have negative eco. Check if we can switch something off
            elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.05 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.50 then
                -- if this unit is already paused, continue with the next unit
                if unit:IsPaused() then continue end
                -- Low eco, disable all pods
                if aiBrain:GetEconomyStoredRatio('MASS') < 0.05 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.50 then
                    unit:SetPaused( true )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            -- We have positive eco. Check if we can switch something on
            elseif aiBrain:GetEconomyTrend('MASS') >= 0.0 and aiBrain:GetEconomyTrend('ENERGY') >= 0.0 then
                -- if this unit is paused, continue with the next unit
                if not unit:IsPaused() then continue end
                if aiBrain:GetEconomyStoredRatio('MASS') >= 0.055 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.55 then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            end
        end


        if bussy then
            continue -- while true do
        end
   end
end

function BaseTargetManagerThreadSwarm(aiBrain)
    --        LOG('location manager '..repr(aiBrain.NukedArea))
    while SWARMTIME() < 25 + aiBrain:GetArmyIndex() do
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
            if aiBrain.BuilderManagers['MAIN'] then
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