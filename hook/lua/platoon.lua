--WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] * AI-Uveso: offset platoon.lua' )

local UUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')



local PlatoonExists = moho.aibrain_methods.PlatoonExists
local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits
local IsUnitState = moho.unit_methods.IsUnitState
local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition

local SWARMCOPY = table.copy
local SWARMSORT = table.sort
local SWARMTIME = GetGameTimeSeconds
local SWARMFLOOR = math.floor
local SWARMENTITY = EntityCategoryContains
local SWARMINSERT = table.insert
local SWARMCAT = table.cat

local VDist2Sq = VDist2Sq
local VDist3 = VDist3

local ForkThread = ForkThread
local ForkTo = ForkThread

local KillThread = KillThread







OldPlatoonClass = Platoon
Platoon = Class(OldPlatoonClass) {

-- For AI Patch V8 if eng:IsUnitState('BlockCommandQueue') then
    ProcessBuildCommand = function(eng, removeLastBuild)
        if not eng or not eng.PlatoonHandle or eng.Dead then
            return
        end
        if eng:BeenDestroyed() then
            WARN('* AI-DEBUG: ProcessBuildCommand: eng is not dead but destroyed')
            return
        end
        local aiBrain = eng.PlatoonHandle:GetBrain()

       -- Only use this with AI-Uveso
        if not aiBrain.Uveso then
            return OldPlatoonClass.ProcessBuildCommand(eng, removeLastBuild)
        end

        if not aiBrain or eng.Dead or not eng.EngineerBuildQueue or table.getn(eng.EngineerBuildQueue) == 0 then
            if aiBrain:PlatoonExists(eng.PlatoonHandle) then
                --LOG("*AI DEBUG: Disbanding Engineer Platoon in ProcessBuildCommand top " .. eng.Sync.id)
                --if eng.CDRHome then LOG('*AI DEBUG: Commander process build platoon disband...') end
                if not eng.AssistSet and not eng.AssistPlatoon and not eng.UnitBeingAssist then
                    eng.PlatoonHandle:PlatoonDisband()
                end
            end
            if eng then eng.ProcessBuild = nil end
            return
        end

        -- it wasn't a failed build, so we just finished something
        if removeLastBuild then
            table.remove(eng.EngineerBuildQueue, 1)
        end

        function BuildToNormalLocation(location)
            return {location[1], 0, location[2]}
        end

        function NormalToBuildLocation(location)
            return {location[1], location[3], 0}
        end

        eng.ProcessBuildDone = false
        IssueClearCommands({eng})
        local commandDone = false
        while not eng.Dead and not commandDone and table.getn(eng.EngineerBuildQueue) > 0  do
            if eng:IsUnitState('BlockCommandQueue') then
                while not eng.Dead and eng:IsUnitState('BlockCommandQueue') do
                    --LOG('* AI-DEBUG: Unit BlockCommandQueue is true, delaying build')
                    WaitTicks(1)
                end
            end
            local whatToBuild = eng.EngineerBuildQueue[1][1]
            local buildLocation = BuildToNormalLocation(eng.EngineerBuildQueue[1][2])
            local buildRelative = eng.EngineerBuildQueue[1][3]
            -- see if we can move there first
            if AIUtils.EngineerMoveWithSafePath(aiBrain, eng, buildLocation) then
                if not eng or eng.Dead or not eng.PlatoonHandle or not aiBrain:PlatoonExists(eng.PlatoonHandle) then
                    if eng then eng.ProcessBuild = nil end
                    return
                end

                if not eng.NotBuildingThread then
                    eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuilding)
                end

                local engpos = eng:GetPosition()
                while not eng.Dead and eng:IsUnitState("Moving") and VDist2(engpos[1], engpos[3], buildLocation[1], buildLocation[3]) > 15 do
                    WaitTicks(10)
                end

                -- check to see if we need to reclaim or capture...
                if not AIUtils.EngineerTryReclaimCaptureArea(aiBrain, eng, buildLocation) then
                    -- check to see if we can repair
                    if not AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, buildLocation) then
                        -- otherwise, go ahead and build the next structure there
                        aiBrain:BuildStructure(eng, whatToBuild, NormalToBuildLocation(buildLocation), buildRelative)
                        if not eng.NotBuildingThread then
                            eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuilding)
                        end
                    end
                end
                commandDone = true
            else
                -- we can't move there, so remove it from our build queue
                table.remove(eng.EngineerBuildQueue, 1)
            end
        end

        -- final check for if we should disband
        if not eng or eng.Dead or table.getn(eng.EngineerBuildQueue) <= 0 then
            if eng.PlatoonHandle and aiBrain:PlatoonExists(eng.PlatoonHandle) then
                --LOG("*AI DEBUG: Disbanding Engineer Platoon in ProcessBuildCommand bottom " .. eng.Sync.id)
                eng.PlatoonHandle:PlatoonDisband()
            end
            if eng then eng.ProcessBuild = nil end
            return
        end
        if eng then eng.ProcessBuild = nil end
    end,
    
-- For AI Patch V8 emoved old sorian delay platoon method
    EngineerBuildAI = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local armyIndex = aiBrain:GetArmyIndex()
        local x,z = aiBrain:GetArmyStartPos()
        local cons = self.PlatoonData.Construction
        local buildingTmpl, buildingTmplFile, baseTmpl, baseTmplFile

        local eng
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.ENGINEER - categories.STATIONASSISTPOD, v) then --DUNCAN - was construction
                IssueClearCommands({v})
                if not eng then
                    eng = v
                else
                    IssueGuard({v}, eng)
                end
            end
        end

        if not eng or eng.Dead then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end

        --DUNCAN - added
        if eng:IsUnitState('Building') or eng:IsUnitState('Upgrading') or eng:IsUnitState("Enhancing") then
           return
        end

        local FactionToIndex  = { UEF = 1, AEON = 2, CYBRAN = 3, SERAPHIM = 4, NOMADS = 5}
        local factionIndex = cons.FactionIndex or FactionToIndex[eng.factionCategory]

        buildingTmplFile = import(cons.BuildingTemplateFile or '/lua/BuildingTemplates.lua')
        baseTmplFile = import(cons.BaseTemplateFile or '/lua/BaseTemplates.lua')
        buildingTmpl = buildingTmplFile[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
        baseTmpl = baseTmplFile[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]

        --LOG('*AI DEBUG: EngineerBuild AI ' .. eng.Sync.id)

        if self.PlatoonData.NeedGuard then
            eng.NeedGuard = true
        end

        -------- CHOOSE APPROPRIATE BUILD FUNCTION AND SETUP BUILD VARIABLES --------
        local reference = false
        local refName = false
        local buildFunction
        local closeToBuilder
        local relative
        local baseTmplList = {}

        -- if we have nothing to build, disband!
        if not cons.BuildStructures then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end
        if cons.NearUnitCategory then
            self:SetPrioritizedTargetList('support', {ParseEntityCategory(cons.NearUnitCategory)})
            local unitNearBy = self:FindPrioritizedUnit('support', 'Ally', false, self:GetPlatoonPosition(), cons.NearUnitRadius or 50)
            --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." attempt near: ", cons.NearUnitCategory)
            if unitNearBy then
                reference = table.copy(unitNearBy:GetPosition())
                -- get commander home position
                --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." Near unit: ", cons.NearUnitCategory)
                if cons.NearUnitCategory == 'COMMAND' and unitNearBy.CDRHome then
                    reference = unitNearBy.CDRHome
                end
            else
                reference = table.copy(eng:GetPosition())
            end
            relative = false
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
        elseif cons.Wall then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100
            relative = false
            reference = AIUtils.GetLocationNeedingWalls(aiBrain, 200, 4, 'STRUCTURE - WALLS', cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            table.insert(baseTmplList, 'Blank')
            buildFunction = AIBuildStructures.WallBuilder
        elseif cons.NearBasePatrolPoints then
            relative = false
            reference = AIUtils.GetBasePatrolPoints(aiBrain, cons.Location or 'MAIN', cons.Radius or 100)
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            for k,v in reference do
                table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, v))
            end
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
        elseif cons.FireBase and cons.FireBaseRange then
            --DUNCAN - pulled out and uses alt finder
            reference, refName = AIUtils.AIFindFirebaseLocation(aiBrain, cons.LocationType, cons.FireBaseRange, cons.NearMarkerType,
                                                cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType,
                                                cons.MarkerUnitCount, cons.MarkerUnitCategory, cons.MarkerRadius)
            if not reference or not refName then
                self:PlatoonDisband()
                return
            end

        elseif cons.NearMarkerType and cons.ExpansionBase then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100

            if cons.NearMarkerType == 'Expansion Area' then
                reference, refName = AIUtils.AIFindExpansionAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                    return
                end
            elseif cons.NearMarkerType == 'Naval Area' then
                reference, refName = AIUtils.AIFindNavalAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                    return
                end
            else
                --DUNCAN - use my alternative expansion finder on large maps below a certain time
                local mapSizeX, mapSizeZ = GetMapSize()
                if GetGameTimeSeconds() <= 780 and mapSizeX > 512 and mapSizeZ > 512 then
                    reference, refName = AIUtils.AIFindFurthestStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                    if not reference or not refName then
                        reference, refName = AIUtils.AIFindStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                            (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                    end
                else
                    reference, refName = AIUtils.AIFindStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                end
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                    return
                end
            end

            -- If moving far from base, tell the assisting platoons to not go with
            if cons.FireBase or cons.ExpansionBase then
                local guards = eng:GetGuards()
                for k,v in guards do
                    if not v.Dead and v.PlatoonHandle then
                        v.PlatoonHandle:PlatoonDisband()
                    end
                end
            end

            if not cons.BaseTemplate and (cons.NearMarkerType == 'Naval Area' or cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, eng, cons)
            end
            relative = false
            if reference and aiBrain:GetThreatAtPosition(reference , 1, true, 'AntiSurface') > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            --buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
            buildFunction = AIBuildStructures.AIBuildBaseTemplate
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindDefensivePointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Naval Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindNavalDefensivePointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and (cons.NearMarkerType == 'Rally Point' or cons.NearMarkerType == 'Protected Experimental Construction') then
            --DUNCAN - add so experimentals build on maps with no markers.
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if not reference then
                reference = pos
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType then
            --WARN('*Data weird for builder named - ' .. self.BuilderName)
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            if not cons.BaseTemplate and (cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, (cons.ExpansionRadius or 100), cons.ExpansionTypes, nil, cons)
            end
            if reference and aiBrain:GetThreatAtPosition(reference, 1, true) > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.AvoidCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager.Location
            local cat = cons.AdjacencyCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(cat) == 'string' then
                cat = ParseEntityCategory(cat)
            end
            local avoidCat = cons.AvoidCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(avoidCat) == 'string' then
                avoidCat = ParseEntityCategory(avoidCat)
            end
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.FindUnclutteredArea(aiBrain, cat, pos, radius, cons.maxUnits, cons.maxRadius, avoidCat)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            table.insert(baseTmplList, baseTmpl)
        elseif cons.AdjacencyCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager.Location
            local cat = cons.AdjacencyCategory
            -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
            if type(cat) == 'string' then
                cat = ParseEntityCategory(cat)
            end
            local radius = (cons.AdjacencyDistance or 50)
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.GetOwnUnitsAroundPoint(aiBrain, cat, pos, radius, cons.ThreatMin,
                                                        cons.ThreatMax, cons.ThreatRings)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            table.insert(baseTmplList, baseTmpl)
        else
            table.insert(baseTmplList, baseTmpl)
            relative = true
            reference = true
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        end
        if cons.BuildClose then
            closeToBuilder = eng
        end
        if cons.BuildStructures[1] == 'T1Resource' or cons.BuildStructures[1] == 'T2Resource' or cons.BuildStructures[1] == 'T3Resource' then
            relative = true
            closeToBuilder = eng
            local guards = eng:GetGuards()
            for k,v in guards do
                if not v.Dead and v.PlatoonHandle and aiBrain:PlatoonExists(v.PlatoonHandle) then
                    v.PlatoonHandle:PlatoonDisband()
                end
            end
        end

        --LOG("*AI DEBUG: Setting up Callbacks for " .. eng.Sync.id)
        self.SetupEngineerCallbacks(eng)

        -------- BUILD BUILDINGS HERE --------
        for baseNum, baseListData in baseTmplList do
            for k, v in cons.BuildStructures do
                if aiBrain:PlatoonExists(self) then
                    if not eng.Dead then
                        local faction = SUtils.GetEngineerFaction(eng)
                        if aiBrain.CustomUnits[v] and aiBrain.CustomUnits[v][faction] then
                            local replacement = SUtils.GetTemplateReplacement(aiBrain, v, faction, buildingTmpl)
                            if replacement then
                                buildFunction(aiBrain, eng, v, closeToBuilder, relative, replacement, baseListData, reference, cons.NearMarkerType)
                            else
                                buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons.NearMarkerType)
                            end
                        else
                            buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons.NearMarkerType)
                        end
                    else
                        if aiBrain:PlatoonExists(self) then
                            WaitTicks(1)
                            self:PlatoonDisband()
                            return
                        end
                    end
                end
            end
        end

        -- wait in case we're still on a base
        local count = 0
        while not eng.Dead and eng:IsUnitState('Attached') and count < 2 do
            WaitSeconds(6)
            count = count + 1
        end

        if not eng:IsUnitState('Building') then
            return self.ProcessBuildCommand(eng, false)
        end
    end,

