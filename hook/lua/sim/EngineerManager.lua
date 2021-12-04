local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')

SwarmEngineerManager = EngineerManager
EngineerManager = Class(SwarmEngineerManager) {

    UnitConstructionFinished = function(self, unit, finishedUnit)
        if not self.Brain.Swarm then
            return SwarmEngineerManager.UnitConstructionFinished(self, unit, finishedUnit)
        end
        if EntityCategoryContains(categories.FACTORY * categories.STRUCTURE, finishedUnit) and finishedUnit:GetAIBrain():GetArmyIndex() == self.Brain:GetArmyIndex() then
            self.Brain.BuilderManagers[self.LocationType].FactoryManager:AddFactory(finishedUnit)
            local unitBp = finishedUnit:GetBlueprint()
			local upgradeID = unitBp.General.UpgradesTo or false
			if upgradeID and unitBp then
				-- if upgradeID available then launch upgrade thread
				SwarmUtils.StructureUpgradeInitializeSwarm(finishedUnit, self.Brain)
			end
        end
        if EntityCategoryContains(categories.MASSEXTRACTION * categories.STRUCTURE, finishedUnit) and finishedUnit:GetAIBrain():GetArmyIndex() == self.Brain:GetArmyIndex() then
            local unitBp = finishedUnit:GetBlueprint()
            local upgradeID = unitBp.General.UpgradesTo or false
			if upgradeID and unitBp then
				--LOG('* AI-Swarm: UpgradeID')
				SwarmUtils.StructureUpgradeInitializeSwarm(finishedUnit, self.Brain)
            end
		end
        if finishedUnit:GetAIBrain():GetArmyIndex() == self.Brain:GetArmyIndex() then
            self:AddUnit(finishedUnit)
        end
        local guards = unit:GetGuards()
        for k,v in guards do
            if not v.Dead and v.AssistPlatoon then
                if self.Brain:PlatoonExists(v.AssistPlatoon) then
                    v.AssistPlatoon:ForkThread(v.AssistPlatoon.EconAssistBodySwarm)
                else
                    v.AssistPlatoon = nil
                end
            end
        end
        --self.Brain:RemoveConsumption(self.LocationType, unit)
    end,

    ManagerLoopBody = function(self,builder,bType)
        if not self.Brain.Swarm then
            return SwarmEngineerManager.ManagerLoopBody(self,builder,bType)
        end
        BuilderManager.ManagerLoopBody(self,builder,bType)
    end,

    AssignEngineerTask = function(self, unit)
        if not self.Brain.Swarm then
            return SwarmEngineerManager.AssignEngineerTask(self, unit)
        end
        if unit.Combat or unit.GoingHome or unit.UnitBeingBuiltBehavior or unit.Upgrading then
            if unit.Upgrading then
                --LOG('Unit Is upgrading, applying 5 second delay')
            end
            --LOG('Unit Still in combat or going home, delay')
            self.AssigningTask = false
            --LOG('CDR Combat Delay')
            self:DelayAssign(unit, 50)
            return
        end
        unit.LastActive = GetGameTimeSeconds()
        if unit.UnitBeingAssist or unit.UnitBeingBuilt then
            --LOG('UnitBeingAssist Delay')
            self:DelayAssign(unit, 50)
            return
        end

        unit.DesiresAssist = false
        unit.NumAssistees = nil
        unit.MinNumAssistees = nil

        if self.AssigningTask then
            --LOG('Assigning Task Delay')
            self:DelayAssign(unit, 50)
            return
        else
            self.AssigningTask = true
        end

        local builder = self:GetHighestBuilder('Any', {unit})

        if builder and ((not unit.Combat) or (not unit.GoingHome) or (not unit.Upgrading)) then
            -- Fork off the platoon here
            local template = self:GetEngineerPlatoonTemplate(builder:GetPlatoonTemplate())
            local hndl = self.Brain:MakePlatoon(template[1], template[2])
            self.Brain:AssignUnitsToPlatoon(hndl, {unit}, 'support', 'none')
            unit.PlatoonHandle = hndl

            --if EntityCategoryContains(categories.COMMAND, unit) then
            --    LOG('*AI DEBUG: ARMY '..self.Brain.Nickname..': Engineer Manager Forming - '..builder.BuilderName..' - Priority: '..builder:GetPriority())
            --end

            --LOG('*AI DEBUG: ARMY ', repr(self.Brain:GetArmyIndex()),': Engineer Manager Forming - ',repr(builder.BuilderName),' - Priority: ', builder:GetPriority())
            hndl.PlanName = template[2]

            --If we have specific AI, fork that AI thread
            if builder:GetPlatoonAIFunction() then
                hndl:StopAI()
                local aiFunc = builder:GetPlatoonAIFunction()
                hndl:ForkAIThread(import(aiFunc[1])[aiFunc[2]])
            end
            if builder:GetPlatoonAIPlan() then
                hndl.PlanName = builder:GetPlatoonAIPlan()
                hndl:SetAIPlan(hndl.PlanName)
            end

            --If we have additional threads to fork on the platoon, do that as well.
            if builder:GetPlatoonAddPlans() then
                for papk, papv in builder:GetPlatoonAddPlans() do
                    hndl:ForkThread(hndl[papv])
                end
            end

            if builder:GetPlatoonAddFunctions() then
                for pafk, pafv in builder:GetPlatoonAddFunctions() do
                    hndl:ForkThread(import(pafv[1])[pafv[2]])
                end
            end

            if builder:GetPlatoonAddBehaviors() then
                for pafk, pafv in builder:GetPlatoonAddBehaviors() do
                    hndl:ForkThread(import('/lua/ai/AIBehaviors.lua')[pafv])
                end
            end

            hndl.Priority = builder:GetPriority()
            hndl.BuilderName = builder:GetBuilderName()

            hndl:SetPlatoonData(builder:GetBuilderData(self.LocationType))

            if hndl.PlatoonData.DesiresAssist then
                unit.DesiresAssist = hndl.PlatoonData.DesiresAssist
            else
                unit.DesiresAssist = true
            end

            if hndl.PlatoonData.NumAssistees then
                unit.NumAssistees = hndl.PlatoonData.NumAssistees
            end

            if hndl.PlatoonData.MinNumAssistees then
                unit.MinNumAssistees = hndl.PlatoonData.MinNumAssistees
            end

            builder:StoreHandle(hndl)
            self.AssigningTask = false
            return
        end
        self.AssigningTask = false
        --LOG('End of AssignEngineerTask Delay')
        self:DelayAssign(unit, 50)
    end,

    RemoveUnit = function(self, unit)
        if not self.Brain.Swarm then
            return SwarmEngineerManager.RemoveUnit(self, unit)
        end
        local guards = unit:GetGuards()
        for k,v in guards do
            if not v.Dead and v.AssistPlatoon then
                if self.Brain:PlatoonExists(v.AssistPlatoon) then
                    v.AssistPlatoon:ForkThread(v.AssistPlatoon.EconAssistBodySwarm)
                else
                    v.AssistPlatoon = nil
                end
            end
        end

        local found = false
        for k,v in self.ConsumptionUnits do
            if EntityCategoryContains(v.Category, unit) then
                for num,sUnit in v.Units do
                    if sUnit.Unit == unit then
                        table.remove(v.Units, num)
                        table.remove(v.UnitsList, num)
                        v.Count = v.Count - 1
                        found = true
                        break
                    end
                end
            end
            if found then
                break
            end
        end

        --self.Brain:RemoveConsumption(self.LocationType, unit)
    end,

    -- Killing Shit Functions
    -- Fuck Default Functions FML!
    LowMass = function(self)
        -- See eco manager.
        if not self.Brain.Swarm then
            return SwarmEngineerManager.LowMass(self)
        end
        --LOG('LowMass Condition detected by default eco manager')
    end,

    LowEnergy = function(self)
        -- See eco manager.
        if not self.Brain.Swarm then
            return SwarmEngineerManager.LowEnergy(self)
        end
        --LOG('LowEnergy Condition detected by default eco manager')
    end,

    RestoreEnergy = function(self)
        -- See eco manager.
        if not self.Brain.Swarm then
            return SwarmEngineerManager.RestoreEnergy(self)
        end
    end,

    RestoreMass = function(self)
        -- See eco manager.
        if not self.Brain.Swarm then
            return SwarmEngineerManager.RestoreMass(self)
        end
    end,
}