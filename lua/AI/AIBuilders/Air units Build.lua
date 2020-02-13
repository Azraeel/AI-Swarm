local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ================================================================================== --
-- ==                                 Air Unit Builders                               == --
-- ================================================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Air Builders',
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder { BuilderName = 'T1AirScout - Swarm',
        PlatoonTemplate = 'T1AirScout',
        Priority = 505,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.MOBILE * categories.SCOUT } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirFighter - Swarm - Response',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 650,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.AIR - categories.SCOUT }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirFighter - Swarm',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 20, categories.AIR * categories.MOBILE * categories.ANTIAIR }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirBomber - Swarm - Response',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 505,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'EnemyUnitsLessAtLocationRadius', { BaseEnemyZone, 'LocationType', 10, categories.ANTIAIR }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirBomber - Swarm',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.AIR * categories.MOBILE * categories.BOMBER }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1Gunship - Swarm',
        PlatoonTemplate = 'T1Gunship',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.AIR * categories.MOBILE * categories.GROUNDATTACK }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2FighterBomber - Swarm',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 16, categories.AIR * categories.MOBILE * categories.ANTIAIR * categories.BOMBER * categories.TECH2 }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T2AirGunship - Swarm',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.AIR * categories.MOBILE * categories.GROUNDATTACK * categories.TECH2 }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    Builder { BuilderName = 'T3AirScout - Swarm',
        PlatoonTemplate = 'T3AirScout',
        Priority = 705,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.AIR * categories.MOBILE * categories.SCOUT * categories.TECH3 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.AIR * categories.MOBILE * categories.SCOUT * categories.TECH3 } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirFighter - Swarm',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 30, categories.AIR * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirFighter - Swarm - Response',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 710,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.AIR - categories.SCOUT }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirGunship - Swarm',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 9, categories.AIR * categories.MOBILE * categories.GROUNDATTACK * categories.TECH3 }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirBomber - Swarm',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.AIR * categories.MOBILE * categories.BOMBER * categories.TECH3 }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --   TRANSPORT  --
    -- ============ --

    Builder { BuilderName = 'U1 Air Transport - Swarm',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 550, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.TRANSPORTATION } },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U2 Air Transport - Swarm',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.TRANSPORTATION } },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U3 Air Transport - Swarm',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 750,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.TRANSPORTATION } },
       },
        BuilderType = 'Air',
    }, 
}


-- ===================================================-======================================================== --
--                                          Air Scouts Formbuilder                                              --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Air Scout Formers',
    BuildersType = 'PlatoonFormBuilder',
    Builder { BuilderName = 'U1 Air Scout Form',
        PlatoonTemplate = 'T1AirScoutForm',
        Priority = 10000,
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
        },
        BuilderType = 'Any',
    },


    Builder { BuilderName = 'U3 Air Scout Form',
        PlatoonTemplate = 'T3AirScoutForm',
        PlatoonAddBehaviors = { 'AirUnitRefit' },
        Priority = 20000,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.INTELLIGENCE } },
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
--                                          Air Formbuilder                                                     --
-- ===================================================-======================================================== --

