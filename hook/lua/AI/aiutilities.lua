local SwarmUtils = import('/mods/AI-Swarm/lua/AI/Swarmutilities.lua')
local AIBehaviors = import('/lua/ai/AIBehaviors.lua')
local MABC = import('/lua/editor/MarkerBuildConditions.lua')
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
local import = import

local SWARMREMOVE = table.remove
local SWARMGETN = table.getn
local SWARMINSERT = table.insert
local SWARMWAIT = coroutine.yield
local SWARMTIME = GetGameTimeSeconds
local SWARMPI = math.pi
local SWARMSIN = math.sin
local SWARMCOS = math.cos
local SWARMFLOOR = math.floor
local SWARMENTITY = EntityCategoryContains

local VDist2 = VDist2

local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local GetAIBrain = moho.unit_methods.GetAIBrain

function FindUnclutteredAreaSwarm(aiBrain, category, location, radius, maxUnits, maxRadius, avoidCat)
    local units = aiBrain:GetUnitsAroundPoint(category, location, radius, 'Ally')
    local index = aiBrain:GetArmyIndex()
    local retUnits = {}
    for _, v in units do
        if not v.Dead and v:GetAIBrain():GetArmyIndex() == index then
            local nearby = aiBrain:GetNumUnitsAroundPoint(avoidCat, v:GetPosition(), maxRadius, 'Ally')
            if nearby < maxUnits then
                SWARMINSERT(retUnits, v)
            end
        end
    end

    return retUnits
end 

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

function AIGetMarkerLocationsNotFriendlySwarm(aiBrain, markerType)
    local markerList = {}
    --LOG('* AI-Swarm: Marker Type for AIGetMarkerLocationsNotFriendlySwarm is '..markerType)
    if markerType == 'Start Location' then
        local tempMarkers = AIGetMarkerLocationsSwarm(aiBrain, 'Blank Marker')
        for k, v in tempMarkers do
            if string.sub(v.Name, 1, 5) == 'ARMY_' then
                local ecoStructures = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE * (categories.MASSEXTRACTION + categories.MASSPRODUCTION), v.Position, 30, 'Ally')
                local GetBlueprint = moho.entity_methods.GetBlueprint
                local ecoThreat = 0
                for _, v in ecoStructures do
                    local bp = v:GetBlueprint()
                    local ecoStructThreat = bp.Defense.EconomyThreatLevel
                    --LOG('* AI-Swarm: Eco Structure'..ecoStructThreat)
                    ecoThreat = ecoThreat + ecoStructThreat
                end
                if ecoThreat < 10 then
                    SWARMINSERT(markerList, {Position = v.Position, Name = v.Name})
                end
            end
        end
    else
        local markers = Scenario.MasterChain._MASTERCHAIN_.Markers
        if markers then
            for k, v in markers do
                if v.type == markerType then
                    SWARMINSERT(markerList, {Position = v.Position, Name = k})
                end
            end
        end
    end
    return markerList
end

function AIGetMarkerLocationsSwarm(aiBrain, markerType)
    local markerList = {}
    if markerType == 'Start Location' then
        local tempMarkers = AIGetMarkerLocationsSwarm(aiBrain, 'Blank Marker')
        for k, v in tempMarkers do
            if string.sub(v.Name, 1, 5) == 'ARMY_' then
                SWARMINSERT(markerList, {Position = v.Position, Name = v.Name, MassSpotsInRange = v.MassSpotsInRange})
            end
        end
    else
        local markers = Scenario.MasterChain._MASTERCHAIN_.Markers
        if markers then
            for k, v in markers do
                if v.type == markerType then
                    SWARMINSERT(markerList, {Position = v.position, Name = k, MassSpotsInRange = v.MassSpotsInRange})
                end
            end
        end
    end

    return markerList
end

