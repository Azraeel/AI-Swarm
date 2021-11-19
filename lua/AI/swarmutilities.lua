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
local SWARMPARSE =  ParseEntityCategory

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

--Extractor Upgrading needs a complete rework, though honestly I do not have the skill to rewrite this completely nor the skill to use Sprouto or Relly's code right now.

function ExtractorPauseSwarm(self, aiBrain, MassExtractorUnitList, ratio, techLevel)
    local aiBrain = self:GetBrain()
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    local BasePosition = aiBrain.BuilderManagers['MAIN'].Position
    local UpgradingBuilding = nil
    local UpgradingBuildingNum = 0
    local PausedUpgradingBuilding = nil
    local PausedUpgradingBuildingNum = 0
    local DisabledBuilding = nil
    local DisabledBuildingNum = 0
    local DistanceToBase = nil
    local LowestDistanceToBase = nil
    local IdleBuilding = nil
    local BussyBuilding = nil
    local IdleBuildingNum = 0

    for unitNum, unit in MassExtractorUnitList do
        if unit
            and not unit.Dead
            and not unit:GetFractionComplete() < 1
            and SWARMENTITY(SWARMPARSE(techLevel), unit)
        then

            if unit:IsUnitState('Upgrading') then
                if unit:IsPaused() then
                    if not PausedUpgradingBuilding then
                        PausedUpgradingBuilding = unit
                    end
                    PausedUpgradingBuildingNum = PausedUpgradingBuildingNum + 1
                else
                    if not UpgradingBuilding then
                        UpgradingBuilding = unit
                    end
                    UpgradingBuildingNum = UpgradingBuildingNum + 1
                end

            elseif unit:GetScriptBit('RULEUTC_ProductionToggle') then
                if not DisabledBuilding then
                    DisabledBuilding = unit
                end
                DisabledBuildingNum = DisabledBuildingNum + 1
            else
                if not unit:IsPaused() then
                    if not IdleBuilding then
                        IdleBuilding = unit
                    end
                else
                    unit:SetPaused( false )
                end
               IdleBuildingNum = IdleBuildingNum + 1
            end

        end
    end
    

    if aiBrain:GetEconomyStoredRatio('ENERGY') <= 0.25 then
        if UpgradingBuilding then
            if UpgradingBuildingNum <= 0 and SWARMGETN(MassExtractorUnitList) >= 8 then
            else
                UpgradingBuilding:SetPaused( true )
                return true
            end
        end 
    end 

    local MassRatioCheckPositive = GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm( self, aiBrain, ratio, techLevel, '<' )

    if PausedUpgradingBuilding then
        if MassRatioCheckPositive then
            PausedUpgradingBuilding:SetPaused( false )
            return true
        elseif not MassRatioCheckPositive and UpgradingBuildingNum < 1 and SWARMGETN(MassExtractorUnitList) >= 8 or econ.MassEfficiencyOverTime > 1.02 and aiBrain:GetEconomyStored('MASS') >= 200 then
            PausedUpgradingBuilding:SetPaused( false )
            return true
        end
    end

    local MassRatioCheckNegative = GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm( self, aiBrain, ratio, techLevel, '>=')
    
    if MassRatioCheckNegative then
        if UpgradingBuildingNum > 0 then
            if econ.MassEfficiencyOverTime < 1.02 and aiBrain:GetEconomyStored('MASS') <= 200 then
                UpgradingBuilding:SetPaused( true )
                return true
            end
        end
    end
    return false

end


