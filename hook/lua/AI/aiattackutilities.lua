local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions

local SWARMINSERT = table.insert
local SWARMGETN = table.getn
local SWARMREMOVE = table.remove
local SWARMSORT = table.sort
local SWARMPOW = math.pow
local SWARMSQRT = math.sqrt
local SWARMFLOOR = math.floor
local SWARMCEIL = math.ceil
local SWARMPI = math.pi
local SWARMCAT = table.cat
local SWARMWAIT = coroutine.yield

local VDist2Sq = VDist2Sq

-- Swarm Functions
function CanGraphAreaTo_OLD(startPos, destPos, layer)
    local startNode = GetClosestPathNodeInRadiusByLayer(startPos, 100, layer)
    local endNode = false
    if startNode then
        endNode = GetClosestPathNodeInRadiusByLayer(destPos, 100, layer)
    end
    --WARN('* AI-Swarm: CanGraphAreaTo: Start Area: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[startNode.name].GraphArea)..' - End Area: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[endNode.name].GraphArea)..'')
    if Scenario.MasterChain._MASTERCHAIN_.Markers[startNode.name].GraphArea == Scenario.MasterChain._MASTERCHAIN_.Markers[endNode.name].GraphArea then
        return true
    end
    return false
end

function CanGraphAreaTo(startPos, destPos, layer)
    local graphTable = GetPathGraphs()[layer]
    local startNode, endNode, distS, distE
    local bestDistS, bestDistE = 100, 100 -- will only find markers that are closer than 100 map units
    if graphTable then
        for mn, markerInfo in graphTable['Default'..layer] do
            distS = VDist2Sq(startPos[1], startPos[3], markerInfo.position[1], markerInfo.position[3])
            distE = VDist2Sq(destPos[1], destPos[3], markerInfo.position[1], markerInfo.position[3])
            if distS < bestDistS then
                bestDistS = distS
                startNode = markerInfo.name
            end
            if distE < bestDistE then
                bestDistE = distE
                endNode = markerInfo.name
            end
            if bestDistS == 0 and bestDistE == 0 then
                break
            end
        end
    end
    --WARN('* AI-Swarm: CanGraphAreaTo: Start Area: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[startNode.name].GraphArea)..' - End Area: '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[endNode.name].GraphArea)..'')
    if startNode and endNode and Scenario.MasterChain._MASTERCHAIN_.Markers[startNode].GraphArea == Scenario.MasterChain._MASTERCHAIN_.Markers[endNode].GraphArea then
        return true
    end
    return false
end

function GetPathGraphsSwarm()
    if ScenarioInfo.PathGraphsSwarm then
        return ScenarioInfo.PathGraphsSwarm
    else
        ScenarioInfo.PathGraphsSwarm = {}
    end

    local markerGroups = {
        Land = AIUtils.AIGetMarkerLocationsEx(nil, 'Land Path Node') or {},
        Water = AIUtils.AIGetMarkerLocationsEx(nil, 'Water Path Node') or {},
        Air = AIUtils.AIGetMarkerLocationsEx(nil, 'Air Path Node') or {},
        Amphibious = AIUtils.AIGetMarkerLocationsEx(nil, 'Amphibious Path Node') or {},
    }

    for gk, markerGroup in markerGroups do
        for mk, marker in markerGroup do
            --Create stuff if it doesn't exist
            ScenarioInfo.PathGraphsSwarm[gk] = ScenarioInfo.PathGraphsSwarm[gk] or {}
            ScenarioInfo.PathGraphsSwarm[gk][marker.graph] = ScenarioInfo.PathGraphsSwarm[gk][marker.graph] or {}
            -- If the marker has no adjacentTo then don't use it. We can't build a path with this node.
            if not (marker.adjacentTo) then
                WARN('*AI DEBUG: GetPathGraphs(): Path Node '..marker.name..' has no adjacentTo entry!')
                continue
            end
            --Add the marker to the graph.
            ScenarioInfo.PathGraphsSwarm[gk][marker.graph][marker.name] = {name = marker.name, layer = gk, graphName = marker.graph, position = marker.position, SwarmArea = marker.SwarmArea, adjacent = STR_GetTokens(marker.adjacentTo, ' '), color = marker.color}
        end
    end

    return ScenarioInfo.PathGraphsSwarm or {}
end

function GetClosestPathNodeInRadiusByLayerSwarm(location, radius, layer)

    local bestDist = radius*radius
    local bestMarker = false

    local graphTable =  GetPathGraphsSwarm()[layer]

    if graphTable then
        for name, graph in graphTable do
            for mn, markerInfo in graph do
                local dist2 = VDist2Sq(location[1], location[3], markerInfo.position[1], markerInfo.position[3])

                if dist2 < bestDist then
                    bestDist = dist2
                    bestMarker = markerInfo
                end
            end
        end
    end

    return bestMarker
end

function GetClosestPathNodeInRadiusByGraphSwarm(location, radius, graphName)
    local bestDist = radius*radius
    local bestMarker = false

    for graphLayer, graphTable in GetPathGraphsSwarm() do
        for name, graph in graphTable do
            if graphName == name then
                for mn, markerInfo in graph do
                    local dist2 = VDist2Sq(location[1], location[3], markerInfo.position[1], markerInfo.position[3])

                    if dist2 < bestDist then
                        bestDist = dist2
                        bestMarker = markerInfo
                    end
                end
            end
        end
    end

    return bestMarker
end

function CanGraphToSwarm(startPos, destPos, layer)
    local startNode = GetClosestPathNodeInRadiusByLayerSwarm(startPos, 100, layer)
    local endNode = false

    if startNode then
        endNode = GetClosestPathNodeInRadiusByGraphSwarm(destPos, 100, startNode.graphName)
    end

    if endNode then
        if startNode.SwarmArea == endNode.SwarmArea then
            --LOG('CanGraphToIsTrue for area '..startNode.SwarmArea)
            return true, endNode.Position
        else
            --LOG('CanGraphToIsFalse for start area '..startNode.SwarmArea..' and end area of '..endNode.SwarmArea)
        end
    end
    return false
end

-- Huge Credit to Relent0r for EngineerGenerateSafePathToSwarm & EngineerGeneratePathSwarm!
function EngineerGenerateSafePathToSwarm(aiBrain, platoonLayer, startPos, endPos, optThreatWeight, optMaxMarkerDist)
    local VDist2Sq = VDist2Sq
    if not GetPathGraphs()[platoonLayer] then
        return false, 'NoGraph'
    end

    --Get the closest path node at the platoon's position
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    local startNode
    startNode = GetClosestPathNodeInRadiusByLayer(startPos, optMaxMarkerDist, platoonLayer)
    if not startNode then return false, 'NoStartNode' end

    --Get the matching path node at the destiantion
    local endNode = GetClosestPathNodeInRadiusByGraph(endPos, optMaxMarkerDist, startNode.graphName)
    if not endNode then return false, 'NoEndNode' end

    --Generate the safest path between the start and destination
    local path = EngineerGeneratePathSwarm(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, endPos, startPos)
    if not path then return false, 'NoPath' end

    -- Insert the path nodes (minus the start node and end nodes, which are close enough to our start and destination) into our command queue.
    -- delete the first and last node only if they are very near (under 30 map units) to the start or end destination.
    local finalPath = {}
    local NodeCount = SWARMGETN(path.path)
    for i,node in path.path do
        -- IF this is the first AND not the only waypoint AND its nearer 30 THEN continue and don't add it to the finalpath
        if i == 1 and NodeCount > 1 and VDist2Sq(startPos[1], startPos[3], node.position[1], node.position[3]) < 900 then  
            continue
        end
        -- IF this is the last AND not the only waypoint AND its nearer 20 THEN continue and don't add it to the finalpath
        if i == NodeCount and NodeCount > 1 and VDist2Sq(endPos[1], endPos[3], node.position[1], node.position[3]) < 400 then  
            continue
        end
        SWARMINSERT(finalPath, node.position)
    end

    -- return the path
    return finalPath, 'PathOK'
end

function EngineerGeneratePathSwarm(aiBrain, startNode, endNode, threatType, threatWeight, endPos, startPos, platoonLayer)
    threatWeight = threatWeight or 1
    -- Check if we have this path already cached.
    if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path then
        -- Path is not older then 30 seconds. Is it a bad path? (the path is too dangerous)
        if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path == 'bad' then
            -- We can't move this way at the moment. Too dangerous.
            return false
        else
            -- The cached path is newer then 30 seconds and not bad. Sounds good :) use it.
            return aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path
        end
    end
    -- loop over all path's and remove any path from the cache table that is older then 30 seconds
    if aiBrain.PathCache then
        local GameTime = GetGameTimeSeconds()
        -- loop over all cached paths
        for StartNodeName, CachedPaths in aiBrain.PathCache do
            -- loop over all paths starting from StartNode
            for EndNodeName, ThreatWeightedPaths in CachedPaths do
                -- loop over every path from StartNode to EndNode stored by ThreatWeight
                for ThreatWeight, PathNodes in ThreatWeightedPaths do
                    -- check if the path is older then 30 seconds.
                    if GameTime - 30 > PathNodes.settime then
                        --LOG('* AI-Swarm: GeneratePathSwarm() Found old path: storetime: '..PathNodes.settime..' store+60sec: '..(PathNodes.settime + 30)..' actual time: '..GameTime..' timediff= '..(PathNodes.settime + 30 - GameTime) )
                        -- delete the old path from the cache.
                        aiBrain.PathCache[StartNodeName][EndNodeName][ThreatWeight] = nil
                    end
                end
            end
        end
    end
    -- We don't have a path that is newer then 30 seconds. Let's generate a new one.
    --Create path cache table. Paths are stored in this table and saved for 30 seconds, so
    --any other platoons needing to travel the same route can get the path without any extra work.
    aiBrain.PathCache = aiBrain.PathCache or {}
    aiBrain.PathCache[startNode.name] = aiBrain.PathCache[startNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name] = aiBrain.PathCache[startNode.name][endNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = {}
    local fork = {}
    -- Is the Start and End node the same OR is the distance to the first node longer then to the destination ?
    if startNode.name == endNode.name
    or VDist2Sq(startPos[1], startPos[3], startNode.position[1], startNode.position[3]) > VDist2Sq(startPos[1], startPos[3], endPos[1], endPos[3])
    or VDist2Sq(startPos[1], startPos[3], endPos[1], endPos[3]) < 2500 then
        -- store as path only our current destination.
        fork.path = { { position = endPos } }
        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = fork }
        -- return the destination position as path
        return fork
    end
    -- Set up local variables for our path search
    local AlreadyChecked = {}
    local curPath = {}
    local lastNode = {}
    local newNode = {}
    local dist = 0
    local threat = 0
    local lowestpathkey = 1
    local lowestcost
    local tableindex = 0
    local armyIndex = aiBrain:GetArmyIndex()
    -- Get all the waypoints that are from the same movementlayer than the start point.
    local graph = GetPathGraphs()[startNode.layer][startNode.graphName]
    -- For the beginning we store the startNode here as first path node.
    local queue = {
        {
        cost = 0,
        path = {startNode},
        }
    }
    -- Now loop over all path's that are stored in queue. If we start, only the startNode is inside the queue
    -- (We are using here the "A*(Star) search algorithm". An extension of "Edsger Dijkstra's" pathfinding algorithm used by "Shakey the Robot" in 1959)
    while true do
        -- remove the table (shortest path) from the queue table and store the removed table in curPath
        -- (We remove the path from the queue here because if we don't find a adjacent marker and we
        --  have not reached the destination, then we no longer need this path. It's a dead end.)
        curPath = SWARMREMOVE(queue,lowestpathkey)
        if not curPath then break end
        -- get the last node from the path, so we can check adjacent waypoints
        lastNode = curPath.path[SWARMGETN(curPath.path)]
        -- Have we already checked this node for adjacenties ? then continue to the next node.
        if not AlreadyChecked[lastNode] then
            -- Check every node (marker) inside lastNode.adjacent
            for i, adjacentNode in lastNode.adjacent do
                -- get the node data from the graph table
                newNode = graph[adjacentNode]
                -- check, if we have found a node.
                if newNode then
                    -- copy the path from the startNode to the lastNode inside fork,
                    -- so we can add a new marker at the end and make a new path with it
                    fork = {
                        cost = curPath.cost,            -- cost from the startNode to the lastNode
                        path = {unpack(curPath.path)},  -- copy full path from starnode to the lastNode
                    }
                    -- get distance from new node to destination node
                    dist = VDist2(newNode.position[1], newNode.position[3], lastNode.position[1], lastNode.position[3])
                    -- get threat from current node to adjacent node
                    -- threat = Scenario.MasterChain._MASTERCHAIN_.Markers[newNode.name][armyIndex] or 0
                    local threat = aiBrain:GetThreatBetweenPositions(newNode.position, lastNode.position, nil, threatType)
                    -- add as cost for the path the path distance and threat to the overall cost from the whole path
                    fork.cost = fork.cost + dist + (threat * 1) * threatWeight
                    -- add the newNode at the end of the path
                    SWARMINSERT(fork.path, newNode)
                    -- check if we have reached our destination
                    if newNode.name == endNode.name then
                        -- store the path inside the path cache
                        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = fork }
                        -- return the path
                        return fork
                    end
                    -- add the path to the queue, so we can check the adjacent nodes on the last added newNode
                    SWARMINSERT(queue,fork)
                end
            end
            -- Mark this node as checked
            AlreadyChecked[lastNode] = true
        end
        -- Search for the shortest / safest path and store the table key in lowestpathkey
        lowestcost = 100000000
        lowestpathkey = 1
        tableindex = 1
        while queue[tableindex].cost do
            if lowestcost > queue[tableindex].cost then
                lowestcost = queue[tableindex].cost
                lowestpathkey = tableindex
            end
            tableindex = tableindex + 1
        end
    end
    -- At this point we have not found any path to the destination.
    -- The path is to dangerous at the moment (or there is no path at all). We will check this again in 30 seconds.
    aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = 'bad' }
    return false
