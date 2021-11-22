local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

local HaveLessThanTwoT2AirFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR - categories.TECH1, false, true )) < 2 then
	
		return 500, true
		
	end

	
	return 0, false
	
end


local HaveLessThanTwoT3AirFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR * categories.TECH3, false, true )) < 2 then
	
		return 500, true
		
	end

	
	return 0, false
	
end

BuilderGroup {
    BuilderGroupName = 'Swarm Adaptive Air Build',
    BuildersType = 'FactoryBuilder',

    Builder {
        BuilderName = 'T1AirBomber - Crush Enemy - Swarm',

        PlatoonTemplate = 'T1AirBomber',

        Priority = 550,

        PriorityFunction = HaveLessThanTwoT2AirFactory,

        BuilderType = 'Air',

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 5 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.MOBILE * categories.AIR * categories.BOMBER } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
    },

    Builder {
        BuilderName = 'T1AirGunship - Crush Enemy - Swarm',

        PlatoonTemplate = 'T1Gunship',

        Priority = 550,

        PriorityFunction = HaveLessThanTwoT2AirFactory,

        BuilderType = 'Air',

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 5 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
    },
    
    -- ============ --
    --    TECH 2    --
    -- ============ --

    Builder {
        BuilderName = 'T2AirGunship - Crush Enemy - Swarm',

        PlatoonTemplate = 'T2AirGunship',

        Priority = 775,

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        BuilderType = 'Air',

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 5 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
    },

    Builder {
        BuilderName = 'T2FighterBomber - Crush Enemy - Swarm',

        PlatoonTemplate = 'T2FighterBomber',

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        Priority = 775,

        BuilderType = 'Air',

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 5 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
    },

    Builder {
        BuilderName = 'T2TorpedoBomber - Swarm - WaterMap',

        PlatoonTemplate = 'T2AirTorpedoBomber',

        Priority = 775,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 5 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTINAVY }},

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.NAVAL * categories.MOBILE } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    
    Builder {
        BuilderName = 'T3AirBomber - Crush Enemy - Swarm',

        PlatoonTemplate = 'T3AirBomber',

        Priority = 1000,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 5 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.9, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T3AirGunship - Crush Enemy - Swarm',

        PlatoonTemplate = 'T3AirGunship',

        Priority = 1000,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 5 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.9, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderType = 'Air',
    }, 
}