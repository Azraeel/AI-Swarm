WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aibrain.lua' )

local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')
local AIUtils = import('/lua/ai/AIUtilities.lua')
local AIBehaviors = import('/lua/ai/AIBehaviors.lua')

local lastCall = 0
local SWARMGETN = table.getn
local SWARMINSERT = table.insert
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

        -- Condition monitor for the whole brain
        self.ConditionsMonitor = BrainConditionsMonitor.CreateConditionsMonitor(self)

        -- Add default main location and setup the builder managers
        self.NumBases = 0 -- AddBuilderManagers will increase the number

        self.BuilderManagers = {}
        SUtils.AddCustomUnitSupport(self)
        self:AddBuilderManagers(self:GetStartVector3f(), 100, 'MAIN', false)

        self:BaseMonitorInitialization()
        local plat = self:GetPlatoonUniquelyNamed('ArmyPool')
        plat:ForkThread(plat.BaseManagersDistressAI)

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
                    --LOG('* AI-RNG: BlueprintID to upgrade to is : '..unitBp.General.UpgradesTo)
                    if upgradeID and __blueprints[upgradeID] then
                        SwarmUtils.StructureUpgradeInitializeSwarm(unit, self)
                    end
                    local unitTable = StructurePool:GetPlatoonUnits()
                    --LOG('* AI-RNG: StructurePool now has :'..RNGGETN(unitTable))
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

    GetUpgradeSpec = function(self, unit)
        local upgradeSpec = {}
        
        if EntityCategoryContains(categories.MASSEXTRACTION, unit) then
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
        else
            --LOG('* AI-Swarm: Unit is not Mass Extractor')
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
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    -- mass marker is too close to border, skip it.
                    continue
                end 
                if CanBuildStructureAt(self, 'ueb1103', v.position) then
                    massMarkerBuildable = massMarkerBuildable + 1
                end
                markerCount = markerCount + 1
                SWARMINSERT(MassMarker, v)
            end
        end
        self.MassMarker = markerCount
        self.MassMarkerBuildable = massMarkerBuildable
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
                    local enemyAir = GetListOfUnits( enemy, categories.MOBILE * categories.AIR - categories.TRANSPORTFOCUS - categories.SATELLITE, false, false)
                    for _,v in enemyAir do
                        -- previous method of getting unit ID before the property was added.
                        --local unitbpId = v:GetUnitId()
                        --LOG('Unit blueprint id test only on dev branch:'..v.UnitId)
                        bp = ALLBPS[v.UnitId].Defense
            
                        enemyAirThreat = enemyAirThreat + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel
                        enemyAntiAirThreat = enemyAntiAirThreat + bp.AirThreatLevel
                    end
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
        self.EnemyACUGunUpgrades = enemyACUGun
        self.EnemyAir = enemyAirThreat
        self.EnemyAntiAir = enemyAntiAirThreat
        self.EnemyExtractor = enemyExtractorthreat
        self.EnemyExtractorCount = enemyExtractorCount
        self.EnemyNaval = enemyNavalThreat
        self.EnemyNavalSub = enemyNavalSubThreat
        self.EnemyLand = enemyLandThreat
        self.EnemyDefenseAir = enemyDefenseAir
        self.EnemyDefenseSurface = enemyDefenseSurface
        self.EnemyDefenseSub = enemyDefenseSub
        --LOG('Completing Threat Check'..GetGameTick())
    end,

    -- 100% Relent0r's Work
    -- A Nice Self Threat Analysis
    SelfThreatCheckSwarm = function(self, ALLBPS)
        -- Get AI strength
        local selfIndex = self:GetArmyIndex()

        local brainAirUnits = GetListOfUnits( self, categories.AIR * categories.MOBILE - categories.TRANSPORTFOCUS - categories.SATELLITE, false, false)
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
        self.SelfAirNow = airthreat
        self.SelfAntiAirNow = antiAirThreat
        
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
                --LOG('* AI-RNG: Assigning built extractor to StructurePool')
                self:AssignUnitsToPlatoon(StructurePool, {v}, 'Support', 'none' )
                local upgradeID = unitBp.General.UpgradesTo or false
                if upgradeID and unitBp then
                    --LOG('* AI-RNG: UpgradeID')
                    SwarmUtils.StructureUpgradeInitializeSwarm(v, self)
                end
            end
        end
        self.SelfExtractor = selfExtractorThreat
        self.SelfExtractorCount = selfExtractorCount
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
        self.SelfAllyExtractorCount = allyExtractorCount + selfExtractorCount
        self.SelfAllyExtractor = allyExtractorthreat + selfExtractorThreat
        self.SelfAllyLandThreat = allyLandThreat
        SWARMWAIT(1)
        local brainNavalUnits = GetListOfUnits( self, (categories.MOBILE * categories.NAVAL) + (categories.NAVAL * categories.FACTORY) + (categories.NAVAL * categories.DEFENSE), false, false)
        local navalThreat = 0
        local navalSubThreat = 0
        for _,v in brainNavalUnits do
            bp = ALLBPS[v.UnitId].Defense
            navalThreat = navalThreat + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel
            navalSubThreat = navalSubThreat + bp.SubThreatLevel
        end
        self.SelfNavalNow = navalThreat
        self.SelfNavalSubNow = navalSubThreat

        SWARMWAIT(1)
        local brainLandUnits = GetListOfUnits( self, categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.COMMAND , false, false)
        local landThreat = 0
        for _,v in brainLandUnits do
            bp = ALLBPS[v.UnitId].Defense
            landThreat = landThreat + bp.SurfaceThreatLevel
        end
        self.SelfLandNow = landThreat
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

            local enemyLandThreat = self.EnemyLand
            local landThreat = self.SelfLandNow

            if enemyLandThreat ~= 0 then
                self.MyLandRatio = landThreat/enemyLandThreat
            else
                self.MyLandRatio = 1
            end

            local enemyAirThreat = self.EnemyAir
            local airthreat = self.SelfAirNow

            if enemyAirThreat ~= 0 then
                self.MyAirRatio = airthreat/enemyAirThreat
            else
                self.MyAirRatio = 1
            end

            local enemyNavalThreat = self.EnemyNaval
            local navalThreat = self.SelfNavalNow
    
            if enemyNavalThreat ~= 0 then
                self.MyNavalRatio = navalThreat/enemyNavalThreat
            else
                self.MyNavalRatio = 1
            end

            --LOG("*AI DEBUG "..self.Nickname.." Air Ratio is "..repr(self.MyAirRatio).." Land Ratio is "..repr(self.MyLandRatio).." Naval Ratio is "..repr(self.MyNavalRatio))
        end
    end,
}
