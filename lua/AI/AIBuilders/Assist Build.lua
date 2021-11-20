local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                             Assistees                                                  == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Engineer Assistees',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    -- ================== --
    --  Factories Assist  --
    -- ================== --

    Builder {
        BuilderName = 'Engineer Assist Factory',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1000,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.FACTORY,
                AssistRange = 120,
                AssistClosestUnit = true, 
                AssistUntilFinished = true,
                BeingBuiltCategories = {categories.LAND * categories.MOBILE},        -- Unitcategories must be type string
                Time = 40,
            },
        }
    },

    -- ===================== --
    --   Factories Upgrade   --
    -- ===================== --

    Builder { BuilderName = 'S1 Assist 1st T2 Factory Upgrade',
        PlatoonTemplate = 'T1EngineerAssistSwarm',
        Priority = 150,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.FACTORY,
                AssistRange = 200,
                AssistClosestUnit = true, 
                AssistUntilFinished = false,
                BeingBuiltCategories = {categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH2},        -- Unitcategories must be type string
                Time = 75,
            },
        }
    },
    Builder { BuilderName = 'S1 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'T1EngineerAssistSwarm',
        Priority = 200,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.FACTORY,
                AssistRange = 200,
                AssistClosestUnit = true, 
                AssistUntilFinished = false,
                BeingBuiltCategories = {categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH3},        -- Unitcategories must be type string
                Time = 75,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssistSwarm',
        Priority = 210,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.FACTORY,
                AssistRange = 200,
                AssistClosestUnit = true, 
                AssistUntilFinished = false,
                BeingBuiltCategories = {categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH3},        -- Unitcategories must be type string
                Time = 75,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssistSwarm',
        Priority = 250,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.FACTORY,
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = false,
                BeingBuiltCategories = {categories.STRUCTURE * categories.FACTORY},                   -- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    -- ============ --
    --    ENERGY    --
    -- ============ --
    Builder { BuilderName = 'S1 Assist Energy Turbo',
        PlatoonTemplate = 'T1EngineerAssistSwarm',
        Priority = 590,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 0.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                BeingBuiltCategories = {categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH1 + categories.TECH2 + categories.TECH3)},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'S2 Assist Energy Turbo',
        PlatoonTemplate = 'T2EngineerAssistSwarm',
        Priority = 605,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 0.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                BeingBuiltCategories = {categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3)},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'S3 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 650,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 0.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                BeingBuiltCategories = {categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3)},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'S4 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistSUB',
        Priority = 650,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'LessThanEnergyTrend', { 0.0 } },     

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 0.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                BeingBuiltCategories = {categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3)},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'S1 Assist HYDROCARBON Turbo',
        PlatoonTemplate = 'T1EngineerAssistSwarm',
        Priority = 650,
        InstanceCount = 1,
        BuilderConditions = {
            { EBC, 'LessThanEnergyTrend', { 0.0 } },  

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 0}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 0.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                BeingBuiltCategories = {categories.HYDROCARBON},-- Unitcategories must be type string
            },
        }
    },

    -- ================= --
    --    Mass Assist    --
    -- ================= --

    Builder { BuilderName = 'S1 Assist Mass Upgrade',
        PlatoonTemplate = 'T1EngineerAssistSwarm',
        Priority = 590,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.MASSPRODUCTION - categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
                BeingBuiltCategories = {categories.MASSPRODUCTION - categories.TECH1},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    -- =================== --
    --    General Assist   --
    -- =================== --
    Builder {
        BuilderName = 'All Engineer Assist',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 950,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {categories.TECH1 + categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL},               -- Unitcategories must be type string
                PermanentAssist = false,
                AssisteeType = categories.STRUCTURE,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 40,
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

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 300,
                PermanentAssist = false,
                BeingBuiltCategories = {categories.EXPERIMENTAL * categories.ECONOMIC},               -- Unitcategories must be type string
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
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 700,
                PermanentAssist = false,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {categories.EXPERIMENTAL},                        -- Unitcategories must be type string
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
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.01, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 700,
                PermanentAssist = false,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {categories.FACTORY * categories.GATE},                                -- Unitcategories must be type string
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
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.04 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                PermanentAssist = false,
                BeingBuiltCategories = {categories.ANTIMISSILE * categories.SILO},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'All Assist SML',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.03, 1.04 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                PermanentAssist = false,
                BeingBuiltCategories = {categories.STRATEGIC * categories.NUKE},-- Unitcategories must be type string
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

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, 'NUKE STRUCTURE'}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.FACTORY,
                AssistRange = 500,
                PermanentAssist = false,
                AssisteeCategory = {categories.STRATEGIC * categories.NUKE},
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'All Assist T3-T4 Artillery',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1400,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.05 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                PermanentAssist = false,
                BeingBuiltCategories = {categories.STRATEGIC * categories.ARTILLERY},-- Unitcategories must be type string
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

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 250,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                PermanentAssist = false,
                BeingBuiltCategories = {categories.STRUCTURE * categories.SHIELD},                    -- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    -- =============== --
    --    Finisher     --
    -- =============== --
    Builder { BuilderName = 'S1 Finisher',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'FinisherAISwarm',
        Priority = 750,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 Finisher',
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        PlatoonAIPlan = 'FinisherAISwarm',
        Priority = 760,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

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
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

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
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 1,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

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
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.8, 2.0}},

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
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

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

