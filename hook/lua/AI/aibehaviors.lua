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
local PlatoonExists = moho.aibrain_methods.PlatoonExists

local SWARMGETN = table.getn
local SWARMSORT = table.sort
local SWARMINSERT = table.insert
local SWARMMIN = math.min
local SWARMMAX = math.max
local SWARMWAIT = coroutine.yield

-- 80% of the below was Sprouto's work
function StructureUpgradeThreadSwarm(unit, aiBrain, upgradeSpec, bypasseco) 
    --LOG('* AI-Swarm: Starting structure thread upgrade for'..aiBrain.Nickname)

    GetStartingReclaimSwarm(aiBrain)

    local unitBp = unit:GetBlueprint()
    local upgradeID = unitBp.General.UpgradesTo or false
    local upgradebp = false
    local unitType, unitTech = StructureTypeCheck(aiBrain, unitBp)

    if upgradeID then
        upgradebp = aiBrain:GetUnitBlueprint(upgradeID) or false
    end

    if not (upgradeID and upgradebp) then
        unit.UpgradeThread = nil
        unit.UpgradesComplete = true
        --LOG('* AI-Swarm: upgradeID or upgradebp is false, returning')
        return
    end

    local upgradeable = true
    local upgradeIssued = false

    if not bypasseco then
        local bypasseco = false
    end
    -- Eco requirements
    local massNeeded = upgradebp.Economy.BuildCostMass
	local energyNeeded = upgradebp.Economy.BuildCostEnergy
    local buildtime = upgradebp.Economy.BuildTime
    --LOG('Mass Needed '..massNeeded)
    --LOG('Energy Needed '..energyNeeded)
    -- build rate
    local buildrate = unitBp.Economy.BuildRate

    -- production while upgrading
    local massProduction = unitBp.Economy.ProductionPerSecondMass or 0
    local energyProduction = unitBp.Economy.ProductionPerSecondEnergy or 0
    
    local massTrendNeeded = ( SWARMMIN( 0,(massNeeded / buildtime) * buildrate) - massProduction) * .1
    --LOG('Mass Trend Needed for '..unitTech..' Extractor :'..massTrendNeeded)
    local energyTrendNeeded = ( SWARMMIN( 0,(energyNeeded / buildtime) * buildrate) - energyProduction) * .1
    --LOG('Energy Trend Needed for '..unitTech..' Extractor :'..energyTrendNeeded)
    local energyMaintenance = (upgradebp.Economy.MaintenanceConsumptionPerSecondEnergy or 10) * .1

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
    local extractorClosest = false
    local multiplier
    local initial_delay = 0
    local ecoStartTime = GetGameTimeSeconds()

    if aiBrain.CheatEnabled then
        multiplier = tonumber(ScenarioInfo.Options.BuildMult)
    else
        multiplier = 1
    end

    if unitTech == 'TECH1' and aiBrain.UpgradeMode == 'Aggressive' then
        ecoTimeOut = (320 / multiplier)
    elseif unitTech == 'TECH2' and aiBrain.UpgradeMode == 'Aggressive' then
        ecoTimeOut = (650 / multiplier)
    elseif unitTech == 'TECH1' and aiBrain.UpgradeMode == 'Normal' then
        ecoTimeOut = (420 / multiplier)
    elseif unitTech == 'TECH2' and aiBrain.UpgradeMode == 'Normal' then
        ecoTimeOut = (860 / multiplier)
    elseif unitTech == 'TECH1' and aiBrain.UpgradeMode == 'Caution' then
        ecoTimeOut = (420 / multiplier)
    elseif unitTech == 'TECH2' and aiBrain.UpgradeMode == 'Caution' then
        ecoTimeOut = (880 / multiplier)
    end

    --LOG('Multiplier is '..multiplier)
    --LOG('Initial Delay is before any multiplier is '..upgradeSpec.InitialDelay)
    --LOG('Initial Delay is '..(upgradeSpec.InitialDelay / multiplier))
    --LOG('Eco timeout for Tech '..unitTech..' Extractor is '..ecoTimeOut)
    --LOG('* AI-Swarm: Initial Variables set')
    while initial_delay < (upgradeSpec.InitialDelay / multiplier) do
		if GetEconomyStored( aiBrain, 'MASS') >= 50 and GetEconomyStored( aiBrain, 'ENERGY') >= 900 and unit:GetFractionComplete() == 1 then
            initial_delay = initial_delay + 10
            unit.InitialDelay = true
            if (GetGameTimeSeconds() - ecoStartTime) > ecoTimeOut then
                initial_delay = upgradeSpec.InitialDelay
            end
        end
        --LOG('* AI-Swarm: Initial Delay loop trigger for '..aiBrain.Nickname..' is : '..initial_delay..' out of 90')
		SWARMWAIT(100)
    end
    unit.InitialDelay = false

    -- Main Upgrade Loop
    while ((not unit.Dead) or unit.Sync.id) and upgradeable and not upgradeIssued do
        --LOG('* AI-Swarm: Upgrade main loop starting for'..aiBrain.Nickname)
        SWARMWAIT(upgradeSpec.UpgradeCheckWait * 10)
        upgradeSpec = aiBrain:GetUpgradeSpec(unit)
        --LOG('Upgrade Spec '..repr(upgradeSpec))
        --LOG('Current low mass trigger '..upgradeSpec.MassLowTrigger)
        if (GetGameTimeSeconds() - ecoStartTime) > ecoTimeOut then
            --LOG('Eco Bypass is True')
            bypasseco = true
        end
        if bypasseco and not (GetEconomyStored( aiBrain, 'MASS') > ( massNeeded * 1.6 ) and aiBrain.EconomyOverTimeCurrent.MassEfficiencyOverTime < 1.0 ) then
            upgradeNumLimit = StructureUpgradeNumDelay(aiBrain, unitType, unitTech)
            if unitTech == 'TECH1' then
                extractorUpgradeLimit = aiBrain.EcoManager.ExtractorUpgradeLimit.TECH1
            elseif unitTech == 'TECH2' then
                extractorUpgradeLimit = aiBrain.EcoManager.ExtractorUpgradeLimit.TECH2
            end
            --LOG('UpgradeNumLimit is '..upgradeNumLimit)
            --LOG('extractorUpgradeLimit is '..extractorUpgradeLimit)
            if upgradeNumLimit >= extractorUpgradeLimit then
                SWARMWAIT(10)
                continue
            end
        end



        extractorClosest = ExtractorClosest(aiBrain, unit, unitBp)
        if not extractorClosest then
            --LOG('ExtractorClosest is false')
            SWARMWAIT(10)
            continue
        end
        if (not unit.MAINBASE) or (unit.MAINBASE and not bypasseco and GetEconomyStored( aiBrain, 'MASS') < (massNeeded * 0.5)) then
            if HaveUnitRatio( aiBrain, 1.7, categories.MASSEXTRACTION * categories.TECH1, '>=', categories.MASSEXTRACTION * categories.TECH2 ) and unitTech == 'TECH2' then
                --LOG('Too few tech2 extractors to go tech3')
                ecoStartTime = ecoStartTime + upgradeSpec.UpgradeCheckWait
                SWARMWAIT(10)
                continue
            end
        end
        if unit.MAINBASE then
            --LOG('MAINBASE Extractor')
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
                            IssueUpgrade({unit}, upgradeID)

                            -- if upgrade issued and not completely full --
                            if massStorageRatio < 1 or energyStorageRatio < 1 then
                                ForkThread(StructureUpgradeDelay, aiBrain, aiBrain.UpgradeIssuedPeriod)  -- delay the next upgrade by the full amount
                            else
                                ForkThread(StructureUpgradeDelay, aiBrain, aiBrain.UpgradeIssuedPeriod * .5)     -- otherwise halve the delay period
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

		elseif (not unitbeingbuilt.Dead) then

            AssignUnitsToPlatoon( aiBrain, aiBrain.StructurePool, {unitbeingbuilt}, 'Support', 'none' )
		end
        unit.UpgradeThread = nil
	end
