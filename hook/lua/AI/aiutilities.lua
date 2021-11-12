local import = import

local SWARMREMOVE = table.remove
local SWARMGETN = table.getn
local SWARMINSERT = table.insert
local SWARMWAIT = coroutine.yield
local SWARMTIME = GetGameTimeSeconds
local SWARMPI = math.pi
local SWARMSIN = math.sin
local SWARMCOS = math.cos
local SWARMENTITY = EntityCategoryContains
local SWARMPARSE = ParseEntityCategory

local VDist2 = VDist2

local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetAIBrain = moho.unit_methods.GetAIBrain

-- AI-Swarm: Helper function for targeting
function ValidateLayerSwarm(UnitPos,MovementLayer)
    -- Air can go everywhere
    if MovementLayer == 'Air' then
        return true
    end
    local TerrainHeight = GetTerrainHeight( UnitPos[1], UnitPos[3] ) -- terran high
    local SurfaceHeight = GetSurfaceHeight( UnitPos[1], UnitPos[3] ) -- water high
    -- Terrain > Surface = Target is on land
    if TerrainHeight >= SurfaceHeight and ( MovementLayer == 'Land' or MovementLayer == 'Amphibious' ) then
        --LOG('AttackLayer '..MovementLayer..' - TerrainHeight > SurfaceHeight. = Target is on land ')
        return true
    end
    -- Terrain < Surface = Target is underwater
    if TerrainHeight < SurfaceHeight and ( MovementLayer == 'Water' or MovementLayer == 'Amphibious' ) then
        --LOG('AttackLayer '..MovementLayer..' - TerrainHeight < SurfaceHeight. = Target is on water ')
        return true
    end

    return false
end

function ValidateAttackLayerSwarm(position, TargetPosition)
    -- check if attacker and target are both over or under water
    if ( position[2] >= GetSurfaceHeight( position[1], position[3] ) ) == ( TargetPosition[2] >= GetSurfaceHeight( TargetPosition[1], TargetPosition[3] ) ) then
        return true
    end
    return false
end

-- AI-Uveso: Helper function for targeting
function IsNukeBlastAreaSwarm(aiBrain, TargetPosition)
    -- check if the target is inside a nuke blast radius
    if aiBrain.NukedArea then
        for i, data in aiBrain.NukedArea or {} do
            if data.NukeTime + 50 <  SWARMTIME() then
                SWARMREMOVE(aiBrain.NukedArea, i)
            elseif VDist2(TargetPosition[1], TargetPosition[3], data.Location[1], data.Location[3]) < 40 then
                return true
            end
        end
    end
    return false
end

