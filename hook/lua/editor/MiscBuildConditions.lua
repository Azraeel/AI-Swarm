
-- Swarm AI. Function to see if we are on a water map and/or can't send Land units to the enemy
local CanPathToEnemySwarm = {}
function CanPathToCurrentEnemySwarm(aiBrain, bool, LocationType)

    local EnemyIndex = ArmyBrains[aiBrain:GetCurrentEnemy():GetArmyIndex()].Nickname
    local Nickname = ArmyBrains[aiBrain:GetArmyIndex()].Nickname

    CanPathToEnemySwarm[Nickname] = CanPathToEnemySwarm[Nickname] or {} 
    CanPathToEnemySwarm[Nickname][LocationType] = CanPathToEnemySwarm[Nickname][LocationType] or {} 

    if CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] == 'WATER' then
        return false == bool
    end

    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    local startX, startZ = aiBrain:GetArmyStartPos()
    local enemyX, enemyZ
    if aiBrain:GetCurrentEnemy() then
        enemyX, enemyZ = aiBrain:GetCurrentEnemy():GetArmyStartPos()
  
        if not enemyX then
            return false
        end
    else
 
        return false
    end


    local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Land', {startX,0,startZ}, {enemyX,0,enemyZ}, 1000)

    if path then

        CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] = 'LAND'

        return true == bool

    else

        if reason == 'NoPath' then

            CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] = 'WATER'

            return false == bool

        elseif reason == 'NoGraph' then

            if aiBrain:GetMapWaterRatio() < 0.50 then

                CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] = 'LAND'

                return true == bool

            else
                
                CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] = 'WATER'

                return false == bool

            end
        end
    end
    return false
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

