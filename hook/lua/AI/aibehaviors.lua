WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aibehaviors.lua' )

local HaveUnitRatio = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua').HaveUnitRatio
local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
local GetEconomyStoredRatio = moho.aibrain_methods.GetEconomyStoredRatio
local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome
local GetEconomyRequested = moho.aibrain_methods.GetEconomyRequested
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local MakePlatoon = moho.aibrain_methods.MakePlatoon
local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local PlatoonExists = moho.aibrain_methods.PlatoonExists
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition

local SWARMGETN = table.getn
local SWARMSORT = table.sort
local SWARMINSERT = table.insert
local SWARMMIN = math.min
local SWARMMAX = math.max
local SWARMWAIT = coroutine.yield

-- Below LOCALs are for Performance and Readability in new Support Factory Compability Code
-- See local function DecideUpgradeBP()

-- FACTORY
local FACTORYALL = categories.FACTORY * categories.STRUCTURE
-- MASS EXTRACTOR 
local EXTRACTORALL = categories.MASSEXTRACTION * categories.STRUCTURE * (categories.TECH1 + categories.TECH2 + categories.TECH3)

-- LAND FACTORY
local FACTORYLAND = categories.FACTORY * categories.STRUCTURE * categories.LAND - categories.RESEARCH
-- AIR FACTORY
local FACTORYAIR = categories.FACTORY * categories.STRUCTURE * categories.AIR - categories.RESEARCH
-- NAVAL FACTORY
local FACTORYNAVAL = categories.FACTORY * categories.STRUCTURE * categories.NAVAL - categories.RESEARCH

-- LAND HQs
local FLHQ2 = categories.FACTORY * categories.STRUCTURE * categories.LAND * categories.TECH2 * categories.RESEARCH
local FLHQ3 = categories.FACTORY * categories.STRUCTURE * categories.LAND * categories.TECH3 * categories.RESEARCH
-- AIR HQs
local FAHQ2 = categories.FACTORY * categories.STRUCTURE * categories.AIR * categories.TECH2 * categories.RESEARCH
local FAHQ3 = categories.FACTORY * categories.STRUCTURE * categories.AIR * categories.TECH3 * categories.RESEARCH
-- NAVAL HQs
local FNHQ2 = categories.FACTORY * categories.STRUCTURE * categories.NAVAL * categories.TECH2 * categories.RESEARCH
local FNHQ3 = categories.FACTORY * categories.STRUCTURE * categories.NAVAL * categories.TECH3 * categories.RESEARCH

-- LAND SUPPORT FACTORIES 
local FLSF1 = categories.FACTORY * categories.STRUCTURE * categories.LAND * categories.TECH1 - categories.SUPPORTFACTORY
local FLSF2 = categories.FACTORY * categories.STRUCTURE * categories.LAND * categories.TECH2 * categories.SUPPORTFACTORY
-- AIR SUPPORT FACTORIES 
local FASF1 = categories.FACTORY * categories.STRUCTURE * categories.AIR * categories.TECH1 - categories.SUPPORTFACTORY
local FASF2 = categories.FACTORY * categories.STRUCTURE * categories.AIR * categories.TECH2 * categories.SUPPORTFACTORY
-- NAVAL SUPPORT FACTORIES 
local FNSF1 = categories.FACTORY * categories.STRUCTURE * categories.NAVAL * categories.TECH1 - categories.SUPPORTFACTORY
local FNSF2 = categories.FACTORY * categories.STRUCTURE * categories.NAVAL * categories.TECH2 * categories.SUPPORTFACTORY

function MapAdvisor(aiBrain)
    if GetGameTimeSeconds() > 180 then
        aiBrain:BuildScoutLocationsSwarm()
        GetStartingReclaimSwarm(aiBrain)
    end
end

