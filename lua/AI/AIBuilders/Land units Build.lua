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
        Priority = 1010,
        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 260 } }, 

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.MOBILE * categories.SCOUT - categories.ENGINEER }},
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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandAA - Swarm - Reactive',
        PlatoonTemplate = 'T1LandAA',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 5, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR }},
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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandAA - Swarm - Reactive',
        PlatoonTemplate = 'T2LandAA',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 5, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 }},
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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 25, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandBot - Swarm',
        PlatoonTemplate = 'T3LandBotSwarm',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

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

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandAA - Swarm - Reactive',
        PlatoonTemplate = 'T3LandAA',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemySwarm', { true } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 5, categories.AIR * (categories.BOMBER + categories.GROUNDATTACK) }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},
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
        BuilderName = 'Microed Small Land Attack - Anti-Raid',
        PlatoonTemplate = 'AISwarm LandAttack Micro Small', 
        Priority = 100,
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 0, categories.LAND - categories.SCOUT }},
        },
        BuilderData = {
            AttackEnemyStrength = 200,
            SearchRadius = BasePanicZone,
            GetTargetsFromBase = true,
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         
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
        BuilderName = 'Microed Small Land Attack - Panic',
        PlatoonTemplate = 'AISwarm LandAttack Micro Small', 
        Priority = 100,
        InstanceCount = 4,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 1, categories.LAND - categories.SCOUT }},
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BasePanicZone,
            GetTargetsFromBase = true,
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         
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
        InstanceCount = 6,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'LessThanGameTimeSeconds', { 1500 } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.LAND - categories.SCOUT }},
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         
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
        InstanceCount = 6,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'LessThanGameTimeSeconds', { 1500 } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 1, categories.STRUCTURE - categories.SCOUT }},
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseEnemyZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         
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
        InstanceCount = 6,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'GreaterThanGameTimeSeconds', { 1500 } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 1, categories.LAND - categories.SCOUT }},
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseMilitaryZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         
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
        InstanceCount = 6,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'GreaterThanGameTimeSeconds', { 1500 } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 1, categories.STRUCTURE - categories.SCOUT }},
        },
        BuilderData = {
            AttackEnemyStrength = 100,
            SearchRadius = BaseEnemyZone,
            GetTargetsFromBase = false,
            TargetSearchCategory = categories.ALLUNITS - categories.AIR,                         
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
        BuilderName = 'Microed Raid Structures - Military',                          
        PlatoonTemplate = 'AISwarm LandAttack Micro Raid',                          
        Priority = 100,                                                        
        InstanceCount = 2,                                                   
        BuilderData = {
            SearchRadius = BaseMilitaryZone,                                   
            GetTargetsFromBase = false,                                       
            RequireTransport = false,                                            
            AggressiveMove = true,                                             
            AttackEnemyStrength = 200,                                          
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,    
            MoveToCategories = {                                                
                categories.EXPERIMENTAL,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.STRUCTURE,
            },
            WeaponTargetCategories = {                                    
                categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.INDIRECTFIRE,
                categories.DIRECTFIRE,
                categories.ANTIAIR,
                categories.STRUCTURE,
            },
        },
        BuilderConditions = {                                                  
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseMilitaryZone, 'LocationType', 0, categories.STRUCTURE - categories.NAVAL}}, 
        },
        BuilderType = 'Any',                                                  
    },

    Builder {
        BuilderName = 'Microed Raid Structure&Engineer - Enemy',                              
        PlatoonTemplate = 'AISwarm LandAttack Mini Raids',                           
        Priority = 100,                                                       
        InstanceCount = 2,                                                     
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                      
            GetTargetsFromBase = false,                                        
            RequireTransport = false,                                           
            AggressiveMove = false,                                             
            AttackEnemyStrength = 0,                                            
            TargetSearchCategory = categories.STRUCTURE + categories.ENGINEER,                      
            MoveToCategories = {                                              
                categories.MASSEXTRACTION,
                categories.ENGINEER,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = { 
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.STRUCTURE - categories.NAVAL}},                                                  
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Microed Raid Mex&Engineer - Enemy - Early',                              
        PlatoonTemplate = 'AISwarm LandAttack Micro Raid',                           
        Priority = 100,                                                       
        InstanceCount = 3,                                                     
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                      
            GetTargetsFromBase = false,                                        
            RequireTransport = false,                                           
            AggressiveMove = true,                                             
            AttackEnemyStrength = 0,                                            
            TargetSearchCategory = categories.MASSEXTRACTION + categories.ENGINEER,                      
            MoveToCategories = {                                              
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.STRUCTURE * categories.EXPERIMENTAL* categories.SHIELD,
                categories.STRUCTURE * categories.ARTILLERY,
                categories.STRUCTURE * categories.NUKE,
                categories.STRUCTURE * categories.ENERGYPRODUCTION,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.DEFENSE * categories.TECH3,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {   
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.STRUCTURE - categories.NAVAL}},                                                
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Microed AntiMass - Enemy',                            
        PlatoonTemplate = 'AISwarm LandAttack Micro Raid',                     
        Priority = 100,                                                   
        InstanceCount = 2,                                                    
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                      
            GetTargetsFromBase = false,                                        
            RequireTransport = false,                                            
            AggressiveMove = true,                                              
            AttackEnemyStrength = 80,                                          
            TargetSearchCategory = categories.MASSEXTRACTION + categories.DEFENSE, 
            MoveToCategories = {                                                
                categories.MASSEXTRACTION,
                categories.DEFENSE,
            },
            WeaponTargetCategories = {                                         
                categories.DEFENSE - categories.ANTIAIR,
                categories.DEFENSE,
                categories.MASSEXTRACTION,
                categories.ALLUNITS - categories.SCOUT,
            },
        },
        BuilderConditions = {                                               
            { UCBC, 'UnitsGreaterAtEnemySwarm', { 0 , categories.MASSEXTRACTION + categories.DEFENSE } },
        },
        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Microed Land Experimental Guard',
        PlatoonTemplate = 'T3ExperimentalAAGuard',
        PlatoonAIPlan = 'GuardUnit',
        Priority = 115,
        InstanceCount = 4,
        BuilderData = {
            GuardRadius = 70,
            GuardCategory = categories.MOBILE * categories.LAND * categories.EXPERIMENTAL,
            LocationType = 'LocationType',
        },
        BuilderConditions = {
--          { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER } },
            { UCBC, 'UnitsNeedGuard', { categories.MOBILE * categories.EXPERIMENTAL * categories.LAND} },
        },
        BuilderType = 'Any',
    },
}

