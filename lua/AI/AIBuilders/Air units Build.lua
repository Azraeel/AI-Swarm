local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ================================================================================== --
-- ==                                 Air Unit Builders                               == --
-- ================================================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Air Builders',
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder { BuilderName = 'T1AirDefaultQueue',
        PlatoonTemplate = 'T1AirDefaultQueue',
        Priority = 500,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T2AirDefaultQueue',
        PlatoonTemplate = 'T2AirDefaultQueue',
        Priority = 600,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },
        },
        BuilderType = 'Air',
    },

    Builder { BuilderName = 'T3AirDefaultQueue',
        PlatoonTemplate = 'T3AirDefaultQueue',
        Priority = 700,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },
        },
        BuilderType = 'Air',
    },
}




BuilderGroup { BuilderGroupName = 'Swarm Air Transport Builders',
    BuildersType = 'FactoryBuilder',
    -- ============= --
    --    AllMaps    --
    -- ============= --
    Builder { BuilderName = 'U1 Air Transport 1st',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 300, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 8, 40 } },

            { UCBC, 'HaveLessThanArmyPoolWithCategory', { 3, categories.TRANSPORTATION} },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U1 Air Transport',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 150, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 8, 40 } },

            { UCBC, 'HaveLessThanArmyPoolWithCategory', { 1, categories.TRANSPORTATION} },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U2 Air Transport',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 200,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 40, 600 } },

            { UCBC, 'HaveLessThanArmyPoolWithCategory', { 1, categories.TRANSPORTATION} },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U3 Air Transport',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 250,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 65, 2000 } },

            { UCBC, 'HaveLessThanArmyPoolWithCategory', { 2, categories.TRANSPORTATION} },
       },
        BuilderType = 'Air',
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Air Scout Builders',
    BuildersType = 'FactoryBuilder',
    Builder { BuilderName = 'U1 Air Scout',
        PlatoonTemplate = 'T1AirScout',
        Priority = 10000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 8, 40 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.SCOUT } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.AIR * categories.SCOUT } },
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'U3 Air Scout',
        PlatoonTemplate = 'T3AirScout',
        Priority = 20000,
        DelayEqualBuildPlattons = {'Scouts', 10},
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 8, 40 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.SCOUT } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, categories.AIR * categories.SCOUT } },
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


BuilderGroup { BuilderGroupName = 'Swarm Air Formers',
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    
    Builder {
        BuilderName = 'AISwarm AirAttack Bombers',
        PlatoonTemplate = 'BomberAttack',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'GrowthFormation', 
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Fighters',
        PlatoonTemplate = 'AirAttack',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = { 
           UseFormation = 'GrowthFormation', 
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

    Builder {
        BuilderName = 'AISwarm AirAttack Gunship Raid',
        PlatoonTemplate = 'GunshipMassHunter',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = { 
            UseFormation = 'GrowthFormation',
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
                'MASSFABRICATION',
            },        
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm AirAttack Bomber Raid',
        PlatoonTemplate = 'MassHunterBomber',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = {
        	UseFormation = 'GrowthFormation', 
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
                'MASSFABRICATION',
            },       
        },
        BuilderConditions = { },
    },
}