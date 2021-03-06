local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'

local MaxCapFactory = 0.024                                                     -- 2.4% of all units can be factories (STRUCTURE * FACTORY)
local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

BuilderGroup {
    BuilderGroupName = 'Swarm Expansion Builder',                            -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',                                           -- BuilderTypes are: EngineerBuilder, FactoryBuilder, PlatoonFormBuilder.

    --ACU Building Expansions --EXTREMELY EXPERIMENTAL--

    --[[ Builder {
        BuilderName = 'SC - Expand To Start Location',                               -- Random Builder Name.
        PlatoonTemplate = 'CommanderBuilder',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 620,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },

            { UCBC, 'StartLocationNeedsEngineer', { 'LocationType', 1000, -1000, 100, 1, 'StructuresNotMex' } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.1, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.20, 0.95 } },             -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Start Location',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 10000,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1LandFactory',
                    'T1LandFactory',
                }
            },
        }
    }, ]]--
    
    Builder {
        BuilderName = 'S1 Vacant Start Location',                               -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilder',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 500,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },

            { UCBC, 'StartLocationNeedsEngineer', { 'LocationType', 1000, -1000, 100, 1, 'StructuresNotMex' } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.25, 0.45 } },             -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Start Location',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5000,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1LandFactory',
                    'T1Radar',
                    'T1GroundDefense',
                    'T1LandFactory',
                }
            },
        }
    },
    Builder {
        BuilderName = 'S1 Vacant Start Location trans',                               -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilder',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 500,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },

            { UCBC, 'StartLocationNeedsEngineer', { 'LocationType', 1000, -1000, 100, 1, 'StructuresNotMex' } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.45, 0.45 } },             -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Start Location',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5000,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1LandFactory',
                    'T1Radar',
                    'T1GroundDefense',
                    'T1LandFactory',
                }
            },
        }
    },
    Builder {
        BuilderName = 'S1 Vacant Expansion Area',                               -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilder',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 500,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 4,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },

            { UCBC, 'StartLocationNeedsEngineer', { 'LocationType', 1000, -1000, 100, 1, 'StructuresNotMex' } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.25, 0.45 } },             -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Expansion Area',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5000,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1LandFactory',
                    'T1Radar',
                    'T1GroundDefense',
                    'T1LandFactory',
                }
            },
        }
    },
    Builder {
        BuilderName = 'S1 Vacant Expansion Area trans',                               -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilder',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 500,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },

            { UCBC, 'StartLocationNeedsEngineer', { 'LocationType', 1000, -1000, 100, 1, 'StructuresNotMex' } },

            { EBC, 'GreaterThanEconTrendSwarm', { 0.0, 0.0 } }, -- relative income

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.45, 0.45 } },             -- Ratio from 0 to 1. (1=100%)
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Expansion Area',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5000,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1LandFactory',
                    'T1Radar',
                    'T1GroundDefense',
                    'T1LandFactory',
                }
            },
        }
    },
    Builder {
        BuilderName = 'S1 Naval Builder',                                       -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilder',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 500,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'NavalBaseCheck', { } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'NavalAreaNeedsEngineer', { 'LocationType', 750, -1000, 100, 1, 'AntiSurface' } },
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconIncomeSwarm',  { 1.0, 6.0}},
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.25, 0.50 } },
            -- Don't build it if...
            -- Respect UnitCap
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Naval Area',
                LocationRadius = 750,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 100,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
                ExpansionRadius = 120,
                BuildStructures = {
                    'T1SeaFactory',
                }
            }
        }
    },
}
