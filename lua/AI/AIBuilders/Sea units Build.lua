local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Uveso/lua/AI/uvesoutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 SEA                                              == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    
    -- =========== --
    --    TECH 1   --
    -- =========== --
    Builder { BuilderName = 'U1 Sea Frigate ratio',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 550,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U1 Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 535,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },
        },
        BuilderType = 'Sea',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'U2 Sea Destroyer',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 675,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 30 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U2 Sea Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 645,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 30 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U2 Sea SubKiller',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 655,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 30 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U2 Sea ShieldBoat',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 635,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 30 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U2 Sea CounterIntelBoat',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 580,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 30 } },
        },
        BuilderType = 'Sea',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'U3 Sea Battleship',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 750,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 100 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U3 Sea NukeSub',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 725,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 100 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U3 Sea MissileBoat',
        PlatoonTemplate = 'T3MissileBoat',
        Priority = 725,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 100 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U3 Sea SubKiller',
        PlatoonTemplate = 'T3SubKiller',
        Priority = 740,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 100 } },
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'U3 Sea Battlecruiser',
        PlatoonTemplate = 'T3Battlecruiser',
        Priority = 745,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 100 } },
        },
        BuilderType = 'Sea',
    },
}

-- ===================================================-======================================================== --
-- ==                                            Sonar  builder                                              == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Sonar Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U1 Sonar',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 17500,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, (categories.SONAR * categories.STRUCTURE - categories.TECH3) + (categories.MOBILESONAR * categories.TECH3) } }, -- TECH3 sonar is MOBILE not STRUCTURE!!!
            -- Do we need additional conditions to build it ?
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.ENERGYPRODUCTION,
                AdjacencyDistance = 50,
                BuildStructures = {
                    'T1Sonar',
                },
                Location = 'LocationType',
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Sonar Upgraders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'U1 Sonar Upgrade',
        PlatoonTemplate = 'T1SonarUpgrade',
        Priority = 200,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SONAR * categories.TECH1}},
            -- Do we need additional conditions to build it ?
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
    
    Builder { BuilderName = 'U2 Sonar Upgrade',
        PlatoonTemplate = 'T2SonarUpgrade',
        Priority = 300,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SONAR * categories.TECH2}},
            -- Do we need additional conditions to build it ?
            { MIBC, 'FactionIndex', { 1, 2, 3, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } }, -- relative income
            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.99 } },             -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                      NAVAL T1 T2 T3 Formbuilder                                        == --
-- ===================================================-======================================================== --
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Formers',                            -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Swarm Sea Attack Small',
        PlatoonTemplate = 'Swarm Sea Attack Small',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 

            UseFormation = 'GrowthFormation',

        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Attack Medium',
        PlatoonTemplate = 'Swarm Sea Attack Small',
        Priority = 101,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 

            UseFormation = 'GrowthFormation',

        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Attack Large',
        PlatoonTemplate = 'Swarm Sea Attack Small',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 

            UseFormation = 'GrowthFormation',

        },
        BuilderConditions = { },
    },
}
