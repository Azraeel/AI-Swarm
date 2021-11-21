local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')

SwarmEngineerManager = EngineerManager
EngineerManager = Class(SwarmEngineerManager) {

    UnitConstructionFinished = function(self, unit, finishedUnit)
        if not self.Brain.Swarm then
            return SwarmEngineerManager.UnitConstructionFinished(self, unit, finishedUnit)
        end
        if EntityCategoryContains(categories.FACTORY * categories.STRUCTURE, finishedUnit) and finishedUnit:GetAIBrain():GetArmyIndex() == self.Brain:GetArmyIndex() then
            self.Brain.BuilderManagers[self.LocationType].FactoryManager:AddFactory(finishedUnit)
        end
        if EntityCategoryContains(categories.MASSEXTRACTION * categories.STRUCTURE, finishedUnit) and finishedUnit:GetAIBrain():GetArmyIndex() == self.Brain:GetArmyIndex() then
            if not self.Brain.StructurePool then
                SwarmUtils.CheckCustomPlatoonsCustom(self.Brain)
            end
            local unitBp = finishedUnit:GetBlueprint()
            local StructurePool = self.Brain.StructurePool
            --LOG('* AI-Swarm: Assigning built extractor to StructurePool')
            self.Brain:AssignUnitsToPlatoon(StructurePool, {finishedUnit}, 'Support', 'none' )
            --Debug log
            local platoonUnits = StructurePool:GetPlatoonUnits()
            --LOG('* AI-Swarm: StructurePool now has :'..table.getn(platoonUnits))
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