local import = import

local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
local AIUtils = import('/lua/ai/aiutilities.lua')
local ToString = import('/lua/sim/CategoryUtils.lua').ToString

local SWARMGETN = table.getn
local SWARMINSERT = table.insert
local SWARMREMOVE = table.remove
local SWARMSORT = table.sort
local SWARMWAIT = coroutine.yield
local SWARMFLOOR = math.floor
local SWARMRANDOM = math.random
local SWARMSQRT = math.sqrt
local SWARMPOW = math.pow
local SWARMMAX = math.max
local SWARMMIN = math.min
local SWARMABS = math.abs
local SWARMCEIL = math.ceil
local SWARMPI = math.pi
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
        local StructurePool = aiBrain:MakePlatoon('StructurePool', 'none')
        StructurePool:UniquelyNamePlatoon('StructurePool')
        StructurePool.BuilderName = 'Structure Pool'
        aiBrain.StructurePool = StructurePool
    end

    if not aiBrain.FactoryPool then
        --LOG('* AI-Swarm: Creating FactoryPool Pool Platoon')
        local factoryPool = aiBrain:MakePlatoon('FactoryPool', 'none')
        factoryPool:UniquelyNamePlatoon('FactoryPool')
        factoryPool.BuilderName = 'Factory Pool'
        aiBrain.FactoryPool = factoryPool
    end
end

-- 99% of the below was Sprouto's work
function StructureUpgradeInitializeSwarm(finishedUnit, aiBrain)
    --LOG("StructureUpgradeIntializeSwarm starting for " ..repr(finishedUnit:GetBlueprint().Description))

    local StructureUpgradeThreadSwarm = import('/lua/ai/aibehaviors.lua').StructureUpgradeThreadSwarm
    local StructurePool = aiBrain.StructurePool
    local FactoryPool = aiBrain.FactoryPool
    local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
    --LOG('* AI-Swarm: Structure Upgrade Initializing')
    if EntityCategoryContains(categories.MASSEXTRACTION, finishedUnit) then
        local extractorPlatoon = aiBrain:MakePlatoon('ExtractorPlatoon'..tostring(finishedUnit.Sync.id), 'none')
        extractorPlatoon.BuilderName = 'ExtractorPlatoon'..tostring(finishedUnit.Sync.id)
        extractorPlatoon.MovementLayer = 'Land'
        --LOG('* AI-Swarm: Assigning Extractor to new platoon')
        AssignUnitsToPlatoon(aiBrain, extractorPlatoon, {finishedUnit}, 'Support', 'none')
        finishedUnit.PlatoonHandle = extractorPlatoon
        extractorPlatoon:ForkThread( extractorPlatoon.ExtractorCallForHelpAISwarm, aiBrain )

        if not finishedUnit.UpgradeThread then
            --LOG('* AI-Swarm: Forking Upgrade Thread')
            upgradeSpec = aiBrain:GetUpgradeSpecSwarm(finishedUnit)
            --LOG('* AI-Swarm: UpgradeSpec'..repr(upgradeSpec))
            finishedUnit.UpgradeThread = finishedUnit:ForkThread(StructureUpgradeThreadSwarm, aiBrain, upgradeSpec, false)
        end
    elseif EntityCategoryContains(categories.FACTORY * categories.STRUCTURE, finishedUnit) then
        local factoryPlatoon = aiBrain:MakePlatoon('FactoryPlatoon'..tostring(finishedUnit.Sync.id), 'none')
        factoryPlatoon.BuilderName = 'FactoryPlatoon'..tostring(finishedUnit.Sync.id)
        factoryPlatoon.MovementLayer = 'Land'
        --LOG('* AI-Swarm: Assigning Factory to new platoon')
        AssignUnitsToPlatoon(aiBrain, factoryPlatoon, {finishedUnit}, 'Support', 'none')
        finishedUnit.PlatoonHandle = factoryPlatoon

        if not finishedUnit.UpgradeThread then
            --LOG('* AI-Swarm: Forking Upgrade Thread')
            upgradeSpec = aiBrain:GetUpgradeSpecSwarm(finishedUnit)
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

-- Start of Zone Area Support Functions

