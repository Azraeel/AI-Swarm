local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)
local MaxDefense = 0.12 -- 12% of all units can be defenses (categories.STRUCTURE * categories.DEFENSE)
local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                       Build T2 & T3 Shields                                            == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Shields Builder',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder { BuilderName = 'U2 Shield Ratio',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 850,
        InstanceCount = 2,
        BuilderConditions = {
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.50 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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
    
    Builder { BuilderName = 'U3 Shield Ratio',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1250,
        InstanceCount = 2,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.40 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
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

    Builder { BuilderName = 'U3 Shield Ratio',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1250,
        InstanceCount = 2,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.40 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 3, categories.STRUCTURE * categories.SHIELD}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 30, categories.STRUCTURE * categories.SHIELD * categories.TECH3) }},
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

    Builder { BuilderName = 'U3 Shield Ratio - Reactive',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1600,
        InstanceCount = 3,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.20, 0.40 } },             -- Ratio from 0 to 1. (1=100%)

            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.STRUCTURE * categories.TECH3 * categories.ARTILLERY } },
            -- Don't build it if...
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
    
    Builder { BuilderName = 'U3 Paragon Shield',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1000,
        InstanceCount = 2,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            -- Do we need additional conditions to build it ?
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC  * categories.ENERGYPRODUCTION  * categories.MASSPRODUCTION, 100, 'ueb2304' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 3,
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
    
    -- ===================== --
    --    Reclaim Shields    --
    -- ===================== --
    Builder { BuilderName = 'U1 Reclaim T1-T2 Shields',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH3 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * (categories.TECH1 + categories.TECH2) }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH1,
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH2,
                      },
        },
        BuilderType = 'Any',
    },
    
    Builder { BuilderName = 'U1 Reclaim T1-T2-T3 Shields',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.SHIELD * categories.EXPERIMENTAL } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.EXPERIMENTAL }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.SHIELD - categories.EXPERIMENTAL }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH1,
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH2,
                        categories.STRUCTURE * categories.DEFENSE * categories.SHIELD * categories.TECH3,
                      },
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                      Upgrade T1 & T2 Shields                                           == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Shields Upgrader',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder {
        BuilderName = 'U2 Shield Cybran 1',
        PlatoonTemplate = 'T2Shield1',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield Cybran 2',
        PlatoonTemplate = 'T2Shield2',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield Cybran 3',
        PlatoonTemplate = 'T2Shield3',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield Cybran 4',
        PlatoonTemplate = 'T2Shield4',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'U2 Shield UEF Seraphim',
        PlatoonTemplate = 'T2Shield',
        Priority = 1000,
        DelayEqualBuildPlattons = {'Shield', 2},
        InstanceCount = 10,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.50}}, -- Ratio from 0 to 1. (1=100%)
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 1, categories.TECH3 * categories.ENERGYPRODUCTION}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.STRUCTURE * categories.SHIELD }},
            { UCBC, 'CheckBuildPlattonDelay', { 'Shield' }},
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                     T2 Tactical Missile Defenses                                       == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm T2 Tactical Missile Defenses Builder',                               
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U2 TMD Panic 1',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 0, categories.TACTICALMISSILEPLATFORM }}, 

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
        BuilderName = 'U2 TMD Panic 2',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 3, categories.TACTICALMISSILEPLATFORM }}, 

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
        BuilderName = 'U2 TMD Panic 3',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  280, 'LocationType', 6, categories.TACTICALMISSILEPLATFORM }}, 

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
        BuilderName = 'U2 TMD',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 10000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.60 } },             -- Ratio from 0 to 1. (1=100%)

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2 }}, 

            { UCBC, 'HaveUnitRatioAtLocation', { 'LocationType', 0.5, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH2, '<',categories.STRUCTURE * categories.FACTORY } },
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
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

-- ===================================================-======================================================== --
-- ==                                    T3 Strategic Missile Defense                                        == --
-- ===================================================-======================================================== --

