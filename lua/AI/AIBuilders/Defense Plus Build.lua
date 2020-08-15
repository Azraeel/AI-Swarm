local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)
local MaxDefense = 0.12 -- 12% of all units can be defenses (categories.STRUCTURE * categories.DEFENSE)
local MaxCapStructure = 0.12      

BuilderGroup { BuilderGroupName = 'Swarm Defense Plus Builders',                               
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'AI-Swarm T1 Mass Adjacency Defense Engineer',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 800,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 600, -1, 0, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.25, 1.2 }},

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
        PlatoonTemplate = 'EngineerBuilderT2T3',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 600, -1, 0, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.25, 1.2 }},

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
        PlatoonTemplate = 'EngineerBuilderT3&SUB',
        Priority = 940,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 600, -1, 0, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.25, 1.3 }},

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
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Defense Plus Builders Expansion',                               
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'AI-Swarm T1 Base D AA Engineer - Response',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'DEFENSE ANTIAIR STRUCTURE TECH1'}},

            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 1, 'Air' } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.3, 1.2 }},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH1 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = 'STRUCTURE FACTORY',
                AdjacencyDistance = 175,
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
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'DEFENSE DIRECTFIRE STRUCTURE TECH1'}},

            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 1, 'Land' } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.3, 1.2 }},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH1 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = 'STRUCTURE FACTORY',
                AdjacencyDistance = 175,
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
        PlatoonTemplate = 'EngineerBuilderT2T3',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'DEFENSE ANTIAIR STRUCTURE TECH2'}},

            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 1, 'Air' } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.25, 1.2 }},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH2 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = 'STRUCTURE FACTORY',
                AdjacencyDistance = 175,
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
        PlatoonTemplate = 'EngineerBuilderT2T3',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'DEFENSE DIRECTFIRE STRUCTURE TECH2'}},

            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 1, 'Land' } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.25, 1.2 }},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH2 * categories.STRUCTURE - categories.SHIELD - categories.ANTIMISSILE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = 'STRUCTURE FACTORY',
                AdjacencyDistance = 175,
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
        PlatoonTemplate = 'EngineerBuilderT2T3',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, 'ARTILLERY TECH2 STRUCTURE'}},

            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 20, 'Land' } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.5, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = 'STRUCTURE FACTORY',
                AdjacencyDistance = 175,
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
        PlatoonTemplate = 'EngineerBuilderT3&SUB',
        Priority = 945,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, 'DEFENSE TECH3 ANTIAIR STRUCTURE' }},

            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 3, 'Air' } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.15, 1.2 }},

            { UCBC, 'LocationEngineersBuildingLess', { 'LocationType', 1, categories.DEFENSE * categories.TECH3 * categories.STRUCTURE * (categories.ANTIAIR + categories.DIRECTFIRE) } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                AdjacencyCategory = 'STRUCTURE FACTORY',
                AdjacencyDistance = 175,
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
}
