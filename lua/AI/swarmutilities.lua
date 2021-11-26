local import = import

local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local AIUtils = import('/lua/ai/aiutilities.lua')
local ToString = import('/lua/sim/CategoryUtils.lua').ToString

local SWARMGETN = table.getn
local SWARMINSERT = table.insert
local SWARMREMOVE = table.remove
local SWARMWAIT = coroutine.yield
local SWARMFLOOR = math.floor
local SWARMMAX = math.max
local SWARMMIN = math.min
local SWARMABS = math.abs
local SWARMTIME = GetGameTimeSeconds
local SWARMENTITY = EntityCategoryContains

local VDist2 = VDist2
local VDist2Sq = VDist2Sq
local VDist3 = VDist3

local GetThreatsAroundPosition = moho.aibrain_methods.GetThreatsAroundPosition
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt
local IsUnitState = moho.unit_methods.IsUnitState
local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local GetFractionComplete = moho.entity_methods.GetFractionComplete
local GetAIBrain = moho.unit_methods.GetAIBrain

function CheckCustomPlatoonsSwarm(aiBrain)
    if not aiBrain.StructurePool then
        --LOG('* AI-Swarm: Creating Structure Pool Platoon')
        local structurepool = aiBrain:MakePlatoon('StructurePool', 'none')
        structurepool:UniquelyNamePlatoon('StructurePool')
        structurepool.BuilderName = 'Structure Pool'
        aiBrain.StructurePool = structurepool
    end
end

-- 99% of the below was Sprouto's work
function StructureUpgradeInitializeSwarm(finishedUnit, aiBrain)
    local StructureUpgradeThreadSwarm = import('/lua/ai/aibehaviors.lua').StructureUpgradeThreadSwarm
    local structurePool = aiBrain.StructurePool
    local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
    --LOG('* AI-Swarm: Structure Upgrade Initializing')
    if EntityCategoryContains(categories.MASSEXTRACTION, finishedUnit) then
        local extractorPlatoon = aiBrain:MakePlatoon('ExtractorPlatoon'..tostring(finishedUnit.Sync.id), 'none')
        extractorPlatoon.BuilderName = 'ExtractorPlatoon'..tostring(finishedUnit.Sync.id)
        extractorPlatoon.MovementLayer = 'Land'
        --LOG('* AI-Swarm: Assigning Extractor to new platoon')
        AssignUnitsToPlatoon(aiBrain, extractorPlatoon, {finishedUnit}, 'Support', 'none')
        finishedUnit.PlatoonHandle = extractorPlatoon

        if not finishedUnit.UpgradeThread then
            --LOG('* AI-Swarm: Forking Upgrade Thread')
            upgradeSpec = aiBrain:GetUpgradeSpec(finishedUnit)
            --LOG('* AI-Swarm: UpgradeSpec'..repr(upgradeSpec))
            finishedUnit.UpgradeThread = finishedUnit:ForkThread(StructureUpgradeThreadSwarm, aiBrain, upgradeSpec, false)
        end
    end
    if finishedUnit.UpgradeThread then
        finishedUnit.Trash:Add(finishedUnit.UpgradeThread)
    end
end

function ExtractorsBeingUpgradedSwarm(aiBrain)
    -- Returns number of extractors upgrading

    local tech1ExtractorUpgrading = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * categories.TECH1, true)
    local tech2ExtractorUpgrading = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * categories.TECH2, true)
    local tech1ExtNumBuilding = 0
    local tech2ExtNumBuilding = 0
    -- own armyIndex
    local armyIndex = aiBrain:GetArmyIndex()
    -- loop over all units and search for upgrading units
    for t1extKey, t1extrator in tech1ExtractorUpgrading do
        if not t1extrator.Dead and not t1extrator:BeenDestroyed() and t1extrator:IsUnitState('Upgrading') and t1extrator:GetAIBrain():GetArmyIndex() == armyIndex then
            tech1ExtNumBuilding = tech1ExtNumBuilding + 1
        end
    end
    for t2extKey, t2extrator in tech2ExtractorUpgrading do
        if not t2extrator.Dead and not t2extrator:BeenDestroyed() and t2extrator:IsUnitState('Upgrading') and t2extrator:GetAIBrain():GetArmyIndex() == armyIndex then
            tech2ExtNumBuilding = tech2ExtNumBuilding + 1
        end
    end
    return {TECH1 = tech1ExtNumBuilding, TECH2 = tech2ExtNumBuilding}
end

function HaveUnitRatio(aiBrain, ratio, categoryOne, compareType, categoryTwo)
    local numOne = aiBrain:GetCurrentUnits(categoryOne)
    local numTwo = aiBrain:GetCurrentUnits(categoryTwo)
    return CompareBody(numOne / numTwo, ratio, compareType)
end

function CompareBody(numOne, numTwo, compareType)
    if compareType == '>' then
        if numOne > numTwo then
            return true
        end
    elseif compareType == '<' then
        if numOne < numTwo then
            return true
        end
    elseif compareType == '>=' then
        if numOne >= numTwo then
            return true
        end
    elseif compareType == '<=' then
        if numOne <= numTwo then
            return true
        end
    else
       error('*AI ERROR: Invalid compare type: ' .. compareType)
       return false
    end
    return false
end

-- 100% Relent0r's Work 
function GetAssisteesSwarm(aiBrain, locationType, assisteeType, buildingCategory, assisteeCategory)
    if assisteeType == categories.FACTORY then
        -- Sift through the factories in the location
        local manager = aiBrain.BuilderManagers[locationType].FactoryManager
        return manager:GetFactoriesWantingAssistance(buildingCategory, assisteeCategory)
    elseif assisteeType == categories.ENGINEER then
        local manager = aiBrain.BuilderManagers[locationType].EngineerManager
        return manager:GetEngineersWantingAssistance(buildingCategory, assisteeCategory)
    elseif assisteeType == categories.STRUCTURE then
        local manager = aiBrain.BuilderManagers[locationType].PlatoonFormManager
        return manager:GetUnitsBeingBuilt(buildingCategory, assisteeCategory)
    else
        error('*AI ERROR: Invalid assisteeType - ' .. ToString(assisteeType))
    end

    return false
end

