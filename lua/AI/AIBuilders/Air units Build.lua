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
        Priority = 525,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.MOBILE * categories.SCOUT * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.AIR * categories.MOBILE * categories.SCOUT } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirFighter - Swarm - Minimum',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 520,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.ANTIAIR }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T1AirFighter > Enemy',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.MOBILE * categories.ENGINEER - categories.STATIONASSISTPOD}},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.LAND * categories.FACTORY * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.TECH3 - categories.ENGINEER }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 1.00, categories.MOBILE * categories.AIR * categories.ANTIAIR, '<',categories.MOBILE * categories.AIR * categories.ANTIAIR } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirBomber - Swarm',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.GROUNDATTACK }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1Gunship - Swarm',
        PlatoonTemplate = 'T1Gunship',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.AIR  * categories.BOMBER }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'T2AirFighterBomber - Swarm',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T2TorpedoBomber - Swarm',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 }},

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.NAVAL * categories.FACTORY } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.ANTINAVY }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTINAVY * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T2TorpedoBomber - Swarm - WaterMap',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 750,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTINAVY }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTINAVY * categories.TECH3 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T2AirGunship - Swarm',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 }},
            -- Respect UnitCap
            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxAttackForce , '<=', categories.MOBILE - categories.ENGINEER } },
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    Builder { BuilderName = 'T3AirScout - Swarm',
        PlatoonTemplate = 'T3AirScout',
        Priority = 985,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.MOBILE * categories.SCOUT * categories.TECH3 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.MOBILE * categories.SCOUT * categories.TECH3 } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T3AirFighter - Swarm - Minimum',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 950,
        BuilderConditions = {
            { EBC, 'GreaterThanEconIncomeSwarm', { 2.5, 100 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR * categories.TECH3 - categories.GROUNDATTACK }},

            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T3AirGunship - Swarm - Minimum',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR }},

            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T3AirFighter < Gunship - Swarm',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveUnitRatioSwarm', { 2.50, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR - categories.GROUNDATTACK, '<=',categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR } },

            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'T3AirGunship < Fighter - Swarm',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveUnitRatioSwarm', { 2.50, categories.MOBILE * categories.AIR * categories.HIGHALTAIR * categories.ANTIAIR - categories.GROUNDATTACK, '>=',categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR } },

            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T3AirBomber < 20 - Swarm',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.MOBILE * categories.AIR * categories.BOMBER }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.EXPERIMENTAL }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.AIR  * categories.BOMBER }},
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },

    -- =========================== --
    --  Anti-Experimental Builder  --
    -- =========================== --

    Builder {
        BuilderName = 'T2EAirGunship - Swarm',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 960,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.GROUNDATTACK * categories.TECH3 - categories.HIGHALTAIR }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR }},

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 30.0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR, '<=', categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },

            { UCBC, 'UnitCapCheckLess', { 0.98 } },

        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'T3EAirFighter EXPResponse',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 970,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.MOBILE * categories.AIR * categories.EXPERIMENTAL } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 80, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 30.0, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.GROUNDATTACK - categories.BOMBER, '<=', categories.MOBILE * categories.AIR * categories.EXPERIMENTAL } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'S3E Air Gunship EXPResponse',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 970,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR }},

            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 30.0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.HIGHALTAIR, '<=', categories.MOBILE * categories.LAND * categories.EXPERIMENTAL } },
            -- Respect UnitCap
            { UCBC, 'UnitCapCheckLess', { 0.98 } },
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --   TRANSPORT  --
    -- ============ --

    Builder { BuilderName = 'S1 Air Transport - Swarm',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 510, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 2, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.TRANSPORTATION } },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S2 Air Transport - Swarm',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 603,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 2, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.TRANSPORTATION } },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S3 Air Transport - Swarm',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 707,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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
    Builder {
        BuilderName = 'Swarm Former Scout T1',
        PlatoonTemplate = 'T1AirScoutFormSwarm',
        InstanceCount = 8,
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
    Builder {
    BuilderName = 'Swarm Former Scout T3',
        PlatoonTemplate = 'T3AirScoutFormSwarm',
        InstanceCount = 8,
        Priority = 910,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Swarm Former Scout Patrol DMZ T1',
        PlatoonTemplate = 'T1AirScoutFormSwarm',
        InstanceCount = 4,
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
        },
        BuilderData = {
            Patrol = true,
            PatrolTime = 600,
            --MilitaryArea = 'BaseDMZArea',
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Swarm Former Scout Patrol DMZ T3',
        PlatoonTemplate = 'T3AirScoutFormSwarm',
        InstanceCount = 4,
        Priority = 900,
        BuilderData = {
            Patrol = true,
            PatrolTime = 600,
            --MilitaryArea = 'BaseDMZArea',
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
--                                          Air Formbuilder                                                     --
-- ===================================================-======================================================== --

BuilderGroup { BuilderGroupName = 'Swarm Air Formers',
    BuildersType = 'PlatoonFormBuilder',
    
    Builder {
        BuilderName = 'Swarm Fighter Intercept 3 5',
        PlatoonTemplate = 'Swarm Fighter Intercept 3 5',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                      
        Priority = 150,                                                        
        InstanceCount = 4,                                                   
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                   
            GetTargetsFromBase = true,                                          
            AttackEnemyStrength = 1000000,                                      
            IgnorePathing = false,                                          
            AggressiveMove = true,                                            
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                           
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, 
        },
        BuilderType = 'Any',                                                   
    },

    Builder {
        BuilderName = 'Swarm Fighter Intercept 10',
        PlatoonTemplate = 'Swarm Fighter Intercept 10',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                      
        Priority = 150,                                                        
        InstanceCount = 4,                                                   
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                   
            GetTargetsFromBase = true,                                          
            AttackEnemyStrength = 1000000,                                      
            IgnorePathing = false,                                          
            AggressiveMove = true,                                            
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                           
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, 
        },
        BuilderType = 'Any',                                                   
    },
    Builder {
        BuilderName = 'Swarm Fighter Intercept 20',
        PlatoonTemplate = 'Swarm Fighter Intercept 20',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 150,                                                        
        InstanceCount = 2,                                                     
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                  
            GetTargetsFromBase = true,                                         
            AttackEnemyStrength = 200,                                           
            IgnorePathing = false,                                         
            AggressiveMove = true,                                           
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                              
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                             
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, 
        },
        BuilderType = 'Any',                                                   
    },
    Builder {
        BuilderName = 'Swarm Fighter Intercept 30 50',
        PlatoonTemplate = 'Swarm Fighter Intercept 30 50',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                          
        Priority = 150,                                                         
        InstanceCount = 1,                                                      
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    
            GetTargetsFromBase = true,                                          
            AttackEnemyStrength = 300,                                       
            IgnorePathing = false,                                             
            AggressiveMove = true,                                           
            TargetSearchCategory = categories.MOBILE * categories.AIR - categories.SCOUT, 
            MoveToCategories = {                                               
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.MOBILE * categories.AIR,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR - categories.SCOUT }}, 
        },
        BuilderType = 'Any',                                                  
    },

    Builder {
        BuilderName = 'Swarm Military AntiTransport',
        PlatoonTemplate = 'Swarm Fighter Intercept 3 5',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                             
        Priority = 100,                                                       
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    
            GetTargetsFromBase = true,                                      
            AggressiveMove = true,                                          
            AttackEnemyStrength = 300,                                         
            IgnorePathing = true,                                      
            TargetSearchCategory = categories.MOBILE * categories.AIR  * categories.TRANSPORTFOCUS,      
            MoveToCategories = {                                           
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS }}, 
        },
        BuilderType = 'Any',                                                   
    },

    Builder {
        BuilderName = 'Swarm Military AntiGunship',
        PlatoonTemplate = 'Swarm Fighter Intercept 1 2',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 100,                                                          
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    
            GetTargetsFromBase = true,                                      
            AggressiveMove = true,                                             
            AttackEnemyStrength = 300,                                      
            IgnorePathing = true,                                           
            TargetSearchCategory = categories.MOBILE * categories.AIR * categories.GROUNDATTACK, 
            MoveToCategories = {                                                
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Panic AntiGunship',
        PlatoonTemplate = 'Swarm Fighter Intercept 1 2',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 100,                                                          
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BasePanicZone,                                    
            GetTargetsFromBase = true,                                      
            AggressiveMove = true,                                             
            AttackEnemyStrength = 300,                                      
            IgnorePathing = true,                                           
            TargetSearchCategory = categories.MOBILE * categories.AIR * categories.GROUNDATTACK, 
            MoveToCategories = {                                                
                categories.MOBILE * categories.AIR * categories.GROUNDATTACK,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Military AntiBomber',
        PlatoonTemplate = 'Swarm Fighter Intercept 1 2',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 100,                                                          
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    
            GetTargetsFromBase = true,                                      
            AggressiveMove = true,                                             
            AttackEnemyStrength = 300,                                      
            IgnorePathing = true,                                           
            TargetSearchCategory = categories.MOBILE * categories.AIR * categories.BOMBER, 
            MoveToCategories = {                                                
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.BOMBER }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Panic AntiBomber',
        PlatoonTemplate = 'Swarm Fighter Intercept 1 2',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 100,                                                          
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BasePanicZone,                                    
            GetTargetsFromBase = true,                                      
            AggressiveMove = true,                                             
            AttackEnemyStrength = 300,                                      
            IgnorePathing = true,                                           
            TargetSearchCategory = categories.MOBILE * categories.AIR * categories.BOMBER, 
            MoveToCategories = {                                                
                categories.MOBILE * categories.AIR * categories.BOMBER,
                categories.MOBILE * categories.AIR * categories.TRANSPORTFOCUS,
                categories.MOBILE * categories.AIR * categories.ANTIAIR,
                categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.AIR * categories.BOMBER }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Panic AntiGround',                                 
        PlatoonTemplate = 'AntiGround Bomber/Gunship Mix',                           
        PlatoonAddBehaviors = { 'AirUnitRefit' },                             
        Priority = 100,                                                        
        InstanceCount = 3,                                                
        BuilderData = {
            SearchRadius = BasePanicZone,                                    
            GetTargetsFromBase = true,                                          
            AggressiveMove = true,                                              
            AttackEnemyStrength = 100000000,                                    
            IgnorePathing = true,                                               
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,       
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
            WeaponTargetCategories = {                                       
                categories.ANTIAIR,
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                  
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Military AntiGround',                                 
        PlatoonTemplate = 'AntiGround Bomber/Gunship Mix',                           
        PlatoonAddBehaviors = { 'AirUnitRefit' },                             
        Priority = 100,                                                       
        InstanceCount = 4,                                                 
        BuilderData = {
            SearchRadius = BasePanicZone,                                    
            GetTargetsFromBase = true,                                         
            AggressiveMove = true,                                             
            AttackEnemyStrength = 100000000,                                    
            IgnorePathing = true,                                               
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,    
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
            WeaponTargetCategories = {                                         
                categories.ANTIAIR,
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                               
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Military AntiArty 1 2',                             
        PlatoonTemplate = 'Swarm Gunship/Bomber Intercept 1 2',                 
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 92,                                                        
        InstanceCount = 2,                                                     
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                  
            GetTargetsFromBase = true,                                       
            AggressiveMove = false,                                           
            AttackEnemyStrength = 500,                                        
            IgnorePathing = false,                                             
            TargetSearchCategory = categories.MOBILE * categories.LAND * categories.INDIRECTFIRE, 
            MoveToCategories = {                                              
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                  
                categories.INDIRECTFIRE * categories.TECH3,
                categories.INDIRECTFIRE * categories.TECH2,
                categories.INDIRECTFIRE * categories.TECH1,
                categories.COMMAND,
                categories.ENGINEER - categories.STATIONASSISTPOD,
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
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, 
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE * categories.LAND * categories.INDIRECTFIRE }}, 
        },
        BuilderType = 'Any',                                                 
    },

    Builder {
        BuilderName = 'Swarm Military AntiGround 3 5',                               
        PlatoonTemplate = 'Swarm Gunship/Bomber Intercept 3 5',                 
        PlatoonAddBehaviors = { 'AirUnitRefit' },                             
        Priority = 80,                                                       
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                   
            GetTargetsFromBase = true,                                         
            AggressiveMove = false,                                             
            AttackEnemyStrength = 200,                                          
            IgnorePathing = false,                                               
            TargetSearchCategory = categories.MOBILE - categories.AIR,          
            MoveToCategories = {                                               
                categories.MOBILE * categories.EXPERIMENTAL,
                categories.MOBILE * categories.ANTIAIR,
                categories.MOBILE * categories.INDIRECTFIRE,
                categories.MOBILE * categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE - categories.AIR }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Enemy AntiMass Gunship',                                  
        PlatoonTemplate = 'Swarm Gunship Intercept 3 5',                          
        Priority = 67,                                                          
        InstanceCount = 4,                                                    
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       
            GetTargetsFromBase = false,                                         
            AggressiveMove = true,                                             
            AttackEnemyStrength = 33,                                    
            IgnorePathing = false,                                               
            TargetSearchCategory = categories.ALLUNITS,                         
            MoveToCategories = {                                              
                categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.ALLUNITS,
            },
            WeaponTargetCategories = {                                          
                categories.MASSEXTRACTION,
                categories.COMMAND,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, 
        },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'Swarm Enemy AntiMass Bomber 3 5',                                   
        PlatoonTemplate = 'Swarm Bomber Intercept 3 5',                        
        Priority = 67,                                                     
        InstanceCount = 3,                                                  
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                          
            GetTargetsFromBase = false,                                        
            AggressiveMove = false,                                            
            AttackEnemyStrength = 33,                                           
            IgnorePathing = false,                                             
            TargetSearchCategory = categories.MASSEXTRACTION,                  
            MoveToCategories = {                                               
                categories.MASSEXTRACTION,
            },
            WeaponTargetCategories = {                                         
                categories.MASSEXTRACTION,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, 
        },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'U12 Enemy Unprotected Gunship 3 5',                            
        PlatoonTemplate = 'Swarm Gunship Intercept 3 5',                          
        Priority = 68,                                                         
        InstanceCount = 3,                                                     
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       
            GetTargetsFromBase = false,                                       
            AggressiveMove = false,                                            
            AttackEnemyStrength = 0,                                           
            IgnorePathing = false,                                              
            TargetSearchCategory = categories.STRUCTURE + categories.ENGINEER - categories.STATIONASSISTPOD,                        
            MoveToCategories = {                                                
                categories.MASSEXTRACTION,
                categories.ENGINEER - categories.STATIONASSISTPOD,
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
                categories.ENGINEER - categories.STATIONASSISTPOD,
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
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, 
        },
        BuilderType = 'Any',                                                   
    },
    Builder {
        BuilderName = 'Swarm Enemy Unprotected Bomber 1 3',                            
        PlatoonTemplate = 'Swarm Bomber Intercept 1 3',                          
        Priority = 68,                                                   
        InstanceCount = 3,                                                  
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                    
            GetTargetsFromBase = false,                                      
            AggressiveMove = false,                                        
            AttackEnemyStrength = 0,                                         
            IgnorePathing = false,                                             
            TargetSearchCategory = categories.STRUCTURE + categories.ENGINEER - categories.STATIONASSISTPOD,                 
            MoveToCategories = {  
                categories.ENGINEER,                                              
                categories.MASSEXTRACTION,
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
                categories.ENGINEER - categories.STATIONASSISTPOD,
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
        BuilderConditions = {                                                 
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, 
        },
        BuilderType = 'Any',                                                   
    },

    Builder {
        BuilderName = 'Swarm Enemy AntiGround Bomber',                                
        PlatoonTemplate = 'Swarm Bomber Intercept 15 20',                       
        PlatoonAddBehaviors = { 'AirUnitRefit' },                              
        Priority = 62,                                                  
        InstanceCount = 3,                                                    
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                      
            GetTargetsFromBase = false,                                        
            AggressiveMove = false,                                           
            AttackEnemyStrength = 100,                                          
            IgnorePathing = false,                                             
            TargetSearchCategory = categories.EXPERIMENTAL + categories.STRUCTURE,                 
            MoveToCategories = {                                               
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
                categories.COMMAND,
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
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, 
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 30, categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'Swarm Enemy AntiGround Gunship',                               
        PlatoonTemplate = 'Swarm Gunship Intercept 15 20',                      
        PlatoonAddBehaviors = { 'AirUnitRefit' },                              
        Priority = 60,                                                        
        InstanceCount = 3,                                                     
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                     
            GetTargetsFromBase = false,                                        
            AggressiveMove = false,                                             
            AttackEnemyStrength = 100,                                         
            IgnorePathing = false,                                          
            TargetSearchCategory = categories.EXPERIMENTAL + categories.STRUCTURE,                   
            MoveToCategories = {                                               
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH3,
                categories.STRUCTURE * categories.MASSEXTRACTION * categories.TECH2,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
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
                categories.COMMAND,
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
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.MOBILE * categories.EXPERIMENTAL }}, 
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 30, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',                                               
    },
    
    Builder {
        BuilderName = 'S123 PANIC AntiSea TorpedoBomber',                       -- Random Builder Name.
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

    Builder {
        BuilderName = 'S123 Military AntiSea TorpedoBomber',                    -- Random Builder Name.
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.STRUCTURE + categories.MOBILE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

    Builder {
        BuilderName = 'S123 Enemy AntiStructure TorpedoBomber',
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        Priority = 70,
        InstanceCount = 2,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.STRUCTURE * categories.NAVAL * categories.FACTORY,
                categories.MOBILE * categories.NAVAL * categories.DEFENSE,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitsGreaterAtEnemySwarm', { 1 , categories.STRUCTURE + categories.MOBILE } },
        },
        BuilderType = 'Any',
    },
}