local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii(true)

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

if not categories.STEALTHFIELD then categories.STEALTHFIELD = categories.SHIELD end

-- ===================================================-======================================================== --
--                                           LAND Scouts Builder                                                --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Scout Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    
    Builder { BuilderName = 'U1R Land Scout',
        PlatoonTemplate = 'T1LandScout',
        Priority = 1014,
        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 260 } }, 

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.MOBILE * categories.SCOUT - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },
}

-- ===================================================-======================================================== --
-- ==                                         Land ratio builder Normal                                      == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Builders Ratio',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder { BuilderName = 'T1 Land Opening Queue',
        PlatoonTemplate = 'T1LandOpeningQueue',
        Priority = 1010, -- Early Game Unit Coverage
        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 60 * 4 } }, -- don't build after 3 minutes

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = 'Land', 
    },

    Builder { BuilderName = 'T1LandDFTank - Swarm',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandArtillery - Swarm',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.INDIRECTFIRE * categories.LAND }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandAA - Swarm',
        PlatoonTemplate = 'T1LandAA',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR }},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.ANTIAIR } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandAA - Swarm - Reactive',
        PlatoonTemplate = 'T1LandAA',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 5, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 3, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2LandDFTank - Swarm',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2AttackTank - Swarm',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandArtillery - Swarm',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.INDIRECTFIRE * categories.LAND * categories.TECH2 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH2 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2MobileShields - Swarm',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH2 - categories.ENGINEER }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND * categories.SHIELD }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandAA - Swarm',
        PlatoonTemplate = 'T2LandAA',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH2 - categories.ENGINEER }},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.ANTIAIR } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandAA - Swarm - Reactive',
        PlatoonTemplate = 'T2LandAA',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 1, 20 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 5, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH2 - categories.ENGINEER }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.ANTIAIR } },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3ArmoredAssault - Swarm',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandBot - Swarm',
        PlatoonTemplate = 'T3LandBotSwarm',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3SniperBots - Swarm',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.SNIPER * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandArtillery - Swarm',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3MobileMissile - Swarm',
        PlatoonTemplate = 'T3MobileMissile',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandAA - Swarm',
        PlatoonTemplate = 'T3LandAA',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3 } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandAA - Swarm - Reactive',
        PlatoonTemplate = 'T3LandAA',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 5, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3 } },
        },
        BuilderType = 'Land',
    },
}

