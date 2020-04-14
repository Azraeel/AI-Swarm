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
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.40 } },

            { EBC, 'GreaterThanEconIncome', { 1.4, 20 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'S1 Assist 1st T2 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 150,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 1.4, 20 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH2'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S1 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 3, 40 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 210,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 3.4, 50 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 250,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 2.5, 30 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE FACTORY'},                   -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    -- Permanent assist
    Builder { BuilderName = 'T1 Assist Factory unit build',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 450,
        InstanceCount = 6,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 1.5, 20 } },

            { UCBC, 'GreaterThanGameTimeSeconds', { 60*15 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE FACTORY'},                   -- Unitcategories must be type string
                AssistClosestUnit = false,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'T2 Assist Factory unit build',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 450,
        InstanceCount = 6,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 1.5, 30 } },

            { UCBC, 'GreaterThanGameTimeSeconds', { 60*15 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE FACTORY'},                   -- Unitcategories must be type string
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
            },
        }
    },

    -- ============ --
    --    ENERGY    --
    -- ============ --
    Builder { BuilderName = 'SC Assist Energy',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 16300,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 2.0, 20 } },
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
    Builder { BuilderName = 'S1 Assist Energy Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 570,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 2, 20 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist Energy Turbo',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 605,
        InstanceCount = 15,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 2, 20 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S3 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 650,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 4, 50 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S1 Assist HYDROCARBON Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 565,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'HYDROCARBON'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    -- ============ --
    --    Paragon   --
    -- ============ --
    Builder { BuilderName = 'S1 Assist PARA',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 1000,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 50, 900 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 300,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist PARA',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1010,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 50, 900 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 300,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S3 Assist PARA',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 1015,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 50, 900 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 300,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    -- =================== --
    --    Experimentals    --
    -- =================== --
    Builder { BuilderName = 'S1 Assist Experimental',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 1500,
        InstanceCount = 100,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL'},                        -- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S2 Assist Experimental',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1500,
        InstanceCount = 100,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S3 Assist Experimental',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 1500,
        InstanceCount = 100,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },
    Builder { BuilderName = 'S3 Assist Experimental2',
        PlatoonTemplate = 'T3EngineerAssistSUB',
        Priority = 1500,
        InstanceCount = 100,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    -- ============== --
    --    STRATEGIC   --
    -- ============== --

    Builder { BuilderName = 'Z3 Assist SMD',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 4.5, 50 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'ANTIMISSILE SILO'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'Z3 Assist SMD2',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'ANTIMISSILE SILO'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'Z4 Assist SML',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 4.5, 100 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC NUKE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'Z4 Assist SML2',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC NUKE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'Z4 Assist SML3',
        PlatoonTemplate = 'T3EngineerAssistSUB',
        Priority = 1500,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC NUKE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'Z5 Assist T3-T4 Artillery',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1400,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC ARTILLERY'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'Z5 Assist T3-T4 Artillery2',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 1400,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC ARTILLERY'},-- Unitcategories must be type string
            },
        }
    },

    Builder { BuilderName = 'Z5 Assist T3-T4 Artillery3',
        PlatoonTemplate = 'T3EngineerAssistSUB',
        Priority = 1400,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 700,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'STRATEGIC ARTILLERY'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    Builder {
        BuilderName = 'S3 Engineer Assist Build Nuke Missile',
        PlatoonTemplate = 'T3EngineerAssistnoSUB',
        Priority = 850,
        InstanceCount = 14,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, 'NUKE STRUCTURE'}},

            { EBC, 'GreaterThanEconIncome', { 8.5, 200 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'NonUnitBuildingStructure',
                AssistRange = 500,
                AssisteeCategory = 'STRUCTURE NUKE',
                AssistUntilFinished = true,
            },
        }
    },


    -- ============== --
    --    Shields     --
    -- ============== --
    Builder { BuilderName = 'S1 Assist Shield',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 310,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { .8, 4 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD'},                    -- Unitcategories must be type string
                AssisteeType = 'Structure',
                AssistRange = 250,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
            },
        }
    },

    Builder { BuilderName = 'S1 Assist Shield2',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 350,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncome', { .8, 4 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD'},                    -- Unitcategories must be type string
                AssisteeType = 'Structure',
                AssistRange = 250,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                AssistUntilFinished = true,
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
            -- When do we want to build this ?
            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'UnfinishedUnitsAtLocationSwarm', { 'LocationType' }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50}}, -- Ratio from 0 to 1. (1=100%)
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
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50}}, -- Ratio from 0 to 1. (1=100%)
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
    Builder { BuilderName = 'S1 Reclaim RECOVER mass',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
            { EBC, 'LessThanEconStorageRatio', { 0.9, 1}}, -- Ratio from 0 to 1. (1=100%)
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S1 Reclaim RECOVER energy',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION } },
            { EBC, 'LessThanEconStorageRatio', { 0.9, 0.9}}, -- Ratio from 0 to 1. (1=100%)
            -- Have we the eco to build it ?
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.ENGINEER}},
            { EBC, 'LessThanEconStorageRatio', { 0.9, 1}}, -- Ratio from 0 to 1. (1=100%)
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 9, categories.MOBILE * categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.9, 1}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
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
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH2}},
            -- Do we need additional conditions to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.9, 1}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S1 Reclaim Resource 4',
        PlatoonTemplate = 'S1Reclaim',
        Priority = 350,
        InstanceCount = 6,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH3}},
            -- Do we need additional conditions to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.9, 1}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}