-- AI-Swarm: Target function
function AIFindNearestCategoryTargetInRangeSwarm(aiBrain, platoon, squad, position, maxRange, MoveToCategories, TargetSearchCategory, enemyBrain)
    if not maxRange then
        return false, false, false, 'NoRange'
    end
    if not TargetSearchCategory then
        return false, false, false, 'NoCat'
    end
    if not position then
        return false, false, false, 'NoPos'
    end
    if not platoon then
        return false, false, false, 'NoPlatoon'
    end
    local AttackEnemyStrength = platoon.PlatoonData.AttackEnemyStrength or 300
    local platoonUnits = platoon:GetPlatoonUnits()
    local PlatoonStrength = SWARMGETN(platoonUnits)
    local IgnoreTargetLayerCheck = platoon.PlatoonData.IgnoreTargetLayerCheck
    
    local enemyIndex = false
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end

    local RangeList = { [1] = maxRange }
    if maxRange > 512 then
        RangeList = {
            [1] = 64,
            [2] = 128,
            [2] = 192,
            [3] = 256,
            [3] = 384,
            [4] = 512,
            [5] = maxRange,
        }
    elseif maxRange > 256 then
        RangeList = {
            [1] = 64,
            [2] = 128,
            [2] = 192,
            [3] = 256,
            [4] = maxRange,
        }
    elseif maxRange > 64 then
        RangeList = {
            [1] = 64,
            [2] = maxRange,
        }
    end

    local path = false
    local reason = false
    local ReturnReason = 'got no reason'
    local UnitWithPath = false
    local UnitNoPath = false
    local count = 0
    local TargetsInRange, EnemyStrength, TargetPosition, distance, targetRange, success, bestGoalPos
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInRange)..'  ')
        for _, category in MoveToCategories do
            distance = maxRange
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                --LOG('* AIFindNearestCategoryTargetInRange: targetRange '..repr(targetRange))
                if targetRange < distance then
                    EnemyStrength = 0
                    -- check if this is the right enemy
                    if not SWARMENTITY(category, Target) then continue end
                    -- check if the target is on the same layer then the attacker
                    if not IgnoreTargetLayerCheck then
                        if not ValidateAttackLayerSwarm(position, TargetPosition) then continue end
                    end
                    -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                    if not platoon:CanAttackTarget(squad, Target) then continue end
                    --LOG('* AIFindNearestCategoryTargetInRange: canAttack CHECKED')
                    if platoon.MovementLayer == 'Land' and SWARMENTITY(categories.AIR, Target) then continue end

                    local blip = Target:GetBlip(MyArmyIndex)
                    if blip then
                        if blip:IsOnRadar(MyArmyIndex) or blip:IsSeenEver(MyArmyIndex) then
                            if not blip:BeenDestroyed() and not blip:IsKnownFake(MyArmyIndex) and not blip:IsMaybeDead(MyArmyIndex) then
                                if not Target.Dead then
                                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                                    if not IsEnemy( MyArmyIndex, Target.Army ) then continue end
                                    -- check if the target is inside a nuke blast radius
                                    if IsNukeBlastAreaSwarm(aiBrain, TargetPosition) then continue end
                                    -- check if we have a special player as enemy
                                    if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                                    -- we can't attack units while reclaim or capture is in progress
                                    if Target.ReclaimInProgress then continue end
                                    if Target.CaptureInProgress then continue end
                                    if not aiBrain:PlatoonExists(platoon) then
                                        return false, false, false, 'NoPlatoonExists'
                                    end
                                    if platoon.MovementLayer == 'Land' then
                                        EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE) , TargetPosition, 50, 'Enemy' )
                                    elseif platoon.MovementLayer == 'Air' then
                                        EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * categories.ANTIAIR , TargetPosition, 60, 'Enemy' )
                                    elseif platoon.MovementLayer == 'Water' then
                                        EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.ANTINAVY) , TargetPosition, 50, 'Enemy' )
                                    elseif platoon.MovementLayer == 'Amphibious' then
                                        EnemyStrength = aiBrain:GetNumUnitsAroundPoint( (categories.STRUCTURE + categories.MOBILE) * (categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.ANTINAVY) , TargetPosition, 50, 'Enemy' )
                                    end
                                    --LOG('PlatoonStrength / 100 * AttackEnemyStrength <= '..(PlatoonStrength / 100 * AttackEnemyStrength)..' || EnemyStrength = '..EnemyStrength)
                                    -- Only attack if we have a chance to win
                                    if PlatoonStrength / 100 * AttackEnemyStrength < EnemyStrength then continue end
                                    --LOG('* AIFindNearestCategoryTargetInRange: PlatoonGenerateSafePathTo ')
                                    path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, platoon.MovementLayer, position, TargetPosition, platoon.PlatoonData.NodeWeight or 10 )
                                    --LOG('What is Reason ' .. repr(reason))
                                    -- Check if we found a path with markers
                                    if path then
                                        UnitWithPath = Target
                                        distance = targetRange
                                        ReturnReason = reason
                                        --LOG('* AIFindNearestCategoryTargetInRange: Possible target with path. distance '..distance..'  ')
                                    -- We don't find a path with markers
                                    else
                                        -- NoPath happens if we have markers, but can't find a way to the destination. (We need transport)
                                        if reason == 'NoPath' then
                                            UnitNoPath = Target
                                            distance = targetRange
                                            ReturnReason = reason
                                            --LOG('* AIFindNearestCategoryTargetInRange: Possible target no path. distance '..distance..'  ')
                                        -- NoGraph means we have no Map markers. Lets try to path with c-engine command CanPathTo()
                                        elseif reason == 'NoGraph' then
                                            local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(platoon, TargetPosition)
                                            -- check if we found a path with c-engine command.
                                            if success then
                                                UnitWithPath = Target
                                                distance = targetRange
                                                ReturnReason = reason
                                                --LOG('* AIFindNearestCategoryTargetInRange: Possible target with CanPathTo(). distance '..distance..'  ')
                                                -- break out of the loop, so we don't use CanPathTo too often.
                                                break
                                            -- There is no path to the target.
                                            else
                                                UnitNoPath = Target
                                                distance = targetRange
                                                ReturnReason = reason
                                                --LOG('* AIFindNearestCategoryTargetInRange: Possible target failed CanPathTo(). distance '..distance..'  ')
                                            end     
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                count = count + 1
                if count > 300 then -- 300 
                    SWARMWAIT(1)
                    count = 0
                end
                -- DEBUG; use the first target we can path to it.
                --if UnitWithPath then
                --    return UnitWithPath, UnitNoPath, path, ReturnReason
                --end
                -- DEBUG; use the first target we can path to it.
            end
            if UnitWithPath then
                return UnitWithPath, false, path, ReturnReason
            end
        end
    end
    if UnitNoPath then
        return false, UnitNoPath, false, ReturnReason
    end
    return false, false, false, 'NoUnitFound'
