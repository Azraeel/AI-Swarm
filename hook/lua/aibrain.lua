WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Swarm: offset aibrain.lua' )

local lastCall = 0

SwarmAIBrainClass = AIBrain
AIBrain = Class(SwarmAIBrainClass) {

    OnCreateAI = function(self, planName)
        SwarmAIBrainClass.OnCreateAI(self, planName)

        local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality

        if string.find(per, 'swarm') then

            --LOG('* AI-Swarm: OnCreateAI() found AI-Swarm  Name: ('..self.Name..') - personality: ('..per..') ')

            self.Swarm = true

            self:ForkThread(self.ParseIntelThreadSwarm)

        end

    end,

    CalculateMassMarkersSwarm = function(self)

        local MassMarker = {}

        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do

            if v.type == 'Mass' then

                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    continue
                end 

                table.insert(MassMarker, v)

            end
        end

        local MassMarker = table.getn(MassMarker)

        self.BrainIntel.SelfThreat.MassMarker = MassMarker

    end,

    ExpansionHelpThread = function(self)

        if not self.Swarm then
            return SwarmAIBrainClass.ExpansionHelpThread(self)
        end

        coroutine.yield(10)

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

        coroutine.yield(10)

        KillThread(CurrentThread())
    end,

    -- Needs to be expanded on sooner or later. Unit Cap was only a replacement for Threat, until we clean threat up in the FAF DB. 
    -- Eventually, I will personally do this with the rest of AI Development Team and we will PR our complete threat reviewal towards the FAF Github.

    ParseIntelThreadSwarm = function(self)

        --LOG("*AI DEBUG "..self.Nickname.." ParseIntelThreadSwarm begins")

        -----------------
        --- LAND UNITS --
		-----------------
        while self.Swarm do

            WaitTicks(20)

            allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do

                if ArmyIsCivilian(brain:GetArmyIndex()) then
                  
                elseif IsAlly( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end

            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                self.MyLandRatio = 1/enemyScore*allyScore
            else
                self.MyLandRatio = 0.01
            end
        

            --LOG("*AI DEBUG "..self.Nickname.." First Phase Ends")


            allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do

                if ArmyIsCivilian(brain:GetArmyIndex()) then
                   
                elseif IsAlly( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end

            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                self.MyAirRatio = 1/enemyScore*allyScore
            else
                self.MyAirRatio = 0.01
            end
    

            --LOG("*AI DEBUG "..self.Nickname.." Second Phase Ends")


            allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do

                if ArmyIsCivilian(brain:GetArmyIndex()) then
                   
                elseif IsAlly( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end
    
            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                self.MyNavalRatio = 1/enemyScore*allyScore
            else
                self.MyNavalRatio = 0.01
            end
            LOG("*AI DEBUG "..self.Nickname.." Air Ratio is "..repr(self.MyAirRatio).." Land Ratio is "..repr(self.MyLandRatio).." Naval Ratio is "..repr(self.MyNavalRatio))
        end
    end,
}