-- 50% of the below was Sprouto's work 
-- Also Thanks Balthazar and Sprouto for Assistance with getting Support Factories to Work
-- With Factories included in this thread his tech pacing is so rapid that with no cheats on open palms he can have full t2 production by 12m 
-- Still Tuning this has theres still excess eco nowadays
function StructureUpgradeThreadSwarm(unit, aiBrain, upgradeSpec, bypasseco) 
    --LOG('* AI-Swarm: Starting structure thread upgrade for'..aiBrain.Nickname)

    local unitBp = unit:GetBlueprint()
    local upgradeID = unitBp.General.UpgradesTo or false

    if not upgradeID then return end

    local massNeeded, energyNeeded, buildtime, buildrate, massProduction, energyProduction, massTrendNeeded, energyTrendNeeded, energyMaintenance
    local upgradeable = true
    local upgradeIssued = false
    if not bypasseco then
        bypasseco = false
    end
    local upgradebp = aiBrain:GetUnitBlueprint(upgradeID)
    local alternativebp = false
    --LOG("What is upgradeID at the Start " ..repr(upgradeID))

    local unitType, unitTech, unitFactionIndex = StructureTypeCheckSwarm(aiBrain, unitBp)
    --LOG("What is unitFactionIndex " ..unitFactionIndex)
    --LOG("What is unitType " ..unitType)
    --LOG("What is unitTech " ..unitTech)

    -- Maybe Replace Unreliable GetListOfUnits with EntityCategoryCount?
    local function DecideUpgradeBP()
        --LOG("What is upgradeID at the start of DecideUpgradeBP Function " ..repr(upgradeID).. " and unit was " ..repr(unit:GetBlueprint().Description))
        if upgradeID then
            -- This is the support factory compatibility code
            if EntityCategoryContains( FACTORYLAND, unit) then -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads
                if table.getn( GetListOfUnits(aiBrain, FLHQ2, false, true )) > 0 or table.getn( GetListOfUnits(aiBrain, FLHQ3, false, true )) > 0 and EntityCategoryContains( FLSF1, unit) then
                    if unitFactionIndex == 1 then
                        alternativebp = 'zeb9501'
                    elseif unitFactionIndex == 2 then
                        alternativebp = 'zab9501'
                    elseif unitFactionIndex == 3 then
                        alternativebp = 'zrb9501'
                    elseif unitFactionIndex == 4 then
                        alternativebp = 'zsb9501'
                    end
                    --LOG("What is unitFactionIndex " ..repr(unitFactionIndex))
                    --LOG("What is alternativebp " ..repr(alternativebp))
                    if alternativebp then
                        upgradebp = aiBrain:GetUnitBlueprint(alternativebp)
                    end
                    if upgradebp then
                        upgradeID = alternativebp
                    end
                elseif table.getn( GetListOfUnits(aiBrain, FLHQ3, false, true )) > 0 and EntityCategoryContains( FLSF2, unit) then
                    if unitFactionIndex == 1 then
                        alternativebp = 'zeb9601'
                    elseif unitFactionIndex == 2 then
                        alternativebp = 'zab9601'
                    elseif unitFactionIndex == 3 then
                        alternativebp = 'zrb9601'
                    elseif unitFactionIndex == 4 then
                        alternativebp = 'zsb9601'
                    end
                    if alternativebp then
                        upgradebp = aiBrain:GetUnitBlueprint(alternativebp)
                    end
                    if upgradebp then
                        upgradeID = alternativebp
                    end
                end
            elseif EntityCategoryContains( FACTORYAIR, unit) then -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads
                if table.getn( GetListOfUnits(aiBrain, FAHQ2, false, true )) > 0 or table.getn( GetListOfUnits(aiBrain, FAHQ3, false, true )) > 0 and EntityCategoryContains( FASF1, unit) then
                    if unitFactionIndex == 1 then
                        alternativebp = 'zeb9502'
                    elseif unitFactionIndex == 2 then
                        alternativebp = 'zab9502'
                    elseif unitFactionIndex == 3 then
                        alternativebp = 'zrb9502'
                    elseif unitFactionIndex == 4 then
                        alternativebp = 'zsb9502'
                    end
                    if alternativebp then
                        upgradebp = aiBrain:GetUnitBlueprint(alternativebp)
                    end
                    if upgradebp then
                        upgradeID = alternativebp
                    end
                elseif table.getn( GetListOfUnits(aiBrain, FAHQ3, false, true )) > 0 and EntityCategoryContains( FASF2, unit) then
                    if unitFactionIndex == 1 then
                        alternativebp = 'zeb9602'
                    elseif unitFactionIndex == 2 then
                        alternativebp = 'zab9602'
                    elseif unitFactionIndex == 3 then
                        alternativebp = 'zrb9602'
                    elseif unitFactionIndex == 4 then
                        alternativebp = 'zsb9602'
                    end
                    if alternativebp then
                        upgradebp = aiBrain:GetUnitBlueprint(alternativebp)
                    end
                    if upgradebp then
                        upgradeID = alternativebp
                    end
                end
            elseif EntityCategoryContains( FACTORYNAVAL, unit) then -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads
                if table.getn( GetListOfUnits(aiBrain, FNHQ2, false, true )) > 0 or table.getn( GetListOfUnits(aiBrain, FNHQ3, false, true )) > 0 and EntityCategoryContains( FNSF1, unit) then
                    if unitFactionIndex == 1 then
                        alternativebp = 'zeb9503'
                    elseif unitFactionIndex == 2 then
                        alternativebp = 'zab9503'
                    elseif unitFactionIndex == 3 then
                        alternativebp = 'zrb9503'
                    elseif unitFactionIndex == 4 then
                        alternativebp = 'zsb9503'
                    end
                    if alternativebp then
                        upgradebp = aiBrain:GetUnitBlueprint(alternativebp)
                    end
                    if upgradebp then
                        upgradeID = alternativebp
                    end
                elseif table.getn( GetListOfUnits(aiBrain, FNHQ3, false, true )) > 0 and EntityCategoryContains( FNSF2, unit) then
                    if unitFactionIndex == 1 then
                        alternativebp = 'zeb9603'
                    elseif unitFactionIndex == 2 then
                        alternativebp = 'zab9603'
                    elseif unitFactionIndex == 3 then
                        alternativebp = 'zrb9603'
                    elseif unitFactionIndex == 4 then
                        alternativebp = 'zsb9603'
                    end
                    if alternativebp then
                        upgradebp = aiBrain:GetUnitBlueprint(alternativebp)
                    end
                    if upgradebp then
                        upgradeID = alternativebp
                    end
                end
            --LOG("What is upgradeID " ..repr(upgradebp))
            end
        end
    end

    --LOG("What is upgradeID " ..repr(upgradebp))

    -- Eco requirements
    local function GetUpgradeEconomy()
        if upgradebp then -- safety check
            --LOG("What is upgradeID " ..repr(upgradebp))
            massNeeded = upgradebp.Economy.BuildCostMass or 0
            --LOG('Mass Needed '..massNeeded)
	        energyNeeded = upgradebp.Economy.BuildCostEnergy or 0
            --LOG('Energy Needed '..energyNeeded)
            buildtime = upgradebp.Economy.BuildTime or 0
            --LOG('Build Time is  '..buildtime)
            buildrate = unitBp.Economy.BuildRate or 0
            --LOG('Build Rate is  '..buildrate)

            -- production while upgrading
            massProduction = unitBp.Economy.ProductionPerSecondMass or 0
            --LOG('Mass Production is  '..massProduction)
            energyProduction = unitBp.Economy.ProductionPerSecondEnergy or 0
            --LOG('Energy Production is  '..energyProduction)
    
            massTrendNeeded = ( SWARMMIN( 0, ( massNeeded / buildtime ) * buildrate) - massProduction) * .1
            --LOG('Mass Trend Needed for '..unitTech..' Unit :'..massTrendNeeded.. ' and Unit was ' ..repr(unit:GetBlueprint().Description))
            energyTrendNeeded = ( SWARMMIN( 0, ( energyNeeded / buildtime ) * buildrate) - energyProduction) * .1
            --LOG('Energy Trend Needed for '..unitTech..' Unit :'..energyTrendNeeded.. ' and Unit was ' ..repr(unit:GetBlueprint().Description))
            energyMaintenance = (upgradebp.Economy.MaintenanceConsumptionPerSecondEnergy or 10) * .1
        end
    end

    -- Define Economic Data
    local eco = aiBrain.EcoData.OverTime -- mother of god I'm stupid this is another bit of Sprouto genius.
    local massStorage
    local energyStorage
    local massStorageRatio
    local energyStorageRatio
    local massIncome
    local massRequested
    local energyIncome
    local energyRequested
    local massTrend
    local energyTrend
    local massEfficiency
    local energyEfficiency
    local ecoTimeOut
    local upgradeNumLimit
    local extractorUpgradeLimit = 0
    local multiplier
    local initial_delay = 0
    local ecoStartTime = GetGameTimeSeconds()

    if aiBrain.CheatEnabled then
        multiplier = tonumber(ScenarioInfo.Options.BuildMult)
    else
        multiplier = 1
    end

    --LOG('Multiplier is '..multiplier)
    --LOG('The upgradeSpec is '..repr(upgradeSpec))
    --LOG('Initial Delay is before any multiplier is '..upgradeSpec.InitialDelay)
    --LOG('Initial Delay is '..(upgradeSpec.InitialDelay / multiplier))
    --LOG('Eco timeout for Tech '..unitTech..' Extractor is '..ecoTimeOut)
    --LOG('* AI-Swarm: Initial Variables set')
    while initial_delay < (upgradeSpec.InitialDelay / multiplier) do
		if GetEconomyStored( aiBrain, 'MASS') >= 50 and GetEconomyStored( aiBrain, 'ENERGY') >= 900 and unit:GetFractionComplete() == 1 then
            if aiBrain.UpgradeMode == 'Aggressive' then
                initial_delay = initial_delay + 20
            elseif aiBrain.UpgradeMode == 'Normal' then
                initial_delay = initial_delay + 10
            elseif aiBrain.UpgradeMode == 'Caution' then
                initial_delay = initial_delay + 5
            end
            unit.InitialDelay = true
        end
        --LOG('* AI-Swarm: Initial Delay loop trigger for '..aiBrain.Nickname..' is : '..initial_delay..' out of 90')
		SWARMWAIT(100)
    end
    unit.InitialDelay = nil

    -- Main Upgrade Loop
    --LOG("What is upgradeID before the start of the main loop " ..repr(upgradeID))
    while ((not unit.Dead) or unit.Sync.id) and upgradeable and not upgradeIssued do
        --LOG('* AI-Swarm: Upgrade main loop starting for'..aiBrain.Nickname)
        SWARMWAIT(upgradeSpec.UpgradeCheckWait * 10)

        DecideUpgradeBP()
        GetUpgradeEconomy()
        --LOG("What is Upgrade BP " ..repr(upgradebp))
        upgradeSpec = aiBrain:GetUpgradeSpecSwarm(unit)
        --LOG('Upgrade Spec '..repr(upgradeSpec))
        --LOG('Current low mass trigger '..upgradeSpec.MassLowTrigger)

        if EntityCategoryContains( EXTRACTORALL, unit) and not ExtractorClosestSwarm(aiBrain, unit, unitBp) then
            --LOG('This is not the Closest Extractor ' .. ' ' ..repr(unit:GetBlueprint().Description))
            SWARMWAIT(10)
            continue
        end

        if (not unit.MAINBASE) or (unit.MAINBASE and not bypasseco and GetEconomyStored( aiBrain, 'MASS') < (massNeeded * 0.5)) then
            --LOG('Mainbase Unit is ' .. ' ' ..repr(unit:GetBlueprint().Description))
            if HaveUnitRatio( aiBrain, 1.6, categories.MASSEXTRACTION * categories.TECH1, '>=', categories.MASSEXTRACTION * categories.TECH2 ) and unitTech == 'TECH2' then
                --LOG('Too few tech2 extractors to go tech3')
                ecoStartTime = ecoStartTime + upgradeSpec.UpgradeCheckWait
                SWARMWAIT(10)
                continue
            end
        end

        --LOG('Current Upgrade Limit is :'..upgradeNumLimit)
        --LOG('Upgrade Issued '..aiBrain.UpgradeIssued..' Upgrade Issued Limit '..aiBrain.UpgradeIssuedLimit)
        if aiBrain.UpgradeIssued < aiBrain.UpgradeIssuedLimit then
            --LOG('* AI-Swarm:'..aiBrain.Nickname)
            --LOG('* AI-Swarm: UpgradeIssues and UpgradeIssuedLimit are set')
            massStorage = GetEconomyStored( aiBrain, 'MASS')
            --LOG('* AI-Swarm: massStorage'..massStorage)
            energyStorage = GetEconomyStored( aiBrain, 'ENERGY')
            --LOG('* AI-Swarm: energyStorage'..energyStorage)
            massStorageRatio = GetEconomyStoredRatio(aiBrain, 'MASS')
            --LOG('* AI-Swarm: massStorageRatio'..massStorageRatio)
            energyStorageRatio = GetEconomyStoredRatio(aiBrain, 'ENERGY')
            --LOG('* AI-Swarm: energyStorageRatio'..energyStorageRatio)
            massIncome = GetEconomyIncome(aiBrain, 'MASS')
            --LOG('* AI-Swarm: massIncome'..massIncome)
            massRequested = GetEconomyRequested(aiBrain, 'MASS')
            --LOG('* AI-Swarm: massRequested'..massRequested)
            energyIncome = GetEconomyIncome(aiBrain, 'ENERGY')
            --LOG('* AI-Swarm: energyIncome'..energyIncome)
            energyRequested = GetEconomyRequested(aiBrain, 'ENERGY')
            --LOG('* AI-Swarm: energyRequested'..energyRequested)
            massTrend = aiBrain.EconomyOverTimeCurrent.MassTrendOverTime
            --LOG('* AI-Swarm: massTrend'..massTrend)
            energyTrend = aiBrain.EconomyOverTimeCurrent.EnergyTrendOverTime
            --LOG('* AI-Swarm: energyTrend'..energyTrend)
            --massEfficiency = math.min(massIncome / massRequested, 2)
            --LOG('* AI-Swarm: massEfficiency'..massEfficiency)
            --energyEfficiency = math.min(energyIncome / energyRequested, 2)
            --LOG('* AI-Swarm: energyEfficiency'..energyEfficiency)
            
            if (aiBrain.EconomyOverTimeCurrent.MassEfficiencyOverTime >= upgradeSpec.MassLowTrigger and aiBrain.EconomyOverTimeCurrent.EnergyEfficiencyOverTime >= upgradeSpec.EnergyLowTrigger)
                or ((massStorageRatio > .60 and energyStorageRatio > .40))
                or (massStorage > (massNeeded * .7) and energyStorage > (energyNeeded * .7 ) ) or bypasseco then
                    if bypasseco then
                        --LOG('Low Triggered bypasseco')
                    else
                        --LOG('* AI-Swarm: low_trigger_good = true')
                    end
                --LOG('* AI-Swarm: low_trigger_good = true')
            else
                SWARMWAIT(10)
                continue
            end
            
            if (massEfficiency <= upgradeSpec.MassHighTrigger and energyEfficiency <= upgradeSpec.EnergyHighTrigger) then
                --LOG('* AI-Swarm: hi_trigger_good = true')
            else
                continue
            end

            if ( massTrend >= massTrendNeeded and energyTrend >= energyTrendNeeded and energyTrend >= energyMaintenance )
				or ( massStorage >= (massNeeded * .7) and energyStorage > (energyNeeded * .7) ) or bypasseco then
				-- we need to have 15% of the resources stored -- some things like MEX can bypass this last check
				if (massStorage > ( massNeeded * .15 * upgradeSpec.MassLowTrigger) and energyStorage > ( energyNeeded * .15 * upgradeSpec.EnergyLowTrigger)) or bypasseco then
                    if aiBrain.UpgradeIssued < aiBrain.UpgradeIssuedLimit then
						if not unit.Dead then

                            upgradeIssued = true
                            --LOG("What is upgradeID " ..repr(upgradeID) .. " What Unit is upgrading " ..repr(unit:GetBlueprint().Description))
                            IssueUpgrade({unit}, upgradeID)

                            -- if upgrade issued and not completely full --
                            if massStorageRatio < 1 or energyStorageRatio < 1 then
                                ForkThread(StructureUpgradeDelaySwarm, aiBrain, aiBrain.UpgradeIssuedPeriod)  -- delay the next upgrade by the full amount
                            else
                                ForkThread(StructureUpgradeDelaySwarm, aiBrain, aiBrain.UpgradeIssuedPeriod * .5)     -- otherwise halve the delay period
                            end

                            if ScenarioInfo.StructureUpgradeDialog then
                                --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.Sync.id.." "..unit:GetBlueprint().Description.." upgrading to "..repr(upgradeID).." "..repr(__blueprints[upgradeID].Description).." at "..GetGameTimeSeconds() )
                            end

                            repeat
                                SWARMWAIT(50)
                            until unit.Dead or (unit.UnitBeingBuilt:GetBlueprint().BlueprintId == upgradeID) -- Fix this!
                        end

                        if unit.Dead then
                            --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.Sync.id.." "..unit:GetBlueprint().Description.." to "..upgradeID.." failed.  Dead is "..repr(unit.Dead))
                            upgradeIssued = false
                        end

                        if upgradeIssued then
                            SWARMWAIT(10)
                            continue
                        end
                    else
                        LOG("Could not do an upgrade because the UpgradeIssuedLimit was exceeded " .. repr(aiBrain.UpgradeIssued) .. " and UpgradedIsssuedLimit was actually " .. repr(aiBrain.UpgradeIssuedLimit))
                    end
                end
            else
                if ScenarioInfo.StructureUpgradeDialog then
                    if not ( massTrend >= massTrendNeeded ) then
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.Sync.id.." "..unit:GetBlueprint().Description.." FAILS MASS Trend trigger "..massTrend.." needed "..massTrendNeeded)
                    end
                    if not ( energyTrend >= energyTrendNeeded ) then
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.Sync.id.." "..unit:GetBlueprint().Description.." FAILS ENER Trend trigger "..energyTrend.." needed "..energyTrendNeeded)
                    end
                    if not (energyTrend >= energyMaintenance) then
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.Sync.id.." "..unit:GetBlueprint().Description.." FAILS Maintenance trigger "..energyTrend.." "..energyMaintenance)  
                    end
                    if not ( massStorage >= (massNeeded * .8)) then
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.Sync.id.." "..unit:GetBlueprint().Description.." FAILS MASS storage trigger "..massStorage.." needed "..(massNeeded*.8) )
                    end
                    if not (energyStorage > (energyNeeded * .4)) then
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..unit.Sync.id.." "..unit:GetBlueprint().Description.." FAILS ENER storage trigger "..energyStorage.." needed "..(energyNeeded*.4) )
                    end
                end
            end
        end
    end

    if upgradeIssued then
	    --LOG('* AI-Swarm: upgradeIssued is true')

		unit.Upgrading = true

        unit.DesiresAssist = true

        local unitbeingbuiltbp = false
		
		local unitbeingbuilt = unit.UnitBeingBuilt

        unitbeingbuiltbp = unitbeingbuilt:GetBlueprint()

        upgradeID = unitbeingbuiltbp.General.UpgradesTo or false
        --LOG('* AI-Swarm: T1 extractor upgrading to T2 then upgrades to :'..upgradeID)
		
		-- if the upgrade has a follow on upgrade - start an upgrade thread for it --
        if upgradeID and not unitbeingbuilt.Dead then

			upgradeSpec.InitialDelay = upgradeSpec.InitialDelay + 60			-- increase delay before first check for next upgrade

            unitbeingbuilt.DesiresAssist = true			-- let engineers know they can assist this upgrade

            --LOG('* AI-Swarm: Forking another instance of StructureUpgradeThreadSwarm')
			unitbeingbuilt.UpgradeThread = unitbeingbuilt:ForkThread( StructureUpgradeThreadSwarm, aiBrain, upgradeSpec, bypasseco )
        end
		-- assign mass extractors to their own platoon 
		if (not unitbeingbuilt.Dead) and EntityCategoryContains( categories.MASSEXTRACTION, unitbeingbuilt) then

			local extractorPlatoon = MakePlatoon( aiBrain,'ExtractorPlatoon'..tostring(unitbeingbuilt.Sync.id), 'none')

			extractorPlatoon.BuilderName = 'ExtractorPlatoon'..tostring(unitbeingbuilt.Sync.id)

            extractorPlatoon.MovementLayer = 'Land'

            --LOG('* AI-Swarm: Extractor Platoon name is '..extractorPlatoon.BuilderName)
			AssignUnitsToPlatoon( aiBrain, extractorPlatoon, {unitbeingbuilt}, 'Support', 'none' )

            extractorPlatoon:ForkThread( extractorPlatoon.ExtractorCallForHelpAISwarm, aiBrain )

		elseif (not unitbeingbuilt.Dead) then

            AssignUnitsToPlatoon( aiBrain, aiBrain.StructurePool, {unitbeingbuilt}, 'Support', 'none' )
		end
        unit.UpgradeThread = nil
	end