end


--PlatoonGenerateSafePathToSwarm(aiBrain, self.MovementLayer or 'Land' , PlatoonPosition, TargetPosition, 1000, 512)
function PlatoonGenerateSafePathToSwarm(aiBrain, platoonLayer, start, destination, optThreatWeight, optMaxMarkerDist, testPathDist)
    -- if we don't have markers for the platoonLayer, then we can't build a path.
    if not GetPathGraphs()[platoonLayer] then
        return false, 'NoGraph'
    end
    local location = start
    optMaxMarkerDist = optMaxMarkerDist or 250
    optThreatWeight = optThreatWeight or 1
    local finalPath = {}

    --If we are within 100 units of the destination, don't bother pathing. (Sorian and Duncan AI)
    if (aiBrain.Sorian or aiBrain.Duncan) and (VDist2Sq(start[1], start[3], destination[1], destination[3]) <= 10000
    or (testPathDist and VDist2Sq(start[1], start[3], destination[1], destination[3]) <= testPathDist)) then
        SWARMINSERT(finalPath, destination)
        return finalPath
    end

    --Get the closest path node at the platoon's position
    local startNode

    startNode = GetClosestPathNodeInRadiusByLayer(location, optMaxMarkerDist, platoonLayer)
    if not startNode then return false, 'NoStartNode' end

    --Get the matching path node at the destiantion
    local endNode

    endNode = GetClosestPathNodeInRadiusByGraph(destination, optMaxMarkerDist, startNode.graphName)
    if not endNode then return false, 'NoEndNode' end

    --Generate the safest path between the start and destination
    local path
    path = GeneratePathSwarm(aiBrain, startNode, endNode, ThreatTable[platoonLayer], optThreatWeight, destination, location, platoonLayer)

    if not path then return false, 'NoPath' end
    -- Insert the path nodes (minus the start node and end nodes, which are close enough to our start and destination) into our command queue.
    for i,node in path.path do
        if i > 1 and i < SWARMGETN(path.path) then
            SWARMINSERT(finalPath, node.position)
        end
    end

    SWARMINSERT(finalPath, destination)

    return finalPath, false, path.totalThreat