end

function StructureUpgradeDelay( aiBrain, delay )

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

function StructureUpgradeNumDelay(aiBrain, type, tech)
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

function StructureTypeCheck(aiBrain, unitBp)
    -- Returns the tech and type of a structure unit
    local unitType = false
    local unitTech = false
    for k, v in unitBp.Categories do
        if v == 'MASSEXTRACTION' then
            --LOG('Unit is Mass Extractor')
            unitType = 'MASSEXTRACTION'
        else
            --LOG('Value Not Mass Extraction')
        end

        if v == 'TECH1' then
            --LOG('Extractor is Tech 1')
            unitTech = 'TECH1'
        elseif v == 'TECH2' then
            --LOG('Extractor is Tech 2')
            unitTech = 'TECH2'
        else
            --LOG('Value not TECH1, TECH2')
        end
    end
    if unitType and unitTech then
       return unitType, unitTech
    else
        return false, false
    end
    return false, false
end

function ExtractorClosest(aiBrain, unit, unitBp)
    -- Checks if the unit is closest to the main base
    local MassExtractorUnitList = false
    local unitType, unitTech = StructureTypeCheck(aiBrain, unitBp)
    local BasePosition = aiBrain.BuilderManagers['MAIN'].Position
    local DistanceToBase = nil
    local LowestDistanceToBase = nil
    local UnitPos

    if unitType == 'MASSEXTRACTION' and unitTech == 'TECH1' then
        MassExtractorUnitList = GetListOfUnits(aiBrain, categories.MASSEXTRACTION * (categories.TECH1), false, false)
    elseif unitType == 'MASSEXTRACTION' and unitTech == 'TECH2' then
        MassExtractorUnitList = GetListOfUnits(aiBrain, categories.MASSEXTRACTION * (categories.TECH2), false, false)
    end

    for k, v in MassExtractorUnitList do
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
        if (not LowestDistanceToBase and v.InitialDelay == false) or (DistanceToBase < LowestDistanceToBase and v.InitialDelay == false) then
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
    --LOG('Reclaim Scan Area is '..reclaimScanArea)
    reclaimScanArea = SWARMMAX(50, reclaimScanArea)
    reclaimScanArea = SWARMMIN(120, reclaimScanArea)
    --Wait 10 seconds for the wrecks to become reclaim
    --SWARMWAIT(100)
    
    startReclaim = GetReclaimablesInRect(posX - reclaimScanArea, posZ - reclaimScanArea, posX + reclaimScanArea, posZ + reclaimScanArea)
    --LOG('Initial Reclaim Table size is '..SWARMGETN(startReclaim))
    if startReclaim and SWARMGETN(startReclaim) > 0 then
        for k,v in startReclaim do
            if not IsProp(v) then continue end
            if v.MaxMassReclaim and v.MaxMassReclaim >= minRec then
                --LOG('High Value Reclaim is worth '..v.MaxMassReclaim)
                local rpos = v:GetCachePosition()
                SWARMINSERT(reclaimTable, { Reclaim = v, Distance = VDist2( rpos[1], rpos[3], posX, posZ ) })
                --LOG('Distance to reclaim from main pos is '..VDist2( rpos[1], rpos[3], posX, posZ ))
                reclaimTotal = reclaimTotal + v.MaxMassReclaim
            end
        end
        --LOG('Sorting Reclaim table by distance ')
        SWARMSORT(reclaimTable, function(a,b) return a.Distance < b.Distance end)
        --LOG('Final Reclaim Table size is '..SWARMGETN(reclaimTable))
        aiBrain.StartReclaimTableSwarm = reclaimTable
        for k, v in aiBrain.StartReclaimTableSwarm do
            --LOG('Table entry distance is '..v.Distance)
        end
    end
    --LOG('Complete Get Starting Reclaim')
end