-- ===================================================-======================================================== --
--                                         Land Scouts Formbuilder                                              --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Scout Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'Swarm Land Scout',
        PlatoonTemplate = 'T1LandScoutForm',
        Priority = 10000,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.LAND * categories.SCOUT } },
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                         Land Formbuilder                                               == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'AISwarm Platoon Builder',
    BuildersType = 'PlatoonFormBuilder', -- A PlatoonFormBuilder is for builder groups of units.

    Builder {
        BuilderName = 'AI-Swarm Base Response - Intelli',                                        
        PlatoonTemplate = 'AISwarm Intercept',                       
        Priority = 300,                                                       
        InstanceCount = 1,                                                     
        BuilderData = {
            SearchRadius = BasePanicZone,                                       
            GetTargetsFromBase = true,                                          
            RequireTransport = false,                                           
            AggressiveMove = true,                                             
            AttackEnemyStrength = 100000000,                                    
            IgnorePathing = true,                                               
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        
            MoveToCategories = {                                             
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {    
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BasePanicZone, 'LocationType', 0, categories.MOBILE - categories.SCOUT }}, 
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AI-Swarm Standard Land (80) M',
        PlatoonTemplate = 'AISwarm LandAttack Micro - Standard', 
        Priority = 650,
        InstanceCount = 4,
        BuilderType = 'Any',
        BuilderConditions = { 
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderData = {
            AttackEnemyStrength = 80,
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = false,
            RequireTransport = false, 
            AggressiveMove = true, 
            IgnorePathing = false,
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT,                        
            MoveToCategories = {
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS,
            },
        },        
    },

    Builder {
        BuilderName = 'AI-Swarm Standard Land (120) M',
        PlatoonTemplate = 'AISwarm LandAttack Micro - Standard', 
        Priority = 650,
        InstanceCount = 4,
        BuilderType = 'Any',
        BuilderConditions = { 
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderData = {
            AttackEnemyStrength = 120,
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = false,
            RequireTransport = false, 
            AggressiveMove = true, 
            IgnorePathing = false,
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT,                        
            MoveToCategories = {
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS,
            },
        },        
    },

    Builder {
        BuilderName = 'AI-Swarm Standard Land (80) E',
        PlatoonTemplate = 'AISwarm LandAttack Micro - Standard', 
        Priority = 650,
        InstanceCount = 4,
        BuilderType = 'Any',
        BuilderConditions = { 
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseEnemyZone, 'LocationType', 0, categories.MOBILE - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderData = {
            AttackEnemyStrength = 80,
            SearchRadius = BaseEnemyZone,
            GetTargetsFromBase = false,
            RequireTransport = false, 
            AggressiveMove = true, 
            IgnorePathing = false,
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE - categories.SCOUT,                        
            MoveToCategories = {
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },        
    },

    Builder {
        BuilderName = 'AI-Swarm Standard Land (120) E',
        PlatoonTemplate = 'AISwarm LandAttack Micro - Standard', 
        Priority = 650,
        InstanceCount = 4,
        BuilderType = 'Any',
        BuilderConditions = { 
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadius', {  BaseEnemyZone, 'LocationType', 0, categories.MOBILE - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderData = {
            AttackEnemyStrength = 120,
            SearchRadius = BaseEnemyZone,
            GetTargetsFromBase = false,
            RequireTransport = false, 
            AggressiveMove = true, 
            IgnorePathing = false,
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE - categories.SCOUT,                        
            MoveToCategories = {
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },        
    },
}

BuilderGroup {
    BuilderGroupName = 'S3 SACU Formers',                              
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'S3 Teleport 1',
        PlatoonTemplate = 'S3 SACU Teleport 1 1',
        Priority = 21000,
        InstanceCount = 2,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.TECH3,
                categories.STRUCTURE * categories.SHIELD * categories.TECH3,
                categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 1000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's

            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.SUBCOMMANDER} },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 1 , categories.STRUCTURE } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S3 Teleport 3',
        PlatoonTemplate = 'S3 SACU Teleport 3 3',
        Priority = 21000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.TECH3,
                categories.STRUCTURE * categories.SHIELD * categories.TECH3,
                categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 3000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's

            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 3, categories.SUBCOMMANDER} },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 1 , categories.STRUCTURE } },
        },
        BuilderType = 'Any',
    },
     
    Builder {
        BuilderName = 'S3 SACU CAP 3 7',
        PlatoonTemplate = 'S3 SACU Fight 3 7',
        Priority = 500,
        InstanceCount = 4,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 3, categories.SUBCOMMANDER} },
        },
        BuilderType = 'Any',
    },
}

