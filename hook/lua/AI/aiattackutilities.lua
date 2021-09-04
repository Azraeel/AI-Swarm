local VDist2Sq = VDist2Sq

-- Uveso Functions
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