function ExtractorUpgradeSwarm(self, aiBrain, MassExtractorUnitList, ratio, techLevel, UnitUpgradeTemplates, StructureUpgradeTemplates)
    local MassRatioCheckPositive = GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm(self, aiBrain, ratio, techLevel, '<' )
    local aiBrain = self:GetBrain()
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    local BasePosition = aiBrain.BuilderManagers['MAIN'].Position
    local factionIndex = aiBrain:GetFactionIndex()
    local UpgradingBuilding = 0
    local DistanceToBase = nil
    local LowestDistanceToBase = nil
    local upgradeID = nil
    local upgradeBuilding = nil
    local UnitPos = nil
    local FactionToIndex  = { UEF = 1, AEON = 2, CYBRAN = 3, SERAPHIM = 4, NOMADS = 5}
    local UnitBeingUpgradeFactionIndex = nil

    for k, v in MassExtractorUnitList do

        local TempID

        if not v
            or v.Dead
            or v:BeenDestroyed()
            or v:IsPaused()
            or not SWARMENTITY(SWARMPARSE(techLevel), v)
            or v:GetFractionComplete() < 1
        then
            continue
        end

        if v:IsUnitState('Upgrading') then
            UpgradingBuilding = UpgradingBuilding + 1
            continue
        end

        UnitPos = v:GetPosition()
        DistanceToBase= VDist2(BasePosition[1] or 0, BasePosition[3] or 0, UnitPos[1] or 0, UnitPos[3] or 0)

        if not LowestDistanceToBase or DistanceToBase < LowestDistanceToBase then

            UnitBeingUpgradeFactionIndex = FactionToIndex[v.factionCategory] or factionIndex

            if SWARMENTITY(categories.MOBILE, v) then
                TempID = aiBrain:FindUpgradeBP(v:GetUnitId(), UnitUpgradeTemplates[UnitBeingUpgradeFactionIndex])

                if not TempID then
                    --WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find UnitUpgradeTemplate for mobile unit: ' .. repr(v:GetUnitId()) )
                end

            else
                TempID = aiBrain:FindUpgradeBP(v:GetUnitId(), StructureUpgradeTemplates[UnitBeingUpgradeFactionIndex])

                if not TempID then
                    --WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for structure: ' .. repr(v:GetUnitId()) )
                end

            end 

            if TempID and SWARMENTITY(categories.STRUCTURE, v) and not v:CanBuild(TempID) then

                --WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t upgrade structure with StructureUpgradeTemplate: ' .. repr(v:GetUnitId()) )

            elseif TempID then
                upgradeID = TempID
                upgradeBuilding = v
                LowestDistanceToBase = DistanceToBase
            end

        end
    end
    
    if 
    not MassRatioCheckPositive 
    --and aiBrain:GetEconomyStored('MASS') < 200 
    --and econ.MassEfficiencyOverTime >= 1.0 
    --and econ.EnergyEfficiencyOverTime >= 1.04 
    then
      
        if UpgradingBuilding > 0 or SWARMGETN(MassExtractorUnitList) < 8 then
            return false
        end

    end

    if upgradeID and upgradeBuilding then
        IssueUpgrade({upgradeBuilding}, upgradeID)
        SWARMWAIT(100)
        return true
    end

    return false
end

-- Helperfunction fro ExtractorUpgradeAISwarm. 
function GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm(self, aiBrain, ratio, techLevel, compareType)

    local GlobalUpgradeCost = 0
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    local unitsBuilding = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2), true)
    local numBuilding = 0
    
    if compareType == '<' or compareType == '<=' then
        numBuilding = 1
        if techLevel == 'TECH1' then
            GlobalUpgradeCost = 10
            MassIncomeLost = 2
        else
            GlobalUpgradeCost = 24
            MassIncomeLost = 6
        end
    end

    local SingleUpgradeCost
    local armyIndex = aiBrain:GetArmyIndex()
   
    for unitNum, unit in unitsBuilding do
        if unit
            and not unit:BeenDestroyed()
            and not unit.Dead
            and not unit:IsPaused()
            and not unit:GetFractionComplete() < 1
            and unit:IsUnitState('Upgrading')
            and unit:GetAIBrain():GetArmyIndex() == armyIndex
        then
            numBuilding = numBuilding + 1
            
            local UpgraderBlueprint = unit:GetBlueprint()
            local BeingUpgradeEconomy = __blueprints[UpgraderBlueprint.General.UpgradesTo].Economy
            SingleUpgradeCost = (UpgraderBlueprint.Economy.BuildRate / BeingUpgradeEconomy.BuildTime) * BeingUpgradeEconomy.BuildCostMass
            GlobalUpgradeCost = GlobalUpgradeCost + SingleUpgradeCost
        end
    end
   
    local MassIncome = ( aiBrain:GetEconomyIncome('MASS') * 10 ) - MassIncomeLost

    if MassIncome < 20 and ( compareType == '<' or compareType == '<=' ) then
        return false
    end

    return CompareBody(GlobalUpgradeCost / MassIncome, ratio, compareType)
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
                --LOG('* AI-RNG: Unit is capturable and not category t1 mobile'..unitdesc)
                -- if we can capture the unit/building then do so
                unit.CaptureInProgress = true
                IssueCapture({eng}, unit)
            else
                --LOG('* AI-RNG: We are going to reclaim the unit'..unitdesc)
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
    --LOG('Return marker list has '..RNGGETN(newList)..' entries')
    return newList
end