function AIGetMarkersAroundLocationSwarm(aiBrain, markerType, pos, radius, threatMin, threatMax, threatRings, threatType)
    local markers = AIGetMarkerLocationsSwarm(aiBrain, markerType)
    local returnMarkers = {}
    for _, v in markers do
        if markerType == 'Blank Marker' then
            if VDist2Sq(aiBrain.BuilderManagers['MAIN'].Position[1], aiBrain.BuilderManagers['MAIN'].Position[3], v.Position[1], v.Position[3]) < 10000 then
                --LOG('Start Location too close to main base skip, location is '..VDist2Sq(aiBrain.BuilderManagers['MAIN'].Position[1], aiBrain.BuilderManagers['MAIN'].Position[3], v.Position[1], v.Position[3])..' from main base pos')
                continue
            end
        end
        local dist = VDist2(pos[1], pos[3], v.Position[1], v.Position[3])
        if dist < radius then
            if not threatMin then
                SWARMINSERT(returnMarkers, v)
            else
                local threat = GetThreatAtPosition(aiBrain, v.Position, threatRings, true, threatType or 'Overall')
                if threat >= threatMin and threat <= threatMax then
                    SWARMINSERT(returnMarkers, v)
                end
            end
        end
    end

    return returnMarkers
end

-- AI-Swarm: Helper function for targeting
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
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
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
                category = ParseEntityCategory(category)
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

function AIFindBrainTargetInRangeSwarm(aiBrain, platoon, squad, maxRange, atkPri, avoidbases, platoonThreat, index)
    local position = platoon:GetPlatoonPosition()
    local VDist2 = VDist2
    if platoon.PlatoonData.GetTargetsFromBase then
        --LOG('Looking for targets from position '..platoon.PlatoonData.LocationType)
        position = aiBrain.BuilderManagers[platoon.PlatoonData.LocationType].Position
    end
    local enemyThreat, targetUnits, category
    local RangeList = { [1] = maxRange }
    if not aiBrain or not position or not maxRange then
        return false
    end
    if not avoidbases then
        avoidbases = false
    end
    if not platoon.MovementLayer then
        AIAttackUtils.GetMostRestrictiveLayer(platoon)
    end
    
    if maxRange > 512 then
        RangeList = {
            [1] = 30,
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
            [1] = 30,
            [1] = 64,
            [2] = 128,
            [2] = 192,
            [3] = 256,
            [4] = maxRange,
        }
    elseif maxRange > 64 then
        RangeList = {
            [1] = 30,
            [2] = maxRange,
        }
    end

    for _, range in RangeList do
        targetUnits = GetUnitsAroundPoint(aiBrain, categories.ALLUNITS, position, range, 'Enemy')
        for _, v in atkPri do
            category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            local retUnit = false
            local distance = false
            local targetShields = 9999
            for num, unit in targetUnits do
                if index then
                    for k, v in index do
                        if unit:GetAIBrain():GetArmyIndex() == v then
                            if not unit.Dead and not unit.CaptureInProgress and EntityCategoryContains(category, unit) and platoon:CanAttackTarget(squad, unit) then
                                local unitPos = unit:GetPosition()
                                if not retUnit or VDist2(position[1], position[3], unitPos[1], unitPos[3]) < distance then
                                    retUnit = unit
                                    distance = VDist2(position[1], position[3], unitPos[1], unitPos[3])
                                end
                                if platoon.MovementLayer == 'Air' and platoonThreat then
                                    enemyThreat = GetThreatAtPosition( aiBrain, unitPos, aiBrain.IMAPConfigSwarm.Rings, true, 'AntiAir')
                                    --LOG('Enemy Threat is '..enemyThreat..' and my threat is '..platoonThreat)
                                    if enemyThreat > platoonThreat then
                                        continue
                                    end
                                end
                                local numShields = aiBrain:GetNumUnitsAroundPoint(categories.DEFENSE * categories.SHIELD * categories.STRUCTURE, unitPos, 46, 'Enemy')
                                if not retUnit or numShields < targetShields or (numShields == targetShields and VDist2(position[1], position[3], unitPos[1], unitPos[3]) < distance) then
                                    retUnit = unit
                                    distance = VDist2(position[1], position[3], unitPos[1], unitPos[3])
                                    targetShields = numShields
                                end
                            end
                        end
                    end
                else
                    if not unit.Dead and EntityCategoryContains(category, unit) and platoon:CanAttackTarget(squad, unit) then
                        local unitPos = unit:GetPosition()
                        if avoidbases then
                            for _, w in ArmyBrains do
                                if IsEnemy(w:GetArmyIndex(), aiBrain:GetArmyIndex()) or (aiBrain:GetArmyIndex() == w:GetArmyIndex()) then
                                    local estartX, estartZ = w:GetArmyStartPos()
                                    if VDist2Sq(estartX, estartZ, unitPos[1], unitPos[3]) < 22500 then
                                        continue
                                    end
                                end
                            end
                        end
                        if platoon.MovementLayer == 'Air' and platoonThreat then
                            enemyThreat = GetThreatAtPosition( aiBrain, unitPos, aiBrain.BrainIntel.IMAPConfig.Rings, true, 'AntiAir')
                            --LOG('Enemy Threat is '..enemyThreat..' and my threat is '..platoonThreat)
                            if enemyThreat > platoonThreat then
                                continue
                            end
                        end
                        local numShields = aiBrain:GetNumUnitsAroundPoint(categories.DEFENSE * categories.SHIELD * categories.STRUCTURE, unitPos, 46, 'Enemy')
                        if not retUnit or numShields < targetShields or (numShields == targetShields and VDist2(position[1], position[3], unitPos[1], unitPos[3]) < distance) then
                            retUnit = unit
                            distance = VDist2(position[1], position[3], unitPos[1], unitPos[3])
                            targetShields = numShields
                        end
                    end
                end
            end
            if retUnit and targetShields > 0 then
                local platoonUnits = platoon:GetPlatoonUnits()
                for _, w in platoonUnits do
                    if not w.Dead then
                        unit = w
                        break
                    end
                end
                local closestBlockingShield = AIBehaviors.GetClosestShieldProtectingTargetSorian(unit, retUnit)
                if closestBlockingShield then
                    return closestBlockingShield
                end
            end
            if retUnit then
                return retUnit
            end
        end
        coroutine.yield(1)
    end
    return false
