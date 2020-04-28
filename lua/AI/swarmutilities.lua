
function ExtractorPauseSwarm(self, aiBrain, MassExtractorUnitList, ratio, techLevel)
    local UpgradingBuilding = nil
    local UpgradingBuildingNum = 0
    local PausedUpgradingBuilding = nil
    local PausedUpgradingBuildingNum = 0
    local DisabledBuilding = nil
    local DisabledBuildingNum = 0
    local IdleBuilding = nil
    local BussyBuilding = nil
    local IdleBuildingNum = 0
    -- loop over all MASSEXTRACTION buildings 
    for unitNum, unit in MassExtractorUnitList do
        if unit
            and not unit.Dead
            and not unit:BeenDestroyed()
            and not unit:GetFractionComplete() < 1
            and EntityCategoryContains(ParseEntityCategory(techLevel), unit)
        then
            -- Is the building upgrading ?
            if unit:IsUnitState('Upgrading') then
                -- If is paused
                if unit:IsPaused() then
                    if not PausedUpgradingBuilding then
                        PausedUpgradingBuilding = unit
                    end
                    PausedUpgradingBuildingNum = PausedUpgradingBuildingNum + 1
                -- The unit is upgrading but not paused
                else
                    if not UpgradingBuilding then
                         UpgradingBuilding = unit
                    end
                    UpgradingBuildingNum = UpgradingBuildingNum + 1
                end
            -- check if we have stopped the production
            elseif unit:GetScriptBit('RULEUTC_ProductionToggle') then
                if not DisabledBuilding then
                    DisabledBuilding = unit
                end
                DisabledBuildingNum = DisabledBuildingNum + 1
            -- we have left buildings that are not disabled, and not upgrading. Mabe they are paused ?
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
    --LOG('* ExtractorPauseSwarm: Idle= '..UpgradingBuildingNum..'   Upgrading= '..UpgradingBuildingNum..'   Paused= '..PausedUpgradingBuildingNum..'   Disabled= '..DisabledBuildingNum..'   techLevel= '..techLevel)
    --Check for energy stall
    --if aiBrain:GetEconomyStoredRatio('ENERGY') < 0.50 and aiBrain:GetEconomyStoredRatio('MASS') > aiBrain:GetEconomyStoredRatio('ENERGY') then
    if aiBrain:GetEconomyStoredRatio('MASS') -0.1 > aiBrain:GetEconomyStoredRatio('ENERGY') then
        -- Have we a building that is actual upgrading
        if UpgradingBuilding then
            -- Its upgrading, now check fist if we only have 1 building that is upgrading
            if UpgradingBuildingNum <= 1 and table.getn(MassExtractorUnitList) >= 6 then
            else
                -- we don't have the eco to upgrade the extractor. Pause it!
                UpgradingBuilding:SetPaused( true )
                --UpgradingBuilding:SetCustomName('Upgrading paused')
                --LOG('Upgrading paused')
                return true
            end
        end
        -- All buildings that are doing nothing
        if IdleBuilding then
            if IdleBuildingNum <= 1 then
            else
                IdleBuilding:SetScriptBit('RULEUTC_ProductionToggle', true)
                --IdleBuilding:SetCustomName('Production off')
                --LOG('Production off')
                return true
            end
        end
    -- Do we produce more mass then we need ? Disable some for more energy    
    else
        if DisabledBuilding then
            DisabledBuilding:SetScriptBit('RULEUTC_ProductionToggle', false)
            --DisabledBuilding:SetCustomName('Production on')
            --LOG('Production on')
            return true
        end
    end
    -- Check for positive Mass/Upgrade ratio
    local MassRatioCheckPositive = GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm( self, aiBrain, ratio, techLevel, '<' )
    -- Did we found a paused unit ?
    if PausedUpgradingBuilding then
        if MassRatioCheckPositive then
            -- We have good Mass ratio. We can unpause an extractor
            PausedUpgradingBuilding:SetPaused( false )
            --PausedUpgradingBuilding:SetCustomName('PausedUpgradingBuilding2 unpaused')
            --LOG('PausedUpgradingBuilding2 unpaused')
            return true
        elseif not MassRatioCheckPositive and UpgradingBuildingNum < 1 and table.getn(MassExtractorUnitList) >= 6 then
            PausedUpgradingBuilding:SetPaused( false )
            --PausedUpgradingBuilding:SetCustomName('PausedUpgradingBuilding1 unpaused')
            --LOG('PausedUpgradingBuilding1 unpaused')
            return true
        end
    end
    -- Check for negative Mass/Upgrade ratio
    local MassRatioCheckNegative = GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm( self, aiBrain, ratio, techLevel, '>=')
    --LOG('* ExtractorPauseSwarm 2 MassRatioCheckNegative >: '..repr(MassRatioCheckNegative)..' - IF this is true , we have bad eco and we should pause.')
    if MassRatioCheckNegative then
        if UpgradingBuildingNum > 1 then
            -- we don't have the eco to upgrade the extractor. Pause it!
            if aiBrain:GetEconomyTrend('MASS') <= 0 and aiBrain:GetEconomyStored('MASS') <= 0.80  then
                UpgradingBuilding:SetPaused( true )
                --UpgradingBuilding:SetCustomName('UpgradingBuilding paused')
                --LOG('UpgradingBuilding paused')
                --LOG('* ExtractorPauseSwarm: Pausing upgrading extractor')
                return true
            end
        end
        if PausedUpgradingBuilding then
            -- if we stall mass, then cancel the upgrade
            if aiBrain:GetEconomyTrend('MASS') <= 0 and aiBrain:GetEconomyStored('MASS') <= 0  then
                IssueClearCommands({PausedUpgradingBuilding})
                PausedUpgradingBuilding:SetPaused( false )
                --PausedUpgradingBuilding:SetCustomName('Upgrade canceled')
                --LOG('Upgrade canceled')
                --LOG('* ExtractorPauseSwarm: Cancel upgrading extractor')
                return true
            end 
        end
    end
    return false
