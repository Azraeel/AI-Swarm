
-- Swarm AI. Function to see if we are on a water map and/or can't send Land units to the enemy
local CanPathToEnemySwarm = {}
function CanPathToCurrentEnemySwarm(aiBrain, bool, LocationType)

    local EnemyIndex = ArmyBrains[aiBrain:GetCurrentEnemy():GetArmyIndex()].Nickname
    --LOG('* AI-Swarm: Enemy Index is ' .. repr(EnemyIndex))
    local Nickname = ArmyBrains[aiBrain:GetArmyIndex()].Nickname

    CanPathToEnemySwarm[Nickname] = CanPathToEnemySwarm[Nickname] or {} 
    CanPathToEnemySwarm[Nickname][LocationType] = CanPathToEnemySwarm[Nickname][LocationType] or {} 

    if CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] == 'LAND' then
        return true == bool
    elseif CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] == 'WATER' then
        return false == bool
    end
    --LOG('* AI-Swarm: Bool Check is ' .. repr(bool))

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
        LOG('* AI-Swarm: CanPathToCurrentEnemy: Land path from '..LocationType..' to the enemy found! LAND map! - '..Nickname..' vs '..EnemyIndex..'')
        CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] = 'LAND'

        return true == bool

    else

        if reason == 'NoPath' then
            LOG('* AI-Swarm: CanPathToCurrentEnemy: No land path from '..LocationType..' to the enemy found! WATER map! - '..Nickname..' vs '..EnemyIndex..'')
            CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] = 'WATER'

            return false == bool

        elseif reason == 'NoGraph' then
            LOG('* AI-Swarm: CanPathToCurrentEnemy: No AI markers found! Using land/water ratio instead')
            if aiBrain:GetMapWaterRatio() < 0.50 then
                LOG(string.format('* AI-Swarm: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming LAND map! - '..Nickname..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
                CanPathToEnemySwarm[Nickname][LocationType][EnemyIndex] = 'LAND'
                
                return true == bool

            else
                LOG(string.format('* AI-Swarm: CanPathToCurrentEnemy: Water on map: %0.2f%%. Assuming WATER map! - '..Nickname..' vs '..EnemyIndex..'',aiBrain:GetMapWaterRatio()*100 ))
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

