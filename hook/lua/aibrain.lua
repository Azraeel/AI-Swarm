WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aibrain.lua' )

local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')
local AIUtils = import('/lua/ai/AIUtilities.lua')
local AIBehaviors = import('/lua/ai/AIBehaviors.lua')

local lastCall = 0
local SWARMGETN = table.getn
local SWARMINSERT = table.insert
local SWARMREMOVE = table.remove
local SWARMMIN = math.min
local SWARMMAX = math.max
local SWARMWAIT = coroutine.yield

local VDist2Sq = VDist2Sq

local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome
local GetEconomyRequested = moho.aibrain_methods.GetEconomyRequested
local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
local GiveResource = moho.aibrain_methods.GiveResource
local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
local GetThreatsAroundPosition = moho.aibrain_methods.GetThreatsAroundPosition
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt
local GetConsumptionPerSecondMass = moho.unit_methods.GetConsumptionPerSecondMass
local GetConsumptionPerSecondEnergy = moho.unit_methods.GetConsumptionPerSecondEnergy
local GetProductionPerSecondMass = moho.unit_methods.GetProductionPerSecondMass
local GetProductionPerSecondEnergy = moho.unit_methods.GetProductionPerSecondEnergy
local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend
local GetEconomyStoredRatio = moho.aibrain_methods.GetEconomyStoredRatio

