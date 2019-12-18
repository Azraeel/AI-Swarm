local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

-- ===================================================-======================================================== --
-- ==                                 Mobile Experimental Land/Air/Sea                                       == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Experimental Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'U4 LandExperimental3',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.EXPERIMENTAL * categories.LAND}},   	

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 300 } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                BuildStructures = {
                    'T4LandExperimental3',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U4 LandExperimental2',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.EXPERIMENTAL * categories.LAND}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 300 } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = false,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                BuildStructures = {
                    'T4LandExperimental2',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'U4 LandExp1',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.EXPERIMENTAL * categories.LAND}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 300 } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = true,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                BuildStructures = {
                    'T4LandExperimental1',
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
BuilderGroup { BuilderGroupName = 'Swarm Land Experimental Formers',              -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',   
    Builder {
        BuilderName = 'AISwarm LandAttack EZ Experimental',                                  -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'AISwarm LandAttack Experimental',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 100,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                      -- Number of plattons that will be formed
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'AISwarm LandAttack MZ Experimental',                                  -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'AISwarm LandAttack Experimental',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 100,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                      -- Number of plattons that will be formed
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'AISwarm LandAttack MZ Experimental',                                  -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'AISwarm LandAttack Experimental',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 100,                                                          -- Priority. 1000 is normal.
        InstanceCount = 10,                                                      -- Number of plattons that will be formed
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
}