GenerateDistinctColorTableSwarm = function(num)
    local function factorial(n,min)
        if n>min and n>1 then
            return n*factorial(n-1)
        else
            return n
        end
    end
    local function combintoid(a,b,c)
        local o=tostring(0)
        local tab={a,b,c}
        local tabid={}
        for k,v in tab do
            local n=v
            tabid[k]=tostring(v)
            while n<1000 do
                n=n*10
                tabid[k]=o..tabid[k]
            end
        end
        return tabid[1]..tabid[2]..tabid[3]
    end
    local i=0
    local n=1
    while i<num do
        n=n+1
        i=n*n*n-n
    end
    local ViableValues={}
    for x=0,256,256/(n-1) do
        SWARMINSERT(ViableValues,ToColorSwarm(0,256,x/256))
    end
    local colortable={}
    local combinations={}
    --[[for k,v in ViableValues do
        table.insert(colortable,v..v..v)
        combinations[combintoid(k,k,k)]=1
    end]]
    local max=ViableValues[SWARMGETN(ViableValues)]
    local min=ViableValues[1]
    local primaries={min..min..min,max..max..min,max..min..max,min..max..max,max..min..min,min..max..min,min..min..max,max..max..max}
    combinations[combintoid(max,max,min)]=1
    combinations[combintoid(max,min,max)]=1
    combinations[combintoid(min,max,max)]=1
    combinations[combintoid(max,min,min)]=1
    combinations[combintoid(min,max,min)]=1
    combinations[combintoid(min,min,max)]=1
    combinations[combintoid(max,max,max)]=1
    combinations[combintoid(min,min,min)]=1
    for a,d in ViableValues do
        for b,e in ViableValues do
            for c,f in ViableValues do
                if not combinations[combintoid(a,b,c)] and not (a==b and b==c) then
                    SWARMINSERT(colortable,d..e..f)
                    combinations[combintoid(a,b,c)]=1
                end
            end
        end
    end
    for _,v in primaries do
        SWARMINSERT(colortable,v)
    end
    return colortable
