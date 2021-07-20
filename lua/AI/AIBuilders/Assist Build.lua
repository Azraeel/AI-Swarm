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
                Time = 75,
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
                Time = 75,
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
                Time = 75,
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
                Time = 75,
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
                Time = 75,
            },
        }
    },

    -- ============ --
    --    ENERGY    --
    -- ============ --
    Builder { BuilderName = 'S1 Assist Energy Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 590,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 2.0, 20.0 } },

            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.0 }},
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
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'S2 Assist Energy Turbo',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 605,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 2.0, 20.0 } },

            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.0 }},
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
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'S3 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 650,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 40.0, 500.0 } },

            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.0 }},
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
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'S4 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistSUB',
        Priority = 650,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 40.0, 500.0 } },

            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.0 }},
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
                Time = 75,
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

    -- ================= --
    --    Mass Assist    --
    -- ================= --

    Builder { BuilderName = 'S1 Assist Mass Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 590,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'LessThanEconStorageRatioSwarm', { 0.20, 2.0}},

            { UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.MASSPRODUCTION - categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'MASSPRODUCTION -TECH1'},-- Unitcategories must be type string
                AssistUntilFinished = false,
                Time = 75,
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
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.03, 0.01}},
            
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'TECH2', 'TECH3', 'EXPERIMENTAL'},               -- Unitcategories must be type string
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 75,
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
                Time = 75,
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
                Time = 75,
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
                Time = 75,
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
                Time = 75,
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
                Time = 75,
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
                Time = 75,
            },
        }
    },

    Builder {
        BuilderName = 'S3 Engineer Assist Build Nuke Missile',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 850,
        InstanceCount = 6,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.03 }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, 'NUKE STRUCTURE'}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 500,
                AssisteeCategory = 'STRUCTURE NUKE',
                PermanentAssist = false,
                Time = 75,
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
                Time = 75,
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
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},
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
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},
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

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},

            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
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

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.02 }},

            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
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
        InstanceCount = 4,
        BuilderConditions = {
            { EBC, 'LessThanEconStorageRatioSwarm', { 1.0, 2.0}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm Reclaim Resource - Additional',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 595,
        InstanceCount = 4,
        BuilderConditions = {
            { EBC, 'LessThanEconStorageRatioSwarm', { 0.6, 1}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },

    --[[ Builder { BuilderName = 'S1 Reclaim Resource 3',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH2}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.9, 2}}, 

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

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.9, 2}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType',  1, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any', 
    }, ]]--
}

