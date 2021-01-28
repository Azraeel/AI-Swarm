local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapMass = 0.25 -- 25% of all units can be mass extractors (STRUCTURE * MASSEXTRACTION)
local MaxCapStructure = 0.25                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ============================================================================================================ --
-- ==                                     Build MassExtractors / Creators                                    == --
-- ============================================================================================================ --
BuilderGroup {
    BuilderGroupName = 'S1 MassBuilders',                       
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S1 Mass 30 - Opener',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 600,
        InstanceCount = 2,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 30, -500, 1, 0, 'AntiSurface', 1 }}, 
            
            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S1 Mass 30',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 600,
        InstanceCount = 2,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 30, -500, 1, 0, 'AntiSurface', 1 }},

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S2 Mass 30',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 600,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 30, -500, 1, 0, 'AntiSurface', 1 }},

            { EBC, 'LessThanEconStorageRatio', { 0.50, 2 } },

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S3 Mass 30',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 600,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 30, -500, 1, 0, 'AntiSurface', 1 }},

            { EBC, 'LessThanEconStorageRatio', { 0.35, 2 } },

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T3Resource',
                }
            }
        }
    },
    
    Builder {
        BuilderName = 'S1 Mass 60',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 585,
        InstanceCount = 4,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 60, -500, 1, 0, 'AntiSurface', 1 }},

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S2 Mass 60',
        PlatoonTemplate = 'T2EngineerBuilder',
        Priority = 585,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 60, -500, 1, 0, 'AntiSurface', 1 }},

            { EBC, 'LessThanEconStorageRatio', { 0.50, 2 } },

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S3 Mass 60',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 585,
        InstanceCount = 1,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 60, -500, 1, 0, 'AntiSurface', 1 }},

            { EBC, 'LessThanEconStorageRatio', { 0.35, 2 } },

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                BuildStructures = {
                    'T3Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S1 Mass 1000 6+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 575,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        InstanceCount = 4,
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'S1 Mass 1000 8+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 565,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        InstanceCount = 4,
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }}, 
            
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 7, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'S1 Mass 1000 10+',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 555,
        DelayEqualBuildPlattons = {'MASSEXTRACTION', 3},
        InstanceCount = 4,
        BuilderConditions = {
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 1000, -500, 1, 0, 'AntiSurface', 1 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 9, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'CheckBuildPlattonDelay', { 'MASSEXTRACTION' }},

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapMass , '<', categories.STRUCTURE * categories.MASSEXTRACTION } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'SC Resource RECOVER',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 150,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 2*60 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },

            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 60, -5000, 1, 0, 'AntiSurface', 1 }},

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'S1 Resource RECOVER',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 150,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 2*60 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.MASSEXTRACTION } },
      
            { MABC, 'CanBuildOnMassSwarm', { 'LocationType', 60, -5000, 1, 0, 'AntiSurface', 1 }}, 

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S3 Mass Fab',
        PlatoonTemplate = 'EngineerBuilderT3&SUB',
        Priority = 1175,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'HaveUnitRatioSwarm', { 0.3, categories.STRUCTURE * categories.MASSFABRICATION, '<=',categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.95}}, 

            { EBC, 'LessThanEconStorageRatio', { 0.75, 2 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 4,
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                AdjacencyDistance = 80,
                AvoidCategory = categories.MASSFABRICATION,
                maxUnits = 1,
                maxRadius = 15,
                BuildClose = true,
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'S123 ExtractorUpgrades SWARM',                               
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'S1S Extractor upgrade',
        PlatoonTemplate = 'AddToMassExtractorUpgradePlatoon',
        Priority = 18400,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.MASSEXTRACTION} },

            { UCBC, 'GreaterThanGameTimeSeconds', { 270 } },
        },
        BuilderData = {
            AIPlan = 'ExtractorUpgradeAISwarm',
        },
        BuilderType = 'Any',
    },
}

BuilderGroup {
    BuilderGroupName = 'S1 MassStorage Builder',                        
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Mass Adjacency Engineer - Ring',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 1005,
        InstanceCount = 4,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3) }},
            
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3), 250, 'ueb1106' } },
            
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 10 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.50 } },

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 275, -3, 0, 0}},

            { UCBC, 'UnitCapCheckLess', { .8 } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 4,  categories.STRUCTURE * categories.MASSSTORAGE }},
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3),
                AdjacencyDistance = 250,
                ThreatMin = -3,
                ThreatMax = 0,
                ThreatRings = 0,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
    Builder {
        BuilderName = 'Swarm Mass Adjacency Engineer - Outter Mexes - Ring',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 1025,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 8, categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3) }},
           
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3), 750, 'ueb1106' } },
            
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 15 } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.50 } }, 

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 775, -3, 0, 0}},

            { UCBC, 'UnitCapCheckLess', { .8 } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 4,  categories.STRUCTURE * categories.MASSSTORAGE }},
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3),
                AdjacencyDistance = 750,
                ThreatMin = -3,
                ThreatMax = 0,
                ThreatRings = 0,
                BuildClose = false,
                BuildStructures = {
                    'MassStorage',
                }
            }
        },
        BuilderType = 'Any'
    },
}