end
function DisplayMarkerAdjacencySwarm(aiBrain)
    --aiBrain:ForkThread(LastKnownThread)
    local expansionMarkers = Scenario.MasterChain._MASTERCHAIN_.Markers
    local VDist3Sq = VDist3Sq
    aiBrain.SwarmAreas={}
    aiBrain.armyspots={}
    aiBrain.expandspots={}
    aiBrain.masspoints = {}
    for k,marker in expansionMarkers do
        local node=false
        local expand=false
        local mass=false
        --LOG(repr(k)..' marker type is '..repr(marker.type))
        for i, v in STR_GetTokens(marker.type,' ') do
            if v=='Node' then
                node=true
                break
            end
            if v=='Expansion' then
                expand=true
                break
            end
            if v=='Mass' then
                mass=true
                break
            end
        end
        if node and not marker.SwarmArea then
            aiBrain.SwarmAreas[k]={}
            InfectMarkersSwarm(aiBrain,marker,k)
        end
        if expand then
            SWARMINSERT(aiBrain.expandspots,{marker,k})
        end
        if mass then
            SWARMINSERT(aiBrain.masspoints,{marker,k})
        end
        if not node and not expand and not mass then
            for _,v in STR_GetTokens(k,'_') do
                if v=='ARMY' then
                    SWARMINSERT(aiBrain.armyspots,{marker,k})
                    SWARMINSERT(aiBrain.expandspots,{marker,k})
                end
            end
        end
    end
    aiBrain.analysistablecolors={}
    local tablecolors=GenerateDistinctColorTableSwarm(SWARMGETN(aiBrain.expandspots))
    local colors=aiBrain.analysistablecolors
    --WaitSeconds(10)
    --LOG('colortable is'..repr(tablecolors))
    local bases=false
    if bases then
        for _,army in aiBrain.armyspots do
            local closestpath=Scenario.MasterChain._MASTERCHAIN_.Markers[AIAttackUtils.GetClosestPathNodeInRadiusByLayer(army[1].position,25,'Land').name]
            --LOG('closestpath is '..repr(closestpath))
            aiBrain.renderthreadtracker=ForkThread(DoArmySpotDistanceInfectSwarm,aiBrain,closestpath,army[2])
            local randy=SWARMRANDOM(SWARMGETN(tablecolors))
            colors[army[2]]='FF'..tablecolors[randy]
            SWARMREMOVE(tablecolors,randy)
        end
    else
        for i,v in ArmyBrains do
            if ArmyIsCivilian(v:GetArmyIndex()) or v.Result=="defeat" then continue end
            local astartX, astartZ = v:GetArmyStartPos()
            local army = {position={astartX, GetTerrainHeight(astartX, astartZ), astartZ},army=i,brain=v}
            SWARMSORT(aiBrain.expandspots,function(a,b) return VDist3Sq(a[1].position,army.position)<VDist3Sq(b[1].position,army.position) end)
            local closestpath=Scenario.MasterChain._MASTERCHAIN_.Markers[AIAttackUtils.GetClosestPathNodeInRadiusByLayer(aiBrain.expandspots[1][1].position,25,'Land').name]
            --LOG('closestpath is '..repr(closestpath))
            aiBrain.renderthreadtracker=ForkThread(DoArmySpotDistanceInfectSwarm,aiBrain,closestpath,aiBrain.expandspots[1][2])
            local randy=nil
            if i<9 then
                randy=SWARMRANDOM(SWARMGETN(tablecolors)-7+i,SWARMGETN(tablecolors))
            else
                randy=SWARMRANDOM(SWARMGETN(tablecolors))
            end
            colors[aiBrain.expandspots[1][2]]=tablecolors[randy]
            SWARMREMOVE(tablecolors,randy)
        end
    end
    local expands=true
    local expandcolors={}
    while aiBrain.renderthreadtracker do
        SWARMWAIT(2)
    end
    if expands then
        --tablecolors=GenerateDistinctColorTable(SWARMGETN(aiBrain.expandspots))
        for _,expand in aiBrain.expandspots do
            local closestpath=Scenario.MasterChain._MASTERCHAIN_.Markers[AIAttackUtils.GetClosestPathNodeInRadiusByLayer(expand[1].position,25,'Land').name]
            --LOG('closestpath is '..repr(closestpath))
            aiBrain.renderthreadtracker=ForkThread(DoExpandSpotDistanceInfectSwarm,aiBrain,closestpath,expand[2])
            local randy=SWARMRANDOM(SWARMGETN(tablecolors))
            if colors[expand[2]] then continue end
            colors[expand[2]]=tablecolors[randy]
            SWARMREMOVE(tablecolors,randy)
        end
    end
    local massPointCount = 0
    for _, mass in aiBrain.masspoints do
        massPointCount = massPointCount + 1
        local closestpath=Scenario.MasterChain._MASTERCHAIN_.Markers[AIAttackUtils.GetClosestPathNodeInRadiusByLayer(mass[1].position,25,'Land').name]
        aiBrain.renderthreadtracker=ForkThread(DoMassPointInfectSwarm,aiBrain,closestpath,mass[2])
    end
    aiBrain.MassMarker = massPointCount
    while aiBrain.renderthreadtracker do
        SWARMWAIT(2)
    end
    --LOG('SwarmAreas:')
    --for k,v in aiBrain.SwarmAreas do
    --    LOG(repr(k)..' has '..repr(SWARMGETN(v))..' nodes')
    --end
    if aiBrain.GraphZonesSwarm.FirstRun then
        aiBrain.GraphZonesSwarm.FirstRun = false
    end
end

function InfectMarkersSwarm(aiBrain,marker,graphname)
    marker.SwarmArea=graphname
    SWARMINSERT(aiBrain.SwarmAreas[graphname],marker)
    for i, node in STR_GetTokens(marker.adjacentTo or '', ' ') do
        if not Scenario.MasterChain._MASTERCHAIN_.Markers[node].SwarmArea then
            InfectMarkersSwarm(aiBrain,Scenario.MasterChain._MASTERCHAIN_.Markers[node],graphname)
        end
    end
end

