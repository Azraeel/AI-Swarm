local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                             Assistees                                                  == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Engineer Assistees',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- =============== --
    --    Factories    --
    -- =============== --
    Builder {
        BuilderName = 'Basic Engineer Assist Engineer',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1000,
        InstanceCount = 75,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true, 
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'S1 Assist 1st T2 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 150,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                AssistClosestUnit = true, 
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH2'},        -- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },
    Builder { BuilderName = 'S1 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                AssistClosestUnit = true, 
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 210,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                AssistClosestUnit = true, 
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 250,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE FACTORY'},                   -- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },

    -- =============== --
    --    COMMANDER    --
    -- =============== --
    Builder {
        BuilderName = 'SC Assist Hydro',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocationSwarm', { 'LocationType', 0, categories.STRUCTURE * categories.HYDROCARBON }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 25,
                BeingBuiltCategories = {'STRUCTURE HYDROCARBON'},
                AssistUntilFinished = true,
            },
        }
    },

    Builder {
        BuilderName = 'SC Assist Standard',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 550,
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'TECH2', 'TECH3', 'EXPERIMENTAL'},               -- Unitcategories must be type string
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'SC Assist Energy',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 2.0, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 0.6 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    -- ============ --
    --    ENERGY    --
    -- ============ --
    Builder { BuilderName = 'S1 Assist Energy Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 570,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 2, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.6 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'S2 Assist Energy Turbo',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 605,
        InstanceCount = 15,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 2, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.6 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'S3 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 650,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 4, 50 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.6 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'S4 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistSUB',
        Priority = 650,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 4, 50 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.6 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'S1 Assist HYDROCARBON Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 565,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'HYDROCARBON'},-- Unitcategories must be type string
                AssistUntilFinished = false,
            },
        }
    },

    -- =================== --
    --    General Assist   --
    -- =================== --
    Builder {
        BuilderName = 'All Engineer Assist Engineer',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 950,
        InstanceCount = 50,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL } },

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.03, 0.01}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'TECH2', 'TECH3', 'EXPERIMENTAL'},               -- Unitcategories must be type string
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 150,
            },
        }
    },

    -- ============ --
    --    Paragon   --
    -- ============ --
    Builder { BuilderName = 'All Assist PARA',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1000,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.07, 1.1 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 300,
                PermanentAssist = false,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                Time = 150,
            },
        }
    },
    -- =================== --
    --    Experimentals    --
    -- =================== --
    Builder { BuilderName = 'All Assist Experimental',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1500,
        InstanceCount = 65,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 8.5, 200 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                PermanentAssist = false,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL'},                        -- Unitcategories must be type string
                Time = 150,
            },
        }
    },

    -- ================== --
    --    Quantum Gate    --
    -- ================== --
    Builder { BuilderName = 'All Assist Quantum Gate',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1500,
        InstanceCount = 65,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                PermanentAssist = false,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'GATE FACTORY'},                                -- Unitcategories must be type string
                Time = 150,
            },
        }
    },

    -- ============== --
    --    STRATEGIC   --
    -- ============== --

    Builder { BuilderName = 'All Assist SMD',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1500,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 4.5, 50 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'ANTIMISSILE SILO'},-- Unitcategories must be type string
                PermanentAssist = false,
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'All Assist SML',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 4.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.03, 1.04 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC NUKE'},-- Unitcategories must be type string
                PermanentAssist = false,
                Time = 150,
            },
        }
    },

    Builder { BuilderName = 'All Assist T3-T4 Artillery',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1400,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 8.5, 200 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.05 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC ARTILLERY'},-- Unitcategories must be type string
                PermanentAssist = false,
                Time = 150,
            },
        }
    },

    Builder {
        BuilderName = 'S3 Engineer Assist Build Nuke Missile',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 850,
        InstanceCount = 6,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, 'NUKE STRUCTURE'}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.03 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 500,
                AssisteeCategory = 'STRUCTURE NUKE',
                PermanentAssist = false,
                Time = 150,
            },
        }
    },


    -- ============== --
    --    Shields     --
    -- ============== --
    Builder { BuilderName = 'All Assist Shield',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 310,
        InstanceCount = 15,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD'},                    -- Unitcategories must be type string
                AssisteeType = 'Structure',
                AssistRange = 250,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                PermanentAssist = false,
                Time = 150,
            },
        }
    },

    -- =============== --
    --    Finisher     --
    -- =============== --
    Builder { BuilderName = 'S1 Finisher',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'FinisherAISwarm',
        Priority = 750,
        InstanceCount = 10,
        BuilderConditions = {
            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 Finisher',
        PlatoonTemplate = 'T2EngineerBuilder',
        PlatoonAIPlan = 'FinisherAISwarm',
        Priority = 760,
        InstanceCount = 10,
        BuilderConditions = {
            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    -- =============== --
    --    Repair     --
    -- =============== --
    Builder { BuilderName = 'S1 Engineer Repair',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 Engineer Repair',
        PlatoonTemplate = 'T2EngineerBuilder',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 1,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}

-- ============== --
--    Reclaim     --
-- ============== --
BuilderGroup { BuilderGroupName = 'Swarm Engineer Reclaim',                                -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',

    Builder { BuilderName = 'Swarm Reclaim Mass - Opener',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 595,
        InstanceCount = 2,
        BuilderConditions = {
            { EBC, 'LessThanEconStorageRatio', { 1.0, 2.0}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },


    Builder { BuilderName = 'Swarm Reclaim - Mass',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 1,
        BuilderConditions = {
            { EBC, 'LessThanEconStorageRatio', { 0.9, 2}}, 

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm Reclaim - Energy',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 1,
        BuilderConditions = {
            { EBC, 'LessThanEconStorageRatio', { 0.9, 2}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 Reclaim Resource 1',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.ENGINEER}},

            { EBC, 'LessThanEconStorageRatio', { 0.9, 2}}, 

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType',  1, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 Reclaim Resource 2',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 9, categories.MOBILE * categories.ENGINEER}},

            { EBC, 'LessThanEconStorageRatio', { 0.9, 2}}, 

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType',  1, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 Reclaim Resource 3',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH2}},

            { EBC, 'LessThanEconStorageRatio', { 0.9, 2}}, 

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType',  1, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 Reclaim Resource 4',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH3}},

            { EBC, 'LessThanEconStorageRatio', { 0.9, 2}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType',  1, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}

