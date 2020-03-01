local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapEngineers = 0.08 -- 8% of all units can be Engineers (categories.MOBILE * categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                 Build Engineers TECH 1,2,3 and SACU                                    == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Engineer Builders',
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder { BuilderName = 'U1 Engineer builder Cap',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 1000,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0, 0 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH1 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH1} },
         },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'U2 Engineer builder Cap',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 1010,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH2 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH1} },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'U3 Engineer builder Cap',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 1015,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH3 } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.ENGINEER * categories.TECH1} },
        },
        BuilderType = 'Land',
    },
}

BuilderGroup {
    BuilderGroupName = 'Swarm Engineering Support Builder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'AISwarm T2 Engineering Support UEF',
        PlatoonTemplate = 'UEFT2EngineerBuilder',
        Priority = 200,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, 'ENGINEERSTATION' }},

            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 1, 'ENGINEER TECH2' } },

            { EBC, 'GreaterThanEconIncome',  { 10, 100}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 1.4 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'FACTORY',
                BuildClose = true,
                FactionIndex = 1,
                BuildStructures = {
                    'T2EngineerSupport',
                },
            }
        }
    },
    Builder {
        BuilderName = 'AISwarm T2 Engineering Support Cybran',
        PlatoonTemplate = 'CybranT2EngineerBuilder',
        Priority = 200,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, 'ENGINEERSTATION' }},

            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 1, 'ENGINEER TECH2' } },

            { EBC, 'GreaterThanEconIncome',  { 10, 100}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 1.4 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'FACTORY',
                BuildClose = true,
                FactionIndex = 3,
                BuildStructures = {
                    'T2EngineerSupport',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'Swarm Hive+Kennel Upgrade',                           
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'S2 Kennel Upgrade',
        PlatoonTemplate = 'S2KennelUpgrade',
        Priority = 1000,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1 }}, 

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99 } }, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.ENGINEERSTATION }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 Hive Upgrade',
        PlatoonTemplate = 'S2HiveUpgrade',
        Priority = 1000,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 3 }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99 } },   

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.ENGINEERSTATION }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S3 Hive Upgrade',
        PlatoonTemplate = 'S3HiveUpgrade',
        Priority = 1000,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 3 }}, 

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconStorageRatio', { 0.30, 0.99 } },        

            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgrade', { 3, categories.ENGINEERSTATION }},
        },
        BuilderType = 'Any',
    },
}