-- For AI Patch V8 emoved old sorian delay platoon method
    EngineerBuildAISorian = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local cons = self.PlatoonData.Construction
        local platoonUnits = self:GetPlatoonUnits()
        local armyIndex = aiBrain:GetArmyIndex()
        local x,z = aiBrain:GetArmyStartPos()
        local buildingTmpl, buildingTmplFile, baseTmpl, baseTmplFile

        local eng
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.CONSTRUCTION, v) then
                if not eng then
                    eng = v
                else
                    IssueClearCommands({v})
                    IssueGuard({v}, eng)
                end
            end
        end

        if not eng or eng.Dead then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end

        local FactionToIndex  = { UEF = 1, AEON = 2, CYBRAN = 3, SERAPHIM = 4, NOMADS = 5}
        local factionIndex = cons.FactionIndex or FactionToIndex[eng.factionCategory]

        if not SUtils.CheckForMapMarkers(aiBrain) and cons.NearMarkerType and (cons.NearMarkerType == 'Rally Point' or
        cons.NearMarkerType == 'Protected Experimental Construction') then
            cons.NearMarkerType = nil
            cons.BaseTemplate = nil
        end

        buildingTmplFile = import(cons.BuildingTemplateFile or '/lua/BuildingTemplates.lua')
        baseTmplFile = import(cons.BaseTemplateFile or '/lua/BaseTemplates.lua')
        buildingTmpl = buildingTmplFile[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
        baseTmpl = baseTmplFile[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]

        if self.PlatoonData.NeedGuard then
            eng.NeedGuard = true
        end

        -------- CHOOSE APPROPRIATE BUILD FUNCTION AND SETUP BUILD VARIABLES --------
        local reference = false
        local refName = false
        local buildFunction
        local closeToBuilder
        local relative
        local baseTmplList = {}

        -- if we have nothing to build, disband!
        if not cons.BuildStructures then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end

        if cons.NearUnitCategory then
            self:SetPrioritizedTargetList('support', {ParseEntityCategory(cons.NearUnitCategory)})
            local unitNearBy = self:FindPrioritizedUnit('support', 'Ally', false, self:GetPlatoonPosition(), cons.NearUnitRadius or 50)
            --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." attempt near: ", cons.NearUnitCategory)
            if unitNearBy then
                reference = table.copy(unitNearBy:GetPosition())
                -- get commander home position
                --LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." Near unit: ", cons.NearUnitCategory)
                if cons.NearUnitCategory == 'COMMAND' and unitNearBy.CDRHome then
                    reference = unitNearBy.CDRHome
                end
            else
                reference = table.copy(eng:GetPosition())
            end
            relative = false
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
        elseif cons.Wall then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100
            relative = false
            reference = AIUtils.GetLocationNeedingWalls(aiBrain, 200, 5, 'DEFENSE', cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            table.insert(baseTmplList, 'Blank')
            buildFunction = AIBuildStructures.WallBuilder
        elseif cons.NearBasePatrolPoints then
            relative = false
            reference = AIUtils.GetBasePatrolPointsSorian(aiBrain, cons.Location or 'MAIN', cons.Radius or 100)
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            for k,v in reference do
                table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, v))
            end
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
        elseif cons.NearMarkerType and cons.ExpansionBase then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100

            if cons.FireBase and cons.FireBaseRange then
                reference, refName = AIUtils.AIFindFirebaseLocationSorian(aiBrain, cons.LocationType, cons.FireBaseRange, cons.NearMarkerType,
                                                    cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType,
                                                    cons.MarkerUnitCount, cons.MarkerUnitCategory, cons.MarkerRadius)
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            elseif cons.NearMarkerType == 'Expansion Area' then
                reference, refName = AIUtils.AIFindExpansionAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            elseif cons.NearMarkerType == 'Naval Area' then
                reference, refName = AIUtils.AIFindNavalAreaNeedsEngineer(aiBrain, cons.LocationType,
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            else
                local mapSizeX, mapSizeZ = GetMapSize()
                if mapSizeX > 512 and mapSizeZ > 512 then
                    reference, refName = AIUtils.AIFindStartLocationNeedsEngineerSorian(aiBrain, cons.LocationType,
                            (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                else
                    reference, refName = AIUtils.AIFindStartLocationNeedsEngineer(aiBrain, cons.LocationType,
                            (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType)
                end
                -- didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            end

            -- If moving far from base, tell the assisting platoons to not go with
            if cons.FireBase or cons.ExpansionBase then
                local guards = eng:GetGuards()
                for k,v in guards do
                    if not v.Dead and v.PlatoonHandle and EntityCategoryContains(categories.CONSTRUCTION, v) then
                        v.PlatoonHandle:PlatoonDisband()
                    end
                end
            end

            if not cons.BaseTemplate and (cons.NearMarkerType == 'Naval Area' or cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, eng, cons)
            end
            relative = false
            if reference and aiBrain:GetThreatAtPosition(reference , 1, true, 'AntiSurface') > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            -- Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            --buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
            buildFunction = AIBuildStructures.AIBuildBaseTemplate
        elseif cons.NearMarkerType and cons.FireBase and cons.FireBaseRange then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindFirebaseLocationSorian(aiBrain, cons.LocationType, cons.FireBaseRange, cons.NearMarkerType,
                                                cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType,
                                                cons.MarkerUnitCount, cons.MarkerUnitCategory, cons.MarkerRadius)

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindDefensivePointNeedsStructureSorian(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Naval Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindNavalDefensivePointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Expansion Area' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindExpansionPointNeedsStructure(aiBrain, cons.LocationType, (cons.LocationRadius or 100),
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1),
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface'))

            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType then
            --WARN('*Data weird for builder named - ' .. self.BuilderName)
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            if not cons.BaseTemplate and (cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area') then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase(aiBrain, refName, reference, (cons.ExpansionRadius or 100), cons.ExpansionTypes, nil, cons)
            end
            if reference and aiBrain:GetThreatAtPosition(reference, 1, true) > 0 then
                --aiBrain:ExpansionHelp(eng, reference)
            end
            table.insert(baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation(baseTmpl, reference))
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.AvoidCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager.Location
            local cat = ParseEntityCategory(cons.AdjacencyCategory)
            local avoidCat = ParseEntityCategory(cons.AvoidCategory)
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.FindUnclutteredArea(aiBrain, cat, pos, radius, cons.maxUnits, cons.maxRadius, avoidCat)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            table.insert(baseTmplList, baseTmpl)
        elseif cons.AdjacencyCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager.Location
            local cat = ParseEntityCategory(cons.AdjacencyCategory)
            local radius = (cons.AdjacencyDistance or 50)
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.GetOwnUnitsAroundPointSorian(aiBrain, cat, pos, radius, cons.ThreatMin,
                                                        cons.ThreatMax, cons.ThreatRings, 'Overall', cons.MinRadius or 0)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            table.insert(baseTmplList, baseTmpl)
        else
            table.insert(baseTmplList, baseTmpl)
            relative = true
            reference = true
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        end
        if cons.BuildClose then
            closeToBuilder = eng
        end
        if cons.BuildStructures[1] == 'T1Resource' or cons.BuildStructures[1] == 'T2Resource' or cons.BuildStructures[1] == 'T3Resource' then
            relative = true
            closeToBuilder = eng
            local guards = eng:GetGuards()
            for k,v in guards do
                if not v.Dead and v.PlatoonHandle and aiBrain:PlatoonExists(v.PlatoonHandle) and EntityCategoryContains(categories.CONSTRUCTION, v) then
                    v.PlatoonHandle:PlatoonDisband()
                end
            end
        end

        --LOG("*AI DEBUG: Setting up Callbacks for " .. eng.Sync.id)
        self.SetupEngineerCallbacksSorian(eng)

        -------- BUILD BUILDINGS HERE --------
        for baseNum, baseListData in baseTmplList do
            for k, v in cons.BuildStructures do
                if aiBrain:PlatoonExists(self) then
                    if not eng.Dead then
                        local faction = SUtils.GetEngineerFaction(eng)
                        if aiBrain.CustomUnits[v] and aiBrain.CustomUnits[v][faction] then
                            local replacement = SUtils.GetTemplateReplacement(aiBrain, v, faction, buildingTmpl)
                            if replacement then
                                buildFunction(aiBrain, eng, v, closeToBuilder, relative, replacement, baseListData, reference, cons.NearMarkerType)
                            else
                                buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons.NearMarkerType)
                            end
                        else
                            buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons.NearMarkerType)
                        end
                    else
                        if aiBrain:PlatoonExists(self) then
                            WaitTicks(1)
                            self:PlatoonDisband()
                            return
                        end
                    end
                end
            end
        end

        -- wait in case we're still on a base
        if not eng.Dead then
            local count = 0
            while eng:IsUnitState('Attached') and count < 2 do
                WaitSeconds(6)
                count = count + 1
            end
        end

        if not eng:IsUnitState('Building') then
            return self.ProcessBuildCommandSorian(eng, false)
        end
    end,

-- UVESO's Stuff: ------------------------------------------------------------------------------------

    -- Hook for Mass RepeatBuild
    PlatoonDisband = function(self)
        local aiBrain = self:GetBrain()
--        LOG('* AI-Uveso: PlatoonDisband = '..repr(self.PlatoonData.Construction.BuildStructures))
--        LOG('* AI-Uveso: PlatoonDisband = '..repr(self.PlatoonData.Construction))
        if self.PlatoonData.Construction.RepeatBuild then
--            LOG('* AI-Uveso: Repeat build = '..repr(self.PlatoonData.Construction.BuildStructures[1]))
            -- only repeat build if less then 10% of all structures are extractors
            local UCBC = import('/lua/editor/UnitCountBuildConditions.lua')
            if UCBC.HaveUnitRatioVersusCap(aiBrain, 0.10, '<', categories.STRUCTURE * categories.MASSEXTRACTION) then
                -- only repeat if we have a free mass spot
                local MABC = import('/lua/editor/MarkerBuildConditions.lua')
                if MABC.CanBuildOnMass(aiBrain, 'MAIN', 1000, -500, 1, 0, 'AntiSurface', 1) then  -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
                    self:SetAIPlan('EngineerBuildAI')
                    return
                end
            end
            -- delete the repeat flag so the engineer will not repeat on its next task
            self.PlatoonData.Construction.RepeatBuild = nil
            self:MoveToLocation(aiBrain.BuilderManagers['MAIN'].Position, false)
            return
        end
        OldPlatoonClass.PlatoonDisband(self)
    end,

    BaseManagersDistressAI = function(self)
       -- Only use this with AI-Uveso
        if not self.Uveso then
            return OldPlatoonClass.BaseManagersDistressAI(self)
        end
        WaitTicks(10)
        -- We are leaving this forked thread here because we don't need it.
        KillThread(CurrentThread())
    end,

    InterceptorAIUveso = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local aiBrain = self:GetBrain()
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = table.getn(platoonUnits)
        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        --LOG('* AI-Uveso: * InterceptorAIUveso: Switching RULEUTC_StealthToggle')
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        --LOG('* AI-Uveso: * InterceptorAIUveso: Switching RULEUTC_CloakToggle')
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Uveso: * InterceptorAIUveso: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local path
        local reason
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local basePosition
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonPos
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local GetTargetsFrom = basePosition
        local LastTargetCheck
        local DistanceToBase = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        while aiBrain:PlatoonExists(self) do
            PlatoonPos = self:GetPlatoonPosition()
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonPos
            else
                DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                if DistanceToBase > maxRadius then
                    target = nil
                end
            end
            -- only get a new target and make a move command if the target is dead
            if not target or target.Dead or target:BeenDestroyed() then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    --LOG('* AI-Uveso: *InterceptorAIUveso: found UnitWithPath')
                    self:Stop()
                    target = UnitWithPath
                    if self.PlatoonData.IgnorePathing then
                        self:AttackTarget(UnitWithPath)
                    elseif path then
                        self:MovePath(aiBrain, path, bAggroMove, UnitWithPath)
                    -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                    else
                        self:MoveDirect(aiBrain, bAggroMove, UnitWithPath)
                    end
                    -- We moved to the target, attack it now if its still exists
                    if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead and not UnitWithPath:BeenDestroyed() then
                        self:AttackTarget(UnitWithPath)
                    end
                elseif UnitNoPath then
                    --LOG('* AI-Uveso: *InterceptorAIUveso: found UnitNoPath')
                    self:Stop()
                    target = UnitNoPath
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        self:AttackTarget(UnitNoPath)
                    else
                        self:SimpleReturnToBase(basePosition)
                    end
                else
                    --LOG('* AI-Uveso: *InterceptorAIUveso: no target found '..repr(reason))
                    -- we have no target return to main base
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        if VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 30 then
                            self:MoveToLocation(basePosition, false)
                        else
                            -- we are at home and we don't have a target. Disband!
                            if aiBrain:PlatoonExists(self) then
                                self:PlatoonDisband()
                                return
                            end
                        end
                    else
                        if not self.SuicideMode then
                            self.SuicideMode = true
                            self.PlatoonData.AttackEnemyStrength = 1000
                            self.PlatoonData.GetTargetsFromBase = false
                            self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self:InterceptorAIUveso()
                        else
                            self:SimpleReturnToBase(basePosition)
                        end
                    end
                end
            -- targed exists and is not dead
            end
            WaitTicks(1)
            if aiBrain:PlatoonExists(self) and target and not target.Dead then
                LastTargetPos = target:GetPosition()
                -- check if we are still inside the attack radius and be sure the area is not a nuke blast area
                if VDist2(basePosition[1] or 0, basePosition[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < maxRadius and not AIUtils.IsNukeBlastArea(aiBrain, LastTargetPos) then
                    self:Stop()
                    if self.PlatoonData.IgnorePathing or VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0) < 60 then
                        self:AttackTarget(target)
                    else
                        self:MoveToLocation(LastTargetPos, false)
                    end
                    WaitTicks(10)
                else
                    target = nil
                end
            end
            WaitTicks(10)
        end
    end,

    LandAttackAIUveso = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = table.getn(platoonUnits)
        local ExperimentalInPlatoon = false
        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if IsDestroyed(v) then
                        WARN('Unit is not Dead but DESTROYED')
                    end
                    if v:BeenDestroyed() then
                        WARN('Unit is not Dead but DESTROYED')
                    end
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    if EntityCategoryContains(categories.EXPERIMENTAL, v) then
                        ExperimentalInPlatoon = true
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Uveso: * LandAttackAIUveso: MoveToCategories missing in platoon '..self.BuilderName)
        end
        -- Set the target list to all platoon units
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local aiBrain = self:GetBrain()
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local WantsTransport = self.PlatoonData.RequireTransport
        local maxRadius = self.PlatoonData.SearchRadius
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local DistanceToTarget = 0
        local basePosition = aiBrain.BuilderManagers['MAIN'].Position
        local losttargetnum = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        while aiBrain:PlatoonExists(self) do 

            self.MergeWithNearbyPlatoonsSwarm( self, aiBrain, 'LandAttackAIUveso', 30, false, 40)


            local OriginalSurfaceThreat = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)
            local mystrength = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)

            if mystrength <= (OriginalSurfaceThreat * .40) then
					self.MergeIntoNearbyPlatoons( self, aiBrain, 'LandAttackAIUveso', 100, false)
					return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				end	

            PlatoonPos = self:GetPlatoonPosition()
            -- only get a new target and make a move command if the target is dead or after 10 seconds
            if not target or target.Dead then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', PlatoonPos, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    losttargetnum = 0
                    self:Stop()
                    target = UnitWithPath
                    LastTargetPos = table.copy(target:GetPosition())
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    if DistanceToTarget > 30 then
                        -- if we have a path then use the waypoints
                        if self.PlatoonData.IgnorePathing then
                            self:Stop()
                            self:SetPlatoonFormationOverride('AttackFormation')
                            self:AttackTarget(UnitWithPath)
                        elseif path then
                            self:MoveToLocationInclTransport(target, LastTargetPos, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon)
                        -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                        else
                            self:MoveDirect(aiBrain, bAggroMove, target)
                        end
                        -- We moved to the target, attack it now if its still exists
                        if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead and not UnitWithPath:BeenDestroyed() then
                            self:Stop()
                            self:SetPlatoonFormationOverride('AttackFormation')
                            self:AttackTarget(UnitWithPath)
                        end
                    end
                elseif UnitNoPath then
                    losttargetnum = 0
                    self:Stop()
                    target = UnitNoPath
                    self:MoveWithTransport(aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
                    -- We moved to the target, attack it now if its still exists
                    if aiBrain:PlatoonExists(self) and UnitNoPath and not UnitNoPath.Dead and not UnitNoPath:BeenDestroyed() then
                        self:SetPlatoonFormationOverride('AttackFormation')
                        self:AttackTarget(UnitNoPath)
                    end
                else
                    -- we have no target return to main base
                    losttargetnum = losttargetnum + 1
                    if losttargetnum > 2 then
                        if not self.SuicideMode then
                            self.SuicideMode = true
                            self.PlatoonData.AttackEnemyStrength = 1000
                            self.PlatoonData.GetTargetsFromBase = false
                            self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:LandAttackAIUveso()
                        else
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:ForceReturnToNearestBaseAIUveso()
                        end
                    end
                end
            else
                if aiBrain:PlatoonExists(self) and target and not target.Dead and not target:BeenDestroyed() then
                    LastTargetPos = target:GetPosition()
                    -- check if the target is not in a nuke blast area
                    if AIUtils.IsNukeBlastArea(aiBrain, LastTargetPos) then
                        target = nil
                    else
                        self:SetPlatoonFormationOverride('AttackFormation')
                        self:AttackTarget(target)
                    end
                    WaitSeconds(2)
                end
            end
            WaitSeconds(1)
        end
    end,

    NavalAttackAIUveso = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = table.getn(platoonUnits)
        local ExperimentalInPlatoon = false
        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_JammingToggle') then
                        v:SetScriptBit('RULEUTC_JammingToggle', false)
                    end
                    if EntityCategoryContains(categories.EXPERIMENTAL, v) then
                        ExperimentalInPlatoon = true
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Uveso: * NavalAttackAIUveso: MoveToCategories missing in platoon '..self.BuilderName)
        end
        -- Set the target list to all platoon units
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local aiBrain = self:GetBrain()
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local maxRadius = self.PlatoonData.SearchRadius or 250
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local DistanceToTarget = 0
        local basePosition = PlatoonPos   -- Platoons will be created near a base, so we can return to this position if we don't have targets.
        local losttargetnum = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        while aiBrain:PlatoonExists(self) do
            PlatoonPos = self:GetPlatoonPosition()
            -- only get a new target and make a move command if the target is dead or after 10 seconds
            if not target or target.Dead then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', PlatoonPos, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    losttargetnum = 0
                    self:Stop()
                    target = UnitWithPath
                    LastTargetPos = table.copy(target:GetPosition())
                    DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, LastTargetPos[1] or 0, LastTargetPos[3] or 0)
                    if DistanceToTarget > 30 then
                        -- if we have a path then use the waypoints
                        if self.PlatoonData.IgnorePathing then
                            self:Stop()
                            self:AttackTarget(UnitWithPath)
                        elseif path then
                            self:MovePath(aiBrain, path, bAggroMove, target)
                        -- if we dont have a path, but UnitWithPath is true, then we have no map markers but PathCanTo() found a direct path
                        else
                            self:MoveDirect(aiBrain, bAggroMove, target)
                        end
                        -- We moved to the target, attack it now if its still exists
                        if aiBrain:PlatoonExists(self) and UnitWithPath and not UnitWithPath.Dead and not UnitWithPath:BeenDestroyed() then
                            self:Stop()
                            self:AttackTarget(UnitWithPath)
                        end
                    end
                else
                    -- we have no target return to main base
                    losttargetnum = losttargetnum + 1
                    if losttargetnum > 2 then
                        if not self.SuicideMode then
                            self.SuicideMode = true
                            self.PlatoonData.AttackEnemyStrength = 1000
                            self.PlatoonData.GetTargetsFromBase = false
                            self.PlatoonData.MoveToCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self.PlatoonData.WeaponTargetCategories = { categories.EXPERIMENTAL, categories.TECH3, categories.TECH2, categories.ALLUNITS }
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:NavalAttackAIUveso()
                        else
                            self:Stop()
                            self:SetPlatoonFormationOverride('NoFormation')
                            self:ForceReturnToNavalBaseAIUveso(aiBrain, basePosition)
                        end
                    end
                end
            else
                if aiBrain:PlatoonExists(self) and target and not target.Dead and not target:BeenDestroyed() then
                    LastTargetPos = target:GetPosition()
                    -- check if the target is not in a nuke blast area
                    if AIUtils.IsNukeBlastArea(aiBrain, LastTargetPos) then
                        target = nil
                    else
                        self:SetPlatoonFormationOverride('AttackFormation')
                        self:AttackTarget(target)
                    end
                    WaitSeconds(2)
                end
            end
            WaitSeconds(1)
        end
    end,
    
    ACUAttackAIUveso = function(self)
        --LOG('* AI-Uveso: * ACUAttackAIUveso: START '..self.BuilderName)
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local aiBrain = self:GetBrain()
        local PlatoonUnits = self:GetPlatoonUnits()
        local cdr = PlatoonUnits[1]
        -- There should be only the commander inside this platoon. Check it.
        if not cdr then
            WARN('* ACUAttackAIUveso: Platoon formed but Commander unit not found!')
            WaitTicks(1)
            for k,v in self:GetPlatoonUnits() or {} do
                if EntityCategoryContains(categories.COMMAND, v) then
                    WARN('* ACUAttackAIUveso: Commander found in platoon on index: '..k)
                    cdr = v
                else
                    WARN('* ACUAttackAIUveso: Platoon unit Index '..k..' is not a commander!')
                end
            end
            if not cdr then
                self:PlatoonDisband()
                return
            end
        end
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        cdr.HealthOLD = 100
        cdr.CDRHome = aiBrain.BuilderManagers['MAIN'].Position
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Uveso: * ACUAttackAIUveso: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        -- prevent ACU from reclaiming while attack moving
        cdr:RemoveCommandCap('RULEUCC_Reclaim')
        cdr:RemoveCommandCap('RULEUCC_Repair')
        local TargetUnit, DistanceToTarget
        local PlatoonPos = self:GetPlatoonPosition()
        -- land and air units are assigned to mainbase
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local GetTargetsFrom = cdr.CDRHome
        local LastTargetCheck
        local DistanceToBase = 0
        local UnitsInACUBaseRange
        local ReturnToBaseAfterGameTime = self.PlatoonData.ReturnToBaseAfterGameTime or false
        local DoNotLeavePlatoonUnderHealth = self.PlatoonData.DoNotLeavePlatoonUnderHealth or 30
        local maxRadius
        local maxTimeRadius
        local SearchRadius = self.PlatoonData.SearchRadius or 250
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        while aiBrain:PlatoonExists(self) do
            if cdr.Dead then break end
            cdr.position = self:GetPlatoonPosition()
            -- leave the loop and disband this platton in time
            if ReturnToBaseAfterGameTime and ReturnToBaseAfterGameTime < GetGameTimeSeconds()/60 then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: ReturnToBaseAfterGameTime:'..ReturnToBaseAfterGameTime..' >= '..GetGameTimeSeconds()/60)
                UUtils.CDRParkingHome(self,cdr)
                break
            end
            -- the maximum radis that the ACU can be away from base
            maxRadius = (UUtils.ComHealth(cdr)-65)*7 -- If the comanders health is 100% then we have a maxtange of ~250 = (100-65)*7
            maxTimeRadius = 240 - GetGameTimeSeconds()/60*6 -- reduce the radius by 6 map units per minute. After 30 minutes it's (240-180) = 60
            if maxRadius > maxTimeRadius then 
                maxRadius = math.max( 60, maxTimeRadius ) -- IF maxTimeRadius < 60 THEN maxTimeRadius = 60
            end
            if maxRadius > SearchRadius then
                maxRadius = SearchRadius
            end
            UnitsInACUBaseRange = aiBrain:GetUnitsAroundPoint( TargetSearchCategory, cdr.CDRHome, maxRadius, 'Enemy')
            -- get the position of this platoon (ACU)
            if not GetTargetsFromBase then
                -- we don't get out targets relativ to base position. Use the ACU position
                GetTargetsFrom = cdr.position
            end
            ----------------------------------------------
            --- This is the start of the main ACU loop ---
            ----------------------------------------------
            if aiBrain:GetEconomyStoredRatio('ENERGY') > 0.95 and UUtils.ComHealth(cdr) < 100 then
                cdr:SetAutoOvercharge(true)
            else
                cdr:SetAutoOvercharge(false)
            end
           
            -- in case we have no Factory left, recover!
            if not aiBrain:GetListOfUnits(categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY, false)[1] then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: exiting attack function. RECOVER')
                self:PlatoonDisband()
                return
            -- check if we are further away from base then the closest enemy
            elseif UUtils.CDRRunHomeEnemyNearBase(self,cdr,UnitsInACUBaseRange) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: CDRRunHomeEnemyNearBase')
                TargetUnit = false
            -- check if we get actual damage, then move home
            elseif UUtils.CDRRunHomeAtDamage(self,cdr) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: CDRRunHomeAtDamage')
                TargetUnit = false
            -- check how much % health we have and go closer to our base
            elseif UUtils.CDRRunHomeHealthRange(self,cdr,maxRadius) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: CDRRunHomeHealthRange')
                TargetUnit = false
            -- can we upgrade ?
            elseif table.getn(UnitsInACUBaseRange) <= 0 and VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) < 60 and self:BuildACUEnhancements(cdr) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements')
                -- Do nothing if BuildACUEnhancements is true. we are upgrading!
            -- only get a new target and make a move command if the target is dead
            else
               --LOG('* AI-Uveso: * ACUAttackAIUveso: ATTACK')
                -- ToDo: scann for enemy COM and change target if needed
                TargetUnit, _, _, _ = AIUtils.AIFindNearestCategoryTargetInRangeCDR(aiBrain, GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false)
                -- if we have a target, move to the target and attack
                if TargetUnit then
                    --LOG('* AI-Uveso: * ACUAttackAIUveso: ATTACK TargetUnit')
                    if aiBrain:PlatoonExists(self) and TargetUnit and not TargetUnit.Dead and not TargetUnit:BeenDestroyed() then
                        local targetPos = TargetUnit:GetPosition()
                        local cdrNewPos = {}
                        cdr:GetNavigator():AbortMove()
                        cdrNewPos[1] = targetPos[1] + Random(-3, 3)
                        cdrNewPos[2] = targetPos[2]
                        cdrNewPos[3] = targetPos[3] + Random(-3, 3)
                        self:MoveToLocation(cdrNewPos, false)
                        WaitTicks(1)
                        if TargetUnit and not TargetUnit.Dead and not TargetUnit:BeenDestroyed() then
                            self:AttackTarget(TargetUnit)
                        end
                    end
                -- if we have no target, move to base. If we are at base, dance. (random moves)
                elseif UUtils.CDRForceRunHome(self,cdr) then
                    --LOG('* AI-Uveso: * ACUAttackAIUveso: CDRForceRunHome true. we are running home')
                -- we are at home, dance if we have nothing to do.
                else
                    -- There is nothing to fight; so we left the attack function and see if we can build something
                    --LOG('* AI-Uveso: * ACUAttackAIUveso:We are at home and dancing')
                    --LOG('* AI-Uveso: * ACUAttackAIUveso: exiting attack function')
                    self:PlatoonDisband()
                    return
                end
            end
            --DrawCircle(cdr.CDRHome, maxRadius, '00FFFF')
            WaitTicks(10)
            --------------------------------------------
            --- This is the end of the main ACU loop ---
            --------------------------------------------
        end
        --LOG('* AI-Uveso: * ACUAttackAIUveso: END '..self.BuilderName)
        self:PlatoonDisband()
    end,
    
    BuildACUEnhancements = function(platoon,cdr)
        local EnhancementsByUnitID = {
            -- UEF
            ['uel0001'] = {'HeavyAntiMatterCannon', 'DamageStabilization', 'Shield', 'ShieldGeneratorField'},
            -- Aeon
            ['ual0001'] = {'HeatSink', 'CrysalisBeam', 'Shield', 'ShieldHeavy'},
            -- Cybran
            ['url0001'] = {'CoolingUpgrade', 'StealthGenerator', 'MicrowaveLaserGenerator', 'CloakingGenerator'},
            -- Seraphim
            ['xsl0001'] = {'RateOfFire', 'DamageStabilization', 'BlastAttack', 'DamageStabilizationAdvanced'},
            -- Nomads
            ['xnl0001'] = {'Capacitor', 'GunUpgrade', 'MovementSpeedIncrease', 'DoubleGuns'},

            -- UEF - Black Ops ACU
            ['eel0001'] = {'GatlingEnergyCannon', 'CombatEngineering', 'ShieldBattery', 'AutomaticBarrelStabalizers', 'AssaultEngineering', 'ImprovedShieldBattery', 'EnhancedPowerSubsystems', 'ApocalypticEngineering', 'AdvancedShieldBattery'},
            -- Aeon
            ['eal0001'] = {'PhasonBeamCannon', 'CombatEngineering', 'ShieldBattery', 'DualChannelBooster', 'AssaultEngineering', 'ImprovedShieldBattery', 'EnergizedMolecularInducer', 'ApocalypticEngineering', 'AdvancedShieldBattery'},
            -- Cybram
            ['erl0001'] = {'EMPArray', 'CombatEngineering', 'ArmorPlating', 'AdjustedCrystalMatrix', 'AssaultEngineering', 'StructuralIntegrityFields', 'EnhancedLaserEmitters', 'ApocalypticEngineering', 'CompositeMaterials'},
            -- Seraphim
            ['esl0001'] = {'PlasmaGatlingCannon', 'CombatEngineering', 'ElectronicsEnhancment', 'PhasedEnergyFields', 'AssaultEngineering', 'PersonalTeleporter', 'SecondaryPowerFeeds', 'ApocalypticEngineering', 'CloakingSubsystems'},
        }
        local CRDBlueprint = cdr:GetBlueprint()
        --LOG('* AI-Uveso: BlueprintId '..repr(CRDBlueprint.BlueprintId))
        local ACUUpgradeList = EnhancementsByUnitID[CRDBlueprint.BlueprintId]
        --LOG('* AI-Uveso: ACUUpgradeList '..repr(ACUUpgradeList))
        local NextEnhancement = false
        local HaveEcoForEnhancement = false
        for _,enhancement in ACUUpgradeList or {} do
            local wantedEnhancementBP = CRDBlueprint.Enhancements[enhancement]
            --LOG('* AI-Uveso: wantedEnhancementBP '..repr(wantedEnhancementBP))
            if not wantedEnhancementBP then
                SPEW('* AI-Uveso: ACUAttackAIUveso: no enhancement found for  = '..repr(enhancement))
            elseif cdr:HasEnhancement(enhancement) then
                NextEnhancement = false
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgrade(cdr, wantedEnhancementBP) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --LOG('* AI-Uveso: * ACUAttackAIUveso: *** Set as Enhancememnt: '..NextEnhancement)
                end
            else
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements: Eco is bad for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = false
                    -- if we don't have the eco for this ugrade, stop the search
                    --LOG('* AI-Uveso: * ACUAttackAIUveso: canceled search. no eco available')
                    break
                end
            end
        end
        if NextEnhancement and HaveEcoForEnhancement then
            --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements Building '..NextEnhancement)
            if platoon:BuildEnhancement(cdr, NextEnhancement) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements returned true'..NextEnhancement)
                return true
            else
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildACUEnhancements returned false'..NextEnhancement)
                return false
            end
        end
        return false
    end,
    
    EcoGoodForUpgrade = function(platoon,cdr,enhancement)
        local aiBrain = platoon:GetBrain()
        local BuildRate = cdr:GetBuildRate()
        if not enhancement.BuildTime then
            WARN('* AI-Uveso: EcoGoodForUpgrade: Enhancement has no buildtime: '..repr(enhancement))
        end
        --LOG('* AI-Uveso: cdr:GetBuildRate() '..BuildRate..'')
        local drainMass = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostMass
        local drainEnergy = (BuildRate / enhancement.BuildTime) * enhancement.BuildCostEnergy
        --LOG('* AI-Uveso: drain: m'..drainMass..'  e'..drainEnergy..'')
        --LOG('* AI-Uveso: Pump: m'..math.floor(aiBrain:GetEconomyTrend('MASS')*10)..'  e'..math.floor(aiBrain:GetEconomyTrend('ENERGY')*10)..'')
        if aiBrain.HasParagon then
            return true
        elseif aiBrain:GetEconomyTrend('MASS')*10 >= drainMass and aiBrain:GetEconomyTrend('ENERGY')*10 >= drainEnergy
        and aiBrain:GetEconomyStoredRatio('MASS') > 0.05 and aiBrain:GetEconomyStoredRatio('ENERGY') > 0.95 then
            -- only RUSH AI; don't enhance if mass storage is lower than 90%
            local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
            if personality == 'uvesorush' or personality == 'uvesorushcheat' then
                if aiBrain:GetEconomyStoredRatio('MASS') < 0.90 then
                    return false
                end
            end
            return true
        end
        return false
    end,
    
    BuildEnhancement = function(platoon,cdr,enhancement)
        --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildEnhancement '..enhancement)
        local aiBrain = platoon:GetBrain()

        IssueStop({cdr})
        IssueClearCommands({cdr})
        
        if not cdr:HasEnhancement(enhancement) then
            
            local tempEnhanceBp = cdr:GetBlueprint().Enhancements[enhancement]
            local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(cdr.EntityId)
            -- Do we have already a enhancment in this slot ?
            if unitEnhancements[tempEnhanceBp.Slot] and unitEnhancements[tempEnhanceBp.Slot] ~= tempEnhanceBp.Prerequisite then
                -- remove the enhancement
                --LOG('* AI-Uveso: * ACUAttackAIUveso: Found enhancement ['..unitEnhancements[tempEnhanceBp.Slot]..'] in Slot ['..tempEnhanceBp.Slot..']. - Removing...')
                local order = { TaskName = "EnhanceTask", Enhancement = unitEnhancements[tempEnhanceBp.Slot]..'Remove' }
                IssueScript({cdr}, order)
                WaitTicks(10)
            end
            --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildEnhancement: '..platoon:GetBrain().Nickname..' IssueScript: '..enhancement)
            local order = { TaskName = "EnhanceTask", Enhancement = enhancement }
            IssueScript({cdr}, order)
        end
        while not cdr.Dead and not cdr:HasEnhancement(enhancement) do
            if UUtils.ComHealth(cdr) < 60 then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildEnhancement: '..platoon:GetBrain().Nickname..' Emergency!!! low health, canceling Enhancement '..enhancement)
                IssueStop({cdr})
                IssueClearCommands({cdr})
                return false
            end
            WaitTicks(10)
        end
        --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildEnhancement: '..platoon:GetBrain().Nickname..' Upgrade finished '..enhancement)
        return true
    end,

    MoveWithTransport = function(self, aiBrain, bAggroMove, target, basePosition, ExperimentalInPlatoon)
        local TargetPosition = table.copy(target:GetPosition())
        local usedTransports = false
        self:SetPlatoonFormationOverride('NoFormation')
        --LOG('* AI-Uveso: * MoveWithTransport: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
        if not ExperimentalInPlatoon and aiBrain:PlatoonExists(self) then
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        if not usedTransports then
            --LOG('* AI-Uveso: * MoveWithTransport: SendPlatoonWithTransportsNoCheck failed.')
            local PlatoonPos = self:GetPlatoonPosition() or TargetPosition
            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
            if DistanceToBase < DistanceToTarget or DistanceToTarget > 50 then
                --LOG('* AI-Uveso: * MoveWithTransport: base is nearer then distance to target or distance to target over 50. Return To base')
                self:SimpleReturnToBase(basePosition)
            else
                --LOG('* AI-Uveso: * MoveWithTransport: Direct move to Target')
                if bAggroMove then
                    self:AggressiveMoveToLocation(TargetPosition)
                else
                    self:MoveToLocation(TargetPosition, false)
                end
            end
        else
            --LOG('* AI-Uveso: * MoveWithTransport: We got a transport!!')
        end
    end,

    MoveDirect = function(self, aiBrain, bAggroMove, target)
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local TargetPosition = table.copy(target:GetPosition())
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        local ATTACKFORMATION = false
        if bAggroMove then
            self:AggressiveMoveToLocation(TargetPosition)
        else
            self:MoveToLocation(TargetPosition, false)
        end
        while aiBrain:PlatoonExists(self) do
            PlatoonPosition = self:GetPlatoonPosition() or TargetPosition
            dist = VDist2( TargetPosition[1], TargetPosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            local platoonUnitscheck = self:GetPlatoonUnits()
            if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
                --LOG('* AI-Uveso: * MoveDirect: unit in platoon destroyed!!!')
                self:SetPlatoonFormationOverride('AttackFormation')
            end
            --LOG('* AI-Uveso: * MoveDirect: dist to next Waypoint: '..dist)
            --LOG('* AI-Uveso: * MoveDirect: dist to target: '..dist)
            if not ATTACKFORMATION and dist < 80 then
                ATTACKFORMATION = true
                --LOG('* AI-Uveso: * MoveDirect: dist < 50 '..dist)
                self:SetPlatoonFormationOverride('AttackFormation')
            end
            if dist < 20 then
                return
            end
            -- Do we move ?
            if Lastdist ~= dist then
                Stuck = 0
                Lastdist = dist
            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
            else
                Stuck = Stuck + 1
                if Stuck > 20 then
                    --LOG('* AI-Uveso: * MoveDirect: Stucked while moving to target. Stuck='..Stuck)
                    self:Stop()
                    return
                end
            end
            -- If we lose our target, stop moving to it.
            if not target or target.Dead then
                --LOG('* AI-Uveso: * MoveDirect: Lost target while moving to target. ')
                return
            end
            WaitTicks(10)
        end
    end,

    MovePath = function(self, aiBrain, path, bAggroMove, target)
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        local AirCUT = 0
        if self.MovementLayer == 'Air' then
            AirCUT = 3
        end
        local PathNodesCount = table.getn(path)
        local ATTACKFORMATION = false
        for i=1, PathNodesCount - AirCUT do
            local PlatoonPosition
            local Lastdist
            local dist
            local Stuck = 0
            --LOG('* AI-Uveso: * MovePath: moving to destination. i: '..i..' coords '..repr(path[i]))
            if bAggroMove then
                self:AggressiveMoveToLocation(path[i])
            else
                self:MoveToLocation(path[i], false)
            end
            while aiBrain:PlatoonExists(self) do
                PlatoonPosition = self:GetPlatoonPosition() or path[i]
                dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                local platoonUnitscheck = self:GetPlatoonUnits()
                if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
                    --LOG('* AI-Uveso: * MovePath: unit in platoon destroyed!!!')
                    self:SetPlatoonFormationOverride('AttackFormation')
                end
                --LOG('* AI-Uveso: * MovePath: dist to next Waypoint: '..dist)
                distEnd = VDist2( path[PathNodesCount][1], path[PathNodesCount][3], PlatoonPosition[1], PlatoonPosition[3] )
                --LOG('* AI-Uveso: * MovePath: dist to Path End: '..distEnd)
                if not ATTACKFORMATION and distEnd < 80 then
                    ATTACKFORMATION = true
                    --LOG('* AI-Uveso: * MovePath: distEnd < 50 '..distEnd)
                    self:SetPlatoonFormationOverride('AttackFormation')
                end
                -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                if dist < 20 then
                    -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                    self:Stop()
                    break
                end
                -- Do we move ?
                if Lastdist ~= dist then
                    Stuck = 0
                    Lastdist = dist
                -- No, we are not moving, wait 20 ticks then break and use the next weaypoint
                else
                    Stuck = Stuck + 1
                    if Stuck > 20 then
                        --LOG('* AI-Uveso: * MovePath: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                        self:Stop()
                        break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                    end
                end
                -- If we lose our target, stop moving to it.
                if not target or target.Dead then
                    --LOG('* AI-Uveso: * MovePath: Lost target while moving to Waypoint. '..repr(path[i]))
                    return
                end
                WaitTicks(10)
            end
        end
    end,

    MoveToLocationInclTransport = function(self, target, TargetPosition, bAggroMove, WantsTransport, basePosition, ExperimentalInPlatoon)
        local platoonUnits = self:GetPlatoonUnits()
        self:SetPlatoonFormationOverride('NoFormation')
        if not TargetPosition then
            TargetPosition = table.copy(target:GetPosition())
        end
        local aiBrain = self:GetBrain()
        local PlatoonPosition = self:GetPlatoonPosition()
        -- this will be true if we got our units transported to the destination
        local usedTransports = false
        local TransportNotNeeded, bestGoalPos
        -- check, if we can reach the destination without a transport
        local unit = AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Land' , PlatoonPosition, TargetPosition, 1000, 512)
        if not aiBrain:PlatoonExists(self) then
            return
        end
        -- don't use a transporter if we have a path and the target is closer then 100 map units
        if path and VDist2( PlatoonPosition[1], PlatoonPosition[3], TargetPosition[1], TargetPosition[3] ) < 100 then
            --LOG('* AI-Uveso: * MoveToLocationInclTransport: no trasnporter used for target distance '..VDist2( PlatoonPosition[1], PlatoonPosition[3], TargetPosition[1], TargetPosition[3] ) )
        -- use a transporter if we don't have a path, or if we want a transport
        elseif not ExperimentalInPlatoon and ((not path and reason ~= 'NoGraph') or WantsTransport)  then
            --LOG('* AI-Uveso: * MoveToLocationInclTransport: SendPlatoonWithTransportsNoCheck')
            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
        end
        -- if we don't got a transport, try to reach the destination by path or directly
        if not usedTransports then
            -- clear commands, so we don't get stuck if we have an unreachable destination
            IssueClearCommands(self:GetPlatoonUnits())
            if path then
                --LOG('* AI-Uveso: * MoveToLocationInclTransport: No transport used, and we dont need it.')
                if table.getn(path) > 1 then
                    --LOG('* AI-Uveso: * MoveToLocationInclTransport: table.getn(path): '..table.getn(path))
                end
                local PathNodesCount = table.getn(path)
                local ATTACKFORMATION = false
                for i=1, PathNodesCount do
                    --LOG('* AI-Uveso: * MoveToLocationInclTransport: moving to destination. i: '..i..' coords '..repr(path[i]))
                    if bAggroMove then
                        self:AggressiveMoveToLocation(path[i])
                    else
                        self:MoveToLocation(path[i], false)
                    end
                    local PlatoonPosition
                    local Lastdist
                    local dist
                    local Stuck = 0
                    while aiBrain:PlatoonExists(self) do
                        PlatoonPosition = self:GetPlatoonPosition() or nil
                        if not PlatoonPosition then break end
                        dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                        local platoonUnitscheck = self:GetPlatoonUnits()
                        if table.getn(platoonUnits) > table.getn(platoonUnitscheck) then
                            --LOG('* AI-Uveso: * MoveToLocationInclTransport: unit in platoon destroyed!!!')
                            self:SetPlatoonFormationOverride('AttackFormation')
                        end
                        --LOG('* AI-Uveso: * MoveToLocationInclTransport: dist to next Waypoint: '..dist)
                        distEnd = VDist2( path[PathNodesCount][1], path[PathNodesCount][3], PlatoonPosition[1], PlatoonPosition[3] )
                        --LOG('* AI-Uveso: * MoveToLocationInclTransport: dist to Path End: '..distEnd)
                        if not ATTACKFORMATION and distEnd < 80 then
                            ATTACKFORMATION = true
                            --LOG('* AI-Uveso: * MoveToLocationInclTransport: distEnd < 50 '..distEnd)
                            self:SetPlatoonFormationOverride('AttackFormation')
                        end
                        -- are we closer then 20 units from the next marker ? Then break and move to the next marker
                        if dist < 20 then
                            -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                            self:Stop()
                            break
                        end
                        -- Do we move ?
                        if Lastdist ~= dist then
                            Stuck = 0
                            Lastdist = dist
                        -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                        else
                            Stuck = Stuck + 1
                            if Stuck > 20 then
                                --LOG('* AI-Uveso: * MoveToLocationInclTransport: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                                self:Stop()
                                break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                            end
                        end
                        -- If we lose our target, stop moving to it.
                        if not target then
                            --LOG('* AI-Uveso: * MoveToLocationInclTransport: Lost target while moving to Waypoint. '..repr(path[i]))
                            self:Stop()
                            return
                        end
                        WaitTicks(10)
                    end
                end
            else
                --LOG('* AI-Uveso: * MoveToLocationInclTransport: No transport used, and we have no Graph to reach the destination. Checking CanPathTo()')
                if reason == 'NoGraph' then
                    local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, TargetPosition)
                    if success then
                        --LOG('* AI-Uveso: * MoveToLocationInclTransport: No transport used, found a way with CanPathTo(). moving to destination')
                        if bAggroMove then
                            self:AggressiveMoveToLocation(bestGoalPos)
                        else
                            self:MoveToLocation(bestGoalPos, false)
                        end
                        local PlatoonPosition
                        local Lastdist
                        local dist
                        local Stuck = 0
                        while aiBrain:PlatoonExists(self) do
                            PlatoonPosition = self:GetPlatoonPosition() or nil
                            if not PlatoonPosition then continue end
                            dist = VDist2( bestGoalPos[1], bestGoalPos[3], PlatoonPosition[1], PlatoonPosition[3] )
                            if dist < 20 then
                                break
                            end
                            -- Do we move ?
                            if Lastdist ~= dist then
                                Stuck = 0
                                Lastdist = dist
                            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                            else
                                Stuck = Stuck + 1
                                if Stuck > 20 then
                                    --LOG('* AI-Uveso: * MoveToLocationInclTransport: Stucked while moving to target. Stuck='..Stuck)
                                    self:Stop()
                                    break -- break the while aiBrain:PlatoonExists(self) do loop and move to the next waypoint
                                end
                            end
                            -- If we lose our target, stop moving to it.
                            if not target then
                                --LOG('* AI-Uveso: * MoveToLocationInclTransport: Lost target while moving to target. ')
                                self:Stop()
                                return
                            end
                            WaitTicks(10)
                        end
                    else
                        --LOG('* AI-Uveso: * MoveToLocationInclTransport: CanPathTo() failed for '..repr(TargetPosition)..' forcing SendPlatoonWithTransportsNoCheck.')
                        if not ExperimentalInPlatoon then
                            usedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, self, TargetPosition, true, false)
                        end
                        if not usedTransports then
                            --LOG('* AI-Uveso: * MoveToLocationInclTransport: CanPathTo() and SendPlatoonWithTransportsNoCheck failed. SimpleReturnToBase!')
                            local PlatoonPos = self:GetPlatoonPosition()
                            local DistanceToTarget = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, TargetPosition[1] or 0, TargetPosition[3] or 0)
                            local DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                            if DistanceToBase < DistanceToTarget and DistanceToTarget > 50 then
                                --LOG('* AI-Uveso: * MoveToLocationInclTransport: base is nearer then distance to target and distance to target over 50. Return To base')
                                self:SimpleReturnToBase(basePosition)
                            else
                                --LOG('* AI-Uveso: * MoveToLocationInclTransport: Direct move to Target')
                                if bAggroMove then
                                    self:AggressiveMoveToLocation(TargetPosition)
                                else
                                    self:MoveToLocation(TargetPosition, false)
                                end
                            end
                        else
                            --LOG('* AI-Uveso: * MoveToLocationInclTransport: CanPathTo() failed BUT we got an transport!!')
                        end

                    end
                else
                    --LOG('* AI-Uveso: * MoveToLocationInclTransport: We have no path but there is a Graph with markers. So why we don\'t get a path ??? (Island or threat too high?) - reason: '..repr(reason))
                end
            end
        else
            --LOG('* AI-Uveso: * MoveToLocationInclTransport: TRANSPORTED.')
        end
    end,

    TransferAIUveso = function(self)
        local aiBrain = self:GetBrain()
        if not aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType] then
            --LOG('* AI-Uveso: * TransferAIUveso: Location ('..self.PlatoonData.MoveToLocationType..') has no BuilderManager!')
            self:PlatoonDisband()
            return
        end
        local eng = self:GetPlatoonUnits()[1]
        if eng and not eng.Dead and eng.BuilderManagerData.EngineerManager then
            --LOG('* AI-Uveso: * TransferAIUveso: '..repr(self.BuilderName))
            eng.BuilderManagerData.EngineerManager:RemoveUnit(eng)
            --LOG('* AI-Uveso: * TransferAIUveso: AddUnit units to - BuilderManagers: '..self.PlatoonData.MoveToLocationType..' - ' .. aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) )
            aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].EngineerManager:AddUnit(eng, true)
            -- Move the unit to the desired base after transfering BuilderManagers to the new LocationType
            local basePosition = aiBrain.BuilderManagers[self.PlatoonData.MoveToLocationType].Position
            --LOG('* AI-Uveso: * TransferAIUveso: Moving transfer-units to - ' .. self.PlatoonData.MoveToLocationType)
            self:MoveToLocationInclTransport(true, basePosition, false, false, basePosition, false)
        end
        if aiBrain:PlatoonExists(self) then
            self:PlatoonDisband()
        end
    end,

    ReclaimAIUveso = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local eng
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD, v) then
                eng = v
                break
            end
        end
        if eng then
            eng.UnitBeingBuilt = eng
            UUtils.ReclaimAIThread(self,eng,aiBrain)
            eng.UnitBeingBuilt = nil
        end
        self:PlatoonDisband()
    end,

    FinisherAI = function(self)
        local aiBrain = self:GetBrain()
        -- Only use this with AI-Uveso
        if not self.PlatoonData or not self.PlatoonData.LocationType then
            self:PlatoonDisband()
            return
        end
        local eng = self:GetPlatoonUnits()[1]
        local engineerManager = aiBrain.BuilderManagers[self.PlatoonData.LocationType].EngineerManager
        if not engineerManager then
            self:PlatoonDisband()
            return
        end
        local unfinishedUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE + categories.EXPERIMENTAL, engineerManager.Location, engineerManager.Radius, 'Ally')
        for k,v in unfinishedUnits do
            local FractionComplete = v:GetFractionComplete()
            if FractionComplete < 1 and table.getn(v:GetGuards()) < 1 then
                self:Stop()
                IssueRepair(self:GetPlatoonUnits(), v)
                break
            end
        end
        local count = 0
        repeat
            WaitSeconds(2)
            if not aiBrain:PlatoonExists(self) then
                return
            end
            count = count + 1
            if eng:IsIdleState() then break end
        until count >= 30
        self:PlatoonDisband()
    end,

    TMLAIUveso = function(self)
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local TML
        for k, v in platoonUnits do
            if not v.Dead and EntityCategoryContains(categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM * categories.TECH2, v) then
                TML = v
                break
            end
        end
        UUtils.TMLAIThread(self,TML,aiBrain)
        self:PlatoonDisband()
    end,

    PlatoonMerger = function(self)
        --LOG('* AI-Uveso: * PlatoonMerger: called from Builder: '..(self.BuilderName or 'Unknown'))
        local aiBrain = self:GetBrain()
        local PlatoonPlan = self.PlatoonData.AIPlan
        --LOG('* AI-Uveso: * PlatoonMerger: AIPlan: '..(PlatoonPlan or 'Unknown'))
        if not PlatoonPlan then
            return
        end
        -- Get all units from the platoon
        local platoonUnits = self:GetPlatoonUnits()
        -- check if we have already a Platoon with this AIPlan
        local AlreadyMergedPlatoon
        local PlatoonList = aiBrain:GetPlatoonsList()
        for _,Platoon in PlatoonList do
            if Platoon:GetPlan() == PlatoonPlan then
                --LOG('* AI-Uveso: * PlatoonMerger: Found Platton with plan '..PlatoonPlan)
                AlreadyMergedPlatoon = Platoon
                break
            end
            --LOG('* AI-Uveso: * PlatoonMerger: Found '..repr(Platoon:GetPlan()))
        end
        -- If we dont have already a platton for this AIPlan, create one.
        if not AlreadyMergedPlatoon then
            AlreadyMergedPlatoon = aiBrain:MakePlatoon( PlatoonPlan..'Platoon', PlatoonPlan )
            AlreadyMergedPlatoon.PlanName = PlatoonPlan
            AlreadyMergedPlatoon.BuilderName = PlatoonPlan..'Platoon'