function EngineerTryReclaimCaptureAreaSwarm(aiBrain, eng, pos, pointRadius)
    if not pos then
        return false
    end
    if not pointRadius then
        pointRadius = 15
    end
    local Reclaiming = false
    --Temporary for troubleshooting
    --local GetBlueprint = moho.entity_methods.GetBlueprint
    -- Check if enemy units are at location
    local checkUnits = GetUnitsAroundPoint(aiBrain, (categories.STRUCTURE + categories.MOBILE) - categories.AIR, pos, pointRadius, 'Enemy')
    -- reclaim units near our building place.
    if checkUnits and SWARMGETN(checkUnits) > 0 then
        for num, unit in checkUnits do
            --temporary for troubleshooting
            --unitdesc = GetBlueprint(unit).Description
            if unit.Dead or unit:BeenDestroyed() then
                continue
            end
            if not IsEnemy( aiBrain:GetArmyIndex(), unit:GetAIBrain():GetArmyIndex() ) then
                continue
            end
            if unit:IsCapturable() and not EntityCategoryContains(categories.TECH1 * (categories.MOBILE + categories.WALL), unit) then 
                --LOG('* AI-Swarm: Unit is capturable and not category t1 mobile'..unitdesc)
                -- if we can capture the unit/building then do so
                unit.CaptureInProgress = true
                IssueCapture({eng}, unit)
            else
                --LOG('* AI-Swarm: We are going to reclaim the unit'..unitdesc)
                -- if we can't capture then reclaim
                unit.ReclaimInProgress = true
                IssueReclaim({eng}, unit)
            end
        end
        Reclaiming = true
    end
    -- reclaim rocks etc or we can't build mexes or hydros
    local Reclaimables = GetReclaimablesInRect(Rect(pos[1], pos[3], pos[1], pos[3]))
    if Reclaimables and SWARMGETN( Reclaimables ) > 0 then
        for k,v in Reclaimables do
            if v.MaxMassReclaim and v.MaxMassReclaim > 0 or v.MaxEnergyReclaim and v.MaxEnergyReclaim > 0 then
                IssueReclaim({eng}, v)
            end
        end
    end
    return Reclaiming
end

