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

BuilderGroup { BuilderGroupName = 'Swarm ACU Initial Opener',
    BuildersType = 'EngineerBuilder',    
    Builder {
        BuilderName = 'Swarm Commander First Factory',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 5000,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
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
        BuilderName = 'Swarm Commander Intial Mexes',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 4900,
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 12, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSEXTRACTION }},
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'Swarm Factory Builders Naval',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S1 Sea Factory 1st',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 605,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01}},

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
        BuilderName = 'Swarm Naval Factory Mass > 0.7',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},          
            
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

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

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

BuilderGroup { BuilderGroupName = 'T1 Phase Adaptiveness',
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'Swarm Land Factory Mass > 0.02',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },
            
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},

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
        BuilderName = 'SC Land Factory Mass > 0.015',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },
            
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.015, 0.01}},

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

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.035, 0.01}},

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
        BuilderName = 'Swarm Air Factory Enemy - Outnumbered',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.035, 0.01}},

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
        BuilderName = 'Swarm Land Factory - Good Eco - Outnumbered',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.03, 0.01}},

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
        Priority = 650,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.03, 0.01}},

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
        BuilderName = 'Swarm Air Factory - Good Eco - No Air Factory',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 655,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = true,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Factory Builder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Commander Factory Builder Land - Recover',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 600,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.30}}, 

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Factory Builders Expansions',
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'All Land Factory Expansions',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 500,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.075, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.85, 0.9 }},

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
        Priority = 500,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathNavalBaseToNavalTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.AIR }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.075, 0.01}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.85, 0.9 }},

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
        	{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.05 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.03, 0.1}},

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
        	{ EBC, 'GreaterThanEconEfficiencyOverTime', { 1.15, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}},

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
    
    Builder { BuilderName = 'U-T2 Air Staging 1st',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 15300,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.30, 0.99}},
           
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
    Builder { BuilderName = 'U-T2 Air Staging',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 15300,
        BuilderConditions = {
            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 0.05, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM, '<', categories.MOBILE * categories.AIR } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.75, 0.99}}, 

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

