
SwarmAIBrainClass = AIBrain
AIBrain = Class(SwarmAIBrainClass) {

    -- Hook AI-Swarm, set self.Swarm = true
    OnCreateAI = function(self, planName)
        SwarmAIBrainClass.OnCreateAI(self, planName)
        local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
        if string.find(per, 'swarm') then
            LOG('* AI-Swarm: OnCreateAI() found AI-Swarm  Name: ('..self.Name..') - personality: ('..per..') ')
            self.Swarm = true
        end
    end,

    CalculateMassMarkersSwarm = function(self)
        local MassMarker = {}
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    -- mass marker is too close to border, skip it.
                    continue
                end 
                table.insert(MassMarker, v)
            end
        end
        local MassMarker = table.getn(MassMarker)
        self.BrainIntel.SelfThreat.MassMarker = MassMarker
    end,

    ExpansionHelpThread = function(self)
       -- Only use this with AI-Swarm
        if not self.Swarm then
            return SwarmAIBrainClass.ExpansionHelpThread(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    InitializeEconomyState = function(self)
        -- Only use this with AI-Swarm
        if not self.Swarm then
            return SwarmAIBrainClass.InitializeEconomyState(self)
        end
    end,

    OnIntelChange = function(self, blip, reconType, val)
        -- Only use this with AI-Swarm
        if not self.Swarm then
            return SwarmAIBrainClass.OnIntelChange(self, blip, reconType, val)
        end
    end,

    SetupAttackVectorsThread = function(self)
       -- Only use this with AI-Swarm
        if not self.Swarm then
            return SwarmAIBrainClass.SetupAttackVectorsThread(self)
        end
        coroutine.yield(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    ParseIntelThread = function(self)

        -----------------
        --- LAND UNITS --
		-----------------
        if (GetGameTimeSeconds() > 60 * 1) and lastCall+10 < GetGameTimeSeconds() then
            lastCall = GetGameTimeSeconds()

            --score of all players (unitcount)
            allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do
                if ArmyIsCivilian(brain:GetArmyIndex()) then
                    --NOOP
                elseif IsAlly( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.LAND - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end
            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                aiBrain.MyLandRatio = enemyScore / allyScore
            else
                aiBrain.MyLandRatio = 1
            end
        end

        -----------------
        --- AIR UNITS ---
		-----------------
        if (GetGameTimeSeconds() > 60 * 1) and lastCall+10 < GetGameTimeSeconds() then
            lastCall = GetGameTimeSeconds()

            --score of all players (unitcount)
            allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do
                if ArmyIsCivilian(brain:GetArmyIndex()) then
                    --NOOP
                elseif IsAlly( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.AIR - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end
            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                aiBrain.MyAirRatio = enemyScore / allyScore
            else
                aiBrain.MyAirRatio = 1
            end
        end

        -----------------
        --- NAVAL UNITS -
		-----------------
        if (GetGameTimeSeconds() > 60 * 1) and lastCall+10 < GetGameTimeSeconds() then
            lastCall = GetGameTimeSeconds()

            --score of all players (unitcount)
            allyScore = 0
            enemyScore = 0

            for k, brain in ArmyBrains do
                if ArmyIsCivilian(brain:GetArmyIndex()) then
                    --NOOP
                elseif IsAlly( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then

                    allyScore = allyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))

                elseif IsEnemy( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then

                    enemyScore = enemyScore + table.getn(brain:GetListOfUnits( categories.MOBILE * categories.NAVAL - categories.ENGINEER - categories.SCOUT, false, false))
                end
            end
            if enemyScore ~= 0 then
                if allyScore == 0 then
                    allyScore = 1
                end
                aiBrain.MyNavalRatio = enemyScore / allyScore
            else
                aiBrain.MyNavalRatio = 1
            end
        end
    end,
}
