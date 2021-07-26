local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local MaxCapStructure = 0.12                                                   

-- ===================================================-======================================================== --
-- ==                                       Build Power TECH 1,2,3                                           == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'S123 Energy Builders',                              
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Power low trend',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 650,
        InstanceCount = 2,                                                     
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},

            { UCBC, 'GreaterThanGameTimeSeconds', { 260 } },

            { EBC, 'LessThanEnergyTrend', { 0.0 } },             

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH2 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.FACTORY * categories.STRUCTURE * (categories.AIR + categories.LAND),
                AdjacencyDistance = 50,
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },

    --==========================--
    --  Early Game Power Scale  --
    --==========================--

    Builder {
        BuilderName = 'Swarm Power low trend - Scale Power',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 660,
        InstanceCount = 3,                                                     
        DelayEqualBuildPlattons = {'Energy', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0}},

            { EBC, 'LessThanEnergyTrend', { 4.0 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION - categories.TECH1 - categories.COMMAND } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.FACTORY * categories.STRUCTURE * (categories.AIR + categories.LAND),
                AdjacencyDistance = 50,
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Power Hydrocarbon Rush',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 675,
        DelayEqualBuildPlattons = {'Energy', 1},
        InstanceCount = 1,
        BuilderConditions = {
            
            { MABC, 'CanBuildOnHydroSwarm', { 'LocationType', 50, -1000, 15, 1, 'AntiSurface', 1 }},          

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.HYDROCARBON } },

            { EBC, 'GreaterThanEconIncomeSwarm',  { 0.2, 2.0}}, 

            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
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

    Builder {
        BuilderName = 'Swarm Power Hydrocarbon Normal',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 660,
        DelayEqualBuildPlattons = {'Energy', 1},
        InstanceCount = 1,
        BuilderConditions = {
            { MABC, 'CanBuildOnHydroSwarm', { 'LocationType', 240, -1000, 15, 1, 'AntiSurface', 1 }},            

            { EBC, 'GreaterThanEconIncomeSwarm',  { 0.2, 2.0}}, 

            { EBC, 'LessThanEconStorageRatio', { 2.0, 0.75 } },

            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},
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
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'LessThanEnergyTrend', { 8.0 } },              -- Ratio from 0 to 1. (1=100%)

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 25,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH2,
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
        BuilderName = 'S3 Power0',
        PlatoonTemplate = 'EngineerBuilderT3&SUB',
        Priority = 2700,
        DelayEqualBuildPlattons = {'Energy', 10},
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Energy' }},

            { EBC, 'LessThanEnergyTrend', { 0.0 } },              -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = (categories.STRUCTURE * categories.SHIELD) + (categories.FACTORY * (categories.TECH3 + categories.TECH2 + categories.TECH1)),
                AvoidCategory = categories.ENERGYPRODUCTION * categories.TECH3,
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
        PlatoonTemplate = 'EngineerBuilder',
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
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 500,
        BuilderConditions = {
            { MIBC, 'GreaterThanGameTime', { 600 } },
            { UCBC, 'UnitCapCheckLess', { .7 } },
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.20, 0.30 } },             -- Ratio from 0 to 1. (1=100%)
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
        PlatoonTemplate = 'EngineerBuilder',
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
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 1.0 } }, -- relative income

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
        PlatoonTemplate = 'EngineerBuilder',
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
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 50.0 } }, -- relative income

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
        PlatoonTemplate = 'EngineerBuilder',
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
