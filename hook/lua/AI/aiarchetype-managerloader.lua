--WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aiarchetype-managerloader.lua' )

local BuffSwarm = import('/lua/sim/Buff.lua')


-- This hook is for debug-option Platoon-Names. Hook for all AI's
SwarmExecutePlanFunction = ExecutePlan
function ExecutePlan(aiBrain)
   -- enable ecomanager
    if aiBrain.Swarm then
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
    while GetGameTimeSeconds() < 15 + aiBrain:GetArmyIndex() do
        WaitTicks(10)
    end
    local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
    local CheatMultOption = tonumber(ScenarioInfo.Options.CheatMult)
    local BuildMultOption = tonumber(ScenarioInfo.Options.BuildMult)
    local CheatMult = CheatMultOption
    local BuildMult = BuildMultOption
    if CheatMultOption ~= BuildMultOption then
        CheatMultOption = math.max(CheatMultOption,BuildMultOption)
        BuildMultOption = math.max(CheatMultOption,BuildMultOption)
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
        WaitTicks(5)
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
            if (GetGameTimeSeconds() > 60 * 1) and lastCall+10 < GetGameTimeSeconds() then
                lastCall = GetGameTimeSeconds()
                --score of all players (unitcount)
                allyScore = 0
                enemyScore = 0
                for k, brain in ArmyBrains do
                    if ArmyIsCivilian(brain:GetArmyIndex()) then
                        --NOOP
                    elseif IsAlly( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then
                        --allyScore = allyScore + table.getn(brain:GetListOfUnits( (categories.MOBILE + categories.DEFENSE) - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
                        allyScore = allyScore + table.getn(brain:GetListOfUnits( categories.MOBILE - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
                    elseif IsEnemy( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then
                        --enemyScore = enemyScore + table.getn(brain:GetListOfUnits( (categories.MOBILE + categories.DEFENSE) - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
                        enemyScore = enemyScore + table.getn(brain:GetListOfUnits( categories.MOBILE - categories.MASSEXTRACTION - categories.ENGINEER - categories.SCOUT, false, false))
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

                -- Increase cheatfactor to +3 after 30 Minutes gametime
                if GetGameTimeSeconds() > 60 * 25 then
                    CheatMult = CheatMult + 0.1
                    BuildMult = BuildMult + 0.1
                    if CheatMult < tonumber(CheatMultOption) then CheatMult = tonumber(CheatMultOption) end
                    if BuildMult < tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    if CheatMult > tonumber(CheatMultOption) + 3 then CheatMult = tonumber(CheatMultOption) + 3 end
                    if BuildMult > tonumber(BuildMultOption) + 3 then BuildMult = tonumber(BuildMultOption) + 3 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Increase cheatfactor to +2 after 30 hour gametime
                elseif GetGameTimeSeconds() > 60 * 10 then
                    CheatMult = CheatMult + 0.1
                    BuildMult = BuildMult + 0.1
                    if CheatMult < tonumber(CheatMultOption) then CheatMult = tonumber(CheatMultOption) end
                    if BuildMult < tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    if CheatMult > tonumber(CheatMultOption) + 2 then CheatMult = tonumber(CheatMultOption) + 2 end
                    if BuildMult > tonumber(BuildMultOption) + 2 then BuildMult = tonumber(BuildMultOption) + 2 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Increase ECO if we have less than 40% of the enemy units
                elseif MyArmyRatio < 35 then
                    CheatMult = CheatMult + 0.4
                    BuildMult = BuildMult + 0.1
                    if CheatMult > tonumber(CheatMultOption) + 8 then CheatMult = tonumber(CheatMultOption) + 8 end
                    if BuildMult > tonumber(BuildMultOption) + 8 then BuildMult = tonumber(BuildMultOption) + 8 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                elseif MyArmyRatio < 55 then
                    CheatMult = CheatMult + 0.3
                    if CheatMult > tonumber(CheatMultOption) + 6 then CheatMult = tonumber(CheatMultOption) + 6 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Increase ECO if we have less than 85% of the enemy units
                elseif MyArmyRatio < 75 then
                    CheatMult = CheatMult + 0.2
                    if CheatMult > tonumber(CheatMultOption) + 4 then CheatMult = tonumber(CheatMultOption) + 4 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Decrease ECO if we have to much units
                elseif MyArmyRatio < 95 then
                    CheatMult = CheatMult + 0.1
                    if CheatMult > tonumber(CheatMultOption) + 3 then CheatMult = tonumber(CheatMultOption) + 3 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                -- Decrease ECO if we have to much units
                elseif MyArmyRatio > 125 then
                    CheatMult = CheatMult - 0.5
                    BuildMult = BuildMult - 0.1
                    if CheatMult < 0.9 then CheatMult = 0.9 end
                    if BuildMult < 0.9 then BuildMult = 0.9 end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
                    SetArmyPoolBuffSwarm(aiBrain, CheatMult, BuildMult)
                elseif MyArmyRatio > 105 then
                    CheatMult = CheatMult - 0.1
                    if CheatMult < 1.0 then CheatMult = 1.0 end
                    if BuildMult ~= tonumber(BuildMultOption) then BuildMult = tonumber(BuildMultOption) end
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
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
                    --LOG('* ECO + ally('..allyScore..') enemy('..enemyScore..') - ArmyRatio: '..math.floor(MyArmyRatio)..'% - Build/CheatMult old: '..math.floor(tonumber(ScenarioInfo.Options.BuildMult)*10)..' '..math.floor(tonumber(ScenarioInfo.Options.CheatMult)*10)..' - new: '..math.floor(BuildMult*10)..' '..math.floor(CheatMult*10)..'')
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
            elseif aiBrain:GetEconomyTrend('MASS') < 0.0 or aiBrain:GetEconomyTrend('ENERGY') < 0.0 then
                -- if this unit is already paused, continue with the next unit
                if unit:IsPaused() then continue end
                -- Low eco, disable all pods
                if aiBrain:GetEconomyStoredRatio('MASS') < 0.35 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.90 then
                    unit:SetPaused( true )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            -- We have positive eco. Check if we can switch something on
            elseif aiBrain:GetEconomyTrend('MASS') >= 0.0 and aiBrain:GetEconomyTrend('ENERGY') >= 0.0 then
                -- if this unit is paused, continue with the next unit
                if not unit:IsPaused() then continue end
                if aiBrain:GetEconomyStoredRatio('MASS') >= 0.35 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.90 then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            end
        end
        if bussy then
            continue -- while true do
        end

-- ECO for Assisting engineers
        -- loop over assisting engineers and manage pause / unpause
        for _, unit in Engineers do
            -- if the unit is dead, continue with the next unit
            if unit.Dead then continue end
            -- Only Check units that are assisting
            if not unit.PlatoonHandle.PlatoonData.Assist.AssisteeType then continue end
            -- Only Check units that have UnitBeingAssist
            if not unit.UnitBeingAssist then continue end

            -- Do we have a Paragon like structure ?
            if aiBrain.HasParagon then
                if unit:IsPaused() then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            -- We have negative eco. Check if we can switch something off
            elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.0 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.25 then
                -- if this unit is already paused, continue with the next unit
                if unit:IsPaused() then continue end
                -- Emergency low eco energy, prevent shield colaps: disable everything
                if aiBrain:GetEconomyStoredRatio('ENERGY') < 0.25 then
                    -- Pause Experimental assist
                    if EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Paragon assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Factory assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.FACTORY, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Energy assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    end
                    -- disband all other assist Platoons
                    unit.PlatoonHandle:Stop()
                    unit.PlatoonHandle:PlatoonDisband()
                    bussy = true
                    break
                -- Extreme low eco mass, disable everything exept energy
                elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.0 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.25 then
                    -- Pause Experimental assist
                    if EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Paragon assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Factory assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.FACTORY, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Energy assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.ECONOMIC, unit.UnitBeingAssist) then
                        -- noop
                    end
                    -- disband all other assist Platoons
                    unit.PlatoonHandle:Stop()
                    unit.PlatoonHandle:PlatoonDisband()
                    bussy = true
                    break
                -- Very low eco, disable everything but factory
                elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.0 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.25 then
                    -- Pause Experimental assist
                    if EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Paragon assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Factory assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.FACTORY, unit.UnitBeingAssist) then
                        -- noop
                    -- Pause Energy assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.ECONOMIC, unit.UnitBeingAssist) then
                        -- noop
                    end
                    -- disband all other assist Platoons
                    unit.PlatoonHandle:Stop()
                    unit.PlatoonHandle:PlatoonDisband()
                    bussy = true
                    break
                -- Low eco, disable only special buildings
                elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.0 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.25 then
                    -- Pause Experimental assist
                    if EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( true )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- Pause Paragon assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC, unit.UnitBeingAssist) then
                        -- noop
                    -- Pause Factory assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.FACTORY, unit.UnitBeingAssist) then
                        -- noop
                    -- Pause Energy assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.ECONOMIC, unit.UnitBeingAssist) then
                        -- noop
                    end
                    -- disband all other assist Platoons
                    unit.PlatoonHandle:Stop()
                    unit.PlatoonHandle:PlatoonDisband()
                    bussy = true
                    break
                end
            -- We have positive eco. Check if we can switch something on
            elseif aiBrain:GetEconomyTrend('MASS') >= 0.0 and aiBrain:GetEconomyTrend('ENERGY') >= 0.0 then
                -- if this unit is paused, continue with the next unit
                if not unit:IsPaused() then continue end
                if aiBrain:GetEconomyStoredRatio('MASS') >= 0.35 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.99 then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                elseif aiBrain:GetEconomyStoredRatio('MASS') >= 0.25 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.80 then
                    -- UnPause Experimental assist
                    if EntityCategoryContains(categories.STRUCTURE * categories.EXPERIMENTAL - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( false )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- UnPause Factory assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.FACTORY, unit.UnitBeingAssist) then
                        unit:SetPaused( false )
                        bussy = true
                        break -- for _, unit in Engineers do
                    -- UnPause Energy assist
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( false )
                        bussy = true
                        break -- for _, unit in Engineers do
                    end
                elseif aiBrain:GetEconomyStoredRatio('MASS') >= 0.05 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.50 then
                    -- UnPause Factory assist
                    if EntityCategoryContains(categories.STRUCTURE * categories.FACTORY, unit.UnitBeingAssist) then
                        unit:SetPaused( false )
                        bussy = true
                        break -- for _, unit in Engineers do
                    elseif EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( false )
                        bussy = true
                        break -- for _, unit in Engineers do
                    end
                elseif aiBrain:GetEconomyStoredRatio('ENERGY') > 0.25 then
                    -- UnPause Energy assist
                    if EntityCategoryContains(categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.ECONOMIC, unit.UnitBeingAssist) then
                        unit:SetPaused( false )
                        bussy = true
                        break -- for _, unit in Engineers do
                    end
                end
            end
        end
        if bussy then
            continue -- while true do
        end
-- ECO for Building engineers
        -- loop over building engineers and manage pause / unpause
        for _, unit in Engineers do
            -- if the unit is dead, continue with the next unit
            if unit.Dead then continue end
            if unit.PlatoonHandle.PlatoonData.Assist.AssisteeType then continue end
            -- Only Check units that are assisting
            if not unit.UnitBeingBuilt then continue end
            if aiBrain.HasParagon or unit.noPause then
                if unit:IsPaused() then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            -- We have negative eco. Check if we can switch something off
            elseif aiBrain:GetEconomyStoredRatio('ENERGY') < 0.01 then
                if unit:IsPaused() then continue end
                if not EntityCategoryContains( categories.ENERGYPRODUCTION + ((categories.MASSEXTRACTION + categories.FACTORY + categories.ENERGYSTORAGE) * categories.TECH1) , unit.UnitBeingBuilt) then
                    unit:SetPaused( true )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.0 then
                if unit:IsPaused() then continue end
                if not EntityCategoryContains( categories.MASSEXTRACTION + ((categories.ENERGYPRODUCTION + categories.FACTORY + categories.MASSSTORAGE) * categories.TECH1) , unit.UnitBeingBuilt) then
                    unit:SetPaused( true )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            -- We have positive eco. Check if we can switch something on
            elseif aiBrain:GetEconomyStoredRatio('MASS') >= 0.2 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.80 then
                if not unit:IsPaused() then continue end
                unit:SetPaused( false )
                bussy = true
                break -- for _, unit in Engineers do
            elseif aiBrain:GetEconomyStoredRatio('MASS') >= 0.01 and aiBrain:GetEconomyStoredRatio('ENERGY') >= 0.80 then
                if not unit:IsPaused() then continue end
                if EntityCategoryContains((categories.ENERGYPRODUCTION + categories.MASSEXTRACTION) - categories.EXPERIMENTAL, unit.UnitBeingBuilt) then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            elseif aiBrain:GetEconomyStoredRatio('ENERGY') >= 1.00 then
                if not unit:IsPaused() then continue end
                if not EntityCategoryContains(categories.ENERGYPRODUCTION - categories.EXPERIMENTAL, unit.UnitBeingBuilt) then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            end
        end
        if bussy then
            continue -- while true do
        end
-- ECO for FACTORIES
        -- loop over Factories and manage pause / unpause
        for _, unit in Factories do
            -- if the unit is dead, continue with the next unit
            if unit.Dead then continue end
            if aiBrain.HasParagon then
                if unit:IsPaused() then
                    unit:SetPaused( false )
                    bussy = true
                    break -- for _, unit in Engineers do
                end
            -- We have negative eco. Check if we can switch something off
            elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.00 or aiBrain:GetEconomyStoredRatio('ENERGY') < 0.25 then
                if unit:IsPaused() or not unit:IsUnitState('Building') then continue end
                if not unit.UnitBeingBuilt then continue end
                if EntityCategoryContains(categories.ENGINEER + categories.TECH1, unit.UnitBeingBuilt) then continue end
                if table.getn(Factories) == 1 then continue end
                unit:SetPaused( true )
                bussy = true
                break -- for _, unit in Engineers do
            else
                if not unit:IsPaused() then continue end
                unit:SetPaused( false )
                bussy = true
                break -- for _, unit in Engineers do
            end
        end
        if bussy then
            continue -- while true do
        end

-- ECO for STRUCTURES
        if aiBrain:GetEconomyStoredRatio('ENERGY') < 0.01 and not aiBrain.HasParagon then
            -- Emergency Low Energy
            if aiBrain:GetEconomyStoredRatio('ENERGY') < 0.01 then
                -- Disable Nuke
                if DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.MASSFABRICATION, 'MassFab') then bussy = true
                -- Disable AntiNuke
                elseif DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL), 'Nuke') then bussy = true
                -- Disable Massfabricators
                elseif DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.ANTIMISSILE * categories.SILO * categories.TECH3, 'AntiNuke') then bussy = true
                -- Disable Intel
                elseif DisableUnitsSwarm(aiBrain, categories.RADAR + categories.OMNI + categories.SONAR, 'Intel') then bussy = true
                -- Disable ExperimentalShields
                elseif DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL, 'ExperimentalShields') then bussy = true
                -- Disable NormalShields
                elseif DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD - categories.EXPERIMENTAL, 'NormalShields') then bussy = true
                end
            elseif aiBrain:GetEconomyStoredRatio('ENERGY') < 0.95 then
                if DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.MASSFABRICATION, 'MassFab') then bussy = true
                end
            end
        end

        if bussy then
            continue -- while true do
        end

        if aiBrain:GetEconomyStoredRatio('MASS') < 0.0 and not aiBrain.HasParagon then
            -- Emergency Low Mass
            if aiBrain:GetEconomyStoredRatio('MASS') < 0.0 then
                -- Disable AntiNuke
                if DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.ANTIMISSILE * categories.SILO * categories.TECH3, 'AntiNuke') then bussy = true
                end
            elseif aiBrain:GetEconomyStoredRatio('MASS') < 0.01 then
                -- Disable Nuke
                if DisableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL), 'Nuke') then bussy = true
                end
            end
        elseif aiBrain:GetEconomyStoredRatio('ENERGY') > 0.50 then
            if aiBrain:GetEconomyStoredRatio('MASS') > 0.01 or aiBrain.HasParagon then
                -- Enable NormalShields
                if EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD - categories.EXPERIMENTAL, 'NormalShields') then bussy = true
                -- Enable ExperimentalShields
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL, 'ExperimentalShields') then bussy = true
                -- Enable Intel
                elseif EnableUnitsSwarm(aiBrain, categories.RADAR + categories.OMNI + categories.SONAR, 'Intel') then bussy = true
                -- Enable AntiNuke
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.ANTIMISSILE * categories.SILO * categories.TECH3, 'AntiNuke') then bussy = true
                -- Enable massfabricators
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.MASSFABRICATION, 'MassFab') then bussy = true
                -- Enable Nuke
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL), 'Nuke') then bussy = true
                end
            elseif aiBrain:GetEconomyStoredRatio('MASS') > 0.25 or aiBrain.HasParagon then
                -- Enable NormalShields
                if EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD - categories.EXPERIMENTAL, 'NormalShields') then bussy = true
                -- Enable ExperimentalShields
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL, 'ExperimentalShields') then bussy = true
                -- Enable Intel
                elseif EnableUnitsSwarm(aiBrain, categories.RADAR + categories.OMNI + categories.SONAR, 'Intel') then bussy = true
                -- Enable AntiNuke
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.ANTIMISSILE * categories.SILO * categories.TECH3, 'AntiNuke') then bussy = true
                -- Enable massfabricators
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.MASSFABRICATION, 'MassFab') then bussy = true
                end
            else
                -- Enable NormalShields
                if EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD - categories.EXPERIMENTAL, 'NormalShields') then bussy = true
                -- Enable ExperimentalShields
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL, 'ExperimentalShields') then bussy = true
                -- Enable Intel
                elseif EnableUnitsSwarm(aiBrain, categories.RADAR + categories.OMNI + categories.SONAR, 'Intel') then bussy = true
                -- Enable massfabricators
                elseif EnableUnitsSwarm(aiBrain, categories.STRUCTURE * categories.MASSFABRICATION, 'MassFab') then bussy = true
                end
            end
        end

        if bussy then
            continue -- while true do
        end



   end
end

function DisableUnitsSwarm(aiBrain, Category, UnitType)
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
end

