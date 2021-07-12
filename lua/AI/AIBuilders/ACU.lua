local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

-- The Commander needs to fully become an Engineer, Combat doesnt suit him or the AI.
-- Not really sure if he should have a military usage tbf.
-- Done

BuilderGroup {
    BuilderGroupName = 'SC ACU Attack Former',                                    
    BuildersType = 'EngineerBuilder',
-- ================ --
--    ACU Former    --
-- ================ --
    Builder {
        BuilderName = 'SC CDR Attack Panic',                                    
        PlatoonTemplate = 'CDR Attack Swarm',                                       
        Priority = 590,                                                    
        InstanceCount = 100,                                                 
        BuilderData = {
            SearchRadius = BasePanicZone,
            GetTargetsFromBase = true,                                          
            RequireTransport = false,                                          
            AttackEnemyStrength = 2000,                                         
            IgnorePathing = true,         
            NodeWeight = 10000,                                             
            TargetSearchCategory = categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                            
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
                
            },
            WeaponTargetCategories = {                                      
                categories.COMMAND,
                categories.LAND + categories.INDIRECTFIRE,
                categories.LAND + categories.DIRECTFIRE,
                categories.LAND + categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*3  } },
           
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
       
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
        },
        BuilderType = 'Any',                                                  
    },

    Builder {
        BuilderName = 'SC CDR Attack Military - Usage',                                 
        PlatoonTemplate = 'CDR Attack Swarm',                                      
        Priority = 600,                                                    
        InstanceCount = 100,                                                      
        BuilderData = {
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = false,                                         
            RequireTransport = false,                                           
            AttackEnemyStrength = 2000,                                         
            IgnorePathing = true,                                              
            NodeWeight = 10000,   
            TargetSearchCategory = categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          
                categories.COMMAND,
                categories.LAND + categories.INDIRECTFIRE,
                categories.LAND + categories.DIRECTFIRE,
                categories.LAND + categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                  
   
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*6 } },
         
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
        },
        BuilderType = 'Any',                                              
    },

    Builder {
        BuilderName = 'SC CDR Attack Enemy - Usage',                                 
        PlatoonTemplate = 'CDR Attack Swarm',                                      
        Priority = 610,                                                    
        InstanceCount = 100,                                                      
        BuilderData = {
            SearchRadius = BaseEnemyZone,
            GetTargetsFromBase = false,                                         
            RequireTransport = false,                                           
            AttackEnemyStrength = 2000,                                         
            IgnorePathing = true,                                              
            NodeWeight = 10000,   
            TargetSearchCategory = categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          
                categories.COMMAND,
                categories.LAND + categories.INDIRECTFIRE,
                categories.LAND + categories.DIRECTFIRE,
                categories.LAND + categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                  
   
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*9 } },
         
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND - categories.SUPPORTFACTORY } },
        },
        BuilderType = 'Any',                                              
    },

    Builder {
        BuilderName = 'SC CDR Attack - Enhancing',                                 
        PlatoonTemplate = 'CDR Attack Swarm',                                      
        Priority = 580,                
        DelayEqualBuildPlattons = {'ACUFORM', 10},                                    
        InstanceCount = 100,                                                      
        BuilderData = {
            SearchRadius = 30,
            GetTargetsFromBase = false,                                         
            RequireTransport = false,                                           
            AttackEnemyStrength = 2000,                                         
            IgnorePathing = true,                                              
            NodeWeight = 10000,   
            TargetSearchCategory = categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          
                categories.COMMAND,
                categories.LAND + categories.INDIRECTFIRE,
                categories.LAND + categories.DIRECTFIRE,
                categories.LAND + categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                         
            { UCBC, 'CheckBuildPlattonDelay', { 'ACUFORM' }},
                                     
            { EBC, 'GreaterThanEconIncome',  { 2, 50}},
        },
        BuilderType = 'Any',                                              
    },

    Builder {
        BuilderName = 'SC CDR Attack - Hide',                                 
        PlatoonTemplate = 'CDR Attack Swarm',                                      
        Priority = 585,                
        DelayEqualBuildPlattons = {'ACUFORM', 10},                                    
        InstanceCount = 100,                                                      
        BuilderData = {
            SearchRadius = BasePanicZone,
            GetTargetsFromBase = false,                                         
            RequireTransport = false,                                           
            AttackEnemyStrength = 2000,                                         
            IgnorePathing = true,                                              
            NodeWeight = 10000,   
            TargetSearchCategory = categories.ALLUNITS - (categories.ENGINEER * categories.TECH1 * categories.TECH2) - categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          
                categories.COMMAND,
                categories.LAND + categories.INDIRECTFIRE,
                categories.LAND + categories.DIRECTFIRE,
                categories.LAND + categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                         
            { UCBC, 'CDRHealthLessThanSwarm', { 40 }},
        },
        BuilderType = 'Any',                                              
    },
}

-- ===================================================-======================================================== --
-- ==                                           ACU Assistees                                                == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'ACU Support Platoon Swarm',                               
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Engineer to ACU Platoon Swarm',
        PlatoonTemplate = 'AddEngineerToACUChampionPlatoon',
        Priority = 0,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 1, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 1, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Shield to ACU Platoon Swarm',
        PlatoonTemplate = 'AddShieldToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3) } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 2, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3) } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'SACU to ACU Platoon Swarm',
        PlatoonTemplate = 'AddSACUToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.SUBCOMMANDER} },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 2, categories.SUBCOMMANDER } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Tank to ACU Platoon Swarm',
        PlatoonTemplate = 'AddTankToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 2, categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'AntiAir to ACU Platoon Swarm',
        PlatoonTemplate = 'AddAAToACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MOBILE * categories.LAND * categories.ANTIAIR } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 3, categories.MOBILE * categories.LAND * categories.ANTIAIR } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Gunship to ACU Platoon Swarm',
        PlatoonTemplate = 'AddGunshipACUChampionPlatoon',
        Priority = 10000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            AIPlan = 'ACUChampionPlatoonSwarm',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 8, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS } },
        },
        BuilderType = 'Any',
    },
}