function AIGetSortedMassLocationsThreatSwarm(aiBrain, minDist, maxDist, tMin, tMax, tRings, tType, position)

    local threatCheck = false
    local maxDistance = 2000
    local minDistance = 0
    local VDist2Sq = VDist2Sq


    local startX, startZ
    
    if position then
        startX = position[1]
        startZ = position[3]
    else
        startX, startZ = aiBrain:GetArmyStartPos()
    end
    if maxDist and minDist then
        maxDistance = maxDist * maxDist
        minDistance = minDist * minDist
    end

    if tMin and tMax and tType then
        threatCheck = true
    else
        threatCheck = false
    end

    local markerList = GetMarkersByType('Mass')
    SWARMSORT(markerList, function(a,b) return VDist2Sq(a.Position[1],a.Position[3], startX,startZ) < VDist2Sq(b.Position[1],b.Position[3], startX,startZ) end)
    --LOG('Sorted Mass Marker List '..repr(markerList))
    local newList = {}
    for _, v in markerList do
        -- check distance to map border. (game engine can't build mass closer then 8 mapunits to the map border.) 
        if v.Position[1] <= 8 or v.Position[1] >= ScenarioInfo.size[1] - 8 or v.Position[3] <= 8 or v.Position[3] >= ScenarioInfo.size[2] - 8 then
            -- mass marker is too close to border, skip it.
            continue
        end
        if VDist2Sq(v.Position[1], v.Position[3], startX, startZ) < minDistance then
            continue
        end
        if VDist2Sq(v.Position[1], v.Position[3], startX, startZ) > maxDistance  then
            --LOG('Current Distance of marker..'..VDist2Sq(v.Position[1], v.Position[3], startX, startZ))
            --LOG('Max Distance'..maxDistance)
            --LOG('mass marker MaxDistance Reached, breaking loop')
            break
        end
        if CanBuildStructureAt(aiBrain, 'ueb1103', v.Position) then
            if threatCheck then
                if GetThreatAtPosition(aiBrain, v.Position, 0, true, tType) >= tMax then
                    --LOG('mass marker threatMax Reached, continuing')
                    continue
                end
            end
            table.insert(newList, v)
        end
    end
    --LOG('Return marker list has '..SWARMGETN(newList)..' entries')
    return newList
end

local PropBlacklist = {}
-- This uses a mix of Uveso's reclaim logic and Relent0r's Logic 
function ReclaimSwarmAIThread(platoon, self, aiBrain)

    --LOG('* AI-Swarm: Start Reclaim Function')
    if aiBrain.StartReclaimTakenSwarm then
        --LOG('StartReclaimTakenSwarm set to true')
        --LOG('Start Reclaim Table has '..SWARMGETN(aiBrain.StartReclaimTableSwarm)..' items in it')
    end
    IssueClearCommands({self})
    local locationType = self.PlatoonData.LocationType
    local initialRange = 40
    local createTick = GetGameTick()
    local reclaimLoop = 0
    local VDist2 = VDist2

    self.BadReclaimables = self.BadReclaimables or {}

    while aiBrain:PlatoonExists(platoon) and self and not self.Dead do
        local engPos = self:GetPosition()
        if not aiBrain.StartReclaimTakenSwarm then
            --self:SetCustomName('StartReclaim Logic Start')
            --LOG('Reclaim Function - Starting reclaim is false')
            local sortedReclaimTable = {}
            if SWARMGETN(aiBrain.StartReclaimTableSwarm) > 0 then
                
                --SWARMWAIT(10)
                local reclaimCount = 0
                aiBrain.StartReclaimTakenSwarm = true
                for k, r in aiBrain.StartReclaimTableSwarm do
                    if r.Reclaim and not IsDestroyed(r.Reclaim) then
                        reclaimCount = reclaimCount + 1
                        --LOG('Reclaim Function - Issuing reclaim')
                        --LOG('Reclaim distance is '..r.Distance)
                        IssueReclaim({self}, r.Reclaim)
                        SWARMWAIT(20)
                        local reclaimTimeout = 0
                        while aiBrain:PlatoonExists(platoon) and r.Reclaim and (not IsDestroyed(r.Reclaim)) and (reclaimTimeout < 20) do
                            reclaimTimeout = reclaimTimeout + 1
                            --LOG('Waiting for reclaim to no longer exist')
                            if aiBrain:GetEconomyStoredRatio('MASS') > 0.95 then
                                self:SetPaused( true )
                                SWARMWAIT(50)
                                self:SetPaused( false )
                            end
                            SWARMWAIT(20)
                        end
                        --LOG('Reclaim Count is '..reclaimCount)
                        if reclaimCount > 10 then
                            break
                        end
                    else
                        --LOG('Reclaim is no longer valid')
                    end
                    --LOG('Set key to nil')
                    aiBrain.StartReclaimTableSwarm[k] = nil
                end
                --LOG('Pre Rebuild Reclaim table has '..SWARMGETN(aiBrain.StartReclaimTableSwarm)..' reclaim left')
                aiBrain.StartReclaimTableSwarm = aiBrain:RebuildTable(aiBrain.StartReclaimTableSwarm)
                --LOG('Reclaim table has '..SWARMGETN(aiBrain.StartReclaimTableSwarm)..' reclaim left')
                
                if SWARMGETN(aiBrain.StartReclaimTableSwarm) == 0 then
                    --LOG('Start Reclaim Taken set to true')
                    aiBrain.StartReclaimTakenSwarm = true
                else
                    --LOG('Start Reclaim table not empty, set StartReclaimTakenSwarm to false')
                    aiBrain.StartReclaimTakenSwarm = false
                end
                for i=1, 10 do
                    --LOG('Waiting Ticks '..i)
                    SWARMWAIT(20)
                end
            end
            --self:SetCustomName('StartReclaim logic end')
        end
        local furtherestReclaim = nil
        local closestReclaim = nil
        local closestDistance = 10000
        local furtherestDistance = 0
        local minRec = platoon.PlatoonData.MinimumReclaim
        local x1 = engPos[1] - initialRange
        local x2 = engPos[1] + initialRange
        local z1 = engPos[3] - initialRange
        local z2 = engPos[3] + initialRange
        local rect = Rect(x1, z1, x2, z2)
        local reclaimRect = {}
        reclaimRect = GetReclaimablesInRect(rect)
        if not engPos then
            SWARMWAIT(1)
            return
        end

        local reclaim = {}
        local needEnergy = aiBrain:GetEconomyStored('ENERGY') < 2000
        --LOG('* AI-Swarm: Going through reclaim table')
        --self:SetCustomName('Loop through reclaim table')
        if reclaimRect and SWARMGETN( reclaimRect ) > 0 then
            for k,v in reclaimRect do
                if not IsProp(v) or self.BadReclaimables[v] then continue end
                local rpos = v:GetCachePosition()
                -- Start Blacklisted Props
                local blacklisted = false
                for _, BlackPos in PropBlacklist do
                    if rpos[1] == BlackPos[1] and rpos[3] == BlackPos[3] then
                        blacklisted = true
                        break
                    end
                end
                if blacklisted then continue end
                -- End Blacklisted Props
                if not needEnergy or v.MaxEnergyReclaim then
                    if v.MaxMassReclaim and v.MaxMassReclaim >= minRec then
                        if not self.BadReclaimables[v] then
                            local recPos = v:GetCachePosition()
                            local distance = VDist2(engPos[1], engPos[3], recPos[1], recPos[3])
                            if distance < closestDistance then
                                closestReclaim = recPos
                                closestDistance = distance
                            end
                            if distance > furtherestDistance then -- and distance < closestDistance + 20
                                furtherestReclaim = recPos
                                furtherestDistance = distance
                            end
                            if furtherestDistance - closestDistance > 20 then
                                break
                            end
                        end
                    end
                end
            end
        else
            --self:SetCustomName('No reclaim, increase 100 from '..initialRange)
            initialRange = initialRange + 100
            --LOG('* AI-Swarm: initialRange is'..initialRange)
            if initialRange > 300 then
                --LOG('* AI-Swarm: Reclaim range > 300, Disabling Reclaim.')
                PropBlacklist = {}
                aiBrain.ReclaimEnabledSwarm = false
                aiBrain.ReclaimLastCheckSwarm = GetGameTimeSeconds()
                return
            end
            SWARMWAIT(2)
            continue
        end
        if closestDistance == 10000 then
            --self:SetCustomName('closestDistance return 10000')
            initialRange = initialRange + 100
            --LOG('* AI-Swarm: initialRange is'..initialRange)
            if initialRange > 200 then
                --LOG('* AI-Swarm: Reclaim range > 200, Disabling Reclaim.')
                PropBlacklist = {}
                aiBrain.ReclaimEnabledSwarm = false
                aiBrain.ReclaimLastCheckSwarm = GetGameTimeSeconds()
                return
            end
            SWARMWAIT(2)
            continue
        end
        if self.Dead then 
            return
        end
        --LOG('* AI-Swarm: Closest Distance is : '..closestDistance..'Furtherest Distance is :'..furtherestDistance)
        -- Clear Commands first
        IssueClearCommands({self})
        --LOG('* AI-Swarm: Attempting move to closest reclaim')
        --LOG('* AI-Swarm: Closest reclaim is '..repr(closestReclaim))
        if not closestReclaim then
            --self:SetCustomName('no closestDistance')
            SWARMWAIT(2)
            return
        end
        if self.lastXtarget == closestReclaim[1] and self.lastYtarget == closestReclaim[3] then
            --self:SetCustomName('blocked reclaim')
            self.blocked = self.blocked + 1
            --LOG('* AI-Swarm: Reclaim Blocked + 1 :'..self.blocked)
            if self.blocked > 3 then
                self.blocked = 0
                SWARMINSERT (PropBlacklist, closestReclaim)
                --LOG('* AI-Swarm: Reclaim Added to blacklist')
            end
        else
            self.blocked = 0
            self.lastXtarget = closestReclaim[1]
            self.lastYtarget = closestReclaim[3]
            StartMoveDestination(self, closestReclaim)
        end

        --LOG('* AI-Swarm: Attempting agressive move to furtherest reclaim')
        -- Clear Commands first
        --self:SetCustomName('Aggressive move to reclaim')
        IssueClearCommands({self})
        IssueAggressiveMove({self}, furtherestReclaim)
        local reclaiming = not self:IsIdleState()
        local max_time = platoon.PlatoonData.ReclaimTime
        local currentTime = 0
        local idleCount = 0
        while reclaiming do
            --LOG('* AI-Swarm: Engineer is reclaiming')
            --self:SetCustomName('reclaim loop start')
            SWARMWAIT(200)
            currentTime = currentTime + 20
            if currentTime > max_time then
                reclaiming = false
            end
            if self:IsIdleState() then
                idleCount = idleCount + 1
                if idleCount > 5 then
                    reclaiming = false
                end
            end
            --self:SetCustomName('reclaim loop end')
        end
        local basePosition = aiBrain.BuilderManagers['MAIN'].Position
        local location = AIUtils.RandomLocation(basePosition[1],basePosition[3])
        --LOG('* AI-Swarm: basePosition random location :'..repr(location))
        IssueClearCommands({self})
        StartMoveDestination(self, location)
        SWARMWAIT(30)
        --self:SetCustomName('moving back to base')
        reclaimLoop = reclaimLoop + 1
        if reclaimLoop == 5 then
            --LOG('* AI-Swarm: reclaimLopp = 5 returning')
            return
        end
        --self:SetCustomName('end of reclaim function')
        SWARMWAIT(5)
    end
end

function StartMoveDestination(self,destination)
    local NowPosition = self:GetPosition()
    local x, z, y = unpack(self:GetPosition())
    local count = 0
    IssueClearCommands({self})
    while x == NowPosition[1] and y == NowPosition[3] and count < 20 do
        count = count + 1
        IssueClearCommands({self})
        IssueMove( {self}, destination )
        SWARMWAIT(10)
    end
end

function ComHealth(cdr)
    local armorPercent = 100 / cdr:GetMaxHealth() * cdr:GetHealth()
    local shieldPercent = armorPercent
    if cdr.MyShield then
        shieldPercent = 100 / cdr.MyShield:GetMaxHealth() * cdr.MyShield:GetHealth()
    end
    return ( armorPercent + shieldPercent ) / 2
end

function UnderAttackSwarm(cdr)
    local CDRHealth = ComHealth(cdr)
    if CDRHealth - (cdr.HealthOLD or CDRHealth) < -1 then
        cdr.LastDamaged = SWARMTIME()
    end
    cdr.HealthOLD = CDRHealth
    if SWARMTIME() - cdr.LastDamaged < 4 then
        return true
    else
        return false
    end
end

-- Decided to grab this from Chp2001, because the FBM rally placement sometimes is completely garbage
function lerpy(vec1, vec2, distance)
    -- Courtesy of chp2001
    -- note the distance param is {distance, distance - weapon range}
    -- vec1 is friendly unit, vec2 is enemy unit
    local distanceFrac = distance[2] / distance[1]
    local x = vec1[1] * (1 - distanceFrac) + vec2[1] * distanceFrac
    local y = vec1[2] * (1 - distanceFrac) + vec2[2] * distanceFrac
    local z = vec1[3] * (1 - distanceFrac) + vec2[3] * distanceFrac
    return {x,y,z}
end

function RandomizePosition(position)
    local Posx = position[1]
    local Posz = position[3]
    local X = -1
    local Z = -1
    local guard = 0
    while X <= 0 or X >= ScenarioInfo.size[1] do
        guard = guard + 1
        if guard > 100 then break end
        X = Posx + Random(-10, 10)
    end
    guard = 0
    while Z <= 0 or Z >= ScenarioInfo.size[2] do
        guard = guard + 1
        if guard > 100 then break end
        Z = Posz + Random(-10, 10)
    end
    local Y = GetTerrainHeight(X, Z)
    if GetSurfaceHeight(X, Z) > Y then
        Y = GetSurfaceHeight(X, Z)
    end
    return {X, Y, Z}
end

function RandomizePositionTML(position)
    local Posx = position[1]
    local Posz = position[3]
    local X = -1
    local Z = -1
    local guard = 0
    while X <= 0 or X >= ScenarioInfo.size[1] do
        guard = guard + 1
        if guard > 100 then break end
        X = Posx + Random(-3, 3)
    end
    guard = 0
    while Z <= 0 or Z >= ScenarioInfo.size[2] do
        guard = guard + 1
        if guard > 100 then break end
        Z = Posz + Random(-3, 3)
    end
    local Y = GetTerrainHeight(X, Z)
    if GetSurfaceHeight(X, Z) > Y then
        Y = GetSurfaceHeight(X, Z)
    end
    return {X, Y, Z}
end


function GetDangerZoneRadii(bool)
    
    local BaseMilitaryZone = SWARMMAX( ScenarioInfo.size[1]-50, ScenarioInfo.size[2]-50 ) / 2
    BaseMilitaryZone = SWARMMAX( 250, BaseMilitaryZone )

    local BasePanicZone = BaseMilitaryZone / 2
    BasePanicZone = SWARMMAX( 60, BasePanicZone )
    BasePanicZone = SWARMMIN( 120, BasePanicZone )

    local BaseEnemyZone = SWARMMAX( ScenarioInfo.size[1], ScenarioInfo.size[2] ) * 1.5
  
    if bool then
        LOG('* AI-Swarm: BasePanicZone= '..SWARMFLOOR( BasePanicZone * 0.01953125 ) ..' Km - ('..BasePanicZone..' units)' )
        LOG('* AI-Swarm: BaseMilitaryZone= '..SWARMFLOOR( BaseMilitaryZone * 0.01953125 )..' Km - ('..BaseMilitaryZone..' units)' )
        LOG('* AI-Swarm: BaseEnemyZone= '..SWARMFLOOR( BaseEnemyZone * 0.01953125 )..' Km - ('..BaseEnemyZone..' units)' )
    end

    return BasePanicZone, BaseMilitaryZone, BaseEnemyZone
end

-- Requires Rework
function AirScoutPatrolSwarmAIThread(self, aiBrain)
    
    local scout = self:GetPlatoonUnits()[1]
    if not scout then
        return
    end

   
    if not aiBrain.InterestList then
        aiBrain:BuildScoutLocations()
    end

   
    if scout:TestToggleCaps('RULEUTC_CloakToggle') then
        scout:EnableUnitIntel('Toggle', 'Cloak')
    end

    while not scout.Dead do
        local targetArea = false
        local highPri = false

        local mustScoutArea, mustScoutIndex = aiBrain:GetUntaggedMustScoutArea()
        local unknownThreats = aiBrain:GetThreatsAroundPosition(scout:GetPosition(), 16, true, 'Unknown')

        --1) If we have any "must scout" (manually added) locations that have not been scouted yet, then scout them
        if mustScoutArea then
            mustScoutArea.TaggedBy = scout
            targetArea = mustScoutArea.Position

        --2) Scout "unknown threat" areas with a threat higher than 5
        elseif SWARMGETN(unknownThreats) > 0 and unknownThreats[1][3] > 5 then
            aiBrain:AddScoutArea({unknownThreats[1][1], 0, unknownThreats[1][2]})

        --3) Scout high priority locations
        elseif aiBrain.IntelData.AirHiPriScouts < aiBrain.NumOpponents and aiBrain.IntelData.AirLowPriScouts < 1
        and SWARMGETN(aiBrain.InterestList.HighPriority) > 0 then
            aiBrain.IntelData.AirHiPriScouts = aiBrain.IntelData.AirHiPriScouts + 1

            highPri = true

            targetData = aiBrain.InterestList.HighPriority[1]
            targetData.LastScouted = SWARMTIME()
            targetArea = targetData.Position

            aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)

        --4) Every time we scout NumOpponents number of high priority locations, scout a low priority location
        elseif aiBrain.IntelData.AirLowPriScouts < 1 and SWARMGETN(aiBrain.InterestList.LowPriority) > 0 then
            aiBrain.IntelData.AirHiPriScouts = 0
            aiBrain.IntelData.AirLowPriScouts = aiBrain.IntelData.AirLowPriScouts + 1

            targetData = aiBrain.InterestList.LowPriority[1]
            targetData.LastScouted = SWARMTIME()
            targetArea = targetData.Position

            aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
        else
            aiBrain.IntelData.AirLowPriScouts = 0
            aiBrain.IntelData.AirHiPriScouts = 0
        end

        --Air scout do scoutings.
        if targetArea then
            self:Stop()

            local vec = self:DoAirScoutVecs(scout, targetArea)

            while not scout.Dead and not scout:IsIdleState() do

              
                if VDist2Sq(vec[1], vec[3], scout:GetPosition()[1], scout:GetPosition()[3]) < 15625 then
                    if mustScoutArea then
                        for idx,loc in aiBrain.InterestList.MustScout do
                            if loc == mustScoutArea then
                               SWARMREMOVE(aiBrain.InterestList.MustScout, idx)
                               break
                            end
                        end
                    end
                   
                    break
                end

                if VDist3(scout:GetPosition(), targetArea) < 25 then
                    break
                end

                SWARMWAIT(50)
            end
        else
            SWARMWAIT(10)
        end
        SWARMWAIT(5)
    end
