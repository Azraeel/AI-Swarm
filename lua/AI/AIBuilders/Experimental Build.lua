local EBC = '/lua/editor/EconomyBuildConditions.lua'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

-----------------------------
-- Mobile Experimental Air --
-----------------------------

-- Yet another reduction to Experimental Econ Efficiency :)
-- from { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.03, 1.04 }},
-- to { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

BuilderGroup { BuilderGroupName = 'Swarm Air Experimental Builders',                          
    BuildersType = 'EngineerBuilder',
        
    Builder { BuilderName = 'S Air Experimental',

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 950,

        InstanceCount = 3,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},
            
            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },
        },
        BuilderType = 'Any',

        BuilderData = {

            NumAssistees = 3,
            
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
    
    Builder { BuilderName = 'S Air Experimental - Satellite',

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 950,

        InstanceCount = 1,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { MIBC, 'GreaterThanGameTime', { 3600 } }, -- Need to figure out a better restriction for Satellite --
        },
        BuilderType = 'Any',

        BuilderData = {

            NumAssistees = 1,
            
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

BuilderGroup { BuilderGroupName = 'Swarm Land Experimental Builders', 

    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'S Land Experimental - 3',

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 950,

        InstanceCount = 1,

        BuilderConditions = {
        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.EXPERIMENTAL * categories.LAND}},   	

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},
        },

        BuilderType = 'Any',

        BuilderData = {

            NumAssistees = 2,
            
            Construction = {

                DesiresAssist = true,

                BuildClose = true,

                AdjacencyCategory = categories.STRUCTURE * categories.SHIELD,

                BuildStructures = {

                    'T4LandExperimental3',

                },

                Location = 'LocationType',

            }
        }
    },

    Builder {
        BuilderName = 'S Land Experimental - 2',

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 950,

        InstanceCount = 1,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 4, 5 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.EXPERIMENTAL * categories.LAND}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},
        },

        BuilderType = 'Any',
        
        BuilderData = {
            
            NumAssistees = 2,
            
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
        BuilderName = 'S Land Experimental',

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 950,

        InstanceCount = 1,

        BuilderConditions = {
        	{ UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.EXPERIMENTAL * categories.LAND}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },
            
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},
        },

        BuilderType = 'Any',

        BuilderData = {

            NumAssistees = 3,
            
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

--------------------------------------
-- Mobile Experimental Sea --
--------------------------------------

BuilderGroup { BuilderGroupName = 'Swarm Naval Experimental Builders',                         
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'S Water Experimental',

        PlatoonTemplate = 'T3EngineerBuilderSUBSwarm',

        Priority = 950,

        InstanceCount = 2,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 } },            

            { EBC, 'GreaterThanMassTrendSwarm', { 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.02, 1.03 }},      
            
            { EBC, 'GreaterThanEconStorageCurrent', { 200, 2000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.MOBILE * categories.EXPERIMENTAL }},
        },
        BuilderType = 'Any',

        BuilderData = {

            NumAssistees = 2,
            
            Construction = {

                DesiresAssist = true,

                BuildClose = false,

                BuildStructures = {

                    'T4SeaExperimental1',

                },

                Location = 'LocationType',
            }
        }
    },
}

---------------------------------------
-- Experimental Attack Form-Builders --
---------------------------------------

BuilderGroup { BuilderGroupName = 'Swarm Air Experimental Formers',              
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'S Air Experimental',                         
        PlatoonTemplate = 'S Air Attack Experimental',     

        Priority = 100,          

        InstanceCount = 2,             

        FormRadius = 10000,

        BuilderData = {
            SearchRadius = BaseMilitaryZone,         

            GetTargetsFromBase = false,          

            AggressiveMove = true,            

            AttackEnemyStrength = 90,      

            IgnorePathing = true,              

            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE + categories.ECONOMIC,   

            MoveToCategories = {                                                
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,

                categories.STRUCTURE * categories.EXPERIMENTAL,

                categories.STRUCTURE * categories.NUKE,

                categories.STRUCTURE * categories.FACTORY * categories.TECH3,

                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,

                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,

                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,

                categories.STRUCTURE * categories.DEFENSE,

                categories.STRUCTURE,

                categories.MOBILE,
            },
        },

        BuilderConditions = {  },

        BuilderType = 'Any',

    },

    Builder {
        BuilderName = 'S Air Experimental - Group',   
                       
        PlatoonTemplate = 'S Air Attack Experimental - Group',        

        Priority = 2,   

        InstanceCount = 1,  

        FormRadius = 10000,

        BuilderData = {
            SearchRadius = BaseEnemyZone,    

            GetTargetsFromBase = false,     

            AggressiveMove = false,      

            AttackEnemyStrength = 100,      

            IgnorePathing = true,         

            TargetSearchCategory = categories.STRUCTURE + categories.MOBILE + categories.ECONOMIC,  

            MoveToCategories = {                                               
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,

                categories.STRUCTURE * categories.EXPERIMENTAL,

                categories.STRUCTURE * categories.NUKE,

                categories.STRUCTURE * categories.FACTORY * categories.TECH3,

                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,

                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,

                categories.STRUCTURE * categories.DEFENSE * categories.TECH2,

                categories.STRUCTURE * categories.DEFENSE,

                categories.STRUCTURE,

                categories.MOBILE,
            },
        },

        BuilderConditions = {  },

        BuilderType = 'Any',   

    },
}

BuilderGroup { BuilderGroupName = 'Swarm Land Experimental Formers',    

    BuildersType = 'PlatoonFormBuilder',   

    Builder {

        BuilderName = 'AISwarm - Land Experimental',                                 
        PlatoonTemplate = 'AISwarm - Experimental',                           
        Priority = 100,     

        InstanceCount = 2,   

        FormRadius = 10000,

        BuilderData = {
            SearchRadius = BaseMilitaryZone, 

            GetTargetsFromBase = false,  

            AggressiveMove = true,       

            AttackEnemyStrength = 105,   

            TargetSearchCategory = categories.ALLUNITS - categories.WALL - categories.NAVAL - categories.MASSEXTRACTION,        

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
        BuilderName = 'AISwarm - Land Experimental Group',       

        PlatoonTemplate = 'AISwarm - Experimental Group',    

        Priority = 100,              

        InstanceCount = 1,

        FormRadius = 10000,      

        BuilderData = {

            SearchRadius = BaseEnemyZone,    

            GetTargetsFromBase = false,     

            AggressiveMove = true,      

            AttackEnemyStrength = 110,  

            TargetSearchCategory = categories.ALLUNITS - categories.WALL - categories.NAVAL - categories.MASSEXTRACTION,   

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