BuilderGroup { BuilderGroupName = 'Swarm Air Formers',
    BuildersType = 'PlatoonFormBuilder',                                       
    
    Builder {
        BuilderName = 'AISwarm AirAttack Bombers Units - Panic',
        PlatoonTemplate = 'BomberAttack',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                             
        Priority = 100,                                                          
        InstanceCount = 5,                                                 
        BuilderData = {
            SearchRadius = BasePanicZone,                                      
            GetTargetsFromBase = true,                                         
            AggressiveMove = true,                                              
            AttackEnemyStrength = 150,                                    
            IgnorePathing = true,                                               
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT,        
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
            WeaponTargetCategories = {                                        
                categories.ANTIAIR,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Bombers Units - Military',
        PlatoonTemplate = 'BomberAttack',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                             
        Priority = 100,                                                          
        InstanceCount = 5,                                                 
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                      
            GetTargetsFromBase = true,                                         
            AggressiveMove = true,                                              
            AttackEnemyStrength = 150,                                    
            IgnorePathing = true,                                               
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT,        
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
            WeaponTargetCategories = {                                        
                categories.ANTIAIR,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Bombers Resource - Enemy',
        PlatoonTemplate = 'BomberAttack',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                            
        Priority = 100,                                                         
        InstanceCount = 4,                                                      
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                   
            GetTargetsFromBase = false,                                      
            AggressiveMove = true,                                      
            AttackEnemyStrength = 100,                                         
            IgnorePathing = true,                                             
            TargetSearchCategory = categories.STRUCTURE,                 
            MoveToCategories = {          
                categories.STRUCTURE * categories.MASSEXTRACTION,                                      
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSFABRICATION,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.MOBILE * categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                       
                categories.COMMAND,
                categories.STRUCTURE * categories.MASSEXTRACTION,                                      
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSFABRICATION,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.EXPERIMENTAL,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                              
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Bombers Resource - Military',
        PlatoonTemplate = 'BomberAttack',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                            
        Priority = 100,                                                         
        InstanceCount = 4,                                                      
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                   
            GetTargetsFromBase = false,                                      
            AggressiveMove = true,                                      
            AttackEnemyStrength = 100,                                         
            IgnorePathing = true,                                             
            TargetSearchCategory = categories.STRUCTURE,                 
            MoveToCategories = {          
                categories.STRUCTURE * categories.MASSEXTRACTION,                                      
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSFABRICATION,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.MOBILE * categories.LAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                       
                categories.STRUCTURE * categories.MASSEXTRACTION,                                      
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.MASSFABRICATION,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.EXPERIMENTAL,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                              
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Snipe - T3 - Structure',
        PlatoonTemplate = 'SpecialOpsBomberAttack',
        Priority = 100,                                                         
        InstanceCount = 3,                                                 
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                      
            GetTargetsFromBase = false,                                      
            AggressiveMove = true,                                          
            AttackEnemyStrength = 150,                                            
            IgnorePathing = true,                                              
            TargetSearchCategory = categories.STRUCTURE,                        
            MoveToCategories = {                                                
                categories.COMMAND,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ARTILLERY,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                         
                categories.COMMAND,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ARTILLERY,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                  
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Snipe - T3 - Anti-Land',
        PlatoonTemplate = 'SpecialOpsBomberAttack',
        Priority = 100,                                                         
        InstanceCount = 3,                                                 
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                      
            GetTargetsFromBase = false,                                      
            AggressiveMove = true,                                          
            AttackEnemyStrength = 150,                                            
            IgnorePathing = true,                                              
            TargetSearchCategory = categories.MOBILE * categories.LAND,                        
            MoveToCategories = {                                                
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.TECH3,
                categories.MOBILE * categories.LAND * categories.TECH2,
                categories.MOBILE * categories.LAND * categories.TECH1,
                categories.COMMAND,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                         
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.TECH3,
                categories.MOBILE * categories.LAND * categories.TECH2,
                categories.MOBILE * categories.LAND * categories.TECH1,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                  
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Threat Fighters - Enemy',
        PlatoonTemplate = 'AirAttackThreat',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 100,                                                          
        InstanceCount = 5,                                                      
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                    
            GetTargetsFromBase = true,                                          
            AttackEnemyStrength = 1000000,                                      
            IgnorePathing = false,                                              
            AggressiveMove = true,                                             
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT , 
            MoveToCategories = {                                                
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }},
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Threat Fighters - Military',
        PlatoonTemplate = 'AirAttackThreat',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 100,                                                          
        InstanceCount = 5,                                                      
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    
            GetTargetsFromBase = true,                                          
            AttackEnemyStrength = 1000000,                                      
            IgnorePathing = false,                                              
            AggressiveMove = true,                                             
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT , 
            MoveToCategories = {                                                
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }},
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Threat Fighters - Panic',
        PlatoonTemplate = 'AirAttackThreat',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 100,                                                          
        InstanceCount = 5,                                                      
        BuilderData = {
            SearchRadius = BasePanicZone,                                    
            GetTargetsFromBase = true,                                          
            AttackEnemyStrength = 1000000,                                      
            IgnorePathing = false,                                              
            AggressiveMove = true,                                             
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT , 
            MoveToCategories = {                                                
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }},
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AISwarm Gunship Attack - Enemy',
        PlatoonTemplate = 'GunshipAttack',
        Priority = 100,                                                        
        InstanceCount = 3,                                                     
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                     
            GetTargetsFromBase = false,                                         
            AggressiveMove = true,                                           
            AttackEnemyStrength = 100,                                        
            IgnorePathing = true,                                             
            TargetSearchCategory = categories.STRUCTURE,                      
            MoveToCategories = {                                             
                categories.MASSEXTRACTION,
                categories.ENGINEER,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                        
                categories.MASSEXTRACTION,
                categories.COMMAND,
                categories.ENGINEER,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AISwarm Gunship Attack - Military',
        PlatoonTemplate = 'GunshipAttack',
        Priority = 100,                                                        
        InstanceCount = 3,                                                     
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                     
            GetTargetsFromBase = false,                                         
            AggressiveMove = true,                                           
            AttackEnemyStrength = 100,                                        
            IgnorePathing = true,                                             
            TargetSearchCategory = categories.STRUCTURE,                      
            MoveToCategories = {                                             
                categories.MASSEXTRACTION,
                categories.ENGINEER,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                        
                categories.MASSEXTRACTION,
                categories.COMMAND,
                categories.ENGINEER,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
}