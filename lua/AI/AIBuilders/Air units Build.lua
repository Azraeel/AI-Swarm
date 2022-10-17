local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()                                        

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

    -- This Specific Builder Covers the first 6 Minutes.
    -- In Which Swarm is promised to open with a fourth air factory.
    -- So Due to the construct of our normal air builders.
    -- We put this in to cover our first maybe 5 or 10 Inteceptors. 
    Builder {
        BuilderName = 'T1 Air Opening Queue',

        PlatoonTemplate = 'SwarmAIT1AirOpeningQueue',

        Priority = 500,

        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 60 * 5 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},
        },
        BuilderType = 'Air',
    }, 

    Builder {
        BuilderName = 'Swarm-AI - T1 Air Fighter',

        PlatoonTemplate = 'T1AirFighter',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T1 Air Bomber',

        PlatoonTemplate = 'T1AirBomber',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT2AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T1 Air Gunship',

        PlatoonTemplate = 'T1Gunship',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT2AirFactory,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder {
        BuilderName = 'Swarm-AI - T2 Air Fighter/Bomber',

        PlatoonTemplate = 'T2FighterBomber',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.9, 1.0 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T2 Air Gunship',

        PlatoonTemplate = 'T2AirGunship',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.9, 1.0 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T2 Air Torpedo-Bomber',

        PlatoonTemplate = 'T2AirTorpedoBomber',

        Priority = 500,

        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.NAVAL * categories.MOBILE } },

            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.9, 1.0 }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    Builder {
        BuilderName = 'Swarm-AI - T3 Air Fighter',

        PlatoonTemplate = 'T3AirFighter',

        Priority = 500,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'AirStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.1 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T3 Air Bomber',

        PlatoonTemplate = 'T3AirBomber',

        Priority = 500,
        
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.1 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T3 Air Gunship',

        PlatoonTemplate = 'T3AirGunship',

        Priority = 500,
        
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.1 }},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T3 Air Torpedo-Bomber',

        PlatoonTemplate = 'T3TorpedoBomber',

        Priority = 500,

        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.NAVAL * categories.MOBILE } },

            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.1 }},
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.3, 12.0 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.1 }},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S2 Air Transport - Swarm',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 603,
        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.3, 12.0 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.1 }},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S3 Air Transport - Swarm',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 707,
        BuilderConditions = {
            { UCBC, 'AirStrengthRatioGreaterThan', { 1 } },

            { MIBC, 'FactionIndex', { 1 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.3, 12.0 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.1 }},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},
       },
        BuilderType = 'Air',
    }, 

    Builder {
        BuilderName = 'Swarm-AI - T1 Air Scout',

        PlatoonTemplate = 'T1AirScoutSwarm',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3AirFactory,

        BuilderConditions = {
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.AIR * categories.SCOUT * categories.TECH1 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { SIBC, 'HaveLessThanUnitsForMapSize', { {[256] = 8, [512] = 12, [1024] = 18, [2048] = 20, [4096] = 20}, categories.AIR * categories.SCOUT}},
        },
        BuilderType = 'Air',
    },

    Builder {
        BuilderName = 'Swarm-AI - T3 Air Scout',

        PlatoonTemplate = 'T3AirScout',

        Priority = 500,

        BuilderConditions = {
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.AIR * categories.SCOUT * categories.TECH3 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.1 }},

            { SIBC, 'HaveLessThanUnitsForMapSize', { {[256] = 4, [512] = 8, [1024] = 12, [2048] = 16, [4096] = 20}, categories.AIR * categories.SCOUT}},
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
        InstanceCount = 2,
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
        InstanceCount = 2,
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
        BuilderName = 'Swarm Fighter Intercept 1 10',
        PlatoonTemplate = 'Swarm Fighter Intercept 1 10',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                      
        Priority = 160,                                                        
        InstanceCount = 2,                                                  
        BuilderData = {
            Defensive = true,
            SearchRadius = BasePanicZone,
            LocationType = 'LocationType',
            AvoidBases = true,
            NeverGuardEngineers = true,
            PlatoonLimit = 10,
            PrioritizedCategories = {
                categories.EXPERIMENTAL * categories.AIR,
                categories.BOMBER * categories.AIR,
                categories.GROUNDATTACK * categories.AIR,
                categories.TRANSPORTFOCUS * categories.AIR,
                categories.ANTIAIR * categories.AIR,
                categories.AIR,
            },
        },
        BuilderConditions = {                          
            { UCBC, 'AirStrengthRatioLessThan', { 1 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.ENGINEER } },
        },
        BuilderType = 'Any',                                                   
    },

    Builder {
        BuilderName = 'Swarm Fighter Intercept 10 40',
        PlatoonTemplate = 'Swarm Fighter Intercept 10 40',
        PlatoonAddBehaviors = { 'AirUnitRefit' },                               
        Priority = 158,                                                        
        InstanceCount = 2,                                                     
        BuilderData = {
            SearchRadius = BasePanicZone,
            LocationType = 'LocationType',
            AvoidBases = true,
            NeverGuardEngineers = true,
            PlatoonLimit = 40,
            PrioritizedCategories = {
                categories.EXPERIMENTAL * categories.AIR,
                categories.GROUNDATTACK * categories.AIR,
                categories.BOMBER * categories.AIR,
                categories.ANTIAIR * categories.AIR,
            },
        },
        BuilderConditions = {         
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.1 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 9, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.ENGINEER } },    
        },
        BuilderType = 'Any',                                                   
    },

    Builder {
        BuilderName = 'Swarm Gunship Local',                                  
        PlatoonTemplate = 'Swarm Gunship Medium',    
        PlatoonAddBehaviors = { 'AirUnitRefit' },                        
        Priority = 75,                                                          
        InstanceCount = 2,                                                    
        BuilderData = {
            Defensive = true,
            SearchRadius = BaseMilitaryZone,                                                       
            PrioritizedCategories = {               
                categories.COMMAND,  
                categories.SUBCOMMANDER, 
                categories.EXPERIMENTAL,                                 
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.ENGINEER - categories.STATIONASSISTPOD,
                categories.ECONOMIC,
                categories.SHIELD,
                categories.ANTIAIR,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.MOBILE * categories.AIR * categories.GROUNDATTACK } }, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Bomber Local',                                 
        PlatoonTemplate = 'Swarm Bomber Medium',                           
        PlatoonAddBehaviors = { 'AirUnitRefit' },                             
        Priority = 100,                                                        
        InstanceCount = 2,                                                
        BuilderData = {
            Defensive = true,
            SearchRadius = BaseMilitaryZone,                                    
            PrioritizedCategories = {                            
                categories.COMMAND,  
                categories.SUBCOMMANDER,    
                categories.EXPERIMENTAL,                
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.ENGINEER - categories.STATIONASSISTPOD,
                categories.ECONOMIC,
                categories.SHIELD,
                categories.ANTIAIR,
            },
        },
        BuilderConditions = {   
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.MOBILE * categories.AIR * categories.BOMBER } },                                                
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Gunship Economic',                                  
        PlatoonTemplate = 'Swarm Gunship Big',     
        PlatoonAddBehaviors = { 'AirUnitRefit' },                        
        Priority = 75,                                                          
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                                           
            PrioritizedCategories = {                                              
                categories.MASSPRODUCTION + categories.MASSEXTRACTION, 
                categories.ENGINEER - categories.STATIONASSISTPOD,
                categories.ECONOMIC,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.AIR * categories.GROUNDATTACK } }, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Bomber Economic',                                  
        PlatoonTemplate = 'Swarm Bomber Big',    
        PlatoonAddBehaviors = { 'AirUnitRefit' },                         
        Priority = 70,                                                          
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                                           
            PrioritizedCategories = {                                              
                categories.MASSPRODUCTION + categories.MASSEXTRACTION, 
                categories.ENGINEER - categories.STATIONASSISTPOD,
                categories.ECONOMIC,
                categories.SHIELD,
                categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {               
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.AIR * categories.BOMBER } }, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm T3 Bomber Anti-Mass 1 1',                            
        PlatoonTemplate = 'Swarm T3 Bomber Intercept 1 1',   
        PlatoonAddBehaviors = { 'AirUnitRefit' },                          
        Priority = 75,                                                   
        InstanceCount = 1,                                                  
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                               
            PrioritizedCategories = {                                              
                categories.MASSEXTRACTION - categories.TECH1,
                categories.ENERGYPRODUCTION - categories.TECH1,
                categories.FACTORY - categories.TECH1,
                categories.ALLUNITS - categories.TECH1,
            },
        },
        BuilderConditions = {           
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 } }, 
        },
        BuilderType = 'Any',                                                   
    },

    Builder {
        BuilderName = 'Swarm T3 Bomber Snipe 5 20',                            
        PlatoonTemplate = 'Swarm T3 Bomber Intercept 5 20',   
        PlatoonAddBehaviors = { 'AirUnitRefit' },                          
        Priority = 70,                                                   
        InstanceCount = 1,                                                  
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                                   
            PrioritizedCategories = {                                              
                categories.COMMAND,
                categories.SUBCOMMANDER,
                categories.MASSEXTRACTION - categories.TECH1,
                categories.ENERGYPRODUCTION - categories.TECH1,
                categories.FACTORY - categories.TECH1,
                categories.ALLUNITS - categories.TECH1,
            },
        },
        BuilderConditions = {                  
            { UCBC, 'AirStrengthRatioGreaterThan', { 2 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 } }, 
        },
        BuilderType = 'Any',                                                   
    },
    
    Builder {
        BuilderName = 'Swarm PANIC AntiSea TorpedoBomber',                      
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        PlatoonAddBehaviors = { 'AirUnitRefit' },   
        Priority = 90,                                                       
        InstanceCount = 2,                                           
        BuilderData = {
            SearchRadius = BasePanicZone,                                     
            GetTargetsFromBase = true,                                     
            AggressiveMove = true,                                              
            AttackEnemyStrength = 300,                          
            IgnorePathing = true,                                             
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,  
            MoveToCategories = {                                                
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {        
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.AIR * categories.ANTINAVY } },                                      
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Military AntiSea TorpedoBomber',                  
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        PlatoonAddBehaviors = { 'AirUnitRefit' },   
        Priority = 80,                                                 
        InstanceCount = 3,                                            
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                 
            GetTargetsFromBase = false,                         
            AggressiveMove = true,                                      
            AttackEnemyStrength = 150,                                          
            IgnorePathing = true,                                           
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,    
            MoveToCategories = {                                              
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 1.5 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 10, categories.MOBILE * categories.AIR * categories.ANTINAVY } }, 
        },
        BuilderType = 'Any',                                           
    },

    Builder {
        BuilderName = 'Swarm Enemy AntiStructure TorpedoBomber',
        PlatoonTemplate = 'S123-TorpedoBomber 1 100',
        PlatoonAddBehaviors = { 'AirUnitRefit' },   
        Priority = 70,
        InstanceCount = 2,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                    
            GetTargetsFromBase = false,                                   
            AggressiveMove = true,                                
            AttackEnemyStrength = 150,                                        
            IgnorePathing = true,                                           
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,
            MoveToCategories = {                                             
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
            { UCBC, 'AirStrengthRatioGreaterThan', { 2 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.MOBILE * categories.AIR * categories.ANTINAVY } }, 
        },
        BuilderType = 'Any',
    },
}