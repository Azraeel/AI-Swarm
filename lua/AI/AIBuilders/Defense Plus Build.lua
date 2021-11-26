local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'

local MaxAttackForce = 0.45                                       
local MaxDefense = 0.12
local MaxCapStructure = 0.12      

BuilderGroup { BuilderGroupName = 'Swarm Defense Plus Builders',                               
    BuildersType = 'EngineerBuilder',

    -- This just doesn't work out.
    -- Unreliable and sucks up tons of mass for no pay off
    -- especially against human players

    --[[ Builder {
        BuilderName = 'AI-Swarm T1 Mass Adjacency Defense Engineer',
        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',
        Priority = 800,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 600, -1, 0, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.25, 1.2 }},

            { UCBC, 'AdjacencyCheck', { 'LocationType', 'MASSEXTRACTION', 600, 'ueb2101' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                AdjacencyDistance = 600,
                BuildClose = false,
                ThreatMin = 5,
                ThreatMax = 3000,
                ThreatRings = 1,
                MinRadius = 250,
                BuildStructures = {
                    'T1GroundDefense',
                    'T1AADefense',
                }
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T2 Mass Adjacency Defense Engineer',
        PlatoonTemplate = 'EngineerBuilderT2T3Swarm',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 600, -1, 0, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.25, 1.2 }},

            { UCBC, 'AdjacencyCheck', { 'LocationType', 'MASSEXTRACTION', 600, 'ueb2101' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                AdjacencyDistance = 600,
                BuildClose = false,
                ThreatMin = 5,
                ThreatMax = 3000,
                ThreatRings = 1,
                MinRadius = 250,
                BuildStructures = {
                    'T2GroundDefense',
                    'T2AADefense',
                }
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T3 Mass Adjacency Defense Engineer',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 940,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 600, -1, 0, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.25, 1.3 }},

            { UCBC, 'AdjacencyCheck', { 'LocationType', 'MASSEXTRACTION', 600, 'ueb2101' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION',
                AdjacencyDistance = 600,
                BuildClose = false,
                ThreatMin = 5,
                ThreatMax = 3000,
                ThreatRings = 1,
                MinRadius = 250,
                BuildStructures = {
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T2AADefense',
                }
            }
        }
    }, ]]--
}

BuilderGroup { BuilderGroupName = 'Swarm Defense Plus Builders Expansion',                               
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'AI-Swarm T1 Base D Panic T1 PD',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { MIBC, 'GreaterThanGameTime', { 300 } },

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.DEFENSE * categories.DIRECTFIRE}},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER }}, -- radius, LocationType, unitCount, categoryEnemy

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 50 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
                BaseTemplateFile = '/mods/AI-Swarm/lua/AI/AIBuilders/BaseTemplates Build.lua',
                BaseTemplate = 'T1PDTemplate',
                BuildClose = true,
                OrderedTemplate = true,
                NearBasePatrolPoints = false,
                BuildStructures = {
                    'T1GroundDefense',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T1 Base D AA Engineer - Response',
        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.DEFENSE * categories.TECH1 * categories.ANTIAIR}},

            { UCBC, 'AirStrengthRatioLessThan', { 1.0 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 50 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH1 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                BuildClose = false,
                BuildStructures = {
                    'T1AADefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T1 Base D PD Engineer - Response',
        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.DEFENSE * categories.TECH1 * categories.DIRECTFIRE}},

            { UCBC, 'LandStrengthRatioLessThan', { 1.0 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 50 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH1 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                BuildClose = false,
                BuildStructures = {
                    'T1GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T2 Base D AA Engineer - Response',
        PlatoonTemplate = 'EngineerBuilderT2T3Swarm',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.DEFENSE * categories.ANTIAIR * categories.STRUCTURE * categories.TECH2}},

            { UCBC, 'AirStrengthRatioLessThan', { 1.0 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.01 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH2 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                BuildClose = false,
                BuildStructures = {
                    'T2AADefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T2 Base D PD Engineer - Response',
        PlatoonTemplate = 'EngineerBuilderT2T3Swarm',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.DEFENSE * categories.DIRECTFIRE * categories.STRUCTURE * categories.TECH2}},

            { UCBC, 'LandStrengthRatioLessThan', { 1.0 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.01 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH2 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                BuildClose = false,
                BuildStructures = {
                    'T2GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T2 Base D Artillery Engineer - Response',
        PlatoonTemplate = 'EngineerBuilderT2T3Swarm',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.DEFENSE * categories.ARTILLERY * categories.STRUCTURE * categories.TECH2}},

            { UCBC, 'LandStrengthRatioLessThan', { 0.8 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 300 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.06 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3),
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                BuildClose = false,
                BuildStructures = {
                    'T2Artillery',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T3 Base D Engineer AA - Response',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 945,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.DEFENSE * categories.ANTIAIR * categories.STRUCTURE}},

            { UCBC, 'AirStrengthRatioLessThan', { 1.0 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH3 * categories.STRUCTURE * (categories.ANTIAIR + categories.DIRECTFIRE) } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'AI-Swarm T3 Base D Engineer AA - Response To Ratio',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 1025,
        InstanceCount = 1,                                      
        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 0.8 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                maxUnits = 1,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },  
}
