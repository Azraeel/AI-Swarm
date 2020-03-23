local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapMass = 0.25 -- 25% of all units can be mass extractors (STRUCTURE * MASSEXTRACTION)
local MaxCapStructure = 0.25                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ============================================================================================================ --
-- ==                                     Build MassExtractors / Creators                                    == --
-- ============================================================================================================ --
BuilderGroup {
    -- Build MassExtractors / Creators 
    BuilderGroupName = 'U1 MassBuilders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Mass 30',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 600,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 30, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 60',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 585,
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 60, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 1000 6+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 575,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 1},
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENGINEER * categories.TECH1 }},
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 1000 8+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 565,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 1},
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 7, categories.ENGINEER * categories.TECH1 }},
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Mass 1000 10+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 555,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 1},
        InstanceCount = 2,
        BuilderConditions = {
            -- When do we want to build this ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 9, categories.ENGINEER * categories.TECH1 }},
            { UCBC, 'HasNotParagon', {} },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'UC Resource RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 2*60 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
            -- Do we need additional conditions to build it ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 60, -5000, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRings, threatType, maxNum
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'U1 Resource RECOVER',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 150,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 2*60 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
            -- Do we need additional conditions to build it ?
            { MABC, 'CanBuildOnMass', { 'LocationType', 60, -5000, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRings, threatType, maxNum
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder {
        BuilderName = 'U3 Mass Fab',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1175,
        BuilderConditions = {
            { UCBC, 'HasNotParagon', {} },

            { EBC, 'GreaterThanEconTrend', { 0, 10000 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 1.00}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 4,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.MASSFABRICATION,
                maxUnits = 1,
                maxRadius = 15,
                BuildClose = true,
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },

    Builder {
        BuilderName = 'U1 Reclaim T1+T2 Massfabrikation',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 145,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 20, categories.STRUCTURE * categories.MASSEXTRACTION }},
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.STRUCTURE * categories.MASSFABRICATION * (categories.TECH1 + categories.TECH2) }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.MASSFABRICATION * (categories.TECH1 + categories.TECH2)},
        },
        BuilderType = 'Any',
    },
}
-- ============================================================================================================ --
-- ==                                         Upgrade MassExtractors                                         == --
-- ============================================================================================================ --
BuilderGroup {
    -- Upgrade MassExtractors from Tech 1 to 2 AND from Tech 2 to 3
    BuilderGroupName = 'U123 ExtractorUpgrades',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Extractor upgrade >40 mass',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
        	{ MIBC, 'GreaterThanGameTime', { 480 } },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 4.0, -0.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractor upgrade >4 factories',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
        	{ MIBC, 'GreaterThanGameTime', { 600 } },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY} },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Extractor upgrade > 6 minutes',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
        	{ MIBC, 'GreaterThanGameTime', { 360 } },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
}
BuilderGroup {
    -- Upgrade MassExtractors from Tech 1 to 2 AND from Tech 2 to 3
    BuilderGroupName = 'U123 ExtractorUpgrades SWARM',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'U1S Extractor upgrade >40 mass',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
        	{ MIBC, 'GreaterThanGameTime', { 600 } },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 4.0, -0.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U1S Extractor enemy > T2',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
        	{ MIBC, 'GreaterThanGameTime', { 600 } },
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MASSEXTRACTION} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3) } },            -- Don't build it if...
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncome',  { 4.0, -0.0}}, -- Absolut Base income
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAI',
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                     Build MassStorage/Adjacency                                        == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'U1 MassStorage Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Mass Adjacency Engineer',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 535,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH2}},
            -- When do we want to build this ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3), 100, 'ueb1106' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 10 } },

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 4,  categories.STRUCTURE * categories.MASSSTORAGE }},
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3),
                AdjacencyDistance = 175,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'Swarm Mass Adjacency Engineer - Outter Mexes',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH2}},
            -- When do we want to build this ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3), 100, 'ueb1106' } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 25 } },

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 4,  categories.STRUCTURE * categories.MASSSTORAGE }},
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3),
                AdjacencyDistance = 350,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
}