end

-- ExtractorUpgradeSwarm is upgrading the nearest building to our own main base instead of a random building.
function ExtractorUpgradeSwarm(self, aiBrain, MassExtractorUnitList, ratio, techLevel, UnitUpgradeTemplates, StructureUpgradeTemplates)
    -- Do we have the eco to upgrade ?
    local MassRatioCheckPositive = GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm(self, aiBrain, ratio, techLevel, '<' )
    local aiBrain = self:GetBrain()
    -- search for the neares building to the base for upgrade.
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
        -- Check if we don't want to upgrade this unit
        if not v
            or v.Dead
            or v:BeenDestroyed()
            or v:IsPaused()
            or not EntityCategoryContains(ParseEntityCategory(techLevel), v)
            or v:GetFractionComplete() < 1
        then
            -- Skip this loop and continue with the next array
            continue
        end
        if v:IsUnitState('Upgrading') then
            UpgradingBuilding = UpgradingBuilding + 1
            -- Skip this loop and continue with the next array
            continue
        end
        -- Check for the nearest distance from mainbase
        UnitPos = v:GetPosition()
        DistanceToBase= VDist2(BasePosition[1] or 0, BasePosition[3] or 0, UnitPos[1] or 0, UnitPos[3] or 0)
        if not LowestDistanceToBase or DistanceToBase < LowestDistanceToBase then
            -- Get the factionindex from the unit to get the right update (in case we have captured this unit from another faction)
            UnitBeingUpgradeFactionIndex = FactionToIndex[v.factionCategory] or factionIndex
            -- see if we can find a upgrade
            if EntityCategoryContains(categories.MOBILE, v) then
                TempID = aiBrain:FindUpgradeBP(v:GetUnitId(), UnitUpgradeTemplates[UnitBeingUpgradeFactionIndex])
                if not TempID then
                    WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find UnitUpgradeTemplate for mobile unit: ' .. repr(v:GetUnitId()) )
                end
            else
                TempID = aiBrain:FindUpgradeBP(v:GetUnitId(), StructureUpgradeTemplates[UnitBeingUpgradeFactionIndex])
                if not TempID then
                    WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t find StructureUpgradeTemplate for structure: ' .. repr(v:GetUnitId()) )
                end
            end 
            -- Check if we can build the upgrade
            if TempID and EntityCategoryContains(categories.STRUCTURE, v) and not v:CanBuild(TempID) then
                WARN('['..string.gsub(debug.getinfo(1).source, ".*\\(.*.lua)", "%1")..', line:'..debug.getinfo(1).currentline..'] *UnitUpgradeAI ERROR: Can\'t upgrade structure with StructureUpgradeTemplate: ' .. repr(v:GetUnitId()) )
            elseif TempID then
                upgradeID = TempID
                upgradeBuilding = v
                LowestDistanceToBase = DistanceToBase
            end
        end
    end
    -- If we have not the Eco then return false. Exept we have none extractor upgrading or 100% mass storrage
    if not MassRatioCheckPositive and aiBrain:GetEconomyStoredRatio('MASS') < 1.00 then
        -- if we have at least 1 extractor upgrading or less then 4 extractors, then return false
        if UpgradingBuilding > 0 or table.getn(MassExtractorUnitList) < 4 then
            return false
        end
        -- Even if we don't have the Eco for it; If we have more then 4 Extractors, then upgrade at least one of them.
    end
    -- Have we found a unit that can upgrade ?
    if upgradeID and upgradeBuilding then
        --LOG('* ExtractorUpgradeSwarm: Upgrading Building in DistanceToBase '..(LowestDistanceToBase or 'Unknown ???')..' '..techLevel..' - UnitId '..upgradeBuilding:GetUnitId()..' - upgradeID '..upgradeID..' - GlobalUpgrading '..techLevel..': '..(UpgradingBuilding + 1) )
        IssueUpgrade({upgradeBuilding}, upgradeID)
        WaitTicks(10)
        return true
    end
    return false