end

CountSoonMassSpotsSwarm = function(aiBrain)
    --LOG("Are we starting CountSoonMassSpotsSwarm")
    local enemies={}
    local VDist2Sq = VDist2Sq
    for i,v in ArmyBrains do
        if ArmyIsCivilian(v:GetArmyIndex()) or not IsEnemy(aiBrain:GetArmyIndex(),v:GetArmyIndex()) or v.Result=="defeat" then continue end
        local index = v:GetArmyIndex()
        local astartX, astartZ = v:GetArmyStartPos()
        local aiBrainstart = {Position={astartX, GetTerrainHeight(astartX, astartZ), astartZ},army=i}
        table.insert(enemies,aiBrainstart)
    end
    local startX, startZ = aiBrain:GetArmyStartPos()
    table.sort(enemies,function(a,b) return VDist2Sq(a.Position[1],a.Position[3],startX,startZ)<VDist2Sq(b.Position[1],b.Position[3],startX,startZ) end)
    while not aiBrain.cmanager do SWARMWAIT(20) end
    if not aiBrain.expansionMex or not aiBrain.expansionMex[1].priority then
        --initialize expansion priority
        local starts = AIUtils.AIGetMarkerLocations(aiBrain, 'Start Location')
        local Expands = AIUtils.AIGetMarkerLocations(aiBrain, 'Expansion Area')
        local BigExpands = AIUtils.AIGetMarkerLocations(aiBrain, 'Large Expansion Area')
        if not aiBrain.emanager then aiBrain.emanager={} end
        aiBrain.emanager.expands = {}
        aiBrain.emanager.enemies=enemies
        aiBrain.emanager.enemy=enemies[1]
        for _, v in Expands do
            v.expandtype='expand'
            v.mexnum=0
            v.mextable={}
            v.relevance=0
            v.owner=nil
            table.insert(aiBrain.emanager.expands,v)
        end
        for _, v in BigExpands do
            v.expandtype='bigexpand'
            v.mexnum=0
            v.mextable={}
            v.relevance=0
            v.owner=nil
            table.insert(aiBrain.emanager.expands,v)
        end
        for _, v in starts do
            v.expandtype='start'
            v.mexnum=0
            v.mextable={}
            v.relevance=0
            v.owner=nil
            table.insert(aiBrain.emanager.expands,v)
        end
        aiBrain.expansionMex={}
        local expands={}
        for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                table.sort(aiBrain.emanager.expands,function(a,b) return VDist2Sq(a.Position[1],a.Position[3],v.position[1],v.position[3])<VDist2Sq(b.Position[1],b.Position[3],v.position[1],v.position[3]) end)
                if VDist3Sq(aiBrain.emanager.expands[1].Position,v.position)<25*25 then
                    table.insert(aiBrain.emanager.expands[1].mextable,{v,Position = v.position, Name = k})
                    aiBrain.emanager.expands[1].mexnum=aiBrain.emanager.expands[1].mexnum+1
                    table.insert(aiBrain.expansionMex, {v,Position = v.position, Name = k,ExpandMex=true})
                else
                    table.insert(aiBrain.expansionMex, {v,Position = v.position, Name = k})
                end
            end
        end
        for _,v in aiBrain.expansionMex do
            table.sort(aiBrain.emanager.expands,function(a,b) return VDist2Sq(a.Position[1],a.Position[3],v.Position[1],v.Position[3])<VDist2Sq(b.Position[1],b.Position[3],v.Position[1],v.Position[3]) end)
            v.distsq=VDist2Sq(aiBrain.emanager.expands[1].Position[1],aiBrain.emanager.expands[1].Position[2],v.Position[1],v.Position[3])
            if v.ExpandMex then
                v.priority=aiBrain.emanager.expands[1].mexnum
                v.expand=aiBrain.emanager.expands[1]
                v.expand.taken=0
                v.expand.takentime=0
            else
                v.priority=1
            end
        end
    end
    aiBrain.cmanager.unclaimedmexcount=0
    local massmarkers={}
        for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
            if v.type == 'Mass' then
                if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                    -- mass marker is too close to border, skip it.
                    continue
                end 
                table.insert(massmarkers,v)
            end
        end
    while aiBrain.Result ~= "defeat" do
        local markercache=table.copy(massmarkers)
        for _=0,10 do
            local soonmexes={}
            local unclaimedmexcount=0
            for i,v in markercache do
                if not CanBuildStructureAt(aiBrain, 'ueb1103', v.position) then 
                    table.remove(markercache,i) 
                    continue 
                end
                if aiBrain:GetNumUnitsAroundPoint(categories.MASSEXTRACTION + categories.ENGINEER, v.position, 50*ScenarioInfo.size[1]/256, 'Ally')>0 then
                    unclaimedmexcount=unclaimedmexcount+1
                    table.insert(soonmexes,{Position = v.position, Name = i})
                end
            end
            aiBrain.cmanager.unclaimedmexcount=(aiBrain.cmanager.unclaimedmexcount+unclaimedmexcount)/2
            aiBrain.emanager.soonmexes=soonmexes
            --LOG(repr(aiBrain.Nickname)..' unclaimedmex='..repr(aiBrain.cmanager.unclaimedmexcount))
            SWARMWAIT(20)
        end
    end