--            AlreadyMergedPlatoon:UniquelyNamePlatoon(PlatoonPlan)
        end
        -- Add our unit(s) to the platoon
        aiBrain:AssignUnitsToPlatoon( AlreadyMergedPlatoon, platoonUnits, 'support', 'none' )
        -- Disband this platoon, it's no longer needed.
        self:PlatoonDisbandNoAssign()
    end,

    ExtractorUpgradeAI = function(self)
        --LOG('* AI-Uveso: +++ ExtractorUpgradeAI: START')
        local aiBrain = self:GetBrain()
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        while aiBrain:PlatoonExists(self) do
            local ratio = 0.3
            if aiBrain.HasParagon then
                -- if we have a paragon, upgrade mex as fast as possible. Mabye we lose the paragon and need mex again.
                ratio = 1.0
            elseif aiBrain:GetEconomyIncome('MASS') * 10 > 600 then
                --LOG('* AI-Uveso: Mass over 200. Eco running with 30%')
                ratio = 0.25
            elseif GetGameTimeSeconds() > 1800 then -- 30 * 60
                ratio = 0.25
            elseif GetGameTimeSeconds() > 1200 then -- 20 * 60
                ratio = 0.20
            elseif GetGameTimeSeconds() > 900 then -- 15 * 60
                ratio = 0.15
            elseif GetGameTimeSeconds() > 600 then -- 10 * 60
                ratio = 0.15
            elseif GetGameTimeSeconds() > 360 then -- 6 * 60
                ratio = 0.10
            elseif GetGameTimeSeconds() <= 360 then -- 6 * 60 run the first 6 minutes with 0% Eco and 100% Army
                ratio = 0.00
            end
            local platoonUnits = self:GetPlatoonUnits()
            local MassExtractorUnitList = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3), false, false)
            -- Check if we can pause/unpause TECH3 Extractors (for more energy)
            if not UUtils.ExtractorPause( self, aiBrain, MassExtractorUnitList, ratio, 'TECH3') then
                -- Check if we can pause/unpause TECH2 Extractors
                if not UUtils.ExtractorPause( self, aiBrain, MassExtractorUnitList, ratio, 'TECH2') then
                    -- Check if we can pause/unpause TECH1 Extractors
                    if not UUtils.ExtractorPause( self, aiBrain, MassExtractorUnitList, ratio, 'TECH1') then
                        -- We have nothing to pause or unpause, lets upgrade more extractors
                        -- if we have 10% TECH1 extractors left (and 90% TECH2), then upgrade TECH2 to TECH3
                        if UUtils.HaveUnitRatio( aiBrain, 0.90, categories.MASSEXTRACTION * categories.TECH1, '<=', categories.MASSEXTRACTION * categories.TECH2 ) then
                            -- Try to upgrade a TECH2 extractor.
                            if not UUtils.ExtractorUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH2', UnitUpgradeTemplates, StructureUpgradeTemplates) then
                                -- We can't upgrade a TECH2 extractor. Try to upgrade from TECH1 to TECH2
                                UUtils.ExtractorUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                            end
                        else
                            -- We have less than 90% TECH2 extractors compared to TECH1. Upgrade more TECH1
                            UUtils.ExtractorUpgrade(self, aiBrain, MassExtractorUnitList, ratio, 'TECH1', UnitUpgradeTemplates, StructureUpgradeTemplates)
                        end
                    end
                end
            end
            -- Check the Eco every x Ticks
            WaitTicks(10)
            -- find dead units inside the platoon and disband if we find one
            for k,v in self:GetPlatoonUnits() do
                if not v or v.Dead or v:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    --LOG('* AI-Uveso: +++ ExtractorUpgradeAI: Found Dead unit, self:PlatoonDisbandNoAssign()')
                    -- needs PlatoonDisbandNoAssign, or extractors will stop upgrading if the platton is disbanded
                    WaitTicks(1)
                    self:PlatoonDisbandNoAssign()
                    return
                end
            end
        end
        -- No return here. We will never reach this position. After disbanding this platoon, the forked 'ExtractorUpgradeAI' thread will be terminated from outside.
    end,

    SimpleReturnToBase = function(self, basePosition)
        local aiBrain = self:GetBrain()
        local PlatoonPosition
        local Lastdist
        local dist
        local Stuck = 0
        self:Stop()
        self:MoveToLocation(basePosition, false)
        while aiBrain:PlatoonExists(self) do
            PlatoonPosition = self:GetPlatoonPosition()
            if not PlatoonPosition then
                --LOG('* AI-Uveso: * SimpleReturnToBase: no Platoon Position')
                break
            end
            dist = VDist2( basePosition[1], basePosition[3], PlatoonPosition[1], PlatoonPosition[3] )
            if dist < 20 then
                break
            end
            -- Do we move ?
            if Lastdist ~= dist then
                Stuck = 0
                Lastdist = dist
            -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
            else
                Stuck = Stuck + 1
                if Stuck > 20 then
                    self:Stop()
                    break
                end
            end
            WaitTicks(10)
        end
        self:PlatoonDisband()
    end,

    ForceReturnToNearestBaseAIUveso = function(self)
        local platPos = self:GetPlatoonPosition() or false
        if not platPos then
            return
        end
        local aiBrain = self:GetBrain()
        local nearestbase = false
        for k,v in aiBrain.BuilderManagers do
            -- check if we can move to this base
            if not AIUtils.ValidateLayer(v.FactoryManager.Location,self.MovementLayer) then
                --LOG('* AI-Uveso: ForceReturnToNearestBaseAIUveso Can\'t return to This base. Wrong movementlayer: '..repr(v.FactoryManager.LocationType))
                continue
            end
            local dist = VDist2( platPos[1], platPos[3], v.FactoryManager.Location[1], v.FactoryManager.Location[3] )
            if not nearestbase or nearestbase.dist > dist then
                nearestbase = {}
                nearestbase.Pos = v.FactoryManager.Location
                nearestbase.dist = dist
            end
        end
        if not nearestbase then
            return
        end
        self:Stop()
        self:MoveToLocationInclTransport(true, nearestbase.Pos, false, false, nearestbase.Pos, false)
        -- Disband the platoon so the locationmanager can assign a new task to the units.
        WaitTicks(30)
        self:PlatoonDisband()
    end,

    ForceReturnToNavalBaseAIUveso = function(self, aiBrain, basePosition)
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer or 'Water' , self:GetPlatoonPosition(), basePosition, 1000, 512)
        -- clear commands, so we don't get stuck if we have an unreachable destination
        IssueClearCommands(self:GetPlatoonUnits())
        if path then
            if table.getn(path) > 1 then
                --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: table.getn(path): '..table.getn(path))
            end
            --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: moving to destination by path.')
            for i=1, table.getn(path) do
                --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: moving to destination. i: '..i..' coords '..repr(path[i]))
                self:MoveToLocation(path[i], false)
                --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: moving to Waypoint')
                local PlatoonPosition
                local Lastdist
                local dist
                local Stuck = 0
                while aiBrain:PlatoonExists(self) do
                    PlatoonPosition = self:GetPlatoonPosition()
                    dist = VDist2( path[i][1], path[i][3], PlatoonPosition[1], PlatoonPosition[3] )
                    -- are we closer then 15 units from the next marker ? Then break and move to the next marker
                    if dist < 20 then
                        -- If we don't stop the movement here, then we have heavy traffic on this Map marker with blocking units
                        self:Stop()
                        break
                    end
                    -- Do we move ?
                    if Lastdist ~= dist then
                        Stuck = 0
                        Lastdist = dist
                    -- No, we are not moving, wait 100 ticks then break and use the next weaypoint
                    else
                        Stuck = Stuck + 1
                        if Stuck > 15 then
                            --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: Stucked while moving to Waypoint. Stuck='..Stuck..' - '..repr(path[i]))
                            self:Stop()
                            break
                        end
                    end
                    WaitTicks(10)
                end
            end
        else
            --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: we have no Graph to reach the destination. Checking CanPathTo()')
            if reason == 'NoGraph' then
                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(self, basePosition)
                if success then
                    --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: found a way with CanPathTo(). moving to destination')
                    self:MoveToLocation(basePosition, false)
                else
                    --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: CanPathTo() failed for '..repr(basePosition)..'.')
                end
            end
        end
        local oldDist = 100000
        local platPos = self:GetPlatoonPosition() or basePosition
        local Stuck = 0
        while aiBrain:PlatoonExists(self) do
            self:MoveToLocation(basePosition, false)
            --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: Waiting for moving to base')
            platPos = self:GetPlatoonPosition() or basePosition
            dist = VDist2(platPos[1], platPos[3], basePosition[1], basePosition[3])
            if dist < 20 then
                --LOG('* AI-Uveso: * ForceReturnToNavalBaseAIUveso: We are home! disband!')
                -- Wait some second, so all platoon units have time to reach the base.
                WaitSeconds(5)
                self:Stop()
                break
            end
            -- if we haven't moved in 5 seconds... leave the loop
            if oldDist - dist < 0 then
                break
            end
            oldDist = dist
            Stuck = Stuck + 1
            if Stuck > 4 then
                self:Stop()
                break
            end
            WaitSeconds(5)
        end
        -- Disband the platoon so the locationmanager can assign a new task to the units.
        WaitTicks(30)
        self:PlatoonDisband()
    end,

    U3AntiNukeAI = function(self)
        local aiBrain = self:GetBrain()
        while aiBrain:PlatoonExists(self) do
            local platoonUnits = self:GetPlatoonUnits()
            -- find dead units inside the platoon and disband if we find one
            for k,unit in platoonUnits do
                if not unit or unit.Dead or unit:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                    self:PlatoonDisbandNoAssign()
                    --LOG('* AI-Uveso: * U3AntiNukeAI: PlatoonDisband')
                    return
                else
                    unit:SetAutoMode(true)
                end
            end
            WaitTicks(50)
        end
    end,

    U34ArtilleryAI = function(self)
        local aiBrain = self:GetBrain()
        local ClosestTarget = nil
        local LastTarget = nil
        while aiBrain:PlatoonExists(self) do
            -- Primary Target
            ClosestTarget = nil
            -- We always use the PrimaryTarget from the targetmanager first:
            if aiBrain.PrimaryTarget and not aiBrain.PrimaryTarget.Dead then
                ClosestTarget = aiBrain.PrimaryTarget
            else
                -- We have no PrimaryTarget from the tagetmanager.
                -- That means there is no paragon, no experimental and no Tech3 Factories left as target.
                -- No need to search for any of this here.
            end
            -- in case we found a target, attack it until it's dead or we have another Primary Target
            if ClosestTarget == LastTarget then
                --LOG('* AI-Uveso: * U34ArtilleryAI: ClosestTarget == LastTarget')
            elseif ClosestTarget and not ClosestTarget.Dead then
                local BlueprintID = ClosestTarget:GetBlueprint().BlueprintId
                LastTarget = ClosestTarget
                -- Wait until the target is dead
                while ClosestTarget and not ClosestTarget.Dead do
                    -- leave the loop if the primary target has changed
                    if aiBrain.PrimaryTarget and aiBrain.PrimaryTarget ~= ClosestTarget then
                        break
                    end
                    platoonUnits = self:GetPlatoonUnits()
                    for _, Arty in platoonUnits do
                        if not Arty or Arty.Dead then
                            return
                        end
                        local Target = Arty:GetTargetEntity()
                        if Target == ClosestTarget then
                            --Arty:SetCustomName('continue '..BlueprintID)
                        else
                            --Arty:SetCustomName('Attacking '..BlueprintID)
                            --IssueStop({v})
                            IssueClearCommands({Arty})
                            WaitTicks(1)
                            if ClosestTarget and not ClosestTarget.Dead then
                                IssueAttack({Arty}, ClosestTarget)
                            end
                        end
                    end
                    WaitSeconds(5)
                end
            end
            -- Reaching this point means we have no special target and our arty is using it's own weapon target priorities.
            -- So we are still attacking targets at this point.
            WaitSeconds(5)
        end
    end,

    ShieldRepairAI = function(self)
        local aiBrain = self:GetBrain()
        local BuilderManager = aiBrain.BuilderManagers['MAIN']
        local lastSHIELD = 0
        local lastSUB = 0
        local numSUB
        local SUBCOMs
        local platoonUnits

        while aiBrain:PlatoonExists(self) do
            platoonUnits = self:GetPlatoonUnits()
            numSUB = table.getn(platoonUnits) or 0
            local Shields = AIUtils.GetOwnUnitsAroundPoint(aiBrain, categories.STRUCTURE * categories.SHIELD, BuilderManager.Position, 256)
            local lasthighestHealth
            local highestHealth
            local numSHIELD = 0
            -- get the shield with the highest health
            for k,Shield in Shields do
                if not Shield or Shield.Dead then continue end
                if not highestHealth or Shield.MyShield:GetMaxHealth() > highestHealth then
                    highestHealth = Shield.MyShield:GetMaxHealth()
                end
                numSHIELD = numSHIELD + 1
            end
            for k,Shield in Shields do
                if not Shield or Shield.Dead then continue end
                if (not lasthighestHealth or Shield.MyShield:GetMaxHealth() > lasthighestHealth) and Shield.MyShield:GetMaxHealth() < highestHealth then
                    lasthighestHealth = Shield.MyShield:GetMaxHealth()
                end
            end
            if numSUB ~= lastSUB or numSHIELD ~= lastSHIELD then
                self:Stop()
                -- Wait for stopping assist
                WaitTicks(1)
                lastSUB = numSUB
                lastSHIELD = numSHIELD
                for i,unit in self:GetPlatoonUnits() do
