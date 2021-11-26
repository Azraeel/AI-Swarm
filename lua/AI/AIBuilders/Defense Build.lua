local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                    
local MaxDefense = 0.12 
local MaxCapStructure = 0.12                                                 

-- A Few Notes About Some Changes here
-- You'll notice a really strange condition called GreaterThanEnergyIncomeOverTimeSwarm on most of these builders
-- What this does is tries to determine Swarm's Eco Development 
-- We use this as a measurement of how much Eco he has developed and what is allowed to build

-- General Reduction in GreaterThanEnergyIncomeOverTimeSwarm Numbers 
-- July 26, 2021

BuilderGroup { BuilderGroupName = 'Swarm Shields Builder', 

    BuildersType = 'EngineerBuilder',

    Builder { BuilderName = 'S2 Shield Ratio',

        PlatoonTemplate = 'T2EngineerBuilderSwarm',

        Priority = 850,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.1 }},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 9, categories.STRUCTURE * categories.SHIELD * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
            Construction = {
                DesiresAssist = true,
                BuildClose = true,
                AdjacencyPriority = {
                    categories.STRATEGIC * categories.STRUCTURE,
                    categories.ENERGYPRODUCTION - categories.TECH1,
                    categories.RADAR * categories.STRUCTURE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
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

        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',

        Priority = 1250,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},
            
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 25, categories.STRUCTURE * categories.SHIELD * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyPriority = {
                    categories.STRATEGIC * categories.STRUCTURE,
                    categories.ENERGYPRODUCTION - categories.TECH1,
                    categories.RADAR * categories.STRUCTURE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
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

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 1250,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},
           
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.SHIELD * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyPriority = {
                    categories.STRATEGIC * categories.STRUCTURE,
                    categories.ENERGYPRODUCTION - categories.TECH1,
                    categories.RADAR * categories.STRUCTURE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
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

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 1600,

        InstanceCount = 3,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},
           
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.1, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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
                AdjacencyPriority = {
                    categories.STRATEGIC * categories.STRUCTURE,
                    categories.ENERGYPRODUCTION - categories.TECH1,
                    categories.RADAR * categories.STRUCTURE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
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

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 1000,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.1, 1.0 }},

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 1000 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
         
            { UCBC, 'HasParagon', {} },
          
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, 100, 'ueb2304' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 4,
            Construction = {
                AdjacencyPriority = {
                    categories.ECONOMIC * categories.EXPERIMENTAL,
                    categories.SHIELD * categories.STRUCTURE,
                    categories.STRATEGIC * categories.STRUCTURE,
                    categories.ENERGYPRODUCTION - categories.TECH1,
                    categories.RADAR * categories.STRUCTURE,
                    categories.STRUCTURE * categories.FACTORY * categories.AIR,
                    categories.FACTORY * categories.STRUCTURE * categories.LAND,
                },
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
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },
            
            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
            
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
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.1 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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

        PlatoonTemplate = 'T2EngineerBuilderSwarm',

        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 50 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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

        PlatoonTemplate = 'T2EngineerBuilderSwarm',

        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 50 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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

        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        
        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 50 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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

        PlatoonTemplate = 'T2EngineerBuilderSwarm',

        Priority = 10000,

        InstanceCount = 1,

        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 100 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.05, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

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

        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',

        Priority = 1600,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'GreaterThanGameTime', { 1800 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},     

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
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

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 1275,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'HaveUnitRatioAtLocationSwarmRadiusVersusEnemy', { 1.20, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
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

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 2000,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 300 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}}, 

            { UCBC, 'HaveUnitRatioAtLocationSwarmRadiusVersusEnemy', { 3.00, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * categories.EXPERIMENTAL * categories.SERAPHIM } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
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

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 1150,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
            
            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 300 }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},    
        	
            { UCBC, 'HaveUnitRatioAtLocationSwarmRadiusVersusEnemy', { 1.50, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<',categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildNotOnLocationSwarm', { 'LocationType', 'MAIN' } },

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
        BuilderName = 'UA1 - Panic T1 PD',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
            { MIBC, 'GreaterThanGameTime', { 300 } },

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, categories.DEFENSE * categories.DIRECTFIRE}},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER }}, -- radius, LocationType, unitCount, categoryEnemy

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 50 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = true,
            NumAssistees = 5,
            Construction = {
                BaseTemplateFile = '/mods/AI-Swarm/lua/AI/AIBuilders/BaseTemplates Build.lua',
                BaseTemplate = 'T1PDTemplate',
                BuildClose = true,
                OrderedTemplate = true,
                NearBasePatrolPoints = false,
                BuildStructures = {
                    'T1GroundDefense',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                    'Wall',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'UA2 Perimeter Defense',
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        Priority = 950,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.ENGINEER * categories.TECH2}},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.04, 1.05 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
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
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.ENGINEER * (categories.TECH3 + categories.SUBCOMMANDER)}},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 500 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.04, 1.05 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
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
}

BuilderGroup { BuilderGroupName = 'Swarm Defense Anti Air Builders',                              
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'S2 AA',
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        Priority = 905,
        InstanceCount = 1,                                      
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
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
        BuilderName = 'S2 AA - Response to Ratio',
        PlatoonTemplate = 'T2EngineerBuilderSwarm',
        Priority = 910,
        InstanceCount = 1,                                      
        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 0.8 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 6, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
                maxUnits = 1,
                maxRadius = 8,
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
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 1025,
        InstanceCount = 1,                                      
        BuilderConditions = {
            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
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
        BuilderName = 'S3 AA - Response to Ratio',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 1030,
        InstanceCount = 1,                                      
        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 0.8 } },

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 0.0 } },

            { EBC, 'GreaterThanEnergyIncomeOverTimeSwarm', { 200 }},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 8, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.STRUCTURE * categories.FACTORY,
                },
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
}



