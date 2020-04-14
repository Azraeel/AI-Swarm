local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii(true)


BuilderGroup { BuilderGroupName = 'Swarm Transports - Water Map',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',

    Builder { BuilderName = 'S1 Air Transport - Water Map',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 550, 
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }},
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S2 Air Transport - Water Map',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 650,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }}
        },
        BuilderType = 'Air',
    },


    Builder { BuilderName = 'S3 Air Transport - Water Map',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 750,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 2.5, 100 } },

            { MIBC, 'ArmyNeedsTransports', {} },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION} },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.AIR * categories.TRANSPORTATION }}
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
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.LAND * categories.TECH1 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},

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
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.LAND * categories.TECH2 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},

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
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 8, categories.LAND * categories.TECH3 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.TECH3 * (categories.DIRECTFIRE + categories.INDIRECTFIRE)}},
        },
        BuilderType = 'Land',
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Factory Builder - Water Map',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Swarm Commander Factory Builder Land - Water Map',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 590,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.30}}, 

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
            	AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Commander Factory Builder Air - Water Map',
        PlatoonTemplate = 'CommanderBuilder',
        Priority = 600,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.15, 0.40}}, 

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.AIR * categories.FACTORY * (categories.TECH1 + categories.TECH2 + categories.TECH3)  }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
                AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                Location = 'LocationType',
                BuildStructures = {
                   'T1AirFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Land - Water Map',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 605,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.40}}, 

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
            	DesiresAssist = true,
            	AdjacencyCategory = categories.MASSEXTRACTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
                Location = 'LocationType',
                BuildStructures = {
                   'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Factory Builder Air - Water Map',
        PlatoonTemplate = 'EngineerBuilder',
        Priority = 610,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.40}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 7, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                AdjacencyCategory = categories.ENERGYPRODUCTION * (categories.TECH3 + categories.TECH2 + categories.TECH1),
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
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE - categories.SCOUT,        -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.MOBILE,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.STRUCTURE}}, -- radius, LocationType, unitCount, categoryEnemy
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
            AttackEnemyStrength = 300,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
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
            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.STRUCTURE}}, -- radius, LocationType, unitCount, categoryEnemy
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
            AttackEnemyStrength = 500,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
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
            { MIBC, 'CanPathToCurrentEnemySwarm', { false } },
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.STRUCTURE}}, -- radius, LocationType, unitCount, categoryEnemy
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
            AttackEnemyStrength = 100000000,                                    -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.MOBILE,                           -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.MOBILE }}, -- radius, LocationType, unitCount, categoryEnemy
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
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
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
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.LAND + categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
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
            AttackEnemyStrength = 200,                                          -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            TargetSearchCategory = categories.LAND + categories.NAVAL,          -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   -- platoon will be formed if all conditions are true
            -- When do we want to form this ?
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.LAND + categories.NAVAL }}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderType = 'Any',                                                    -- Build with "Land" "Air" "Sea" "Gate" or "All" Factories. - "Any" forms a Platoon.
    },
}