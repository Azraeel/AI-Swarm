local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

BuilderGroup {
    BuilderGroupName = 'Swarm Adaptive Air Build',
    BuildersType = 'FactoryBuilder',

    --[[ Builder {
        BuilderName = 'T1AirBomber - Crush Enemy - Swarm',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 550,
        BuilderType = 'Air',
        BuilderConditions = {
            { UCBC, 'LessThanThreatAtEnemyBaseSwarm', { 'AntiAir', 100 }},

            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 8, categories.MOBILE * categories.AIR * categories.ANTIAIR, 'Enemy'}},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 3, categories.MOBILE * categories.AIR * categories.BOMBER } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) }},
        },
    },

    Builder {
        BuilderName = 'T1AirGunship - Crush Enemy - Swarm',
        PlatoonTemplate = 'T1Gunship',
        Priority = 550,
        BuilderType = 'Air',
        BuilderConditions = {
            { UCBC, 'LessThanThreatAtEnemyBaseSwarm', { 'AntiAir', 120 }},

            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 10, categories.MOBILE * categories.AIR * categories.ANTIAIR, 'Enemy'}},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) }},
        },
    },
    
    -- ============ --
    --    TECH 2    --
    -- ============ --

    Builder {
        BuilderName = 'T2AirGunship - Crush Enemy - Swarm',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 775,
        BuilderType = 'Air',
        BuilderConditions = {
            { UCBC, 'LessThanThreatAtEnemyBaseSwarm', { 'AntiAir', 540 }},

            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 12, categories.MOBILE * categories.AIR * categories.ANTIAIR, 'Enemy'}},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH2 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
        },
    },

    Builder {
        BuilderName = 'T2FighterBomber - Crush Enemy - Swarm',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 775,
        BuilderType = 'Air',
        BuilderConditions = {
            { UCBC, 'LessThanThreatAtEnemyBaseSwarm', { 'AntiAir', 620 }},

            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 13, categories.MOBILE * categories.AIR * categories.ANTIAIR, 'Enemy'}},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH2 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
        },
    },

    Builder {
        BuilderName = 'T2TorpedoBomber - Swarm - WaterMap',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 775,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTINAVY }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTINAVY * categories.TECH3 }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    
    Builder {
        BuilderName = 'T3AirBomber - Crush Enemy - Swarm',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'LessThanThreatAtEnemyBaseSwarm', { 'AntiAir', 1240 }},

            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3, 'Enemy'}},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T3AirGunship - Crush Enemy - Swarm',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'LessThanThreatAtEnemyBaseSwarm', { 'AntiAir', 1360 }},

            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 9, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3, 'Enemy'}},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.FACTORY * categories.AIR * categories.TECH3 }},
        },
        BuilderType = 'Air',
    }, ]]--
}