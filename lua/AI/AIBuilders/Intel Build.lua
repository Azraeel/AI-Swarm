local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'

local MaxCapStructure = 0.12                                                    -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

-- ===================================================-======================================================== --
-- ==                                        Radar T1 T3 builder                                             == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'S1 Land Radar Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S1 Radar',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, (categories.RADAR + categories.OMNI) * categories.STRUCTURE}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND } },

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 5.0 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = false,
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                BuildStructures = {
                    'T1Radar',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'S3 Radar',
        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',
        Priority = 1000,
        BuilderConditions = {

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OMNI * categories.STRUCTURE }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 1.5, 200.0 } }, -- relative income

            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, categories.OMNI * categories.STRUCTURE } },

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.OMNI * categories.STRUCTURE } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                BuildStructures = {
                    'T3Radar',
                },
                Location = 'LocationType',
            }
        }
    },

    Builder {
        BuilderName = 'S1 Reclaim T1+T2 Radar',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 790,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.OMNI * categories.STRUCTURE }},
        
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.RADAR }},
        },
        BuilderData = {
            Location = 'LocationType',
            Reclaim = {categories.STRUCTURE * categories.RADAR * (categories.TECH1 + categories.TECH2)},
        },
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                    Radar T1 Upgrade Land+Air                                           == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'S1 Land Radar Upgrader',                           
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'S1 Radar Upgrade',
        PlatoonTemplate = 'T1RadarUpgrade',
        Priority = 10000,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 
   
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.RADAR * categories.TECH1 }},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'S2 Radar Upgrade',
        PlatoonTemplate = 'T2RadarUpgrade',
        Priority = 1000,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },
         
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OMNI * categories.STRUCTURE }},
           
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 
           
            { UCBC, 'HaveLessThanUnitsInCategoryBeingUpgradeSwarm', { 1, categories.RADAR * categories.TECH2 }},
        },
        BuilderType = 'Any',
    },
}
-- =============================================-==================================================== --
-- ==                                    Special Optics                                            == --
-- =============================================-==================================================== --

BuilderGroup {
    BuilderGroupName = 'AeonOptics',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S3 Optics Construction Aeon',
        PlatoonTemplate = 'AeonT3EngineerBuilder',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OPTICS * categories.AEON}},

            { EBC, 'GreaterThanEconIncomeOverTimeSwarm', { 15, 1500}},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},          

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.ENERGYPRODUCTION * categories.TECH3,
                },
                BuildClose = false,
                BuildStructures = {
                    'T3Optics',
                },
                Location = 'LocationType',
            }
        }
    }
}

BuilderGroup {
    BuilderGroupName = 'CybranOptics',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S3 Optics Construction Cybran',
        PlatoonTemplate = 'CybranT3EngineerBuilder',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.OPTICS * categories.CYBRAN}},

            { EBC, 'GreaterThanEconIncomeOverTimeSwarm', { 15, 1500}},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},  

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'ForwardClose',
                AdjacencyPriority = {
                    categories.STRUCTURE * categories.SHIELD,
                    categories.ENERGYPRODUCTION * categories.TECH3,
                },
                BuildClose = false,
                BuildStructures = {
                    'T3Optics',
                },
                Location = 'LocationType',
            }
        }
    }
}