--                    IssueClearCommands({unit})
                    unit.AssistSet = nil
                    unit.UnitBeingAssist = nil
                end
                while true do
                    local numAssisters
                    local ShieldWithleastAssisters
                    -- get a shield with highest Health and lowest assistees
                    numAssisters = nil
                    -- Fist check all shields with the highest health
                    for k,Shield in Shields do
                        if not Shield or Shield.Dead or Shield.MyShield:GetMaxHealth() ~= highestHealth then continue end
                        if not numAssisters or table.getn(Shield:GetGuards()) < numAssisters  then
                            numAssisters = table.getn(Shield:GetGuards())
                            -- set a maximum of 10 assisters per shield
                            if numAssisters < 10 then
                                ShieldWithleastAssisters = Shield
                            end
                        end
                    end
                    -- If we have assister on all high shilds then spread the remaining SUBCOMs over lower shields
                    if not ShieldWithleastAssisters and lasthighestHealth and lasthighestHealth ~= highestHealth then
                        for k,Shield in Shields do
                            if not Shield or Shield.Dead or Shield.MyShield:GetMaxHealth() ~= lasthighestHealth then continue end
                            if not numAssisters or table.getn(Shield:GetGuards()) < numAssisters  then
                                numAssisters = table.getn(Shield:GetGuards())
                                ShieldWithleastAssisters = Shield
                            end
                        end
                    end
                    
                    if not ShieldWithleastAssisters then
                        --LOG('* AI-Uveso: *ShieldRepairAI: not ShieldWithleastAssisters. break!')
                        break
                    end
                    local shieldPos = ShieldWithleastAssisters:GetPosition() or nil
                    -- search for the closest idle unit
                    local closest
                    local bestUnit
                    for i,unit in self:GetPlatoonUnits() do
                        if not unit or unit.Dead or unit:BeenDestroyed() then
                            self:PlatoonDisbandNoAssign()
                            return
                        end
                        if unit.AssistSet then continue end
                        local unitPos = unit:GetPosition() or nil
                        if unitPos and shieldPos then
                            local dist = VDist2(shieldPos[1], shieldPos[3], unitPos[1], unitPos[3])
                            if not closest or dist < closest then
                                closest = dist
                                bestUnit = unit
                            end
                        end
                    end
                    if not bestUnit then
                        --LOG('* AI-Uveso: *ShieldRepairAI: not bestUnit. break!')
                        break
                    end
                    IssueClearCommands({bestUnit})
                    WaitTicks(1)
                    IssueGuard({bestUnit}, ShieldWithleastAssisters)
                    bestUnit.AssistSet = true
                    bestUnit.UnitBeingAssist = ShieldWithleastAssisters
                    WaitTicks(1)
                end

            end
            WaitTicks(30)
        end
    end,

    NukePlatoonAI = function(self)
        local NUKEDEBUG = false
        local aiBrain = self:GetBrain()
        local ECOLoopCounter = 0
        local mapSizeX, mapSizeZ = GetMapSize()
        local platoonUnits
        local LauncherFull
        local LauncherReady
        local ExperimentalLauncherReady
        local LauncherCount
        local EnemyAntiMissile
        local EnemyUnits
        local EnemyTargetPositions
        local MissileCount
        local EnemyTarget
        local NukeSiloAmmoCount
        local TargetPosition

        while aiBrain:PlatoonExists(self) do
            ---------------------------------------------------------------------------------------------------
            -- Count Launchers, set them to automode, count stored missiles
            ---------------------------------------------------------------------------------------------------
            platoonUnits = self:GetPlatoonUnits()
            LauncherFull = {}
            LauncherReady = {}
            ExperimentalLauncherReady = {}
            HighMissileCountLauncherReady = {}
            MissileCount = 0
            LauncherCount = 0
            HighestMissileCount = 0
            NukeSiloAmmoCount = 0
            WaitTicks(100)
            NukeLaunched = false
            for _, Launcher in platoonUnits do
                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    self:PlatoonDisbandNoAssign()
                    return
                end
                Launcher:SetAutoMode(true)
                IssueClearCommands({Launcher})
                NukeSiloAmmoCount = Launcher:GetNukeSiloAmmoCount() or 0
                if not HighMissileCountLauncherReady.MissileCount or HighMissileCountLauncherReady.MissileCount < NukeSiloAmmoCount then
                    HighMissileCountLauncherReady = Launcher
                    HighMissileCountLauncherReady.MissileCount = NukeSiloAmmoCount
                end
                -- check if the launcher is full:
                local bp = Launcher:GetBlueprint()
                local weapon = bp.Weapon[1]
                local MaxLoad = weapon.MaxProjectileStorage or 5
                if NUKEDEBUG then
                    LOG('* AI-Uveso: * NukePlatoonAI: launcher can load '..MaxLoad..' missiles ')
                end

                if NukeSiloAmmoCount >= MaxLoad then
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: launcher can load '..MaxLoad..' missiles and has '..NukeSiloAmmoCount..' = FULL ')
                    end
                    table.insert(LauncherFull, Launcher)
                end
                if NukeSiloAmmoCount > 0 and EntityCategoryContains(categories.NUKE * categories.EXPERIMENTAL, Launcher) then
                    table.insert(ExperimentalLauncherReady, Launcher)
                    MissileCount = MissileCount + NukeSiloAmmoCount
                elseif NukeSiloAmmoCount > 0 then
                    table.insert(LauncherReady, Launcher)
                    MissileCount = MissileCount + NukeSiloAmmoCount
                end
                LauncherCount = LauncherCount + 1
                -- count experimental launcher seraphim
            end
            EnemyAntiMissile = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * ((categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL)), Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            if NUKEDEBUG then
                LOG('* AI-Uveso: ************************************************************************************************')
                LOG('* AI-Uveso: * NukePlatoonAI: Checking for Targets. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - EnemyAntiMissile:('..table.getn(EnemyAntiMissile)..')')
            end
            -- Don't check all nuke functions if we have no missile.
            if LauncherCount < 1 or ( table.getn(LauncherReady) < 1 and table.getn(LauncherFull) < 1 ) then
                continue
            end
            ---------------------------------------------------------------------------------------------------
            -- PrimaryTarget, launch a single nuke on primary targets.
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Unprotected) Experimental PrimaryTarget ')
            end
            if 1 == 1 and aiBrain.PrimaryTarget and table.getn(LauncherReady) > 0 and EntityCategoryContains(categories.EXPERIMENTAL, aiBrain.PrimaryTarget) then
                -- Only shoot if the target is not protected by antimissile or experimental shields
                if not self:IsTargetNukeProtected(aiBrain.PrimaryTarget, EnemyAntiMissile) then
                    -- Lead target function
                    TargetPos = self:LeadNukeTarget(aiBrain.PrimaryTarget)
                    if not TargetPos then
                        -- Our Target is dead. break
                        break
                    end
                    -- Only shoot if we are not damaging our own structures
                    if aiBrain:GetNumUnitsAroundPoint(categories.STRUCTURE, TargetPos, 50 , 'Ally') <= 0 then
                        if not self:NukeSingleAttack(HighMissileCountLauncherReady, TargetPos) then
                            if self:NukeSingleAttack(LauncherReady, TargetPos) then
                                if NUKEDEBUG then
                                    LOG('* AI-Uveso: * NukePlatoonAI: (Unprotected) Experimental PrimaryTarget FIRE LauncherReady!')
                                end
                                NukeLaunched = true
                            end
                        else
                            if NUKEDEBUG then
                                LOG('* AI-Uveso: * NukePlatoonAI: (Unprotected) Experimental PrimaryTarget FIRE HighMissileCountLauncherReady!')
                            end
                            NukeLaunched = true
                        end
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- first try to target all targets that are not protected from enemy anti missile
            ---------------------------------------------------------------------------------------------------
            EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE - categories.MASSEXTRACTION - categories.TECH1 - categories.TECH2 , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
            EnemyTargetPositions = {}
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Unprotected) EnemyUnits. Checking enemy units: '..table.getn(EnemyUnits))
            end
            for _, EnemyTarget in EnemyUnits do
                -- get position of the possible next target
                local EnemyTargetPos = EnemyTarget:GetPosition() or nil
                if not EnemyTargetPos then continue end
                local ToClose = false
                -- loop over all already attacked targets
                for _, ETargetPosition in EnemyTargetPositions do
                    -- Check if the target is closeer then 40 to an already attacked target
                    if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                        ToClose = true
                        break -- break out of the EnemyTargetPositions loop
                    end
                end
                if ToClose then
                    continue -- Skip this enemytarget and check the next
                end
                -- Check if the target is not protected by an antinuke
                if not self:IsTargetNukeProtected(EnemyTarget, EnemyAntiMissile) then
                    table.insert(EnemyTargetPositions, EnemyTargetPos)
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have unprotected targets, shot at it
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Unprotected) EnemyUnits: Unprotected enemy units: '..table.getn(EnemyTargetPositions))
            end
            if 1 == 1 and table.getn(EnemyTargetPositions) > 0 and table.getn(LauncherReady) > 0 then
                -- loopß over all targets
                self:NukeJerichoAttack(LauncherReady, EnemyTargetPositions, false)
                NukeLaunched = true
            end
            ---------------------------------------------------------------------------------------------------
            -- Try to overwhelm anti nuke, search for targets
            ---------------------------------------------------------------------------------------------------
            EnemyProtectorsNum = 0
            TargetPosition = false
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Check for MissileCount > 8  [ '..MissileCount..' > 8 ]')
            end
            if 1 == 1 and MissileCount > 8 and table.getn(EnemyAntiMissile) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) MissileCount, EnemyAntiMissile  [ '..MissileCount..', '..table.getn(EnemyAntiMissile)..' ]')
                end
                local AntiMissileRanger = {}
                -- get a list with all antinukes and distance to each other
                for MissileIndex, AntiMissileSTART in EnemyAntiMissile do
                    AntiMissileRanger[MissileIndex] = 0
                    -- get the location of AntiMissile
                    local AntiMissilePosSTART = AntiMissileSTART:GetPosition() or nil
                    if not AntiMissilePosSTART then break end
                    for _, AntiMissileEND in EnemyAntiMissile do
                        local AntiMissilePosEND = AntiMissileSTART:GetPosition() or nil
                        if not AntiMissilePosEND then continue end
                        local dist = VDist2(AntiMissilePosSTART[1],AntiMissilePosSTART[3],AntiMissilePosEND[1],AntiMissilePosEND[3])
                        AntiMissileRanger[MissileIndex] = AntiMissileRanger[MissileIndex] + dist
                    end
                end
                -- find the least protected anti missile
                local HighestDistance = 0
                local HighIndex = false
                for MissileIndex, MissileRange in AntiMissileRanger do
                    if MissileRange > HighestDistance then
                        HighestDistance = MissileRange
                        HighIndex = MissileIndex
                    end
                end
                if HighIndex and EnemyAntiMissile[HighIndex] and not EnemyAntiMissile[HighIndex].Dead then
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Antimissile with highest distance to other antimissiles has HighIndex = '..HighIndex)
                    end
                    -- kill the launcher will all missiles we have
                    EnemyTarget = EnemyAntiMissile[HighIndex]
                    TargetPosition = EnemyTarget:GetPosition() or false
                elseif EnemyAntiMissile[1] and not EnemyAntiMissile[1].Dead then
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Targetting Antimissile[1]')
                    end
                    EnemyTarget = EnemyAntiMissile[1]
                    TargetPosition = EnemyTarget:GetPosition() or false
                end
                -- Scan how many antinukes are protecting the least defended target:
                local ProtectorUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * ((categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3) + (categories.SHIELD * categories.EXPERIMENTAL)), TargetPosition, 90, 'Enemy')
                if ProtectorUnits then
                    EnemyProtectorsNum = table.getn(ProtectorUnits)
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Try to overwhelm anti nuke, search for targets
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) missiles > antimissiles  [ '..MissileCount..' > '..(EnemyProtectorsNum * 8)..' ]')
            end
            if 1 == 1 and EnemyTarget and TargetPosition and EnemyProtectorsNum > 0 and MissileCount > EnemyProtectorsNum * 8 then
                -- Fire as long as the target exists
                if NUKEDEBUG then
                    LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) while EnemyTarget do ')
                end
                while EnemyTarget and not EnemyTarget.Dead do
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Loop!')
                    end
                    local missile = false
                    for k, Launcher in platoonUnits do
                        if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                            -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                            -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                            self:PlatoonDisbandNoAssign()
                            return
                        end
                        if NUKEDEBUG then
                            LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Fireing Nuke: '..repr(k))
                        end
                        if Launcher:GetNukeSiloAmmoCount() > 0 then
                            if Launcher:GetNukeSiloAmmoCount() > 1 then
                                missile = true
                            end
                            IssueNuke({Launcher}, TargetPosition)
                            table.remove(LauncherReady, k)
                            MissileCount = MissileCount - 1
                            NukeLaunched = true
                        end
                        if not EnemyTarget or EnemyTarget.Dead then
                            if NUKEDEBUG then
                                LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Target is dead. break fire loop')
                            end
                            break -- break the "for Index, Launcher in platoonUnits do" loop
                        end
                    end
                    if not missile then
                        if NUKEDEBUG then
                            LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Nukes are empty')
                        end
                        break -- break the "while EnemyTarget do" loop
                    end
                    if NukeLaunched then
                        if NUKEDEBUG then
                            LOG('* AI-Uveso: * NukePlatoonAI: (Overwhelm) Nukes launched')
                        end
                        break -- break the "while EnemyTarget do" loop
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Jericho! Check if we can attack all targets at the same time
            ---------------------------------------------------------------------------------------------------
            EnemyTargetPositions = {}
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Jericho) Searching for EnemyTargetPositions')
            end
            for _, EnemyTarget in EnemyUnits do
                -- get position of the possible next target
                local EnemyTargetPos = EnemyTarget:GetPosition() or nil
                if not EnemyTargetPos then continue end
                local ToClose = false
                -- loop over all already attacked targets
                for _, ETargetPosition in EnemyTargetPositions do
                    -- Check if the target is closer then 40 to an already attacked target
                    if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                        ToClose = true
                        break -- break out of the EnemyTargetPositions loop
                    end
                end
                if ToClose then
                    continue -- Skip this enemytarget and check the next
                end
                table.insert(EnemyTargetPositions, EnemyTargetPos)
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have more launchers ready then targets start Jericho bombardment
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Jericho) Checking for Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - Enemy Targets:('..table.getn(EnemyTargetPositions)..')')
            end
            if 1 == 1 and table.getn(LauncherReady) >= table.getn(EnemyTargetPositions) and table.getn(EnemyTargetPositions) > 0 and table.getn(LauncherFull) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Uveso: * NukePlatoonAI: Jericho!')
                end
                -- loopß over all targets
                self:NukeJerichoAttack(LauncherReady, EnemyTargetPositions, false)
                NukeLaunched = true
            end
            ---------------------------------------------------------------------------------------------------
            -- If we have an launcher with 5 missiles fire one.
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) Checking for Full Launchers. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..')')
            end
            if 1 == 1 and table.getn(LauncherFull) > 0 then
                if NUKEDEBUG then
                    LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) - Launcher is full!')
                end
                EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.EXPERIMENTAL, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                if table.getn(EnemyUnits) > 0 then
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) Enemy Experimental Buildings: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * categories.TECH3 , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) Enemy TECH3 Buildings: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.MOBILE * categories.EXPERIMENTAL - categories.AIR, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) Enemy Experimental Units: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE , Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) Enemy Buildings: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) <= 0 then
                    EnemyUnits = aiBrain:GetUnitsAroundPoint(categories.MOBILE - categories.AIR, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) Enemy Mobile Units: ('..table.getn(EnemyUnits)..')')
                    end
                end
                if table.getn(EnemyUnits) > 0 then
                    if NUKEDEBUG then
                        LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) MissileCount ('..MissileCount..') > EnemyUnits ('..table.getn(EnemyUnits)..')')
                    end
                    EnemyTargetPositions = {}
                    -- get enemy target positions
                    for _, EnemyTarget in EnemyUnits do
                        -- get position of the possible next target
                        local EnemyTargetPos = EnemyTarget:GetPosition() or nil
                        if not EnemyTargetPos then continue end
                        local ToClose = false
                        -- loop over all already attacked targets
                        for _, ETargetPosition in EnemyTargetPositions do
                            -- Check if the target is closeer then 40 to an already attacked target
                            if VDist2(EnemyTargetPos[1],EnemyTargetPos[3],ETargetPosition[1],ETargetPosition[3]) < 40 then
                                ToClose = true
                                break -- break out of the EnemyTargetPositions loop
                            end
                        end
                        if ToClose then
                            continue -- Skip this enemytarget and check the next
                        end
                        table.insert(EnemyTargetPositions, EnemyTargetPos)
                    end
                end
            end
            ---------------------------------------------------------------------------------------------------
            -- Now, if we have targets, shot at it
            ---------------------------------------------------------------------------------------------------
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: (Launcher Full) Attack only with full Launchers. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:('..table.getn(LauncherFull)..') - Missiles:('..MissileCount..') - Enemy Targets:('..table.getn(EnemyTargetPositions)..')')
            end
            if 1 == 1 and table.getn(EnemyTargetPositions) > 0 and table.getn(LauncherFull) > 0 then
                self:NukeJerichoAttack(LauncherFull, EnemyTargetPositions, true)
                NukeLaunched = true
            end
            if NUKEDEBUG then
                LOG('* AI-Uveso: * NukePlatoonAI: END. Launcher:('..LauncherCount..') Ready:('..table.getn(LauncherReady)..') Full:'..table.getn(LauncherFull)..' - Missiles:('..MissileCount..')')
            end
            if NukeLaunched == true then
                --LOG('* AI-Uveso: Fired nuke(s), waiting...')
                WaitTicks(450)-- wait 45 seconds for the missile flight, then get new targets
            end
        end -- while aiBrain:PlatoonExists(self) do
    end,
    
    LeadNukeTarget = function(self, target)
        local TargetPos
        -- Get target position in 1 second intervals.
        -- This allows us to get speed and direction from the target
        local TargetStartPosition=0
        local Target1SecPos=0
        local Target2SecPos=0
        local XmovePerSec=0
        local YmovePerSec=0
        local XmovePerSecCheck=-1
        local YmovePerSecCheck=-1
        -- Check if the target is runing straight or circling
        -- If x/y and xcheck/ycheck are equal, we can be sure the target is moving straight
        -- in one direction. At least for the last 2 seconds.
        local LoopSaveGuard = 0
        while target and not target.Dead and (XmovePerSec ~= XmovePerSecCheck or YmovePerSec ~= YmovePerSecCheck) and LoopSaveGuard < 10 do
            if not target or target.Dead then return false end
            -- 1st position of target
            TargetPos = target:GetPosition()
            TargetStartPosition = {TargetPos[1], 0, TargetPos[3]}
            WaitTicks(10)
            -- 2nd position of target after 1 second
            TargetPos = target:GetPosition()
            Target1SecPos = {TargetPos[1], 0, TargetPos[3]}
            XmovePerSec = (TargetStartPosition[1] - Target1SecPos[1])
            YmovePerSec = (TargetStartPosition[3] - Target1SecPos[3])
            WaitTicks(10)
            -- 3rd position of target after 2 seconds to verify straight movement
            TargetPos = target:GetPosition()
            Target2SecPos = {TargetPos[1], TargetPos[2], TargetPos[3]}
            XmovePerSecCheck = (Target1SecPos[1] - Target2SecPos[1])
            YmovePerSecCheck = (Target1SecPos[3] - Target2SecPos[3])
            --We leave the while-do check after 10 loops (20 seconds) and try collateral damage
            --This can happen if a player try to fool the targetingsystem by circling a unit.
            LoopSaveGuard = LoopSaveGuard + 1
        end
        if not target or target.Dead then return false end
        local MissileImpactTime = 25
        -- Create missile impact corrdinates based on movePerSec * MissileImpactTime
        local MissileImpactX = Target2SecPos[1] - (XmovePerSec * MissileImpactTime)
        local MissileImpactY = Target2SecPos[3] - (YmovePerSec * MissileImpactTime)
        return {MissileImpactX, Target2SecPos[2], MissileImpactY}
    end,

    NukeSingleAttack = function(self, Launchers, EnemyTargetPosition)
        --LOG('* AI-Uveso: ** NukeSingleAttack: Launcher count: '..table.getn(Launchers))
        if table.getn(Launchers) <= 0 then
            --LOG('* AI-Uveso: ** NukeSingleAttack: No Launcher ready.')
            return false
        end
        -- loop over all nuke launcher
        for k, Launcher in Launchers do
            if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                --LOG('* AI-Uveso: ** NukeSingleAttack: Found destroyed launcher inside platoon. Disbanding...')
                self:PlatoonDisbandNoAssign()
                return
            end
            -- check if the target is closer then 20000
            LauncherPos = Launcher:GetPosition() or nil
            if not LauncherPos then
                --LOG('* AI-Uveso: ** NukeSingleAttack: no Launcher Pos. Skiped')
                continue
            end
            if not EnemyTargetPosition then
                --LOG('* AI-Uveso: ** NukeSingleAttack: no Target Pos. Skiped')
                continue
            end
            if VDist2(LauncherPos[1],LauncherPos[3],EnemyTargetPosition[1],EnemyTargetPosition[3]) > 20000 then
                --LOG('* AI-Uveso: ** NukeSingleAttack: Target out of range. Skiped')
                -- Target is out of range, skip this launcher
                continue
            end
            -- Attack the target
            --LOG('* AI-Uveso: ** NukeSingleAttack: Attacking Enemy Position!')
            IssueNuke({Launcher}, EnemyTargetPosition)
            -- stop seraching for available launchers and check the next target
            return true
        end
    end,

    NukeJerichoAttack = function(self, Launchers, EnemyTargetPositions, LaunchAll)
        --LOG('* AI-Uveso: * NukeJerichoAttack: Launcher: '..table.getn(Launchers))
        if table.getn(Launchers) <= 0 then
            --LOG('* AI-Uveso: * NukeSingleAttack: Launcher empty')
            return false
        end
        for _, ActualTargetPos in EnemyTargetPositions do
            -- loop over all nuke launcher
            for k, Launcher in Launchers do
                if not Launcher or Launcher.Dead or Launcher:BeenDestroyed() then
                    -- We found a dead unit inside this platoon. Disband the platton; It will be reformed
                    -- needs PlatoonDisbandNoAssign, or launcher will stop building nukes if the platton is disbanded
                    --LOG('* AI-Uveso: * NukeJerichoAttack: Found destroyed launcher inside platoon. Disbanding...')
                    self:PlatoonDisbandNoAssign()
                    return
                end
                -- check if the target is closer then 20000
                LauncherPos = Launcher:GetPosition() or nil
                if not LauncherPos then
                    --LOG('* AI-Uveso: * NukeJerichoAttack: no Launcher Pos. Skiped')
                    continue
                end
                if not ActualTargetPos then
                    --LOG('* AI-Uveso: * NukeJerichoAttack: no Target Pos. Skiped')
                    continue
                end
                if VDist2(LauncherPos[1],LauncherPos[3],ActualTargetPos[1],ActualTargetPos[3]) > 20000 then
                    --LOG('* AI-Uveso: * NukeJerichoAttack: Target out of range. Skiped')
                    -- Target is out of range, skip this launcher
                    continue
                end
                -- Attack the target
                --LOG('* AI-Uveso: * NukeJerichoAttack: Attacking Enemy Position!')
                IssueNuke({Launcher}, ActualTargetPos)
                -- remove the launcher from the table, so it can't be used for the next target
                table.remove(Launchers, k)
                -- stop seraching for available launchers and check the next target
                break -- for k, Launcher in Launcher do
            end
            --LOG('* AI-Uveso: * NukeJerichoAttack: Launcher after shoot: '..table.getn(Launchers))
            if table.getn(Launchers) < 1 then
                --LOG('* AI-Uveso: * NukeJerichoAttack: All Launchers are bussy! Break!')
                -- stop seraching for targets, we don't hava a launcher ready.
                break -- for _, ActualTargetPos in EnemyTargetPositions do
            end
        end
        if table.getn(Launchers) > 0 and LaunchAll == true then
            self:NukeJerichoAttack(Launchers, EnemyTargetPositions, true)
        end
    end,

    IsTargetNukeProtected = function(self, Target, EnemyAntiMissile)
        TargetPos = Target:GetPosition() or nil
        if not TargetPos then
            -- we don't have a target position, so we return ture like we have a protected target.
            return true
        end
        for _, AntiMissile in EnemyAntiMissile do
            if not AntiMissile or AntiMissile.Dead or AntiMissile:BeenDestroyed() then continue end
            -- if the launcher is still in build, don't count it.
            local FractionComplete = AntiMissile:GetFractionComplete() or nil
            if not FractionComplete then continue end
            if FractionComplete < 1 then
                --LOG('* AI-Uveso: * IsTargetNukeProtected: Target TAntiMissile:GetFractionComplete() < 1')
                continue
            end
            -- get the location of AntiMissile
            local AntiMissilePos = AntiMissile:GetPosition() or nil
            if not AntiMissilePos then
               --LOG('* AI-Uveso: * IsTargetNukeProtected: Target AntiMissilePos NIL')
                continue 
            end
            -- Check if our target is inside range of an antimissile
            if VDist2(TargetPos[1],TargetPos[3],AntiMissilePos[1],AntiMissilePos[3]) < 90 then
                --LOG('* AI-Uveso: * IsTargetNukeProtected: Target in range of Nuke Anti Missile. Skiped')
                return true
            end
        end
        return false
    end,

    SACUTeleportAI = function(self)
        --LOG('* AI-Uveso: * SACUTeleportAI: Start ')
        -- SACU need to move out of the gate first
        WaitTicks(50)
        local aiBrain = self:GetBrain()
        local platoonUnits
        local platoonPosition = self:GetPlatoonPosition()
        local TargetPosition
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        -- start upgrading all SubCommanders as teleporter
        while aiBrain:PlatoonExists(self) do
            local allEnhanced = true
            platoonUnits = self:GetPlatoonUnits()
            for k, unit in platoonUnits do
                IssueStop({unit})
                IssueClearCommands({unit})
                WaitTicks(1)
                if not unit.Dead then
                    for k, Assister in platoonUnits do
                        if not Assister.Dead and Assister ~= unit then
                            -- only assist if we have the energy for it
                            if aiBrain:GetEconomyTrend('ENERGY')*10 > 5000 or aiBrain.HasParagon then
                                --LOG('* AI-Uveso: * SACUTeleportAI: IssueGuard({Assister}, unit) ')
                                IssueGuard({Assister}, unit)
                            end
                        end
                    end
                    self:BuildSACUEnhancements(unit)
                    WaitTicks(1)
                    if not unit:HasEnhancement('Teleporter') then
                        --LOG('* AI-Uveso: * SACUTeleportAI: Not teleporter enhanced')
                        allEnhanced = false
                    else
                        --LOG('* AI-Uveso: * SACUTeleportAI: Has teleporter installed')
                    end
                end
            end
            if allEnhanced == true then
                --LOG('* AI-Uveso: * SACUTeleportAI: allEnhanced == true ')
                break
            end
            WaitTicks(50)
        end
        --
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Uveso: * SACUTeleportAI: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        local maxRadius = self.PlatoonData.SearchRadius or 100
        -- search for a target
        local Target
        while not Target do
            WaitTicks(50)
            Target, _, _, _ = AIUtils.AIFindNearestCategoryTeleportLocation(aiBrain, platoonPosition, maxRadius, MoveToCategories, TargetSearchCategory, false)
        end
        platoonUnits = self:GetPlatoonUnits()
        if Target and not Target.Dead then
            TargetPosition = Target:GetPosition()
            for k, unit in platoonUnits do
                if not unit.Dead then
                    if not unit:HasEnhancement('Teleporter') then
                        --WARN('* AI-Uveso: * SACUTeleportAI: Unit has no transport enhancement!')
                        continue
                    end
                    --IssueStop({unit})
                    WaitTicks(2)
                    IssueTeleport({unit}, UUtils.RandomizePosition(TargetPosition))
                end
            end
        else
            --LOG('* AI-Uveso: SACUTeleportAI: No target, disbanding platoon!')
            self:PlatoonDisband()
            return
        end
        WaitTicks(30)
        -- wait for the teleport of all unit
        local count = 0
        local UnitTeleporting = 0
        while aiBrain:PlatoonExists(self) do
            platoonUnits = self:GetPlatoonUnits()
            UnitTeleporting = 0
            for k, unit in platoonUnits do
                if not unit.Dead then
                    if unit:IsUnitState('Teleporting') then
                        UnitTeleporting = UnitTeleporting + 1
                    end
                end
            end
            --LOG('* AI-Uveso: SACUTeleportAI: Units Teleporting :'..UnitTeleporting )
            if UnitTeleporting == 0 then
                break
            end
            WaitTicks(10)
        end        
        -- Fight
        WaitTicks(1)
        for k, unit in platoonUnits do
            if not unit.Dead then
                IssueStop({unit})
                WaitTicks(2)
                IssueMove({unit}, TargetPosition)
            end
        end
        WaitTicks(50)
        self:LandAttackAIUveso()
        self:PlatoonDisband()
    end,

    BuildSACUEnhancements = function(platoon,unit)
        local EnhancementsByUnitID = {
            -- UEF
            ['uel0301'] = {'xxx', 'xxx', 'xxx'},
            -- Aeon
            ['ual0301'] = {'StabilitySuppressant', 'Teleporter'},
            -- Cybram
            ['url0301'] = {'xxx', 'xxx', 'xxx'},
            -- Seraphim
            ['xsl0301'] = {'DamageStabilization', 'Shield', 'Teleporter'},
            -- Nomads
            ['xnl0301'] = {'xxx', 'xxx', 'xxx'},
        }
        local CRDBlueprint = unit:GetBlueprint()
        --LOG('* AI-Uveso: BlueprintId RAW:'..repr(CRDBlueprint.BlueprintId))
        --LOG('* AI-Uveso: BlueprintId clean: '..repr(string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")))
        local ACUUpgradeList = EnhancementsByUnitID[string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")]
        --LOG('* AI-Uveso: ACUUpgradeList '..repr(ACUUpgradeList))
        local NextEnhancement = false
        local HaveEcoForEnhancement = false
        for _,enhancement in ACUUpgradeList or {} do
            local wantedEnhancementBP = CRDBlueprint.Enhancements[enhancement]
            --LOG('* AI-Uveso: wantedEnhancementBP '..repr(wantedEnhancementBP))
            if not wantedEnhancementBP then
                SPEW('* AI-Uveso: BuildSACUEnhancements: no enhancement found for ('..string.gsub(CRDBlueprint.BlueprintId, "(%a+)(%d+)_(%a+)", "%1".."%2")..') = '..repr(enhancement))
            elseif unit:HasEnhancement(enhancement) then
                NextEnhancement = false
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements: Enhancement is already installed: '..enhancement)
            elseif platoon:EcoGoodForUpgrade(unit, wantedEnhancementBP) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements: Eco is good for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = true
                    --LOG('* AI-Uveso: * ACUAttackAIUveso: *** Set as Enhancememnt: '..NextEnhancement)
                end
            else
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements: Eco is bad for '..enhancement)
                if not NextEnhancement then
                    NextEnhancement = enhancement
                    HaveEcoForEnhancement = false
                    -- if we don't have the eco for this ugrade, stop the search
                    --LOG('* AI-Uveso: * ACUAttackAIUveso: canceled search. no eco available')
                end
            end
        end
        if NextEnhancement and HaveEcoForEnhancement then
            --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements Building '..NextEnhancement)
            if platoon:BuildEnhancement(unit, NextEnhancement) then
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements returned true'..NextEnhancement)
            else
                --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements returned false'..NextEnhancement)
            end
            return
        end
        --LOG('* AI-Uveso: * ACUAttackAIUveso: BuildSACUEnhancements returned false')
        return
    end,

    RenamePlatoon = function(self, text)
        for k, v in self:GetPlatoonUnits() do
            if v and not v.Dead then
                v:SetCustomName(text..' '..math.floor(GetGameTimeSeconds()))
            end
        end
    end,

    AirSuicideAI = function(self)
        --LOG('* AI-Uveso: *AirSuicideAI: START')
        AIAttackUtils.GetMostRestrictiveLayer(self) -- this will set self.MovementLayer to the platoon
        local aiBrain = self:GetBrain()
        -- Search all platoon units and activate Stealth and Cloak (mostly Modded units)
        local platoonUnits = self:GetPlatoonUnits()
        local PlatoonStrength = table.getn(platoonUnits)
        if platoonUnits and PlatoonStrength > 0 then
            for k, v in platoonUnits do
                if not v.Dead then
                    if v:TestToggleCaps('RULEUTC_StealthToggle') then
                        --LOG('* AI-Uveso: * AirSuicideAI: Switching RULEUTC_StealthToggle')
                        v:SetScriptBit('RULEUTC_StealthToggle', false)
                    end
                    if v:TestToggleCaps('RULEUTC_CloakToggle') then
                        --LOG('* AI-Uveso: * AirSuicideAI: Switching RULEUTC_CloakToggle')
                        v:SetScriptBit('RULEUTC_CloakToggle', false)
                    end
                    -- prevent units from reclaiming while attack moving
                    v:RemoveCommandCap('RULEUCC_Reclaim')
                    v:RemoveCommandCap('RULEUCC_Repair')
                end
            end
        end
        local MoveToCategories = {}
        if self.PlatoonData.MoveToCategories then
            for k,v in self.PlatoonData.MoveToCategories do
                table.insert(MoveToCategories, v )
            end
        else
            LOG('* AI-Uveso: * AirSuicideAI: MoveToCategories missing in platoon '..self.BuilderName)
        end
        local WeaponTargetCategories = {}
        if self.PlatoonData.WeaponTargetCategories then
            for k,v in self.PlatoonData.WeaponTargetCategories do
                table.insert(WeaponTargetCategories, v )
            end
        elseif self.PlatoonData.MoveToCategories then
            WeaponTargetCategories = MoveToCategories
        end
        self:SetPrioritizedTargetList('Attack', WeaponTargetCategories)
        local target
        local bAggroMove = self.PlatoonData.AggressiveMove
        local path
        local reason
        local maxRadius = self.PlatoonData.SearchRadius or 100
        local PlatoonPos = self:GetPlatoonPosition()
        local LastTargetPos = PlatoonPos
        local basePosition
        if self.MovementLayer == 'Water' then
            -- we could search for the nearest naval base here, but buildposition is almost at the same location
            basePosition = PlatoonPos
        else
            -- land and air units are assigned to mainbase
            basePosition = aiBrain.BuilderManagers['MAIN'].Position
        end
        local GetTargetsFromBase = self.PlatoonData.GetTargetsFromBase
        local GetTargetsFrom = basePosition
        local LastTargetCheck
        local DistanceToBase = 0
        local TargetSearchCategory = self.PlatoonData.TargetSearchCategory or 'ALLUNITS'
        while aiBrain:PlatoonExists(self) do
            PlatoonPos = self:GetPlatoonPosition()
            if not GetTargetsFromBase then
                GetTargetsFrom = PlatoonPos
            else
                DistanceToBase = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0)
                if DistanceToBase > maxRadius then
                    target = nil
                end
            end
            -- only get a new target and make a move command if the target is dead
            if not target or target.Dead or target:BeenDestroyed() then
                UnitWithPath, UnitNoPath, path, reason = AIUtils.AIFindNearestCategoryTargetInRange(aiBrain, self, 'Attack', GetTargetsFrom, maxRadius, MoveToCategories, TargetSearchCategory, false )
                if UnitWithPath then
                    --LOG('* AI-Uveso: *AirSuicideAI: found UnitWithPath')
                    self:Stop()
                    target = UnitWithPath
                    LastTargetPos = target:GetPosition()
                    if LastTargetPos then
                        self:MoveToLocation(LastTargetPos, false)
                        self.AirSuicideTargetPos = LastTargetPos
                    end
                elseif UnitNoPath then
                    --LOG('* AI-Uveso: *AirSuicideAI: found UnitNoPath')
                    self:Stop()
                    target = UnitNoPath
                    LastTargetPos = target:GetPosition()
                    if LastTargetPos then
                        self:MoveToLocation(LastTargetPos, false)
                        self.AirSuicideTargetPos = LastTargetPos
                    end
                else
                    --LOG('* AI-Uveso: *AirSuicideAI: no target found '..repr(reason))
                    -- we have no target return to main base
                    self:Stop()
                    if self.MovementLayer == 'Air' then
                        if VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, basePosition[1] or 0, basePosition[3] or 0) > 30 then
                            --LOG('* AI-Uveso: *AirSuicideAI: moving to base ')
                            self:MoveToLocation(basePosition, false)
                        else
                            -- we are at home and we don't have a target. Disband!
                            if aiBrain:PlatoonExists(self) then
                                --LOG('* AI-Uveso: *AirSuicideAI: Disbanding platoon')
                                self:PlatoonDisband()
                                return
                            end
                        end
                    else
                        self:SimpleReturnToBase(basePosition)
                    end
                end
            -- targed exists and is not dead
            end
            WaitTicks(1)
            -- forece all units inside the platoon to move to the target
            for k, v in platoonUnits do
                if self.AirSuicideTargetPos then
                    IssueMove({v}, self.AirSuicideTargetPos)
                end
            end

            local LastPlatoonPos = false
            local CrashFlightDistance
            while aiBrain:PlatoonExists(self) and self.AirSuicideTargetPos do
                PlatoonPos = self:GetPlatoonPosition()
                CrashFlightDistance = VDist2(PlatoonPos[1] or 0, PlatoonPos[3] or 0, self.AirSuicideTargetPos[1] or 0, self.AirSuicideTargetPos[3] or 0)
                if CrashFlightDistance <= 100 then
                    local FlightElevation
                    local unitpos
                    while aiBrain:PlatoonExists(self) do
                        for k, v in platoonUnits do
                            unitpos = v:GetPosition()
                            if v.FlightElevation then
                                FlightElevation = v.FlightElevation
                            else
                                FlightElevation = v:GetBlueprint().Physics.Elevation
                                v.FlightElevation = FlightElevation
                            end
                            CrashFlightDistance = VDist2(unitpos[1] or 0, unitpos[3] or 0, self.AirSuicideTargetPos[1] or 0, self.AirSuicideTargetPos[3] or 0)
                            --LOG('* AI-Uveso: *AirSuicideAI: CrashFlightDistance: '..CrashFlightDistance)
                            if CrashFlightDistance/5 <= FlightElevation then
                                v:SetElevation(CrashFlightDistance/5)
                                if CrashFlightDistance < 2 then
                                    v:Kill()
                                end
                            end
                        end
                        WaitTicks(1)
                    end

                end
                WaitTicks(1)
            end
        end
    end,

    BuildOnMassAI = function(self)
        local aiBrain = self:GetBrain()
        local engineer = self:GetPlatoonUnits()[1]
        if not engineer or engineer.Dead or engineer:BeenDestroyed() then
            LOG('* AI-Uveso: BuildOnMassAI: Platoon failed to form')
            return
        end
        -- block AssignEngineerTask from using this engineer
        engineer.UnitBeingAssist = true
        -- block ProcessBuildCommand() from using this engineer
        engineer.AssistSet = true
        engineer.UnitBeingBuiltBehavior = true
        -- block the uveso-ecomanager from pausing this unit
        engineer.noPause = true
        -- get the faction index from the actual brain
        local factionIndex = aiBrain:GetFactionIndex()
        -- get the faction from the engineer in case we have an engineer from a different faction captured
        local FactionToIndex  = { UEF = 1, AEON = 2, CYBRAN = 3, SERAPHIM = 4, NOMADS = 5}
        local EngineerFactionIndex = FactionToIndex[engineer.factionCategory] or factionIndex
        -- get the unit id from T1Resource building from the engineer faction
        local buildingTmpl = import('/lua/BuildingTemplates.lua')['BuildingTemplates'][factionIndex]
        local T1ResourceUnitID
        for Key, Data in buildingTmpl do
            if Data[1] and Data[2] and Data[1] == 'T1Resource' then
                T1ResourceUnitID = Data[2]
                break
            end
        end
        if not T1ResourceUnitID then
            WARN('* AI-Uveso: BuildOnMassAI: can\'t find massextractor unitID for faction '..repr(engineer.factionCategory)..' ')
            return
        end
        --LOG('* AI-Uveso: BuildOnMassAI: EngineerFactionIndex '..EngineerFactionIndex..' can build unitID '..T1ResourceUnitID)
        --get the basetemplate file
        local baseTmplFile = import('/lua/BaseTemplates.lua')
        local baseTmpl = baseTmplFile['BaseTemplates'][factionIndex]

        -- loop as long as the engineer is alive
        while aiBrain:PlatoonExists(self) and not engineer.Dead do
            -- The engineer is the first unit iside this platoon
            engineer = self:GetPlatoonUnits()[1]
            -- if we get a target then build there
            if engineer.MexToCap then
                
                -- Move to the target
                if AIUtils.EngineerMoveWithSafePath(aiBrain, engineer, engineer.MexToCap.Position) then

                    if AIUtils.EngineerTryReclaimCaptureArea(aiBrain, engineer, engineer.MexToCap.Position) then
                        WaitTicks(3)
                        while  not engineer.Dead and (engineer:IsUnitState('Building') or not engineer:IsIdleState()) do
                            WaitTicks(5)
                        end
                    end

                    --LOG('* AI-Uveso: BuildOnMassAI: Want to build MexToCap at Position: '..repr(engineer.MexToCap.Position))

                    if aiBrain:CanBuildStructureAt(T1ResourceUnitID, engineer.MexToCap.Position) then
                        --LOG('* AI-Uveso: BuildOnMassAI: MexToCap CanBuildStructureAt '..repr(engineer.MexToCap.Position))
                        IssueStop({engineer})
                        IssueClearCommands({engineer})
                        aiBrain:BuildStructure(engineer, T1ResourceUnitID, {engineer.MexToCap.Position[1], engineer.MexToCap.Position[3], 0} , false)
                    end

                    WaitTicks(5)

                    if not engineer:IsUnitState('Building') and engineer:IsIdleState() then
                        --LOG('* AI-Uveso: BuildOnMassAI: Build failed, searching for an alternative building place ')
                        local location = aiBrain:FindPlaceToBuild('T1Resource', T1ResourceUnitID, baseTmpl, false, nil, 'Enemy', engineer.MexToCap.Position[1], engineer.MexToCap.Position[3], 5)
                        --LOG('* AI-Uveso: BuildOnMassAI: FindPlaceToBuild Position: '..repr(location))
                        aiBrain:BuildStructure(engineer, T1ResourceUnitID, {location[1], location[3], 0} , false)
                     end

                    WaitTicks(5)

                    while not engineer.Dead and (engineer:IsUnitState('Building') or not engineer:IsIdleState()) do
                        WaitTicks(5)
                    end
                end
                engineer.MexToCap = nil
            end
            WaitTicks(1)
        end
    end,

    TacticalAISwarm = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local platoonUnits = self:GetPlatoonUnits()
        local unit

        if not aiBrain:PlatoonExists(self) then return end

        --GET THE Launcher OUT OF THIS PLATOON
        for k, v in platoonUnits do
            if EntityCategoryContains(categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM, v) then
                unit = v
                break
            end
        end

        if not unit then return end

        local bp = unit:GetBlueprint()
        local weapon = bp.Weapon[1]
        local maxRadius = weapon.MaxRadius
        local minRadius = weapon.MinRadius
        unit:SetAutoMode(true)

        --DUNCAN - commented out
        --local atkPri = { 'COMMAND', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE', 'CONSTRUCTION', 'EXPERIMENTAL MOBILE LAND', 'TECH3 MOBILE LAND',
        --    'TECH2 MOBILE LAND', 'TECH1 MOBILE LAND', 'ALLUNITS' }

        --DUNCAN - added energy production, removed construction, repriotised.
        self:SetPrioritizedTargetList('Attack', {
            categories.COMMAND,
            categories.EXPERIMENTAL,
            categories.MASSEXTRACTION * categories.TECH3,
            categories.ENERGYPRODUCTION * categories.TECH3,
            categories.MASSEXTRACTION * categories.TECH2,
            categories.ENERGYPRODUCTION * categories.TECH2,
            categories.STRUCTURE,
            categories.TECH3 * categories.MOBILE})
        while aiBrain:PlatoonExists(self) do
            local target = false
            local blip = false
            while unit:GetTacticalSiloAmmoCount() < 1 or not target do
                WaitSeconds(7)
                target = false
                while not target do

                    --DUNCAN - Commented out
                    --if aiBrain:GetCurrentEnemy() and aiBrain:GetCurrentEnemy().Result == "defeat" then
                    --    aiBrain:PickEnemyLogic()
                    --end
                    --target = AIUtils.AIFindBrainTargetInRange(aiBrain, self, 'Attack', maxRadius, atkPri, aiBrain:GetCurrentEnemy())

                    if not target then
                        target = self:FindPrioritizedUnit('Attack', 'Enemy', true, unit:GetPosition(), maxRadius)
                    end
                    if target then
                        break
                    end
                    WaitSeconds(3)
                    if not aiBrain:PlatoonExists(self) then
                        return
                    end
                end
            end
            if not target.Dead then
                --LOG('*AI DEBUG: Firing Tactical Missile at enemy swine!')
                IssueTactical({unit}, target)
            end
            WaitSeconds(3)
        end
    end,
    
    -- 90% of this Relent0r's Work  --Scouting--
    ScoutingAISwarm = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self)

        if self.MovementLayer == 'Air' then
            return self:AirScoutingAISwarm()
        else
            return self:LandScoutingAISwarm()
        end
    end,

    AirScoutingAISwarm = function(self)
        local patrol = self.PlatoonData.Patrol or false
        local scout = self:GetPlatoonUnits()[1]
        if not scout then
            return
        end
        local aiBrain = self:GetBrain()

        if not aiBrain.InterestList then
            aiBrain:BuildScoutLocations()
        end

        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:EnableUnitIntel('Toggle', 'Cloak')
        end

        if patrol == true then
            local patrolTime = self.PlatoonData.PatrolTime or 30
            local estartX = nil
            local estartZ = nil
            local startX = nil
            local startZ = nil
            local patrolPositionX = nil
            local patrolPositionZ = nil
            while not scout.Dead do
                if aiBrain:GetCurrentEnemy() then
                    estartX, estartZ = aiBrain:GetCurrentEnemy():GetArmyStartPos()
                end
                startX, startZ = aiBrain:GetArmyStartPos()
                local rng = math.random(1,3)
                if rng == 1 then
                    patrolPositionX = (estartX + startX) / 2.2
                    patrolPositionZ = (estartZ + startZ) / 2.2
                elseif rng == 2 then
                    patrolPositionX = (estartX + startX) / 2
                    patrolPositionZ = (estartZ + startZ) / 2
                    patrolPositionX = (patrolPositionX + startX) / 2
                    patrolPositionZ = (patrolPositionZ + startZ) / 2
                elseif rng == 3 then
                    patrolPositionX = (estartX + startX) / 2
                    patrolPositionZ = (estartZ + startZ) / 2
                end
                patrolLocation1 = AIUtils.RandomLocation(patrolPositionX, patrolPositionZ)
                patrolLocation2 = AIUtils.RandomLocation(patrolPositionX, patrolPositionZ)
                self:MoveToLocation({patrolPositionX, 0, patrolPositionZ}, false)
                local patrolunits = self:GetPlatoonUnits()
                IssuePatrol(patrolunits, AIUtils.RandomLocation(patrolPositionX, patrolPositionZ))
                IssuePatrol(patrolunits, AIUtils.RandomLocation(patrolPositionX, patrolPositionZ))
                IssuePatrol(patrolunits, AIUtils.RandomLocation(patrolPositionX, patrolPositionZ))
                WaitSeconds(patrolTime)
                self:MoveToLocation({startX, 0, startZ}, false)
                self:PlatoonDisband()
                return
            end
        else
            while not scout.Dead do
                local targetArea = false
                local highPri = false

                local mustScoutArea, mustScoutIndex = aiBrain:GetUntaggedMustScoutArea()
                local unknownThreats = aiBrain:GetThreatsAroundPosition(scout:GetPosition(), 16, true, 'Unknown')
                if mustScoutArea then
                    mustScoutArea.TaggedBy = scout
                    targetArea = mustScoutArea.Position

                elseif table.getn(unknownThreats) > 0 and unknownThreats[1][3] > 25 then
                    aiBrain:AddScoutArea({unknownThreats[1][1], 0, unknownThreats[1][2]})

                elseif aiBrain.IntelData.AirHiPriScouts < aiBrain.NumOpponents and aiBrain.IntelData.AirLowPriScouts < 1
                and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                    aiBrain.IntelData.AirHiPriScouts = aiBrain.IntelData.AirHiPriScouts + 1

                    highPri = true

                    targetData = aiBrain.InterestList.HighPriority[1]
                    targetData.LastScouted = GetGameTimeSeconds()
                    targetArea = targetData.Position

                    aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)


                elseif aiBrain.IntelData.AirLowPriScouts < 1 and table.getn(aiBrain.InterestList.LowPriority) > 0 then
                    aiBrain.IntelData.AirHiPriScouts = 0
                    aiBrain.IntelData.AirLowPriScouts = aiBrain.IntelData.AirLowPriScouts + 1

                    targetData = aiBrain.InterestList.LowPriority[1]
                    targetData.LastScouted = GetGameTimeSeconds()
                    targetArea = targetData.Position

                    aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
                else

                    aiBrain.IntelData.AirLowPriScouts = 0
                    aiBrain.IntelData.AirHiPriScouts = 0
                end


                if targetArea then
                    self:Stop()

                    local vec = self:DoAirScoutVecs(scout, targetArea)

                    while not scout.Dead and not scout:IsIdleState() do


                        if VDist2Sq(vec[1], vec[3], scout:GetPosition()[1], scout:GetPosition()[3]) < 15625 then
                           if mustScoutArea then

                                for idx,loc in aiBrain.InterestList.MustScout do
                                    if loc == mustScoutArea then
                                       table.remove(aiBrain.InterestList.MustScout, idx)
                                       break
                                    end
                                end
                            end

                            break
                        end

                        if VDist3(scout:GetPosition(), targetArea) < 25 then
                            break
                        end

                        WaitTicks(50)
                    end
                else
                    WaitTicks(10)
                end
                WaitTicks(1)
            end
        end
    end,

    LandScoutingAISwarm = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self)

        local aiBrain = self:GetBrain()
        local scout = self:GetPlatoonUnits()[1]


        if not aiBrain.InterestList then
            aiBrain:BuildScoutLocations()
        end


        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:SetScriptBit('RULEUTC_CloakToggle', false)
        end

        while not scout.Dead do

            local targetData = false


            if aiBrain.IntelData.HiPriScouts < aiBrain.NumOpponents and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                targetData = aiBrain.InterestList.HighPriority[1]
                aiBrain.IntelData.HiPriScouts = aiBrain.IntelData.HiPriScouts + 1
                targetData.LastScouted = GetGameTimeSeconds()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)

            elseif table.getn(aiBrain.InterestList.LowPriority) > 0 then
                targetData = aiBrain.InterestList.LowPriority[1]
                aiBrain.IntelData.HiPriScouts = 0
                targetData.LastScouted = GetGameTimeSeconds()

                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            else

                aiBrain.IntelData.HiPriScouts = 0
            end


            if targetData then

                local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, scout:GetPosition(), targetData.Position, 400) --DUNCAN - Increase threatwieght from 100

                IssueClearCommands(self)

                if path then
                    local pathLength = table.getn(path)
                    for i=1, pathLength-1 do
                        self:MoveToLocation(path[i], false)
                    end
                end

                self:MoveToLocation(targetData.Position, false)


                while not scout.Dead and not scout:IsIdleState() do
                    WaitTicks(25)
                end
            end

            WaitTicks(10)
        end
    end,

    -- Function: MergeWithNearbyPlatoons
    --    self - the single platoon to run the AI on
    --    planName - AI plan to merge with
    --    radius - merge with platoons in this radius 
    --    planmatchrequired     - if true merge platoons only with same builder name AND the same plan
    --                          - if false then merging will be done with all platoons using same plan
    --    mergelimit - if set, the merge can only be taken upto that size
    --
    -- Finds platoon nearby (when self platoon is not near a base) and merge with them if they're a good fit.
    --      Dont allow smaller platoons to merge larger platoons into themselves
    --   Returns:  
    --       nil if no merge was done, true if a merge was done
    
    -- NOTE: The platoon executing this function will 'grab' units
    --      from the allied platoons - so in effect, it's reinforcing itself

    -- 90% of This Work is from Sprouto

    MergeWithNearbyPlatoonsSwarm = function( self, aiBrain, planName, radius, planmatchrequired, mergelimit )

        if self.UsingTransport then
        
            return false
            
        end
        
        if not PlatoonExists(aiBrain,self) then
        
            return false
            
        end

        local platoonUnits = GetPlatoonUnits(self)
        local platooncount = 0

        for _,v in platoonUnits do
        
            if not v.Dead then
            
                platooncount = platooncount + 1
                
            end
            
        end

        if (mergelimit and platooncount > mergelimit) or platooncount < 1 then
        
            return false
            
        end
        
        local platPos = SWARMCOPY(GetPlatoonPosition(self))
        local radiusSq = radius*radius  -- maximum range to check allied platoons --

        -- we cant be within 1/3 that range to our own base --