local PropBlacklist = {}
function ReclaimAIThreadSwarm(platoon,self,aiBrain)
    local scanrange = 25
    local scanKM = 0
    local playablearea
    if  ScenarioInfo.MapData.PlayableRect then
        playablearea = ScenarioInfo.MapData.PlayableRect
    else
        playablearea = {0, 0, ScenarioInfo.size[1], ScenarioInfo.size[2]}
    end
    local basePosition = aiBrain.BuilderManagers['MAIN'].Position
    local MassStorageRatio
    local EnergyStorageRatio
    local SelfPos
    while aiBrain:PlatoonExists(platoon) and self and not self.Dead do
        SelfPos = self:GetPosition()
        MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS')
        EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
        if (MassStorageRatio < 1.00 or EnergyStorageRatio < 1.00) and not aiBrain.HasParagon then

            local x1 = SelfPos[1]-scanrange
            local y1 = SelfPos[3]-scanrange
            local x2 = SelfPos[1]+scanrange
            local y2 = SelfPos[3]+scanrange
            if x1 < playablearea[1]+6 then x1 = playablearea[1]+6 end
            if y1 < playablearea[2]+6 then y1 = playablearea[2]+6 end
            if x2 > playablearea[3]-6 then x2 = playablearea[3]-6 end
            if y2 > playablearea[4]-6 then y2 = playablearea[4]-6 end
            local props = GetReclaimablesInRect(Rect(x1, y1, x2, y2))
            local NearestWreckDist = -1
            local NearestWreckPos = {}
            local WreckDist = 0
            local WrackCount = 0

            if props and SWARMGETN( props ) > 0 then
                for _, p in props do
                    local WreckPos = p.CachePosition
                    -- Start Blacklisted Props
                    local blacklisted = false
                    for _, BlackPos in PropBlacklist do
                        if WreckPos[1] == BlackPos[1] and WreckPos[3] == BlackPos[3] then
                            blacklisted = true
                            break
                        end
                    end
                    if blacklisted then continue end
                    -- End Blacklisted Props
                    local BPID = p.AssociatedBP or "unknown"
                    if BPID == 'ueb5101' or BPID == 'uab5101' or BPID == 'urb5101' or BPID == 'xsb5101' then 
                        continue
                    end
					
                    if (MassStorageRatio <= EnergyStorageRatio and p.MaxMassReclaim and p.MaxMassReclaim > 1) or (SWARMTIME() > 240 and MassStorageRatio > EnergyStorageRatio and p.MaxEnergyReclaim and p.MaxEnergyReclaim > 1) then
                        WreckDist = VDist2(SelfPos[1], SelfPos[3], WreckPos[1], WreckPos[3])
                        WrackCount = WrackCount + 1
                        if WreckDist < NearestWreckDist or NearestWreckDist == -1 then
                            NearestWreckDist = WreckDist
                            NearestWreckPos = WreckPos
                           
                        end
                        if NearestWreckDist < 20 then
                          
                            break
                        end
                    end
                end
            end

            if self.Dead then
			
                return
            end

            if NearestWreckDist == -1 then
                scanrange = SWARMFLOOR(scanrange + 100)
                if scanrange > 512 then -- 5 Km
                    IssueClearCommands({self})
                    scanrange = 25
                    local HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
                    if HomeDist > 50 then
                        StartMoveDestination(self, {basePosition[1], basePosition[2], basePosition[3]})
                    end
                    PropBlacklist = {}
                end
         
            elseif SWARMFLOOR(NearestWreckDist) < scanrange then
                scanrange = SWARMFLOOR(NearestWreckDist)
                if scanrange < 25 then
                    scanrange = 25
                end
            end

            scanKM = SWARMFLOOR(10000/512*NearestWreckDist)
            if NearestWreckDist > 20 and not self.Dead then
                if NearestWreckPos[1] < playablearea[1]+21 then
                    NearestWreckPos[1] = playablearea[1]+21
                end
                if NearestWreckPos[1] > playablearea[3]-21 then
                    NearestWreckPos[1] = playablearea[3]-21
                end
                if NearestWreckPos[3] < playablearea[2]+21 then
                    NearestWreckPos[3] = playablearea[2]+21
                end
                if NearestWreckPos[3] > playablearea[4]-21 then
                    NearestWreckPos[3] = playablearea[4]-21
                end

                if self.lastXtarget == NearestWreckPos[1] and self.lastYtarget == NearestWreckPos[3] then
                    self.blocked = self.blocked + 1
                    if self.blocked > 10 then
                        self.blocked = 0
                        SWARMINSERT (PropBlacklist, NearestWreckPos)
                    end
                else
                    self.blocked = 0
                    self.lastXtarget = NearestWreckPos[1]
                    self.lastYtarget = NearestWreckPos[3]
                    StartMoveDestination(self, NearestWreckPos)
                end

            end 
            SWARMWAIT(10)
            if not self.Dead and self:IsUnitState("Moving") then
             
                while self and not self.Dead and self:IsUnitState("Moving") do
                    SWARMWAIT(10)
                end
                scanrange = 25
            end
            IssueClearCommands({self})
            IssueAggressiveMove({self}, self:GetPosition())
            IssueAggressiveMove({self}, self:GetPosition())
        else
           
            local HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
            if HomeDist > 36 then
               
                StartMoveDestination(self, {basePosition[1], basePosition[2], basePosition[3]})
                SWARMWAIT(10)
                if not self.Dead and self:IsUnitState("Moving") then
                    while self and not self.Dead and self:IsUnitState("Moving") and (MassStorageRatio == 1 or EnergyStorageRatio == 1) and HomeDist > 30 do
                        MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS')
                        EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
                        HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
                        SWARMWAIT(30)
                    end
                    IssueClearCommands({self})
                    scanrange = 25
                end
            else
				
                return
            end
        end
        SWARMWAIT(10)
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