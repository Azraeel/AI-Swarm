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
        SwarmAIBrainClass.InitializeSkirmishSystems(self)

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
                table.insert(aiBrain.InterestList.HighPriority,
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
                        table.insert(aiBrain.InterestList.HighPriority,
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
                            table.insert(aiBrain.InterestList.LowPriority,
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

            local enemyLandThreat = self.EnemyLand
            local landThreat = self.SelfLandNow

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

            local enemyAirThreat = self.EnemyAir
            local airthreat = self.SelfAirNow

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

            local enemyNavalThreat = self.EnemyNaval
            local navalThreat = self.SelfNavalNow
    
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