function DoArmySpotDistanceInfectSwarm(aiBrain,marker,army)
    aiBrain.renderthreadtracker=CurrentThread()
    SWARMWAIT(1)
    --DrawCircle(marker.position,5,'FF'..aiBrain.analysistablecolors[army])
    if not marker then LOG('No Marker sent to army distance check') return end
    if not marker.armydists then
        marker.armydists={}
    end
    if not marker.armydists[army] then
        marker.armydists[army]=0
    end
    local potentialdists={}
    for i, node in STR_GetTokens(marker.adjacentTo or '', ' ') do
        if node=='' then continue end
        local adjnode=Scenario.MasterChain._MASTERCHAIN_.Markers[node]
        local skip=false
        local bestdist=nil
        local adjdist=VDist3(marker.position,adjnode.position)
        if adjnode.armydists then
            for k,v in adjnode.armydists do
                --[[if not bestdist or v<bestdist then
                    bestdist=v
                end
                if k~=army and v<marker.armydists[army] then
                    skip=true
                end]]
                if not potentialdists[k] or potentialdists[k]>v then
                    potentialdists[k]=v+adjdist
                end
            end
        end
        if not adjnode.armydists then adjnode.armydists={} end
        if not adjnode.armydists[army] then
            adjnode.armydists[army]=adjdist+marker.armydists[army]
            
            --table.insert(aiBrain.renderlines,{marker.position,Scenario.MasterChain._MASTERCHAIN_.Markers[node].position,marker.type,army})
            ForkThread(DoArmySpotDistanceInfectSwarm,aiBrain,adjnode,army)
        elseif adjnode.armydists[army]>adjdist+marker.armydists[army] then
            adjnode.armydists[army]=adjdist+marker.armydists[army]
            adjnode.bestarmy=army
            ForkThread(DoArmySpotDistanceInfectSwarm,aiBrain,adjnode,army)
        end
    end
    for k,v in marker.armydists do
        if potentialdists[k]<v then
            v=potentialdists[k]
        end
    end
    for k,v in marker.armydists do
        if not marker.bestarmy or marker.armydists[marker.bestarmy]>v then
            marker.bestarmy=k
        end
    end
    SWARMWAIT(1)
    if aiBrain.renderthreadtracker==CurrentThread() then
        aiBrain.renderthreadtracker=nil
    end
end

function DoExpandSpotDistanceInfectSwarm(aiBrain,marker,expand)
    aiBrain.renderthreadtracker=CurrentThread()
    SWARMWAIT(1)
    --DrawCircle(marker.position,4,'FF'..aiBrain.analysistablecolors[expand])
    if not marker then return end
    if not marker.expanddists then
        marker.expanddists={}
    end
    if not marker.expanddists[expand] then
        marker.expanddists[expand]=0
    end
    local potentialdists={}
    for i, node in STR_GetTokens(marker.adjacentTo or '', ' ') do
        if node=='' then continue end
        local adjnode=Scenario.MasterChain._MASTERCHAIN_.Markers[node]
        local skip=false
        local bestdist=nil
        local adjdist=VDist3(marker.position,adjnode.position)
        if adjnode.expanddists then
            for k,v in adjnode.expanddists do
                --[[if not bestdist or v<bestdist then
                    bestdist=v
                end
                if k~=expand and v<marker.expanddists[expand] then
                    skip=true
                end]]
                if not potentialdists[k] or potentialdists[k]>v then
                    potentialdists[k]=v+adjdist
                end
            end
        end
        if not adjnode.expanddists then adjnode.expanddists={} end
        if not adjnode.expanddists[expand] then
            adjnode.expanddists[expand]=adjdist+marker.expanddists[expand]
            --table.insert(aiBrain.renderlines,{marker.position,Scenario.MasterChain._MASTERCHAIN_.Markers[node].position,marker.type,expand})
            ForkThread(DoExpandSpotDistanceInfectSwarm,aiBrain,adjnode,expand)
        elseif adjnode.expanddists[expand]>adjdist+marker.expanddists[expand] then
            adjnode.expanddists[expand]=adjdist+marker.expanddists[expand]
            adjnode.bestexpand=expand
            ForkThread(DoExpandSpotDistanceInfectSwarm,aiBrain,adjnode,expand)
        end
    end
    for k,v in marker.expanddists do
        if potentialdists[k]<v then
            v=potentialdists[k]
        end
    end
    for k,v in marker.expanddists do
        if not marker.bestexpand or marker.expanddists[marker.bestexpand]>v then
            marker.bestexpand=k
            -- Important. Extension to chps logic to add SwarmArea to expansion markers so we can tell if we own expansions on islands etc
            if not Scenario.MasterChain._MASTERCHAIN_.Markers[k].SwarmArea then
                Scenario.MasterChain._MASTERCHAIN_.Markers[k].SwarmArea = marker.SwarmArea
                --LOG('ExpansionMarker '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[k]))
            end
        end
    end
    SWARMWAIT(1)
    if aiBrain.renderthreadtracker==CurrentThread() then
        aiBrain.renderthreadtracker=nil
    end
