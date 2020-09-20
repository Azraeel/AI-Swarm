-- hook for additional build conditions used from AIBuilders

local BASEPOSTITIONSSWARM = {}
local mapSizeX, mapSizeZ = GetMapSize()
local PlatoonExists = moho.aibrain_methods.PlatoonExists
local GetPlatoonUnits = moho.platoon_methods.GetPlatoonUnits
local IsUnitState = moho.unit_methods.IsUnitState
local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition
local GetBrain = moho.platoon_methods.GetBrain
local PlatoonCategoryCount = moho.platoon_methods.PlatoonCategoryCount

local SWARMCOPY = table.copy
local SWARMSORT = table.sort
local SWARMTIME = GetGameTimeSeconds
local SWARMFLOOR = math.floor
local SWARMENTITY = EntityCategoryContains
local SWARMINSERT = table.insert
local SWARMCAT = table.cat

local VDist2Sq = VDist2Sq
local VDist3 = VDist3

local ForkThread = ForkThread
local ForkTo = ForkThread

local KillThread = KillThread

--{ UCBC, 'ReturnTrue', {} },
function ReturnTrue(aiBrain)
    LOG('** true')
    return true
end

--{ UCBC, 'ReturnFalse', {} },
function ReturnFalse(aiBrain)
    LOG('** false')
    return false
end

--{ UCBC, 'CanBuildCategorySwarm', { categories.RADAR * categories.TECH1 } },
local FactionIndexToCategory = {[1] = categories.UEF, [2] = categories.AEON, [3] = categories.CYBRAN, [4] = categories.SERAPHIM, [5] = categories.NOMADS }
function CanBuildCategorySwarm(aiBrain,category)
    -- convert text categories like 'MOBILE AIR' to 'categories.MOBILE * categories.AIR'
    local FactionCat = FactionIndexToCategory[aiBrain:GetFactionIndex()] or categories.ALLUNITS
    local numBuildableUnits = table.getn(EntityCategoryGetUnitList(category * FactionCat)) or -1
    --LOG('* CanBuildCategorySwarm: FactionIndex: ('..repr(aiBrain:GetFactionIndex())..') numBuildableUnits:'..numBuildableUnits..' - '..repr( EntityCategoryGetUnitList(category * FactionCat) ))
    return numBuildableUnits > 0
end

--            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.RADAR * categories.TECH1 }},
function HaveUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, compareType)
    -- get all units matching 'category'
    local unitsBuilding = aiBrain:GetListOfUnits(category, false)
    local numBuilding = 0
    -- own armyIndex
    local armyIndex = aiBrain:GetArmyIndex()
    -- loop over all units and search for upgrading units
    for unitNum, unit in unitsBuilding do
        if not unit.Dead and not unit:BeenDestroyed() and unit:IsUnitState('Upgrading') and unit:GetAIBrain():GetArmyIndex() == armyIndex then
            numBuilding = numBuilding + 1
        end
    end
    --LOG(aiBrain:GetArmyIndex()..' HaveUnitsInCategoryBeingUpgrade ( '..numBuilding..' '..compareType..' '..numunits..' ) --  return '..repr(CompareBody(numBuilding, numunits, compareType))..' ')
    return CompareBody(numBuilding, numunits, compareType)
end
function HaveLessThanUnitsInCategoryBeingUpgradeSwarm(aiBrain, numunits, category)
    return HaveUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, '<')
end
function HaveGreaterThanUnitsInCategoryBeingUpgradeSwarm(aiBrain, numunits, category)
    return HaveUnitsInCategoryBeingUpgrade(aiBrain, numunits, category, '>')
end

-- function GreaterThanGameTime(aiBrain, num) is multiplying the time by 0.5, if we have an cheat AI. But i need the real time here.
--            { UCBC, 'GreaterThanGameTimeSeconds', { 180 } },
function GreaterThanGameTimeSeconds(aiBrain, num)
    if num < GetGameTimeSeconds() then
        return true
    end
    return false
end
--            { UCBC, 'LessThanGameTimeSeconds', { 180 } },
function LessThanGameTimeSeconds(aiBrain, num)
    if num > GetGameTimeSeconds() then
        return true
    end
    return false
end

