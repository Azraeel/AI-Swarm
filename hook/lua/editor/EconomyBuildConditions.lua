-- Fuck This Replacing and Ripping basically the economical guts of the AI
-- This shit is more then painful holy fuck

local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend
local GetEconomyStoredRatio = moho.aibrain_methods.GetEconomyStoredRatio
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome
local GetEconomyRequested = moho.aibrain_methods.GetEconomyRequested
local GetEconomyStored = moho.aibrain_methods.GetEconomyStored

function GreaterThanEconStorageCurrentSwarm(aiBrain, mStorage, eStorage)

    if (GetEconomyStored(aiBrain, 'MASS') >= mStorage and GetEconomyStored(aiBrain, 'ENERGY') >= eStorage) then
        return true
    end
    return false
end

function GreaterThanEconStorageRatioSwarm(aiBrain, mStorageRatio, eStorageRatio)
	if (GetEconomyStoredRatio(aiBrain,'ENERGY') *100) >= eStorageRatio and (GetEconomyStoredRatio(aiBrain,'MASS') *100) >= mStorageRatio then
        return true
    end
    return false
end

function LessThanEconStorageRatioSwarm(aiBrain, mStorageRatio, eStorageRatio)
	if (GetEconomyStoredRatio(aiBrain,'ENERGY') *100) < eStorageRatio and (GetEconomyStoredRatio(aiBrain,'MASS') *100) < mStorageRatio then
        return true
    end
    return false
end

function GreaterThanEconTrendSwarm(aiBrain, mTrend, eTrend)
    if (GetEconomyTrend( aiBrain, 'MASS' ) *10) >= mTrend and (GetEconomyTrend( aiBrain, 'ENERGY' ) *10) >= eTrend then
        return true
    end
    return false
end

function LessThanEconTrendSwarm(aiBrain, mTrend, eTrend)
    if (GetEconomyTrend( aiBrain, 'MASS' ) *10) < mTrend and (GetEconomyTrend( aiBrain, 'ENERGY' ) *10) < eTrend then
        return true
    end
    return false
end

function GreaterThanEconIncomeSwarm(aiBrain, mIncome, eIncome)
	if (GetEconomyIncome( aiBrain, 'MASS') *10) >= mIncome and (GetEconomyIncome( aiBrain, 'ENERGY') *10) >= eIncome then
        return true
    end
    return false
end 

function GreaterThanMassTrendSwarm(aiBrain, mTrend)
    if (GetEconomyTrend( aiBrain, 'MASS' ) *10) >= mTrend then
        return true
    end
    return false
end

function GreaterThanEnergyTrendSwarm(aiBrain, eTrend)
    if (GetEconomyTrend( aiBrain, 'ENERGY' ) *10) >= eTrend then
        return true
    end
    return false
end

function LessThanMassTrendSwarm(aiBrain, mTrend)
	if GetEconomyTrend( aiBrain, 'MASS' ) < mTrend then
        return true
    end
    return false
end

function LessThanEnergyTrendSwarm(aiBrain, eTrend)
	if GetEconomyTrend( aiBrain, 'ENERGY' ) < eTrend then
        return true
    end
    return false
end

function GreaterThanEnergyIncomeSwarm(aiBrain, eIncome)
	if (GetEconomyIncome( aiBrain, 'ENERGY') *10) >= eIncome then
        return true
    end
    return false
end

function GreaterThanEconEfficiencyOverTimeSwarm(aiBrain, MassEfficiency, EnergyEfficiency)
    -- Using eco over time values from the EconomyOverTimeRNG thread.
    --LOG('Mass Wanted :'..MassEfficiency..'Actual :'..MassEfficiencyOverTime..'Energy Wanted :'..EnergyEfficiency..'Actual :'..EnergyEfficiencyOverTime)
    if (aiBrain.EconomyOverTimeCurrent.MassEfficiencyOverTime >= MassEfficiency and aiBrain.EconomyOverTimeCurrent.EnergyEfficiencyOverTime >= EnergyEfficiency) then
        --LOG('GreaterThanEconEfficiencyOverTimeSwarm Returned True')
        return true
    end
    --LOG('GreaterThanEconEfficiencyOverTimeSwarm Returned False')
    return false
end

function GreaterThanEconEfficiencySwarm(aiBrain, MassEfficiency, EnergyEfficiency)

    local EnergyEfficiencyOverTime = math.min(GetEconomyIncome(aiBrain,'ENERGY') / GetEconomyRequested(aiBrain,'ENERGY'), 2)
    local MassEfficiencyOverTime = math.min(GetEconomyIncome(aiBrain,'MASS') / GetEconomyRequested(aiBrain,'MASS'), 2)
    --LOG('Mass Wanted :'..MassEfficiency..'Actual :'..MassEfficiencyOverTime..'Energy Wanted :'..EnergyEfficiency..'Actual :'..EnergyEfficiencyOverTime)
    if (MassEfficiencyOverTime >= MassEfficiency and EnergyEfficiencyOverTime >= EnergyEfficiency) then
        --LOG('GreaterThanEconEfficiencyOverTimeSwarm Returned True')
        return true
    end
    --LOG('GreaterThanEconEfficiencyOverTimeSwarm Returned False')
    return false