end

-- Helperfunction fro ExtractorUpgradeAISwarm. 
function GlobalMassUpgradeCostVsGlobalMassIncomeRatioSwarm(self, aiBrain, ratio, techLevel, compareType)
    local GlobalUpgradeCost = 0
    -- get all units matching 'category'
    local unitsBuilding = aiBrain:GetListOfUnits(categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2), true)
    local numBuilding = 0
    -- if we compare for more buildings, add the cost for a building.
    if compareType == '<' or compareType == '<=' then
        numBuilding = 1
        if techLevel == 'TECH1' then
            GlobalUpgradeCost = 10
            MassIncomeLost = 2
        else
            GlobalUpgradeCost = 26
            MassIncomeLost = 6
        end
    end
    local SingleUpgradeCost
    -- own armyIndex
    local armyIndex = aiBrain:GetArmyIndex()
    -- loop over all units and search for upgrading units
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
            -- look for every building, category can hold different categories / techlevels for multiple building search
            local UpgraderBlueprint = unit:GetBlueprint()
            local BeingUpgradeEconomy = __blueprints[UpgraderBlueprint.General.UpgradesTo].Economy
            SingleUpgradeCost = (UpgraderBlueprint.Economy.BuildRate / BeingUpgradeEconomy.BuildTime) * BeingUpgradeEconomy.BuildCostMass
            GlobalUpgradeCost = GlobalUpgradeCost + SingleUpgradeCost
        end
    end
    -- If we have under 20 Massincome return always false
    local MassIncome = ( aiBrain:GetEconomyIncome('MASS') * 10 ) - MassIncomeLost
    if MassIncome < 20 and ( compareType == '<' or compareType == '<=' ) then
        return false
    end
    return CompareBody(GlobalUpgradeCost / MassIncome, ratio, compareType)
end

