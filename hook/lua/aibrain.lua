WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aibrain.lua' )

local lastCall = 0
local SWARMGETN = table.getn
local SWARMINSERT = table.insert
local SWARMWAIT = coroutine.yield

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

        end

    end,

    InitializeSkirmishSystems = function(self)
        if not self.Swarm then
            return SwarmAIBrainClass.InitializeSkirmishSystems(self)
        end

        if self.BrainType == 'Human' then
            return
        end

        self.BrainArmy.SelfThreatIs = {
            Air = {},
            Extractor = 0,
            ExtractorCount = 0,
            MassMarker = 0,
            MassMarkerBuildable = 0,
            AllyExtractorCount = 0,
            AllyExtractor = 0,
            AllyLandThreat = 0,
            AntiAirNow = 0,
            AirNow = 0,
            LandNow = 0,
            NavalNow = 0,
            NavalSubNow = 0,
        }

        self.EnemyArmy.ACU = {}
        for _, v in ArmyBrains do
            self.EnemyArmy.ACU[v:GetArmyIndex()] = {
                Position = {},
                LastSpotted = 0,
                Threat = 0,
                Hp = 0,
                OnField = false,
                Gun = false,
            }
        end

        self.EnemyArmy.EnemyThreatIs = {
            Air = 0,
            AntiAir = 0,
            Land = 0,
            Extractor = 0,
            ExtractorCount = 0,
            Naval = 0,
            NavalSub = 0,
            DefenseAir = 0,
            DefenseSurface = 0,
            DefenseSub = 0,
            ACUGunUpgrades = 0,
        }
    end,

    ExpansionHelpThread = function(self)

        if not self.Swarm then
            return SwarmAIBrainClass.ExpansionHelpThread(self)
        end

        SWARMWAIT(10)

        KillThread(CurrentThread())
    end,

    InitializeEconomyState = function(self)

        if not self.Swarm then
            return SwarmAIBrainClass.InitializeEconomyState(self)
        end

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
        self.BrainArmy.SelfThreatIs.MassMarker = markerCount
        self.BrainArmy.SelfThreatIs.MassMarkerBuildable = massMarkerBuildable
    end,

    StrategicMonitorThreadSwarm = function(self, ALLBPS)

        while true do 

            self:SelfThreatCheckSwarm(ALLBPS)
            self:EnemyThreatCheckSwarm(ALLBPS)
            self:CalculateMassMarkersSwarm()

        end
        SWARMWAIT(30)
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
                        self.EnemyArmy.ACU[enemyIndex].Gun = true
                        --LOG('Gun Upgrade Present on army '..enemy.Nickname)
                    else
                        self.EnemyArmy.ACU[enemyIndex].Gun = false
                    end
                    if self.CheatEnabled then
                        self.EnemyArmy.ACU[enemyIndex].Hp = acuHealth
                        self.EnemyArmy.ACU[enemyIndex].LastSpotted = lastSpotted
                        --LOG('Cheat is enabled and acu has '..acuHealth..' Health '..'Brain intel says '..self.EnemyArmy.ACU[enemyIndex].Hp)
                    end
                end
            end
        end
        self.EnemyArmy.EnemyThreatIs.ACUGunUpgrades = enemyACUGun
        self.EnemyArmy.EnemyThreatIs.Air = enemyAirThreat
        self.EnemyArmy.EnemyThreatIs.AntiAir = enemyAntiAirThreat
        self.EnemyArmy.EnemyThreatIs.Extractor = enemyExtractorthreat
        self.EnemyArmy.EnemyThreatIs.ExtractorCount = enemyExtractorCount
        self.EnemyArmy.EnemyThreatIs.Naval = enemyNavalThreat
        self.EnemyArmy.EnemyThreatIs.NavalSub = enemyNavalSubThreat
        self.EnemyArmy.EnemyThreatIs.Land = enemyLandThreat
        self.EnemyArmy.EnemyThreatIs.DefenseAir = enemyDefenseAir
        self.EnemyArmy.EnemyThreatIs.DefenseSurface = enemyDefenseSurface
        self.EnemyArmy.EnemyThreatIs.DefenseSub = enemyDefenseSub
        --LOG('Completing Threat Check'..GetGameTick())
    end,

    -- 100% Relent0r's Work
    -- A Nice Self Threat Analysis
    SelfThreatCheckSwarm = function(self, ALLBPS)
        -- Get AI strength
        local selfIndex = self:GetArmyIndex()

        local brainAirUnits = GetListOfUnits( self, (categories.AIR * categories.MOBILE) - categories.TRANSPORTFOCUS - categories.SATELLITE - categories.EXPERIMENTAL, false, false)
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
        self.BrainArmy.SelfThreatIs.AirNow = airthreat
        self.BrainArmy.SelfThreatIs.AntiAirNow = antiAirThreat
        
        SWARMWAIT(1)
        local brainExtractors = GetListOfUnits( self, categories.STRUCTURE * categories.MASSEXTRACTION, false, false)
        local selfExtractorCount = 0
        local selfExtractorThreat = 0
        local exBp

        for _,v in brainExtractors do
            exBp = ALLBPS[v.UnitId].Defense
            selfExtractorThreat = selfExtractorThreat + exBp.EconomyThreatLevel
            selfExtractorCount = selfExtractorCount + 1
        end
        self.BrainArmy.SelfThreatIs.Extractor = selfExtractorThreat
        self.BrainArmy.SelfThreatIs.ExtractorCount = selfExtractorCount
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
        self.BrainArmy.SelfThreatIs.AllyExtractorCount = allyExtractorCount + selfExtractorCount
        self.BrainArmy.SelfThreatIs.AllyExtractor = allyExtractorthreat + selfExtractorThreat
        self.BrainArmy.SelfThreatIs.AllyLandThreat = allyLandThreat
        SWARMWAIT(1)
        local brainNavalUnits = GetListOfUnits( self, (categories.MOBILE * categories.NAVAL) + (categories.NAVAL * categories.FACTORY) + (categories.NAVAL * categories.DEFENSE), false, false)
        local navalThreat = 0
        local navalSubThreat = 0
        for _,v in brainNavalUnits do
            bp = ALLBPS[v.UnitId].Defense
            navalThreat = navalThreat + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel
            navalSubThreat = navalSubThreat + bp.SubThreatLevel
        end
        self.BrainArmy.SelfThreatIs.NavalNow = navalThreat
        self.BrainArmy.SelfThreatIs.NavalSubNow = navalSubThreat

        SWARMWAIT(1)
        local brainLandUnits = GetListOfUnits( self, categories.MOBILE * categories.LAND * (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.COMMAND , false, false)
        local landThreat = 0
        for _,v in brainLandUnits do
            bp = ALLBPS[v.UnitId].Defense
            landThreat = landThreat + bp.SurfaceThreatLevel
        end
        self.BrainArmy.SelfThreatIs.LandNow = landThreat
        --LOG('Self LandThreat is '..self.BrainArmy.SelfThreat.LandNow)
    end,

    -- Needs to be expanded on sooner or later. Unit Cap was only a replacement for Threat, until we clean threat up in the FAF DB. 
    -- Eventually, I will personally do this with the rest of AI Development Team and we will PR our complete threat reviewal towards the FAF Github.
    -- Surpisely Accurate
    -- Might make my own threats for tiers and such.
    ParseIntelThreadSwarm = function(self)

        --LOG("*AI DEBUG "..self.Nickname.." ParseIntelThreadSwarm begins")

        -----------------
        --- LAND UNITS --
		-----------------
        while self.Swarm do

            SWARMWAIT(30)

            --[[ allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do

                if ArmyIsCivilian(brain:GetArmyIndex()) then
                  
                elseif IsAlly( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + SWARMGETN(self:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + SWARMGETN(brain:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end ]]--    

            local enemyLandThreat = self.EnemyArmy.EnemyThreatIs.Land
            local landThreat = self.BrainArmy.SelfThreatIs.LandNow

            if enemyLandThreat ~= 0 then
                if landThreat == 0 then
                    landThreat = 1
                end
                self.MyLandRatio = 1/enemyLandThreat*landThreat
            else
                self.MyLandRatio = 0.01
            end
        

            --LOG("*AI DEBUG "..self.Nickname.." First Phase Ends")


            --[[ allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do

                if ArmyIsCivilian(brain:GetArmyIndex()) then
                   
                elseif IsAlly( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + SWARMGETN(self:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + SWARMGETN(brain:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end ]]--

            local enemyAirThreat = self.EnemyArmy.EnemyThreatIs.Air
            local airthreat = self.BrainArmy.SelfThreatIs.AirNow

            if enemyAirThreat ~= 0 then
                if airthreat == 0 then
                    airthreat = 1
                end
                self.MyAirRatio = 1/enemyAirThreat*airthreat
            else
                self.MyAirRatio = 0.01
            end
    

            --LOG("*AI DEBUG "..self.Nickname.." Second Phase Ends")


            --[[ allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do

                if ArmyIsCivilian(brain:GetArmyIndex()) then
                   
                elseif IsAlly( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + SWARMGETN(self:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + SWARMGETN(brain:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end ]]--

            local enemyNavalThreat = self.EnemyArmy.EnemyThreatIs.Naval
            local navalThreat = self.BrainArmy.SelfThreatIs.NavalNow
    
            if enemyNavalThreat ~= 0 then
                if navalThreat == 0 then
                    navalThreat = 1
                end
                self.MyNavalRatio = 1/enemyNavalThreat*navalThreat
            else
                self.MyNavalRatio = 0.01
            end

            LOG("*AI DEBUG "..self.Nickname.." Air Ratio is "..repr(self.MyAirRatio).." Land Ratio is "..repr(self.MyLandRatio).." Naval Ratio is "..repr(self.MyNavalRatio))
        end
    end,
}
