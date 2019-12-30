local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ================================================================================== --
-- ==                                 Air Unit Builders                               == --
-- ================================================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Air Builders',
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder { BuilderName = 'T1AirScout - Swarm',
        PlatoonTemplate = 'T1AirScout',
        Priority = 505,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.AIR * categories.MOBILE * categories.SCOUT }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.AIR * categories.MOBILE * categories.SCOUT } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirFighter - Swarm',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 20, categories.AIR * categories.MOBILE * categories.ANTIAIR }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1AirBomber - Swarm',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.AIR * categories.MOBILE * categories.BOMBER }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T1Gunship - Swarm',
        PlatoonTemplate = 'T1Gunship',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.AIR * categories.MOBILE * categories.GROUNDATTACK }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2FighterBomber - Swarm',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 16, categories.AIR * categories.MOBILE * categories.ANTIAIR * categories.BOMBER * categories.TECH2 }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T2AirGunship - Swarm',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.AIR * categories.MOBILE * categories.GROUNDATTACK * categories.TECH2 }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --

    Builder { BuilderName = 'T3AirScout - Swarm',
        PlatoonTemplate = 'T3AirScout',
        Priority = 705,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.AIR * categories.MOBILE * categories.SCOUT * categories.TECH3 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.AIR * categories.MOBILE * categories.SCOUT * categories.TECH3 } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirFighter - Swarm',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 30, categories.AIR * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirGunship - Swarm',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 9, categories.AIR * categories.MOBILE * categories.GROUNDATTACK * categories.TECH3 }},
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirBomber - Swarm',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.AIR * categories.MOBILE * categories.BOMBER * categories.TECH3 }},
        },
        BuilderType = 'Air',
    },

    -- ============ --
    --   TRANSPORT  --
    -- ============ --

    Builder { BuilderName = 'U1 Air Transport - Swarm',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 550, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.TRANSPORTATION } },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U2 Air Transport - Swarm',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.TRANSPORTATION } },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U3 Air Transport - Swarm',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 750,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

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
    Builder { BuilderName = 'U1 Air Scout Form',
        PlatoonTemplate = 'T1AirScoutForm',
        Priority = 10000,
        InstanceCount = 3,
        BuilderConditions = {
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.SCOUT } },
        },
        BuilderType = 'Any',
    },


    Builder { BuilderName = 'U3 Air Scout Form',
        PlatoonTemplate = 'T3AirScoutForm',
        PlatoonAddBehaviors = { 'AirUnitRefit' },
        Priority = 20000,
        InstanceCount = 5,
        BuilderConditions = {
            -- When do we want to form this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.INTELLIGENCE } },
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
--                                          Air Formbuilder                                                     --
-- ===================================================-======================================================== --

BuilderGroup { BuilderGroupName = 'Swarm Air Formers',
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    
    Builder {
        BuilderName = 'AISwarm AirAttack Bombers Mass',
        PlatoonTemplate = 'BomberAttack',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'NoFormation',
           PrioritizedCategories = {
                'MASSEXTRACTION',
                'MASSFABRICATION',
                'ENGINEER',
                'MOBILE ANTIAIR',
                'MOBILE LAND',
                'ALLUNITS',
            }, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Bombers Energy',
        PlatoonTemplate = 'BomberAttack',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'NoFormation',
           PrioritizedCategories = {
                'ENERGYPRODUCTION',
                'ENGINEER',
                'MOBILE ANTIAIR',
                'MOBILE LAND',
                'ALLUNITS',
            }, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Bombers Units',
        PlatoonTemplate = 'BomberAttack',
        Priority = 100,
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'NoFormation',
           PrioritizedCategories = {
                'MOBILE LAND',
                'MOBILE ANTIAIR',
                'ENGINEER',
                'ALLUNITS',
            }, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Snipe - T3 - Anti-Resource',
        PlatoonTemplate = 'SpecialOpsBomberAttack',
        Priority = 100,
        InstanceCount = 4,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'NoFormation',
           PrioritizedCategories = {
                'ENERGYPRODUCTION',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            }, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Snipe - T3 - Structure',
        PlatoonTemplate = 'SpecialOpsBomberAttack',
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'NoFormation',
           PrioritizedCategories = {
                'EXPERIMENTAL STRUCTURE',
                'STRATEGIC ARTILLERY',
                'SILO NUKE',
                'SILO ANTIMISSLE',
                'COMMAND',
                'ENERGYPRODUCTION',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            }, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Snipe - T3 - Anti-Land',
        PlatoonTemplate = 'SpecialOpsBomberAttack',
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'NoFormation',
           PrioritizedCategories = {
                'COMMAND',
                'EXPERIMENTAL LAND',
                'SUBCOMMANDER',
                'MOBILE LAND TECH3',
                'MOBILE LAND TECH2',
                'MOBILE LAND TECH1',
                'ALLUNITS',
            }, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Fighters',
        PlatoonTemplate = 'AirAttack',
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'GrowthFormation',
           PrioritizedCategories = {
                'MOBILE AIR',
                'ALLUNITS',
            }, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Threat Fighters',
        PlatoonTemplate = 'AirAttackThreat',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = { 
           ThreatThreshold = 100, 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm Gunship Attack',
        PlatoonTemplate = 'GunshipAttack',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = { 
        	UseFormation = 'GrowthFormation', 
        },
        BuilderConditions = { },
    },
}