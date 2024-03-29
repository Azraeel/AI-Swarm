local AIUtils = import('/lua/ai/aiutilities.lua')

OldGreaterThanEconStorageRatioFunction = GreaterThanEconStorageRatio
function GreaterThanEconStorageRatioSwarm(aiBrain, mStorageRatio, eStorageRatio)
   -- Only use this with AI-Swarm
    if not aiBrain.Swarm then
        return OldGreaterThanEconStorageRatioFunction(aiBrain, mStorageRatio, eStorageRatio)
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    -- If a paragon is present and we not stall mass or energy, return true
    if aiBrain.HasParagon and econ.MassStorageRatio >= 0.01 and econ.EnergyStorageRatio >= 0.01 then
        return true
    elseif econ.MassStorageRatio >= mStorageRatio and econ.EnergyStorageRatio >= eStorageRatio then
        return true
    end
    return false
end

function LessThanEconStorageRatioSwarm(aiBrain, mStorageRatio, eStorageRatio)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassStorageRatio < mStorageRatio or econ.EnergyStorageRatio < eStorageRatio) then
        return true
    end
    return false
end

OldGreaterThanEconTrendFunction = GreaterThanEconTrend
function GreaterThanEconTrendSwarm(aiBrain, MassTrend, EnergyTrend)
   -- Only use this with AI-Swarm
    if not aiBrain.Swarm then
        return OldGreaterThanEconTrendFunction(aiBrain, MassTrend, EnergyTrend)
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    -- If a paragon is present and we have at least a neutral m+e trend, return true
    if aiBrain.HasParagon and econ.MassTrend >= 0 and econ.EnergyTrend >= 0 then
        return true
    elseif econ.MassTrend >= MassTrend and econ.EnergyTrend >= EnergyTrend then
        return true
    end
    return false
end

OldGreaterThanEconIncomeFunction = GreaterThanEconIncome
function GreaterThanEconIncomeSwarm(aiBrain, MassIncome, EnergyIncome)
   -- Only use this with AI-Swarm
    if not aiBrain.Swarm then
        return OldGreaterThanEconIncomeFunction(aiBrain, MassIncome, EnergyIncome)
    end
    -- If a paragon is present, return true
    if aiBrain.HasParagon then
        return true
    end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassIncome >= MassIncome and econ.EnergyIncome >= EnergyIncome) then
        return true
    end
    return false
end

function GreaterThanMassTrendSwarm(aiBrain, mTrend, DEBUG)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if DEBUG then
        --LOG('Current Energy Trend is : ', econ.MassTrend)
    end
    if econ.MassTrend < mTrend then
        --LOG('Less Than Mass Trend Returning True : '..econ.MassTrend)
        return true
    else
        --LOG('Less Than Mass Trend Returning False : '..econ.MassTrend)
        return false
    end
end

function GreaterThanEnergyTrendSwarm(aiBrain, eTrend, DEBUG)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if DEBUG then
        --LOG('Current Energy Trend is : ', econ.EnergyTrend)
    end
    if econ.EnergyTrend > eTrend then
        --LOG('Greater than Energy Trend Returning True : '..econ.EnergyTrend)
        return true
    else
        --LOG('Greater than Energy Trend Returning False : '..econ.EnergyTrend)
        return false
    end
end

--            { UCBC, 'LessThanMassTrend', { 50.0 } },
function LessThanMassTrend(aiBrain, mTrend)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.MassTrend < mTrend then
        return true
    else
        return false
    end
end

--            { UCBC, 'LessThanEnergyTrend', { 50.0 } },
function LessThanEnergyTrend(aiBrain, eTrend)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.EnergyTrend < eTrend then
        return true
    else
        return false
    end
end

function GreaterThanEnergyIncomeSwarm(aiBrain, EnergyIncome)
	local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.EnergyIncome >= EnergyIncome then
        return true
    else
        return false
    end
end

--            { UCBC, 'EnergyToMassRatioIncome', { 10.0, '>=',true } },  -- True if we have 10 times more Energy then Mass income ( 100 >= 10 = true )
function EnergyToMassRatioIncome(aiBrain, ratio, compareType)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    --LOG(aiBrain:GetArmyIndex()..' CompareBody {World} ( E:'..(econ.EnergyIncome*10)..' '..compareType..' M:'..(econ.MassIncome*10)..' ) -- R['..ratio..'] -- return '..repr(CompareBody(econ.EnergyIncome / econ.MassIncome, ratio, compareType)))
    return CompareBody(econ.EnergyIncome / econ.MassIncome, ratio, compareType)
end
