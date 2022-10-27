local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'                                           

-- ===================================================-======================================================== --
-- ==                                       Build Power TECH 1,2,3                                           == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'S123 Energy Builders',                              
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Power Low Trend',

        PlatoonTemplate = 'T1EngineerBuilderSwarm',

        Priority = 655,

        InstanceCount = 2,

        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION - categories.TECH1 - categories.COMMAND } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},

            { EBC, 'LessThanEnergyTrendOverTimeSwarm', { 4.0 } },             
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 0,
            Construction = {
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.RADAR * categories.STRUCTURE,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                    categories.MASSEXTRACTION * categories.TECH1,
                    categories.ENERGYSTORAGE,   
                },
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Power Hydrocarbon Normal',

        PlatoonTemplate = 'T1EngineerBuilderSwarm',

        Priority = 675,

        InstanceCount = 1,

        BuilderConditions = {
            { MABC, 'CanBuildOnHydroSwarm', { 'LocationType', 240, -1000, 4, 1, 'AntiSurface', 1 }},            
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1HydroCarbon',
                }
            }
        }
    },


    -- ============ --
    --    TECH 2    --
    -- ============ --

    Builder {
        BuilderName = 'S2 Power',

        PlatoonTemplate = 'T2EngineerBuilderSwarm',

        Priority = 1000,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ENGINEER * categories.TECH3 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            
            { EBC, 'LessThanEnergyTrendOverTimeSwarm', { 8.0 } },              -- Ratio from 0 to 1. (1=100%)

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 6,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyPriority = {
                    categories.SHIELD * categories.STRUCTURE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.RADAR * categories.STRUCTURE,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
                maxUnits = 1,
                maxRadius = 10,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    Builder {
        BuilderName = 'S3 Power',

        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',

        Priority = 2700,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'LessThanEnergyTrendOverTimeSwarm', { 200.0 } },              -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 6,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyPriority = {
                    categories.SHIELD * categories.STRUCTURE,
                    categories.MASSPRODUCTION * categories.TECH3,
                    categories.STRUCTURE * categories.GATE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.RADAR * categories.STRUCTURE,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },

    -- =================== --
    --    EnergyStorage    --
    -- =================== --

    Builder {
        BuilderName = 'T1 Energy Storage Builder OverCharge',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 800,
        BuilderConditions = {
            { MIBC, 'GreaterThanGameTime', { 300 } },

            { UCBC, 'UnitCapCheckLess', { .7 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'ENERGYSTORAGE' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    Builder {
        BuilderName = 'T1 Energy Storage Builder',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 500,
        BuilderConditions = {
            { MIBC, 'GreaterThanGameTime', { 600 } },

            { UCBC, 'UnitCapCheckLess', { .7 } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
            
            { UCBC, 'HaveLessThanUnitsWithCategory', { 9, 'ENERGYSTORAGE' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'EnergyStorage',
                },
            }
        }
    },
    
    -- ======================= --
    --    Reclaim Buildings    --
    -- ======================= --

    Builder {
        BuilderName = 'S1 Reclaim T1 Pgens',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 Reclaim T1 Pgens cap',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 1.0 } }, -- relative income

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},

            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH1 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 Reclaim T2 Pgens',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 Reclaim T2 Pgens cap',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 50.0 } }, -- relative income

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 Reclaim E storage cap',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.ENERGYSTORAGE }},

            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.ENERGYSTORAGE},
        },
        BuilderType = 'Any',
    },
}


BuilderGroup {
    BuilderGroupName = 'SExpansion23 Energy Builders',                              
    BuildersType = 'EngineerBuilder',

    -- ============ --
    --    TECH 2    --
    -- ============ --

    Builder {
        BuilderName = 'S2 Power Expansion',
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'IsEngineerNotBuildingSwarm', { categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) }},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},
            
            { EBC, 'LessThanEnergyTrendOverTimeSwarm', { 8.0 } },              -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 25,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyPriority = {
                    categories.SHIELD * categories.STRUCTURE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.RADAR * categories.STRUCTURE,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
                maxUnits = 1,
                maxRadius = 10,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    Builder {
        BuilderName = 'S3 Power Expansion',
        
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',

        Priority = 2700,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'IsEngineerNotBuildingSwarm', { categories.ENERGYPRODUCTION * categories.TECH3 }},

            { EBC, 'LessThanEnergyTrendOverTimeSwarm', { 0.0 } },              -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyPriority = {
                    categories.SHIELD * categories.STRUCTURE,
                    categories.MASSPRODUCTION * categories.TECH3,
                    categories.STRUCTURE * categories.GATE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.RADAR * categories.STRUCTURE,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
                maxUnits = 1,
                maxRadius = 15,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },

    -- ======================= --
    --    Reclaim Buildings    --
    -- ======================= --

    Builder {
        BuilderName = 'S1 Reclaim T2 Pgens Expansion',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 Reclaim T2 Pgens Cap Expansion',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 50.0 } }, -- relative income

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON }},
            
            { UCBC, 'UnitCapCheckGreater', { 0.95 } },
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.TECH2 * categories.ENERGYPRODUCTION - categories.HYDROCARBON},
        },
        BuilderType = 'Any',
    },
}