end

function StructureUpgradeDelaySwarm( aiBrain, delay )

    aiBrain.UpgradeIssued = aiBrain.UpgradeIssued + 1
    
    if ScenarioInfo.StructureUpgradeDialog then
        --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade counter up to "..aiBrain.UpgradeIssued.." period is "..delay)
    end

    SWARMWAIT( delay )
    aiBrain.UpgradeIssued = aiBrain.UpgradeIssued - 1
    --LOG('Upgrade Issue delay over')
    
    if ScenarioInfo.StructureUpgradeDialog then
        --LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade counter down to "..aiBrain.UpgradeIssued)
    end
end

function StructureUpgradeNumDelaySwarm(aiBrain, type, tech)
    -- Checked if a slot is available for unit upgrades
    local numLimit = false
    if type == 'MASSEXTRACTION' and tech == 'TECH1' then
        numLimit = aiBrain.EcoManager.ExtractorsUpgrading.TECH1
    elseif type == 'MASSEXTRACTION' and tech == 'TECH2' then
        numLimit = aiBrain.EcoManager.ExtractorsUpgrading.TECH2
    end
    if numLimit then
        return numLimit
    else
        return false
    end
    return false
end

function StructureTypeCheckSwarm(aiBrain, unitBp)
    local factionIndex = aiBrain:GetFactionIndex()
    -- Returns the tech and type of a structure unit
    local unitType = false
    local unitTech = false
    local unitFactionIndex = false
    for k, v in unitBp.Categories do
        if v == 'MASSEXTRACTION' then
            --LOG('Unit is Mass Extractor')
            unitType = 'MASSEXTRACTION'
        elseif v == 'FACTORY' then
            --LOG('Unit is Factory')
            unitType = 'FACTORY'
        else
            --LOG('Value Not Mass Extraction or Factory')
        end

        if v == 'TECH1' then
            --LOG('Unit is Tech 1')
            unitTech = 'TECH1'
        elseif v == 'TECH2' then
            --LOG('Unit is Tech 2')
            unitTech = 'TECH2'
        else
            --LOG('Value not TECH1, TECH2')
        end

        if unitFactionIndex == false then
            unitFactionIndex = aiBrain:GetFactionIndex()
        end
    end
    if unitType and unitTech and unitFactionIndex then
       --LOG("What is unitFactionIndex " ..unitFactionIndex)
       return unitType, unitTech, unitFactionIndex
    else
        return false, false, false
    end
    return false, false, false