end

function AIFindNearestCategoryTargetInRangeCDRSwarm(aiBrain, position, maxRange, MoveToCategories, enemyBrain)
    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = SWARMPARSE(TargetSearchCategory)
    end
    local enemyIndex = false
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local RangeList = {
        [1] = 30,
        [1] = 64,
        [2] = 128,
        [4] = maxRange,
    }
    local TargetUnit = false
    local basePostition = aiBrain.BuilderManagers['MAIN'].Position
    local TargetsInRange, EnemyStrength, TargetPosition, category, distance, targetRange, baseTargetRange, canAttack
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in MoveToCategories do
            category = v
            if type(category) == 'string' then
                category = SWARMPARSE(category)
            end
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRangeSwarm: numTargets '..table.getn(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                EnemyStrength = 0
                -- check if we have a special player as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not Target.Dead and SWARMENTITY(category, Target) then
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if not IsEnemy( MyArmyIndex, Target:GetAIBrain():GetArmyIndex() ) then continue end
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRangeSwarm: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.CaptureInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRangeSwarm: CaptureInProgress !!! Ignoring the target.')
                        continue
                    end
                    targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                    baseTargetRange = VDist2(basePostition[1],basePostition[3],TargetPosition[1],TargetPosition[3])
                    -- check if the target is in range of the ACU and in range of the base
                    if targetRange < distance then
                        TargetUnit = Target
                        distance = targetRange
                    end
                end
            end
            if TargetUnit then
                return TargetUnit
            end
            SWARMWAIT(1)
        end
        SWARMWAIT(1)
    end
    return TargetUnit
end


function AIFindNearestCategoryTargetInCloseRangeSwarm(platoon, aiBrain, squad, position, maxRange, MoveToCategories, TargetSearchCategory, enemyBrain)
    local IgnoreTargetLayerCheck = platoon.PlatoonData.IgnoreTargetLayerCheck
    local enemyIndex = false
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    if maxRange < 50 then
        maxRange = 50
    end
    local RangeList = {
        [1] = 30,
        [2] = maxRange,
        [3] = maxRange + 50,
    }
    local TargetUnit = false
    local TargetsInRange, EnemyStrength, TargetPosition, distance, targetRange, baseTargetRange, canAttack
    for _, range in RangeList do
        TargetsInRange = aiBrain:GetUnitsAroundPoint(TargetSearchCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, category in MoveToCategories do
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..table.getn(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                EnemyStrength = 0
                -- check if the target is inside a nuke blast radius
                if IsNukeBlastAreaSwarm(aiBrain, TargetPosition) then continue end
                -- check if we have a special player as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                -- check if the target is on the same layer then the attacker
                if not IgnoreTargetLayerCheck then
                    if not ValidateAttackLayerSwarm(position, TargetPosition) then continue end
                end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not platoon:CanAttackTarget(squad, Target) then continue end
                --LOG('* AIFindNearestCategoryTargetInRange: canAttack '..repr(canAttack))
                if platoon.MovementLayer == 'Land' and SWARMENTITY(categories.AIR, Target) then continue end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not Target.Dead and SWARMENTITY(category, Target) then
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if not IsEnemy( MyArmyIndex, Target.Army ) then continue end
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.CaptureInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: CaptureInProgress !!! Ignoring the target.')
                        continue
                    end
                    if not AIAttackUtils.CanGraphAreaTo(position, TargetPosition, platoon.MovementLayer) then continue end
                    targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                    -- check if the target is in range of the unit and in range of the base
                    if targetRange < distance then
                        TargetUnit = Target
                        distance = targetRange
                    end
                end
            end
            if TargetUnit then
                return TargetUnit
            end
            SWARMWAIT(5)
        end
        SWARMWAIT(5)
    end
    return TargetUnit
end

function points(original,radius,num)
    local nnn=0
    local coords = {}
    while nnn < num do
        local xxx = 0
        local yyy = 0
        xxx = original[1] + radius * SWARMCOS (nnn/num* (2 * SWARMPI))
        yyy = original[3] + radius * SWARMSIN (nnn/num* (2 * SWARMPI))
        SWARMINSERT(coords, {xxx, yyy})
        nnn = nnn + 1
    end
    for k, v in ipairs(coords) do
    print(v[1]..':'..v[2])
    end
end

local originalcoords = { 233.5, 25.239820480347, 464.5, type="VECTOR3" }

points(originalcoords, 20, 6)