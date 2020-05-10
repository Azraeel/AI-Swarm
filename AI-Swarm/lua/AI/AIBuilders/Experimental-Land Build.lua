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
        BuilderName = 'S4 LandExperimental3',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.LAND}},   	

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.3, 1.4 }},

            { EBC, 'GreaterThanEconIncomeSwarm', { 10, 300 } },
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
        BuilderName = 'S4 LandExperimental2',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.LAND}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.3, 1.4 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 10, 300 } },
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
        BuilderName = 'S4 LandExp1',
        PlatoonTemplate = 'T3EngineerBuilderSUB',
        Priority = 1000,
        InstanceCount = 1,
        BuilderConditions = {
        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.LAND}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },
            
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.3, 1.4 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconIncomeSwarm', { 10, 300 } },
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

BuilderGroup { BuilderGroupName = 'Swarm Land Experimental Formers',         
    BuildersType = 'PlatoonFormBuilder',   
    Builder {
        BuilderName = 'AISwarm - Experimental Group - EZ',                                 
        PlatoonTemplate = 'AISwarm - Experimental - Group',                           
        Priority = 100,                                                       
        InstanceCount = 2,                                                 
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                 
            GetTargetsFromBase = false,                                    
            AggressiveMove = true,                                            
            AttackEnemyStrength = 250,                                    
            TargetSearchCategory = categories.ALLUNITS - categories.WALL - categories.NAVAL,                                 
            MoveToCategories = {                                            
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'AISwarm - Experimental Group - MZ',                           
        PlatoonTemplate = 'AISwarm - Experimental - Group',                        
        Priority = 100,                                                     
        InstanceCount = 2,
        FormRadius = 10000,                                                   
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                  
            GetTargetsFromBase = false,                                       
            AggressiveMove = true,                                            
            AttackEnemyStrength = 250,                                       
            TargetSearchCategory = categories.ALLUNITS - categories.WALL - categories.NAVAL,                                  
            MoveToCategories = {                                                
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.STRUCTURE * categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { },
        BuilderType = 'Any',                                                    
    },
}
