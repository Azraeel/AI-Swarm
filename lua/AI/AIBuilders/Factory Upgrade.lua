local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapFactory = 0.024 
local MaxCapStructure = 0.12                 

-- Will Clean This File up when I have time
-- Build Conditions are all out of wack and do tons of unneeded checks.
-- Performance Heavy this LUA is.

-- ===================================================-======================================================== --
-- ==                             Upgrade Factories Land/Air/Sea                                             == --
-- ===================================================-======================================================== --

BuilderGroup { BuilderGroupName = 'Swarm Factory Upgrader Rush',                     
    BuildersType = 'PlatoonFormBuilder',

    Builder { BuilderName = 'S1 L UP HQ 1->2 1st Eco',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.LAND * categories.FACTORY * categories.STRUCTURE } },
         
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.RESEARCH * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
        
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.05 }},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 L UP HQ 2->3 1st Eco',
        PlatoonTemplate = 'T2LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.LAND * categories.FACTORY * categories.STRUCTURE * categories.SUPPORTFACTORY * categories.TECH2} },
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.RESEARCH * categories.TECH3 - categories.SUPPORTFACTORY } },
           
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.2, 11.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 * categories.RESEARCH }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 L UP SUPORT/HQ 1->2 Always',
        PlatoonTemplate = 'T1LandFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9501', 'zab9501', 'zrb9501', 'zsb9501', 'znb9501' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.RESEARCH * ( categories.TECH2 + categories.TECH3 ) - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.4, 3.3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.05 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 L UP SUPORT 2->3 Always 1',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade1',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
           
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.8, 6.8 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 L UP SUPORT 2->3 Always 2',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade2',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
          
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.8, 6.8 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 L UP SUPORT 2->3 Always 3',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade3',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
        
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.8, 6.8 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 L UP SUPORT 2->3 Always 4',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade4',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY} },
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.SUPPORTFACTORY * categories.LAND * categories.TECH2 }},
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.8, 6.8 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 L UP SUPORT 2->3 Always 5',
        PlatoonTemplate = 'T2LandSupFactoryUpgrade5',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9601', 'zab9601', 'zrb9601', 'zsb9601', 'znb9601' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 - categories.SUPPORTFACTORY  - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF } },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SUPPORTFACTORY * categories.TECH2 * categories.LAND - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF }},
         
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.8, 6.8 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    -------------------
    -- AIR Factories --
    -------------------
    Builder { BuilderName = 'S1 A UP HQ 1->2 1st Eco',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.AIR * categories.FACTORY * categories.STRUCTURE } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.RESEARCH * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
           
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
          
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.7, 16.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.07 }},
          
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.AIR }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 A UP HQ 2->3 1st Eco',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.AIR * categories.FACTORY * categories.STRUCTURE * categories.TECH2 * categories.SUPPORTFACTORY } },
            
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.RESEARCH * categories.TECH3 - categories.SUPPORTFACTORY } },
      
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
         
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.2, 31.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 * categories.RESEARCH }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 A UP SUPORT/HQ 1->2 Always',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9502', 'zab9502', 'zrb9502', 'zsb9502', 'znb9502' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.RESEARCH * ( categories.TECH2 + categories.TECH3 ) - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.4, 8.6 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.07 }},
      
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 A UP SUPORT 2->3 Always 1',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade1',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
           
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
           
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 26.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},
         
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 A UP SUPORT 2->3 Always 2',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade2',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
           
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 26.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},
         
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 A UP SUPORT 2->3 Always 3',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade3',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
           
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
           
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 26.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},
         
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 A UP SUPORT 2->3 Always 4',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade4',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY} },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.AIR * categories.SUPPORTFACTORY * categories.TECH2 }},
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 26.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder { BuilderName = 'S2 A UP SUPORT 2->3 Always 5',
        PlatoonTemplate = 'T2AirSupFactoryUpgrade5',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9602', 'zab9602', 'zrb9602', 'zsb9602', 'znb9602' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
        
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY  - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF } },
           
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SUPPORTFACTORY * categories.TECH2 * categories.AIR - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF }},
           
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 26.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    }, 

}

BuilderGroup {
    BuilderGroupName = 'Swarm Factory Upgrader Naval',                      
    BuildersType = 'PlatoonFormBuilder',

    Builder {
        BuilderName = 'S1 N UP HQ 1->2 1st Eco',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
           
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 2, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.RESEARCH * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
           
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.9, 4.9 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.06 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },


    Builder {
        BuilderName = 'S2 N UP HQ 2->3 1st Eco',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH2 * categories.SUPPORTFACTORY } },
       
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.RESEARCH * categories.TECH3 - categories.SUPPORTFACTORY } },
         
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 6.0, 28.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 * categories.RESEARCH - categories.SUPPORTFACTORY }},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 N UP SUPORT/HQ 1->2 Always',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9503', 'zab9503', 'zrb9503', 'zsb9503', 'znb9503' },
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
 
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.RESEARCH * ( categories.TECH2 + categories.TECH3 ) - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 0.9, 4.9 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.06 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S2 N UP SUPORT 2->3 Always 1',
        PlatoonTemplate = 'T2SeaSupFactoryUpgrade1',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9603', 'zab9603', 'zrb9603', 'zsb9603', 'znb9603' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 - categories.SUPPORTFACTORY} },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.UEF * categories.NAVAL * categories.SUPPORTFACTORY * categories.TECH2 }},
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 6.0, 28.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 N UP SUPORT 2->3 Always 2',
        PlatoonTemplate = 'T2SeaSupFactoryUpgrade2',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9603', 'zab9603', 'zrb9603', 'zsb9603', 'znb9603' },
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
           
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 - categories.SUPPORTFACTORY} },
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AEON * categories.NAVAL * categories.SUPPORTFACTORY * categories.TECH2 }},
      
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 6.0, 28.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},
          
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 N UP SUPORT 2->3 Always 3',
        PlatoonTemplate = 'T2SeaSupFactoryUpgrade3',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9603', 'zab9603', 'zrb9603', 'zsb9603', 'znb9603' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
         
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 - categories.SUPPORTFACTORY} },
        
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.CYBRAN * categories.NAVAL * categories.SUPPORTFACTORY * categories.TECH2 }},
  
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 6.0, 28.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 N UP SUPORT 2->3 Always 4',
        PlatoonTemplate = 'T2SeaSupFactoryUpgrade4',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9603', 'zab9603', 'zrb9603', 'zsb9603', 'znb9603' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 - categories.SUPPORTFACTORY} },
        
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SERAPHIM * categories.NAVAL * categories.SUPPORTFACTORY * categories.TECH2 }},
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 6.0, 28.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 N UP SUPORT 2->3 Always 5',
        PlatoonTemplate = 'T2SeaSupFactoryUpgrade5',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderData = {
            OverideUpgradeBlueprint = { 'zeb9603', 'zab9603', 'zrb9603', 'zsb9603', 'znb9603' }, 
        },
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
       
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 - categories.SUPPORTFACTORY  - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF } },
        
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SUPPORTFACTORY * categories.TECH2 * categories.NAVAL - categories.SERAPHIM - categories.CYBRAN - categories.AEON - categories.UEF }},
      
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 6.0, 28.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.04, 1.1 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    }, 
} 