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
    Builder { BuilderName = 'U1 Assist 1st T2 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 200,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 14, 100 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH2'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U1 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 300,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 30, 400 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U2 Assist 1st T3 Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 350,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 34, 500 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Factory',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE LAND FACTORY TECH3'},        -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U2 Assist Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 300,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 25, 350 } },
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
                Time = 0,
            },
        }
    },
    -- Permanent assist
    Builder { BuilderName = 'T1 Assist Factory unit build',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 450,
        InstanceCount = 6,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 15, 200 } },

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
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'T2 Assist Factory unit build',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 450,
        InstanceCount = 6,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 23, 260 } },

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
                Time = 0,
            },
        }
    },

    -- ============ --
    --    ENERGY    --
    -- ============ --
    Builder { BuilderName = 'UC Assist Energy',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 16300,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 20, 150 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U1 Assist Energy Turbo',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 550,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 22, 190 } },
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
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U2 Assist Energy Turbo',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 580,
        InstanceCount = 15,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 10, 100 } },
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
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U3 Assist Energy Turbo',
        PlatoonTemplate = 'T3EngineerAssistNoSUB',
        Priority = 600,
        InstanceCount = 20,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 20, 200 } },
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
                Time = 0,
            },
        }
    },
    -- ============ --
    --    Paragon   --
    -- ============ --
    Builder { BuilderName = 'U1 Assist PARA',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 1000,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 500, 25000 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 300,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U2 Assist PARA',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1010,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 500, 25000 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 300,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U3 Assist PARA',
        PlatoonTemplate = 'T3EngineerAssistNoSUB',
        Priority = 1015,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 500, 25000 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 300,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},               -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    -- =================== --
    --    Experimentals    --
    -- =================== --
    Builder { BuilderName = 'U1 Assist Experimental',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 1000,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 85, 5000 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 400,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL'},                        -- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U2 Assist Experimental',
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 1010,
        InstanceCount = 50,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 90, 5000 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 400,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U3 Assist Experimental',
        PlatoonTemplate = 'T3EngineerAssistNoSUB',
        Priority = 1100,
        InstanceCount = 15,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 95, 5000 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 400,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },
    Builder { BuilderName = 'U3 Assist Experimental',
        PlatoonTemplate = 'T3EngineerAssistSUB',
        Priority = 1200,
        InstanceCount = 30,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 95, 5000 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 400,
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC, EXPERIMENTAL SHIELD, EXPERIMENTAL MOBILE'},-- Unitcategories must be type string
                AssistUntilFinished = true,
                Time = 0,
            },
        }
    },

    -- ============== --
    --    Shields     --
    -- ============== --
    Builder { BuilderName = 'U1 Assist Shield',
        PlatoonTemplate = 'EngineerAssist',
        Priority = 310,
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconIncome', { 8, 40 } },
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
                Time = 0,
            },
        }
    },
    -- =============== --
    --    Finisher     --
    -- =============== --
    Builder { BuilderName = 'U1 Finisher',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'FinisherAI',
        Priority = 250,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnfinishedUnitsAtLocation', { 'LocationType' }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 Finisher',
        PlatoonTemplate = 'T2EngineerBuilder',
        PlatoonAIPlan = 'FinisherAI',
        Priority = 250,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnfinishedUnitsAtLocation', { 'LocationType' }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99}}, -- Ratio from 0 to 1. (1=100%)
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
    Builder { BuilderName = 'U1 Engineer Repair',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 5,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH1 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99}}, -- Ratio from 0 to 1. (1=100%)
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 Engineer Repair',
        PlatoonTemplate = 'T2EngineerBuilder',
        PlatoonAIPlan = 'RepairAI',
        Priority = 60,
        InstanceCount = 1,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'DamagedStructuresInArea', { 'LocationType', }},
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.ENGINEER * categories.TECH2 } },
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.99}}, -- Ratio from 0 to 1. (1=100%)
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
    Builder { BuilderName = 'U1 Reclaim RECOVER mass',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 19600,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U1 Reclaim RECOVER energy',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 19500,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.COMMAND }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U1 Reclaim Resource 1',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 18000,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.MOBILE * categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U1 Reclaim Resource 2',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 17400,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 9, categories.MOBILE * categories.ENGINEER}},
            -- Do we need additional conditions to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U1 Reclaim Resource 3',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 17400,
        InstanceCount = 4,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH2}},
            -- Do we need additional conditions to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U1 Reclaim Resource 4',
        PlatoonTemplate = 'U1Reclaim',
        Priority = 17400,
        InstanceCount = 6,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER * categories.TECH3}},
            -- Do we need additional conditions to build it ?
            { EBC, 'LessThanEconStorageRatio', { 0.80, 2.00}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
}