end

function AIGetMassMarkerLocations(aiBrain, includeWater, waterOnly)
    local markerList = {}
        local markers = ScenarioUtils.GetMarkers()
        if markers then
            for k, v in markers do
                if v.type == 'Mass' then
                    if waterOnly then
                        if PositionInWater(v.position) then
                            SWARMINSERT(markerList, {Position = v.position, Name = k})
                        end
                    elseif includeWater then
                        SWARMINSERT(markerList, {Position = v.position, Name = k})
                    else
                        if not PositionInWater(v.position) then
                            SWARMINSERT(markerList, {Position = v.position, Name = k})
                        end
                    end
                end
            end
        end
    return markerList
end

function PositionInWater(pos)
	return GetTerrainHeight(pos[1], pos[3]) < GetSurfaceHeight(pos[1], pos[3])
end

---------------------------------------------
--   Tactical Missile Launcher AI Thread   --
---------------------------------------------
local MissileTimer = 0
function TMLAIThreadSwarm(platoon,self,aiBrain)
    local bp = self:GetBlueprint()
    local weapon = bp.Weapon[1]
    local maxRadius = weapon.MaxRadius or 256
    local minRadius = weapon.MinRadius or 15
    local MaxLoad = weapon.MaxProjectileStorage or 4
    self:SetAutoMode(true)
    while aiBrain:PlatoonExists(platoon) and self and not self.Dead do
        local target = false
        while self and not self.Dead and self:GetTacticalSiloAmmoCount() < 2 do
            SWARMWAIT(10)
        end
        while self and not self.Dead and self:IsPaused() do
            SWARMWAIT(10)
        end
        while self and not self.Dead and self:GetTacticalSiloAmmoCount() > 1 and not target and not self:IsPaused() do
            target = false
            while self and not self.Dead and not target do
                SWARMWAIT(10)
                while self and not self.Dead and not self:IsIdleState() do
                    SWARMWAIT(10)
                end
                if self.Dead then return end
                target = FindTargetUnit(self, minRadius, maxRadius, MaxLoad)
            end
        end
        if self and not self.Dead and target and not target.Dead and MissileTimer < SWARMTIME() then
            MissileTimer = SWARMTIME() + 1
            if SWARMENTITY(categories.STRUCTURE, target) then
                if self:GetTacticalSiloAmmoCount() >= MaxLoad then
                    IssueTactical({self}, target)
                end
            else
                targPos = LeadTarget(self, target)
                if targPos and targPos[1] > 0 and targPos[3] > 0 then
                    if SWARMENTITY(categories.EXPERIMENTAL - categories.AIR, target) or self:GetTacticalSiloAmmoCount() >= MaxLoad then
                        IssueTactical({self}, targPos)
                    end
                else
                    target = false
                end
            end
        end
        SWARMWAIT(10)
    end