BuilderGroup {
    BuilderGroupName = 'Swarm AI Defense Formers',                         
    BuildersType = 'PlatoonFormBuilder',
    
    Builder {
        BuilderName = 'AISwarm Raid Early Game',
        PlatoonTemplate = 'AISwarm Mass Raid',
        Priority = 1000,
        BuilderConditions = {  
                { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

                { UCBC, 'LessThanGameTimeSeconds', { 240 } },

                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND }},      	
            },
        BuilderData = {
            MarkerType = 'Mass',            
            MoveFirst = 'Random',
            MoveNext = 'Threat',
            ThreatType = 'Economy',			    -- Type of threat to use for gauging attacks
            FindHighestThreat = true,			-- Don't find high threat targets
            MaxThreatThreshold = 2900,			-- If threat is higher than this, do not attack
            MinThreatThreshold = 1000,			-- If threat is lower than this, do not attack
            AvoidBases = false,
            AvoidBasesRadius = 75,
            AggressiveMove = true,      
            AvoidClosestRadius = 50,  
        },    
        InstanceCount = 2,
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'Swarm Mass Raid Large',                            
        PlatoonTemplate = 'AISwarm Mass Raid Large',                         
        Priority = 690,                                                      
        InstanceCount = 4,                                                     
        BuilderType = 'Any',
        BuilderConditions = {   
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'GreaterThanGameTimeSeconds', { 300 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND - categories.ENGINEER } },
        },
        BuilderData = {
            IncludeWater = false,
            IgnoreFriendlyBase = true,
            MaxPathDistance = BaseEnemyZone, 
            FindHighestThreat = true,			
            MaxThreatThreshold = 4900,		
            MinThreatThreshold = 1000,		    
            AvoidBases = true,
            AvoidBasesRadius = 75,
            AggressiveMove = true,      
            AvoidClosestRadius = 100,
            UseFormation = 'None',
        },
    },

    --[[ Builder {
        BuilderName = 'AISwarm Start Locations',
        PlatoonTemplate = 'AISwarm - Guard Marker - Pressure',
        PlatoonAddPlans = {'PlatoonCallForHelpAISwarm', 'DistressResponseAISwarm'},
        Priority = 540,
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'GreaterThanGameTimeSeconds', { 540 } }, 
        },
        BuilderData = {
            ThreatSupport = 75,
            DistressRange = 50,
            UseFormation = 'GrowthFormation',
            MarkerType = 'Start Location',
            MoveFirst = 'Random',
            MoveNext = 'Random',
            -- ThreatType = 'Economy', 		    
            -- FindHighestThreat = false, 		
            -- MaxThreatThreshold = 2900, 		
            -- MinThreatThreshold = 1000, 		
            AvoidBases = true,
            AvoidBasesRadius = 60,
            AggressiveMove = true,
            AvoidClosestRadius = 20,
            GuardTimer = 40,
        },
        InstanceCount = 1,
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'Base Response - AI-Swarm',
        PlatoonTemplate = 'AISwarm - Guard Base',
        Priority =  490,
        BuilderConditions = {
            { MIBC, 'GreaterThanGameTime', { 600 } },  
        },
        BuilderData = {
            LocationType = 'LocationType',
        },
        InstanceCount = 1,
        BuilderType = 'Any',
    }, ]]--
}

BuilderGroup {
    BuilderGroupName = 'Swarm AI United Land Formers',                         
    BuildersType = 'PlatoonFormBuilder', 

    --[[ Builder {
        BuilderName = 'AI-Swarm Attack Force - United Land - Small',
        PlatoonTemplate = 'AI-Swarm Attack Force - United Land - Small',
        PlatoonAddPlans = {'PlatoonCallForHelpAISwarm', 'DistressResponseAISwarm'},
        Priority = 700,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            ThreatSupport = 75,
            DistressRange = 50,
            NeverGuardBases = false,
            NeverGuardEngineers = true,
			UseFormation = 'GrowthFormation',
			AggressiveMove = true,
            ThreatWeights = {
                PrimaryTargetThreatType = 'Land',
                PrimaryThreatWeight = 20,
                SecondaryTargetThreatType = 'Economy',
                SecondaryThreatWeight = 8.5,
                WeakAttackThreatWeight = 2,
                StrongAttackThreatWeight = 15,
                IgnoreThreatLessThan = 3,
                IgnoreCommanderStrength = true,
                EnemyThreatRings = 1,
                TargetCurrentEnemy = false,
            },
        },        
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },
        },
    },

    Builder {
        BuilderName = 'AI-Swarm Attack Force - United Land - Large',
        PlatoonTemplate = 'AI-Swarm Attack Force - United Land - Large',
        PlatoonAddPlans = {'PlatoonCallForHelpAISwarm', 'DistressResponseAISwarm'},
        Priority = 700,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            ThreatSupport = 75,
            DistressRange = 50,
            NeverGuardBases = false,
            NeverGuardEngineers = true,
			UseFormation = 'GrowthFormation',
			AggressiveMove = true,
            ThreatWeights = {
                PrimaryTargetThreatType = 'Land',
                PrimaryThreatWeight = 14,
                SecondaryTargetThreatType = 'Economy',
                SecondaryThreatWeight = 10,
                WeakAttackThreatWeight = 1,
                StrongAttackThreatWeight = 19,
                IgnoreThreatLessThan = 5,
                IgnoreCommanderStrength = true,
                EnemyThreatRings = 1,
                TargetCurrentEnemy = false,
            },
        },        
        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },
        },
    }, ]]--
}

