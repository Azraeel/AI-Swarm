local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxAttackForce = 0.45                                                    
local MaxDefense = 0.12 
local MaxCapStructure = 0.12                                                 

-- A Few Notes About Some Changes here
-- You'll notice a really strange condition called GreaterThanEnergyIncomeSwarm on most of these builders
-- What this does is tries to determine Swarm's Eco Development 
-- We use this as a measurement of how much Eco he has developed and what is allowed to build

BuilderGroup { BuilderGroupName = 'Swarm Shields Builder', 

    BuildersType = 'EngineerBuilder',

    Builder { BuilderName = 'S2 Shield Ratio',

        PlatoonTemplate = 'T2EngineerBuilder',

        Priority = 850,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1 }},

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 500 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.1, 0.1}},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 9, categories.STRUCTURE * categories.SHIELD * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
            Construction = {
                DesiresAssist = true,
                BuildClose = true,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.TECH3) + (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 3,
                maxRadius = 25,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T2ShieldDefense',
                },
            },
        },
    },
    
    Builder { BuilderName = 'S3 Shield Ratio',

        PlatoonTemplate = 'T3EngineerBuildernoSUB',

        Priority = 1250,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeSwarm', { 750 }},
            
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.1, 0.1}},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 25, categories.STRUCTURE * categories.SHIELD * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.TECH3) + (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 3,
                maxRadius = 25,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3ShieldDefense',
                }
            }
        }
    },

    Builder { BuilderName = 'S3 Shield Ratio2',

        PlatoonTemplate = 'T3EngineerBuilderSUB',

        Priority = 1250,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeSwarm', { 800 }},
           
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.1, 0.1}},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.SHIELD * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.TECH3) + (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 3,
                maxRadius = 25,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3ShieldDefense',
                }
            }
        }
    },

    Builder { BuilderName = 'S3 Shield Ratio - Reactive',

        PlatoonTemplate = 'T3EngineerBuilderSUB',

        Priority = 1600,

        InstanceCount = 3,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeSwarm', { 1000 }},
           
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.1, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.1, 0.1}},

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.STRUCTURE * categories.TECH3 * categories.ARTILLERY } },
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 25, categories.STRUCTURE * categories.SHIELD * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = (categories.ENERGYPRODUCTION * categories.TECH3) + (categories.ENERGYPRODUCTION * categories.EXPERIMENTAL) + (categories.STRUCTURE * categories.FACTORY),
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 3,
                maxRadius = 25,
                LocationType = 'LocationType',
                BuildStructures = {
                    'T3ShieldDefense',
                }
            }
        }
    },
    
    Builder { BuilderName = 'S3 Paragon Shield',

        PlatoonTemplate = 'T3EngineerBuilderSUB',

        Priority = 1000,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.1, 1.0 }},

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 1000 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.1, 0.1}},

        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
         
            { UCBC, 'HasParagon', {} },
          
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, 100, 'ueb2304' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 4,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION,
                AdjacencyDistance = 100,
                AvoidCategory = categories.STRUCTURE * categories.SHIELD,
                maxUnits = 10,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3ShieldDefense',
                },
                Location = 'LocationType',
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Shields Upgrader',                
    BuildersType = 'PlatoonFormBuilder',
    
    Builder {
        BuilderName = 'S2 Shield Cybran 1',

        PlatoonTemplate = 'T2Shield1',

        Priority = 1000,

        DelayEqualBuildPlattons = {'Shield', 2},

        InstanceCount = 10,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 150 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.SHIELD }},

            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 Shield Cybran 2',

        PlatoonTemplate = 'T2Shield2',

        Priority = 1000,

        DelayEqualBuildPlattons = {'Shield', 2},

        InstanceCount = 10,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
            
            { EBC, 'GreaterThanEnergyIncomeSwarm', { 150 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},
            
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.SHIELD }},

            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 Shield Cybran 3',

        PlatoonTemplate = 'T2Shield3',

        Priority = 1000,

        DelayEqualBuildPlattons = {'Shield', 2},

        InstanceCount = 10,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 150 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.SHIELD }},

            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 Shield Cybran 4',

        PlatoonTemplate = 'T2Shield4',

        Priority = 1000,

        DelayEqualBuildPlattons = {'Shield', 2},
        
        InstanceCount = 10,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 150 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 2, categories.STRUCTURE * categories.SHIELD }},

            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 Shield UEF Seraphim',

        PlatoonTemplate = 'T2Shield',

        Priority = 1000,

        DelayEqualBuildPlattons = {'Shield', 2},

        InstanceCount = 10,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 150 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 3, categories.STRUCTURE * categories.SHIELD }},

            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
}