end

function FindTargetUnit(self, minRadius, maxRadius, MaxLoad)
    local position = self:GetPosition()
    local aiBrain = self:GetAIBrain()
    local targets = GetEnemyUnitsInSphereOnRadar(aiBrain, position, minRadius, maxRadius)
    if not targets or not self or self.Dead then return false end
    local MissileCount = self:GetTacticalSiloAmmoCount()
    local AllTargets = {}
    local MaxHealthpoints = 0
    local UnitHealth
    local uBP
    for k, v in targets do
        -- Only check if Unit is 100% builded and not AIR
        if not v.Dead and not v:BeenDestroyed() and v:GetFractionComplete() == 1 and SWARMENTITY(categories.SELECTABLE - categories.AIR, v) then
            -- Get Target Data
            uBP = v:GetBlueprint()
            UnitHealth = uBP.Defense.Health or 1
            -- Check Targets
            if not v:BeenDestroyed() and SWARMENTITY(categories.COMMAND, v) and (not IsProtected(self,v:GetPosition())) then
                AllTargets[1] = v
            elseif not v:BeenDestroyed() and (UnitHealth > MaxHealthpoints or (UnitHealth == MaxHealthpoints and v.distance < AllTargets[2].distance)) and SWARMENTITY(categories.EXPERIMENTAL * categories.MOBILE, v) and (not IsProtected(self,v:GetPosition())) then
                AllTargets[2] = v
                MaxHealthpoints = UnitHealth
            elseif not v:BeenDestroyed() and UnitHealth > MaxHealthpoints and SWARMENTITY(categories.MOBILE, v) and uBP.StrategicIconName == 'icon_experimental_generic' and (not IsProtected(self,v:GetPosition())) then
                AllTargets[3] = v
                MaxHealthpoints = UnitHealth
            elseif not v:BeenDestroyed() and (not AllTargets[5] or v.distance < AllTargets[5].distance) and SWARMENTITY(categories.STRUCTURE - categories.WALL, v) and (not IsProtected(self,v:GetPosition())) then
                AllTargets[5] = v
                break
            elseif not v:BeenDestroyed() and v:IsMoving() == false then
                if (not AllTargets[4] or v.distance < AllTargets[4].distance) and SWARMENTITY(categories.TECH3 * categories.MOBILE * categories.INDIRECTFIRE, v) and (not IsProtected(self,v:GetPosition())) then
                    AllTargets[4] = v
                elseif (not AllTargets[6] or v.distance < AllTargets[6].distance) and SWARMENTITY(categories.ENGINEER - categories.STATIONASSISTPOD, v) and (not IsProtected(self,v:GetPosition())) then
                    AllTargets[6] = v
                elseif (not AllTargets[7] or v.distance < AllTargets[7].distance) and SWARMENTITY(categories.MOBILE, v) and (not IsProtected(self,v:GetPosition())) then
                    AllTargets[7] = v
                end
            end
        end
    end
    local TargetType = {
        "Com", -- 1 Commander
        "Exp", -- 2 Experimental. Attack order: highes maxunithealth. (not actual healthbar!)
        "Hea", -- 3 Heavy Assault. (small experimentals from Total Mayhem, Experimental Wars etc.)
        "Art", -- 4 Mobile T3 Unit with indirect Fire and only if the unit don't move. (Artillery / Missilelauncher)
        "Bui", -- 5 T1,T2,T3 Structures. Attack order: nearest completed building.
        "Eng", -- 6 Engineer (fire only on not moving units)
        "Mob", -- 7 Mobile (fire only on not moving units)
    }
    for k, v in sortedpairs(AllTargets) do
        -- Don't shoot at protected targets
        if MissileCount >= 2 then
            if k <= 3 then
                return v
            end
        end
        if MissileCount >= MaxLoad - 2 then
            if k <= 4 then
                return v
            end
        end
        if MissileCount >= MaxLoad then
            return v
        end
    end
    return false
