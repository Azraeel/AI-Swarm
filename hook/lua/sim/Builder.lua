SwarmPlatoonBuilder = PlatoonBuilder
PlatoonBuilder = Class(SwarmPlatoonBuilder) {

    CalculatePriority = function(self, builderManager)
       -- Only use this with Swarm
        if not self.Brain.Swarm then
            return TheOldPlatoonBuilder.CalculatePriority(self, builderManager)
        end
        self.PriorityAltered = false
        if Builders[self.BuilderName].PriorityFunction then
            --LOG('Calculate new Priority '..self.BuilderName..' - '..self.Priority)
            local newPri = Builders[self.BuilderName]:PriorityFunction(self.Brain, builderManager)
            if newPri != self.Priority then
                --LOG('* AI-Swarm: PlatoonBuilder New Priority:  [[  '..self.Priority..' -> '..newPri..'  ]]  -  '..self.BuilderName..'.')
                self.Priority = newPri
                self.PriorityAltered = true
            end
            --LOG('SwarmPlatoonBuilder New Priority '..self.BuilderName..' - '..self.Priority)
        end
        return self.PriorityAltered
    end,

}

SwarmFactoryBuilder = FactoryBuilder
FactoryBuilder = Class(SwarmFactoryBuilder) {



    CalculatePriority = function(self, builderManager)
       -- Only use this with Swarm
        if not self.Brain.Swarm then
            return SwarmFactoryBuilder.CalculatePriority(self, builderManager)
        end
        self.PriorityAltered = false
        if Builders[self.BuilderName].PriorityFunction then
            --LOG('Calculate new Priority '..self.BuilderName..' - '..self.Priority)
            local newPri = Builders[self.BuilderName]:PriorityFunction(self.Brain, builderManager)
            if newPri != self.Priority then
                --LOG('* AI-Swarm: FactoryBuilder New Priority:  [[  '..self.Priority..' -> '..newPri..'  ]]  -  '..self.BuilderName..'.')
                self.Priority = newPri
                self.PriorityAltered = true
            end
            --LOG('SwarmFactoryBuilder New Priority '..self.BuilderName..' - '..self.Priority)
        end
        return self.PriorityAltered
    end,

}


SwarmEngineerBuilder = EngineerBuilder
EngineerBuilder = Class(SwarmEngineerBuilder) {

    CalculatePriority = function(self, builderManager)
       -- Only use this with AI-Swarm
        if not self.Brain.Swarm then
            return SwarmEngineerBuilder.CalculatePriority(self, builderManager)
        end
        self.PriorityAltered = false
        if Builders[self.BuilderName].PriorityFunction then
            --LOG('Calculate new Priority '..self.BuilderName..' - '..self.Priority)
            local newPri = Builders[self.BuilderName]:PriorityFunction(self.Brain, builderManager)
            if newPri != self.Priority then
                --LOG('* AI-Swarm: EngineerBuilder New Priority:  [[  '..self.Priority..' -> '..newPri..'  ]]  -  '..self.BuilderName..'.')
                self.Priority = newPri
                self.PriorityAltered = true
            end
            --LOG('SwarmEngineerBuilder New Priority '..self.BuilderName..' - '..self.Priority)
        end
        return self.PriorityAltered
    end,

}