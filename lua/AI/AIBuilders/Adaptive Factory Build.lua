local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapFactory = 0.015 -- 0.015% of all units can be factories (STRUCTURE * FACTORY)
local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                       Early T1 Phase - Adaptive                                        == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'Swarm Factory Builders Naval',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S1 Sea Factory 1st',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 655,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL - categories.SUPPORTFACTORY } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.75}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.8 }},

            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1SeaFactory',
                },
            }
        }
    },
    -- ================== --
    --    TECH 1 Enemy    --
    -- ================== --
    Builder {
        BuilderName = 'Swarm Naval Factory Mass > MassStorage',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 250, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 0.9 }},          
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.NAVAL }},
           
            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapFactory , '<', categories.STRUCTURE * categories.FACTORY * categories.NAVAL } }, 
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1SeaFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Naval Factory Enemy - Outnumbered',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 250, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 0.9 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.STRUCTURE * categories.FACTORY * categories.NAVAL, '<',categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1SeaFactory',
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Adaptive Factory Build',
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'Swarm Land Factory Mass > MassStorage',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },
            
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }},         
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
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
        BuilderName = 'Swarm Land Factory Enemy - Outnumbered',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

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
        BuilderName = 'Swarm Air Factory Enemy - Outnumbered',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

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
        BuilderName = 'Swarm Air Factory Mass > MassStorage',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
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
        BuilderName = 'Swarm Air Factory > Air Ratio',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},

            { UCBC, 'AirStrengthRatioLessThan', { 1 } },
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
}

BuilderGroup { BuilderGroupName = 'Swarm Factory Builders Expansions',
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'All Land Factory Expansions',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.STRUCTURE * categories.FACTORY * categories.LAND, '<',categories.STRUCTURE * categories.FACTORY * categories.LAND } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder { BuilderName = 'All Air Factory Expansions',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathNavalBaseToNavalTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.AIR }},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.STRUCTURE * categories.FACTORY * categories.AIR, '<',categories.STRUCTURE * categories.FACTORY * categories.AIR } },
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

BuilderGroup { BuilderGroupName = 'Swarm Gate Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U-T3 Gate Cap - Main Base',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1350,
        BuilderConditions = {
        	{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50}},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Gate' } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3QuantumGate',
                },
            }
        }
    },

    Builder { BuilderName = 'U-T3 Gate Cap - Expansions',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 1300,
        BuilderConditions = {
        	{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.075, 0.75}},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'BuildNotOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Gate' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3QuantumGate',
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Air Staging Platform Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U-T1 Air Staging 1st',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.8}},
           
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder { BuilderName = 'U-T1 Air Staging',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 0.05, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM, '<', categories.MOBILE * categories.AIR } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.15, 0.95}}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM  }},
           
            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
} 