function HaveUnitRatio(aiBrain, ratio, categoryOne, compareType, categoryTwo)
    local numOne = aiBrain:GetCurrentUnits(categoryOne)
    local numTwo = aiBrain:GetCurrentUnits(categoryTwo)
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( '..numOne..' '..compareType..' '..numTwo..' ) -- ['..ratio..'] -- return '..repr(CompareBody(numOne / numTwo, ratio, compareType)))
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
        -- 1==1 is always true, i use this to clean up the base from wreckages even if we have full eco.
        if (MassStorageRatio < 1.00 or EnergyStorageRatio < 1.00) and not aiBrain.HasParagon then
            --LOG('Searching for reclaimables')
            local x1 = SelfPos[1]-scanrange
            local y1 = SelfPos[3]-scanrange
            local x2 = SelfPos[1]+scanrange
            local y2 = SelfPos[3]+scanrange
            if x1 < playablearea[1]+6 then x1 = playablearea[1]+6 end
            if y1 < playablearea[2]+6 then y1 = playablearea[2]+6 end
            if x2 > playablearea[3]-6 then x2 = playablearea[3]-6 end
            if y2 > playablearea[4]-6 then y2 = playablearea[4]-6 end
            --LOG('GetReclaimablesInRect from x1='..math.floor(x1)..' - x2='..math.floor(x2)..' - y1='..math.floor(y1)..' - y2='..math.floor(y2)..' - scanrange='..scanrange..'')
            local props = GetReclaimablesInRect(Rect(x1, y1, x2, y2))
            local NearestWreckDist = -1
            local NearestWreckPos = {}
            local WreckDist = 0
            local WrackCount = 0
            if props and table.getn( props ) > 0 then
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
                    if BPID == 'ueb5101' or BPID == 'uab5101' or BPID == 'urb5101' or BPID == 'xsb5101' then -- Walls will not be reclaimed on patrols
                        continue
                    end
					-- reclaim mass if mass is lower than energy and reclaim energy if energy is lower than mass and gametime is higher then 4 minutes.
                    if (MassStorageRatio <= EnergyStorageRatio and p.MaxMassReclaim and p.MaxMassReclaim > 1) or (GetGameTimeSeconds() > 240 and MassStorageRatio > EnergyStorageRatio and p.MaxEnergyReclaim and p.MaxEnergyReclaim > 1) then
                        --LOG('Found Wreckage no.('..WrackCount..') from '..BPID..'. - Distance:'..WreckDist..' - NearestWreckDist:'..NearestWreckDist..' '..repr(MassStorageRatio < EnergyStorageRatio)..' '..repr(p.MaxMassReclaim)..' '..repr(p.MaxEnergyReclaim))
                        WreckDist = VDist2(SelfPos[1], SelfPos[3], WreckPos[1], WreckPos[3])
                        WrackCount = WrackCount + 1
                        if WreckDist < NearestWreckDist or NearestWreckDist == -1 then
                            NearestWreckDist = WreckDist
                            NearestWreckPos = WreckPos
                            --LOG('Found Wreckage no.('..WrackCount..') from '..BPID..'. - Distance:'..WreckDist..' - NearestWreckDist:'..NearestWreckDist..'')
                        end
                        if NearestWreckDist < 20 then
                            --LOG('Found Wreckage nearer then 20. break!')
                            break
                        end
                    end
                end
            end
            if self.Dead then
				--LOG('* ReclaimAIThreadSwarm: Unit Dead')
                return
            end
            if NearestWreckDist == -1 then
                scanrange = math.floor(scanrange + 100)
                if scanrange > 512 then -- 5 Km
                    IssueClearCommands({self})
                    scanrange = 25
                    local HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
                    if HomeDist > 50 then
                        --LOG('noop returning home')
                        StartMoveDestination(self, {basePosition[1], basePosition[2], basePosition[3]})
                    end
                    PropBlacklist = {}
                end
                --LOG('No Wreckage, expanding scanrange:'..scanrange..'.')
            elseif math.floor(NearestWreckDist) < scanrange then
                scanrange = math.floor(NearestWreckDist)
                if scanrange < 25 then
                    scanrange = 25
                end
                --LOG('Adapting scanrange to nearest Object:'..scanrange..'.')
            end
            scanKM = math.floor(10000/512*NearestWreckDist)
            if NearestWreckDist > 20 and not self.Dead then
                --LOG('NearestWreck is > 20 away Distance:'..NearestWreckDist..'. Moving to Wreckage!')
				-- We don't need to go too close to the mapborder for reclaim, we have reclaimdrones with a flightradius of 25!
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
                        table.insert (PropBlacklist, NearestWreckPos)
                    end
                else
                    self.blocked = 0
                    self.lastXtarget = NearestWreckPos[1]
                    self.lastYtarget = NearestWreckPos[3]
                    StartMoveDestination(self, NearestWreckPos)
                end
            end 
            WaitTicks(10)
            if not self.Dead and self:IsUnitState("Moving") then
                --LOG('Moving to Wreckage.')
                while self and not self.Dead and self:IsUnitState("Moving") do
                    WaitTicks(10)
                end
                scanrange = 25
            end
            IssueClearCommands({self})
            IssuePatrol({self}, self:GetPosition())
            IssuePatrol({self}, self:GetPosition())
        else
            --LOG('Storage Full')
            local HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
            if HomeDist > 36 then
                --LOG('full, moving home')
                StartMoveDestination(self, {basePosition[1], basePosition[2], basePosition[3]})
                WaitTicks(10)
                if not self.Dead and self:IsUnitState("Moving") then
                    while self and not self.Dead and self:IsUnitState("Moving") and (MassStorageRatio == 1 or EnergyStorageRatio == 1) and HomeDist > 30 do
                        MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS')
                        EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
                        HomeDist = VDist2(SelfPos[1], SelfPos[3], basePosition[1], basePosition[3])
                        WaitTicks(30)
                    end
                    IssueClearCommands({self})
                    scanrange = 25
                end
            else
				--LOG('* ReclaimAIThreadSwarm: Storrage are full, and we are home.')
                return
            end
        end
        WaitTicks(10)
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
        WaitTicks(10)
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

