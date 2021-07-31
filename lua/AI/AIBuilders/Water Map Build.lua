local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii(true)

local MaxCapFactory = 0.5 -- 0.5% of all units can be factories (STRUCTURE * FACTORY)

-- WaterMap Builders are just generally outdated, all of this needs a complete rewrite and cleaning.
-- Add a Watermap Ratio Condition to replace CanPathTo


BuilderGroup { BuilderGroupName = 'Swarm Transports - Water Map',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',

    Builder { BuilderName = 'S1 Air Transport - Water Map - 20km',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 550, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.1, 1.12 }},

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { MIBC, 'MapGreaterThanSwarm', { 1023, 1023 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType',  1, categories.AIR * categories.TRANSPORTATION }},
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S2 Air Transport - Water Map - 20km',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.15, 1.2 }},

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { MIBC, 'MapGreaterThanSwarm', { 1023, 1023 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType',  1, categories.AIR * categories.TRANSPORTATION }}
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S3 Air Transport - Water Map - 20km',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 750,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.2, 1.25 }},

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { MIBC, 'MapGreaterThanSwarm', { 1023, 1023 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType',  1, categories.AIR * categories.TRANSPORTATION }}
       },
        BuilderType = 'Air',
    }, 
}

BuilderGroup { BuilderGroupName = 'Swarm Land Builders - Water Map',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',

    Builder { BuilderName = 'Swarm LandSquads Amphibious 1',
        PlatoonTemplate = 'S1 LandSquads Amphibious',
        Priority = 500,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.02, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType',  5, categories.LAND * categories.TECH1 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.TECH1 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)} },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'Swarm LandSquads Amphibious 2',
        PlatoonTemplate = 'S2 LandSquads Amphibious',
        Priority = 700,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.85, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType',  5, categories.LAND * categories.TECH2 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.TECH2 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)} },
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'Swarm LandSquads Amphibious 3',
        PlatoonTemplate = 'S3 LandSquads Amphibious',
        Priority = 900,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.07, 0.1}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType',  8, categories.LAND * categories.TECH3 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.TECH3 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},
        },
        BuilderType = 'Land',
    },
}

BuilderGroup { 
    BuilderGroupName = 'Swarm Factory Builder - Water Map',
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'Swarm Commander Factory Builder Air - Watermap',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 575,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.AIR * categories.FACTORY * (categories.TECH1 + categories.TECH2 + categories.TECH3)  }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
                Location = 'LocationType',
                BuildStructures = {
                   'T1AirFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Land - Watermap',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 600,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } }, 

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Air - Watermap',
        PlatoonTemplate = 'EngineerBuilderALLTECH',
        Priority = 600,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.50}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'Swarm Amphibious Formers',                     -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',                                        -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.
    Builder {
        BuilderName = 'S123 Amphibious PANIC 1 10',                             -- Random Builder Name.
        PlatoonTemplate = 'S123 Amphibious 1 10',                               -- Template Name. These units will be formed. 
        Priority = 100,                                                       -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 12,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE + categories.STRUCTURE}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
                                       
    Builder {
        BuilderName = 'S123 Amphibious Military 1 10',                          -- Random Builder Name.
        PlatoonTemplate = 'S123 Amphibious 1 10',                               -- Template Name. These units will be formed. 
        Priority = 90,                                                          -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 80,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.MOBILE + categories.STRUCTURE}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

    Builder {
        BuilderName = 'S123 Amphibious Enemy 1 10',                             -- Random Builder Name.
        PlatoonTemplate = 'S123 Amphibious 1 10',                               -- Template Name. These units will be formed. 
        Priority = 80,                                                        -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 75,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE,    -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.MOBILE * categories.NAVAL * categories.EXPERIMENTAL,
                categories.MOBILE * categories.NAVAL * categories.ANTIAIR,
                categories.STRUCTURE * categories.NAVAL * categories.FACTORY,
                categories.MOBILE * categories.NAVAL * categories.DEFENSE,
                categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.MOBILE + categories.STRUCTURE}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

    Builder {
        BuilderName = 'S123 Hover PANIC 1 10',                                  -- Random Builder Name.
        PlatoonTemplate = 'S123 Hover 1 10',                                    -- Template Name. These units will be formed. 
        Priority = 90,                                                          -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 6,                                                      -- Number of plattons that will be formed with this template.
        BuilderData = {
            SearchRadius = BasePanicZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = true,                                          -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 1000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE,                           -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE + categories.NAVAL + categories.STRUCTURE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

    Builder {
        BuilderName = 'S123 Hover Military 1 100',                              -- Random Builder Name.
        PlatoonTemplate = 'S123 Hover 1 10',                                    -- Template Name. These units will be formed. 
        Priority = 80,                                                        -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                    -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 80,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.LAND + categories.NAVAL,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.LAND + categories.NAVAL + categories.STRUCTURE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },

    Builder {
        BuilderName = 'S123 Hover Enemy 1 100',                                 -- Random Builder Name.
        PlatoonTemplate = 'S123 Hover 1 10',                                    -- Template Name. These units will be formed. 
        Priority = 70,                                                        -- Priority. 1000 is normal.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed.
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            RequireTransport = false,                                           -- If this is true, the unit is forced to use a transport, even if it has a valid path to the destination.
            AggressiveMove = true,                                              -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 75,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.LAND + categories.NAVAL,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { MIBC, 'CanPathToCurrentEnemySwarm', { false, 'LocationType' } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.LAND + categories.NAVAL + categories.STRUCTURE }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}