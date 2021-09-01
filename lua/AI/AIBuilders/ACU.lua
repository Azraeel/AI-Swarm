local categories = categories
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local HaveLessThanThreeT2LandFactoryACU = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.LAND * categories.TECH2, false, true )) >= 3 then
        return 0, false
	end
	
	return self.Priority,true
end

local HaveLessThanThreeT2AirFactoryACU = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR * categories.TECH2, false, true )) >= 3 then
        return 0, false
	end
	
	return self.Priority,true
end

-- The Commander needs to fully become an Engineer, Combat doesnt suit him or the AI.
-- Not really sure if he should have a military usage tbf.
-- Done

BuilderGroup { BuilderGroupName = 'Swarm ACU Initial Opener',
    BuildersType = 'EngineerBuilder',    
    Builder {
        BuilderName = 'Swarm Commander First Factory',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 5000,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Intial Mexes',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 4900,
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 12, -500, 1, 0, 'AntiSurface', 1 }}, -- LocationType, distance, threatMin, threatMax, threatRadius, threatType, maxNum

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.MASSEXTRACTION }},
        },
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                    'T1Resource',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SC ACU Formers',                                    
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
            TargetSearchCategory = categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT, 
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
           
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 10, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
       
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
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
            TargetSearchCategory = categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT, 
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
         
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 10, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
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
            TargetSearchCategory = categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT, 
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
   
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*8 } },
         
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 20, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.FACTORY * categories.LAND } },
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
            TargetSearchCategory = categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT, 
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
                                     
            { EBC, 'GreaterThanEconIncome',  { 2.0, 50.0}},
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
            TargetSearchCategory = categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT, 
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

    -- =============== --
    --    COMMANDER    --
    -- =============== --

    Builder {
        BuilderName = 'SC Assist Hydro',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 550,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocationSwarm', { 'LocationType', 0, categories.STRUCTURE * categories.HYDROCARBON }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 25,
                BeingBuiltCategories = {'STRUCTURE HYDROCARBON'},
                AssistUntilFinished = true,
            },
        }
    }, 

    Builder {
        BuilderName = 'SC Assist Standard',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 550,
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'TECH2', 'TECH3', 'EXPERIMENTAL'},               -- Unitcategories must be type string
                PermanentAssist = false,
                AssisteeType = 'Engineer',
                AssistClosestUnit = true,                                       -- Assist the closest unit instead unit with the least number of assisters
                Time = 75,
            },
        }
    },

    Builder { BuilderName = 'SC Assist Energy',
        PlatoonTemplate = 'CommanderAssist',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 0.6 }},

            { UCBC, 'HaveGreaterThanUnitsInCategoryBeingBuiltAtLocationSwarm', { 'LocationType', 0, categories.STRUCTURE * categories.ENERGYPRODUCTION - categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Structure',
                AssistRange = 200,
                BeingBuiltCategories = {'STRUCTURE ENERGYPRODUCTION TECH2', 'STRUCTURE ENERGYPRODUCTION TECH3'},-- Unitcategories must be type string
                AssistUntilFinished = true,
            },
        }
    },

    --==========================--
    -- Commander Energy Builders--
    --==========================--

    Builder {
        BuilderName = 'Swarm Commander Power low trend',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'LessThanEnergyTrend', { 4.0 } },             -- Ratio from 0 to 1. (1=100%)

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION - categories.TECH1 - categories.COMMAND } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY * (categories.LAND + categories.AIR),
                AdjacencyDistance = 100,
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Power MassRatio 10',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 645,
        BuilderConditions = {
            { EBC, 'EnergyToMassRatioIncome', { 10.0, '<=' } },  -- True if we have less than 10 times more Energy then Mass income ( 100 <= 10 = true )

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION - categories.TECH1 - categories.COMMAND } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.FACTORY * (categories.LAND + categories.AIR),
                AdjacencyDistance = 50,
                BuildClose = true,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    }, 

    Builder {
        BuilderName = 'Swarm Commander Land Factory Mass > MassStorage',

        PlatoonTemplate = 'CommanderBuilder',

        Priority = 650,

        PriorityFunction = HaveLessThanThreeT2LandFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } }, 
            
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Land Factory - Land Ratio',

        PlatoonTemplate = 'CommanderBuilder',

        Priority = 650,

        PriorityFunction = HaveLessThanThreeT2LandFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { UCBC, 'LandStrengthRatioLessThan', { 1 } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Air Factory Mass > MassStorage',

        PlatoonTemplate = 'CommanderBuilder',

        Priority = 650,

        PriorityFunction = HaveLessThanThreeT2AirFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Air Factory - Air Ratio',
        
        PlatoonTemplate = 'CommanderBuilder',

        Priority = 650,

        PriorityFunction = HaveLessThanThreeT2AirFactoryACU,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'AirStrengthRatioLessThan', { 1 } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Air Factory - No Air Factory',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 655,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = true,
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },
}

-- ==================
-- ==================
-- ==================

BuilderGroup { BuilderGroupName = 'Swarm Factory Builder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Commander Factory Builder Land - Recover',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    -- Add a Watermap Ratio Condition to replace CanPathTo
    Builder {
        BuilderName = 'Swarm Commander Factory Builder Land - Watermap',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 600,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Air - First - Watermap',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 650,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
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
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 1, categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD } },

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
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3) } },

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
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.SUBCOMMANDER} },

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
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL } },

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
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.MOBILE * categories.LAND * categories.ANTIAIR } },

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
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS } },

            { UCBC, 'UnitsLessInPlatoonSwarm', { 'ACUChampionPlatoonSwarm', 8, categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS } },
        },
        BuilderType = 'Any',
    },
}