BuilderGroup { BuilderGroupName = 'Swarm SACU Builder',
    BuildersType = 'FactoryBuilder',


    Builder {
        BuilderName = 'U3 SubCommander RAMBO',
        PlatoonTemplate = 'U3 SACU RAMBO preset 12345',
        Priority = 1017,
        BuilderConditions = { 
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.RAMBOPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.RAMBOPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ENGINEER',
        PlatoonTemplate = 'U3 SACU ENGINEER preset 12345',
        Priority = 1020,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.ENGINEERPRESET + categories.RASPRESET } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.ENGINEERPRESET + categories.RASPRESET } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.ENGINEERPRESET + categories.RASPRESET} },
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander RAS',
        PlatoonTemplate = 'U3 SACU RAS preset 123x5',
        Priority = 1020,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 50, categories.ENGINEERPRESET + categories.RASPRESET } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.ENGINEERPRESET + categories.RASPRESET } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.ENGINEERPRESET + categories.RASPRESET} },
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander COMBAT',
        PlatoonTemplate = 'U3 SACU COMBAT preset 1x34x',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.COMBATPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.COMBATPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander NANOCOMBAT',
        PlatoonTemplate = 'U3 SACU NANOCOMBAT preset x2x4x',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.NANOCOMBATPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NANOCOMBATPRESET }},
            -- Respect UnitCap
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander BUBBLESHIELD',
        PlatoonTemplate = 'U3 SACU BUBBLESHIELD preset 1xxxx',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.BUBBLESHIELDPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.BUBBLESHIELDPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander INTELJAMMER',
        PlatoonTemplate = 'U3 SACU INTELJAMMER preset 1xxxx',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.INTELJAMMERPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.INTELJAMMERPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander SIMPLECOMBAT',
        PlatoonTemplate = 'U3 SACU SIMPLECOMBAT preset x2xxx',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.SIMPLECOMBATPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.SIMPLECOMBATPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander SHIELDCOMBAT',
        PlatoonTemplate = 'U3 SACU SHIELDCOMBAT preset x2xxx',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.SHIELDCOMBATPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.SHIELDCOMBATPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ANTIAIR',
        PlatoonTemplate = 'U3 SACU ANTIAIR preset xx3xx',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ANTIAIRPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ANTIAIRPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander STEALTH',
        PlatoonTemplate = 'U3 SACU STEALTH preset xx3xx',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STEALTHPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STEALTHPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander CLOAK',
        PlatoonTemplate = 'U3 SACU CLOAK preset xx3xx',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.CLOAKPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.CLOAKPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander MISSILE',
        PlatoonTemplate = 'U3 SACU MISSILE preset xxx4x',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.MISSILEPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MISSILEPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ADVANCEDCOMBAT',
        PlatoonTemplate = 'U3 SACU ADVANCEDCOMBAT preset xxx4x',
        Priority = 1017,
        BuilderConditions = { 
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ADVANCEDCOMBATPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ADVANCEDCOMBATPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ROCKET',
        PlatoonTemplate = 'U3 SACU ROCKET preset xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ROCKETPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ROCKETPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander ANTINAVAL',
        PlatoonTemplate = 'U3 SACU ANTINAVAL preset xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.ANTINAVALPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.ANTINAVALPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander AMPHIBIOUS',
        PlatoonTemplate = 'U3 SACU AMPHIBIOUS preset xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AMPHIBIOUSPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.AMPHIBIOUSPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander GUNSLINGER',
        PlatoonTemplate = 'U3 SACU GUNSLINGER preset  xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.GUNSLINGERPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.GUNSLINGERPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander NATURALPRODUCER',
        PlatoonTemplate = 'U3 SACU NATURALPRODUCER preset xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.NATURALPRODUCERPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.NATURALPRODUCERPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander DEFAULT',
        PlatoonTemplate = 'U3 SACU DEFAULT preset xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.DEFAULTPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.DEFAULTPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander HEAVYTROOPER',
        PlatoonTemplate = 'U3 SACU HEAVYTROOPER preset xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.HEAVYTROOPERPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.HEAVYTROOPERPRESET }},
        },
        BuilderType = 'Gate',
    },
    Builder {
        BuilderName = 'U3 SubCommander FASTCOMBAT',
        PlatoonTemplate = 'U3 SACU FASTCOMBAT preset xxxx5',
        Priority = 1017,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.10, 0.50}}, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.FASTCOMBATPRESET } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.FASTCOMBATPRESET }},
        },
        BuilderType = 'Gate',
    },
}    

-- ===================================================-======================================================== --
-- ==                                          Engineer Transfers                                            == --
-- ===================================================-======================================================== --
--[[ BuilderGroup { BuilderGroupName = 'Swarm Engineer Transfer To MainBase',
    BuildersType = 'PlatoonFormBuilder',
    -- ============================================ --
    --    Transfer from LocationType to MainBase    --
    -- ============================================ --

    Builder { BuilderName = 'U1 Engi Trans to MainBase',
        PlatoonTemplate = 'U1EngineerTransfer',
        Priority = 650,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 60 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 3,  categories.MOBILE * categories.TECH1 } },
        },
        BuilderData = {
            MoveToLocationType = 'MAIN',
        },
        BuilderType = 'Any',
    },


    Builder { BuilderName = 'U2 Engi Trans to MainBase',
        PlatoonTemplate = 'U2EngineerTransfer',
        Priority = 750,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 90 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 3,  categories.MOBILE * categories.TECH2 } },
        },
        BuilderData = {
            MoveToLocationType = 'MAIN',
        },
        BuilderType = 'Any',
    },


    Builder { BuilderName = 'U3 Engi Trans to MainBase',
        PlatoonTemplate = 'U3EngineerTransfer',
        Priority = 850,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 120 } },
            { UCBC, 'BuildNotOnLocation', { 'LocationType', 'MAIN' } },
            { UCBC, 'EngineerManagerUnitsAtLocation', { 'LocationType', '>', 3,  categories.MOBILE * categories.TECH3 } },
        },
        BuilderData = {
            MoveToLocationType = 'MAIN',
        },
        BuilderType = 'Any',
    },
} ]]--