function CDRRunHomeEnemyNearBase(platoon,cdr,UnitsInBasePanicZone)
    local minEnemyDist, EnemyPosition
    local enemyCount = 0
    for _, EnemyUnit in UnitsInBasePanicZone do
        if not EnemyUnit.Dead and not EnemyUnit:BeenDestroyed() then
            if EntityCategoryContains(categories.MOBILE * categories.EXPERIMENTAL, EnemyUnit) then
                --LOG('* ACUAttackAISwarm: CDRRunHomeEnemyNearBase EXPERIMENTAL!!!! RUN HOME:')
                minEnemyDist = 40
                break
            end
            enemyCount = enemyCount + 1
            EnemyPosition = EnemyUnit:GetPosition()
            local dist = VDist2(cdr.CDRHome[1], cdr.CDRHome[3], EnemyPosition[1], EnemyPosition[3])
            if not minEnemyDist or minEnemyDist > dist then
                minEnemyDist = dist
            end
        end
    end
    if minEnemyDist then
        local CDRDist = VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3])
        local cdrNewPos = {}
        if CDRDist > minEnemyDist then
            cdrNewPos[1] = cdr.CDRHome[1] + Random(-6, 6)
            cdrNewPos[2] = cdr.CDRHome[2]
            cdrNewPos[3] = cdr.CDRHome[3] + Random(-6, 6)
            platoon:Stop()
            WaitTicks(1)
            platoon:MoveToLocation(cdrNewPos, false)
            WaitTicks(50)
            return true
        end
    end
    return false
end

function CDRRunHomeHealthRange(platoon,cdr,maxRadius)
    local cdrNewPos = {}
    if VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) > maxRadius then
        cdrNewPos[1] = cdr.CDRHome[1] + Random(-6, 6)
        cdrNewPos[2] = cdr.CDRHome[2]
        cdrNewPos[3] = cdr.CDRHome[3] + Random(-6, 6)
        platoon:Stop()
        WaitTicks(1)
        platoon:MoveToLocation(cdrNewPos, false)
        WaitTicks(50)
        return true
    end
    return false
end

function CDRRunHomeAtDamage(platoon,cdr)
    local CDRHealth = ComHealth(cdr)
    local diff = CDRHealth - cdr.HealthOLD
    if diff < -1 then
        --LOG('Health diff = '..diff)
        local cdrNewPos = {}
        cdrNewPos[1] = cdr.CDRHome[1] + Random(-6, 6)
        cdrNewPos[2] = cdr.CDRHome[2]
        cdrNewPos[3] = cdr.CDRHome[3] + Random(-6, 6)
        platoon:Stop()
        WaitTicks(1)
        platoon:MoveToLocation(cdrNewPos, false)
        WaitTicks(10)
        cdr.HealthOLD = CDRHealth
        return true
    end    
    cdr.HealthOLD = CDRHealth
    return false
end

function CDRForceRunHome(platoon,cdr)
    local cdrNewPos = {}
    cdrNewPos[1] = cdr.CDRHome[1] + Random(-6, 6)
    cdrNewPos[2] = cdr.CDRHome[2]
    cdrNewPos[3] = cdr.CDRHome[3] + Random(-6, 6)
    platoon:Stop()
    WaitTicks(1)
    platoon:MoveToLocation(cdrNewPos, false)
    WaitTicks(30)
    if VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) > 20 then
        return true
    end
    return false
end

