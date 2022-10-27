local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)
local MaxDefense = 0.12 -- 12% of all units can be defenses (categories.STRUCTURE * categories.DEFENSE)
local MaxCapStructure = 0.12       


BuilderGroup { BuilderGroupName = 'Swarm Strategic Builder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S2 TML Minimum',
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.TACTICALMISSILEPLATFORM}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'ForwardClose',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1,
                },
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2StrategicMissile',
                },
                Location = 'LocationType',
            }
        }
    },
                            
    Builder {
        BuilderName = 'S2 TML Maximum',
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },       

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'ForwardClose',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1,
                },
                BuildClose = false,
                BuildStructures = {
                    'T2StrategicMissile',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'Swarm SML Rush',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 900,
        InstanceCount = 1, 
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.1, 1.2 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 35,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                },
                maxUnits = 1,
                maxRadius = 20,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm SML Normal',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 870,
        InstanceCount = 1, 
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.NUKE * categories.TECH3}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.15, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 35,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                },
                maxUnits = 1,
                maxRadius = 20,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm SML Overwhelm',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 850,
        InstanceCount = 2, 
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.25, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},     

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 2, categories.STRUCTURE * categories.NUKE * categories.TECH3, '<=', categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 12, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 35,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                },
                maxUnits = 1,
                maxRadius = 20,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3StrategicMissile',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm RapidArtillery',
        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.06 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyBias = 'Back',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                },
                BuildStructures = {
                    'T3RapidArtillery',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'Swarm T4 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.06 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyBias = 'Back',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                },
                BuildStructures = {
                    'T4Artillery',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'Swarm T3 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyBias = 'Back',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                },
                BuildStructures = {
                    'T3Artillery',
                },
                Location = 'LocationType',
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'Strategic Platoon Formers',                       -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'ArtilleryAI',
        PlatoonTemplate = 'AddToArtilleryPlatoon',
        Priority = 4000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, (categories.STRUCTURE * categories.ARTILLERY * ( categories.TECH3 + categories.EXPERIMENTAL )) + categories.SATELLITE } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'S34ArtilleryAI',
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'NukePlatoonAISwarm',
        PlatoonTemplate = 'AddToNukePlatoon',
        Priority = 4000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.STRUCTURE * categories.NUKE * (categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderData = {
            AIPlan = 'NukePlatoonAISwarm',
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S2 TML AI',
        PlatoonTemplate = 'T2TacticalLauncherSwarm',
        Priority = 18000,
        InstanceCount = 20,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM * categories.TECH2} },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}


