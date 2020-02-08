local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii(true)

local MaxAttackForce = 0.45                                                     -- 45% of all units can be attacking units (categories.MOBILE - categories.ENGINEER)

if not categories.STEALTHFIELD then categories.STEALTHFIELD = categories.SHIELD end

-- ===================================================-======================================================== --
--                                           LAND Scouts Builder                                                --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Scout Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    
    Builder { BuilderName = 'U1R Land Scout',
        PlatoonTemplate = 'T1LandScout',
        Priority = 1001,
        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 60 } }, 

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.LAND * categories.MOBILE * categories.SCOUT - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },
}

-- ===================================================-======================================================== --
-- ==                                         Land ratio builder Normal                                      == --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Builders Ratio',                         -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder { BuilderName = 'T1LandDFTank - Swarm - Early Game',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 1005, -- Early Game Unit Coverage
        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 420 } }, -- don't build after 7 minutes

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.MOBILE * categories.ENGINEER}},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandDFTank - Swarm',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandArtillery - Swarm',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.INDIRECTFIRE * categories.LAND }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandAA - Swarm',
        PlatoonTemplate = 'T1LandAA',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2LandDFTank - Swarm',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2AttackTank - Swarm',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandArtillery - Swarm',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.INDIRECTFIRE * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2MobileShields - Swarm',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND * categories.SHIELD }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandAA - Swarm',
        PlatoonTemplate = 'T2LandAA',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3ArmoredAssault - Swarm',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandBot - Swarm',
        PlatoonTemplate = 'T3LandBot',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3SniperBots - Swarm',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.SNIPER * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandArtillery - Swarm',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3MobileMissile - Swarm',
        PlatoonTemplate = 'T3MobileMissile',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandAA - Swarm',
        PlatoonTemplate = 'T3LandAA',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },
}

-- ===================================================-======================================================== --
--                                         Land Scouts Formbuilder                                              --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Scout Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'Swarm Land Scout',
        PlatoonTemplate = 'T1LandScoutForm',
        Priority = 10000,
        InstanceCount = 10,
        BuilderConditions = {
            -- When do we want to build this ?
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.LAND * categories.SCOUT } },
        },
        LocationType = 'LocationType',
        BuilderType = 'Any',
    },
}

-- ===================================================-======================================================== --
-- ==                                         Land Formbuilder                                               == --
-- ===================================================-======================================================== --
BuilderGroup {
    BuilderGroupName = 'AISwarm Platoon Builder',
    BuildersType = 'PlatoonFormBuilder', -- A PlatoonFormBuilder is for builder groups of units.

    Builder {
        BuilderName = 'Microed Enemy Intercept - Panic',                                     
        PlatoonTemplate = 'AISwarm LandAttack Intercept',                         
        Priority = 100,                                                          
        InstanceCount = 1,                                                      
        BuilderData = {
            SearchRadius = BasePanicZone,                                     
            GetTargetsFromBase = false,                                        
            RequireTransport = false,                                          
            AggressiveMove = true,                                            
            AttackEnemyStrength = 150,                                        
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Microed Enemy Intercept - Military',                                     
        PlatoonTemplate = 'AISwarm LandAttack Intercept',                         
        Priority = 100,                                                          
        InstanceCount = 1,                                                      
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                     
            GetTargetsFromBase = false,                                        
            RequireTransport = false,                                          
            AggressiveMove = true,                                            
            AttackEnemyStrength = 150,                                        
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Microed Enemy Intercept - Enemy',                                     
        PlatoonTemplate = 'AISwarm LandAttack Intercept',                         
        Priority = 100,                                                          
        InstanceCount = 3,                                                      
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                     
            GetTargetsFromBase = false,                                        
            RequireTransport = false,                                          
            AggressiveMove = false,                                            
            AttackEnemyStrength = 150,                                        
            TargetSearchCategory = categories.MOBILE * categories.LAND - categories.SCOUT, 
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.SCOUT,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {                                                   
            { UCBC, 'UnitsGreaterAtEnemy', { 0 , categories.MOBILE * categories.LAND - categories.SCOUT } },
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Microed Small Land Attack - Panic',
        PlatoonTemplate = 'AISwarm LandAttack Micro Small', 
        Priority = 100,
        InstanceCount = 13,
        BuilderType = 'Any',
        BuilderConditions = { 
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BasePanicZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS,                         
            MoveToCategories = {
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.MASSEXTRACTION, 
                categories.STRUCTURE * categories.ENERGYPRODUCTION,  
                categories.STRUCTURE,                                             
                categories.ALLUNITS, 
            },
            WeaponTargetCategories = {                                          
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },        
    },

    Builder {
        BuilderName = 'Microed Small Land Attack - Military',
        PlatoonTemplate = 'AISwarm LandAttack Micro Small', 
        Priority = 100,
        InstanceCount = 13,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'LessThanGameTimeSeconds', { 1500 } },
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS,                         
            MoveToCategories = {
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.MASSEXTRACTION, 
                categories.STRUCTURE * categories.ENERGYPRODUCTION,  
                categories.STRUCTURE,                                             
                categories.ALLUNITS, 
            },
            WeaponTargetCategories = {                                          
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },        
    },

    Builder {
        BuilderName = 'Microed Small Land Attack - Enemy',
        PlatoonTemplate = 'AISwarm LandAttack Micro Small', 
        Priority = 100,
        InstanceCount = 13,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'LessThanGameTimeSeconds', { 1500 } },
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseEnemyZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS,                         
            MoveToCategories = {
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.MASSEXTRACTION, 
                categories.STRUCTURE * categories.ENERGYPRODUCTION,  
                categories.STRUCTURE,                                             
                categories.ALLUNITS, 
            },
            WeaponTargetCategories = {                                          
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },        
    },

    Builder {
        BuilderName = 'Microed Big Land Attack - Military',
        PlatoonTemplate = 'AISwarm LandAttack Micro Big', 
        Priority = 100,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'GreaterThanGameTimeSeconds', { 1500 } },
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS,                         
            MoveToCategories = {
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.MASSEXTRACTION, 
                categories.STRUCTURE * categories.ENERGYPRODUCTION,  
                categories.STRUCTURE,                                             
                categories.ALLUNITS, 
            },
            WeaponTargetCategories = {                                          
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },        
    },

    Builder {
        BuilderName = 'Microed Big Land Attack - Enemy',
        PlatoonTemplate = 'AISwarm LandAttack Micro Big', 
        Priority = 100,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'GreaterThanGameTimeSeconds', { 1500 } },
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseEnemyZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS,                         
            MoveToCategories = {
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.MASSEXTRACTION, 
                categories.STRUCTURE * categories.ENERGYPRODUCTION,  
                categories.STRUCTURE,                                             
                categories.ALLUNITS, 
            },
            WeaponTargetCategories = {                                          
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.MOBILE,
                categories.ALLUNITS,
            },
        },        
    },
}