end

function DoMassPointInfectSwarm(aiBrain,marker,masspoint)
    aiBrain.renderthreadtracker=CurrentThread()
    SWARMWAIT(1)
    --DrawCircle(marker.position,4,'FF'..aiBrain.analysistablecolors[expand])
    if not marker then return end
    if not Scenario.MasterChain._MASTERCHAIN_.Markers[masspoint].SwarmArea then
        Scenario.MasterChain._MASTERCHAIN_.Markers[masspoint].SwarmArea = marker.SwarmArea
        --LOG('MassMarker '..repr(Scenario.MasterChain._MASTERCHAIN_.Markers[masspoint]))
    end
    SWARMWAIT(1)
    if aiBrain.renderthreadtracker==CurrentThread() then
        aiBrain.renderthreadtracker=nil
    end
end


GrabRandomDistinctColorSwarm = function(num)
    local output=GenerateDistinctColorTableSwarm(num)
    return output[SWARMRANDOM(SWARMGETN(output))]
end

ToColorSwarm = function(min,max,ratio)
    local ToBase16 = function(num)
        if num<10 then
            return tostring(num)
        elseif num==10 then
            return 'a'
        elseif num==11 then
            return 'b'
        elseif num==12 then
            return 'c'
        elseif num==13 then
            return 'd'
        elseif num==14 then
            return 'e'
        else
            return 'f'
        end
    end
    local baseones=0
    local basetwos=0
    local numinit=SWARMABS(SWARMCEIL((max-min)*ratio+min))
    basetwos=SWARMFLOOR(numinit/16)
    baseones=numinit-basetwos*16
    return ToBase16(basetwos)..ToBase16(baseones)
end

function CalculateMassValueSwarm(expansionMarkers)
    local MassMarker = {}
    local VDist2Sq = VDist2Sq
    if not expansionMarkers then
        WARN('No Expansion Markers Passed to calcuatemassvalue')
    end
    for _, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
        if v.type == 'Mass' then
            if v.position[1] <= 8 or v.position[1] >= ScenarioInfo.size[1] - 8 or v.position[3] <= 8 or v.position[3] >= ScenarioInfo.size[2] - 8 then
                continue
            end
            SWARMINSERT(MassMarker, {Position = v.position})
        end
    end
    for k, v in expansionMarkers do
        local masscount = 0
        for k2, v2 in MassMarker do
            if VDist2Sq(v.Position[1], v.Position[3], v2.Position[1], v2.Position[3]) > 6400 then
                continue
            end
            masscount = masscount + 1
        end        
        -- insert mexcount into marker
        v.MassPoints = masscount
        --SPEW('* AI-Swarm: CreateMassCount: Node: '..v.Type..' - MassSpotsInRange: '..v.MassPoints)
    end
    return expansionMarkers
end

