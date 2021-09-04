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

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.LAND } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.05, 0.40 } },             -- Ratio from 0 to 1. (1=100%)
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
    
    -- I have neglected working on expansions more, and they were always a backup and or the last thought inside Swarm's mind.
    -- This needs some serious work, clearly this does not work in FAF and he needs to control his expansions better and building expansions/FOBs would most likely help him defend his ZONE better
    -- I have also neglected to put though into the use of zones as a physical map for Swarm.
    -- For example when a expansion or any other base is created this actually extends the Panic zone which can be his Restricted or Protected Zone in his mind.
    -- This will allow Swarm to tell his frontline more clearly.
    -- More so direct platoons better.
    
    Builder {
        BuilderName = 'S1 Vacant Start Location',                               -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilderALLTECH',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 650,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'StartLocationNeedsEngineer', { 'LocationType', 250, -1000, 5, 1, 'AntiSurface' } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 - categories.COMMAND - categories.STATIONASSISTPOD }},
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Start Location',
                LocationRadius = 250,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1LandFactory',
                    'T1Radar',
                }
            },
        }
    },

    Builder {
        BuilderName = 'S1 Vacant Expansion Area',                               -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilderALLTECH',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 500,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'ExpansionBaseCheck', { } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'ExpansionAreaNeedsEngineer', { 'LocationType', 250, -1000, 5, 1, 'AntiSurface' } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 - categories.COMMAND - categories.STATIONASSISTPOD }},
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = true,
                NearMarkerType = 'Expansion Area',
                LocationRadius = 250,
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1Radar',
                }
            },
        }
    },

    Builder {
        BuilderName = 'S2 Vacant Start Location - Defense Point',                             
        PlatoonTemplate = 'T2EngineerBuilder',                                   
        Priority = 510,                                                  
        InstanceCount = 1,                                                 
        BuilderConditions = {
            { UCBC, 'LandStrengthRatioLessThan', { 1 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH2 - categories.COMMAND - categories.STATIONASSISTPOD }},

            { UCBC, 'ExpansionAreaNeedsEngineer', { 'LocationType', 1000, 5, 500, 1, 'AntiSurface' } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.70}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }}, 
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = false,
                NearMarkerType = 'Start Location',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = 5,
                ThreatMax = 500,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1GroundDefense',
                    'T2GroundDefense',
                    'T2AADefense',
                    'T2GroundDefense',
                    'T2AADefense',
                    'T2Radar',
                    'T2ShieldDefense',
                    'T2MissileDefense',
                    'T2MissileDefense',
                    'T2GroundDefense',
                    'T2GroundDefense',
                }
            },
        }
    },

    Builder {
        BuilderName = 'S2 Vacant Expansion Area - Defense Point',                             
        PlatoonTemplate = 'T2EngineerBuilder',                                   
        Priority = 510,                                                  
        InstanceCount = 1,                                                 
        BuilderConditions = {
            { UCBC, 'LandStrengthRatioLessThan', { 1 } },
            
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.ENGINEER * categories.TECH2 - categories.COMMAND - categories.STATIONASSISTPOD }},

            { UCBC, 'ExpansionAreaNeedsEngineer', { 'LocationType', 1000, 5, 500, 1, 'AntiSurface' } },

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.04, 0.70}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 0.9 }}, 
        },
        BuilderType = 'Any',
        BuilderData = {
            RequireTransport = false,
            Construction = {
                BuildClose = false,
                BaseTemplate = 'ExpansionBaseTemplates',
                ExpansionBase = false,
                NearMarkerType = 'Expansion Area',
                LocationRadius = 1000,
                LocationType = 'LocationType',
                ThreatMin = 5,
                ThreatMax = 500,
                ThreatRings = 1,
                ThreatType = 'StructuresNotMex',
                ExpansionRadius = 100,
                BuildStructures = {
                    'T1GroundDefense',
                    'T2GroundDefense',
                    'T2AADefense',
                    'T2GroundDefense',
                    'T2AADefense',
                    'T2Radar',
                    'T2ShieldDefense',
                    'T2MissileDefense',
                    'T2MissileDefense',
                    'T2GroundDefense',
                    'T2GroundDefense',
                }
            },
        }
    },

    Builder {
        BuilderName = 'S1 Naval Builder',                                       -- Random Builder Name.
        PlatoonTemplate = 'EngineerBuilderALLTECH',                                    -- Template Name. These units will be formed. See: "\lua\AI\PlatoonTemplates\"
        Priority = 500,                                                        -- Priority. Higher priotity will be build more often then lower priotity.
        InstanceCount = 2,                                                      -- Number of plattons that will be formed with this template.
        BuilderConditions = {
            { UCBC, 'NavalBaseCheck', { } },

            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrent', { 250, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.0 }}, 

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 - categories.COMMAND - categories.STATIONASSISTPOD }},

            { UCBC, 'NavalAreaNeedsEngineer', { 'LocationType', 750, -1000, 100, 1, 'AntiSurface' } },
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