--            { UCBC, 'HaveUnitRatioVersusCapSwarm', { 0.024, '<=', categories.STRUCTURE * categories.FACTORY * categories.LAND } }, -- Maximal 3 factories at 125 unitcap, 12 factories at 500 unitcap...
function HaveUnitRatioVersusCapSwarm(aiBrain, ratio, compareType, categoryOwn)
    local numOwnUnits = aiBrain:GetCurrentUnits(categoryOwn)
    local cap = GetArmyUnitCap(aiBrain:GetArmyIndex())
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOwnUnits..' '..compareType..' '..cap..' ) -- ['..ratio..'] -- '..repr(DEBUG)..' :: '..(numOwnUnits / cap)..' '..compareType..' '..cap..' return '..repr(CompareBody(numOwnUnits / cap, ratio, compareType)))
    return CompareBody(numOwnUnits / cap, ratio, compareType)
end

function HaveUnitRatioVersusEnemySwarm(aiBrain, ratio, categoryOwn, compareType, categoryEnemy)
    local numOwnUnits = aiBrain:GetCurrentUnits(categoryOwn)
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ , 'Enemy')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOwnUnits..' '..compareType..' '..numEnemyUnits..' ) -- ['..ratio..'] -- return '..repr(CompareBody(numOwnUnits / numEnemyUnits, ratio, compareType)))
    return CompareBody(numOwnUnits / numEnemyUnits, ratio, compareType)
end

function HaveUnitRatioAtLocationSwarm(aiBrain, locType, ratio, categoryNeed, compareType, categoryHave)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if BASEPOSTITIONSSWARM[AIName][locType] then
        baseposition = BASEPOSTITIONSSWARM[AIName][locType].Pos
        radius = BASEPOSTITIONSSWARM[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager.Location
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        BASEPOSTITIONSSWARM[AIName] = BASEPOSTITIONSSWARM[AIName] or {} 
        BASEPOSTITIONSSWARM[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                BASEPOSTITIONSSWARM[AIName] = BASEPOSTITIONSSWARM[AIName] or {} 
                BASEPOSTITIONSSWARM[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local numNeedUnits = aiBrain:GetNumUnitsAroundPoint(categoryNeed, baseposition, radius , 'Ally')
    local numHaveUnits = aiBrain:GetNumUnitsAroundPoint(categoryHave, baseposition, radius , 'Ally')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {'..locType..'} ( '..numNeedUnits..' '..compareType..' '..numHaveUnits..' ) -- ['..ratio..'] -- '..categoryNeed..' '..compareType..' '..categoryHave..' return '..repr(CompareBody(numNeedUnits / numHaveUnits, ratio, compareType)))
    return CompareBody(numNeedUnits / numHaveUnits, ratio, compareType)
end

--{ UCBC, 'HaveUnitRatioAtLocationSwarmRadiusVersusEnemy', { 1.50, 'LocationType', 90, 'STRUCTURE DEFENSE ANTIMISSILE TECH3', '<','SILO NUKE TECH3' } },
function HaveUnitRatioAtLocationSwarmRadiusVersusEnemy(aiBrain, ratio, locType, radius, categoryOwn, compareType, categoryEnemy)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if BASEPOSTITIONSSWARM[AIName][locType] then
        baseposition = BASEPOSTITIONSSWARM[AIName][locType].Pos
        radius = BASEPOSTITIONSSWARM[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager.Location
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        BASEPOSTITIONSSWARM[AIName] = BASEPOSTITIONSSWARM[AIName] or {} 
        BASEPOSTITIONSSWARM[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                BASEPOSTITIONSSWARM[AIName] = BASEPOSTITIONSSWARM[AIName] or {} 
                BASEPOSTITIONSSWARM[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local numNeedUnits = aiBrain:GetNumUnitsAroundPoint(categoryOwn, baseposition, radius , 'Ally')
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ , 'Enemy')
    return CompareBody(numNeedUnits / numEnemyUnits, ratio, compareType)
end

--            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.MASSEXTRACTION} },
function HavePoolUnitInArmy(aiBrain, unitCount, unitCategory, compareType)
    local poolPlatoon = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    local numUnits = poolPlatoon:GetNumCategoryUnits(unitCategory)
    --LOG('* HavePoolUnitInArmy: numUnits= '..numUnits) 
    return CompareBody(numUnits, unitCount, compareType)
end
function HaveLessThanArmyPoolWithCategorySwarm(aiBrain, unitCount, unitCategory)
    return HavePoolUnitInArmy(aiBrain, unitCount, unitCategory, '<')
end
function HaveGreaterThanArmyPoolWithCategorySwarm(aiBrain, unitCount, unitCategory)
    return HavePoolUnitInArmy(aiBrain, unitCount, unitCategory, '>')
end


function HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, compareType)
    if not aiBrain.BuilderManagers[locationType] then
        WARN('*AI WARNING: HaveEnemyUnitAtLocation - Invalid location - ' .. locationType)
        return false
    end
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, aiBrain.BuilderManagers[locationType].Position, radius , 'Enemy')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} radius:['..radius..'] '..repr(DEBUG)..' ['..numEnemyUnits..'] '..compareType..' ['..unitCount..'] return '..repr(CompareBody(numEnemyUnits, unitCount, compareType)))
    return CompareBody(numEnemyUnits, unitCount, compareType)