BuilderGroup {
    BuilderGroupName = 'AISwarm Platoon Builder Intercepter',
    BuildersType = 'PlatoonFormBuilder', -- A PlatoonFormBuilder is for builder groups of units.

    Builder {
        BuilderName = 'Microed Enemy Intercept - Panic',                                     
        PlatoonTemplate = 'AISwarm LandAttack Intercept',                         
        Priority = 100,                                                          
        InstanceCount = 2,                                                      
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
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BasePanicZone, 'LocationType', 1, categories.LAND - categories.SCOUT - categories.ENGINEER }},
        },
        BuilderType = 'Any',                                                    
    },
}

BuilderGroup {
    BuilderGroupName = 'S3 SACU Formers',                              
    BuildersType = 'PlatoonFormBuilder',
-- ================= --
--    SACU Former    --
-- ================= --
    Builder {
        BuilderName = 'S3 Teleport 1',
        PlatoonTemplate = 'S3 SACU Teleport 1 1',
        Priority = 21000,
        InstanceCount = 2,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.TECH3,
                categories.STRUCTURE * categories.SHIELD * categories.TECH3,
                categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { EBC, 'GreaterThanEconTrend', { 0.0, 1000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's

            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 0, categories.SUBCOMMANDER} },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 1 , categories.STRUCTURE } },
        },
        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'S3 Teleport 3',
        PlatoonTemplate = 'S3 SACU Teleport 3 3',
        Priority = 21000,
        InstanceCount = 1,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = 10000,                                               -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 50000,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = true,                                               -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.ANTIMISSILE * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.EXPERIMENTAL,
                categories.STRUCTURE * categories.STRATEGIC * categories.ARTILLERY * categories.TECH3,
                categories.STRUCTURE * categories.STRATEGIC * categories.NUKE * categories.TECH3,
                categories.STRUCTURE * categories.SHIELD * categories.TECH3,
                categories.STRUCTURE * categories.MASSFABRICATION * categories.TECH3,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.COMMAND,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { EBC, 'GreaterThanEconTrend', { 0.0, 3000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's

            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 3, categories.SUBCOMMANDER} },

            { UCBC, 'UnitsGreaterAtEnemySwarm', { 1 , categories.STRUCTURE } },
        },
        BuilderType = 'Any',
    },
     
    Builder {
        BuilderName = 'S3 SACU CAP 3 7',
        PlatoonTemplate = 'S3 SACU Fight 3 7',
        Priority = 500,
        InstanceCount = 4,
        FormRadius = 10000,
        BuilderData = {
            SearchRadius = BaseEnemyZone,                                       -- Searchradius for new target.
            GetTargetsFromBase = false,                                         -- Get targets from base position (true) or platoon position (false)
            AggressiveMove = false,                                             -- If true, the unit will attack everything while moving to the target.
            AttackEnemyStrength = 100,                                        -- Compare platoon to enemy strenght. 100 will attack equal, 50 weaker and 150 stronger enemies.
            IgnorePathing = false,                                              -- If true, the platoon will not use AI pathmarkers and move directly to the target
            TargetSearchCategory = categories.STRUCTURE - categories.NAVAL,     -- Only find targets matching these categories.
            MoveToCategories = {                                                -- Move to targets
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.ECONOMIC,
                categories.STRUCTURE * categories.EXPERIMENTAL * categories.SHIELD,
                categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3,
                categories.STRUCTURE * categories.EXPERIMENTAL,
                categories.FACTORY * categories.TECH3,
                categories.ALLUNITS,
            },
        },
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanArmyPoolWithCategorySwarm', { 3, categories.SUBCOMMANDER} },
        },
        BuilderType = 'Any',
    },
}
