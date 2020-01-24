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
        Priority = 10000,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 10 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.SCOUT } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.SCOUT } },
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

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 4, categories.INDIRECTFIRE * categories.LAND }},
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

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.INDIRECTFIRE * categories.LAND * categories.TECH2 }},
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

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 }},
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

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},
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

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},
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
        Priority = 5000,
        InstanceCount = 8,
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
        BuilderName = 'Land Attack Mass Raid',
        PlatoonTemplate = 'AISwarm LandAttack Early Raid',
        Priority = 100,
        InstanceCount = 4,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}}, 

            { UCBC, 'LessThanGameTimeSeconds', { 600 } },
        },
        BuilderData = {
            ThreatSupport = 100,
            LocationType = 'LocationType',
            MarkerType = 'Mass',
            MoveFirst = 'Random',
            MoveNext = 'Threat',
            ThreatType = 'Economy',             
            FindHighestThreat = false,      
            MaxThreatThreshold = 4900,      
            MinThreatThreshold = 1000,      
            AvoidBases = true,
            AvoidBasesRadius = 75,
            UseFormation = 'NoFormation',
            AggressiveMove = false,
            AvoidClosestRadius = 100,
        },
    },

    Builder {
        BuilderName = 'Land Attack Small',
        PlatoonTemplate = 'AISwarm LandAttack Small',
        Priority = 100,
        InstanceCount = 6,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR }}, 

            { UCBC, 'LessThanGameTimeSeconds', { 900 } },           
        },
        BuilderData = {
            ThreatSupport = 100,
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'AttackFormation',
            LocationType = 'LocationType',
            AggressiveMove = false,
        },
    },

    Builder {
        BuilderName = 'Land Attack Medium',
        PlatoonTemplate = 'AISwarm LandAttack Medium',
        Priority = 100,
        InstanceCount = 3,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 12, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR }},

            { UCBC, 'GreaterThanGameTimeSeconds', { 900 } },
        },
        BuilderData = {
            ThreatSupport = 100,
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'AttackFormation',
            LocationType = 'LocationType',
            AggressiveMove = false,
        },
    },

    Builder {
        BuilderName = 'Location Deployment',
        PlatoonTemplate = 'AISwarm LandAttack Rapid Deployment',
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR }},

            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
        },
        BuilderData = {
            ThreatSupport = 75,
            MarkerType = 'Start Location',
            MoveFirst = 'Closest',
            LocationType = 'LocationType',
            MoveNext = 'Random',
            AvoidBases = true,
            AvoidBasesRadius = 100,
            AggressiveMove = false,
            AvoidClosestRadius = 50,
            UseFormation = 'AttackFormation',
        },
    },



    Builder {
        BuilderName = 'Land Attack Mex Raid',
        PlatoonTemplate = 'AISwarm LandAttack Special Ops',
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderConditions = { 
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.EXPERIMENTAL}},

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.EXPERIMENTAL }},

            { UCBC, 'GreaterThanGameTimeSeconds', { 600 } },
        },
        BuilderData = {
            ThreatSupport = 100,
            LocationType = 'LocationType',
            MarkerType = 'Mass',
            MoveFirst = 'Random',
            MoveNext = 'Threat',
            ThreatType = 'Economy',             
            FindHighestThreat = false,      
            MaxThreatThreshold = 2000,      
            MinThreatThreshold = 1000,      
            AvoidBases = true,
            AvoidBasesRadius = 75,
            UseFormation = 'GrowthFormation',
            AggressiveMove = false,
            AvoidClosestRadius = 50,
        },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Base Siege',
        PlatoonTemplate = 'AISwarm LandAttack Base Siege', 
        Priority = 100,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            AttackEnemyStrength = 10000,
            SearchRadius = BaseEnemyZone,
            AggressiveMove = true,
            TargetSearchCategory = categories.STRUCTURE,
            MoveToCategories = {                                                
                categories.STRUCTURE, 
            }, 
            WeaponTargetCategories = {                                          
                categories.SHIELD,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.MASSFABRICATION,
                categories.STRUCTURE,
                categories.ALLUNITS,
            },
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'Microed Small Land Attack',
        PlatoonTemplate = 'AISwarm LandAttack Micro Small', 
        Priority = 101,
        InstanceCount = 6,
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
        BuilderName = 'Microed Small Land Attack',
        PlatoonTemplate = 'AISwarm LandAttack Micro Small', 
        Priority = 101,
        InstanceCount = 6,
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
        BuilderName = 'Microed Big Land Attack',
        PlatoonTemplate = 'AISwarm LandAttack Micro Big', 
        Priority = 101,
        InstanceCount = 8,
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
        BuilderName = 'Microed Big Land Attack',
        PlatoonTemplate = 'AISwarm LandAttack Micro Big', 
        Priority = 101,
        InstanceCount = 8,
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