end
--            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND }}, -- radius, LocationType, unitCount, categoryEnemy
function EnemyUnitsGreaterAtLocationRadiusSwarm(aiBrain, radius, locationType, unitCount, categoryEnemy)
    return HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, '>')
end
--            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 1, categories.MOBILE * categories.LAND }}, -- radius, LocationType, unitCount, categoryEnemy
function EnemyUnitsLessAtLocationRadiusSwarm(aiBrain, radius, locationType, unitCount, categoryEnemy)
    return HaveEnemyUnitAtLocation(aiBrain, radius, locationType, unitCount, categoryEnemy, '<')
end

--            { UCBC, 'UnitsLessAtEnemySwarm', { 1 , 'MOBILE EXPERIMENTAL' } },
--            { UCBC, 'UnitsGreaterAtEnemySwarm', { 1 , 'MOBILE EXPERIMENTAL' } },
function GetEnemyUnits(aiBrain, unitCount, categoryEnemy, compareType)
    local numEnemyUnits = aiBrain:GetNumUnitsAroundPoint(categoryEnemy, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ , 'Enemy')
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} '..categoryEnemy..' ['..numEnemyUnits..'] '..compareType..' ['..unitCount..'] return '..repr(CompareBody(numEnemyUnits, unitCount, compareType)))
    return CompareBody(numEnemyUnits, unitCount, compareType)
end
function UnitsLessAtEnemySwarm(aiBrain, unitCount, categoryEnemy)
    return GetEnemyUnits(aiBrain, unitCount, categoryEnemy, '<')
end
function UnitsGreaterAtEnemySwarm(aiBrain, unitCount, categoryEnemy)
    return GetEnemyUnits(aiBrain, unitCount, categoryEnemy, '>')
end

--            { UCBC, 'EngineerManagerUnitsAtLocationSwarm', { 'MAIN', '<=', 100,  'ENGINEER TECH3' } },
function EngineerManagerUnitsAtLocationSwarm(aiBrain, LocationType, compareType, numUnits, category)
    local numEngineers = aiBrain.BuilderManagers[LocationType].EngineerManager:GetNumCategoryUnits('Engineers', category)
    --LOG('* EngineerManagerUnitsAtLocationSwarm: '..LocationType..' ( engineers: '..numEngineers..' '..compareType..' '..numUnits..' ) -- '..category..' return '..repr(CompareBody( numEngineers, numUnits, compareType )) )
    return CompareBody( numEngineers, numUnits, compareType )
end

--            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
function BuildOnlyOnLocationSwarm(aiBrain, LocationType, AllowedLocationType)
    --LOG('* BuildOnlyOnLocationSwarm: we are on location '..LocationType..', Allowed locations are: '..AllowedLocationType..'')
    if string.find(LocationType, AllowedLocationType) then
        return true
    end
    return false
end
--            { UCBC, 'BuildNotOnLocationSwarm', { 'LocationType', 'MAIN' } },
function BuildNotOnLocationSwarm(aiBrain, LocationType, ForbiddenLocationType)
    if string.find(LocationType, ForbiddenLocationType) then
        --LOG('* BuildOnlyOnLocationSwarm: we are on location '..LocationType..', forbidden locations are: '..ForbiddenLocationType..'. return false (don\'t build it)')
        return false
    end
    --LOG('* BuildOnlyOnLocationSwarm: we are on location '..LocationType..', forbidden locations are: '..ForbiddenLocationType..'. return true (OK, build it)')
    return true
end

function HaveGreaterThanUnitsInCategoryBeingBuiltAtLocationSwarm(aiBrain, locationType, numReq, category, constructionCat)
    local numUnits
    if constructionCat then
        numUnits = table.getn( GetUnitsBeingBuiltLocation(aiBrain, locationType, category, category + (categories.ENGINEER * categories.MOBILE - categories.STATIONASSISTPOD) + constructionCat) or {} )
    else
        numUnits = table.getn( GetUnitsBeingBuiltLocation(aiBrain,locationType, category, category + (categories.ENGINEER * categories.MOBILE - categories.STATIONASSISTPOD) ) or {} )
    end
    if numUnits > numReq then
        return true
    end
    return false
