local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 1.0 }}, 
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},
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
            { EBC, 'LessThanEnergyTrendSwarm', { 0.0 } },     

            { EBC, 'GreaterThanMassStorageCurrentSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 0.0 }},
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
            { EBC, 'LessThanEnergyTrendSwarm', { 0.0 } },     

            { EBC, 'GreaterThanMassStorageCurrentSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 0.0 }},
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
            { EBC, 'LessThanEnergyTrendSwarm', { 0.0 } },     

            { EBC, 'GreaterThanMassStorageCurrentSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 0.0 }},
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
            { EBC, 'LessThanEnergyTrendSwarm', { 0.0 } },     

            { EBC, 'GreaterThanMassStorageCurrentSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 0.0 }},
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
            { EBC, 'LessThanEnergyTrendSwarm', { 0.0 } },  

            { EBC, 'GreaterThanMassStorageCurrentSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 0.0 }},
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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
                BeingBuiltCategories = {categories.MASSPRODUCTION + categories.MASSEXTRACTION - categories.TECH1},-- Unitcategories must be type string
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
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {categories.TECH1 + categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL},               -- Unitcategories must be type string
                AssisteeType = categories.STRUCTURE,
                --AssistUntilFinished = true,
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
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.07, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                --AssistUntilFinished = true,
                AssistClosestUnit = true,  
                AssistRange = 200,
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.01 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 200,
                --AssistUntilFinished = true,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {categories.EXPERIMENTAL * categories.MOBILE},                        -- Unitcategories must be type string
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 700,
                AssistUntilFinished = true,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {categories.FACTORY * categories.GATE * categories.TECH3},                                -- Unitcategories must be type string
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
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 100,
                --AssistUntilFinished = true,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'All Assist SML',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 100,
                --AssistUntilFinished = true,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.TECH3},-- Unitcategories must be type string
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'All Assist T3-T4 Artillery',
        PlatoonTemplate = 'EngineerAssistALLTECH',
        Priority = 1400,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 150,
                --AssistUntilFinished = true,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {categories.STRUCTURE * categories.ARTILLERY * categories.STRATEGIC},-- Unitcategories must be type string
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
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = categories.STRUCTURE,
                AssistRange = 150,
                AssistUntilFinished = true,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
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
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

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
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

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
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

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
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

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
BuilderGroup { BuilderGroupName = 'Swarm Engineer Reclaim Main',                                -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',

    Builder { BuilderName = 'Swarm Reclaim Mass - Small Mass',
        PlatoonTemplate = 'Swarm T1Reclaim',
        Priority = 600,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.9, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 10
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm Reclaim Resource - Medium Mass',
        PlatoonTemplate = 'Swarm T1Reclaim',
        Priority = 600,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.8, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 20
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm Reclaim Resource - Big Mass',
        PlatoonTemplate = 'Swarm T1Reclaim',
        Priority = 600,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType',  1, categories.ENGINEER * categories.TECH1 } },

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.7, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 40
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm Reclaim Resource - Huge Mass',
        PlatoonTemplate = 'Swarm T1Reclaim',
        Priority = 600,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType',  2, categories.ENGINEER * categories.TECH1 } },

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.6, 1.0}},
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 80
        },
        BuilderType = 'Any', 
    }, 
}

BuilderGroup { BuilderGroupName = 'Swarm Engineer Reclaim Expansion',                                -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',

    Builder { BuilderName = 'Swarm Reclaim Mass Expansion - Small Mass',
        PlatoonTemplate = 'Swarm T1Reclaim',
        Priority = 600,
        InstanceCount = 6,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.9, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 10
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm Reclaim Mass Expansion - Medium Mass',
        PlatoonTemplate = 'Swarm T1Reclaim',
        Priority = 600,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.ENGINEER * categories.TECH1 }},

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.9, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 20
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm T2 Reclaim Mass Expansion - Small Mass',
        PlatoonTemplate = 'Swarm T2Reclaim',
        Priority = 750,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD }},

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.8, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 40
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm T2 Reclaim Mass Expansion - Big Mass',
        PlatoonTemplate = 'Swarm T2Reclaim',
        Priority = 750,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH2 - categories.STATIONASSISTPOD }},

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.8, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 80
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'Swarm T3 Reclaim Mass Expansion - Small Mass',
        PlatoonTemplate = 'Swarm T3Reclaim',
        Priority = 850,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH3 - categories.STATIONASSISTPOD }},

            { MIBC, 'CheckIfReclaimEnabledSwarm', {}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.6, 1.0}}, 
        },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 80,
            MinimumReclaim = 120
        },
        BuilderType = 'Any',
    },
}
