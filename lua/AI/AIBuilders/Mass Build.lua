local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapMass = 0.25 
local MaxCapStructure = 0.25                   

-- I need a function or something, that does not allow engineers in a certain radius to build something. 
-- This is a issue mostly with factories, engineers walking all the way back to base to build factory from 300 distances away.
-- Fixed Said Issue mostly by introducing new AIBuildStructure and EngineerBuildAI
-- With New MexBuildAI by Chp2001, we can hopefully reduce overrall engineers needed to claim mexes quickly and efficiently

BuilderGroup {
    BuilderGroupName = 'S1 MassBuilders',                       
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'Swarm Mass 240',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 670,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { MABC, 'CanBuildOnMassDistanceSwarm', { 'LocationType', 0, 240, nil, nil, 0, 'AntiSurface', 1}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                Type = 'Mass',
                MaxDistance = 240,
                ThreatMin = -500,
                ThreatMax = 50,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Mass 480 - Mexbuild',
        PlatoonTemplate = 'T1EngineerBuilderMexSwarm',
        Priority = 660,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'LandStrengthRatioGreaterThan', { 0.6 } },

            --{ UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 10, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }},

            { MABC, 'CanBuildOnMassDistanceSwarm', { 'LocationType', 0, 480, nil, nil, 0, 'AntiSurface', 1}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                Type = 'Mass',
                MaxDistance = 480,
                ThreatMin = -500,
                ThreatMax = 50,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Mass 480',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 655,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'LandStrengthRatioGreaterThan', { 0.6 } },

            --{ UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 10, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }},

            { MABC, 'CanBuildOnMassDistanceSwarm', { 'LocationType', 0, 480, nil, nil, 0, 'AntiSurface', 1}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                Type = 'Mass',
                MaxDistance = 480,
                ThreatMin = -500,
                ThreatMax = 50,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Mass 1000',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 655,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'LandStrengthRatioGreaterThan', { 0.6 } },

            --{ UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 10, categories.ALLUNITS - categories.ENGINEER - categories.AIR - categories.SCOUT }},

            { MABC, 'CanBuildOnMassDistanceSwarm', { 'LocationType', 0, 1000, nil, nil, 0, 'AntiSurface', 1}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                RepeatBuild = true,
                Type = 'Mass',
                MaxDistance = 1000,
                ThreatMin = -500,
                ThreatMax = 50,
                ThreatRings = 0,
                ThreatType = 'AntiSurface',
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },

    Builder {
        BuilderName = 'S3 Mass Fab',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { UCBC, 'HaveUnitRatioSwarm', { 0.3, categories.STRUCTURE * categories.MASSFABRICATION, '<=',categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },

            { EBC, 'GreaterThanEnergyTrendOverTimeSwarm', { 0.0 } },   

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { EBC, 'LessThanEconStorageRatioSwarm', { 0.35, 2.0 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                DesiresAssist = true,
                NumAssistees = 4,
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.STRUCTURE * categories.SHIELD,
                },
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
    BuilderGroupName = 'S1 MassStorage Builder',                        
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Mass Adjacency Engineer - Ring',
        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',
        Priority = 1005,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 10 } },

            { UCBC, 'UnitCapCheckLess', { .8 } },

            { MABC, 'MarkerLessThanDistance',  { 'Mass', 275, -3, 0, 0}},
            
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3), 250, 'ueb1106' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3) }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 4,  categories.STRUCTURE * categories.MASSSTORAGE }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 1.2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }}, 

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3),
                AdjacencyDistance = 250,
                AdjRequired = true,
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
        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',
        Priority = 1025,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 * 15 } },

            { UCBC, 'UnitCapCheckLess', { .8 } },
            
            { MABC, 'MarkerLessThanDistance',  { 'Mass', 775, -3, 0, 0}},
           
            { UCBC, 'AdjacencyCheck', { 'LocationType', categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3), 750, 'ueb1106' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 8, categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3) }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 8,  categories.STRUCTURE * categories.MASSSTORAGE }},

            { EBC, 'GreaterThanMassTrendOverTimeSwarm', { 1.6 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }}, 

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
        },
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.MASSEXTRACTION * (categories.TECH2 + categories.TECH3),
                AdjacencyDistance = 750,
                AdjRequired = true,
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