BuilderGroup { BuilderGroupName = 'Swarm T2 Tactical Missile Defenses Builder',   

    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'S2 TMD Panic 1',

        PlatoonTemplate = 'T2EngineerBuilder',

        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 250 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  280, 'LocationType', 0, categories.TACTICALMISSILEPLATFORM }}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S2 TMD Panic 2',

        PlatoonTemplate = 'T2EngineerBuilder',

        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 250 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  280, 'LocationType', 3, categories.TACTICALMISSILEPLATFORM }}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S2 TMD Panic 3',

        PlatoonTemplate = 'T2EngineerBuilder',
        
        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 275 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  280, 'LocationType', 6, categories.TACTICALMISSILEPLATFORM }}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 9, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S2 TMD',

        PlatoonTemplate = 'T2EngineerBuilder',

        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 300 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }}, 

            { UCBC, 'HaveUnitRatioAtLocationSwarm', { 'LocationType', 0.5, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2, '<',categories.STRUCTURE * categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * (categories.MASSEXTRACTION + categories.FACTORY),
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2MissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },
}



BuilderGroup { BuilderGroupName = 'Swarm SMD Builder',                              
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S3 SMD 1st Main',

        PlatoonTemplate = 'T3EngineerBuildernoSUB',

        Priority = 1600,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.05 }},

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 500 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { MIBC, 'GreaterThanGameTime', { 1800 } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.03, 0.1 } },        
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 20,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'S3 SMD Enemy Main',

        PlatoonTemplate = 'T3EngineerBuilderSUB',

        Priority = 1275,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeSwarm', { 600 }},

            { UCBC, 'HaveUnitRatioAtLocationSwarmRadiusVersusEnemy', { 1.20, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.05 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.03, 0.1}},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 20,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'S3 SMD Enemy Yolona Oss',

        PlatoonTemplate = 'T3EngineerBuilderSUB',

        Priority = 2000,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeSwarm', { 700 }},

            { UCBC, 'HaveUnitRatioAtLocationSwarmRadiusVersusEnemy', { 3.00, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * categories.EXPERIMENTAL * categories.SERAPHIM } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}},   
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 20,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'S3 SMD Enemy Expansion',

        PlatoonTemplate = 'T3EngineerBuilderSUB',

        Priority = 1150,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeSwarm', { 700 }},
        	
            { UCBC, 'HaveUnitRatioAtLocationSwarmRadiusVersusEnemy', { 1.50, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<',categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildNotOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}},       

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * (categories.TECH3 + categories.EXPERIMENTAL) } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 5,
            Construction = {
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 50,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3,
                maxUnits = 1,
                maxRadius = 20,
                BuildStructures = {
                    'T3StrategicMissileDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'S3AntiNukeAI',
        PlatoonTemplate = 'AddToAntiNukePlatoon',
        Priority = 4000,
        FormRadius = 10000,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },
        },
        BuilderData = {
            AIPlan = 'S3AntiNukeAI',
        },
        BuilderType = 'Any',
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Defense Anti Ground Builders',                               
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'UA2 Perimeter Defense',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 950,
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 300 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}}, 
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildClose = false,
                NearBasePatrolPoints = true,
                BuildStructures = {
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T2ShieldDefense',
                    'T2AADefense',
                    'T2AADefense',
                    'T2MissileDefense',
                    'T2MissileDefense',
                    'T2Artillery',
                    'T2Artillery',
                    'T2ShieldDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'UA3 Perimeter Defense',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1000,
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 300 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}}, 
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildClose = false,
                NearBasePatrolPoints = true,
                BuildStructures = {
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T2GroundDefense',
                    'T2ShieldDefense',
                    'T3AADefense',
                    'T3AADefense',
                    'T2MissileDefense',
                    'T2MissileDefense',
                    'T2Artillery',
                    'T2Artillery',
                    'T2ShieldDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Reclaim T1 PD',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 550,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * categories.DIRECTFIRE }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH2 * categories.DIRECTFIRE }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * categories.DIRECTFIRE
            },
        },
        BuilderType = 'Any',
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Defense Anti Air Builders',                              
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'S2 AA',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 905,
        InstanceCount = 1,                                      
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 250 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyCategory = categories.STRUCTURE,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH2,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T2AADefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S3 AA',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1025,
        InstanceCount = 1,                                      
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeSwarm', { 350 }},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}},  

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyCategory = categories.STRUCTURE,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH3,
                maxUnits = 1,
                maxRadius = 8,
                BuildClose = false,
                BuildStructures = {
                    'T3AADefense',
                },
                Location = 'LocationType',
            }
        }
    },   

    Builder {
        BuilderName = 'Swarm Reclaim T1 AA',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        PlatoonAIPlan = 'ReclaimStructuresAI',   
        Priority = 250,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * categories.ANTIAIR }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.DEFENSE * categories.TECH2 * categories.ANTIAIR }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * categories.ANTIAIR
            },
        },
        BuilderType = 'Any',
    },
}



