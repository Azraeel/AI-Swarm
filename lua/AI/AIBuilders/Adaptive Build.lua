local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapFactory = 0.015 -- 0.015% of all units can be factories (STRUCTURE * FACTORY)

-- ===================================================-======================================================== --
-- ==                                       Early T1 Phase - Adaptive                                        == --
-- ===================================================-======================================================== --

BuilderGroup { BuilderGroupName = 'T1 Phase Adaptiveness',
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'Swarm Land Factory Mass > 0.4',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },
            
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},          
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildClose = false,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'SC Land Factory Mass > 0.4',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },
            
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.045, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},          
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Land Factory Enemy - Outnumbered',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.STRUCTURE * categories.FACTORY * categories.LAND, '<',categories.STRUCTURE * categories.FACTORY * categories.LAND } },
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Air Factory Enemy - Outnumbered',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 640,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.STRUCTURE * categories.FACTORY * categories.AIR, '<',categories.STRUCTURE * categories.FACTORY * categories.AIR } },
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Land Factory - Good Eco - Outnumbered',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 640,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.06, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.STRUCTURE * categories.FACTORY * categories.LAND, '<',categories.STRUCTURE * categories.FACTORY * categories.LAND } },
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Air Factory - Good Eco - Outnumbered',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 640,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.06, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.STRUCTURE * categories.FACTORY * categories.AIR, '<',categories.STRUCTURE * categories.FACTORY * categories.AIR } },
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm No Air Factory - Still',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 655,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.05, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR - categories.SUPPORTFACTORY } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm First Air Factory',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.06, 0.75}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR - categories.SUPPORTFACTORY } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}

