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
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.60 } }, 

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.TACTICALMISSILEPLATFORM}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'STRUCTURE SHIELD, STRUCTURE ENERGYPRODUCTION',
                AdjacencyDistance = 50,
                AvoidCategory = categories.FACTORY,
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
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.60 } },       

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 50,
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
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 900,
        DelayEqualBuildPlattons = {'NukeBuilder', 3},
        InstanceCount = 1, 
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'CheckBuildPlattonDelay', { 'NukeBuilder' }},

            { EBC, 'GreaterThanEconIncome',  { 4, 200}}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 35,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
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
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 870,
        DelayEqualBuildPlattons = {'NukeBuilder', 3},
        InstanceCount = 1, 
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.NUKE * categories.TECH3}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { EBC, 'GreaterThanEconStorageRatio', { 0.45, 0.60 } },

            { UCBC, 'CheckBuildPlattonDelay', { 'NukeBuilder' }},

            { EBC, 'GreaterThanEconIncome',  { 8, 200}}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NUKE * categories.STRUCTURE}},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 35,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
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
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 850,
        DelayEqualBuildPlattons = {'NukeBuilder', 3},
        InstanceCount = 2, 
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.85, 0.85 } },         

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 }},

            { UCBC, 'CheckBuildPlattonDelay', { 'NukeBuilder' }},

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
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.NUKE,
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
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Artillery', 3},
        InstanceCount = 1,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.60, 0.70 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = true,
                BuildStructures = {
                    'T3RapidArtillery',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'Swarm T4 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Artillery', 3},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.65, 0.70 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = true,
                BuildStructures = {
                    'T4Artillery',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'Swarm T3 Artillery',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Artillery', 3},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'CheckBuildPlattonDelay', { 'Artillery' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.65, 0.70 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ARTILLERY * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = true,
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


