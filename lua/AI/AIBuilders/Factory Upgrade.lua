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

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.LAND * categories.FACTORY * categories.STRUCTURE } },
         
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.RESEARCH * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
        
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},
            
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
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.RESEARCH * categories.TECH3 - categories.SUPPORTFACTORY } },
           
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},
            
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

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},

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

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},

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

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},

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

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},
            
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

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},

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

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 8.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.02 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    -------------------
    -- AIR Factories --
    -------------------
    --[[ Builder { BuilderName = 'S1 A UP HQ 1->2 1st Force',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.30 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.05 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.AIR }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 A UP HQ 1->2 1st Eco',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { MIBC, 'GreaterThanGameTime', { 420 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
           
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
          
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.30 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.05 }},
          
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.AIR }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 A UP HQ 1->2 1st Enemy',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.STRUCTURE * categories.FACTORY * (categories.TECH2 + categories.TECH3) } },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.MOBILE * categories.AIR * (categories.TECH2 + categories.TECH3) } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.30 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.05 }},
           
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.AIR }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S1 A UP HQ 1->2 1st Time',
        PlatoonTemplate = 'T1AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
            
            { MIBC, 'GreaterThanGameTime', { 840 } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
           
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.30 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.05 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.AIR }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 A UP HQ 2->3 1st Force',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY } },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
           
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},
        
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 * categories.RESEARCH }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 A UP HQ 2->3 1st Eco',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { MIBC, 'GreaterThanGameTime', { 1020 } },
            
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY } },
      
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
         
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 * categories.RESEARCH }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 A UP HQ 2->3 1st Enemy',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
          
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY } },
         
            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.STRUCTURE * categories.FACTORY * categories.TECH3 } },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.MOBILE * categories.AIR * categories.TECH3 } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
       
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},
       
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 * categories.RESEARCH }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 A UP HQ 2->3 1st Time',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15400,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 - categories.SUPPORTFACTORY } },
           
            { MIBC, 'GreaterThanGameTime', { 1680 } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
           
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},
           
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 * categories.RESEARCH }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },

    Builder { BuilderName = 'S2 A UP HQ 2->3 Late',
        PlatoonTemplate = 'T2AirFactoryUpgrade',
        Priority = 15000,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
           
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH3 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 1.0, 3.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},
          
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
        
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.AIR * ( categories.TECH2 + categories.TECH3 ) - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.25 }},
      
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
           
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.25 }},
         
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
            
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.25 }},
         
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
           
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.25 }},
         
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
            
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.25 }},

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
           
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.25 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    }, ]]--

}

BuilderGroup {
    BuilderGroupName = 'Swarm Factory Upgrader Naval',                      
    BuildersType = 'PlatoonFormBuilder',

    Builder {
        BuilderName = 'S1 N UP HQ 1->2 1st Force',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
           
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH2 } },
           
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 N UP HQ 1->2 1st Enemy',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.STRUCTURE * categories.FACTORY * (categories.TECH2 + categories.TECH3) } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 N UP HQ 1->2 1st Time',
        PlatoonTemplate = 'T1SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},

            { MIBC, 'GreaterThanGameTime', { 840 } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S2 N UP HQ 2->3 1st Force',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
       
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 - categories.SUPPORTFACTORY } },
         
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH3 } },
         
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 N UP HQ 2->3 1st Enemy',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.STRUCTURE * categories.FACTORY * categories.TECH3 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S1 N UP HQ 2->3 1st Time',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 15400,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * (categories.TECH2 + categories.TECH3) - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},

            { MIBC, 'GreaterThanGameTime', { 1560 } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S2 N UP HQ 2->3 Late',
        PlatoonTemplate = 'T2SeaFactoryUpgrade',
        Priority = 15000,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'FactoryUpgrade', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'FactoryUpgrade' }},
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.01 } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH2 }},
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
 
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * ( categories.TECH2 + categories.TECH3 ) - categories.SUPPORTFACTORY } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.10, 0.50 } },

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
            
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.15, 0.50 } },

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
      
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.15, 0.50 } },
          
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
  
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.15, 0.50 } },

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
            
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.15, 0.50 } },

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
      
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.15, 0.50 } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
        },
        BuilderType = 'Any',
    }, 
} 