end

function AIFindBrainTargetInCloseRangeSwarm(aiBrain, platoon, position, squad, maxRange, targetQueryCategory, TargetSearchCategory, enemyBrain)
    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    local VDist2 = VDist2
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local acuPresent = false
    local acuUnit = false
    local RangeList = {
        [1] = 10,
        [2] = maxRange,
        [3] = maxRange + 30,
    }
    local TargetUnit = false
    local TargetsInRange, EnemyStrength, TargetPosition, category, distance, targetRange, baseTargetRange, canAttack
    for _, range in RangeList do
        if not position then
            WARN('* AI-Swarm: AIFindNearestCategoryTargetInCloseRange: position is empty')
            return false
        end
        if not range then
            WARN('* AI-Swarm: AIFindNearestCategoryTargetInCloseRange: range is empty')
            return false
        end
        if not TargetSearchCategory then
            WARN('* AI-Swarm: AIFindNearestCategoryTargetInCloseRange: TargetSearchCategory is empty')
            return false
        end
        TargetsInRange = GetUnitsAroundPoint(aiBrain, targetQueryCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in TargetSearchCategory do
            category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..SWARMGETN(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                EnemyStrength = 0
                -- check if we have a special player as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                if EntityCategoryContains(categories.COMMAND, Target) then
                    acuPresent = true
                    acuUnit = Target
                end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not Target.Dead and not Target.CaptureInProgress and EntityCategoryContains(category, Target) and platoon:CanAttackTarget(squad, Target) then
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if not IsEnemy( MyArmyIndex, Target:GetAIBrain():GetArmyIndex() ) then continue end
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.CaptureInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: CaptureInProgress !!! Ignoring the target.')
                        continue
                    end
                    targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                    -- check if the target is in range of the unit and in range of the base
                    if targetRange < distance then
                        TargetUnit = Target
                        distance = targetRange
                    end
                end
            end
            if TargetUnit then
                --LOG('Target Found in target aquisition function')
                return TargetUnit, acuPresent, acuUnit
            end
            SWARMWAIT(5)
        end
        SWARMWAIT(1)
    end
    --LOG('NO Target Found in target aquisition function')
    return TargetUnit, acuPresent, acuUnit
end

function AIFindBrainTargetInCloseRangeSwarm(aiBrain, platoon, position, squad, maxRange, targetQueryCategory, TargetSearchCategory, enemyBrain)
    if type(TargetSearchCategory) == 'string' then
        TargetSearchCategory = ParseEntityCategory(TargetSearchCategory)
    end
    local enemyIndex = false
    local VDist2 = VDist2
    local MyArmyIndex = aiBrain:GetArmyIndex()
    if enemyBrain then
        enemyIndex = enemyBrain:GetArmyIndex()
    end
    local acuPresent = false
    local acuUnit = false
    local RangeList = {
        [1] = 10,
        [2] = maxRange,
        [3] = maxRange + 30,
    }
    local TargetUnit = false
    local TargetsInRange, EnemyStrength, TargetPosition, category, distance, targetRange, baseTargetRange, canAttack
    for _, range in RangeList do
        if not position then
            WARN('* AI-Swarm: AIFindNearestCategoryTargetInCloseRange: position is empty')
            return false
        end
        if not range then
            WARN('* AI-Swarm: AIFindNearestCategoryTargetInCloseRange: range is empty')
            return false
        end
        if not TargetSearchCategory then
            WARN('* AI-Swarm: AIFindNearestCategoryTargetInCloseRange: TargetSearchCategory is empty')
            return false
        end
        TargetsInRange = GetUnitsAroundPoint(aiBrain, targetQueryCategory, position, range, 'Enemy')
        --DrawCircle(position, range, '0000FF')
        for _, v in TargetSearchCategory do
            category = v
            if type(category) == 'string' then
                category = ParseEntityCategory(category)
            end
            distance = maxRange
            --LOG('* AIFindNearestCategoryTargetInRange: numTargets '..SWARMGETN(TargetsInRange)..'  ')
            for num, Target in TargetsInRange do
                if Target.Dead or Target:BeenDestroyed() then
                    continue
                end
                TargetPosition = Target:GetPosition()
                EnemyStrength = 0
                -- check if we have a special player as enemy
                if enemyBrain and enemyIndex and enemyBrain ~= enemyIndex then continue end
                if EntityCategoryContains(categories.COMMAND, Target) then
                    acuPresent = true
                    acuUnit = Target
                end
                -- check if the Target is still alive, matches our target priority and can be attacked from our platoon
                if not Target.Dead and not Target.CaptureInProgress and EntityCategoryContains(category, Target) and platoon:CanAttackTarget(squad, Target) then
                    -- yes... we need to check if we got friendly units with GetUnitsAroundPoint(_, _, _, 'Enemy')
                    if not IsEnemy( MyArmyIndex, Target:GetAIBrain():GetArmyIndex() ) then continue end
                    if Target.ReclaimInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: ReclaimInProgress !!! Ignoring the target.')
                        continue
                    end
                    if Target.CaptureInProgress then
                        --WARN('* AIFindNearestCategoryTargetInRange: CaptureInProgress !!! Ignoring the target.')
                        continue
                    end
                    targetRange = VDist2(position[1],position[3],TargetPosition[1],TargetPosition[3])
                    -- check if the target is in range of the unit and in range of the base
                    if targetRange < distance then
                        TargetUnit = Target
                        distance = targetRange
                    end
                end
            end
            if TargetUnit then
                --LOG('Target Found in target aquisition function')
                return TargetUnit, acuPresent, acuUnit
            end
            SWARMWAIT(5)
        end
        SWARMWAIT(1)
    end
    --LOG('NO Target Found in target aquisition function')
    return TargetUnit, acuPresent, acuUnit
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

-- Huge Credits to Relent0r 
function EngineerMoveWithSafePathSwarm(aiBrain, unit, destination)
    if not destination then
        return false
    end
    local pos = unit:GetPosition()
    -- don't check a path if we are in build range
    if VDist2(pos[1], pos[3], destination[1], destination[3]) < 12 then
        return true
    end

    -- first try to find a path with markers. 
    local result, bestPos
    local path, reason = AIAttackUtils.EngineerGenerateSafePathToSwarm(aiBrain, 'Amphibious', pos, destination)
    --LOG('EngineerGenerateSafePathToSwarm reason is'..reason)
    -- only use CanPathTo for distance closer then 200 and if we can't path with markers
    if reason ~= 'PathOK' then
        -- we will crash the game if we use CanPathTo() on all engineer movments on a map without markers. So we don't path at all.
        if reason == 'NoGraph' then
            result = true
        elseif VDist2(pos[1], pos[3], destination[1], destination[3]) < 200 then
            SPEW('* AI-Swarm: EngineerMoveWithSafePath(): executing CanPathTo(). LUA GenerateSafePathTo returned: ('..repr(reason)..') '..VDist2(pos[1], pos[3], destination[1], destination[3]))
            -- be really sure we don't try a pathing with a destoryed c-object
            if unit.Dead or unit:BeenDestroyed() or IsDestroyed(unit) then
                SPEW('* AI-Swarm: Unit is death before calling CanPathTo()')
                return false
            end
            result, bestPos = unit:CanPathTo(destination)
        end 
    end
    local bUsedTransports = false
    -- Increase check to 300 for transports
    if (not result and reason ~= 'PathOK') or VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 250 * 250
    and unit.PlatoonHandle and not EntityCategoryContains(categories.COMMAND, unit) then
        -- If we can't path to our destination, we need, rather than want, transports
        local needTransports = not result and reason ~= 'PathOK'
        if VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 250 * 250 then
            needTransports = true
        end

        -- Skip the last move... we want to return and do a build
        --LOG('run SendPlatoonWithTransportsNoCheck')
        unit.WaitingForTransport = true
        bUsedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, unit.PlatoonHandle, destination, needTransports, true, false)
        unit.WaitingForTransport = false
        --LOG('finish SendPlatoonWithTransportsNoCheck')

        if bUsedTransports then
            return true
        elseif VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 512 * 512 then
            -- If over 512 and no transports dont try and walk!
            return false
        end
    end

    -- If we're here, we haven't used transports and we can path to the destination
    if result or reason == 'PathOK' then
        --LOG('* AI-Swarm: EngineerMoveWithSafePath(): result or reason == PathOK ')
        if reason ~= 'PathOK' then
            path, reason = AIAttackUtils.EngineerGenerateSafePathToSwarm(aiBrain, 'Amphibious', pos, destination)
        end
        if path then
            --LOG('* AI-Swarm: EngineerMoveWithSafePath(): path 0 true')
            local pathSize = SWARMGETN(path)
            -- Move to way points (but not to destination... leave that for the final command)
            for widx, waypointPath in path do
                IssueMove({unit}, waypointPath)
            end
            IssueMove({unit}, destination)
        else
            IssueMove({unit}, destination)
        end
        return true
    end
    return false
end

-- Huge Credits to Chp2001
function EngineerMoveWithSafePathSwarmAdvanced(aiBrain, eng, destination, whatToBuildM)
    if not destination then
        return false
    end
    local pos = eng:GetPosition()
    -- don't check a path if we are in build range
    if VDist2Sq(pos[1], pos[3], destination[1], destination[3]) < 144 then
        return true
    end

    -- first try to find a path with markers. 
    local result, bestPos
    local path, reason = AIAttackUtils.EngineerGenerateSafePathToSwarm(aiBrain, 'Amphibious', pos, destination, nil, 300)
    --LOG('EngineerGenerateSafePathToSwarm reason is'..reason)
    -- only use CanPathTo for distance closer then 200 and if we can't path with markers
    if reason ~= 'PathOK' then
        -- we will crash the game if we use CanPathTo() on all engineer movments on a map without markers. So we don't path at all.
        if reason == 'NoGraph' then
            result = true
        elseif VDist2Sq(pos[1], pos[3], destination[1], destination[3]) < 300*300 then
            SPEW('* AI-Swarm: EngineerMoveWithSafePath(): executing CanPathTo(). LUA GenerateSafePathTo returned: ('..repr(reason)..') '..VDist2Sq(pos[1], pos[3], destination[1], destination[3]))
            -- be really sure we don't try a pathing with a destoryed c-object
            if eng.Dead or eng:BeenDestroyed() or IsDestroyed(eng) then
                SPEW('* AI-Swarm: Unit is death before calling CanPathTo()')
                return false
            end
            result, bestPos = eng:CanPathTo(destination)
        end 
    end
    --LOG('EngineerGenerateSafePathToSwarm move to next bit')
    local bUsedTransports = false
    -- Increase check to 300 for transports
    if (not result and reason ~= 'PathOK') or VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 300 * 300
    and eng.PlatoonHandle and not EntityCategoryContains(categories.COMMAND, eng) then
        -- If we can't path to our destination, we need, rather than want, transports
        local needTransports = not result and reason ~= 'PathOK'
        if VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 300 * 300 then
            needTransports = true
        end

        -- Skip the last move... we want to return and do a build
        --LOG('run SendPlatoonWithTransportsNoCheck')
        eng.WaitingForTransport = true
        bUsedTransports = AIAttackUtils.SendPlatoonWithTransportsNoCheck(aiBrain, eng.PlatoonHandle, destination, needTransports, true, false)
        eng.WaitingForTransport = false
        --LOG('finish SendPlatoonWithTransportsNoCheck')

        if bUsedTransports then
            return true
        elseif VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 512 * 512 then
            -- If over 512 and no transports dont try and walk!
            return false
        end
    end

    -- If we're here, we haven't used transports and we can path to the destination
    if result or reason == 'PathOK' then
        --LOG('* AI-Swarm: EngineerMoveWithSafePath(): result or reason == PathOK ')
        if reason ~= 'PathOK' then
            path, reason = AIAttackUtils.EngineerGenerateSafePathToSwarm(aiBrain, 'Amphibious', pos, destination)
        end
        if path then
            --LOG('We have a path')
            if not whatToBuildM then
                local cons = eng.PlatoonHandle.PlatoonData.Construction
                local buildingTmpl, buildingTmplFile, baseTmpl, baseTmplFile, baseTmplDefault
                local factionIndex = aiBrain:GetFactionIndex()
                buildingTmplFile = import(cons.BuildingTemplateFile or '/lua/BuildingTemplates.lua')
                baseTmplFile = import(cons.BaseTemplateFile or '/lua/BaseTemplates.lua')
                baseTmplDefault = import('/lua/BaseTemplates.lua')
                buildingTmpl = buildingTmplFile[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
                baseTmpl = baseTmplFile[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]
                whatToBuildM = aiBrain:DecideWhatToBuild(eng, 'T1Resource', buildingTmpl)
            end
            --LOG('* AI-Swarm: EngineerMoveWithSafePath(): path 0 true')
            local pathSize = SWARMGETN(path)
            -- Move to way points (but not to destination... leave that for the final command)
            --LOG('We are issuing move commands for the path')
            for widx, waypointPath in path do
                if widx>=3 then
                    local bool,markers=MABC.CanBuildOnMassEngSwarm(aiBrain, waypointPath, 30)
                    if bool then
                        --LOG('We can build on a mass marker within 30')
                        --local massMarker = SwarmUtils.GetClosestMassMarkerToPos(aiBrain, waypointPath)
                        --LOG('Mass Marker'..repr(massMarker))
                        --LOG('Attempting second mass marker')
                        for _,massMarker in markers do
                        SwarmUtils.EngineerTryReclaimCaptureAreaSwarm(aiBrain, eng, massMarker.Position)
                        EngineerTryRepair(aiBrain, eng, whatToBuildM, massMarker.Position)
                        aiBrain:BuildStructure(eng, whatToBuildM, {massMarker.Position[1], massMarker.Position[3], 0}, false)
                        local newEntry = {whatToBuildM, {massMarker.Position[1], massMarker.Position[3], 0}, false}
                        SWARMINSERT(eng.EngineerBuildQueue, newEntry)
                        end
                    end
                end
                if (widx - SWARMFLOOR(widx/2)*2)==0 or VDist3Sq(destination,waypointPath)<40*40 then continue end
                IssueMove({eng}, waypointPath)
            end
            IssueMove({eng}, destination)
        else
            IssueMove({eng}, destination)
        end
        return true
    end
    return false
end

function UseTransportsSwarm(units, transports, location, transportPlatoon)
    local aiBrain
    for k, v in units do
        if not v.Dead then
            aiBrain = v:GetAIBrain()
            break
        end
    end

    if not aiBrain then
        return false
    end

    -- Load transports
    local transportTable = {}
    local transSlotTable = {}
    if not transports then
        return false
    end

    IssueClearCommands(transports)

    for num, unit in transports do
        local id = unit.UnitId
        if not transSlotTable[id] then
            transSlotTable[id] = GetNumTransportSlots(unit)
        end
        SWARMINSERT(transportTable,
            {
                Transport = unit,
                LargeSlots = transSlotTable[id].Large,
                MediumSlots = transSlotTable[id].Medium,
                SmallSlots = transSlotTable[id].Small,
                Units = {}
            }
        )
    end

    local shields = {}
    local remainingSize3 = {}
    local remainingSize2 = {}
    local remainingSize1 = {}
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    for num, unit in units do
        if not unit.Dead then
            if unit:IsUnitState('Attached') then
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
            elseif EntityCategoryContains(categories.url0306 + categories.DEFENSE, unit) then
                SWARMINSERT(shields, unit)
            elseif unit:GetBlueprint().Transport.TransportClass == 3 then
                SWARMINSERT(remainingSize3, unit)
            elseif unit:GetBlueprint().Transport.TransportClass == 2 then
                SWARMINSERT(remainingSize2, unit)
            elseif unit:GetBlueprint().Transport.TransportClass == 1 then
                SWARMINSERT(remainingSize1, unit)
            else
                SWARMINSERT(remainingSize1, unit)
            end
        end
    end

    local needed = GetNumTransports(units)
    local largeHave = 0
    for num, data in transportTable do
        largeHave = largeHave + data.LargeSlots
    end

    local leftoverUnits = {}
    local currLeftovers = {}
    local leftoverShields = {}
    transportTable, leftoverShields = SortUnitsOnTransports(transportTable, shields, largeHave - needed.Large)

    transportTable, leftoverUnits = SortUnitsOnTransports(transportTable, remainingSize3, -1)

    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, leftoverShields, -1)

    for _, v in currLeftovers do SWARMINSERT(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize2, -1)

    for _, v in currLeftovers do SWARMINSERT(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize1, -1)

    for _, v in currLeftovers do SWARMINSERT(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, currLeftovers, -1)

    aiBrain:AssignUnitsToPlatoon(pool, currLeftovers, 'Unassigned', 'None')
    if transportPlatoon then
        transportPlatoon.UsingTransport = true
    end

    local monitorUnits = {}
    for num, data in transportTable do
        if SWARMGETN(data.Units) > 0 then
            IssueClearCommands(data.Units)
            IssueTransportLoad(data.Units, data.Transport)
            for k, v in data.Units do SWARMINSERT(monitorUnits, v) end
        end
    end

    local attached = true
    repeat
        SWARMWAIT(20)
        local allDead = true
        local transDead = true
        for k, v in units do
            if not v.Dead then
                allDead = false
                break
            end
        end
        for k, v in transports do
            if not v.Dead then
                transDead = false
                break
            end
        end
        if allDead or transDead then return false end
        attached = true
        for k, v in monitorUnits do
            if not v.Dead and not v:IsIdleState() then
                attached = false
                break
            end
        end
    until attached

    -- Any units that aren't transports and aren't attached send back to pool
    for k, unit in units do
        if not unit.Dead and not EntityCategoryContains(categories.TRANSPORTATION, unit) then
            if not unit:IsUnitState('Attached') then
                aiBrain:AssignUnitsToPlatoon(pool, {unit}, 'Unassigned', 'None')
            end
        elseif not unit.Dead and EntityCategoryContains(categories.TRANSPORTATION, unit) and SWARMGETN(unit:GetCargo()) < 1 then
            ReturnTransportsToPool({unit}, true)
            SWARMREMOVE(transports, k)
        end
    end

    -- If some transports have no units return to pool
    for k, t in transports do
        if not t.Dead and SWARMGETN(t:GetCargo()) < 1 then
            aiBrain:AssignUnitsToPlatoon('ArmyPool', {t}, 'Scout', 'None')
            SWARMREMOVE(transports, k)
        end
    end

    if SWARMGETN(transports) ~= 0 then
        -- If no location then we have loaded transports then return true
        if location then
            local safePath = AIAttackUtils.PlatoonGenerateSafePathToSwarm(aiBrain, 'Air', transports[1]:GetPosition(), location, 200)
            if safePath then
                for _, p in safePath do
                    IssueMove(transports, p)
                end
            end
        else
            if transportPlatoon then
                transportPlatoon.UsingTransport = false
            end
            return true
        end
    else
        -- If no transports return false
        if transportPlatoon then
            transportPlatoon.UsingTransport = false
        end
        return false
    end

    -- Adding Surface Height, so thetransporter get not confused, because the target is under the map (reduces unload time)
    location = {location[1], GetSurfaceHeight(location[1],location[3]), location[3]}
    IssueTransportUnload(transports, location)
    local attached = true
    while attached do
        WaitSeconds(2)
        local allDead = true
        for _, v in transports do
            if not v.Dead then
                allDead = false
                break
            end
        end

        if allDead then
            return false
        end

        attached = false
        for num, unit in units do
            if not unit.Dead and unit:IsUnitState('Attached') then
                attached = true
                break
            end
        end
    end

    if transportPlatoon then
        transportPlatoon.UsingTransport = false
    end
    ReturnTransportsToPool(transports, true)

    return true
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