end


function GetUnitsBeingBuiltLocationSwarm(aiBrain, locType, buildingCategory, builderCategory)
    local AIName = ArmyBrains[aiBrain:GetArmyIndex()].Nickname
    local baseposition, radius
    if BASEPOSTITIONSSWARM[AIName][locType] then
        baseposition = BASEPOSTITIONSSWARM[AIName][locType].Pos
        radius = BASEPOSTITIONSSWARM[AIName][locType].Rad
    elseif aiBrain.BuilderManagers[locType] then
        baseposition = aiBrain.BuilderManagers[locType].FactoryManager.Location
        radius = aiBrain.BuilderManagers[locType].FactoryManager:GetLocationRadius()
        BASEPOSTITIONSSWARM[AIName] = BASEPOSTITIONSSWARM[AIName] or {} 
        BASEPOSTITIONSSWARM[AIName][locType] = {Pos=baseposition, Rad=radius}
    elseif aiBrain:PBMHasPlatoonList() then
        for k,v in aiBrain.PBM.Locations do
            if v.LocationType == locType then
                baseposition = v.Location
                radius = v.Radius
                BASEPOSTITIONSSWARM[AIName] = BASEPOSTITIONSSWARM[AIName] or {} 
                BASEPOSTITIONSSWARM[AIName][locType] = {baseposition, radius}
                break
            end
        end
    end
    if not baseposition then
        return false
    end
    local filterUnits = GetOwnUnitsAroundLocationSwarm(aiBrain, builderCategory, baseposition, radius)
    local retUnits = {}
    for k,v in filterUnits do
        -- Only assist if allowed
        if v.DesiresAssist == false then
            continue
        end
        -- Engineer doesn't want any more assistance
        if v.NumAssistees and table.getn(v:GetGuards()) >= v.NumAssistees then
            continue
        end
        -- skip the unit, if it's not building or upgrading.
        if not v:IsUnitState('Building') and not v:IsUnitState('Upgrading') then
            continue
        end
        local beingBuiltUnit = v.UnitBeingBuilt
        if not beingBuiltUnit or not EntityCategoryContains(buildingCategory, beingBuiltUnit) then
            continue
        end
        table.insert(retUnits, v)
    end
    return retUnits
end

function GetOwnUnitsAroundLocationSwarm(aiBrain, category, location, radius)
    local units = aiBrain:GetUnitsAroundPoint(category, location, radius, 'Ally')
    local index = aiBrain:GetArmyIndex()
    local retUnits = {}
    for _, v in units do
        if not v.Dead and v:GetAIBrain():GetArmyIndex() == index then
            table.insert(retUnits, v)
        end
    end
    return retUnits
end



--            { UCBC, 'CanPathNavalBaseToNavalTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }}, -- LocationType, categoryUnits
function CanPathNavalBaseToNavalTargetsSwarm(aiBrain, locationType, unitCategory)
    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    baseposition = aiBrain.BuilderManagers[locationType].FactoryManager.Location
    --LOG('Searching water path from base ['..locationType..'] position '..repr(baseposition))
    local EnemyNavalUnits = aiBrain:GetUnitsAroundPoint(unitCategory, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
    local path, reason
    for _, EnemyUnit in EnemyNavalUnits do
        if not EnemyUnit.Dead then
            --LOG('checking enemy factories '..repr(EnemyUnit:GetPosition()))
            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Water', baseposition, EnemyUnit:GetPosition(), 1)
            --LOG('reason'..repr(reason))
            if path then
                --LOG('Found a water path from base ['..locationType..'] to enemy position '..repr(EnemyUnit:GetPosition()))
                return true
            end
        end
    end
    --LOG('Found no path to any target from naval base ['..locationType..']')
    return false
end

--            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }}, -- LocationType, categoryUnits
function CanPathLandBaseToLandTargetsSwarm(aiBrain, locationType, unitCategory)
    local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
    baseposition = aiBrain.BuilderManagers[locationType].FactoryManager.Location
    --LOG('Searching water path from base ['..locationType..'] position '..repr(baseposition))
    local EnemyNavalUnits = aiBrain:GetUnitsAroundPoint(unitCategory, Vector(mapSizeX/2,0,mapSizeZ/2), mapSizeX+mapSizeZ, 'Enemy')
    local path, reason
    for _, EnemyUnit in EnemyNavalUnits do
        if not EnemyUnit.Dead then
            --LOG('checking enemy factories '..repr(EnemyUnit:GetPosition()))
            path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Land', baseposition, EnemyUnit:GetPosition(), 1)
            --LOG('reason'..repr(reason))
            if path then
                --LOG('Found a water path from base ['..locationType..'] to enemy position '..repr(EnemyUnit:GetPosition()))
                return true
            end
        end
    end
    --LOG('Found no path to any target from naval base ['..locationType..']')
    return false
