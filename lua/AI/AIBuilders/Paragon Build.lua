local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'

-- ===================================================-======================================================== --
-- ==                                 Economic Experimental (Paragon etc)                                    == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'S4 Economic Experimental Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S4 Paragon 1st mass40',
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 300,
        DelayEqualBuildPlattons = {'Paragon', 60},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            -- Have we the eco to build it ?
            { EBC, 'GreaterThanEconStorageRatio', { 0.40, 0.90}}, -- Ratio from 0 to 1. (1=100%)
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
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
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 350,
        DelayEqualBuildPlattons = {'Paragon', 60},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
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
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 3500,
        DelayEqualBuildPlattons = {'Paragon', 60},
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasNotParagon', {} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },
            { EBC, 'GreaterThanEconTrend', { 18.0, 270.0 } },                      -- relative income
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'CheckBuildPlattonDelay', { 'Paragon' }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
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
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
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
        PlatoonTemplate = 'T3EngineerBuildernoSUB',
        Priority = 350,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HasParagon', {} },
            { UCBC, 'GreaterThanGameTimeSeconds', { 60*60 } },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            -- Do we need additional conditions to build it ?
            { UCBC, 'CanBuildCategorySwarm', { categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC } },
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC}},
            -- Have we the eco to build it ?
            -- Don't build it if...
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.ENERGYPRODUCTION * categories.TECH3 } },
            -- Respect UnitCap
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
