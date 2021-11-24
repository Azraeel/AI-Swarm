local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

SwarmFactoryBuilderManager = FactoryBuilderManager
FactoryBuilderManager = Class(SwarmFactoryBuilderManager) {
    
    SetRallyPoint = function(self, factory)
        if not self.Brain.Swarm then
            return SwarmFactoryBuilderManager.SetRallyPoint(self, factory)
        end

        local position = factory:GetPosition()
        local rally = false

        if self.RallyPoint then
            IssueClearFactoryCommands({factory})
            IssueFactoryRallyPoint({factory}, self.RallyPoint)
            return true
        end

        local rallyType = 'Rally Point'
        if EntityCategoryContains(categories.NAVAL, factory) then
            rallyType = 'Naval Rally Point'
        end

        if not self.UseCenterPoint then
            -- Find closest marker to averaged location
            rally = AIUtils.AIGetClosestMarkerLocation(self, rallyType, position[1], position[3])
        elseif self.UseCenterPoint then
            -- use BuilderManager location
            rally = AIUtils.AIGetClosestMarkerLocation(self, rallyType, position[1], position[3])
            local expPoint = AIUtils.AIGetClosestMarkerLocation(self, 'Expansion Area', position[1], position[3])

            if expPoint and rally then
                local rallyPointDistance = VDist2(position[1], position[3], rally[1], rally[3])
                local expansionDistance = VDist2(position[1], position[3], expPoint[1], expPoint[3])

                if expansionDistance < rallyPointDistance then
                    rally = expPoint
                end
            end
        end

        -- Use factory location if no other rally or if rally point is far away
        if not rally or VDist2(rally[1], rally[3], position[1], position[3]) > 75 then
            -- DUNCAN - added to try and vary the rally points.
            --LOG('No Rally Point Found. Setting Point between me and enemy Location')
            local position = false
            if ScenarioInfo.Options.TeamSpawn == 'fixed' then
                -- Spawn locations were fixed. We know exactly where our opponents are.
                -- We're Going to set out land rally point in the direction of the enemy
                local numOpponents = 0
                local enemyStarts = {}
                local myArmy = ScenarioInfo.ArmySetup[self.Brain.Name]
                local locationType = self.LocationType

                for i = 1, 16 do
                    local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
                    local startPos = ScenarioUtils.GetMarker('ARMY_' .. i).position
                    if army and startPos then
                        if army.ArmyIndex ~= myArmy.ArmyIndex and (army.Team ~= myArmy.Team or army.Team == 1) then
                            -- Add the army start location to the list of interesting spots.
                            local opponentStart = startPos
                            
                            local factoryPos = self.Brain.BuilderManagers[locationType].Position
                            --LOG('Start Locations :Opponent'..repr(opponentStart)..' Myself :'..repr(factoryPos))
                            local startDistance = VDist2(opponentStart[1], opponentStart[3], factoryPos[1], factoryPos[3])
                            if EntityCategoryContains(categories.AIR, factory) then
                                position = SwarmUtils.lerpy(opponentStart, factoryPos, {startDistance, startDistance - 60})
                                --LOG('Air Rally Position is :'..repr(position))
                                break
                            else
                                position = SwarmUtils.lerpy(opponentStart, factoryPos, {startDistance, startDistance - 30})
                                --LOG('Rally Position is :'..repr(position))
                                break
                            end
                        end
                    end
                end
            else
                --LOG('No Rally Point Found. Setting Random Location')
                position = AIUtils.RandomLocation(position[1],position[3])
            end
            rally = position
        end

        IssueClearFactoryCommands({factory})
        IssueFactoryRallyPoint({factory}, rally)
        self.RallyPoint = rally
        return true
    end,

    DelayBuildOrder = function(self,factory,bType,time)
        if not self.Brain.Swarm then
            return SwarmFactoryBuilderManager.DelayBuildOrder(self,factory,bType,time)
        end
        local guards = factory:GetGuards()
        for k,v in guards do
            if not v.Dead and v.AssistPlatoon then
                if self.Brain:PlatoonExists(v.AssistPlatoon) then
                    v.AssistPlatoon:ForkThread(v.AssistPlatoon.EconAssistBodySwarm)
                else
                    v.AssistPlatoon = nil
                end
            end
        end
        if factory.DelayThread then
            return
        end
        factory.DelayThread = true
        WaitTicks(math.random(20,50))
        factory.DelayThread = false
        if factory.Offline then
            while factory.Offline and factory and (not factory.Dead) do
                --LOG('Factory is offline, wait inside delaybuildorder')
                WaitTicks(50)
            end
            self:AssignBuildOrder(factory,bType)
        else
           self:AssignBuildOrder(factory,bType)
        end
    end,

    FactoryFinishBuilding = function(self,factory,finishedUnit)
        if not self.Brain.Swarm then
            return SwarmFactoryBuilderManager.FactoryFinishBuilding(self,factory,finishedUnit)
        end
        --LOG('Swarm FactorFinishedbuilding')
        if EntityCategoryContains(categories.ENGINEER, finishedUnit) then
            self.Brain.BuilderManagers[self.LocationType].EngineerManager:AddUnit(finishedUnit)
        elseif EntityCategoryContains(categories.FACTORY * categories.STRUCTURE, finishedUnit ) then
            --LOG('Factory Built by factory, attempting to kill factory.')
			if finishedUnit:GetFractionComplete() == 1 then
				self:AddFactory(finishedUnit )			
				factory.Dead = true
                factory.Trash:Destroy()
                --LOG('Destroy Factory')
				return self:FactoryDestroyed(factory)
			end
		end
        --self.Brain:RemoveConsumption(self.LocationType, factory)
        self:AssignBuildOrder(factory, factory.BuilderManagerData.BuilderType)
    end,

    FactoryDestroyed = function(self, factory)
        if not self.Brain.Swarm then
            return SwarmFactoryBuilderManager.FactoryDestroyed(self, factory)
        end
        --LOG('Factory Destroyed '..factory.UnitId)
        --LOG('We have '..table.getn(self.FactoryList) ' at the start of the FactoryDestroyed function')
        local guards = factory:GetGuards()
        local factoryDestroyed = false
        for k,v in guards do
            if not v.Dead and v.AssistPlatoon then
                if self.Brain:PlatoonExists(v.AssistPlatoon) then
                    v.AssistPlatoon:ForkThread(v.AssistPlatoon.EconAssistBodySwarm)
                else
                    v.AssistPlatoon = nil
                end
            end
        end
        for k,v in self.FactoryList do
            if (not v.Sync.id) or v.Dead then
                --LOG('Removing factory from FactoryList'..v.UnitId)
                self.FactoryList[k] = nil
                factoryDestroyed = true
            end
        end
        if factoryDestroyed then
            --LOG('Performing table rebuild')
            self.FactoryList = self:RebuildTable(self.FactoryList)
        end
        --LOG('We have '..table.getn(self.FactoryList) ' at the end of the FactoryDestroyed function')
        for k,v in self.FactoryList do
            if not v.Dead then
                return
            end
        end
        self.LocationActive = false
        --self.Brain:RemoveConsumption(self.LocationType, factory)
    end,

    BuilderParamCheckOld = function(self,builder,params)
        if not self.Brain.Swarm then
            return SwarmFactoryBuilderManager.BuilderParamCheck(self,builder,params)
        end
        local template = self:GetFactoryTemplate(builder:GetPlatoonTemplate(), params[1])
        if not template then
            WARN('*Factory Builder Error: Could not find template named: ' .. builder:GetPlatoonTemplate())
            return false
        end
        if not template[3][1] then
            --WARN('*Factory Builder Error: no FactionSquad for Template ' .. repr(template))
            return false
        end
        local FactoryLevel = params[1].techCategory
        local TemplateLevel = __blueprints[template[3][1]].TechCategory
        if FactoryLevel == TemplateLevel then
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  Factory is equal to Template Level, we want to continue!')
        elseif FactoryLevel > TemplateLevel then
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  Factory is higher than Template Level, stop building low tech crap!')
            local EngineerFound
            -- search categories for ENGINEER
            for _, cat in __blueprints[template[3][1]].Categories do
                -- continue withthe next categorie if its not ENGINEER
                if cat ~= 'ENGINEER' and cat ~= 'SCOUT' then continue end
                -- found ENGINEER category
                --WARN('found categorie engineer')
                EngineerFound = true
                break
            end
            -- template islower than factory level and its not an engineer, then return false
            if not EngineerFound then
                return false
            end
        elseif FactoryLevel < TemplateLevel then
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  Factory is lower than Template Level, we can\'t built that!')
            return false
        else
            --LOG('Factory Tech Level: ['..FactoryLevel..'] - Template Tech Level: ['..TemplateLevel..'] -  if you can read this then we have messed it up :D')
        end

        -- This faction doesn't have unit of this type
        if table.getn(template) == 2 then
            return false
        end

        -- This function takes a table of factories to determine if it can build
        return self.Brain:CanBuildPlatoon(template, params)

    end,
}