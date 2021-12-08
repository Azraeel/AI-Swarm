local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt
local SLastGetMassMarker = 0
local SLastCheckMassMarker = {}
local SMassMarker = {}
local SLastMassBOOL = false
local SLastGetSHydroMarker = 0
local SHydroMarker = {}
local SLastHydroBOOL = false

function CanBuildOnMassDistanceSwarm(aiBrain, locationType, minDistance, maxDistance, threatMin, threatMax, threatRings, threatType, maxNum )
    if SLastGetMassMarker < GetGameTimeSeconds() then
        SLastGetMassMarker = GetGameTimeSeconds()+5
        local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
        if not engineerManager then
            --WARN('*AI WARNING: CanBuildOnMass: Invalid location - ' .. locationType)
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
                table.insert(SMassMarker, {Position = v.position, Distance = VDist3( v.position, position ) })
            end
        end
        table.sort(SMassMarker, function(a,b) return a.Distance < b.Distance end)
    end
    if not SLastCheckMassMarker[maxDistance] or SLastCheckMassMarker[maxDistance] < GetGameTimeSeconds() then
        SLastCheckMassMarker[maxDistance] = GetGameTimeSeconds()
        local threatCheck = false
        if threatMin and threatMax and threatRings then
            threatCheck = true
        end
        SLastMassBOOL = false
        for _, v in SMassMarker do
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
                SLastMassBOOL = true
                break
            end
        end
    end
    return SLastMassBOOL
end

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

function CanBuildOnMassEngSwarm(aiBrain, engPos, distance)
    local SMassMarker = {}
    for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                -- mass marker is too close to border, skip it.
                continue
            end 
            local mexDistance = VDist3( v.position, engPos )
            if mexDistance < distance and CanBuildStructureAt(aiBrain, 'ueb1103', v.position) then
                --LOG('mexDistance '..mexDistance)
                table.insert(SMassMarker, {Position = v.position, Distance = mexDistance , MassSpot = v})
            end
        end
    end
    table.sort(SMassMarker, function(a,b) return a.Distance < b.Distance end)
    if table.getn(SMassMarker) > 0 then
        return true, SMassMarker
    else
        return false
    end
end

