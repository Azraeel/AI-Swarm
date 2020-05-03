
-- Swarm AI. Function to see if we are on a water map and/or can't send Land units to the enemy
local CanPathToEnemySwarm = {}
function CanPathToCurrentEnemySwarm(aiBrain, bool)
    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    local startX, startZ = aiBrain:GetArmyStartPos()
    local enemyX, enemyZ
    if aiBrain:GetCurrentEnemy() then
        enemyX, enemyZ = aiBrain:GetCurrentEnemy():GetArmyStartPos()
        -- if we don't have an enemy position then we can't search for a path. Return until we have an enemy position
        if not enemyX then
            return false
        end
    else
        -- if we don't have a current enemy then return false
        return false
    end

    -- Get the armyindex from the enemy
    local EnemyIndex = ArmyBrains[aiBrain:GetCurrentEnemy():GetArmyIndex()].Nickname
    local OwnIndex = ArmyBrains[aiBrain:GetArmyIndex()].Nickname

    -- create a table for the enemy index in case it's nil
    CanPathToEnemySwarm[OwnIndex] = CanPathToEnemySwarm[OwnIndex] or {} 
    -- Check if we have already done a path search to the current enemy
    if CanPathToEnemySwarm[OwnIndex][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemySwarm[OwnIndex][EnemyIndex] == 'WATER' then
        return false == bool
    end

    -- path wit AI markers from our base to the enemy base
    local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Land', {startX,0,startZ}, {enemyX,0,enemyZ}, 1000)
    -- if we have a path generated with AI path markers then....
    if path then
        LOG('* AI-Swarm: CanPathToCurrentEnemySwarm: Land path to the enemy found! LAND map! - '..OwnIndex..' vs '..EnemyIndex..'')
        CanPathToEnemySwarm[OwnIndex][EnemyIndex] = 'LAND'
    -- if we not have a path
    else
        -- "NoPath" means we have AI markers but can't find a path to the enemy - There is no path!
        if reason == 'NoPath' then
            LOG('* AI-Swarm: CanPathToCurrentEnemySwarm: No land path to the enemy found! WATER map! - '..OwnIndex..' vs '..EnemyIndex..'')
            CanPathToEnemySwarm[OwnIndex][EnemyIndex] = 'WATER'
        -- "NoGraph" means we have no AI markers and cant graph to the enemy. We can't search for a path - No markers
        elseif reason == 'NoGraph' then
            LOG('* AI-Swarm: CanPathToCurrentEnemySwarm: No AI markers found! Using land/water ratio instead')
            -- Check if we have less then 50% water on the map
            if aiBrain:GetMapWaterRatio() < 0.50 then
                --lets asume we can move on land to the enemy
                LOG(string.format('* AI-Swarm: CanPathToCurrentEnemySwarm: Water on map: %0.2f%%. Assuming LAND map! - '..OwnIndex..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
                CanPathToEnemySwarm[OwnIndex][EnemyIndex] = 'LAND'
            else
                -- we have more then 50% water on this map. Ity maybe a water map..
                LOG(string.format('* AI-Swarm: CanPathToCurrentEnemySwarm: Water on map: %0.2f%%. Assuming WATER map! - '..OwnIndex..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
                CanPathToEnemySwarm[OwnIndex][EnemyIndex] = 'WATER'
            end
        end
    end
    if CanPathToEnemySwarm[OwnIndex][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemySwarm[OwnIndex][EnemyIndex] == 'WATER' then
        return false == bool
    end
    CanPathToEnemySwarm[OwnIndex][EnemyIndex] = 'WATER'
    return false == bool
end

function MapGreaterThanSwarm(aiBrain, sizeX, sizeZ)
    local mapSizeX, mapSizeZ = GetMapSize()
    if mapSizeX > sizeX or mapSizeZ > sizeZ then
        --LOG('*AI DEBUG: MapGreaterThan returned True SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
        return true
    end
    --LOG('*AI DEBUG: MapGreaterThan returned False SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
    return false
end

function MapLessThanSwarm(aiBrain, sizeX, sizeZ)
    local mapSizeX, mapSizeZ = GetMapSize()
    if mapSizeX < sizeX and mapSizeZ < sizeZ then
        --LOG('*AI DEBUG: MapLessThan returned True SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
        return true
    end
    --LOG('*AI DEBUG: MapLessThan returned False SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
    return false
end

