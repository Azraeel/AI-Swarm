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
    Builder { BuilderName = 'T1SeaFrigate - Swarm',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 10 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.FRIGATE * categories.NAVAL }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T1SeaSub - Swarm',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2, 10 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.T1SUBMARINE * categories.NAVAL }},
        },
        BuilderType = 'Sea',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2SeaDestroyer - Swarm',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

        	{ EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 40 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.DESTROYER * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T2SeaCruiser - Swarm',
        PlatoonTemplate = 'T2SeaCruiser',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 40 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.CRUISER * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T2SubKiller - Swarm',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 40 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.T2SUBMARINE * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T2ShieldBoat - Swarm',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 40 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.SHIELD * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T2CounterIntelBoat - Swarm',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 4, 40 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.STEALTH * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Sea',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3SeaBattleship - Swarm',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

        	{ EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.BATTLESHIP * categories.NAVAL * categories.TECH3 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T3Battlecruiser - Swarm',
        PlatoonTemplate = 'T3Battlecruiser',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.CRUISER * categories.NAVAL * categories.TECH3 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T3SubKiller - Swarm',
        PlatoonTemplate = 'T3SubKiller',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.SUBMERSIBLE * categories.NAVAL * categories.TECH3 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T3MissileBoat - Swarm',
        PlatoonTemplate = 'T3MissileBoat',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 100 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.BATTLESHIP * categories.INDIRECTFIRE * categories.NAVAL * categories.TECH3 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T3SeaNukeSub - Swarm',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'CanPathNavalBaseToNavalTargets', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.NAVAL }},

            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 20, 200 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.NUKE * categories.NAVAL }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.NUKE * categories.NAVAL * categories.TECH3 }},
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
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.90 } },
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
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
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
            { EBC, 'GreaterThanEconStorageRatio', { 0.90, 0.90 } },             -- Ratio from 0 to 1. (1=100%)
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
BuilderGroup { BuilderGroupName = 'Swarm Naval Formers',                            
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Swarm PANIC AntiSea',                                     
        PlatoonTemplate = 'Swarm Sea Attack',                          
        Priority = 100,                                                         
        InstanceCount = 5,                                                     
        BuilderData = {
            SearchRadius = BasePanicZone,                                      
            AggressiveMove = true,                                             
            AttackEnemyStrength = 100,                                    
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE }}, 
        },
        BuilderType = 'Any',                                                 
    },

    Builder {
        BuilderName = 'Swarm Military AntiSea',                              
        PlatoonTemplate = 'Swarm Sea Attack',                       
        Priority = 100,                                                         
        InstanceCount = 6,                                                    
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                  
            AggressiveMove = true,                                             
            AttackEnemyStrength = 100,                                        
            TargetSearchCategory = categories.MOBILE,                           
            MoveToCategories = {                                               
                categories.NAVAL * categories.DEFENSE,
                categories.MOBILE * categories.NAVAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE }}, 
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Enemy AntiSea Kill early',
        PlatoonTemplate = 'Swarm Sea Attack',
        Priority = 100,
        InstanceCount = 3,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                    
            AggressiveMove = true,                                              
            AttackEnemyStrength = 200,                                         
            TargetSearchCategory = categories.MOBILE + categories.STRUCTURE,   
            MoveToCategories = {                                                
                categories.STRUCTURE,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                 
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'Swarm Enemy Sea AntiStructure',
        PlatoonTemplate = 'Swarm Sea Attack',
        Priority = 100,
        InstanceCount = 3,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       
            AggressiveMove = true,                                             
            AttackEnemyStrength = 100,                                          
            TargetSearchCategory = categories.STRUCTURE * categories.NAVAL,     
            MoveToCategories = {                                              
                categories.MOBILE * categories.NAVAL * categories.DEFENSE,
                categories.STRUCTURE * categories.NAVAL,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE * categories.NAVAL } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'Swarm Enemy Sea AntiMobile',
        PlatoonTemplate = 'Swarm Sea Attack',
        Priority = 100,
        InstanceCount = 8,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                   
            AggressiveMove = true,                                            
            AttackEnemyStrength = 100,                                        
            TargetSearchCategory = categories.MOBILE * categories.NAVAL,       
            MoveToCategories = {                                               
                categories.MOBILE * categories.NAVAL,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.MOBILE * categories.NAVAL } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'Swarm Enemy AntiNavalFactories',
        PlatoonTemplate = 'Swarm Sea Attack',
        Priority = 100,
        InstanceCount = 2,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       
            AggressiveMove = true,                                             
            AttackEnemyStrength = 100,                                      
            TargetSearchCategory = categories.STRUCTURE * categories.FACTORY * categories.NAVAL, 
            MoveToCategories = {                                               
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 10, categories.MOBILE * categories.NAVAL } },
            { UCBC, 'UnitsGreaterAtEnemy', { 1 , categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'Nuke Submarine Active NukeAI',
        PlatoonTemplate = 'Swarm SeaNuke',
        PlatoonAddPlans = { 'NukePlatoonAI', },
        Priority = 100,
        InstanceCount = 20,
        BuilderType = 'Any',
        BuilderData = {
            UseFormation = 'AttackFormation',
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0, 
                PrimaryThreatTargetType = 'Naval',
                SecondaryThreatTargetType = 'Economy',
                SecondaryThreatWeight = 0.1,
                WeakAttackThreatWeight = 1,
                VeryNearThreatWeight = 10,
                NearThreatWeight = 5,
                MidThreatWeight = 1,
                FarThreatWeight = 1,
            },
        },
        BuilderConditions = { },
    },
}