end

-- In the future make this function just not review factories and etc 
function ExtractorClosestSwarm(aiBrain, unit, unitBp)
    -- Checks if the unit is closest to the main base
    local MassExtractorFactoryUnitList = {}
    local unitType, unitTech, unitFactionIndex = StructureTypeCheckSwarm(aiBrain, unitBp)
    local BasePosition = aiBrain.BuilderManagers['MAIN'].Position
    local DistanceToBase = nil
    local LowestDistanceToBase = nil
    local UnitPos

    if unitType == 'MASSEXTRACTION' and unitTech == 'TECH1' then
        MassExtractorFactoryUnitList = GetListOfUnits(aiBrain, categories.MASSEXTRACTION * (categories.TECH1), false, false)
    elseif unitType == 'MASSEXTRACTION' and unitTech == 'TECH2' then
        MassExtractorFactoryUnitList = GetListOfUnits(aiBrain, categories.MASSEXTRACTION * (categories.TECH2), false, false)
    elseif unitType == 'FACTORY' and unitTech == 'TECH1' then
        MassExtractorFactoryUnitList = GetListOfUnits(aiBrain, categories.FACTORY * (categories.TECH1), false, false)
    elseif unitType == 'FACTORY' and unitTech == 'TECH2' then
        MassExtractorFactoryUnitList = GetListOfUnits(aiBrain, categories.FACTORY * (categories.TECH2), false, false)
    end

    --LOG("What is the UnitType " ..unitType .. " " .. " What is the UnitTech " ..unitTech )
    --LOG("What is MassExtractorFactoryUnitList " ..repr(MassExtractorFactoryUnitList))

    for k, v in MassExtractorFactoryUnitList do
        local TempID
        -- Check if we don't want to upgrade this unit
        if not v
            or v.Dead
            or v:BeenDestroyed()
            or v:IsPaused()
            or not EntityCategoryContains(ParseEntityCategory(unitTech), v)
            or v:GetFractionComplete() < 1
        then
            -- Skip this loop and continue with the next array
            continue
        end
        if v:IsUnitState('Upgrading') then
        -- skip upgrading buildings
            continue
        end
        -- Check for the nearest distance from mainbase
        UnitPos = v:GetPosition()
        DistanceToBase = VDist2Sq(BasePosition[1] or 0, BasePosition[3] or 0, UnitPos[1] or 0, UnitPos[3] or 0)
        if DistanceToBase < 2500 then
            --LOG('Mainbase extractor set true')
            v.MAINBASE = true
        end
        if (not LowestDistanceToBase and v.InitialDelay == nil) or (DistanceToBase < LowestDistanceToBase and v.InitialDelay == nil) then
            -- see if we can find a upgrade
            LowestDistanceToBase = DistanceToBase
            lowestUnitPos = UnitPos
        end
    end
    if unit:GetPosition() == lowestUnitPos then
        --LOG('Extractor is closest to base')
        return true
    else
        --LOG('Extractor is not closest to base')
        return false
    end
