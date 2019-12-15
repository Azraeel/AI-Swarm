local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

-- ===================================================-======================================================== --
-- ==                                      Mobile Experimental Air                                           == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Air Experimental Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
        
    Builder { BuilderName = 'U4 AirExp1',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 950,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 400 } },
       },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                DesiresAssist = true,
                BuildClose = true,
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    
    Builder { BuilderName = 'U4 Satellite',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 10, 400 } },

            { MIBC, 'GreaterThanGameTime', { 3600 } },
        },
        BuilderType = 'Any',
        BuilderData = {
        	NumAssistees = 40,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T4SatelliteExperimental',
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
BuilderGroup { BuilderGroupName = 'Swarm Air Experimental Formers',               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'AISwarm AirAttack EZ Experimental',                                  -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'AISwarm AirAttack Experimental',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 100,                                                          -- Priority. 1000 is normal.
        InstanceCount = 100,                                                      -- Number of plattons that will be formed
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'AISwarm AirAttack MZ Experimental',                                  -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'AISwarm AirAttack Experimental',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 100,                                                          -- Priority. 1000 is normal.
        InstanceCount = 100,                                                      -- Number of plattons that will be formed
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
    Builder {
        BuilderName = 'AISwarm AirAttack PZ Experimental',                                  -- Random Builder Name.
        --PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonTemplate = 'AISwarm AirAttack Experimental',                            -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates"
        Priority = 100,                                                          -- Priority. 1000 is normal.
        InstanceCount = 100,                                                      -- Number of plattons that will be formed
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 150,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.ALLUNITS - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
}


