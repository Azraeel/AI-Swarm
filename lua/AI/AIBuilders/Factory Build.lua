local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapFactory = 0.024 -- 2.4% of all units can be factories (STRUCTURE * FACTORY)
local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                             Build Factories Land/Air/Sea/Quantumgate                                   == --
-- ===================================================-======================================================== --
-- ================ --
--    TECH 1 2nd    --
-- ================ --
BuilderGroup { BuilderGroupName = 'Swarm ACU Initial Opener',
    BuildersType = 'EngineerBuilder',    
    Builder { BuilderName = 'Swarm ACU Initial Opener',
    	PlatoonAddBehaviors = {'CommanderBehavior',},
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 5000,
        BuilderConditions = {
            { IBC, 'NotPreBuilt', {}},
        },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
            	BaseTemplateFile = '/mods/AI-Swarm/lua/AI/AIBuilders/ACUBaseTemplate.lua',
                BaseTemplate = 'ACUBaseTemplate',
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                    'T1EnergyProduction',
                    'T1Resource',
                    'T1Resource',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1LandFactory',
                    'T1EnergyProduction',
                    'T1AirFactory',
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Factory Builder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Factory Builder Land',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 550,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.40}}, 

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = true,
            Construction = {
            	AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Air',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 545,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.40}},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.AIR }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                AdjacencyCategory = categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}
-- ============================ --
--    Builder for Expansions    --
-- ============================ --
BuilderGroup { BuilderGroupName = 'Swarm Factory Builders Expansions',
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U1 Land Factory Expansions',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 450,
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STRUCTURE * categories.FACTORY * categories.LAND}},
 
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.50 } },             -- Ratio from 0 to 1. (1=100%)

            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder { BuilderName = 'U1 Air Factory Expansions',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 450,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.FACTORY * categories.AIR}},

            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.50 } },             

            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                AdjacencyCategory = categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                             Upgrade Factories Land/Air/Sea                                             == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Factory Upgrader Rush',                      -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    --------------------
    -- LAND Factories --
    --------------------
    Builder { BuilderName = 'U1 L UP HQ 1->2 1st Enemy',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.FACTORY * (categories.TECH2 + categories.TECH3) } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U1 L UP HQ 1->2 1st F>4',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U1 L UP HQ 1->2 1st E>1000',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { EBC, 'GreaterThanEconIncome',  { 0.1, 100.0 }},
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 L UP HQ 2->3 1st Enemy',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.FACTORY * categories.TECH3 } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 L UP HQ 2->3 1st Force',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*15 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * ( categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL ) }},
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.10 } },             -- Ratio from 0 to 1. (1=100%)
            { EBC, 'GreaterThanEconIncome', { 1.7, 16.7 }},                    -- Base income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 L UP HQ 2->3 Late',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 15000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH3 } }, -- minimum 2 Tech3 factories
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH2 }},
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        },
        BuilderType = 'Any',
    },
-- LAND Support Factories
    Builder { BuilderName = 'U1 L UP SUPORT/HQ 1->2 Always',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9501', 'zab9501', 'zrb9501', 'zsb9501', 'znb9501' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * ( categories.TECH2 + categories.TECH3 ) - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
-- Builder for 5 factions
    Builder { BuilderName = 'U2 L UP SUPORT 2->3 Always 1',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade1',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } }, -- relative income
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 L UP SUPORT 2->3 Always 2',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade2',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 L UP SUPORT 2->3 Always 3',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade3',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 L UP SUPORT 2->3 Always 4',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade4',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 L UP SUPORT 2->3 Always 5',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade5',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY  - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SUPPORTFACTORY * categories.TECH2 * categories.LAND - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    -------------------
    -- AIR Factories --
    -------------------
    Builder { BuilderName = 'U1 A UP HQ 1->2 1st Force',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 A UP HQ 2->3 1st Force',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 A UP HQ 2->3 Late',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 } }, -- minimum 2 Tech3 factories
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
-- AIR Support Factories
    Builder { BuilderName = 'U1 A UP SUPORT/HQ 1->2 Always',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9502', 'zab9502', 'zrb9502', 'zsb9502', 'znb9502' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR * ( categories.TECH2 + categories.TECH3 ) - categories.SUPPORTFACTORY } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
-- Builder for 5 factions
    Builder { BuilderName = 'U2 A UP SUPORT 2->3 Always 1',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade1',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 4, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 A UP SUPORT 2->3 Always 2',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade2',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 4, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 A UP SUPORT 2->3 Always 3',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade3',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 4, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 A UP SUPORT 2->3 Always 4',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade4',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 4, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'U2 A UP SUPORT 2->3 Always 5',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade5',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, -- overides Upgrade blueprint for all 5 factions. Used for support factories
        },
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY  - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SUPPORTFACTORY * categories.TECH2 * categories.AIR - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF }},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.50 } },
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },

}
-- ===================================================-======================================================== --
-- ==                                        Build Quantum Gate                                              == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Gate Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U-T3 Gate Cap',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 17400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Gate' } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { 0.02 , '<', categories.STRUCTURE * categories.GATE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3QuantumGate',
                },
            }
        }
    },
    Builder { BuilderName = 'U-T3 Gate Para',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 17400,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3 }},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.GATE } },
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { 0.02 , '<', categories.STRUCTURE * categories.GATE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3QuantumGate',
                },
            }
        }
    },
}
-- ===================================================-======================================================== --
-- ==                                   Build T2 Air Staging Platform                                        == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Air Staging Platform Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U-T2 Air Staging 1st',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 15300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder { BuilderName = 'U-T2 Air Staging',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 15300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusEnemy', { 0.05, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM, '<', categories.MOBILE * categories.AIR } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.75, 0.99}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCap', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
} 