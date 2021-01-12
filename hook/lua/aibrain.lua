local lastCall = GetGameTimeSeconds()

--SwarmAIBrainClass = AIBrain
--AIBrain = Class(SwarmAIBrainClass) 

{

    OnCreateAI = function(self, planName)
        SwarmAIBrainClass.OnCreateAI(self, planName)

        local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality

        if string.find(per, 'swarm') then

            --LOG('* AI-Swarm: OnCreateAI() found AI-Swarm  Name: ('..self.Name..') - personality: ('..per..') ')

            self.Swarm = true

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
            return self.ExpansionHelpThread(self)
        end

        coroutine.yield(10)

        KillThread(CurrentThread())
    end,

    InitializeEconomyState = function(self)

        if not self.Swarm then
            return self.InitializeEconomyState(self)
        end

    end,

    OnIntelChange = function(self, blip, reconType, val)

        if not self.Swarm then
            return self.OnIntelChange(self, blip, reconType, val)
        end

    end,

    SetupAttackVectorsThread = function(self)

        if not self.Swarm then
            return self.SetupAttackVectorsThread(self)
        end

        coroutine.yield(10)

        KillThread(CurrentThread())
    end,

    ParseIntelThread = function(self)

        -----------------
        --- LAND UNITS --
		-----------------
        if (GetGameTimeSeconds() > 60 * 1) and lastCall + 10 < GetGameTimeSeconds() then

            local lastCall = GetGameTimeSeconds()

            allyScore = 0
            enemyScore = 0

            for k, self in ArmyBrains do
                if ArmyIsCivilian(self:GetArmyIndex()) then
                  
                elseif IsAlly( self:GetArmyIndex(), self:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), self:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end

            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                self.MyLandRatio = enemyScore / allyScore
            else
                self.MyLandRatio = 0.01
            end

        end

        -----------------
        --- AIR UNITS ---
		-----------------
        if (GetGameTimeSeconds() > 60 * 1) and lastCall + 10 < GetGameTimeSeconds() then

            local lastCall = GetGameTimeSeconds()

            allyScore = 0
            enemyScore = 0

            for k, self in ArmyBrains do
                if ArmyIsCivilian(self:GetArmyIndex()) then
                   
                elseif IsAlly( self:GetArmyIndex(), self:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), self:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end

            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                self.MyAirRatio = enemyScore / allyScore
            else
                self.MyAirRatio = 0.01
            end

        end

        -----------------
        --- NAVAL UNITS -
		-----------------
        if (GetGameTimeSeconds() > 60 * 1) and lastCall + 10 < GetGameTimeSeconds() then

            local lastCall = GetGameTimeSeconds()

            allyScore = 0
            enemyScore = 0

            for k, self in ArmyBrains do
                if ArmyIsCivilian(self:GetArmyIndex()) then
                   
                elseif IsAlly( self:GetArmyIndex(), self:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( self:GetArmyIndex(), self:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(self:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end
    
            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                self.MyNavalRatio = enemyScore / allyScore
            else
                self.MyNavalRatio = 0.01
            end

        end
    end,
}