end

function LeadTarget(launcher, target)
    -- Get launcher and target position
    local LauncherPos = launcher:GetPosition()
    local TargetPos
    -- Get target position in 1 second intervals.
    -- This allows us to get speed and direction from the target
    local TargetStartPosition=0
    local Target1SecPos=0
    local Target2SecPos=0
    local XmovePerSec=0
    local YmovePerSec=0
    local XmovePerSecCheck=-1
    local YmovePerSecCheck=-1
    local LoopSaveGuard = 0
    while target and (XmovePerSec ~= XmovePerSecCheck or YmovePerSec ~= YmovePerSecCheck) and LoopSaveGuard < 10 do
        -- 1st position of target
        TargetPos = target:GetPosition()
        TargetStartPosition = {TargetPos[1], 0, TargetPos[3]}
        SWARMWAIT(10)
        -- 2nd position of target after 1 second
        TargetPos = target:GetPosition()
        Target1SecPos = {TargetPos[1], 0, TargetPos[3]}
        XmovePerSec = (TargetStartPosition[1] - Target1SecPos[1])
        YmovePerSec = (TargetStartPosition[3] - Target1SecPos[3])
        SWARMWAIT(10)
        -- 3rd position of target after 2 seconds to verify straight movement
        TargetPos = target:GetPosition()
        Target2SecPos = {TargetPos[1], TargetPos[2], TargetPos[3]}
        XmovePerSecCheck = (Target1SecPos[1] - Target2SecPos[1])
        YmovePerSecCheck = (Target1SecPos[3] - Target2SecPos[3])
        --We leave the while-do check after 10 loops (20 seconds) and try collateral damage
        --This can happen if a player try to fool the targetingsystem by circling a unit.
        LoopSaveGuard = LoopSaveGuard + 1
    end
    -- Get launcher position height
    local fromheight = GetTerrainHeight(LauncherPos[1], LauncherPos[3])
    if GetSurfaceHeight(LauncherPos[1], LauncherPos[3]) > fromheight then
        fromheight = GetSurfaceHeight(LauncherPos[1], LauncherPos[3])
    end
    -- Get target position height
    local toheight = GetTerrainHeight(Target2SecPos[1], Target2SecPos[3])
    if GetSurfaceHeight(Target2SecPos[1], Target2SecPos[3]) > toheight then
        toheight = GetSurfaceHeight(Target2SecPos[1], Target2SecPos[3])
    end
    -- Get height difference between launcher position and target position
    -- Adjust for height difference by dividing the height difference by the missiles max speed
    local HeightDifference = SWARMABS(fromheight - toheight) / 12
    -- Speed up time is distance the missile will travel while reaching max speed (~22.47 MapUnits)
    -- divided by the missiles max speed (12) which is equal to 1.8725 seconds flight time
    local SpeedUpTime = 22.47 / 12
    --  Missile needs 3 seconds to launch
    local LaunchTime = 3
    -- Get distance from launcher position to targets starting position and position it moved to after 1 second
    local dist1 = VDist2(LauncherPos[1], LauncherPos[3], Target1SecPos[1], Target1SecPos[3])
    local dist2 = VDist2(LauncherPos[1], LauncherPos[3], Target2SecPos[1], Target2SecPos[3])
    -- Missile has a faster turn rate when targeting targets < 50 MU away, so it will level off faster
    local LevelOffTime = 0.25
    local CollisionRangeAdjust = 0
    if dist2 < 50 then
        LevelOffTime = 0.02
        CollisionRangeAdjust = 2
    end
    -- Divide both distances by missiles max speed to get time to impact
    local time1 = (dist1 / 12) + LaunchTime + SpeedUpTime + LevelOffTime + HeightDifference
    local time2 = (dist2 / 12) + LaunchTime + SpeedUpTime + LevelOffTime + HeightDifference
    -- Get the missile travel time by extrapolating speed and time from dist1 and dist2
    local MissileTravelTime = (time2 + (time2 - time1)) + ((time2 - time1) * time2)
    -- Now adding all times to get final missile flight time to the position where the target will be
    local MissileImpactTime = MissileTravelTime + LaunchTime + SpeedUpTime + LevelOffTime + HeightDifference
    -- Create missile impact corrdinates based on movePerSec * MissileImpactTime
    local MissileImpactX = Target2SecPos[1] - (XmovePerSec * MissileImpactTime)
    local MissileImpactY = Target2SecPos[3] - (YmovePerSec * MissileImpactTime)
    -- Adjust for targets CollisionOffsetY. If the hitbox of the unit is above the ground
    -- we nedd to fire "behind" the target, so we hit the unit in midair.
    local TargetCollisionBoxAdjust = 0
    local TargetBluePrint = target:GetBlueprint()
    if TargetBluePrint.CollisionOffsetY and TargetBluePrint.CollisionOffsetY > 0 then
        -- if the unit is far away we need to target farther behind the target because of the projectile flight angel
        local DistanceOffset = (100 / 256 * dist2) * 0.06
        TargetCollisionBoxAdjust = TargetBluePrint.CollisionOffsetY * CollisionRangeAdjust + DistanceOffset
    end
    -- To calculate the Adjustment behind the target we use a variation of the Pythagorean theorem. (Percent scale technique)
    -- (a²+b²=c²) If we add x% to c² then also a² and b² are x% larger. (a²)*x% + (b²)*x% = (c²)*x%
    local Hypotenuse = VDist2(LauncherPos[1], LauncherPos[3], MissileImpactX, MissileImpactY)
    local HypotenuseScale = 100 / Hypotenuse * TargetCollisionBoxAdjust
    local aLegScale = (MissileImpactX - LauncherPos[1]) / 100 * HypotenuseScale
    local bLegScale = (MissileImpactY - LauncherPos[3]) / 100 * HypotenuseScale
    -- Add x percent (behind) the target coordinates to get our final missile impact coordinates
    MissileImpactX = MissileImpactX + aLegScale
    MissileImpactY = MissileImpactY + bLegScale
    -- Cancel firing if target is outside map boundries
    if MissileImpactX < 0 or MissileImpactY < 0 or MissileImpactX > ScenarioInfo.size[1] or MissileImpactY > ScenarioInfo.size[2] then
        return false
    end
    -- Also cancel if target would be out of weaponrange or inside minimum range.
    local LauncherBluePrint = launcher:GetBlueprint()
    local maxRadius = LauncherBluePrint.Weapon[1].MaxRadius or 256
    local minRadius = LauncherBluePrint.Weapon[1].MinRadius or 15
    local dist3 = VDist2(LauncherPos[1], LauncherPos[3], MissileImpactX, MissileImpactY)
    if dist3 < minRadius or dist3 > maxRadius then
        return false
    end
    -- return extrapolated target position / missile impact coordinates
    return {MissileImpactX, Target2SecPos[2], MissileImpactY}
