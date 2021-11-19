local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt

local LastGetMassMarker = 0
local LastCheckMassMarker = {}
local MassMarker = {}
local LastMassBOOL = false
function CanBuildOnMassDistanceSwarm(aiBrain, locationType, minDistance, maxDistance, threatMin, threatMax, threatRings, threatType, maxNum )
    if LastGetMassMarker < GetGameTimeSeconds() then
        LastGetMassMarker = GetGameTimeSeconds()+5
        local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
        if not engineerManager then
            --WARN('*AI WARNING: CanBuildOnMass: Invalid location - ' .. locationType)
            return false
        end
        local position = engineerManager.Location
        MassMarker = {}
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    -- mass marker is too close to border, skip it.
                    continue
                end 
                table.insert(MassMarker, {Position = v.position, Distance = VDist3( v.position, position ) })
            end
        end
        table.sort(MassMarker, function(a,b) return a.Distance < b.Distance end)
    end
    if not LastCheckMassMarker[maxDistance] or LastCheckMassMarker[maxDistance] < GetGameTimeSeconds() then
        LastCheckMassMarker[maxDistance] = GetGameTimeSeconds()
        local threatCheck = false
        if threatMin and threatMax and threatRings then
            threatCheck = true
        end
        LastMassBOOL = false
        for _, v in MassMarker do
            if v.Distance < minDistance then
                continue
            elseif v.Distance > maxDistance then
                break
            end
            --LOG(_..'Checking marker with max maxDistance ['..maxDistance..'] minDistance ['..minDistance..'] . Actual marker has distance: ('..(v.Distance)..').')
            if CanBuildStructureAt(aiBrain, 'ueb1103', v.Position) then
                if threatCheck then
                    threat = aiBrain:GetThreatAtPosition(v.Position, threatRings, true, threatType or 'Overall')
                    if threat <= threatMin or threat >= threatMax then
                        continue
                    end
                end
                --LOG('Returning MassMarkerDistance True')
                LastMassBOOL = true
                break
            end
        end
    end
    return LastMassBOOL
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

function CanBuildOnMassEngSwarm(aiBrain, engPos, distance)
    local MassMarker = {}
    for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                -- mass marker is too close to border, skip it.
                continue
            end 
            local mexDistance = VDist3( v.position, engPos )
            if mexDistance < distance and CanBuildStructureAt(aiBrain, 'ueb1103', v.position) then
                --LOG('mexDistance '..mexDistance)
                table.insert(MassMarker, {Position = v.position, Distance = mexDistance , MassSpot = v})
            end
        end
    end
    table.sort(MassMarker, function(a,b) return a.Distance < b.Distance end)
    if table.getn(MassMarker) > 0 then
        return true, MassMarker
    else
        return false
    end
end