BuilderGroup { BuilderGroupName = 'Swarm SMD Builder',                              
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U3 SMD 1st Main',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1600,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.00, 0.00 } },        
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
        BuilderName = 'U3 SMD Enemy Main',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1275,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 1.20, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } }, 
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
        BuilderName = 'U3 SMD Enemy Yolona Oss',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 2000,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 3.00, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<', categories.SILO * categories.NUKE * categories.EXPERIMENTAL * categories.SERAPHIM } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildOnlyOnLocation', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },   
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
        BuilderName = 'U3 SMD Enemy Expansion',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1150,
        BuilderConditions = {
        	{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.ENERGYPRODUCTION * categories.TECH3 } },
        	
            { UCBC, 'HaveUnitRatioAtLocationRadiusVersusEnemy', { 1.50, 'LocationType', 90, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3, '<',categories.SILO * categories.NUKE * (categories.TECH3 + categories.EXPERIMENTAL) } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH3}},

            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.50 } },       

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
        BuilderName = 'U3AntiNukeAI',
        PlatoonTemplate = 'AddToAntiNukePlatoon',
        Priority = 4000,
        FormRadius = 10000,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanArmyPoolWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 } },
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            AIPlan = 'U3AntiNukeAI',
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                     T1-T3 Base point defense                                           == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Defense Anti Ground Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U1 Ground Defense always',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.50, 0.65 } },        

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 5, categories.STRUCTURE * categories.DEFENSE - categories.ANTIAIR }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.TECH1,
                NumAssistees = 1,
                BuildClose = false,
                BuildStructures = {
                    'T1GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    }, 

    Builder {
        BuilderName = 'U2 Artillery',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 500,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.STRUCTURE * categories.ARTILLERY * categories.TECH2 }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.60, 0.70 }},
        },
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildStructures = {
                    'T2Artillery',
                },
                Location = 'LocationType',
            }
        }
    },
    
    Builder {
        BuilderName = 'U2 Ground Defense always',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 950,
        InstanceCount = 3,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.35 } },   

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 15, categories.STRUCTURE * categories.DEFENSE * categories.TECH2 - categories.ANTIAIR }},     
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 10,
            Construction = {
            	AdjacencyCategory = categories.STRUCTURE,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.TECH2,
                BuildClose = false,
                BuildStructures = {
                    'T2GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U3 Ground Defense always',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1050,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.LAND * categories.EXPERIMENTAL } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.35 } },  

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 15, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 - categories.ANTIAIR }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 5,
            Construction = {
            	AdjacencyCategory = categories.STRUCTURE,
                AvoidCategory = categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                DesiresAssist = true,
                BuildClose = false,
                BuildStructures = {
                    'T3GroundDefense',
                    'T3GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'UA1 Perimeter Defense',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 535,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.35, 0.40 } },   
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildClose = false,
                NearBasePatrolPoints = true,
                BuildStructures = {
                    'T1GroundDefense',
                },
                Location = 'LocationType',
            }
        }
    }, 

    Builder {
        BuilderName = 'UA2 Perimeter Defense',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 950,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.35 } },
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
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.35 } },
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

    -- ============================ --
    --    Reclaim Ground Defense    --
    -- ============================ --
    Builder {
        BuilderName = 'U1 Reclaim T1+T2 PD',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 250,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * (categories.TECH1 + categories.TECH2) * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR,
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH2 * ( categories.DIRECTFIRE + categories.INDIRECTFIRE ) - categories.ANTIAIR
                      },
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                  T1-T3 Base Anti Air defense                                           == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Defense Anti Air Builders',                              
    BuildersType = 'EngineerBuilder',
    --[[ Builder {
        BuilderName = 'U1 AA',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 500,
        InstanceCount = 1,                                     
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.35 }},

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 1,
            Construction = {
            	AdjacencyCategory = categories.STRUCTURE,
                AvoidCategory = categories.STRUCTURE * categories.ANTIAIR * categories.TECH1,
                maxUnits = 1,
                maxRadius = 10,
                BuildClose = false,
                BuildStructures = {
                    'T1AADefense',
                },
                Location = 'LocationType',
            }
        }
    }, ]]--
    Builder {
        BuilderName = 'U2 AA',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 905,
        InstanceCount = 2,                                      
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.45 }}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 13, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 2,
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
        BuilderName = 'U3 AA',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 1025,
        InstanceCount = 3,                                      
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.45}}, 

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 19, categories.STRUCTURE * categories.DEFENSE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 4,
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
    -- ================ --
    --    Reclaim AA    --
    -- ================ --
    Builder {
        BuilderName = 'U1 Reclaim T1+T2 AA',
        PlatoonTemplate = 'EngineerBuilder',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveUnitRatioVersusCap', { MaxDefense, '>', categories.STRUCTURE * categories.DEFENSE } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * categories.TECH3 * categories.ANTIAIR }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.DEFENSE * (categories.TECH1 + categories.TECH2) * categories.ANTIAIR }},
            -- Have we the eco to build it ?
            -- Don't build it if...
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH1 * categories.ANTIAIR,
                        categories.STRUCTURE * categories.DEFENSE * categories.TECH2 * categories.ANTIAIR
                      },
        },
        BuilderType = 'Any',
    },
}