end

function LessThanEconEfficiencySwarm(aiBrain, MassEfficiency, EnergyEfficiency)

    local EnergyEfficiencyOverTime = math.min(GetEconomyIncome(aiBrain,'ENERGY') / GetEconomyRequested(aiBrain,'ENERGY'), 2)
    local MassEfficiencyOverTime = math.min(GetEconomyIncome(aiBrain,'MASS') / GetEconomyRequested(aiBrain,'MASS'), 2)
    --LOG('Mass Wanted :'..MassEfficiency..'Actual :'..MassEfficiencyOverTime..'Energy Wanted :'..EnergyEfficiency..'Actual :'..EnergyEfficiencyOverTime)
    if (MassEfficiencyOverTime <= MassEfficiency and EnergyEfficiencyOverTime <= EnergyEfficiency) then
        --LOG('LessThanEconEfficiencyOverTime Returned True')
        return true
    end
    --LOG('LessThanEconEfficiencyOverTime Returned False')
    return false
end

function LessThanEnergyTrendOverTimeSwarm(aiBrain, EnergyTrend)

    if aiBrain.EconomyOverTimeCurrent.EnergyTrendOverTime < EnergyTrend then
        --LOG('GreaterThanEconTrendOverTime Returned True')
        return true
    end
    --LOG('GreaterThanEconTrendOverTime Returned False')
    return false
end

function GreaterThanEconIncomeOverTimeSwarm(aiBrain, massIncome, energyIncome)
    if aiBrain.EconomyOverTimeCurrent.MassIncome > massIncome and aiBrain.EconomyOverTimeCurrent.EnergyIncome > energyIncome then
        return true
    end
    return false
end

function LessThanEconIncomeOverTimeSwarm(aiBrain, massIncome, energyIncome)
    if aiBrain.EconomyOverTimeCurrent.MassIncome < massIncome and aiBrain.EconomyOverTimeCurrent.EnergyIncome < energyIncome then
        return true
    end
    return false
end

--            { UCBC, 'EnergyToMassRatioIncome', { 10.0, '>=',true } },  -- True if we have 10 times more Energy then Mass income ( 100 >= 10 = true )
function EnergyToMassRatioIncomeSwarm(aiBrain, ratio, compareType)
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( E:'..(econ.EnergyIncome*10)..' '..compareType..' M:'..(econ.MassIncome*10)..' ) -- R['..ratio..'] -- return '..repr(CompareBody(econ.EnergyIncome / econ.MassIncome, ratio, compareType)))
    return CompareBody(GetEconomyIncome(aiBrain,'ENERGY') / GetEconomyIncome(aiBrain,'MASS'), ratio, compareType)
end

function GreaterThanMassIncomeToFactorySwarm(aiBrain, t1Drain, t2Drain, t3Drain)

    # T1 Test
    local testCat = categories.TECH1 * categories.FACTORY
    local unitCount = aiBrain:GetCurrentUnits(testCat)
    # Find units of this type being built or about to be built
    unitCount = unitCount + aiBrain:GetEngineerManagerUnitsBeingBuilt((categories.TECH1 + categories.TECH2 + categories.TECH3) * categories.FACTORY)

    local massTotal = unitCount * t1Drain

    # T2 Test
    testCat = categories.TECH2 * categories.FACTORY
    unitCount = aiBrain:GetCurrentUnits(testCat)

    massTotal = massTotal + (unitCount * t2Drain)

    # T3 Test
    testCat = categories.TECH3 * categories.FACTORY
    unitCount = aiBrain:GetCurrentUnits(testCat)

    massTotal = massTotal + (unitCount * t3Drain)

    if not CompareBody((aiBrain.EconomyOverTimeCurrent.MassIncome * 10), massTotal, '>') then
        --LOG('MassToFactoryRatio false')
        --LOG('aiBrain.EconomyOverTimeCurrent.MassIncome * 10 : '..(aiBrain.EconomyOverTimeCurrent.MassIncome * 10))
        --LOG('Factory massTotal : '..massTotal)
        return false
    end
    --LOG('MassToFactoryRatio true')
    --LOG('aiBrain.EconomyOverTimeCurrent.MassIncome * 10 : '..(aiBrain.EconomyOverTimeCurrent.MassIncome * 10))
    --LOG('Factory massTotal : '..massTotal)
    return true
end

function MassToFactoryRatioBaseCheckSwarm(aiBrain, locationType)
    local factoryManager = aiBrain.BuilderManagers[locationType].FactoryManager
    if not factoryManager then
        WARN('*AI WARNING: FactoryCapCheck - Invalid location - ' .. locationType)
        return false
    end

    local t1
    local t2
    local t3
    if aiBrain.CheatEnabled then
        t1 = (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T1Value or 8) * tonumber(ScenarioInfo.Options.BuildMult)
        t2 = (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T2Value or 20) * tonumber(ScenarioInfo.Options.BuildMult)
        t3 = (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T3Value or 30) * tonumber(ScenarioInfo.Options.BuildMult)
    else
        t1 = aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T1Value or 8
        t2 = aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T2Value or 20
        t3 = aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T3Value or 30
    end

    return GreaterThanMassIncomeToFactorySwarm(aiBrain, t1, t2, t3)
end