function AIConfigureExpansionWatchTableSwarm(aiBrain)
    SWARMWAIT(20)
    local VDist2Sq = VDist2Sq
    local markerList = {}
    local armyStarts = {}
    local expansionMarkers = Scenario.MasterChain._MASTERCHAIN_.Markers
    local massPointValidated = false
    local myArmy = ScenarioInfo.ArmySetup[aiBrain.Name]
    --LOG('Run ExpansionWatchTable Config')

    for i = 1, 16 do
        local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
        local startPos = ScenarioUtils.GetMarker('ARMY_' .. i).position
        if army and startPos then
            SWARMINSERT(armyStarts, startPos)
        end
    end
    --LOG(' Army Starts'..repr(armyStarts))

    if expansionMarkers then
        --LOG('Initial expansionMarker list is '..repr(expansionMarkers))
        for k, v in expansionMarkers do
            local startPosUsed = false
            if v.type == 'Expansion Area' or v.type == 'Large Expansion Area' or v.type == 'Blank Marker' then
                for _, p in armyStarts do
                    if p == v.position then
                        --LOG('Position Taken '..repr(v)..' and '..repr(v.position))
                        startPosUsed = true
                        break
                    end
                end
                if not startPosUsed then
                    if v.MassSpotsInRange then
                        massPointValidated = true
                        SWARMINSERT(markerList, {Name = k, Position = v.position, Type = v.type, TimeStamp = 0, MassPoints = v.MassSpotsInRange, Land = 0, Structures = 0, Commander = 0, PlatoonAssigned = false, ScoutAssigned = false, Zone = false})
                    else
                        SWARMINSERT(markerList, {Name = k, Position = v.position, Type = v.type, TimeStamp = 0, MassPoints = 0, Land = 0, Structures = 0, Commander = 0, PlatoonAssigned = false, ScoutAsigned = false, Zone = false})
                    end
                end
            end
        end
    end
    if not massPointValidated then
        markerList = CalculateMassValueSwarm(markerList)
    end
    --LOG('Army Setup '..repr(ScenarioInfo.ArmySetup))
    local startX, startZ = aiBrain:GetArmyStartPos()
    SWARMSORT(markerList,function(a,b) return VDist2Sq(a.Position[1],a.Position[3],startX, startZ)>VDist2Sq(b.Position[1],b.Position[3],startX, startZ) end)
    aiBrain.ExpansionWatchTableSwarm = markerList
    --LOG('ExpansionWatchTableSwarm is '..repr(markerList))
end

function QueryExpansionTableSwarm(aiBrain, location, radius, movementLayer, threat)
    -- Should be a multipurpose Expansion query that can provide units, acus a place to go
    if not aiBrain.ExpansionWatchTableSwarm then
        WARN('No ExpansionWatchTable. Maybe it hasnt been created yet or something is broken')
        SWARMWAIT(50)
        return false
    end
    

    local MainPos = aiBrain.BuilderManagers.MAIN.Position
    if VDist2Sq(location[1], location[3], MainPos[1], MainPos[3]) > 3600 then
        return false
    end
    local positionNode = Scenario.MasterChain._MASTERCHAIN_.Markers[AIAttackUtils.GetClosestPathNodeInRadiusByLayer(location, radius, movementLayer).name]
    local centerPoint = aiBrain.MapCenterPointSwarm
    local mainBaseToCenter = VDist2Sq(MainPos[1], MainPos[3], centerPoint[1], centerPoint[3])
    local bestExpansions = {}
    local options = {}
    local currentGameTime = GetGameTimeSeconds()

    if positionNode.SwarmArea then
        for k, expansion in aiBrain.ExpansionWatchTableSwarm do
            if expansion.Zone == positionNode.SwarmArea then
                --LOG('Distance to expansion '..VDist2Sq(location[1], location[3], expansion.Position[1], expansion.Position[3]))
                -- Check if this expansion has been staged already in the last 30 seconds unless there is land threat present
                --LOG('Expansion last visited timestamp is '..expansion.TimeStamp)
                if currentGameTime - expansion.TimeStamp > 45 or expansion.Land > 0 then
                    if VDist2Sq(location[1], location[3], expansion.Position[1], expansion.Position[3]) < radius * radius then
                        --LOG('Expansion Zone is within radius')
                        if VDist2Sq(MainPos[1], MainPos[3], expansion.Position[1], expansion.Position[3]) < (VDist2Sq(MainPos[1], MainPos[3], centerPoint[1], centerPoint[3]) + 900) then
                            --LOG('Expansion is not behind us, we are at '..repr(location))
                            --LOG('Expansion has '..expansion.MassPoints..' mass points')
                            --LOG('Expansion is '..expansion.Name..' at '..repr(expansion.Position))
                            if expansion.MassPoints > 1 then
                                SWARMINSERT(options, {Expansion = expansion, Value = expansion.MassPoints, Key = k})
                            end
                        else
                            --LOG('Expansion is beyond the center point')
                            --LOG('Distance from main base to expansion '..VDist2Sq(MainPos[1], MainPos[3], expansion.Position[1], expansion.Position[3]))
                            --LOG('Should be less than ')
                            --LOG('Distance from main base to center point '..VDist2Sq(MainPos[1], MainPos[3], centerPoint[1], centerPoint[3]))
                        end
                    end
                else
                    --LOG('This expansion has already been checked in the last 45 seconds')
                end
            end
        end
        local optionCount = 0
        for k, withinRadius in options do
            if mainBaseToCenter > VDist2Sq(withinRadius.Expansion.Position[1], withinRadius.Expansion.Position[3], centerPoint[1], centerPoint[3]) then
                --LOG('Expansion has high mass value at location '..withinRadius.Expansion.Name..' at position '..repr(withinRadius.Expansion.Position))
                SWARMINSERT(bestExpansions, withinRadius)
            else
                --LOG('Expansion is behind the main base , position '..repr(withinRadius.Expansion.Position))
            end
        end
    else
        WARN('No SwarmArea in path node, either its not created yet or the marker analysis hasnt happened')
    end
    --LOG('We have '..SwarmGETN(bestExpansions)..' expansions to pick from')
    if SWARMGETN(bestExpansions) > 0 then
        return bestExpansions[Random(1,SWARMGETN(bestExpansions))] 
    end
    return false