end

function GeneratePathSwarm(aiBrain, startNode, endNode, threatType, threatWeight, endPos, startPos, platoonLayer)
    local VDist2 = VDist2
    threatWeight = threatWeight or 1
    -- Check if we have this path already cached.
    if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path then
        -- Path is not older then 30 seconds. Is it a bad path? (the path is too dangerous)
        if aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path == 'bad' then
            -- We can't move this way at the moment. Too dangerous.
            return false
        else
            -- The cached path is newer then 30 seconds and not bad. Sounds good :) use it.
            return aiBrain.PathCache[startNode.name][endNode.name][threatWeight].path
        end
    end
    -- loop over all path's and remove any path from the cache table that is older then 30 seconds
    if aiBrain.PathCache then
        local GameTime = GetGameTimeSeconds()
        -- loop over all cached paths
        for StartNodeName, CachedPaths in aiBrain.PathCache do
            -- loop over all paths starting from StartNode
            for EndNodeName, ThreatWeightedPaths in CachedPaths do
                -- loop over every path from StartNode to EndNode stored by ThreatWeight
                for ThreatWeight, PathNodes in ThreatWeightedPaths do
                    -- check if the path is older then 30 seconds.
                    if GameTime - 30 > PathNodes.settime then
                        -- delete the old path from the cache.
                        aiBrain.PathCache[StartNodeName][EndNodeName][ThreatWeight] = nil
                    end
                end
            end
        end
    end
    -- We don't have a path that is newer then 30 seconds. Let's generate a new one.
    --Create path cache table. Paths are stored in this table and saved for 30 seconds, so
    --any other platoons needing to travel the same route can get the path without any extra work.
    aiBrain.PathCache = aiBrain.PathCache or {}
    aiBrain.PathCache[startNode.name] = aiBrain.PathCache[startNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name] = aiBrain.PathCache[startNode.name][endNode.name] or {}
    aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = {}
    local fork = {}
    -- Is the Start and End node the same OR is the distance to the first node longer then to the destination ?
    if startNode.name == endNode.name
    or VDist2(startPos[1], startPos[3], startNode.position[1], startNode.position[3]) > VDist2(startPos[1], startPos[3], endPos[1], endPos[3])
    or VDist2(startPos[1], startPos[3], endPos[1], endPos[3]) < 50 then
        -- store as path only our current destination.
        fork.path = { { position = endPos } }
        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = fork }
        -- return the destination position as path
        return fork
    end
    -- Set up local variables for our path search
    local AlreadyChecked = {}
    local curPath = {}
    local lastNode = {}
    local newNode = {}
    local dist = 0
    local threat = 0
    local lowestpathkey = 1
    local lowestcost
    local tableindex = 0
    local mapSizeX = ScenarioInfo.size[1]
    local mapSizeZ = ScenarioInfo.size[2]
    -- Get all the waypoints that are from the same movementlayer than the start point.
    local graph = GetPathGraphs()[startNode.layer][startNode.graphName]
    -- For the beginning we store the startNode here as first path node.
    local queue = {
        {
        cost = 0,
        path = {startNode},
        totalThreat = 0
        }
    }
    -- Now loop over all path's that are stored in queue. If we start, only the startNode is inside the queue
    -- (We are using here the "A*(Star) search algorithm". An extension of "Edsger Dijkstra's" pathfinding algorithm used by "Shakey the Robot" in 1959)
    while true do
        -- remove the table (shortest path) from the queue table and store the removed table in curPath
        -- (We remove the path from the queue here because if we don't find a adjacent marker and we
        --  have not reached the destination, then we no longer need this path. It's a dead end.)
        curPath = SWARMREMOVE(queue,lowestpathkey)
        if not curPath then break end
        -- get the last node from the path, so we can check adjacent waypoints
        lastNode = curPath.path[SWARMGETN(curPath.path)]
        -- Have we already checked this node for adjacenties ? then continue to the next node.
        if not AlreadyChecked[lastNode] then
            -- Check every node (marker) inside lastNode.adjacent
            for i, adjacentNode in lastNode.adjacent do
                -- get the node data from the graph table
                newNode = graph[adjacentNode]
                -- check, if we have found a node.
                if newNode then
                    -- copy the path from the startNode to the lastNode inside fork,
                    -- so we can add a new marker at the end and make a new path with it
                    fork = {
                        cost = curPath.cost,            -- cost from the startNode to the lastNode
                        path = {unpack(curPath.path)}, -- copy full path from starnode to the lastNode
                        totalThreat = curPath.totalThreat  -- total threat across the path
                    }
                    -- get distance from new node to destination node
                    dist = VDist2(newNode.position[1], newNode.position[3], endNode.position[1], endNode.position[3])
                    -- this brings the dist value from 0 to 100% of the maximum length with can travel on a map
                    dist = 100 * dist / ( mapSizeX + mapSizeZ )
                    -- get threat from current node to adjacent node
                    if platoonLayer == 'Air' and ScenarioInfo.Options.AIMapMarker == 'all' then
                        threat = GetThreatAtPosition(aiBrain, newNode.position, aiBrain.IMAPConfigSwarm.Rings, true, threatType)
                    else
                        threat = GetThreatBetweenPositions(aiBrain, newNode.position, lastNode.position, nil, threatType)
                    end
                    -- add as cost for the path the distance and threat to the overall cost from the whole path
                    fork.cost = fork.cost + dist + (threat * threatWeight)
                    fork.totalThreat = fork.totalThreat + threat
                    -- add the newNode at the end of the path
                    SWARMINSERT(fork.path, newNode)
                    -- check if we have reached our destination
                    if newNode.name == endNode.name then
                        -- store the path inside the path cache
                        aiBrain.PathCache[startNode.name][endNode.name][threatWeight] = { settime = GetGameTimeSeconds(), path = fork }
                        fork.pathLength = SWARMGETN(fork.path)
                        -- return the path
                        return fork
                    end
                    -- add the path to the queue, so we can check the adjacent nodes on the last added newNode
                    SWARMINSERT(queue,fork)
                end
            end
            -- Mark this node as checked
            AlreadyChecked[lastNode] = true
        end
        -- Search for the shortest / safest path and store the table key in lowestpathkey
        lowestcost = 100000000
        lowestpathkey = 1
        tableindex = 1
        while queue[tableindex].cost do
            if lowestcost > queue[tableindex].cost then
                lowestcost = queue[tableindex].cost
                lowestpathkey = tableindex
            end
            tableindex = tableindex + 1
        end
    end
    -- At this point we have not found any path to the destination.
    -- The path is to dangerous at the moment (or there is no path at all). We will check this again in 30 seconds.
    return false
end

-- Sproutos work

function GetRealThreatAtPositionSwarm(aiBrain, position, range )

    local sfake = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiSurface' )
    local afake = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiAir' )
    local bp
    local ALLBPS = __blueprints
    
    airthreat = 0
    surthreat = 0

    local eunits = GetUnitsAroundPoint( aiBrain, categories.ALLUNITS - categories.FACTORY - categories.ECONOMIC - categories.SHIELD - categories.WALL , position, range,  'Enemy')

    if eunits then

        for _,u in eunits do
    
            if not u.Dead then
        
                bp = ALLBPS[u.UnitId].Defense
            
                airthreat = airthreat + bp.AirThreatLevel
                surthreat = surthreat + bp.SurfaceThreatLevel
            end
        end
    end
    
    -- if there is IMAP threat and it's greater than what we actually see
    -- use the sum of both * .5
    if sfake > 0 and sfake > surthreat then
        surthreat = (surthreat + sfake) * .5
    end
    
    if afake > 0 and afake > airthreat then
        airthreat = (airthreat + afake) * .5
    end

    return surthreat, airthreat
end

function SendPlatoonWithTransportsNoCheckSwarm(aiBrain, platoon, destination, bRequired, bSkipLastMove, safeZone)

    GetMostRestrictiveLayer(platoon)

    local units = platoon:GetPlatoonUnits()
    local transportplatoon = false
    local markerRange = 125
    local maxThreat = 200
    local airthreatMax = 20

    -- only get transports for land (or partial land) movement
    if platoon.MovementLayer == 'Land' or platoon.MovementLayer == 'Amphibious' then

        -- DUNCAN - commented out, why check it?
        -- UVESO - If we reach this point, then we have either a platoon with Land or Amphibious MovementLayer.
        --         Both are valid if we have a Land destination point. But if we have a Amphibious destination
        --         point then we don't want to transport landunits.
        --         (This only happens on maps without AI path markers. Path graphing would prevent this.)
        if platoon.MovementLayer == 'Land' then
            local terrain = GetTerrainHeight(destination[1], destination[2])
            local surface = GetSurfaceHeight(destination[1], destination[2])
            if terrain < surface then
                return false
            end
        end

        -- if we don't *need* transports, then just call GetTransports...
        if not bRequired then
            --  if it doesn't work, tell the aiBrain we want transports and bail
            if AIUtils.GetTransports(platoon) == false then
                aiBrain.WantTransports = true
                --LOG('SendPlatoonWithTransportsNoCheckSwarm returning false setting WantTransports')
                return false
            end
        else
            -- we were told that transports are the only way to get where we want to go...
            -- ask for a transport every 10 seconds
            local counter = 0
            local transportsNeeded = AIUtils.GetNumTransports(units)
            local numTransportsNeeded = SWARMCEIL((transportsNeeded.Small + (transportsNeeded.Medium * 2) + (transportsNeeded.Large * 4)) / 10)
            if not aiBrain.NeedTransports then
                aiBrain.NeedTransports = 0
            end
            aiBrain.NeedTransports = aiBrain.NeedTransports + numTransportsNeeded
            if aiBrain.NeedTransports > 10 then
                aiBrain.NeedTransports = 10
            end
            
            local bUsedTransports, overflowSm, overflowMd, overflowLg = AIUtils.GetTransports(platoon)
            while not bUsedTransports and counter < 7 do --Set to 7, default is 6, 9 was previous.
                -- if we have overflow, dump the overflow and just send what we can
                if not bUsedTransports and overflowSm+overflowMd+overflowLg > 0 then
                    local goodunits, overflow = AIUtils.SplitTransportOverflow(units, overflowSm, overflowMd, overflowLg)
                    local numOverflow = SWARMGETN(overflow)
                    if SWARMGETN(goodunits) > numOverflow and numOverflow > 0 then
                        --LOG('numOverflow is '..numOverflow)
                        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                        for _,v in overflow do
                            if not v.Dead then
                                aiBrain:AssignUnitsToPlatoon(pool, {v}, 'Unassigned', 'None')
                            end
                        end
                        units = goodunits
                    end
                end
                bUsedTransports, overflowSm, overflowMd, overflowLg = AIUtils.GetTransports(platoon)
                if bUsedTransports then
                    break
                end
                counter = counter + 1
                --LOG('Counter is now '..counter..'Waiting 10 seconds')
                --LOG('Eng Build Queue is '..SWARMGETN(units[1].EngineerBuildQueue))
                SWARMWAIT(100)
                if not aiBrain:PlatoonExists(platoon) then
                    aiBrain.NeedTransports = aiBrain.NeedTransports - numTransportsNeeded
                    if aiBrain.NeedTransports < 0 then
                        aiBrain.NeedTransports = 0
                    end
                    --LOG('SendPlatoonWithTransportsNoCheckSwarm returning false no platoon exist')
                    return false
                end

                local survivors = {}
                for _,v in units do
                    if not v.Dead then
                        SWARMINSERT(survivors, v)
                    end
                end
                units = survivors
            end
            --LOG('End while loop for bUsedTransports')

            aiBrain.NeedTransports = aiBrain.NeedTransports - numTransportsNeeded
            if aiBrain.NeedTransports < 0 then
                aiBrain.NeedTransports = 0
            end

            -- couldn't use transports...
            if bUsedTransports == false then
                --LOG('SendPlatoonWithTransportsNoCheckSwarm returning false bUsedTransports')
                return false
            end
        end

        -- presumably, if we're here, we've gotten transports
        local transportLocation = false

        --DUNCAN - try the destination directly? Only do for engineers (eg skip last move is true)
        if bSkipLastMove then
            transportLocation = destination
        end
        --DUNCAN - try the land path nodefirst , not the transport marker as this will get units closer(thanks to Sorian).
        if not transportLocation then
            transportLocation = AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Land Path Node', destination[1], destination[3])
        end
        -- find an appropriate transport marker if it's on the map
        if not transportLocation then
            transportLocation = AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Transport Marker', destination[1], destination[3])
        end

        local useGraph = 'Land'
        if not transportLocation then
            -- go directly to destination, do not pass go.  This move might kill you, fyi.
            transportLocation = AIUtils.RandomLocation(destination[1],destination[3]) --Duncan - was platoon:GetPlatoonPosition()
            useGraph = 'Air'
        end

        if transportLocation then
            --LOG('initial transport location is '..repr(transportLocation))
            local minThreat = aiBrain:GetThreatAtPosition(transportLocation, 0, true)
            --LOG('Transport Location minThreat is '..minThreat)
            if (minThreat > 0) or safeZone then
                if platoon.MovementLayer == 'Amphibious' then
                    --LOG('Find Safe Drop Amphib')
                    transportLocation = FindSafeDropZoneWithPathSwarm(aiBrain, platoon, {'Amphibious Path Node','Land Path Node','Transport Marker'}, markerRange, destination, maxThreat, airthreatMax, 'AntiSurface', platoon.MovementLayer, safeZone)
                else
                    --LOG('Find Safe Drop Non Amphib')
                    transportLocation = FindSafeDropZoneWithPathSwarm(aiBrain, platoon, {'Land Path Node','Transport Marker'}, markerRange, destination, maxThreat, airthreatMax, 'AntiSurface', platoon.MovementLayer, safeZone)
                end
            end
            --LOG('Decided transport location is '..repr(transportLocation))
        end

        if not transportLocation then
            --LOG('No transport location or threat at location too high')
            return false
        end

        -- path from transport drop off to end location
        local path, reason = PlatoonGenerateSafePathToSwarm(aiBrain, useGraph, transportLocation, destination, 200)
        -- use the transport!
        AIUtils.UseTransportsSwarm(units, platoon:GetSquadUnits('Scout'), transportLocation, platoon)

        -- just in case we're still landing...
        for _,v in units do
            if not v.Dead then
                if v:IsUnitState('Attached') then
                   WaitSeconds(2)
                end
            end
        end

        -- check to see we're still around
        if not platoon or not aiBrain:PlatoonExists(platoon) then
            --LOG('SendPlatoonWithTransportsNoCheckSwarm returning false platoon doesnt exist')
            return false
        end

        -- then go to attack location
        if not path then
            -- directly
            if not bSkipLastMove then
                platoon:AggressiveMoveToLocation(destination)
                platoon.LastAttackDestination = {destination}
            end
        else
            -- or indirectly
            -- store path for future comparison
            platoon.LastAttackDestination = path

            local pathSize = SWARMGETN(path)
            --move to destination afterwards
            for wpidx,waypointPath in path do
                if wpidx == pathSize then
                    if not bSkipLastMove then
                        platoon:AggressiveMoveToLocation(waypointPath)
                    end
                else
                    platoon:MoveToLocation(waypointPath, false)
                end
            end
        end
    else
        --LOG('SendPlatoonWithTransportsNoCheckSwarm returning false due to movement layer')
        return false
    end
    --LOG('SendPlatoonWithTransportsNoCheckSwarm returning true')
    return true
end

function FindSafeDropZoneWithPathSwarm(aiBrain, platoon, markerTypes, markerrange, destination, threatMax, airthreatMax, threatType, layer, safeZone)

    local markerlist = {}
    local VDist2Sq = VDist2Sq

    -- locate the requested markers within markerrange of the supplied location	that the platoon can safely land at
    for _,v in markerTypes do
    
        markerlist = SWARMCAT( markerlist, AIUtils.AIGetMarkersAroundLocationSwarm(aiBrain, v, destination, markerrange, 0, threatMax, 0, 'AntiSurface') )
    end
    --LOG('Marker List is '..repr(markerlist))
    
    -- sort the markers by closest distance to final destination
    if not safeZone then
        SWARMSORT( markerlist, function(a,b) return VDist2Sq( a.Position[1],a.Position[3], destination[1],destination[3] ) < VDist2Sq( b.Position[1],b.Position[3], destination[1],destination[3] )  end )
    else
        SWARMSORT( markerlist, function(a,b) return VDist2Sq( a.Position[1],a.Position[3], destination[1],destination[3] ) > VDist2Sq( b.Position[1],b.Position[3], destination[1],destination[3] )  end )
        --LOG('SafeZone Sorted marker list '..repr(markerlist))
    end
   
    -- loop thru each marker -- see if you can form a safe path on the surface 
    -- and a safe path for the transports -- use the first one that satisfies both
    for _, v in markerlist do

        -- test the real values for that position
        local stest, atest = GetRealThreatAtPositionSwarm(aiBrain, v.Position, 75 )
        SWARMWAIT(1)
        --LOG('stest is '..stest..'atest is '..atest)

        if stest <= threatMax and atest <= airthreatMax then
        
            --LOG("*AI DEBUG "..aiBrain.Nickname.." FINDSAFEDROP for "..repr(destination).." is testing "..repr(v.Position).." "..v.Name)
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." Position "..repr(v.Position).." says Surface threat is "..stest.." vs "..threatMax.." and Air threat is "..atest.." vs "..airthreatMax )
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..platoon.BuilderName.." drop distance is "..repr( VDist3(destination, v.Position) ) )

            -- can the platoon path safely from this marker to the final destination 
            if CanGraphToSwarm(v.Position, destination, layer) then
                return v.Position, v.Name
            end
            --[[local landpath, reason = PlatoonGenerateSafePathToSwarm(aiBrain, layer, v.Position, destination, threatMax, 160 )
            if not landpath then
                --LOG('No path to transport location from selected position')
            end

            -- can the transports reach that marker ?
            if landpath then
                --LOG('Selected Position')
                return v.Position, v.Name
            end]]
        end
    end
    --LOG('Safe landing Location returning false')
    return false, nil
end