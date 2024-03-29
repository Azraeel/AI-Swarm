local import = import 

local SWARMSORT = table.sort
local SWARMCOPY = table.copy
local SWARMGETN = table.sort

local VDist3 = VDist3

-- AI-Swarm: Hook for Replace factory buildtemplate to find a better buildplace not too close to the center of the base
local AntiSpamList = {}
SwarmAIExecuteBuildStructure = AIExecuteBuildStructure
function AIExecuteBuildStructure(aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, constructionData)
    -- Only use this with AI-Swarm
    if not aiBrain.Swarm then
        return SwarmAIExecuteBuildStructure(aiBrain, builder, buildingType, closeToBuilder, relative, buildingTemplate, baseTemplate, reference, constructionData)
    end
    local factionIndex = aiBrain:GetFactionIndex()
    local whatToBuild = aiBrain:DecideWhatToBuild(builder, buildingType, buildingTemplate)
    local FactionIndexToName = {[1] = 'UEF', [2] = 'AEON', [3] = 'CYBRAN', [4] = 'SERAPHIM', [5] = 'NOMADS' }
    local AIFactionName = FactionIndexToName[factionIndex] or 'Unknown'
    -- If the c-engine can't decide what to build, then search the build template manually.
    if not whatToBuild then
        if AntiSpamList[buildingType] then
            return false
        end
        SPEW('*AIExecuteBuildStructure: c-function DecideWhatToBuild() failed! - AI-faction: index('..factionIndex..') '..AIFactionName..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(builder.factionCategory))
        -- Get the UnitId for the actual buildingType
        if not buildingTemplate then
            WARN('*AIExecuteBuildStructure: Function was called without a buildingTemplate!')
        end
        local BuildUnitWithID
        for Key, Data in buildingTemplate do
            if Data[1] and Data[2] and Data[1] == buildingType then
                SPEW('*AIExecuteBuildStructure: Found template: '..repr(Data[1])..' - Using UnitID: '..repr(Data[2]))
                BuildUnitWithID = Data[2]
                break
            end
        end
        -- If we can't find a template, then return
        if not BuildUnitWithID then
            AntiSpamList[buildingType] = true
            WARN('*AIExecuteBuildStructure: No '..repr(builder.factionCategory)..' unit found for template: '..repr(buildingType)..'! ')
            return false
        end
        -- get the needed tech level to build buildingType
        local BBC = __blueprints[BuildUnitWithID].CategoriesHash
        local NeedTech
        if BBC.BUILTBYCOMMANDER or BBC.BUILTBYTIER1COMMANDER or BBC.BUILTBYTIER1ENGINEER then
            NeedTech = 1
        elseif BBC.BUILTBYTIER2COMMANDER or BBC.BUILTBYTIER2ENGINEER then
            NeedTech = 2
        elseif BBC.BUILTBYTIER3COMMANDER or BBC.BUILTBYTIER3ENGINEER then
            NeedTech = 3
        end
        -- If we can't find a techlevel for the building we want to build, then return
        if not NeedTech then
            WARN('*AIExecuteBuildStructure: Can\'t find techlevel for BuildUnitWithID: '..repr(BuildUnitWithID))
            return false
        else
            SPEW('*AIExecuteBuildStructure: Need engineer with Techlevel ('..NeedTech..') for BuildUnitWithID: '..repr(BuildUnitWithID))
        end
        -- get the actual tech level from the builder
        local BC = builder:GetBlueprint().CategoriesHash
        if BC.TECH1 or BC.COMMAND then
            HasTech = 1
        elseif BC.TECH2 then
            HasTech = 2
        elseif BC.TECH3 then
            HasTech = 3
        end
        -- If we can't find a techlevel for the building we  want to build, return
        if not HasTech then
            WARN('*AIExecuteBuildStructure: Can\'t find techlevel for engineer: '..repr(builder:GetBlueprint().BlueprintId))
            return false
        else
            SPEW('*AIExecuteBuildStructure: Engineer ('..repr(builder:GetBlueprint().BlueprintId)..') has Techlevel ('..HasTech..')')
        end

        if HasTech < NeedTech then
            WARN('*AIExecuteBuildStructure: TECH'..HasTech..' Unit "'..BuildUnitWithID..'" is assigned to build TECH'..NeedTech..' buildplatoon! ('..repr(buildingType)..')')
            return false
        else
            SPEW('*AIExecuteBuildStructure: Engineer with Techlevel ('..HasTech..') can build TECH'..NeedTech..' BuildUnitWithID: '..repr(BuildUnitWithID))
        end
      
        HasFaction = builder.factionCategory
        NeedFaction = string.upper(__blueprints[string.lower(BuildUnitWithID)].General.FactionName)
        if HasFaction ~= NeedFaction then
            WARN('*AIExecuteBuildStructure: AI-faction: '..AIFactionName..', ('..HasFaction..') engineers can\'t build ('..NeedFaction..') structures!')
            return false
        else
            SPEW('*AIExecuteBuildStructure: AI-faction: '..AIFactionName..', Engineer with faction ('..HasFaction..') can build faction ('..NeedFaction..') - BuildUnitWithID: '..repr(BuildUnitWithID))
        end
       
        local IsRestricted = import('/lua/game.lua').IsRestricted
        if IsRestricted(BuildUnitWithID, GetFocusArmy()) then
            WARN('*AIExecuteBuildStructure: Unit is Restricted!!! Building Type: '..repr(buildingType)..', faction: '..repr(builder.factionCategory)..' - Unit:'..BuildUnitWithID)
            AntiSpamList[buildingType] = true
            return false
        end

        WARN('*AIExecuteBuildStructure: All checks passed, forcing enginner TECH'..HasTech..' '..HasFaction..' '..builder:GetBlueprint().BlueprintId..' to build TECH'..NeedTech..' '..buildingType..' '..BuildUnitWithID..'')
        whatToBuild = BuildUnitWithID
        --return false
    else
        -- Sometimes the AI is building a unit that is different from the buildingTemplate table. So we validate the unitID here.
        -- Looks like it never occurred, or i missed the warntext. For now, we don't need it
        for Key, Data in buildingTemplate do
            if Data[1] and Data[2] and Data[1] == buildingType then
                if whatToBuild ~= Data[2] then
                    WARN('*AIExecuteBuildStructure: Missmatch whatToBuild: '..whatToBuild..' ~= buildingTemplate.Data[2]: '..repr(Data[2]))
                    whatToBuild = Data[2]
                end
                break
            end
        end
    end
    -- find a place to build it (ignore enemy locations if it's a resource)
    -- build near the base the engineer is part of, rather than the engineer location
    local relativeTo
    if closeToBuilder then
        relativeTo = builder:GetPosition()
        --LOG('*AIExecuteBuildStructure: Searching for Buildplace near Engineer'..repr(relativeTo))
    else
        if builder.BuilderManagerData and builder.BuilderManagerData.EngineerManager then
            relativeTo = builder.BuilderManagerData.EngineerManager.Location
            --LOG('*AIExecuteBuildStructure: Searching for Buildplace near BuilderManager ')
        else
            local startPosX, startPosZ = aiBrain:GetArmyStartPos()
            relativeTo = {startPosX, 0, startPosZ}
            --LOG('*AIExecuteBuildStructure: Searching for Buildplace near ArmyStartPos ')
        end
    end
    local location = false
    local buildingTypeReplace
    local whatToBuildReplace

    -- if we wnat to build a factory use the Seraphim Awassa for a bigger build place
    if buildingType == 'T1LandFactory' or buildingType == 'T1AirFactory' then
        buildingTypeReplace = 'T4AirExperimental1'
        whatToBuildReplace = 'xsa0402'
    elseif buildingType == 'T1SeaFactory' then
        buildingTypeReplace = 'T4SeaExperimental1'
        whatToBuildReplace = 'ues0401'
    end

    if IsResource(buildingType) then
        
        local constructionData = builder.PlatoonHandle.PlatoonData.Construction

        --location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, baseTemplate, relative, closeToBuilder, 'Enemy', relativeTo[1], relativeTo[3], 5)
        -- OK - Here is an important piece of code particularily for Engineers building Mass Extractors
		-- Notice the final parameter ?  It's supposed to tell the command to ignore places with threat greater than that
		-- If so -- it has no specific range or threat types associated with it - which means we have no idea what it's measuring
		-- Most certainly it won't be related to any threat check we do elsewhere in our code - as far as I can tell.
		-- The biggest result - ENGINEERS GO WANDERING INTO HARMS WAY FREQUENTLY -- I'm going to try various values
		-- I am now passing along the engineers ThreatMax from his platoon (if it's there)
        --location = aiBrain:FindPlaceToBuild( buildingType, whatToBuild, baseTemplate, relative, engineer, 'Enemy', SourcePosition[1], SourcePosition[3], constructionData.ThreatMax or 7.5)	
    
        local AIUtils = '/lua/ai/aiutilities.lua'

        local testunit = 'ueb1102'  -- Hydrocarbon
        local testtype = 'Hydrocarbon'
        
        if buildingType != 'T1HydroCarbon' then
            testunit = 'ueb1103'    -- Extractor
            testtype = 'Mass'
        end

        --LOG("*AI DEBUG: Data is " .. repr(testtype) .. " " .. repr(constructionData))
		local markerlist = import(AIUtils).AIGetMarkerLocations(aiBrain, testtype)
        --LOG("*AI DEBUG: BuilderManagers Location is " .. repr(builder.BuilderManagerData.LocationType))
        local SourcePosition = aiBrain.BuilderManagers[builder.BuilderManagerData.LocationType].Position or false
        
		local mlist = {}
		local counter = 0
        
        local mindistance = constructionData.MinRange or 0
        local maxdistance = constructionData.MaxRange or 500
        local tMin = constructionData.ThreatMin or 0
        local tMax = constructionData.ThreatMax or 20
        local tRings = constructionData.ThreatRings or 0
        local tType = constructionData.ThreatType or 'AntiSurface'
        local maxlist = constructionData.MaxChoices or 1

        --LOG("SourcePosition is " .. repr(SourcePosition))
        SWARMSORT( markerlist, function (a,b) return VDist3( a.Position, SourcePosition ) < VDist3( b.Position, SourcePosition ) end )

		local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt    
        --LOG("*AI DEBUG: Markerlist is " .. repr(markerlist))
    
		for _,v in markerlist do
            
            if VDist3( v.Position, SourcePosition ) >= mindistance then
            
                if VDist3( v.Position, SourcePosition ) <= maxdistance then
                
                    if CanBuildStructureAt( aiBrain, testunit, v.Position ) then
                        mlist[counter] = v
                        counter = counter + 1
                    end
                    
                end
                
            end
            
		end
		
		if counter > 0 then
            
			local markerTable = import(AIUtils).AISortMarkersFromLastPos(aiBrain, mlist, maxlist, tMin, tMax, tRings, tType, SourcePosition)

			if markerTable then
            
                --LOG("*AI DEBUG "..aiBrain.Nickname.." finds "..table.getn(markerTable).." "..repr(buildingType).." markers")

                -- pick one of the points randomly
				location = SWARMCOPY( markerTable[ Random(1,SWARMGETN(markerTable)) ] )
                --LOG("*AI DEBUG at marker is " .. aiBrain:GetThreatAtPosition(location, tRings, true, 'AntiSurface'))
            end
		end	

        -- if no result or out of range - then abort
		if not location or VDist3( SourcePosition, location ) > constructionData.MaxRange then
        
			builder.PlatoonHandle:SetAIPlan('ReturnToBaseAI', aiBrain)
            
            location = false
            
		end

        if location then
 	
            relativeLoc = { location[1], 0, location[3] }

            relative = false
        
            location = {relativeLoc[1],relativeLoc[3]}
        
            if constructionData.RepeatBuild then
            
                -- loop builders have minimum range to start with
                -- reduced after first build
                constructionData.MinRange = 0
            end
            
		end 
        --location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, baseTemplate, relative, closeToBuilder, 'Enemy', relativeTo[1], relativeTo[3], 5)
    else
        location = aiBrain:FindPlaceToBuild(buildingTypeReplace or buildingType, whatToBuildReplace or whatToBuild, baseTemplate, relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
    end

    -- if it's a reference, look around with offsets
    if not location and reference then
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild(buildingTypeReplace or buildingType, whatToBuildReplace or whatToBuild, BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                break
            end
        end
    end

    -- fallback in case we can't find a place to build with experimental template
    if not location and not IsResource(buildingType) then
        location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, baseTemplate, relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
    end

    -- fallback in case we can't find a place to build with experimental template
    if not location and not IsResource(buildingType) then
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild(buildingType, whatToBuild, BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                break
            end
        end
    end

    -- if we have no place to build, then maybe we have a modded/new buildingType. Lets try 'T1LandFactory' as dummy and search for a place to build near base
    if not location and not IsResource(buildingType) and builder.BuilderManagerData and builder.BuilderManagerData.EngineerManager then
        --LOG('*AIExecuteBuildStructure: Find no place to Build! - buildingType '..repr(buildingType)..' - ('..builder.factionCategory..') Trying again with T1LandFactory and RandomIter. Searching near base...')
        relativeTo = builder.BuilderManagerData.EngineerManager.Location
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild('T1LandFactory', 'ueb0101', BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                --LOG('*AIExecuteBuildStructure: Yes! Found a place near base to Build! - buildingType '..repr(buildingType))
                break
            end
        end
    end

    -- if we still have no place to build, then maybe we have really no place near the base to build. Lets search near engineer position
    if not location and not IsResource(buildingType) then
        --LOG('*AIExecuteBuildStructure: Find still no place to Build! - buildingType '..repr(buildingType)..' - ('..builder.factionCategory..') Trying again with T1LandFactory and RandomIter. Searching near Engineer...')
        relativeTo = builder:GetPosition()
        for num,offsetCheck in RandomIter({1,2,3,4,5,6,7,8}) do
            location = aiBrain:FindPlaceToBuild('T1LandFactory', 'ueb0101', BaseTmplFile['MovedTemplates'..offsetCheck][factionIndex], relative, closeToBuilder, nil, relativeTo[1], relativeTo[3])
            if location then
                --LOG('*AIExecuteBuildStructure: Yes! Found a place near engineer to Build! - buildingType '..repr(buildingType))
                break
            end
        end
    end

    -- if we have a location, build!
    if location then
        local relativeLoc = BuildToNormalLocation(location)
        if relative then
            relativeLoc = {relativeLoc[1] + relativeTo[1], relativeLoc[2] + relativeTo[2], relativeLoc[3] + relativeTo[3]}
        end
        -- put in build queue.. but will be removed afterwards... just so that it can iteratively find new spots to build
        --LOG('*AIExecuteBuildStructure: AI-faction: index('..factionIndex..') '..repr(AIFactionName)..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(builder.factionCategory))
        AddToBuildQueue(aiBrain, builder, whatToBuild, NormalToBuildLocation(relativeLoc), false)
        return true
    end
    -- At this point we're out of options, so move on to the next thing
    --WARN('*AIExecuteBuildStructure: c-function FindPlaceToBuild() failed! AI-faction: index('..factionIndex..') '..repr(AIFactionName)..', Building Type: '..repr(buildingType)..', engineer-faction: '..repr(builder.factionCategory))
    return false
end