end

-- End of Area Zone Support Functions

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

function EdgeDistance(x,y,mapwidth)
    local edgeDists = { x, y, SWARMABS(x-mapwidth), SWARMABS(y-mapwidth)}
    SWARMSORT(edgeDists, function(k1, k2) return k1 < k2 end)
    return edgeDists[1]
end

function NormalizeVector( v )
	if v.x then
		v = {v.x, v.y, v.z}
    end
    local length = SWARMSQRT( SWARMPOW( v[1], 2 ) + SWARMPOW( v[2], 2 ) + SWARMPOW(v[3], 2 ) )

    if length > 0 then
        local invlength = 1 / length
        return Vector( v[1] * invlength, v[2] * invlength, v[3] * invlength )
    else
        return Vector( 0,0,0 )
    end
end

function GetDirectionVector( v1, v2 )
    return NormalizeVector( Vector(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]) )
end

function GetDirectionInDegrees( v1, v2 )
    local SWARMACOS = math.acos
	local vec = GetDirectionVector( v1, v2)
	
	if vec[1] >= 0 then
		return SWARMACOS(vec[3]) * (360/(SWARMPI*2))
	end
	
	return 360 - (SWARMACOS(vec[3]) * (360/(SWARMPI*2)))
end

-- This is softles, I was curious to see what it looked like compared to lerpy. Used in scouts avoiding enemy tanks.
function AvoidLocationSwarm(pos,target,dist)
    if not target then
        return pos
    elseif not pos then
        return target
    end
    local delta = VDiff(target,pos)
    local norm = SWARMMAX(VDist2(delta[1],delta[3],0,0),1)
    local x = pos[1]+dist*delta[1]/norm
    local z = pos[3]+dist*delta[3]/norm
    x = SWARMMIN(ScenarioInfo.size[1]-5,SWARMMAX(5,x))
    z = SWARMMIN(ScenarioInfo.size[2]-5,SWARMMAX(5,z))
    return {x,GetSurfaceHeight(x,z),z}
end

function RandomizePositionSwarm(position)
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

function RandomizePositionTMLSwarm(position)
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
        aiBrain:BuildScoutLocationsSwarm()
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

-- CountSoonMassSpotsSwarmPerf&Improved = function(aiBrain)
--     --LOG("Are we starting CountSoonMassSpotsSwarm2")
--     local enemies={}
--     local VDist2Sq = VDist2Sq
--     for i,v in ArmyBrains do
--         if ArmyIsCivilian(v:GetArmyIndex()) or not IsEnemy(aiBrain:GetArmyIndex(),v:GetArmyIndex()) or v.Result=="defeat" then continue end
--         local index = v:GetArmyIndex()
--         local astartX, astartZ = v:GetArmyStartPos()
--         local aiBrainstart = {Position={astartX, GetTerrainHeight(astartX, astartZ), astartZ},army=i}
--         table.insert(enemies,aiBrainstart)
--     end

--     while not aiBrain.cmanager do SWARMWAIT(20) end

--     if not aiBrain.emanager then  aiBrain.emanager={} end

--     if not aiBrain.expansionMex or not aiBrain.expansionMex[1].priority then
--         --initialize expansion priority
--         local starts = AIUtils.AIGetMarkerLocations(aiBrain, 'Start Location')
--         local Expands = AIUtils.AIGetMarkerLocations(aiBrain, 'Expansion Area')
--         local BigExpands = AIUtils.AIGetMarkerLocations(aiBrain, 'Large Expansion Area')