function CDRParkingHome(platoon,cdr)
    local cdrNewPos = {}
    while VDist2(cdr.position[1], cdr.position[3], cdr.CDRHome[1], cdr.CDRHome[3]) > 20 do
        cdr.position = platoon:GetPlatoonPosition()
        cdrNewPos[1] = cdr.CDRHome[1] + Random(-6, 6)
        cdrNewPos[2] = cdr.CDRHome[2]
        cdrNewPos[3] = cdr.CDRHome[3] + Random(-6, 6)
        platoon:Stop()
        WaitTicks(1)
        platoon:MoveToLocation(cdrNewPos, false)
        WaitTicks(30)
    end
    return
end

function RandomizePosition(position)
    local Posx = position[1]
    local Posz = position[3]
    local X = -1
    local Z = -1
    while X <= 0 or X >= ScenarioInfo.size[1] do
        X = Posx + Random(-10, 10)
    end
    while Z <= 0 or Z >= ScenarioInfo.size[2] do
        Z = Posz + Random(-10, 10)
    end
    local Y = GetTerrainHeight(Posx, Posz)
    if GetSurfaceHeight(Posx, Posz) > Y then
        Y = GetSurfaceHeight(Posx, Posz)
    end
    return {X, Y, Z}
end

-- Please don't change any range here!!!
-- Called from AIBuilders/*.*, simInit.lua, aiarchetype-managerloader.lua
function GetDangerZoneRadii(bool)
    -- Military zone is the half the map size (10x10map) or maximal 250.
    local BaseMilitaryZone = math.max( ScenarioInfo.size[1]-50, ScenarioInfo.size[2]-50 ) / 2
    BaseMilitaryZone = math.max( 250, BaseMilitaryZone )
    -- Panic Zone is half the BaseMilitaryZone. That's 1/4 of a 10x10 map
    local BasePanicZone = BaseMilitaryZone / 2
    -- Make sure the Panic Zone is not smaller than 60 or greater than 120
    BasePanicZone = math.max( 60, BasePanicZone )
    BasePanicZone = math.min( 120, BasePanicZone )
    -- The rest of the map is enemy zone
    local BaseEnemyZone = math.max( ScenarioInfo.size[1], ScenarioInfo.size[2] ) * 1.5
    -- "bool" is only true if called from "AIBuilders/Mobile Land.lua", so we only print this once.
    if bool then
        LOG('* AI-Swarm: BasePanicZone= '..math.floor( BasePanicZone * 0.01953125 ) ..' Km - ('..BasePanicZone..' units)' )
        LOG('* AI-Swarm: BaseMilitaryZone= '..math.floor( BaseMilitaryZone * 0.01953125 )..' Km - ('..BaseMilitaryZone..' units)' )
        LOG('* AI-Swarm: BaseEnemyZone= '..math.floor( BaseEnemyZone * 0.01953125 )..' Km - ('..BaseEnemyZone..' units)' )
    end
    return BasePanicZone, BaseMilitaryZone, BaseEnemyZone
end

-- 99% of this is Relent0r's Work --Scouting--
function AirScoutPatrolSwarmAIThread(self, aiBrain)
    
    local scout = self:GetPlatoonUnits()[1]
    if not scout then
        return
    end

    -- build scoutlocations if not already done.
    if not aiBrain.InterestList then
        aiBrain:BuildScoutLocations()
    end

    --If we have Stealth (are cybran), then turn on our Stealth
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

        --2) Scout "unknown threat" areas with a threat higher than 25
        elseif table.getn(unknownThreats) > 0 and unknownThreats[1][3] > 25 then
            aiBrain:AddScoutArea({unknownThreats[1][1], 0, unknownThreats[1][2]})

        --3) Scout high priority locations
        elseif aiBrain.IntelData.AirHiPriScouts < aiBrain.NumOpponents and aiBrain.IntelData.AirLowPriScouts < 1
        and table.getn(aiBrain.InterestList.HighPriority) > 0 then
            aiBrain.IntelData.AirHiPriScouts = aiBrain.IntelData.AirHiPriScouts + 1

            highPri = true

            targetData = aiBrain.InterestList.HighPriority[1]
            targetData.LastScouted = GetGameTimeSeconds()
            targetArea = targetData.Position

            aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)

        --4) Every time we scout NumOpponents number of high priority locations, scout a low priority location
        elseif aiBrain.IntelData.AirLowPriScouts < 1 and table.getn(aiBrain.InterestList.LowPriority) > 0 then
            aiBrain.IntelData.AirHiPriScouts = 0
            aiBrain.IntelData.AirLowPriScouts = aiBrain.IntelData.AirLowPriScouts + 1

            targetData = aiBrain.InterestList.LowPriority[1]
            targetData.LastScouted = GetGameTimeSeconds()
            targetArea = targetData.Position

            aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
        else
            --Reset number of scoutings and start over
            aiBrain.IntelData.AirLowPriScouts = 0
            aiBrain.IntelData.AirHiPriScouts = 0
        end

        --Air scout do scoutings.
        if targetArea then
            self:Stop()

            local vec = self:DoAirScoutVecs(scout, targetArea)

            while not scout.Dead and not scout:IsIdleState() do

                --If we're close enough...
                if VDist2Sq(vec[1], vec[3], scout:GetPosition()[1], scout:GetPosition()[3]) < 15625 then
                    if mustScoutArea then
                        --Untag and remove
                        for idx,loc in aiBrain.InterestList.MustScout do
                            if loc == mustScoutArea then
                               table.remove(aiBrain.InterestList.MustScout, idx)
                               break
                            end
                        end
                    end
                    --Break within 125 ogrids of destination so we don't decelerate trying to stop on the waypoint.
                    break
                end

                if VDist3(scout:GetPosition(), targetArea) < 25 then
                    break
                end

                WaitTicks(50)
            end
        else
            WaitTicks(10)
        end
        WaitTicks(5)
    end
end

function DisperseUnitsToRallyPoints( aiBrain, units, position, rallypointtable )

    if not rallypointtable then

        local rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Rally Point', position, 90)
    
        if table.getn(rallypoints) < 1 then
        
            rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Naval Rally Point', position, 90)
            
        end
        
        rallypointtable = {}
        
        for _,v in rallypoints do
        
            table.insert( rallypointtable, v.Position )
            
        end
        
    end

    if table.getn(rallypointtable) > 0 then
    
        local rallycount = table.getn(rallypointtable)
        
        for _,u in units do
        
            local rp = rallypointtable[ Random( 1, rallycount) ]
            
            IssueMove( {u}, RandomLocation(rp[1],rp[3], 9))
            
        end
        
    else
    
        -- try and catch units being dispersed to what may now be a dead base --
        -- the idea is to drop them back into an RTB which should find another base
        --WARN("*AI DEBUG "..aiBrain.Nickname.." DISPERSE FAIL - No rally points at "..repr(position))

        IssueClearCommands( units )

        local ident = Random(1,999999)

        returnpool = aiBrain:MakePlatoon('ReturnToBase '..tostring(ident), 'none' )

        returnpool.PlanName = 'ReturnToBaseAI'
        returnpool.BuilderName = 'DisperseFail'
        
        returnpool.BuilderLocation = false
        returnpool.RTBLocation = false

        import('/lua/ai/aiattackutilities.lua').GetMostRestrictiveLayer(returnpool) 

        for _,u in units do

            if not u.Dead then

                aiBrain:AssignUnitsToPlatoon( returnpool, {u}, 'Unassigned', 'None' )
                
                u.PlatoonHandle = {returnpool}
                u.PlatoonHandle.PlanName = 'ReturnToBaseAI'
                
            end
            
        end
        
        if returnpool.MovementLayer == "Land" then

            -- dont use naval bases for land --
            returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, returnpool:GetPlatoonPosition(), false )

        else

            if returnpool.MovementLayer == "Air" or returnpool.PlatoonLayer == "Amphibious" then

                -- use any kind of base --
                returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, returnpool:GetPlatoonPosition(), true, false )

            else

                -- use only naval bases --
                returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, returnpool:GetPlatoonPosition(), true, true )

            end

        end

        returnpool.RTBLocation = returnpool.BuilderLocation -- this should insure the RTB to that base

        --LOG("*AI DEBUG "..aiBrain.Nickname.." DISPERSE FAIL Platoon at "..repr(returnpool:GetPlatoonPosition()).." submitted to RTB at "..repr(returnpool.BuilderLocation))

        -- send the new platoon off to RTB
        returnpool:SetAIPlan('ReturnToBaseAI', aiBrain)
        
    end

    return
    
end

