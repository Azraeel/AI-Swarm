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
        Priority = 10000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 10 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.SCOUT } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.SCOUT } },
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
    Builder { BuilderName = 'T1LandDefaultQueue',
        PlatoonTemplate = 'T1LandDefaultQueue',
        Priority = 500,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.SUPPORTFACTORY * categories.TECH2 * categories.LAND }},

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2LandDefaultQueue',
        PlatoonTemplate = 'T2LandDefaultQueue',
        Priority = 700,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.SUPPORTFACTORY * categories.TECH3 * categories.LAND }},

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U2 Amphibious',
        PlatoonTemplate = 'U2 LandSquads Amphibious',
        Priority = 300,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.TECH1} },     
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3LandDefaultQueue',
        PlatoonTemplate = 'T3LandDefaultQueue',
        Priority = 800,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U3 Amphibious',
        PlatoonTemplate = 'U3 LandSquads Amphibious',
        Priority = 400,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.TECH1} },     
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
        Priority = 5000,
        InstanceCount = 8,
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
        BuilderName = 'AISwarm LandAttack Default',
        PlatoonTemplate = 'AISwarm LandAttack Default', 
        Priority = 100,
        InstanceCount = 4,
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
        BuilderName = 'AISwarm Assault Small',
        PlatoonTemplate = 'AISwarm LandAttack Small', 
        Priority = 100,
        InstanceCount = 5,
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
        BuilderName = 'AISwarm Assault Medium',
        PlatoonTemplate = 'AISwarm LandAttack Medium', 
        Priority = 100,
        InstanceCount = 5,
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
        BuilderName = 'AISwarm Assault Large',
        PlatoonTemplate = 'AISwarm LandAttack Large', 
        Priority = 100,
        InstanceCount = 5,
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
        BuilderName = 'AISwarm Expansion Land Protection Medium',
        PlatoonTemplate = 'AISwarm LandAttack Medium', 
        Priority = 100,
        InstanceCount = 5,
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
        BuilderName = 'AISwarm Expansion Land Protection Large',
        PlatoonTemplate = 'AISwarm LandAttack Large', 
        Priority = 100,
        InstanceCount = 5,
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
        BuilderName = 'AISwarm Last Defense Panic Medium',
        PlatoonTemplate = 'AISwarm LandAttack Medium', 
        Priority = 100,
        InstanceCount = 5,
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
        BuilderName = 'AISwarm Last Defense Panic Large',
        PlatoonTemplate = 'AISwarm LandAttack Large', 
        Priority = 100,
        InstanceCount = 5,
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
        BuilderName = 'AISwarm LandAttack EZ Raid',
        PlatoonTemplate = 'AISwarm LandAttack Raid', 
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = {
            SearchRadius = BaseEnemyZone, 
            AttackEnemyStrength = 50,
            TargetSearchCategory = categories.MASSEXTRACTION * categories.MASSFABRICATION * categories.ENERGYPRODUCTION,          
            MoveToCategories = {                                                
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION, 
            },
            WeaponTargetCategories = {                                          
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.MASSFABRICATION,
                categories.ALLUNITS,
            },
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack MZ Raid',
        PlatoonTemplate = 'AISwarm LandAttack Raid', 
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderData = {
            SearchRadius = BaseMilitaryZone, 
            AttackEnemyStrength = 50,
            TargetSearchCategory = categories.MASSEXTRACTION * categories.MASSFABRICATION * categories.ENERGYPRODUCTION,          
            MoveToCategories = {                                                
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION, 
            },
            WeaponTargetCategories = {                                          
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.MASSFABRICATION,
                categories.ALLUNITS,
            },
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Base Siege',
        PlatoonTemplate = 'AISwarm LandAttack Base Siege', 
        Priority = 100,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            AttackEnemyStrength = 10000,
            SearchRadius = BaseEnemyZone,
            AggressiveMove = true,
            TargetSearchCategory = categories.STRUCTURE,
            MoveToCategories = {                                                
                categories.STRUCTURE, 
            }, 
            WeaponTargetCategories = {                                          
                categories.SHIELD,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.MASSFABRICATION,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },        
        BuilderConditions = { },
    },
}