end

--            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},
function UnfinishedUnitsAtLocationSwarm(aiBrain, locationType)
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not engineerManager then
        --WARN('*AI WARNING: UnfinishedUnitsAtLocationSwarm: Invalid location - ' .. locationType)
        return false
    end
    local unfinishedUnits = aiBrain:GetUnitsAroundPoint(categories.STRUCTURE + categories.EXPERIMENTAL, engineerManager.Location, engineerManager.Radius, 'Ally')
    for num, unit in unfinishedUnits do
        local FractionComplete = unit:GetFractionComplete()
        if FractionComplete < 1 and table.getn(unit:GetGuards()) < 1 then
            return true
        end
    end
    return false
end

--             { UCBC, 'HaveUnitRatioSwarm', { 0.75, 'MASSEXTRACTION TECH1', '<=','MASSEXTRACTION TECH2',true } },
function HaveUnitRatioSwarm(aiBrain, ratio, categoryOne, compareType, categoryTwo)
    local numOne = aiBrain:GetCurrentUnits(categoryOne)
    local numTwo = aiBrain:GetCurrentUnits(categoryTwo)
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOne..' '..compareType..' '..numTwo..' ) -- ['..ratio..'] -- '..categoryOne..' '..compareType..' '..categoryTwo..' ('..(numOne / numTwo)..' '..compareType..' '..ratio..' ?) return '..repr(CompareBody(numOne / numTwo, ratio, compareType)))
    return CompareBody(numOne / numTwo, ratio, compareType)
end

--            { UCBC, 'HasParagon', {} },
function HasParagon(aiBrain)
    if aiBrain.HasParagon then
        return true
    end
    return false
end

--            { UCBC, 'HasNotParagon', {} },
function HasNotParagon(aiBrain)
    if not aiBrain.HasParagon then
        return true
    end
    return false
end

function LessThanThreatAtEnemyBaseSwarm(aiBrain, ttype, number)
    if aiBrain:GetCurrentEnemy() then
        enemy = aiBrain:GetCurrentEnemy()
        enemyIndex = aiBrain:GetCurrentEnemy():GetArmyIndex()
    else
        return false
    end

    local StartX, StartZ = enemy:GetArmyStartPos()

    local enemyThreat = aiBrain:GetThreatAtPosition({StartX, 0, StartZ}, 1, true, ttype or 'Overall', enemyIndex)
    if number < enemyThreat then
        return true
    end
    return false
end

function HaveComparativeUnitsWithCategoryAndAllianceSwarm(aiBrain, greater, myCategory, eCategory, alliance)
    if type(eCategory) == 'string' then
        eCategory = ParseEntityCategory(eCategory)
    end
    if type(myCategory) == 'string' then
        myCategory = ParseEntityCategory(myCategory)
    end
    local myUnits = aiBrain:GetCurrentUnits(myCategory)
    local numUnits = aiBrain:GetNumUnitsAroundPoint(eCategory, Vector(0,0,0), 100000, alliance)
    if alliance == 'Ally' then
        numUnits = numUnits - aiBrain:GetCurrentUnits(myCategory)
    end
    if numUnits > myUnits and greater then
        return true
    elseif numUnits < myUnits and not greater then
        return true
    end
    return false
end

function HasMassPointShare( aiBrain )

	local SWARMGETN = table.getn

    local ArmyCount = 0
    local TeamCount = 0
    
	local MassMarker = {}
    local MassMarker = table.getn(MassMarker)
    
    for _,brain in ArmyBrains do
	
        if not brain:IsDefeated() and not ArmyIsCivilian(brain:GetArmyIndex()) then
		
			ArmyCount = ArmyCount + 1		-- number of players in the game
			
			if IsAlly( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then
				TeamCount = TeamCount + 1 	-- number of players on this team
			end
        end
    end

	local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
	
    local extractorCount = SWARMGETN(GetListOfUnits(aiBrain,categories.MASSEXTRACTION, false))
	local fabricatorCount = SWARMGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.TECH3, false))
	local res_genCount = SWARMGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.EXPERIMENTAL, false))
	
	extractorCount = extractorCount + (fabricatorCount * .5) + (res_genCount * 3)
	
	return extractorCount >= SWARMFLOOR( (MassMarker/ ArmyCount)-1 )