--[[
        for _, base in aiBrain.BuilderManagers do
        
            if VDist2Sq( platPos[1],platPos[3], base.Position[1],base.Position[3] ) <= ( radiusSq / 3 ) then
            
                return false
                
            end 
            
        end
--]]

        -- get a list of all the platoons for this brain
        local GetPlatoonsList = moho.aibrain_methods.GetPlatoonsList
        local AlliedPlatoons = SWARMCOPY(GetPlatoonsList(aiBrain))
        
        SWARMSORT(AlliedPlatoons, function(a,b) return VDist2Sq(GetPlatoonPosition(a)[1],GetPlatoonPosition(a)[3], platPos[1],platPos[3]) < VDist2Sq(GetPlatoonPosition(b)[1],GetPlatoonPosition(b)[3], platPos[1],platPos[3]) end)
        
        local mergedunits = false
        local allyPlatoonSize, validUnits, counter = 0
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." checking MERGE WITH for "..repr(table.getn(AlliedPlatoons)))
        
        local count = 0
        
        -- loop thru all the platoons in the list
        for _,aPlat in AlliedPlatoons do
    
            -- ignore yourself
            if aPlat == self then
                continue
            end
        
            count = count + 1

            -- if allied platoon is busy (not necessarily transports - this is really a general 'busy' flag --
            if aPlat.UsingTransport then
            
                continue
                
            end
            
            -- not only the plan must match but the buildername as well
            if planmatchrequired and aPlat.BuilderName != self.BuilderName then
            
                continue
                
            end
            
            -- otherwise it must a least have the same plan
            if aPlat.PlanName != planName then
            
                continue
                
            end
            
            -- and be on the same movement layer
            if self.MovementLayer != aPlat.MovementLayer then
            
                continue
                
            end
            
            -- check distance of allied platoon -- as soon as we hit one farther away then we're done
            if VDist2Sq(platPos[1],platPos[3], GetPlatoonPosition(aPlat)[1],GetPlatoonPosition(aPlat)[3]) > radiusSq then
            
                break
                
            end
            
            -- get the allied platoons size
            allyPlatoonSize = 0
            
            -- mark the allied platoon as being busy
            aPlat.UsingTransport = true
            
            local aPlatUnits = GetPlatoonUnits(aPlat)
            
            validUnits = {}
            counter = 0
            
            -- count and check validity of allied units
            for _,u in aPlatUnits do
            
                if not u.Dead then
                
                    allyPlatoonSize = allyPlatoonSize + 1

                    if not IsUnitState(u,'Attached' )then
                
                        -- if we have space in our platoon --
                        if (counter + platooncount) <= mergelimit then
                        
                            validUnits[counter+1] = u
                            counter = counter + 1
                            
                        end
                        
                    end
                    
                end
                
            end

            -- if no valid units or we are smaller than the allied platoon then dont allow
            if counter < 1 or platooncount < allyPlatoonSize or allyPlatoonSize == 0 then
            
                continue
                
            end

            -- otherwise we do the merge
            if ScenarioInfo.PlatoonMergeDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." MERGE_WITH "..repr(self.BuilderName).." takes "..counter.." units from "..aPlat.BuilderName.." now has "..platooncount+counter)
            end
            
            -- unmark the allied platoon
            aPlat.UsingTransport = false
            
            -- assign the valid units to us - this may end the allied platoon --
            AssignUnitsToPlatoon( aiBrain, self, validUnits, 'Attack', 'none' )
            
            -- add the new units to our count --
            platooncount = platooncount + counter
            
            -- flag that we did a merge --
            mergedunits = true
            
        end

        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." checked "..count.." platoons")
        return mergedunits
        
    end,

    ReturnToBaseAI = function( self, aiBrain )
	
		-- since RTB always deals with MOBILE units we use the Entity based GetPosition
		local GetPosition = moho.entity_methods.GetPosition
		local GetCommandQueue = moho.unit_methods.GetCommandQueue
		
		local VDist3 = VDist3
		local VDist2 = VDist2
		
		if not aiBrain then
		
			aiBrain = GetBrain(self)
			
		end

		if self == aiBrain.ArmyPool or not PlatoonExists(aiBrain, self) then
		
			WARN("*AI DEBUG ArmyPool or nil in RTB")
			return
			
		end
		
		if self.DistressResponseAIRunning then
		
			self.DistressResponseAIRunning = false
			
		end

		if self.MoveThread then

			self:KillMoveThread()
			
		end
		
		if not self.MovementLayer then
		
			GetMostRestrictiveLayer(self)
			
		end
		
		-- assume platoon is dead 
		local platoonDead = true

		-- set the desired RTBLocation (specified base, source base or false)
        local RTBLocation = self.RTBLocation or self.LocationType or false

		-- flag for experimentals (no air transports)
		local experimental = PlatoonCategoryCount(self, categories.EXPERIMENTAL) > 0
		
		-- assume no engineer in platoon
		local engineer = false

		-- process the units to identify engineers and the CDR
		-- and to determine which base to RTB to
		for k,v in GetPlatoonUnits(self) do
		
			-- set the 'platoonDead' to false
			if not v.Dead then
			
				platoonDead = false
                
				-- set the 'engineer' flag
				if SWARMENTITY( categories.ENGINEER, v ) then
				
					engineer = v

					-- Engineer naming
                    if v.BuilderName and ScenarioInfo.NameEngineers then
					
						if not SWARMENTITY( categories.COMMAND, v ) then
						
							v:SetCustomName("Eng "..v.Sync.id.." RTB from "..v.BuilderName.." to "..v.LocationType )
							
						end
						
                    end
					
					-- force CDR to disband - he never leaves home
	                if SWARMENTITY( categories.COMMAND, v ) then
					
						self:PlatoonDisband( aiBrain )
						return
						
					end
					
					RTBLocation = v.LocationType
					
				end
				
				-- if no platoon RTBLocation then force one
				if not RTBLocation or RTBLocation == "Any" then
				
					-- if the unit has a LocationType and it exists -- we might use that for the platoon
					if v.LocationType then
					
						if RTBLocation != "Any" and aiBrain.BuilderManagers[v.LocationType].EngineerManager.Active then
						
							self.LocationType = v.LocationType
							RTBLocation = v.LocationType
							
						else
						
							-- find the closest manager 
							if self.MovementLayer == "Land" then
							
								-- dont use naval bases for land --
								LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." seeks ONLY Land Bases")
								
								self.LocationType = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(self), false, false )
								RTBLocation = self.LocationType
								
							else
							
								if self.MovementLayer == "Air" or self.MovementLayer == "Amphibious" then
								
									-- use any kind of base --
									self.LocationType = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(self), true, false )
									RTBLocation = self.LocationType
									
								else
								
									-- use only naval bases for 'Sea' platoons
									LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.Buildername).." seeks ONLY Naval bases")
									
									self.LocationType = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(self), true, true )
									RTBLocation = self.LocationType
									
								end
								
							end
							
							LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." using RTBLocation "..repr(RTBLocation))
							
						end
						
					end
					
				end
				
				-- default attached processing (something is not doing this properly)
				if v:IsUnitState('Attached') then
				
					v:DetachFrom()
					v:SetCanTakeDamage(true)
					v:SetDoNotTarget(false)
					v:SetReclaimable(true)
					v:SetCapturable(true)
					v:ShowBone(0, true)
					v:MarkWeaponsOnTransport(v, false)
					
				end
				
			end
			
        end

		-- exit if no units --
		if platoonDead then
		
            return 
			
		end
		
		if ScenarioInfo.PlatoonDialog then
			LOG("*AI DEBUG Platoon "..aiBrain.Nickname.." "..repr(self.BuilderName).." begins RTB to "..repr(RTBLocation) )
		end
		
       	IssueClearCommands( GetPlatoonUnits(self) )
        
        local platPos = SWARMCOPY(GetPlatoonPosition(self))
		local lastpos = SWARMCOPY(GetPlatoonPosition(self))
        
		local transportLocation = false	
        local baseName, base
        local bestBase = false
        local bestBaseName = ""
        local bestDistance = 99999999
		local distance = 0
		
		local bases = aiBrain.BuilderManagers
		
		-- confirm RTB location exists or pick closest
		if bases and platPos then
		
			-- if specified base exists and is active - use it
			-- otherwise locate nearest suitable base as RTBLocation
			if RTBLocation and bases[RTBLocation].EngineerManager.Active then
				
				bestBase = bases[RTBLocation]
				bestBaseName = RTBLocation
                RTBLocation = bestBase.Position
			
			else
				
				RTBLocation = 'Any'
				
				-- loop thru all existing 'active' bases and use the closest suitable base --
				-- if no base -- use 'MAIN' --
				for baseName, base in bases do
				
					-- if the base is active --
					if base.EngineerManager.Active then
					
						-- record distance to base
						distance = VDist2Sq( platPos[1],platPos[3], base.Position[1],base.Position[3] )                
				
						-- is this base suitable for this platoon 
						if (distance < bestDistance) and ( (RTBLocation == 'Any') or (not engineer and not RTBLocation) ) then
                
							-- dont allow RTB to Naval Bases for Land --
							-- and dont allow RTB to anything BUT Naval for Water
							if (self.MovementLayer == 'Land' and base.BaseType == "Sea") or
							   (self.MovementLayer == 'Water' and base.BaseType != "Sea") then
							   
								continue
						
							else
							
								bestBase = base
								bestBaseName = baseName
								RTBLocation = bestBase.Position
								bestDistance = distance    
								
							end
							
						end
						
					end
					
				end
            
				if not bestBase then
			
					LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..repr(self.BuilderName).." Couldn't find base "..repr(RTBLocation).." - using MAIN")
				
					bestBase = aiBrain.BuilderManagers['MAIN']
					bestBaseName = 'MAIN'
					RTBLocation = bestBase.Position
					
				end
				
			end

			-- set transportlocation - engineers always use base centre	
			if bestBase.Position then
			
				transportLocation = table.copy(bestBase.Position)
				
			else
				
				LOG("*AI DEBUG "..aiBrain.Nickname.." RTB cant locate a bestBase")
				
				return self:PlatoonDisband(aiBrain)
				
			end
			
			-- others will seek closest rally point of that base
			if not engineer then
			
				-- use the base generated rally points
				local rallypoints = table.copy(bestBase.RallyPoints)
				
				-- sort the rallypoints for closest to the platoon --
				SWARMSORT( rallypoints, function(a,b) return VDist2Sq( a[1],a[3], platPos[1],platPos[3] ) < VDist2Sq( b[1],b[3], platPos[1],platPos[3] ) end )

				transportLocation = table.copy(rallypoints[1])
				
				-- if cannot find rally marker - use base centre
				if not transportLocation then
				
					transportLocation = table.copy(bestBase.Position)
					
				end
				
			end

            RTBLocation[2] = GetTerrainHeight( RTBLocation[1], RTBLocation[3] )
			transportLocation[2] = GetTerrainHeight(transportLocation[1],transportLocation[3])
		
		else
		
            LOG("*AI DEBUG "..aiBrain.Nickname.." RTB reports no platoon position or no bases")
			
			return self:PlatoonDisband(aiBrain)
			
        end

		
		distance = VDist2Sq( platPos[1],platPos[3], RTBLocation[1],RTBLocation[3] )

		-- Move the platoon to the transportLocation either by ground, transport or teleportation (engineers only)
		-- NOTE: distance is calculated above - it's always distance from the base (RTBLocation) - not from the transport location - 
        -- NOTE: When the platoon is within 75 of the base we just bypass this code
        if platPos and transportLocation and distance > (60*60) then
        
            local mythreat = self:CalculatePlatoonThreat('Overall', categories.ALLUNITS)
            
            if mythreat < 10 then
			
				mythreat = 10
				
            end
			
			-- set marker radius for path finding
			local markerradius = 150
			
			if self.MovementLayer == 'Air' or self.MovementLayer == 'Water' then
			
				markerradius = 200
				
			end
			
            -- we use normal threat first
            local path, reason = self.PlatoonGenerateSafePathToSwarm( aiBrain, self, self.MovementLayer, platPos, transportLocation, mythreat, markerradius )
			
			-- then we'll try elevated threat
			if not path then
			-- we use an elevated threat value to help insure that we'll get a path
				path, reason = self.PlatoonGenerateSafePathToSwarm( aiBrain, self, self.MovementLayer, platPos, transportLocation, mythreat * 3, markerradius )
			end
            
			-- engineer teleportation
			if engineer and engineer:HasEnhancement('Teleporter') then
			
				path = {transportLocation}
				distance = 1
				IssueTeleport( {engineer}, transportLocation )
				
			end

			-- if there is no path try transport call
			if (not path) and PlatoonExists(aiBrain, self) then
            
				local usedTransports = false
				
				-- try to use transports --
				if (self.MovementLayer == 'Land' or self.MovementLayer == 'Amphibious') and not experimental then
				
					usedTransports = self:SendPlatoonWithTransportsSwarm( aiBrain, transportLocation, 4, false )
					
				end
				
				-- if no transport reply resubmit LAND platoons, others will set a direct path
				if not usedTransports and PlatoonExists(aiBrain,self) then
				
					if self.MovementLayer == 'Land' then

                        --LOG("*AI DEBUG "..aiBrain.Nickname.." No path "..reason.." and no transport during RTB to "..repr(RTBLocation).." - reissuing RTB for "..repr(self.BuilderName).." lifetime stats "..repr( self:GetPlatoonLifetimeStats() ).." Creation Time was "..repr(self.CreationTime).." Currently "..repr(LOUDTIME()))
						
						WaitTicks(35)
						
						return self:SetAIPlan('ReturnToBaseAI',aiBrain)
						
					else
					
                        self:Stop()
						
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." No path - Moving directly to transportLocation "..repr(transportLocation).." in RTB - distance "..repr(math.sqrt(distance)))
						
						path = { transportLocation }
						
					end
				
				end
			
			end

			-- execute the path movement
			if path then
			
				if PlatoonExists(aiBrain, self) then
				
					self.MoveThread = self:ForkThread( self.MovePlatoon, path, 'GrowthFormation', false)

				end
			
			end
			
		else
		
			-- closer than 75 - move directly --
			if platPos and transportLocation then
			
                --self:Stop()
				self:MoveToLocation(transportLocation, true)		
				
			end
			
		end
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..repr(self.BuilderName).." Moving to transportLocation - distance "..repr(math.sqrt(distance)))

		
		-- At this point the platoon is on its way back to base (or may be there)
		local count = false
		local StuckCount = 0
		local nocmdactive = false	-- this will bypass the nocmdactive check the first time
		
        local timer = SWARMTIME()
        local StartMoveTime = SWARMFLOOR(timer)
		
		local calltransport = 3	-- make immediate call for transport --
		
		-- Monitor the platoons distance to the base watching for death, stuck or idle, and checking for transports
        while (not count) and PlatoonExists(aiBrain, self) and distance > (60*60) do
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..repr(self.BuilderName).." watching travel - RTBLocation is "..repr(RTBLocation).." distance is "..repr(math.sqrt(distance)))
            
			-- check units for idle or stuck --
            for _,v in GetPlatoonUnits(self) do
				
				if not v.Dead then
					
					if nocmdactive then
					
						if SWARMGETN(GetCommandQueue(v)) > 0 or (not v:IsIdleState()) then
						
							nocmdactive = false
							
						else
						
							--LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." has "..LOUDGETN(GetCommandQueue(v)).." CMD queue - Idle State is "..repr(v:IsIdleState()))
							
						end
						
					end
					
					-- look for stuck units after 90 seconds
					if (SWARMTIME() - StartMoveTime) > 90 then
					
						local unitpos = SWARMCOPY(GetPosition(v))
						
						-- if the unit hasn't gotten within range of the platoon
						if VDist2Sq( platPos[1],platPos[3], unitpos[1],unitpos[3] ) > (80*80)  then
					
							if not SWARMENTITY(categories.EXPERIMENTAL,v) then
						
								if not v.WasWarped then
								
									WARN("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." Unit warped in RTB to "..repr(platPos))
									
									Warp( v, platPos )
									IssueMove( {v}, RTBLocation)
									v.WasWarped = true
									
								else
								
									WARN("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." Unit at "..repr(unitpos).." from platoon at "..repr(platPos).." Killed in RTB")
									
									v:Kill()
									
								end
								
							end
							
						end
						
					end
					
				end
				
            end
			
			-- while moving - check distance and call for transport --
			if PlatoonExists(aiBrain, self) then
			
				-- get either a position or use the destination (trigger an end)
				platPos = SWARMCOPY(GetPlatoonPosition(self) or RTBLocation)
				
				distance = VDist2Sq( platPos[1],platPos[3], RTBLocation[1],RTBLocation[3] )
				
				usedTransports = false

				-- call for transports for those platoons that need it -- standard or if stuck
				if (not experimental) and (self.MovementLayer == 'Land' or self.MovementLayer == 'Amphibious')  then
				
					if ( distance > (300*300) or StuckCount > 5 ) and platPos and transportLocation and PlatoonExists(aiBrain, self) then
				
						-- if calltransport counter is 3 check for transport and reset the counter
						-- thru this mechanism we only call for tranport every 4th loop (40 seconds)
						if calltransport > 2 then

							usedTransports = self:SendPlatoonWithTransportsSwarm( aiBrain, transportLocation, 1, false )
							
							calltransport = 0
							
							-- if we used tranports we need to update position and distance
							if usedTransports then
							
								platPos = SWARMCOPY(GetPlatoonPosition(self))
								
								distance = VDist2Sq( platPos[1],platPos[3], RTBLocation[1],RTBLocation[3] )
								
								usedTransports = false
								
							end
							
						else
						
							calltransport = calltransport + 1
							
						end
						
					end
					
				end
				
			end
			
			-- while moving - check for proximity to base (not transportlocation) --
			if PlatoonExists(aiBrain, self) and RTBLocation then
			
				-- proximity to base --
				if distance <= (75*75) then
				
					count = true -- we are near the base - trigger the end of the loop
                    break
					
				end
				
				-- proximity to transportlocation --
                if transportLocation and VDist2Sq( platPos[1],platPos[3], transportLocation[1],transportLocation[3]) < (35*35) then
				
                    count = true
                    break
					
                end
				
				-- if haven't moved much -- 
				if not count and ( lastpos and VDist2Sq( lastpos[1],lastpos[3], platPos[1],platPos[3] ) < 0.15 ) then
				
					StuckCount = StuckCount + 1
					
				else
				
					lastpos = LOUDCOPY(platPos)
					StuckCount = 0
					
				end
				
			end

			-- if platoon idle or base is now inactive -- resubmit platoon if not dead --
			if PlatoonExists(aiBrain, self) and (StuckCount > 10 or nocmdactive or (not aiBrain.BuilderManagers[bestBaseName])) then
				
				if self.MoveThread then
				
					self:KillMoveThread()
					
				end
				
				local platooncount = 0
				
				-- count units and clear out dead
				for k,v in GetPlatoonUnits(self) do
				
					if not v.Dead then
					
						platooncount = platooncount + 1
						
					end
					
				end
                
				-- dead platoon
                if platooncount == 0 then
				
                	return
					
                end                
                
				-- if there is only one unit -- just move it - otherwise resubmit to RTB
                if platooncount == 1 and aiBrain.BuilderManagers[bestBaseName] then
					
                    IssueMove( GetPlatoonUnits(self), RTBLocation)
                    StuckCount = 0
                    count = false
                
				else
				
					local units = GetPlatoonUnits(self)
					
                	IssueClearCommands( units )
					
                    local ident = Random(1,999999)
					
					returnpool = aiBrain:MakePlatoon('ReturnToBase '..tostring(ident), 'none' )
					
                    returnpool.PlanName = 'ReturnToBaseAI'
                    returnpool.BuilderName = 'RTBStuck'
                    returnpool.BuilderLocation = self.LocationType or false
					returnpool.RTBLocation = self.RTBLocation or false
					returnpool.MovementLayer = self.MovementLayer
					
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(nocmdactive).." "..repr(StuckCount).." from "..repr(self.BuilderLocation).." at "..repr(GetPlatoonPosition(returnpool)).." Stuck in RTB to "..repr(self.BuilderLocation).." "..math.sqrt(distance))					
					
					for _,u in units do
					
						if not u.Dead then
						
							if math.sqrt(distance) > 150 then 
						
								AssignUnitsToPlatoon( aiBrain, returnpool, {u}, 'Unassigned', 'None' )
								u.PlatoonHandle = {returnpool}
								u.PlatoonHandle.PlanName = 'ReturnToBaseAI'
								
							else
								
								IssueMove( {u}, RTBLocation )
								
							end
							
						end
						
					end



					if not returnpool.BuilderLocation then
					
						GetMostRestrictiveLayer(returnpool)
						
						if returnpool.MovementLayer == "Land" then
						
							-- dont use naval bases for land --
							returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(returnpool), false )
							
						else
						
							if returnpool.MovementLayer == "Air" or returnpool.PlatoonLayer == "Amphibious" then
							
								-- use any kind of base --
								returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(returnpool), true, false )
								
							else
							
								-- use only naval bases --
								returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(returnpool), true, true )
								
							end
							
						end
						
						returnpool.RTBLocation = returnpool.BuilderLocation	-- this should insure the RTB to a particular base
						
						--LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..repr(returnpool.BuilderName).." submitted to "..repr(returnpool.BuilderLocation))
						
					end
					
                    count = true -- signal the end of the primary loop

					-- send the new platoon off to RTB
					returnpool:SetAIPlan('ReturnToBaseAI', aiBrain)

					WaitTicks(2)
					break
					
				end
				
			end

			nocmdactive = true	-- this will trigger the nocmdactive check on the next pass

			WaitTicks(55)

        end
        
		if PlatoonExists(aiBrain, self) then
		
			if self.MoveThread then

				self:KillMoveThread()
				
			end
			
			-- all units are spread out to the rally points except engineers (we want them back to work ASAP)
			if not engineer then
			
				import('/lua/AI/swarmutilities.lua').DisperseUnitsToRallyPoints( aiBrain, GetPlatoonUnits(self), RTBLocation, aiBrain.BuilderManagers[bestBaseName].RallyPoints or false )
				
			else
			
				-- without this, engineers will continue right to the heart of the base
				self:Stop()
				
			end
        
			self:PlatoonDisband(aiBrain)
	
		end
		
    end,

    PlatoonGenerateSafePathToSwarm = function( aiBrain, platoon, platoonLayer, start, destination, threatallowed, MaxMarkerDist)

		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions
		
		local VDist2Sq = VDist2Sq
		local VDist2 = VDist2
		
		-- types of threat to look at based on composition of platoon
		local ThreatTable = { Land = 'AntiSurface', Water = 'AntiSurface', Amphibious = 'AntiSurface', Air = 'AntiAir', }
		local threattype = ThreatTable[platoonLayer]

		-- threatallowed controls how much threat is considered acceptable at any point
		local threatallowed = threatallowed or 5
		
		-- step size is used when making DestinationBetweenPoints checks
		-- the value of 70 is relatively safe to use to avoid intervening terrain issues
		local stepsize = 100

		-- air platoons can look much further off the line since they generally ignore terrain anyway
		-- this larger step makes looking for destination much less costly in processing
		if platoonLayer == 'Air' then
			stepsize = 240
		end
		
		if start and destination then
	
			local distance = VDist2( start[1],start[3], destination[1],destination[3] )
		
			if distance <= stepsize then
			
				return {destination}, 'Direct', distance
				
			elseif platoonLayer == 'Amphibious' then
			
				stepsize = 125
				
				if distance <= stepsize then
					return {destination}, 'Direct', distance
				end
				
			elseif platoonLayer == 'Water' then
			
				stepsize = 175
				
				if distance <= stepsize then
					return {destination}, 'Direct', distance
				end
				
			elseif platoonLayer == 'Air' then
			
				stepsize = 250
				
				if distance <= stepsize or GetThreatBetweenPositions( aiBrain, start, destination, nil, threattype) < threatallowed then
					return {destination}, 'Direct', distance
				end

			end
			
		else
		
			if not destination then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." Generate Safe Path "..platoonLayer.." had a bad destination "..repr(destination))
				return false, 'Badlocations', 0
				
			else
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName).." Generate Safe Path "..platoonLayer.." had a bad start "..repr(start))
				return {destination}, 'Direct', 9999
			end
			
		end

		-- MaxMarkerDist controls the range we look for markers AND the range we use when making threat checks
		local MaxMarkerDist = MaxMarkerDist or 160
		local radiuscheck = MaxMarkerDist * MaxMarkerDist
		local threatradius = MaxMarkerDist * .33
		
		local stepcheck = stepsize * stepsize
		
		-- get all the layer markers -- table format has 5 values (posX,posY,posZ, nodeName, graph)
		local markerlist = ScenarioInfo.PathGraphs['RawPaths'][platoonLayer] or false

		
		--** A Whole set of localized function **--
		-------------------------------------------
		local AIGetThreatLevelsAroundPoint = function( position, threatradius )
	
			if threattype == 'AntiAir' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'AntiAir')	--airthreat
			elseif threattype == 'AntiSurface' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'AntiSurface')	--surthreat
			elseif threattype == 'AntiSub' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'AntiSub')	--subthreat
			elseif threattype == 'Economy' then
				return aiBrain:GetThreatAtPosition( position, 0, true, 'Economy')	--ecothreat
			else
				return aiBrain:GetThreatAtPosition( position, 0, true, 'Overall')	--airthreat + ecothreat + surthreat + subthreat
			end
	
		end

		-- checks if destination is somewhere between two points
		local DestinationBetweenPoints = function( destination, start, finish )

			-- using the distance between two nodes
			-- calc how many steps there will be in the line
			local steps = SWARMFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize )
	
			if steps > 0 then
			
				-- and the size of each step
				local xstep = (start[1] - finish[1]) / steps
				local ystep = (start[3] - finish[3]) / steps
	
				-- check the steps from start to one less than then destination
				for i = 1, steps - 1 do
				
					-- if we're within the stepcheck ogrids of the destination then we found it
					if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < stepcheck then
					
						return true
						
					end
					
				end	
				
			end
			
			return false
			
		end

		-- this function will return a 3D position and a named marker
		local GetClosestSafePathNodeInRadiusByLayerLOUD = function( location, seeksafest, goalseek, threatmodifier )
	
			if markerlist then
			
				local positions = {}
				local counter = 0
			
				local VDist3Sq = VDist3Sq
				
				-- sort the table by closest to the given location
				SWARMSORT(markerlist, function(a,b) return VDist3Sq( a.position, location ) < VDist3Sq( b.position, location ) end)
	
				-- traverse the list and make a new list of those with allowable threat and within range
				-- since the source table is already sorted by range, the output table will be created in a sorted order
				for nodename,v in markerlist do
			
					-- process only those entries within the radius
					if VDist3Sq( v.position, location ) <= radiuscheck then
			
						-- add only those with acceptable threat to the new list
						-- if seeksafest or goalseek flag is set we'll build a table of points with allowable threats
						-- otherwise we'll just take the closest one
						if AIGetThreatLevelsAroundPoint( v.position, threatradius) <= (threatallowed * threatmodifier) then

							if seeksafest or goalseek then
						
								positions[counter+1] = { AIGetThreatLevelsAroundPoint( v.position, threatradius), v.node, v.position }
								counter = counter + 1
							
							else
						
								return ScenarioInfo.PathGraphs[platoonLayer][v.node], v.node or GetPathGraphs()[platoonLayer][v.node], v.node
							
							end
						
						end
					
					end
				
				end
			
				-- resort positions to be closest to goalseek position
				-- just a note here -- the goalseek position is often sent WITHOUT a vertical indication so I had to use VDIST2 rather than VDIST 3 to be sure
				if goalseek then
			
					SWARMSORT(positions, function(a,b) return VDist2Sq( a[3][1],a[3][3], goalseek[1],goalseek[3] ) < VDist2Sq( b[3][1],b[3][3], goalseek[1],goalseek[3] ) end)
				
				end
			
				--LOG("*AI DEBUG Sorted positions for destination "..repr(goalseek).." are "..repr(positions))
			
				local bestThreat = (threatallowed * threatmodifier)
				local bestMarker = positions[1][2]	-- defalut to the one closest to goal 	--false
			
				-- loop thru to find one with lowest threat	-- if all threats are equal we'll end up with the closest
				if seeksafest then
			
					for _,v in positions do
				
						if v[1] < bestThreat then
							bestThreat = v[1]
							bestMarker = v[2]
						end
					
					end
				
				end

				if bestMarker then
			
					return ScenarioInfo.PathGraphs[platoonLayer][bestMarker],bestMarker or GetPathGraphs()[platoonLayer][bestMarker],bestMarker
				
				end
				
			end
			
			return false, false
			
		end	

		local AddBadPath = function( layer, startnode, endnode )

			if not ScenarioInfo.BadPaths[layer][startnode] then
			
				ScenarioInfo.BadPaths[layer][startnode] = {}
				
			end

			if not ScenarioInfo.BadPaths[layer][startnode][endnode] then
	
				ScenarioInfo.BadPaths[layer][startnode][endnode] = {}

				if not ScenarioInfo.BadPaths[layer][endnode] then
					ScenarioInfo.BadPaths[layer][endnode] = {}
				end
		
				ScenarioInfo.BadPaths[layer][endnode][startnode] = {}
				
			end
			
		end

		-- this flag is set but passed into the path generator
		-- was originally used to allow the path generator to 'cut corners' on final step
		local testPath = true
		
		if platoonLayer == 'Air' or platoonLayer == 'Amphibious' then
		
			testPath = true
			
		end
	
		-- Get the closest safe node at platoon position which is closest to the destination
		local startNode, startNodeName = GetClosestSafePathNodeInRadiusByLayer( start, false, destination, 2 )

		if not startNode and platoonLayer == 'Amphibious' then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." GenerateSafePath "..platoon.BuilderName.." "..threatallowed.." fails no safe "..platoonLayer.." startnode within "..MaxMarkerDist.." of "..repr(start).." - trying Land")
			platoonLayer = 'Land'
			startNode, startNodeName = GetClosestSafePathNodeInRadiusByLayer( start, false, destination, 2 )
			
		end
	
		if not startNode then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." GenerateSafePath "..repr(platoon.BuilderName).." "..threatallowed.." finds no safe "..platoonLayer.." startnode within "..MaxMarkerDist.." of "..repr(start).." - failing")
			WaitTicks(1)
			return false, 'NoPath'
			
		end
		
		if DestinationBetweenPoints( destination, start, startNode.position ) then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName).." finds destination between current position and startNode")
			return {destination}, 'Direct', 0.9
			
		end			
    
		-- Get the closest safe node at the destination which is cloest to the start
		local endNode, endNodeName = GetClosestSafePathNodeInRadiusByLayer( destination, true, false, 1 )

		if not endNode then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." GenerateSafePath "..repr(platoon.BuilderName).." "..threatallowed.." finds no safe "..platoonLayer.." endnode within "..MaxMarkerDist.." of "..repr(destination).." - failing")
			WaitTicks(1)
			return false, 'NoPath'
			
		end
		
		if startNodeName == endNodeName then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName).." GenerateSafePath has same start and end node "..repr(startNodeName))
			return {destination}, 'Direct', 1
			
		end
		
		local path = false
		local pathlength = VDist2(start[1],start[3],startNode.position[1],startNode.position[3])
	
		local BadPath = ScenarioInfo.BadPaths[platoonLayer]
	
		-- if the nodes are not in the bad path cache generate a path for them
		-- Generate the safest path between the start and destination nodes
		if not BadPath[startNodeName][endNodeName] then
			
			-- add the platoons request for a path to the respective path generator for that layer
			SWARMINSERT(aiBrain.PathRequests[platoonLayer], {
															Dest = destination,
															EndNode = endNode,
															Location = start,
															Platoon = platoon, 
															StartNode = startNode,
															Stepsize = stepsize,
															Testpath = testPath,
															ThreatLayer = threattype,
															ThreatWeight = threatallowed,
			} )

			aiBrain.PathRequests['Replies'][platoon] = false
			
            
            local Replies = aiBrain.PathRequests['Replies']
			
			local waitcount = 1
		
			
			-- loop here until reply or 90 seconds
			while waitcount < 100 do
			
				WaitTicks(3)

				waitcount = waitcount + 1
				
				if Replies[platoon].path then
				
					break
					
				end
				
			end
		
			if waitcount < 100 then
			
				path = Replies[platoon].path
				pathlength = pathlength + Replies[platoon].length
				
			else
			
				Replies[platoon] = false
				return false, 'NoResponse',0
				
			end

			Replies[platoon] = false
			
		end

		if not path or path == 'NoPath' then
	
			-- if no path can be found (versus too much threat or no reply) then add to badpath cache
			if path == 'NoPath' and not BadPath[startNodeName][endNodeName] then
			
				ForkTo(AddBadPath, platoonLayer, startNodeName, endNodeName )
				
			end
	
			return false, 'NoPath', 0
			
		end
	
		path[table.getn(path)+1] = destination
	
		return path, 'Pathing', pathlength
		
	end,

	SendPlatoonWithTransportsSwarm = function( self, aiBrain, destination, attempts, bSkipLastMove )

		if self.MovementLayer == 'Land' or self.MovementLayer == 'Amphibious' then
		
			local AIGetMarkersAroundLocation = import('ai/aiutilities.lua').AIGetMarkersAroundLocation
			
			local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
			local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint			
			
			local PlatoonGenerateSafePathToSwarm = self.PlatoonGenerateSafePathToSwarm
		
			local surthreat, airthreat
			local mythreat
    
			-- prohibit LAND platoons from traveling to water locations
			if self.MovementLayer == 'Land' then
			
				if GetTerrainHeight(destination[1], destination[3]) < GetSurfaceHeight(destination[1], destination[3]) - 2 then 
				
					LOG("*AI DEBUG SendPlatWTrans says Water")
					return false
					
				end
				
			end
			
			-- a local function to get the real surface and air threat at a position based on known units rather than using the threat map
			-- we also pull the value from the threat map so we can get an idea of how often it's a better value
			-- I'm thinking of mixing the two values so that it will error on the side of caution
			local GetRealThreatAtPosition = function( position, range )
			
				local s = 0 
				local a = 0
				
				local sfake = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiSurface' )
				local afake = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiAir' )
			
				local eunits = GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.FACTORY - categories.ECONOMIC - categories.SHIELD - categories.WALL , position, range,  'Enemy')
			
				if eunits then
			
					for _,u in eunits do
				
						if not u.Dead then
					
							local bp = __blueprints[u.BlueprintID].Defense
						
							a = a + bp.AirThreatLevel
							s = s + bp.SurfaceThreatLevel

						end
					
					end

				end
				
				if sfake > 0 and sfake > s then
				
					s = (s + sfake) * .5
					
				end
				
				if afake > 0 and afake > a then
				
					a = (a + afake) * .5
					
				end
				
				return s, a
			
			end

			-- a local function to find an alternate Drop point which satisfies both transports and self for threat and a path to the goal
			local FindSafeDropZoneWithPath = function( self, transportplatoon, markerTypes, markerrange, destination, threatMax, airthreatMax, threatType, layer)

				local markerlist = {}
				local path, reason, pathlength
	
				-- locate the requested markers within markerrange of the supplied location	that the platoon can safely land at
				for _,v in markerTypes do
				
					markerlist = SWARMCAT( markerlist, AIGetMarkersAroundLocation(aiBrain, v, destination, markerrange, 0, threatMax, 0, 'AntiSurface') )
					
				end
				
				-- sort the markers by closest distance to final destination
				SWARMSORT( markerlist, function(a,b) return VDist2Sq( a.Position[1],a.Position[3], destination[1],destination[3] ) < VDist2Sq( b.Position[1],b.Position[3], destination[1],destination[3] )  end )

				-- loop thru each marker -- see if you can form a safe path on the surface 
				-- and a safe path for the transports -- use the first one that satisfies both
				for _, v in markerlist do

					-- test the real values for that position
					local stest, atest = GetRealThreatAtPosition( v.Position, 75 )
		
					if stest <= threatMax and atest <= airthreatMax then
					
						--LOG("*AI DEBUG "..aiBrain.Nickname.." FINDSAFEDROP for "..repr(destination).." is testing "..repr(v.Position).." "..v.Name)
						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." Position "..repr(v.Position).." says Surface threat is "..stest.." vs "..threatMax.." and Air threat is "..atest.." vs "..airthreatMax )
						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." drop distance is "..repr( VDist3(destination, v.Position) ) )
			
						-- can the self path safely from this marker to the final destination 
						path, reason, pathlength = PlatoonGenerateSafePathToSwarm(aiBrain, self, layer, destination, v.Position, threatMax, 160 )
	
						-- can the transports reach that marker ?
						if path then
						
							--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." can path from "..repr(v.Position).." to "..repr(destination))
							
							path, reason, pathlength = PlatoonGenerateSafePathToSwarm( aiBrain, transportplatoon, 'Air', v.Position, self:GetPlatoonPosition(), airthreatMax, 240 )
						
							if path then
							
								--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." finds SAFEDROP at "..repr(v.Position))
							
								return v.Position, v.Name
							
							end

						end
					
					end
					
				end

				
				--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." NO safe drop for "..repr(destination).." using "..layer)
				
				return false, nil
				
			end
	
			local counter = 0
			local bUsedTransports = false
			local transportplatoon = false
			local IsEngineer = PlatoonCategoryCount( self, categories.ENGINEER ) > 0
			
			-- make the requested number of attempts to get transports
			for counter = 1, attempts do
			
				if PlatoonExists( aiBrain, self ) then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." call transports attempt "..counter)
					
					-- check if we can get enough transport and how many transports we are using
					-- this call will return the # of units transported (true) or false, if true, the self holding the transports or false
					bUsedTransports, transportplatoon = GetTransports( self, aiBrain )
			
					if bUsedTransports or counter == attempts then
					
						break 
						
					end

					WaitTicks(120)

				end
				
			end

			-- if we didnt use transports
			if (not bUsedTransports) then

				if transportplatoon then
				
					ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
					
				end

				return false
				
			end

			--LOG("*AI DEBUG "..aiBrain.Nickname.." assigns "..transportplatoon.BuilderName.." to "..self.BuilderName)
	
			-- ===================================
			-- FIND A DROP ZONE FOR THE TRANSPORTS
			-- ===================================
			-- this is based upon the threat at the destination and the threat sensitivity of the land units and the transports
			
			-- a threat value for the transports based upon the number of transports
			local transportcount = SWARMGETN( GetPlatoonUnits(transportplatoon))
			
			local airthreatMax = transportcount * 8
			
			airthreatMax = airthreatMax + ( airthreatMax * math.log10(transportcount))
			
			--LOG("*AI DEBUG "..aiBrain.Nickname.." airthreatMax for "..transportcount.." unit transport platoon is "..repr(airthreatMax).." calc is "..math.log10(transportcount) )
			
			-- this is the desired drop location
			local transportLocation = SWARMCOPY(destination)

			-- our own threat
			local mythreat = self:CalculatePlatoonThreat('AntiSurface', categories.ALLUNITS)
			
			if not mythreat then 
				mythreat = 1
			end
			
			-- get the real known threat at the destination within 75 grids
			surthreat, airtheat = GetRealThreatAtPosition( destination, 75 )

			-- if the destination doesn't look good, use alternate or false
			if surthreat > mythreat or airthreat > airthreatMax then
			
				-- we'll look for a drop zone at least half as close as we already are
				local markerrange = VDist3( self:GetPlatoonPosition(), destination ) * .5
				
				--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." seeking alternate landing zone within "..markerrange.." of destination "..repr(destination))
			
				transportLocation = false

				-- If destination is too hot -- locate the nearest movement marker that is safe
				if self.MovementLayer == 'Amphibious' then
				
					transportLocation = FindSafeDropZoneWithPath( self, transportplatoon, {'Amphibious Path Node','Land Path Node','Transport Marker'}, markerrange, destination, mythreat, airthreatMax, 'AntiSurface', self.MovementLayer)
					
				else
				
					transportLocation = FindSafeDropZoneWithPath( self, transportplatoon, {'Land Path Node','Transport Marker'}, markerrange, destination, mythreat, airthreatMax, 'AntiSurface', self.MovementLayer)
					
				end
				
				if transportLocation then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." finds alternate landing position at "..repr(transportLocation))
					
					ForkTo( AISendPing, transportLocation, 'alert', aiBrain.ArmyIndex )
				
				end
			
			end
		
			-- if no alternate, or either self has died, return the transports and abort transport
			if not transportLocation or (not PlatoonExists(aiBrain, self)) or (not PlatoonExists(aiBrain,transportplatoon)) then
				
				if PlatoonExists(aiBrain,transportplatoon) then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." cannot find safe transport position to "..repr(destination).." - "..self.MovementLayer.." - aborting transport")
					
					ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
					
				end

				return false
				
			end

			-- correct drop location for surface height
			transportLocation[2] = GetSurfaceHeight(transportLocation[1], transportLocation[3])

			if self.MoveThread then
			
				-- if the platoon has a movement thread this should kill it 
				-- before we pick the platoon up -- 
				self:KillMoveThread()
				
			end

			
			-- LOAD THE TRANSPORTS AND DELIVER
			-- we stay in this function until we load, move and arrive or die
			-- will get a false if entire self cannot be used
			-- note how we pass the IsEngineer flag -- alters the behaviour of the transport
			bUsedTransports = UseTransports( aiBrain, transportplatoon, transportLocation, self, IsEngineer )
			
			-- if self died or we couldn't use transports --
			if (not self) or (not PlatoonExists(aiBrain, self)) or (not bUsedTransports) then
			
				-- if transports RTB them --
				if PlatoonExists(aiBrain,transportplatoon) then
				
					ForkTo( ReturnTransportsToPool, aiBrain, GetPlatoonUnits(transportplatoon), true)
					
				end
				
				
				return false
				
			end

			-- PROCESS THE PLATOON AFTER LANDING 
			-- if we used transports then process any unlanded units
			-- seriously though - UseTransports should have dealt with that
			-- anyhow - forcibly detach the unit and re-enable standard conditions
			local units = GetPlatoonUnits(self)

			for _,v in units do
			
				if not v.Dead and IsUnitState( v, 'Attached' ) then
				
					v:DetachFrom()
					v:SetCanTakeDamage(true)
					v:SetDoNotTarget(false)
					v:SetReclaimable(true)
					v:SetCapturable(true)
					v:ShowBone(0, true)
					v:MarkWeaponsOnTransport(v, false)
					
				end
				
			end
		
			-- set path to destination if we landed anywhere else but the destination
			-- All platoons except engineers (which move themselves) get this behavior
			if (not IsEngineer) and GetPlatoonPosition(self) != destination then
		
				if not PlatoonExists( aiBrain, self ) or not GetPlatoonPosition(self) then
				
					return false
					
				end

				-- path from where we are to the destination - use inflated threat to get there --
				local path = PlatoonGenerateSafePathToSwarm(aiBrain, self, self.MovementLayer, GetPlatoonPosition(self), destination, mythreat * 1.25, 160)
				
				local AggroMove = true
				
				if PlatoonExists( aiBrain, self ) then
				
					-- if no path then fail otherwise use it
					if not path and destination != nil then

						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." transport failed and/or no path to destination ")
						
						return false
				
					elseif path then

						self.MoveThread = self:ForkThread( self.MovePlatoon, path, 'AttackFormation', AggroMove )

					end
					
				end
				
			end
			
		end
    
		return PlatoonExists( aiBrain, self )
		
	end,

	--  Function: MergeIntoNearbyPlatoons
	--  This is a variation of the MergeWithNearbyPlatoons 
	--	this one will 'insert' units into another platoon.
	--  used when a depleted platoon would otherwise retreat

    MergeIntoNearbyPlatoons = function( self, aiBrain, planName, radius, planmatchrequired, mergelimit )
	
        if self.UsingTransport then 
            return false
        end		
		
		if not PlatoonExists(aiBrain,self) then
			return false
		end

        local platPos = GetPlatoonPosition(self) or false
		
		if not platPos then
			return false
		end
		
        local radiusSq = radius*radius
		
        for _, base in aiBrain.BuilderManagers do
		
            if VDist2Sq( platPos[1],platPos[3], base.Position[1],base.Position[3] ) <= ( radiusSq / 2 ) then
			
                return false
				
            end 
			
        end
		
        -- get all the platoons
		local GetPlatoonsList = moho.aibrain_methods.GetPlatoonsList
        local AlliedPlatoons = GetPlatoonsList(aiBrain)
		
		SWARMSORT(AlliedPlatoons, function(a,b) return VDist2Sq(GetPlatoonPosition(a)[1],GetPlatoonPosition(a)[3], platPos[1],platPos[3]) < VDist2Sq(GetPlatoonPosition(b)[1],GetPlatoonPosition(b)[3], platPos[1],platPos[3]) end)

        for _,aPlat in AlliedPlatoons do

            if aPlat == self then
                continue
            end
			
			if VDist2Sq(platPos[1],platPos[3], GetPlatoonPosition(aPlat)[1],GetPlatoonPosition(aPlat)[3]) > radiusSq then
				break
			end
			
            if aPlat.UsingTransport then
                continue
            end
			
			if planmatchrequired and aPlat.BuilderName != self.BuilderName then
				continue
			end
			
            if aPlat.PlanName != planName then
                continue
            end
			
            if self.MovementLayer != aPlat.MovementLayer then
                continue
            end
			
            local validUnits = {}
			local counter = 0
			local units = GetPlatoonUnits(self)

			for _,u in units do
			
                if (not u.Dead) and (not u:IsUnitState( 'Attached' )) then
				
                    validUnits[counter+1] = u
					counter = counter + 1
					
                end
				
            end

            if counter > 0 then
			
				if ScenarioInfo.PlatoonMergeDialog then
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." with "..counter.." units MERGE_INTO "..repr(aPlat.BuilderName))
				end			

				AssignUnitsToPlatoon( aiBrain, aPlat, validUnits, 'Attack', 'GrowthFormation' )

				IssueMove( validUnits, aPlat:GetPlatoonPosition() )
			
				return true
			
			end
			
        end

		return false
		
    end,
}

--T4 Kanonenbot
--Speed 0.8
--High 12
--Impact after 18 map units

--Schüssel
--Speed 0.8
--High 25
--Impact after 26 map units

--T4 Bomber
--Speed 2.0
--High 25
--Impact after 60

--T3 Bomber
--Speed 1.6
--High 20
--Impact after 

--T2 Kanonenbot
--Speed 1.2
--High 10
--Impact after 12  map units


