
local SLastGetSMassMarker = 0
local SMassMarker = {}
local SLastMassBOOL = false
function CanBuildOnMassSwarm(aiBrain, locationType, distance, threatMin, threatMax, threatRings, threatType, maxNum )
    if SLastGetSMassMarker < GetGameTimeSeconds() then
        SLastGetSMassMarker = GetGameTimeSeconds()+10
        local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
        if not engineerManager then
            --WARN('*AI WARNING: CanBuildOnMassSwarm: Invalid location - ' .. locationType)
            return false
        end
        local position = engineerManager.Location
        SMassMarker = {}
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    -- mass marker is too close to border, skip it.
                    continue
                end 
                table.insert(SMassMarker, {Position = v.position, Distance = VDist2( v.position[1], v.position[3], position[1], position[3] ) })
            end
        end
        table.sort(SMassMarker, function(a,b) return a.Distance < b.Distance end)
    end
    local threatCheck = false
    if threatMin and threatMax and threatRings then
        threatCheck = true
    end
    SLastMassBOOL = false
    for _, v in SMassMarker do
        if aiBrain:CanBuildStructureAt('ueb1103', v.Position) then
            if threatCheck then
                threat = aiBrain:GetThreatAtPosition(v.Position, threatRings, true, threatType or 'Overall')
                if threat < threatMin or threat > threatMax then
                    continue
                end
            end
            SLastMassBOOL = true
            break
        end
    end
    return SLastMassBOOL
end

local SLastGetSHydroMarker = 0
local SHydroMarker = {}
local SLastHydroBOOL = false
--                { MABC, 'CanBuildOnHydroSwarm', { 'LocationType', 1000, -1000, 100, 1, 'AntiSurface', 1 }},
function CanBuildOnHydroSwarm(aiBrain, locationType, distance, threatMin, threatMax, threatRings, threatType, maxNum)
    if SLastGetSHydroMarker < GetGameTimeSeconds() then
        SLastGetSHydroMarker = GetGameTimeSeconds()+10
        local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
        if not engineerManager then
            --WARN('*AI WARNING: CanBuildOnHydroSwarm: Invalid location - ' .. locationType)
            return false
        end
        local position = engineerManager.Location
        SHydroMarker = {}
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Hydrocarbon' then
                table.insert(SHydroMarker, {Position = v.position, Distance = VDist2( v.position[1], v.position[3], position[1], position[3] ) })
            end
        end
        table.sort(SHydroMarker, function(a,b) return a.Distance < b.Distance end)
    end
    local threatCheck = false
    if threatMin and threatMax and threatRings then
        threatCheck = true
    end
    SLastHydroBOOL = false
    for _, v in SHydroMarker do
        if aiBrain:CanBuildStructureAt('ueb1102', v.Position) then
            if threatCheck then
                threat = aiBrain:GetThreatAtPosition(v.Position, threatRings, true, threatType or 'Overall')
                if threat < threatMin or threat > threatMax then
                    continue
                end
            end
            SLastHydroBOOL = true
            break
        end
    end
    return SLastHydroBOOL
end

function CanBuildOnMassLessThanDistanceSwarm(aiBrain, locationType, distance, threatMin, threatMax, threatRings, threatType, maxNum )
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not engineerManager then
        --WARN('*AI WARNING: Invalid location - ' .. locationType)
        return false
    end
    local position = engineerManager.Location
    
    local markerTable = AIUtils.AIGetSortedMassLocations(aiBrain, maxNum, threatMin, threatMax, threatRings, threatType, position)
    positionThreat = aiBrain:GetThreatAtPosition( position, threatRings, true, threatType or 'Overall' )
    if positionThreat > threatMax then
        --LOG('Mass Build at distance :'..distance)
        --LOG('Threat at position :'..positionThreat)
    end
    if markerTable[1] and VDist3( markerTable[1], position ) < distance then
        local dist = VDist3( markerTable[1], position )
        return true
    end
    return false
end