--         aiBrain.emanager.expands = {}
--         aiBrain.emanager.enemies=enemies
--         aiBrain.emanager.enemy=enemies[1]

--         for _, v in Expands do
--             v.expandtype='expand'
--             v.mexnum=0
--             v.mextable={}
--             v.relevance=0
--             v.owner=nil  -- owner is the army that owns this mex spot (or nil if unclaimed)  - used to determine who can build on it and when to remove it from the list of spots that need engineers sent to them  - see AssignEngineerToMexSpot() and RemoveUnclaimedMexSpot()
--             table.insert(aiBrain.emanager.expands,v)
--         end

--         for _, v in BigExpands do
--             v.expandtype='bigexpand'
--             v.mexnum=0
--             v.mextable={}
--             v.relevance=0
--             v.owner=nil  -- owner is the army that owns this mex spot (or nil if unclaimed)  - used to determine who can build on it and when to remove it from the list of spots that need engineers sent to them  - see AssignEngineerToMexSpot() and RemoveUnclaimedMexSpot()
--             table.insert(aiBrain.emanager.expands,v)
--         end

--         for _, v in starts do
--             v.expandtype='start'
--             v.mexnum=0
--             v.mextable={}
--             v.relevance=0   -- relevance is a number indicating how important a spot is - used to determine which engineer gets sent there first  - see AssignEngineerToMexSpot() and RemoveUnclaimedMexSpot()  - higher numbers are more important
--             v.owner=nil  -- owner is the army that owns this mex spot (or nil if unclaimed)  - used to determine who can build on it and when to remove it from the list of spots that need engineers sent to them  - see AssignEngineerToMexSpot() and RemoveUnclaimedMexSpot()
--             table.insert(aiBrain.emanager.expands,v)
--         end

--         aiBrain.expansionMex={}

--         local expands={}
--         for k, v in Scenario.MasterChain._MASTERCHAIN_.Markers do
--             if v.type == 'Mass' then
--                 table.sort(aiBrain.emanager.expands,function(a,b) return VDist2Sq(a.Position[1],a.Position[3],v.position[1],v.position[3])<VDist2Sq(b.Position[1],b.Position[3],v.position[1],v.position[3]) end)
--                 if VDist3Sq(aiBrain.emanager.expands[1].Position,v['position'])<25*25 then
--                     table.insert(aiBrain.emanager.expands[1].mextable,{v,Position = v['position'], Name = k})
--                     aiBrain.emanager.expands[1].mexnum=aiBrain.emanager.expands[1].mexnum+1
--                     table.insert(aiBrain.expansionMex, {v,Position = v['position'], Name = k,ExpandMex=true})
--                 else
--                     table.insert(aiBrain.expansionMex, {v,Position = v['position'], Name = k})
--                 end
--             end
--         end

--         for _,v in aiBrain.expansionMex do  -- go through all expansion mexes and set their priority to 1 if they're not already claimed by someone else (ie: don't overwrite the value if it's already there)  - used to determine which engineer gets sent there first  - see AssignEngineerToMexSpot() and RemoveUnclaimedMexSpot()  - higher numbers are more important

--             local found=false

--             for _,ve in aiBrain.emanager.expands do
--                 if VDist2Sq(ve.Position[1],ve.Position[3],v['position'][1],v['position'][3])<25*25 then
--                     found=true
--                     break
--                 end
--             end

--             if not found then  -- this mex is not close to any of the expansion spots, so it's a new one and we need to set its priority to 1

--                 table.sort(aiBrain.emanager.expands,function(a,b) return VDist2Sq(a.Position[1],a.Position[3],v['position'][1],v['position'][3])<VDist2Sq(b.Position[1],b.Position[3],v['position'][1],v['position'][3]) end)

--                 v['priority']=aiBrain.emanager.expands[1].mexnum+0 -- +0 because I want it to be 0 if there are no other mexes yet (so that it will be chosen for the first expansion spot) - used to determine which engineer gets sent there first  - see AssignEngineerToMexSpot() and RemoveUnclaimedMexSpot()
--                 v['expand']=aiBrain.emanager.expands[1]
--                 v['expand'].taken=0
--                 v['expand'].takentime=0

--             end

--         end

--     end
-- end

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