end

function GetEnemyUnitsInSphereOnRadar(aiBrain, position, minRadius, maxRadius)
    local x1 = position[1] - maxRadius
    local z1 = position[3] - maxRadius
    local x2 = position[1] + maxRadius
    local z2 = position[3] + maxRadius
    local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
    if not UnitsinRec then
        return UnitsinRec
    end
    local SelfArmyIndex = aiBrain:GetArmyIndex()
    local RadEntities = {}
    SWARMWAIT(1)
    local lagstopper = 0
    for Index, EnemyUnit in UnitsinRec do
        lagstopper = lagstopper + 1
        if lagstopper > 20 then
            SWARMWAIT(1)
            lagstopper = 0
        end
        if (not EnemyUnit.Dead) and IsEnemy( SelfArmyIndex, EnemyUnit:GetArmy() ) then
            local EnemyPosition = EnemyUnit:GetPosition()
            -- check if the target is under water.
            local SurfaceHeight = GetSurfaceHeight(EnemyPosition[1], EnemyPosition[3])
            if EnemyPosition[2] < SurfaceHeight - 0.5 then
                continue
            end
            local dist = VDist2(position[1], position[3], EnemyPosition[1], EnemyPosition[3])
            if (dist <= maxRadius) and (dist > minRadius) then
                local blip = EnemyUnit:GetBlip(SelfArmyIndex)
                if blip then
                    if blip:IsOnRadar(SelfArmyIndex) or blip:IsSeenEver(SelfArmyIndex) then
                        if not blip:BeenDestroyed() and not blip:IsKnownFake(SelfArmyIndex) and not blip:IsMaybeDead(SelfArmyIndex) then
                            EnemyUnit.distance = dist
                            SWARMINSERT(RadEntities, EnemyUnit)
                        end
                    end
                end
            end
        end
    end
    return RadEntities
end

function IsProtected(self,position)
    local maxRadius = 14
    local x1 = position.x - maxRadius
    local z1 = position.z - maxRadius
    local x2 = position.x + maxRadius
    local z2 = position.z + maxRadius
    local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
    if not UnitsinRec then
        return false
    end
    SWARMWAIT(1)
    local lagstopper = 0
    local counter = 0
    for _, EnemyUnit in UnitsinRec do
        counter = counter + 1
        lagstopper = lagstopper + 1
        if lagstopper > 20 then
            SWARMWAIT(1)
            lagstopper = 0
        end
        if (not EnemyUnit.Dead) and IsEnemy( self:GetArmy(), EnemyUnit:GetArmy() ) then
            if SWARMENTITY(categories.ANTIMISSILE * categories.TECH2 * categories.STRUCTURE, EnemyUnit) then
                local EnemyPosition = EnemyUnit:GetPosition()
                local dist = VDist2(position[1], position[3], EnemyPosition[1], EnemyPosition[3])
                if dist <= maxRadius then
                    return true
                end
            end
        end
    end
    return false
end