local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Experimental Builders',                         
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'S4 NavalExp1 Minimum',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 450,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 10, 300 } },                  

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.12, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}},           

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.MOBILE * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                BuildStructures = {
                    'T4SeaExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    
    Builder { BuilderName = 'S4 SeaExperimental1',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 500,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.LAND * categories.EXPERIMENTAL }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.ENGINEER * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },

            { UCBC, 'CanBuildCategorySwarm', { categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 10, 300 } },                  

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.13, 1.15 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.065, 0.1}}, 

            { UCBC, 'UnitCapCheckLess', { 0.99 } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                BuildStructures = {
                    'T4SeaExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },

}

-- ===================================================-======================================================== --
-- ==                                  Experimental Attack FormBuilder                                       == --
-- ===================================================-======================================================== --
-- =============== --
--    PanicZone    --
-- =============== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Experimental Formers PanicZone',                   -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'S4 BasePanicZone SEA',                                   -- Random Builder Name.
        PlatoonTemplate = 'S4-ExperimentalSea 1 1',                     -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

-- ================== --
--    MilitaryZone    --
-- ================== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Experimental Formers MilitaryZone',                -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'S4 BaseMilitaryZone Sea',                                -- Random Builder Name.
        PlatoonTemplate = 'S4-ExperimentalSea 1 1',                             -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 80,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE,                           -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

-- =============== --
--    EnemyZone    --
-- =============== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Experimental Formers EnemyZone',              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'S4 EnemyZone Sea',                                       -- Random Builder Name.
        PlatoonTemplate = 'S4-ExperimentalSea 1 1',                             -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        --PlatoonAddPlans = {'NameUnitsSorian'},
        Priority = 70,                                                          -- Priority. 1000 is normal.
        InstanceCount = 3,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE,                           -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*30 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.MOBILE  * categories.NAVAL} },
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}
-- ============ --
--    Sniper    --
-- ============ --

-- ==================== --
--    Unit Cap Trasher  --
-- ==================== --
BuilderGroup { BuilderGroupName = 'Swarm Naval Experimental Formers Trasher',                           -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'S4 SEA Trasher',                                         -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'S4-ExperimentalSea 1 1',                             -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 60,                                                          -- Priority. 1000 is normal.
        InstanceCount = 5,                                                      -- Number of plattons that will be formed.
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100000,                                       -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.ALLUNITS,                         -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'UnitCapCheckGreater', { 0.90 } },
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.EXPERIMENTAL * categories.MOBILE } },
            { UCBC, 'EnemyUnitsLessAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.ALLUNITS - categories.SCOUT }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}

