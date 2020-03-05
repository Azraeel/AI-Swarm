local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii(true)


BuilderGroup { BuilderGroupName = 'Swarm Transports - Water Map',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',

    Builder { BuilderName = 'U1 Air Transport - Water Map',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 550, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U2 Air Transport - Water Map',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }}
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U3 Air Transport - Water Map',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 750,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }}
       },
        BuilderType = 'Air',
    }, 
}

BuilderGroup { BuilderGroupName = 'Swarm Land Builders - Water Map',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',

    Builder { BuilderName = 'T1LandDFTank - Water Map',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.DIRECTFIRE * categories.LAND }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.DIRECTFIRE * categories.LAND} },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandArtillery - Water Map',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.INDIRECTFIRE * categories.LAND }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.INDIRECTFIRE * categories.LAND} },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandAA - Water Map',
        PlatoonTemplate = 'T1LandAA',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR} },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2LandDFTank - Water Map',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.DIRECTFIRE * categories.LAND * categories.TECH2 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.TECH2} },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2AeonBlaze - Water Map',
        PlatoonTemplate = 'T2AeonBlaze',
        Priority = 700,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.DIRECTFIRE * categories.LAND * categories.TECH2 * categories.HOVER * categories.AEON }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.HOVER * categories.TECH2 * categories.AEON} },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2MobileShields - Water Map - Aeon Only',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 700,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND * categories.SHIELD * categories.TECH2 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.SHIELD * categories.TECH2} },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandAA - Water Map - Aeon and Seraphim Only',
        PlatoonTemplate = 'T2LandAA',
        Priority = 700,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 * categories.HOVER}},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.HOVER * categories.TECH2 * categories.ANTIAIR * categories.LAND} },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U2 Amphibious',
        PlatoonTemplate = 'U2 LandSquads Amphibious',
        Priority = 300,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.LAND * categories.HOVER * categories.AMPHIBIOUS * categories.TECH2 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.MOBILE * categories.AMPHIBIOUS * categories.TECH2 * categories.DIRECTFIRE} },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3ArmoredAssault - Water Map',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 900,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.AMPHIBIOUS * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandAA - Water Map',
        PlatoonTemplate = 'T3LandAA',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Factory Builder - Water Map',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Commander Factory Builder Land - Water Map',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 590,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.30}}, 

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
            	AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Factory Builder Air - Water Map',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.40}}, 

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.AIR * categories.FACTORY * (categories.TECH1 + categories.TECH2 + categories.TECH3)  }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
                AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                Location = 'LocationType',
                BuildStructures = {
                   'T1AirFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Land - Water Map',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 605,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.40}}, 

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
            	AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Air - Water Map',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 610,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.40}},

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 7, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                AdjacencyCategory = categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}