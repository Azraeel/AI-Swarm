local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                               


local HaveLessThanTwoT2AirFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR - categories.TECH1, false, true )) < 2 then
	
		return 500, true
		
	end

	
	return 0, false
	
end

local HaveLessThanTwoT3AirFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR * categories.TECH3, false, true )) < 2 then
	
		return 500, true
		
	end

	
	return 0, false
	
end

BuilderGroup { BuilderGroupName = 'Swarm Air Builders',
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --

    Builder {
        BuilderName = 'Swarm-AI - T1 Air Fight Group',

        PlatoonTemplate = 'SwarmAIFighterGroup',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT2AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T1 Air Attack Group',

        PlatoonTemplate = 'SwarmAIT1AirAttack',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT2AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'Swarm-AI - T2 Air Fighter Group',

        PlatoonTemplate = 'SwarmAIFighterGroupT2',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T2 Air Attack Group',

        PlatoonTemplate = 'SwarmAIT2AirAttack',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    Builder {
        BuilderName = 'Swarm-AI - T3 Air Fighter Group',
        PlatoonTemplate = 'SwarmAIT3AirFighterGroup',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'AirStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T3 Air Attack Group',
        PlatoonTemplate = 'SwarmAIT3AirAttackQueue',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.01}},
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

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.1 }},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 2, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

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

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.1 }},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 2, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

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

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.1 }},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

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
            SearchRadius = 256,                                   
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
            SearchRadius = 256,                                   
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
            SearchRadius = 256,                                  
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
            SearchRadius = 256,                                    
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
            SearchRadius = 256,                                    
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
            SearchRadius = 256,                                    
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
            SearchRadius = 128,                                    
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
            SearchRadius = 256,                                    
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
            SearchRadius = 128,                                    
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
            SearchRadius = 128,                                    
            GetTargetsFromBase = true,                                          
            AggressiveMove = true,                                              
            AttackEnemyStrength = 300,                                    
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
            SearchRadius = 128,                                    
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
            SearchRadius = 256,                                  
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
            SearchRadius = 256,                                   
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

        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Enemy AntiMass Gunship',                                  
        PlatoonTemplate = 'Swarm Gunship Intercept 3 5',                          
        Priority = 67,                                                          
        InstanceCount = 4,                                                    
        BuilderData = {
            SearchRadius = 512,                                       
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.1 } },
        },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'Swarm Enemy AntiMass Bomber 3 5',                                   
        PlatoonTemplate = 'Swarm Bomber Intercept 3 5',                        
        Priority = 67,                                                     
        InstanceCount = 3,                                                  
        BuilderData = {
            SearchRadius = 512,                                          
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.1 } },
        },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'U12 Enemy Unprotected Gunship 3 5',                            
        PlatoonTemplate = 'Swarm Gunship Intercept 3 5',                          
        Priority = 68,                                                         
        InstanceCount = 3,                                                     
        BuilderData = {
            SearchRadius = 512,                                       
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.1 } },
        },
        BuilderType = 'Any',                                                   
    },
    Builder {
        BuilderName = 'Swarm Enemy Unprotected Bomber 1 3',                            
        PlatoonTemplate = 'Swarm Bomber Intercept 1 3',                          
        Priority = 68,                                                   
        InstanceCount = 3,                                                  
        BuilderData = {
            SearchRadius = 512,                                    
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.1 } },
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
            SearchRadius = 512,                                      
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },
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
            SearchRadius = 512,                                     
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },
        },
        BuilderType = 'Any',                                               
    },
    
    Builder {
        BuilderName = 'Swarm PANIC AntiSea TorpedoBomber',                      
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 128,                                       -- Searchradius for new target.
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
        BuilderConditions = {                                              

        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Military AntiSea TorpedoBomber',                  
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = 256,                                    -- Searchradius for new target.
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
        BuilderConditions = {                                                   
        
        },
        BuilderType = 'Any',                                           
    },

    Builder {
        BuilderName = 'Swarm Enemy AntiStructure TorpedoBomber',
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        Priority = 70,
        InstanceCount = 2,
        BuilderData = {
            SearchRadius = 512,                                       -- Searchradius for new target.
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
        BuilderConditions = {                                      
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },
        },
        BuilderType = 'Any',
    },
}