end

GetStartingReclaimSwarm = function(aiBrain)
    --LOG('Reclaim Start Check')
    local startReclaim
    local posX, posZ = aiBrain:GetArmyStartPos()
    --LOG('Start Positions X'..posX..' Z '..posZ)
    local minRec = 10
    local reclaimTable = {}
    local reclaimScanArea = SWARMMAX(ScenarioInfo.size[1]-40, ScenarioInfo.size[2]-40) / 4
    local reclaimTotal = 0
        if not aiBrain.StartReclaimList then  --if we haven't already made the table... make it!  (this is for when we're running multiple times in one game-session)   
            aiBrain.StartReclaimList = {}
            local startReclaim = GetReclaimablesInRect(posX - reclaimScanArea, posZ - reclaimScanArea, posX + reclaimScanArea, posZ + reclaimScanArea)
            --LOG('Initial Reclaim Table size is '..SWARMGETN(startReclaim))
            if startReclaim and SWARMGETN(startReclaim) > 0 then
                for k,v in startReclaim do
                    if not IsProp(v) then continue end
                    if v.MaxMassReclaim and v.MaxMassReclaim >= minRec then
                        --LOG('High Value Reclaim is worth '..v.MaxMassReclaim)
                        local rpos = v:GetCachePosition() --get the reclaim position
                        local distance = VDist2( rpos[1], rpos[3], posX, posZ ) --calculate the distance from the main base to this reclaim
                        SWARMINSERT(aiBrain.StartReclaimList, { Reclaim = v, Distance = distance }) --add it to the list of reclaimables
                    end
                end
                aiBrain.StartReclaimListSorted = {} --create a new table that will be sorted by distance (so we can grab the closest ones first)
                for k,v in aiBrain.StartReclaimList do --iterate through all of them and sort them by distance (closest to furthest)
                    SWARMINSERT(aiBrain.StartReclaimListSorted, { Reclaim = v, Distance = v.Distance })  --insert into our sorted table with key of distance
                end
                SWARMSORT(aiBrain.StartReclaimListSorted, function(a,b) return a.Distance < b.Distance end) --sort the table by distance (closest to furthest)
            end
        else --if we've already made the table... check if it's empty!  (this is for when we're running multiple times in one game-session)   
            if not aiBrain.StartReclaimList[1] then --if our sorted list is empty...
                local startReclaim = GetReclaimablesInRect(posX - reclaimScanArea, posZ - reclaimScanArea, posX + reclaimScanArea, posZ + reclaimScanArea)
                --LOG('Initial Reclaim Table size is '..SWARMGETN(startReclaim))
                if startReclaim and SWARMGETN(startReclaim) > 0 then
                    for k,v in startReclaim do
                        if not IsProp(v) then continue end
                        if v.MaxMassReclaim and v.MaxMassReclaim >= minRec then
                            --LOG('High Value Reclaim is worth '..v.MaxMassReclaim)
                        	local rpos = v:GetCachePosition() --get the reclaim position
                        	local distance = VDist2( rpos[1], rpos[3], posX, posZ ) --calculate the distance from the main base to this reclaim
                        	SWARMINSERT(aiBrain.StartReclaimList, { Reclaim = v, Distance = distance }) --add it to the list of reclaimables
                        end
                    end
                    aiBrain.StartReclaimListSorted = {} --create a new table that will be sorted by distance (so we can grab the closest ones first)
                    for k,v in aiBrain.StartReclaimList do --iterate through all of them and sort them by distance (closest to furthest)
                        SWARMINSERT(aiBrain.StartReclaimListSorted, { Reclaim = v, Distance = v.Distance })  --insert into our sorted table with key of distance
                    end
                    SWARMSORT(aiBrain.StartReclaimListSorted, function(a,b) return a.Distance < b.Distance end) --sort the table by distance (closest to furthest)
                end
            else --if our sorted list is not empty...
                local startReclaim = GetReclaimablesInRect(posX - reclaimScanArea, posZ - reclaimScanArea, posX + reclaimScanArea, posZ + reclaimScanArea)
                if startReclaim and SWARMGETN(startReclaim) > 0 then --if there are still more reclaims in the area...
                    for k,v in startReclaim do --iterate through all of them and check if they're already in our list!  If they aren't... add them!   
                        if not IsProp(v) then continue end
                        if v.MaxMassReclaim and v.MaxMassReclaim >= minRec then --if it's a reclaim unit and it's worth more than 10 mass...
                            --LOG('High Value Reclaim is worth '..v.MaxMassReclaim)
                        	local rpos = v:GetCachePosition() --get the reclaim position
                        	local distance = VDist2( rpos[1], rpos[3], posX, posZ ) --calculate the distance from the main base to this reclaim
                        	if not SWARMCONTINENTALISM then  --if we're not running continentalism... (this is for when we're running multiple times in one game-session)   
                        	    if not aiBrain.StartReclaimListSorted[1] or aiBrain.StartReclaimListSorted[1].Distance > distance then --if the closest reclaim in our sorted list is farther away than this one...
                        	        SWARMINSERT(aiBrain.StartReclaimList, { Reclaim = v, Distance = distance }) --add it to the list of reclaimables
                        	    end
                        	else  --if we're running continentalism... (this is for when we're running multiple times in one game-session)   
                        	    if not aiBrain.StartReclaimListSorted[1] or aiBrain.StartReclaimListSorted[1].Distance > distance then --if the closest reclaim in our sorted list is farther away than this one...
                        	        SWARMINSERT(aiBrain.StartReclaimList, { Reclaim = v, Distance = distance }) --add it to the list of reclaimables
                                    else  --otherwise...
                                        local found = false
                                        for k,v in aiBrain.StartReclaimList do --iterate through all of them and check if they're already in our list!  If they aren't... add them!   
                                            if v.Reclaim == v then --if it's the same unit...
                                                found = true --we've found it!  Break out of the loop!
                                                break
                                            end
                        	        end

                        	        if not found then --if we didn't find it... (this is for when we're running multiple times in one game-session)  
                        	            SWARMINSERT(aiBrain.StartReclaimList, { Reclaim = v, Distance = distance }) --add it to the list of reclaimables
                        	        end
                                end
                        	end

                        end
                    end
                else --if there are no more reclaims in the area... (this is for when we're running multiple times in one game-session)   
                    aiBrain.StartReclaimListSorted = {} --create a new table that will be sorted by distance (so we can grab the closest ones first)
                    for k,v in aiBrain.StartReclaimList do --iterate through all of them and sort them by distance (closest to furthest)
                        SWARMINSERT(aiBrain.StartReclaimListSorted, { Reclaim = v, Distance = v.Distance })  --insert into our sorted table with key of distance
                    end
                    SWARMSORT(aiBrain.StartReclaimListSorted, function(a,b) return a.Distance < b.Distance end) --sort the table by distance (closest to furthest)
                end
            end
        end  --if not aiBrain.StartReclaimList[1] then

    
    if aiBrain.StartReclaimListSorted and SWARMGETN(aiBrain.StartReclaimListSorted) > 0 then --if we have something in our sorted list...
        local closest = aiBrain.StartReclaimListSorted[1]  --grab the closest one!   
        return closest.Distance, closest.Reclaim  --return it's distance and reclaim unit!   
    end
end