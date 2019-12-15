local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

-- ===================================================-======================================================== --
-- ==                                        Build T1 T2 T3 SEA                                              == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    
    -- =========== --
    --    TECH 1   --
    -- =========== --
    Builder { BuilderName = 'T1NavyDefaultQueue',
        PlatoonTemplate = 'T1NavyDefaultQueue',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },
        },
        BuilderType = 'Sea',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2NavyDefaultQueue',
        PlatoonTemplate = 'T2NavyDefaultQueue',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 30 } },
        },
        BuilderType = 'Sea',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3NavyDefaultQueue',
        PlatoonTemplate = 'T3NavyDefaultQueue',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 100 } },
        },
        BuilderType = 'Sea',
    },


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
        BuilderName = 'Swarm Sea Assault Small',
        PlatoonTemplate = 'Swarm Sea Attack Small',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 
            AttackEnemyStrength = 100,
            SearchRadius = BaseEnemyZone,
            UseFormation = 'GrowthFormation',
            MoveToCategories = {                                                
                categories.ALLUNITS, 
            },
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Assault Medium',
        PlatoonTemplate = 'Swarm Sea Attack Medium',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 
            AttackEnemyStrength = 100,
            SearchRadius = BaseEnemyZone,
            UseFormation = 'GrowthFormation',
            MoveToCategories = {                                                
                categories.ALLUNITS, 
            },
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Assault Large',
        PlatoonTemplate = 'Swarm Sea Attack Large',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 
            AttackEnemyStrength = 100,
            SearchRadius = BaseEnemyZone,
            UseFormation = 'GrowthFormation',
            MoveToCategories = {                                                
                categories.ALLUNITS, 
            },
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Protection Medium',
        PlatoonTemplate = 'Swarm Sea Attack Medium',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 
            AttackEnemyStrength = 100,
            SearchRadius = BaseMilitaryZone,
            UseFormation = 'GrowthFormation',
            MoveToCategories = {                                                
                categories.ALLUNITS, 
            },
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Protection Large',
        PlatoonTemplate = 'Swarm Sea Attack Large',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 
            AttackEnemyStrength = 100,
            SearchRadius = BaseMilitaryZone,
            UseFormation = 'GrowthFormation',
            MoveToCategories = {                                                
                categories.ALLUNITS, 
            },
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Defense Medium',
        PlatoonTemplate = 'Swarm Sea Attack Medium',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 
            AttackEnemyStrength = 100,
            SearchRadius = BasePanicZone,
            UseFormation = 'GrowthFormation',
            MoveToCategories = {                                                
                categories.ALLUNITS, 
            },
        },
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Swarm Sea Defense Large',
        PlatoonTemplate = 'Swarm Sea Attack Large',
        Priority = 100,
        InstanceCount = 8,
        BuilderType = 'Any',
        BuilderData = { 
            AttackEnemyStrength = 100,
            SearchRadius = BasePanicZone,
            UseFormation = 'GrowthFormation',
            MoveToCategories = {                                                
                categories.ALLUNITS, 
            },
        },
        BuilderConditions = { },
    },
}