end

function NeedMassPointShare( aiBrain )

	local SWARMGETN = table.getn

    local ArmyCount = 0
    local TeamCount = 0

    local MassMarker = {}
    local MassMarker = table.getn(MassMarker)
    
    for _,brain in ArmyBrains do
	
        if not brain:IsDefeated() and not ArmyIsCivilian(brain:GetArmyIndex()) then
		
			ArmyCount = ArmyCount + 1		-- number of players in the game
			
			if IsAlly( aiBrain:GetArmyIndex(), brain:GetArmyIndex() ) then
				TeamCount = TeamCount + 1 	-- number of players on this team
			end
        end
    end

	local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
	
    local extractorCount = SWARMGETN(GetListOfUnits(aiBrain,categories.MASSEXTRACTION, false))
	local fabricatorCount = SWARMGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.TECH3, false))
	local res_genCount = SWARMGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.EXPERIMENTAL, false))
	
	extractorCount = extractorCount + (fabricatorCount * .5) + (res_genCount * 3)
	
	return extractorCount <= SWARMFLOOR( (MassMarker/ ArmyCount)-1 )	
end

function AirStrengthRatioGreaterThan( aiBrain, value )
	return aiBrain.MyAirRatio >= value
end

function AirStrengthRatioLessThan ( aiBrain, value )
	return aiBrain.MyAirRatio < value
end

function LandStrengthRatioGreaterThan( aiBrain, value )
	return aiBrain.MyLandRatio >= value
end

function LandStrengthRatioLessThan ( aiBrain, value )
	return aiBrain.MyLandRatio < value
end

function NavalStrengthRatioGreaterThan( aiBrain, value )
	return aiBrain.MyNavalRatio >= value
end

function NavalStrengthRatioLessThan ( aiBrain, value )
    return aiBrain.MyNavalRatio < value
end

function ScalePlatoonSizeSwarm(aiBrain, locationType, type, unitCategory)
    -- Note to self, create a brain flag in the air superiority function that can assist with the AIR platoon sizing increase.
    local currentTime = GetGameTimeSeconds()
    if type == 'LAND' then
        if currentTime < 240  then
            if PoolGreaterAtLocation(aiBrain, locationType, 4, unitCategory) then
                return true
            end
        elseif currentTime < 480 then
            if PoolGreaterAtLocation(aiBrain, locationType, 6, unitCategory) then
                return true
            end
        elseif currentTime < 720 then
            if PoolGreaterAtLocation(aiBrain, locationType, 8, unitCategory) then
                return true
            end
        elseif currentTime > 900 then
            if PoolGreaterAtLocation(aiBrain, locationType, 10, unitCategory) then
                return true
            end
        else
            return false
        end
    elseif type == 'AIR' then
        if currentTime < 480  then
            if PoolGreaterAtLocation(aiBrain, locationType, 2, unitCategory) then
                return true
            end
        elseif currentTime < 720 then
            if PoolGreaterAtLocation(aiBrain, locationType, 4, unitCategory) then
                return true
            end
        elseif currentTime < 900 then
            if PoolGreaterAtLocation(aiBrain, locationType, 6, unitCategory) then
                return true
            end
        elseif currentTime > 1200 then
            if PoolGreaterAtLocation(aiBrain, locationType, 8, unitCategory) then
                return true
            end
        elseif currentTime >= 480 then
            if PoolGreaterAtLocation(aiBrain, locationType, 2, unitCategory) then
                return true
            end
        else
            return false
        end
    elseif type == 'NAVAL' then
        if currentTime < 720  then
            if PoolGreaterAtLocation(aiBrain, locationType, 2, unitCategory) then
                return true
            end
        elseif currentTime < 960 then
            if PoolGreaterAtLocation(aiBrain, locationType, 3, unitCategory) then
                return true
            end
        elseif currentTime < 1200 then
            if PoolGreaterAtLocation(aiBrain, locationType, 4, unitCategory) then
                return true
            end
        elseif currentTime > 1800 then
            if PoolGreaterAtLocation(aiBrain, locationType, 5, unitCategory) then
                return true
            end
        else
            return false
        end
    end
    return false
end