SwarmAIBrainClass = AIBrain
AIBrain = Class(SwarmAIBrainClass) {

    OnCreateAI = function(self, planName)
        SwarmAIBrainClass.OnCreateAI(self, planName)

        local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality

        if string.find(per, 'swarm') then

            --LOG('* AI-Swarm: OnCreateAI() found AI-Swarm  Name: ('..self.Name..') - personality: ('..per..') ')
            local ALLBPS = __blueprints

            self.Swarm = true
            self:ForkThread(self.ParseIntelThreadSwarm)
            self:ForkThread(self.StrategicMonitorThreadSwarm, ALLBPS)
            self:ForkThread(SwarmUtils.CountSoonMassSpotsSwarm)

        end

    end,

    InitializeSkirmishSystems = function(self)
        if not self.Swarm then
            SwarmAIBrainClass.InitializeSkirmishSystems(self)
        end

        --LOG('* AI-Swarm: Custom Skirmish System for '..ScenarioInfo.ArmySetup[self.Name].AIPersonality)
        -- Make sure we don't do anything for the human player!!!
        if self.BrainType == 'Human' then
            return
        end

        -- TURNING OFF AI POOL PLATOON, I MAY JUST REMOVE THAT PLATOON FUNCTIONALITY LATER
        local poolPlatoon = self:GetPlatoonUniquelyNamed('ArmyPool')
        if poolPlatoon then
            poolPlatoon:TurnOffPoolAI()
        end

        local mapSizeX, mapSizeZ = GetMapSize()
        -- Stores handles to all builders for quick iteration and updates to all
        self.BuilderHandles = {}
        self.MapCenterPointSwarm = { (ScenarioInfo.size[1] / 2), 0 ,(ScenarioInfo.size[2] / 2) }
        self.GraphZonesSwarm = { 
            FirstRun = true,
            HasRun = false
        }
        self.ExpansionWatchTableSwarm = {}
        self.IMAPConfigSwarm = {
            OgridRadius = 0,
            IMAPSize = 0,
            Rings = 0,
        }

        -- Condition monitor for the whole brain
        self.ConditionsMonitor = BrainConditionsMonitor.CreateConditionsMonitor(self)

        -- Add default main location and setup the builder managers
        self.NumBases = 0 -- AddBuilderManagers will increase the number

        self:IMAPConfigurationSwarm()
        -- Begin the base monitor process

        self.BuilderManagers = {}
        SUtils.AddCustomUnitSupport(self)
        self:AddBuilderManagers(self:GetStartVector3f(), 100, 'MAIN', false)

        self:BaseMonitorInitializationSwarm()
        local plat = self:GetPlatoonUniquelyNamed('ArmyPool')
        plat:ForkThread(plat.BaseManagersDistressAISwarm)

        self.DeadBaseThread = self:ForkThread(self.DeadBaseMonitor)

        self.EnemyPickerThread = self:ForkThread(self.PickEnemy)

        -- Economy monitor for new skirmish - stores out econ over time to get trend over 10 seconds
        self.EconomyDataSwarm = {}
        self.EconomyTicksMonitor = 80
        self.EconomyCurrentTick = 1
        --LOG("Starting EconomyMonitorSwarm")
        self.EconomyMonitorThreadSwarm = self:ForkThread(self.EconomyMonitorSwarm)
        --LOG("EconomyMonitorSwarm Started")
        self.EconomyOverTimeCurrent = {}

        self:ForkThread(SwarmUtils.AIConfigureExpansionWatchTableSwarm)
        self:ForkThread(self.ExpansionIntelScanSwarm)
        self:ForkThread(SwarmUtils.DisplayMarkerAdjacencySwarm)
        self:ForkThread(self.EcoExtractorUpgradeCheckSwarm)
        self.EcoManager = {
            EcoManagerTime = 30,
            EcoManagerStatus = 'ACTIVE',
            ExtractorUpgradeLimit = {
                TECH1 = 1,
                TECH2 = 1
            },
            ExtractorsUpgrading = {TECH1 = 0, TECH2 = 0},
            EcoMultiplier = 1,
        }

        self.StartReclaimTableSwarm = {}
        self.StartReclaimTakenSwarm = false

        self.UpgradeMode = 'Normal'
        self.UpgradeIssued = 0
        self.UpgradeIssuedPeriod = 100

        -- Misc
        self.ReclaimEnabledSwarm = true
        self.ReclaimLastCheckSwarm = 0

        if mapSizeX < 1000 and mapSizeZ < 1000  then
            self.UpgradeIssuedLimit = 1
            self.EcoManager.ExtractorUpgradeLimit.TECH1 = 1
        else
            self.UpgradeIssuedLimit = 2
            self.EcoManager.ExtractorUpgradeLimit.TECH1 = 2
        end

        self.cmanager = {}
        self.EnemyThreatCurrentSwarm = {
            EnemyAir = 0,
            EnemyAntiAir = 0,
            EnemyLand = 0,
            EnemyExperimental = 0,
            EnemyExtractor = 0,
            EnemyExtractorCount = 0,
            EnemyNaval = 0,
            EnemyNavalSub = 0,
            EnemyDefenseAir = 0,
            EnemyDefenseSurface = 0,
            EnemyDefenseSub = 0,
            EnemyACUGunUpgrades = 0,
        }
        self.SelfThreatSwarm = {
            SelfExtractor = 0,
            SelfExtractorCount = 0,
            SelfMassMarker = 0,
            SelfMassMarkerBuildable = 0,
            SelfAllyExtractorCount = 0,
            SelfAllyExtractor = 0,
            SelfAllyLandThreat = 0,
            SelfAntiAirNow = 0,
            SelfAirNow = 0,
            SelfLandNow = 0,
            SelfNavalNow = 0,
            SelfNavalSubNow = 0,
        }
        self.EnemyACU = {}
        for _, v in ArmyBrains do
            self.EnemyACU[v:GetArmyIndex()] = {
                Position = {},
                LastSpotted = 0,
                Threat = 0,
                Hp = 0,
                OnField = false,
                Gun = false,
            }
        end

        self.StructurePool = self:MakePlatoon('StructurePool', 'none')
        self.StructurePool:UniquelyNamePlatoon('StructurePool')
        self.FactoryPool = self:MakePlatoon('FactoryPool', 'none')
        self.FactoryPool:UniquelyNamePlatoon('FactoryPool')
        --return
    end,

    OnSpawnPreBuiltUnits = function(self)
        if not self.Swarm then
            return SwarmAIBrainClass.OnSpawnPreBuiltUnits(self)
        end
        local factionIndex = self:GetFactionIndex()
        local resourceStructures = nil
        local initialUnits = nil
        local posX, posY = self:GetArmyStartPos()

        if factionIndex == 1 then
            resourceStructures = {'UEB1103', 'UEB1103', 'UEB1103', 'UEB1103'}
            initialUnits = {'UEB0101', 'UEB1101', 'UEB1101', 'UEB1101', 'UEB1101'}
        elseif factionIndex == 2 then
            resourceStructures = {'UAB1103', 'UAB1103', 'UAB1103', 'UAB1103'}
            initialUnits = {'UAB0101', 'UAB1101', 'UAB1101', 'UAB1101', 'UAB1101'}
        elseif factionIndex == 3 then
            resourceStructures = {'URB1103', 'URB1103', 'URB1103', 'URB1103'}
            initialUnits = {'URB0101', 'URB1101', 'URB1101', 'URB1101', 'URB1101'}
        elseif factionIndex == 4 then
            resourceStructures = {'XSB1103', 'XSB1103', 'XSB1103', 'XSB1103'}
            initialUnits = {'XSB0101', 'XSB1101', 'XSB1101', 'XSB1101', 'XSB1101'}
        end

        if resourceStructures then
            -- Place resource structures down
            for k, v in resourceStructures do
                local unit = self:CreateResourceBuildingNearest(v, posX, posY)
                local unitBp = unit:GetBlueprint()
                if unit ~= nil and unitBp.Physics.FlattenSkirt then
                    unit:CreateTarmac(true, true, true, false, false)
                end
                if unit ~= nil then
                    if not self.StructurePool then
                        SwarmUtils.CheckCustomPlatoonsSwarm(self)
                    end
                    local StructurePool = self.StructurePool
                    self:AssignUnitsToPlatoon(StructurePool, {unit}, 'Support', 'none' )
                    local upgradeID = unitBp.General.UpgradesTo or false
                    --LOG('* AI-Swarm: BlueprintID to upgrade to is : '..unitBp.General.UpgradesTo)
                    if upgradeID and __blueprints[upgradeID] then
                        SwarmUtils.StructureUpgradeInitializeSwarm(unit, self)
                    end
                    local unitTable = StructurePool:GetPlatoonUnits()
                    --LOG('* AI-Swarm: StructurePool now has :'..SWARMGETN(unitTable))
                end
            end
        end

        if initialUnits then
            -- Place initial units down
            for k, v in initialUnits do
                local unit = self:CreateUnitNearSpot(v, posX, posY)
                if unit ~= nil and unit:GetBlueprint().Physics.FlattenSkirt then
                    unit:CreateTarmac(true, true, true, false, false)
                end
            end
        end

        self.PreBuilt = true
    end,

    EconomyMonitor = function(self)

        if not self.Swarm then
            return SwarmAIBrainClass.EconomyMonitor(self)
        end

        SWARMWAIT(10)

        KillThread(CurrentThread())
    end,

    ExpansionHelpThread = function(self)

        if not self.Swarm then
            return SwarmAIBrainClass.ExpansionHelpThread(self)
        end

        SWARMWAIT(10)

        KillThread(CurrentThread())
    end,

    OnIntelChange = function(self, blip, reconType, val)

        if not self.Swarm then
            return SwarmAIBrainClass.OnIntelChange(self, blip, reconType, val)
        end

    end,

    SetupAttackVectorsThread = function(self)

        if not self.Swarm then
            return SwarmAIBrainClass.SetupAttackVectorsThread(self)
        end

        SWARMWAIT(10)

        KillThread(CurrentThread())
    end,

    StrategicMonitorThreadSwarm = function(self, ALLBPS)

        while true do 

            self:SelfThreatCheckSwarm(ALLBPS)
            self:EnemyThreatCheckSwarm(ALLBPS)
            self:EconomyTacticalMonitorSwarm(ALLBPS)
            self:CalculateMassMarkersSwarm()

        end
        SWARMWAIT(30)
    end,

    -- Spicy Sprouto Code Magic
    EconomyMonitorSwarm = function(self)
        --LOG("EconomyMonitor is Started Fully & Running")
        -- This over time thread is based on Sprouto's LOUD AI.
        self.EconomyDataSwarm = { ['EnergyIncome'] = {}, ['EnergyRequested'] = {}, ['EnergyStorage'] = {}, ['EnergyTrend'] = {}, ['MassIncome'] = {}, ['MassRequested'] = {}, ['MassStorage'] = {}, ['MassTrend'] = {}, ['Period'] = 300 }
        -- number of sample points
        -- local point
        local samplerate = 10
        local samples = self.EconomyDataSwarm['Period'] / samplerate
    
        -- create the table to store the samples
        for point = 1, samples do
            self.EconomyDataSwarm['EnergyIncome'][point] = 0
            self.EconomyDataSwarm['EnergyRequested'][point] = 0
            self.EconomyDataSwarm['EnergyStorage'][point] = 0
            self.EconomyDataSwarm['EnergyTrend'][point] = 0
            self.EconomyDataSwarm['MassIncome'][point] = 0
            self.EconomyDataSwarm['MassRequested'][point] = 0
            self.EconomyDataSwarm['MassStorage'][point] = 0
            self.EconomyDataSwarm['MassTrend'][point] = 0
        end    
    
        local SWARMMIN = math.min
        local SWARMMAX = math.max
        local SWARMWAIT = coroutine.yield
    
        -- array totals
        local eIncome = 0
        local mIncome = 0
        local eRequested = 0
        local mRequested = 0
        local eStorage = 0
        local mStorage = 0
        local eTrend = 0
        local mTrend = 0
    
        -- this will be used to multiply the totals
        -- to arrive at the averages
        local samplefactor = 1/samples
    
        local EcoData = self.EconomyDataSwarm
    
        local EcoDataEnergyIncome = EcoData['EnergyIncome']
        local EcoDataMassIncome = EcoData['MassIncome']
        local EcoDataEnergyRequested = EcoData['EnergyRequested']
        local EcoDataMassRequested = EcoData['MassRequested']
        local EcoDataEnergyTrend = EcoData['EnergyTrend']
        local EcoDataMassTrend = EcoData['MassTrend']
        local EcoDataEnergyStorage = EcoData['EnergyStorage']
        local EcoDataMassStorage = EcoData['MassStorage']
        
        local e,m
    
        while true do
            --LOG("EconomyMonitor is Looping Properly")
            for point = 1, samples do
    
                -- remove this point from the totals
                eIncome = eIncome - EcoDataEnergyIncome[point]
                mIncome = mIncome - EcoDataMassIncome[point]
                eRequested = eRequested - EcoDataEnergyRequested[point]
                mRequested = mRequested - EcoDataMassRequested[point]
                eTrend = eTrend - EcoDataEnergyTrend[point]
                mTrend = mTrend - EcoDataMassTrend[point]
                
                -- insert the new data --
                EcoDataEnergyIncome[point] = GetEconomyIncome( self, 'ENERGY')
                EcoDataMassIncome[point] = GetEconomyIncome( self, 'MASS')
                EcoDataEnergyRequested[point] = GetEconomyRequested( self, 'ENERGY')
                EcoDataMassRequested[point] = GetEconomyRequested( self, 'MASS')
    
                e = GetEconomyTrend( self, 'ENERGY')
                m = GetEconomyTrend( self, 'MASS')
    
                if e then
                    EcoDataEnergyTrend[point] = e
                else
                    EcoDataEnergyTrend[point] = 0.1
                end
                
                if m then
                    EcoDataMassTrend[point] = m
                else
                    EcoDataMassTrend[point] = 0.1
                end
    
                -- add the new data to totals
                eIncome = eIncome + EcoDataEnergyIncome[point]
                mIncome = mIncome + EcoDataMassIncome[point]
                eRequested = eRequested + EcoDataEnergyRequested[point]
                mRequested = mRequested + EcoDataMassRequested[point]
                eTrend = eTrend + EcoDataEnergyTrend[point]
                mTrend = mTrend + EcoDataMassTrend[point]
                
                -- calculate new OverTime values --
                self.EconomyOverTimeCurrent.EnergyIncome = eIncome * samplefactor
                self.EconomyOverTimeCurrent.MassIncome = mIncome * samplefactor
                self.EconomyOverTimeCurrent.EnergyRequested = eRequested * samplefactor
                self.EconomyOverTimeCurrent.MassRequested = mRequested * samplefactor
                self.EconomyOverTimeCurrent.EnergyEfficiencyOverTime = SWARMMIN( (eIncome * samplefactor) / (eRequested * samplefactor), 2)
                self.EconomyOverTimeCurrent.MassEfficiencyOverTime = SWARMMIN( (mIncome * samplefactor) / (mRequested * samplefactor), 2)
                self.EconomyOverTimeCurrent.EnergyTrendOverTime = eTrend * samplefactor
                self.EconomyOverTimeCurrent.MassTrendOverTime = mTrend * samplefactor
                
                SWARMWAIT(samplerate)
            end
        end
    end,

    GetUpgradeSpecSwarm = function(self, unit)
        local upgradeSpec = {}
        
        if EntityCategoryContains(categories.MASSEXTRACTION, unit) then
            --LOG("What is unit " .. repr(unit))
            --LOG("Are we reaching this point? GetUpgradeSpecSwarmMassExtractor")
            if self.UpgradeMode == 'Aggressive' then
                upgradeSpec.MassLowTrigger = 0.80
                upgradeSpec.EnergyLowTrigger = 1.0
                upgradeSpec.MassHighTrigger = 2.0
                upgradeSpec.EnergyHighTrigger = 2.0
                upgradeSpec.UpgradeCheckWait = 18
                upgradeSpec.InitialDelay = 40
                upgradeSpec.EnemyThreatLimit = 10
                return upgradeSpec
            elseif self.UpgradeMode == 'Normal' then
                upgradeSpec.MassLowTrigger = 0.90
                upgradeSpec.EnergyLowTrigger = 1.05
                upgradeSpec.MassHighTrigger = 2.0
                upgradeSpec.EnergyHighTrigger = 2.0
                upgradeSpec.UpgradeCheckWait = 18
                upgradeSpec.InitialDelay = 60
                upgradeSpec.EnemyThreatLimit = 5
                return upgradeSpec
            elseif self.UpgradeMode == 'Caution' then
                upgradeSpec.MassLowTrigger = 1.0
                upgradeSpec.EnergyLowTrigger = 1.10
                upgradeSpec.MassHighTrigger = 2.0
                upgradeSpec.EnergyHighTrigger = 2.0
                upgradeSpec.UpgradeCheckWait = 18
                upgradeSpec.InitialDelay = 80
                upgradeSpec.EnemyThreatLimit = 0
                return upgradeSpec
            end
        elseif EntityCategoryContains(categories.FACTORY * categories.STRUCTURE, unit) then
            --LOG("What is unit " .. repr(unit))
            --LOG("Are we reaching this point? GetUpgradeSpecSwarmFactory")
            if self.UpgradeMode == 'Aggressive' then
                upgradeSpec.MassLowTrigger = 1.0
                upgradeSpec.EnergyLowTrigger = 1.0
                upgradeSpec.MassHighTrigger = 2.0
                upgradeSpec.EnergyHighTrigger = 2.0
                upgradeSpec.UpgradeCheckWait = 24
                upgradeSpec.InitialDelay = 30
                upgradeSpec.EnemyThreatLimit = 10
                return upgradeSpec
            elseif self.UpgradeMode == 'Normal' then
                upgradeSpec.MassLowTrigger = 1.015
                upgradeSpec.EnergyLowTrigger = 1.015
                upgradeSpec.MassHighTrigger = 2.0
                upgradeSpec.EnergyHighTrigger = 2.0
                upgradeSpec.UpgradeCheckWait = 24
                upgradeSpec.InitialDelay = 60
                upgradeSpec.EnemyThreatLimit = 5
                return upgradeSpec
            elseif self.UpgradeMode == 'Caution' then
                upgradeSpec.MassLowTrigger = 1.035
                upgradeSpec.EnergyLowTrigger = 1.035
                upgradeSpec.MassHighTrigger = 2.0
                upgradeSpec.EnergyHighTrigger = 2.0
                upgradeSpec.UpgradeCheckWait = 24
                upgradeSpec.InitialDelay = 90
                upgradeSpec.EnemyThreatLimit = 0
                return upgradeSpec
            end
        else
            --LOG('* AI-Swarm: Unit is not Mass Extractor or Factory')
            upgradeSpec = false
            return upgradeSpec
        end
    end,

    EcoExtractorUpgradeCheckSwarm = function(self)
        -- Keep track of how many extractors are currently upgrading
            SWARMWAIT(5)
            while true do
                local upgradingExtractors = SwarmUtils.ExtractorsBeingUpgradedSwarm(self)
                self.EcoManager.ExtractorsUpgrading.TECH1 = upgradingExtractors.TECH1
                self.EcoManager.ExtractorsUpgrading.TECH2 = upgradingExtractors.TECH2
                SWARMWAIT(30)
            end
        end,

    UnderEnergyThreshold = function(self)
        if not self.Swarm then
            return SwarmAIBrainClass.UnderEnergyThreshold(self)
        end
    end,

    OverEnergyThreshold = function(self)
        if not self.Swarm then
            return SwarmAIBrainClass.OverEnergyThreshold(self)
        end
    end,

    UnderMassThreshold = function(self)
        if not self.Swarm then
            return SwarmAIBrainClass.UnderMassThreshold(self)
        end
    end,

    OverMassThreshold = function(self)
        if not self.Swarm then
            return SwarmAIBrainClass.OverMassThreshold(self)
        end
    end,

    EconomyTacticalMonitorSwarm = function(self, ALLBPS)

        SWARMWAIT(5)

        if self.CheatEnabled then
            multiplier = tonumber(ScenarioInfo.Options.BuildMult)
        else
            multiplier = 1
        end

        local gameTime = GetGameTimeSeconds()
        --LOG('gameTime is '..gameTime..' Upgrade Mode is '..self.UpgradeMode)
        if gameTime < (240 / multiplier) then
            self.UpgradeMode = 'Caution'
        elseif gameTime > (240 / multiplier) and self.UpgradeMode == 'Caution' then
            self.UpgradeMode = 'Normal'
            self.UpgradeIssuedLimit = 1
        elseif gameTime > (240 / multiplier) and self.UpgradeIssuedLimit == 1 and self.UpgradeMode == 'Aggressive' then
            self.UpgradeIssuedLimit = self.UpgradeIssuedLimit + 1
        end

        if (gameTime > 1200 and self.SelfAllyExtractor > self.MassMarker / 1.5) then
            --LOG('Switch to agressive upgrade mode')
            self.UpgradeMode = 'Aggressive'
            self.EcoManager.ExtractorUpgradeLimit.TECH1 = 2
        elseif gameTime > 1200 then
            --LOG('Switch to normal upgrade mode')
            self.UpgradeMode = 'Normal'
            self.EcoManager.ExtractorUpgradeLimit.TECH1 = 1
        end
        SWARMWAIT(2)
    end,

    CalculateMassMarkersSwarm = function(self)
        local MassMarker = {}
        local massMarkerBuildable = 0
        local markerCount = 0
        local graphCheck = false
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    -- mass marker is too close to border, skip it.
                    continue
                end 
                if v.SwarmArea and not self.GraphZonesSwarm.FirstRun and not self.GraphZonesSwarm.HasRun then
                    graphCheck = true
                    if not self.GraphZonesSwarm[v.SwarmArea] then
                        self.GraphZonesSwarm[v.SwarmArea] = {}
                        if self.GraphZonesSwarm[v.SwarmArea].MassMarkersInZone == nil then
                            self.GraphZonesSwarm[v.SwarmArea].MassMarkersInZone = 0
                        end
                    end
                    self.GraphZonesSwarm[v.SwarmArea].MassMarkersInZone = self.GraphZonesSwarm[v.SwarmArea].MassMarkersInZone + 1
                end
                if CanBuildStructureAt(self, 'ueb1103', v.position) then
                    massMarkerBuildable = massMarkerBuildable + 1
                end
                markerCount = markerCount + 1
                SWARMINSERT(MassMarker, v)
            end
        end
        if graphCheck then
            self.GraphZonesSwarm.HasRun = true
        end
        self.MassMarker = markerCount
        self.MassMarkerBuildable = massMarkerBuildable
    end,

    BaseMonitorThreadSwarm = function(self)
        while true do
            if self.BaseMonitor.BaseMonitorStatus == 'ACTIVE' then
                self:BaseMonitorCheckSwarm()
            end
            WaitSeconds(self.BaseMonitor.BaseMonitorTime)
        end
    end,

    BaseMonitorInitializationSwarm = function(self, spec)
        self.BaseMonitor = {
            BaseMonitorStatus = 'ACTIVE',
            BaseMonitorPoints = {},
            AlertSounded = false,
            AlertsTable = {},
            AlertLocation = false,
            AlertSoundedThreat = 0,
            ActiveAlerts = 0,

            PoolDistressRange = 75,
            PoolReactionTime = 7,

            -- Variables for checking a radius for enemy units
            UnitRadiusThreshold = spec.UnitRadiusThreshold or 3,
            UnitCategoryCheck = spec.UnitCategoryCheck or (categories.MOBILE - (categories.SCOUT + categories.ENGINEER)),
            UnitCheckRadius = spec.UnitCheckRadius or 40,

            -- Threat level must be greater than this number to sound a base alert
            AlertLevel = spec.AlertLevel or 0,
            -- Delay time for checking base
            BaseMonitorTime = spec.BaseMonitorTime or 11,
            -- Default distance a platoon will travel to help around the base
            DefaultDistressRange = spec.DefaultDistressRange or 75,
            -- Default how often platoons will check if the base is under duress
            PlatoonDefaultReactionTime = spec.PlatoonDefaultReactionTime or 5,
            -- Default duration for an alert to time out
            DefaultAlertTimeout = spec.DefaultAlertTimeout or 10,

            PoolDistressThreshold = 1,

            -- Monitor platoons for help
            PlatoonDistressTable = {},
            PlatoonDistressThread = false,
            PlatoonAlertSounded = false,
        }
        self:ForkThread(self.BaseMonitorThreadSwarm)
    end,

    GetStructureVectorsSwarm = function(self)
        local structures = GetListOfUnits(self, categories.STRUCTURE - categories.WALL - categories.MASSEXTRACTION, false)
        -- Add all points around location
        local tempGridPoints = {}
        local indexChecker = {}

        for k, v in structures do
            if not v.Dead then
                local pos = AIUtils.GetUnitBaseStructureVector(v)
                if pos then
                    if not indexChecker[pos[1]] then
                        indexChecker[pos[1]] = {}
                    end
                    if not indexChecker[pos[1]][pos[3]] then
                        indexChecker[pos[1]][pos[3]] = true
                        SWARMINSERT(tempGridPoints, pos)
                    end
                end
            end
        end

        return tempGridPoints
    end,

    BaseMonitorCheckSwarm = function(self)
        
        local gameTime = GetGameTimeSeconds()
        if gameTime < 300 then
            -- default monitor spec
        elseif gameTime > 300 then
            self.BaseMonitor.PoolDistressRange = 130
            self.AlertLevel = 5
        end

        local vecs = self:GetStructureVectorsSwarm()
        if SWARMGETN(vecs) > 0 then
            -- Find new points to monitor
            for k, v in vecs do
                local found = false
                for subk, subv in self.BaseMonitor.BaseMonitorPoints do
                    if v[1] == subv.Position[1] and v[3] == subv.Position[3] then
                        found = true
                        -- if we found this point already stored, we don't need to continue searching the rest
                        break
                    end
                end
                if not found then
                    SWARMINSERT(self.BaseMonitor.BaseMonitorPoints,
                        {
                            Position = v,
                            Threat = GetThreatAtPosition(self, v, 0, true, 'Land'),
                            Alert = false
                        }
                    )
                end
            end
            --LOG('BaseMonitorPoints Threat Data '..repr(self.BaseMonitor.BaseMonitorPoints))
            -- Remove any points that we dont monitor anymore
            for k, v in self.BaseMonitor.BaseMonitorPoints do
                local found = false
                for subk, subv in vecs do
                    if v.Position[1] == subv[1] and v.Position[3] == subv[3] then
                        found = true
                        break
                    end
                end
                -- If point not in list and the num units around the point is small
                if not found and self:GetNumUnitsAroundPoint(categories.STRUCTURE, v.Position, 16, 'Ally') <= 1 then
                    SWARMREMOVE(self.BaseMonitor.BaseMonitorPoints, k)
                end
            end
            -- Check monitor points for change
            local alertThreat = self.BaseMonitor.AlertLevel
            for k, v in self.BaseMonitor.BaseMonitorPoints do
                if not v.Alert then
                    v.Threat = GetThreatAtPosition(self, v.Position, 0, true, 'Land')
                    if v.Threat > alertThreat then
                        v.Alert = true
                        SWARMINSERT(self.BaseMonitor.AlertsTable,
                            {
                                Position = v.Position,
                                Threat = v.Threat,
                            }
                        )
                        self.BaseMonitor.AlertSounded = true
                        self:ForkThread(self.BaseMonitorAlertTimeout, v.Position)
                        self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts + 1
                    end
                end
            end
        end
    end,

    BaseMonitorPlatoonDistressSwarm = function(self, platoon, threat)
        if not self.BaseMonitor then
            return
        end

        local found = false
        if self.BaseMonitor.PlatoonAlertSounded == false then
            SWARMINSERT(self.BaseMonitor.PlatoonDistressTable, {Platoon = platoon, Threat = threat})
        else
            for k, v in self.BaseMonitor.PlatoonDistressTable do
                -- If already calling for help, don't add another distress call
                if table.equal(v.Platoon, platoon) then
                    --LOG('platoon.BuilderName '..platoon.BuilderName..'already exist as '..v.Platoon.BuilderName..' skipping')
                    found = true
                    break
                end
            end
            if not found then
                --LOG('Platoon doesnt already exist, adding')
                SWARMINSERT(self.BaseMonitor.PlatoonDistressTable, {Platoon = platoon, Threat = threat})
            end
        end
        -- Create the distress call if it doesn't exist
        if not self.BaseMonitor.PlatoonDistressThread then
            self.BaseMonitor.PlatoonDistressThread = self:ForkThread(self.BaseMonitorPlatoonDistressThreadSwarm)
        end
        --LOG('Platoon Distress Table'..repr(self.BaseMonitor.PlatoonDistressTable))
    end,

    BaseMonitorPlatoonDistressThreadSwarm = function(self)
        self.BaseMonitor.PlatoonAlertSounded = true
        while true do
            local numPlatoons = 0
            for k, v in self.BaseMonitor.PlatoonDistressTable do
                if self:PlatoonExists(v.Platoon) then
                    local threat = GetThreatAtPosition(self, v.Platoon:GetPlatoonPosition(), 0, true, 'Land')
                    local myThreat = GetThreatAtPosition(self, v.Platoon:GetPlatoonPosition(), 0, true, 'Overall', self:GetArmyIndex())
                    --LOG('* AI-Swarm: Threat of attacker'..threat)
                    --LOG('* AI-Swarm: Threat of platoon'..myThreat)
                    -- Platoons still threatened
                    if threat and threat > (myThreat * 1.5) then
                        --LOG('* AI-Swarm: Created Threat Alert')
                        v.Threat = threat
                        numPlatoons = numPlatoons + 1
                    -- Platoon not threatened
                    else
                        self.BaseMonitor.PlatoonDistressTable[k] = nil
                        v.Platoon.DistressCall = false
                    end
                else
                    self.BaseMonitor.PlatoonDistressTable[k] = nil
                end
            end

            -- If any platoons still want help; continue sounding
            --LOG('Alerted Platoons '..numPlatoons)
            if numPlatoons > 0 then
                self.BaseMonitor.PlatoonAlertSounded = true
            else
                self.BaseMonitor.PlatoonAlertSounded = false
            end
            self.BaseMonitor.PlatoonDistressTable = self:RebuildTable(self.BaseMonitor.PlatoonDistressTable)
            --LOG('Platoon Distress Table'..repr(self.BaseMonitor.PlatoonDistressTable))
            WaitSeconds(self.BaseMonitor.BaseMonitorTime)
        end
    end,

    BaseMonitorDistressLocationSwarm = function(self, position, radius, threshold)
        local returnPos = false
        local highThreat = false
        local distance
        
        if self.BaseMonitor.AlertSounded then
            --LOG('Base Alert Sounded')
            for k, v in self.BaseMonitor.AlertsTable do
                local tempDist = VDist2(position[1], position[3], v.Position[1], v.Position[3])

                -- Too far away
                if tempDist > radius then
                    continue
                end

                -- Not enough threat in location
                if v.Threat < threshold then
                    continue
                end

                -- Threat lower than or equal to a threat we already have
                if v.Threat <= highThreat then
                    continue
                end

                -- Get real height
                local height = GetTerrainHeight(v.Position[1], v.Position[3])
                local surfHeight = GetSurfaceHeight(v.Position[1], v.Position[3])
                if surfHeight > height then
                    height = surfHeight
                end

                -- currently our winner in high threat
                returnPos = {v.Position[1], height, v.Position[3]}
                distance = tempDist
            end
        end
        if self.BaseMonitor.PlatoonAlertSounded then
            --LOG('Platoon Alert Sounded')
            for k, v in self.BaseMonitor.PlatoonDistressTable do
                if self:PlatoonExists(v.Platoon) then
                    local platPos = v.Platoon:GetPlatoonPosition()
                    if not platPos then
                        self.BaseMonitor.PlatoonDistressTable[k] = nil
                        continue
                    end
                    local tempDist = VDist2(position[1], position[3], platPos[1], platPos[3])

                    -- Platoon too far away to help
                    if tempDist > radius then
                        continue
                    end

                    -- Area not scary enough
                    if v.Threat < threshold then
                        continue
                    end

                    -- Further away than another call for help
                    if tempDist > distance then
                        continue
                    end

                    -- Our current winners
                    returnPos = platPos
                    distance = tempDist
                end
            end
        end
        return returnPos
    end,

    BuildScoutLocationsSwarm = function(self)
        local aiBrain = self
        local opponentStarts = {}
        local allyStarts = {}

        if not aiBrain.InterestList then
            aiBrain.InterestList = {}
            aiBrain.IntelData.HiPriScouts = 0
            aiBrain.IntelData.AirHiPriScouts = 0
            aiBrain.IntelData.AirLowPriScouts = 0

            -- Add each enemy's start location to the InterestList as a new sub table
            aiBrain.InterestList.HighPriority = {}
            aiBrain.InterestList.LowPriority = {}
            aiBrain.InterestList.MustScout = {}

            local myArmy = ScenarioInfo.ArmySetup[self.Name]
            local MarkerList = AIUtils.AIGetMarkerLocations(aiBrain, 'Mass')

            if MarkerList >= 1 then 
                do
                SWARMINSERT(aiBrain.InterestList.HighPriority,
                    {
                        Position = MarkerList,
                        LastScouted = 0,
                    }
                )
                end
            end
                
            if ScenarioInfo.Options.TeamSpawn == 'fixed' then
                -- Spawn locations were fixed. We know exactly where our opponents are.
                -- Don't scout areas owned by us or our allies.
                local numOpponents = 0
                for i = 1, 16 do
                    local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
                    local startPos = ScenarioUtils.GetMarker('ARMY_' .. i).position
                    if army and startPos then
                        if army.ArmyIndex ~= myArmy.ArmyIndex and (army.Team ~= myArmy.Team or army.Team == 1) then
                        -- Add the army start location to the list of interesting spots.
                        opponentStarts['ARMY_' .. i] = startPos
                        numOpponents = numOpponents + 1
                        SWARMINSERT(aiBrain.InterestList.HighPriority,
                            {
                                Position = startPos,
                                LastScouted = 0,
                            }
                        )
                        else
                            allyStarts['ARMY_' .. i] = startPos
                        end
                    end
                end

                aiBrain.NumOpponents = numOpponents

                -- For each vacant starting location, check if it is closer to allied or enemy start locations (within 100 ogrids)
                -- If it is closer to enemy territory, flag it as high priority to scout.
                local starts = AIUtils.AIGetMarkerLocations(aiBrain, 'Start Location')
                for _, loc in starts do
                    -- If vacant
                    if not opponentStarts[loc.Name] and not allyStarts[loc.Name] then
                        local closestDistSq = 999999999
                        local closeToEnemy = false

                        for _, pos in opponentStarts do
                            local distSq = VDist2Sq(pos[1], pos[3], loc.Position[1], loc.Position[3])
                            -- Make sure to scout for bases that are near equidistant by giving the enemies 100 ogrids
                            if distSq-10000 < closestDistSq then
                                closestDistSq = distSq-10000
                                closeToEnemy = true
                            end
                        end

                        for _, pos in allyStarts do
                            local distSq = VDist2Sq(pos[1], pos[3], loc.Position[1], loc.Position[3])
                            if distSq < closestDistSq then
                                closestDistSq = distSq
                                closeToEnemy = false
                                break
                            end
                        end

                        if closeToEnemy then
                            SWARMINSERT(aiBrain.InterestList.LowPriority,
                                {
                                    Position = loc.Position,
                                    LastScouted = 0,
                                }
                            )
                        end
                    end
                end

            else -- Spawn locations were random. We don't know where our opponents are. Add all non-ally start locations to the scout list
                local numOpponents = 0
                for i = 1, 16 do
                    local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
                    local startPos = ScenarioUtils.GetMarker('ARMY_' .. i).position

                    if army and startPos then
                        if army.ArmyIndex == myArmy.ArmyIndex or (army.Team == myArmy.Team and army.Team ~= 1) then
                            allyStarts['ARMY_' .. i] = startPos
                        else
                            numOpponents = numOpponents + 1
                        end
                    end
                end

                aiBrain.NumOpponents = numOpponents

                -- If the start location is not ours or an ally's, it is suspicious
                local starts = AIUtils.AIGetMarkerLocations(aiBrain, 'Start Location')
                for _, loc in starts do
                    -- If vacant
                    if not allyStarts[loc.Name] then
                        table.insert(aiBrain.InterestList.LowPriority,
                            {
                                Position = loc.Position,
                                LastScouted = 0,
                            }
                        )
                    end
                end
            end
            aiBrain:ForkThread(self.ParseIntelThread)
        end
    end,

    IMAPConfigurationSwarm = function(self, ALLBPS)
        -- Used to configure imap values, used for setting threat ring sizes depending on map size to try and get a somewhat decent radius
        local maxmapdimension = math.max(ScenarioInfo.size[1],ScenarioInfo.size[2])

        if maxmapdimension == 256 then
            self.IMAPConfigSwarm.OgridRadius = 11.5
            self.IMAPConfigSwarm.IMAPSize = 16
            self.IMAPConfigSwarm.Rings = 3
        elseif maxmapdimension == 512 then
            self.IMAPConfigSwarm.OgridRadius = 22.5
            self.IMAPConfigSwarm.IMAPSize = 32
            self.IMAPConfigSwarm.Rings = 2
        elseif maxmapdimension == 1024 then
            self.IMAPConfigSwarm.OgridRadius = 45.0
            self.IMAPConfigSwarm.IMAPSize = 64
            self.IMAPConfigSwarm.Rings = 1
        elseif maxmapdimension == 2048 then
            self.IMAPConfigSwarm.OgridRadius = 89.5
            self.IMAPConfigSwarm.IMAPSize = 128
            self.IMAPConfigSwarm.Rings = 0
        else
            self.IMAPConfigSwarm.OgridRadius = 180.0
            self.IMAPConfigSwarm.IMAPSize = 256
            self.IMAPConfigSwarm.Rings = 0
        end
    end,

    -- 100% Relent0r's Work
    -- A Nice Threat Analysis Function
    EnemyThreatCheckSwarm = function(self, ALLBPS)
        local selfIndex = self:GetArmyIndex()
        local enemyBrains = {}
        local enemyAirThreat = 0
        local enemyAntiAirThreat = 0
        local enemyNavalThreat = 0
        local enemyLandThreat = 0
        local enemyNavalSubThreat = 0
        local enemyExtractorthreat = 0
        local enemyExtractorCount = 0
        local enemyDefenseAir = 0
        local enemyDefenseSurface = 0
        local enemyDefenseSub = 0
        local enemyACUGun = 0

        --LOG('Starting Threat Check at'..GetGameTick())
        for index, brain in ArmyBrains do
            if IsEnemy(selfIndex, brain:GetArmyIndex()) then
                SWARMINSERT(enemyBrains, brain)
            end
        end
        if SWARMGETN(enemyBrains) > 0 then
            for k, enemy in enemyBrains do

                local gunBool = false
                local acuHealth = 0
                local lastSpotted = 0
                local enemyIndex = enemy:GetArmyIndex()
                if not ArmyIsCivilian(enemyIndex) then
                    local enemyAir = GetListOfUnits( enemy, categories.MOBILE * categories.AIR - categories.TRANSPORTFOCUS - categories.SATELLITE - categories.SCOUT, false, false)
                    for _,v in enemyAir do
                        -- previous method of getting unit ID before the property was added.
                        --local unitbpId = v:GetUnitId()
                        --LOG('Unit blueprint id test only on dev branch:'..v.UnitId)
                        bp = ALLBPS[v.UnitId].Defense
            
                        enemyAirThreat = enemyAirThreat + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel
                        enemyAntiAirThreat = enemyAntiAirThreat + bp.AirThreatLevel
                    end
                    --LOG('Enemy Air Threat is'..enemyAirThreat)
                    SWARMWAIT(1)
                    local enemyExtractors = GetListOfUnits( enemy, categories.STRUCTURE * categories.MASSEXTRACTION, false, false)
                    for _,v in enemyExtractors do
                        bp = ALLBPS[v.UnitId].Defense

                        enemyExtractorthreat = enemyExtractorthreat + bp.EconomyThreatLevel
                        enemyExtractorCount = enemyExtractorCount + 1
                    end
                    SWARMWAIT(1)
                    local enemyNaval = GetListOfUnits( enemy, categories.NAVAL * ( categories.MOBILE + categories.DEFENSE ), false, false )
                    for _,v in enemyNaval do
                        bp = ALLBPS[v.UnitId].Defense
                        --LOG('NavyThreat unit is '..v.UnitId)
                        --LOG('NavyThreat is '..bp.SubThreatLevel)
                        enemyNavalThreat = enemyNavalThreat + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel
                        enemyNavalSubThreat = enemyNavalSubThreat + bp.SubThreatLevel
                    end
                    SWARMWAIT(1)
                    local enemyLand = GetListOfUnits( enemy, categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.COMMAND , false, false)
                    for _,v in enemyLand do
                        bp = ALLBPS[v.UnitId].Defense
                        enemyLandThreat = enemyLandThreat + bp.SurfaceThreatLevel
                    end
                    SWARMWAIT(1)
                    local enemyDefense = GetListOfUnits( enemy, categories.STRUCTURE * categories.DEFENSE - categories.SHIELD, false, false )
                    for _,v in enemyDefense do
                        bp = ALLBPS[v.UnitId].Defense
                        --LOG('DefenseThreat unit is '..v.UnitId)
                        --LOG('DefenseThreat is '..bp.SubThreatLevel)
                        enemyDefenseAir = enemyDefenseAir + bp.AirThreatLevel
                        enemyDefenseSurface = enemyDefenseSurface + bp.SurfaceThreatLevel
                        enemyDefenseSub = enemyDefenseSub + bp.SubThreatLevel
                    end
                    SWARMWAIT(1)
                    local enemyACU = GetListOfUnits( enemy, categories.COMMAND, false, false )
                    for _,v in enemyACU do
                        local factionIndex = enemy:GetFactionIndex()
                        if factionIndex == 1 then
                            if v:HasEnhancement('HeavyAntiMatterCannon') then
                                enemyACUGun = enemyACUGun + 1
                                gunBool = true
                            end
                        elseif factionIndex == 2 then
                            if v:HasEnhancement('CrysalisBeam') then
                                enemyACUGun = enemyACUGun + 1
                                gunBool = true
                            end
                        elseif factionIndex == 3 then
                            if v:HasEnhancement('CoolingUpgrade') then
                                enemyACUGun = enemyACUGun + 1
                                gunBool = true
                            end
                        elseif factionIndex == 4 then
                            if v:HasEnhancement('RateOfFire') then
                                enemyACUGun = enemyACUGun + 1
                                gunBool = true
                            end
                        end
                        if self.CheatEnabled then
                            acuHealth = v:GetHealth()
                            lastSpotted = GetGameTimeSeconds()
                        end
                    end
                    if gunBool then
                        self.EnemyACU[enemyIndex].Gun = true
                        --LOG('Gun Upgrade Present on army '..enemy.Nickname)
                    else
                        self.EnemyACU[enemyIndex].Gun = false
                    end
                    if self.CheatEnabled then
                        self.EnemyACU[enemyIndex].Hp = acuHealth
                        self.EnemyACU[enemyIndex].LastSpotted = lastSpotted
                        --LOG('Cheat is enabled and acu has '..acuHealth..' Health '..'Brain intel says '..self.EnemyACU[enemyIndex].Hp)
                    end
                end
            end
        end
        self.EnemyThreatCurrentSwarm.EnemyACUGunUpgrades = enemyACUGun
        self.EnemyThreatCurrentSwarm.EnemyAir = enemyAirThreat
        self.EnemyThreatCurrentSwarm.EnemyAntiAir = enemyAntiAirThreat
        self.EnemyThreatCurrentSwarm.EnemyExtractor = enemyExtractorthreat
        self.EnemyThreatCurrentSwarm.EnemyExtractorCount = enemyExtractorCount
        self.EnemyThreatCurrentSwarm.EnemyNaval = enemyNavalThreat
        self.EnemyThreatCurrentSwarm.EnemyNavalSub = enemyNavalSubThreat
        self.EnemyThreatCurrentSwarm.EnemyLand = enemyLandThreat
        self.EnemyThreatCurrentSwarm.EnemyDefenseAir = enemyDefenseAir
        self.EnemyThreatCurrentSwarm.EnemyDefenseSurface = enemyDefenseSurface
        self.EnemyThreatCurrentSwarm.EnemyDefenseSub = enemyDefenseSub
        --LOG('Completing Threat Check'..GetGameTick())
    end,

    -- 100% Relent0r's Work
    -- A Nice Self Threat Analysis
    SelfThreatCheckSwarm = function(self, ALLBPS)
        -- Get AI strength
        local selfIndex = self:GetArmyIndex()

        local brainAirUnits = GetListOfUnits( self, categories.AIR * categories.MOBILE - categories.TRANSPORTFOCUS - categories.SATELLITE - categories.SCOUT, false, false)
        local airthreat = 0
        local antiAirThreat = 0
        local bp

		-- calculate my present airvalue			
		for _,v in brainAirUnits do
			bp = ALLBPS[v.UnitId].Defense

            airthreat = airthreat + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel
            antiAirThreat = antiAirThreat + bp.AirThreatLevel
        end
        --LOG('My Air Threat is'..airthreat)
        self.SelfThreatSwarm.SelfAirNow = airthreat
        self.SelfThreatSwarm.SelfAntiAirNow = antiAirThreat
        
        SWARMWAIT(1)
        local brainExtractors = GetListOfUnits( self, categories.STRUCTURE * categories.MASSEXTRACTION, false, false)
        local selfExtractorCount = 0
        local selfExtractorThreat = 0
        local exBp

        for _,v in brainExtractors do
            exBp = ALLBPS[v.UnitId].Defense
            selfExtractorThreat = selfExtractorThreat + exBp.EconomyThreatLevel
            selfExtractorCount = selfExtractorCount + 1
            -- This bit is important. This is so that if the AI is given or captures any extractors it will start an upgrade thread and distress thread on them.
            if (not v.Dead) and (not v.PlatoonHandle) then
                --LOG('This extractor has no platoon handle')
                if not self.StructurePool then
                    SwarmUtils.CheckCustomPlatoonsSwarm(self)
                end
                local unitBp = v:GetBlueprint()
                local StructurePool = self.StructurePool
                --LOG('* AI-Swarm: Assigning built extractor to StructurePool')
                self:AssignUnitsToPlatoon(StructurePool, {v}, 'Support', 'none' )
                local upgradeID = unitBp.General.UpgradesTo or false
                if upgradeID and unitBp then
                    --LOG('* AI-Swarm: UpgradeID')
                    SwarmUtils.StructureUpgradeInitializeSwarm(v, self)
                end
            end
        end
        self.SelfThreatSwarm.SelfExtractor = selfExtractorThreat
        self.SelfThreatSwarm.SelfExtractorCount = selfExtractorCount
        local allyBrains = {}
        for index, brain in ArmyBrains do
            if index ~= self:GetArmyIndex() then
                if IsAlly(selfIndex, brain:GetArmyIndex()) then
                    SWARMINSERT(allyBrains, brain)
                end
            end
        end
        local allyExtractorCount = 0
        local allyExtractorthreat = 0
        local allyLandThreat = 0
        --LOG('Number of Allies '..SWARMGETN(allyBrains))
        SWARMWAIT(1)
        if SWARMGETN(allyBrains) > 0 then
            for k, ally in allyBrains do
                local allyExtractors = GetListOfUnits( ally, categories.STRUCTURE * categories.MASSEXTRACTION, false, false)
                for _,v in allyExtractors do
                    bp = ALLBPS[v.UnitId].Defense
                    allyExtractorthreat = allyExtractorthreat + bp.EconomyThreatLevel
                    allyExtractorCount = allyExtractorCount + 1
                end
                local allylandThreat = GetListOfUnits( ally, categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.COMMAND , false, false)
                
                for _,v in allylandThreat do
                    bp = ALLBPS[v.UnitId].Defense
                    allyLandThreat = allyLandThreat + bp.SurfaceThreatLevel
                end
            end
        end
        self.SelfThreatSwarm.SelfAllyExtractorCount = allyExtractorCount + selfExtractorCount
        self.SelfThreatSwarm.SelfAllyExtractor = allyExtractorthreat + selfExtractorThreat
        self.SelfThreatSwarm.SelfAllyLandThreat = allyLandThreat
        SWARMWAIT(1)
        local brainNavalUnits = GetListOfUnits( self, (categories.MOBILE * categories.NAVAL) + (categories.NAVAL * categories.FACTORY) + (categories.NAVAL * categories.DEFENSE), false, false)
        local navalThreat = 0
        local navalSubThreat = 0
        for _,v in brainNavalUnits do
            bp = ALLBPS[v.UnitId].Defense
            navalThreat = navalThreat + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel
            navalSubThreat = navalSubThreat + bp.SubThreatLevel
        end
        self.SelfThreatSwarm.SelfNavalNow = navalThreat
        self.SelfThreatSwarm.SelfNavalSubNow = navalSubThreat

        SWARMWAIT(1)
        local brainLandUnits = GetListOfUnits( self, categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.COMMAND , false, false)
        local landThreat = 0
        for _,v in brainLandUnits do
            bp = ALLBPS[v.UnitId].Defense
            landThreat = landThreat + bp.SurfaceThreatLevel
        end
        self.SelfThreatSwarm.SelfLandNow = landThreat
        --LOG('Self LandThreat is '..self.BrainArmy.SelfThreat.LandNow)
    end,

    -- Needs to be expanded on sooner or later. Unit Cap was only a replacement for Threat, until we clean threat up in the FAF DB. 
    -- Eventually, I will personally do this with the rest of AI Development Team and we will PR our complete threat reviewal towards the FAF Github.
    -- Surpisely Semi-Accurate

    -- Now we use actual Threat from Units instead of Unit Cap.
    -- Extremely Accurate
    ParseIntelThreadSwarm = function(self)

        --LOG("*AI DEBUG "..self.Nickname.." ParseIntelThreadSwarm begins")

        while self.Swarm do

            SWARMWAIT(30)  

            local enemyLandThreat = self.EnemyThreatCurrentSwarm.EnemyLand
            local landThreat = self.SelfThreatSwarm.SelfLandNow

            if enemyLandThreat ~= 0 then
                self.MyLandRatio = landThreat/enemyLandThreat
            else
                self.MyLandRatio = 1
            end

            local enemyAirThreat = self.EnemyThreatCurrentSwarm.EnemyAir
            local airthreat = self.SelfThreatSwarm.SelfAirNow

            if enemyAirThreat ~= 0 then
                self.MyAirRatio = airthreat/enemyAirThreat
            else
                self.MyAirRatio = 1
            end

            local enemyNavalThreat = self.EnemyThreatCurrentSwarm.EnemyNaval
            local navalThreat = self.SelfThreatSwarm.SelfNavalNow
    
            if enemyNavalThreat ~= 0 then
                self.MyNavalRatio = navalThreat/enemyNavalThreat
            else
                self.MyNavalRatio = 1
            end

            --LOG("*AI DEBUG "..self.Nickname.." Air Ratio is "..repr(self.MyAirRatio).." Land Ratio is "..repr(self.MyLandRatio).." Naval Ratio is "..repr(self.MyNavalRatio))
        end
    end,

    ExpansionIntelScanSwarm = function(self)
        --LOG('Pre-Start ExpansionIntelScanSwarm')
        SWARMWAIT(100)
        if SWARMGETN(self.ExpansionWatchTableSwarm) == 0 then
            --LOG('ExpansionIntelScanSwarm not ready or is empty')
            return
        end
        local threatTypes = {
            'Land',
            'Commander',
            'Structures',
        }
        local rawThreat = 0
        local GetClosestPathNodeInRadiusByLayer = import('/lua/AI/aiattackutilities.lua').GetClosestPathNodeInRadiusByLayer
        --LOG('Starting ExpansionIntelScanSwarm')
        while self.Result ~= "defeat" do
            for k, v in self.ExpansionWatchTableSwarm do
                if v.PlatoonAssigned.Dead then
                    v.PlatoonAssigned = false
                end
                if v.ScoutAssigned.Dead then
                    v.ScoutAssigned = false
                end
                if not v.Zone then
                    --[[
                        This is the information available in the Path Node currently. subject to change 7/13/2021
                        info: Check for position {
                        info:   GraphArea="LandArea_133",
                        info:   SwarmArea="Land15-24",
                        info:   adjacentTo="Land19-11 Land20-11 Land20-12 Land20-13 Land18-11",
                        info:   armydists={ ARMY_1=209.15859985352, ARMY_2=218.62866210938 },
                        info:   bestarmy="ARMY_1",
                        info:   bestexpand="Expansion Area 6",
                        info:   color="fff4a460",
                        info:   expanddists={
                        info:     ARMY_1=209.15859985352,
                        info:     ARMY_2=218.62866210938,
                        info:     ARMY_3=118.64562988281,
                        info:     ARMY_4=290.41003417969,
                        info:     ARMY_5=270.42752075195,
                        info:     ARMY_6=125.28052520752,
                        info:     Expansion Area 1=354.38958740234,
                        info:     Expansion Area 2=354.2922668457,
                        info:     Expansion Area 5=222.54640197754,
                        info:     Expansion Area 6=0
                        info:   },
                        info:   graph="DefaultLand",
                        info:   hint=true,
                        info:   orientation={ 0, 0, 0 },
                        info:   position={ 312, 16.21875, 200, type="VECTOR3" },
                        info:   prop="/env/common/props/markers/M_Path_prop.bp",
                        info:   type="Land Path Node"
                        info: }
                    ]]
                    local expansionNode = Scenario.MasterChain._MASTERCHAIN_.Markers[GetClosestPathNodeInRadiusByLayer(v.Position, 60, 'Land').name]
                    --LOG('Check for position '..repr(expansionNode))
                    if expansionNode then
                        self.ExpansionWatchTableSwarm[k].Zone = expansionNode.SwarmArea
                    else
                        self.ExpansionWatchTableSwarm[k].Zone = false
                    end
                end
                if v.MassPoints > 2 then
                    for _, t in threatTypes do
                        rawThreat = GetThreatAtPosition(self, v.Position, self.IMAPConfigSwarm.Rings, true, t)
                        if rawThreat > 0 then
                            --LOG('Threats as ExpansionWatchTable for type '..t..' threat is '..rawThreat)
                        end
                        self.ExpansionWatchTableSwarm[k][t] = rawThreat
                    end
                elseif v.MassPoints == 2 then
                    rawThreat = GetThreatAtPosition(self, v.Position, self.IMAPConfigSwarm.Rings, true, 'Structures')
                    self.ExpansionWatchTableSwarm[k]['Structures'] = rawThreat
                end
            end
            SWARMWAIT(100)
            -- don't do this, it might have a platoon inside it LOG('Current Expansion Watch Table '..repr(self.ExpansionWatchTableSwarm))
        end
    end,
}
