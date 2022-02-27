local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                 Economic Experimental (Paragon etc)                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'S4 Economic Experimental Builders',                          
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S4 Paragon 1st mass40',
        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',
        Priority = 300,
        DelayEqualBuildPlattons = {'Paragon', 60},
        BuilderConditions = {
            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },

            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
                AvoidCategory = categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                maxUnits = 1,
                maxRadius = 40,
                BuildClose = false,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S4 Paragon 1st 35min',
        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',
        Priority = 350,
        DelayEqualBuildPlattons = {'Paragon', 60},
        BuilderConditions = {
            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },
           
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
                AvoidCategory = categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                maxUnits = 1,
                maxRadius = 40,
                BuildClose = false,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S4 Paragon 1st HighTrend',
        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',
        Priority = 350,
        DelayEqualBuildPlattons = {'Paragon', 60},
        BuilderConditions = {
            { UCBC, 'HasNotParagon', {} },

            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 18.0, 270.0 } },                      
         
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
          
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
                AvoidCategory = categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                maxUnits = 1,
                maxRadius = 40,
                BuildClose = false,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S4 Paragon 2nd',
        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',
        Priority = 350,
        BuilderConditions = {
            { UCBC, 'HasParagon', {} },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},

            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },
           
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
                AvoidCategory = categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                maxUnits = 1,
                maxRadius = 40,
                BuildClose = false,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'S4 Paragon 3nd',
        PlatoonTemplate = 'T3EngineerBuildernoSUBSwarm',
        Priority = 350,
        BuilderConditions = {
            { UCBC, 'HasParagon', {} },

            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
           
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
           
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,
                AdjacencyDistance = 120,
                AvoidCategory = categories.ENERGYPRODUCTION * categories.EXPERIMENTAL,
                maxUnits = 1,
                maxRadius = 40,
                BuildClose = false,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
}
