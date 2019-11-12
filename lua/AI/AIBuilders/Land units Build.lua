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
    Builder { BuilderName = 'U1 Ratio Tank',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 590,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },


    Builder { BuilderName = 'U1 Ratio Bot',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 550,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U1 Ratio AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 580,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 0.2, 2 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'HaveLessThanArmyPoolWithCategory', { 15, categories.ANTIAIR} },
        },
        BuilderType = 'Land',
    },


    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'U2 DFTank',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 680,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U2 AttackTank',
        PlatoonTemplate = 'T2AttackTank',
        Priority = 680,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U2 Amphibious',
        PlatoonTemplate = 'U2 LandSquads Amphibious',
        Priority = 260,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.TECH1} },     
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U2 Mobile AA',
        PlatoonTemplate = 'T2LandAA',
        Priority = 665,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 1, 20 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'HaveLessThanArmyPoolWithCategory', { 15, categories.ANTIAIR} },
        },
        BuilderType = 'Land',
    },


    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'U3 Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 795,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U3 SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 790,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U3 ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 825,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U3 Amphibious',
        PlatoonTemplate = 'U3 LandSquads Amphibious',
        Priority = 350,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { false } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.MOBILE * categories.TECH1} },     
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U3 Mobile AA',
        PlatoonTemplate = 'T3LandAA',
        Priority = 785,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { UCBC, 'HaveLessThanArmyPoolWithCategory', { 15, categories.ANTIAIR} },
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'U3 MobileShields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 610,
        BuilderConditions = {
            { EBC, 'GreaterThanEconTrend', { 0.0, 0.0 } },

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { MIBC, 'CanPathToCurrentEnemy', { true } },

            { EBC, 'GreaterThanEconIncome', { 3.5, 100 } },
        },
        BuilderType = 'Land',
    },
}


-- ===================================================-======================================================== --
--                                         Land Scouts Formbuilder                                              --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'SU1 Land Scout Formers',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'SU1 Land Scout',
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
        BuilderName = 'AISwarm LandAttack Early',
        PlatoonTemplate = 'AISwarm LandAttack Early', 
        Priority = 500,
        InstanceCount = 100,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
        },        
        BuilderConditions = { 

            { MIBC, 'LessThanGameTime', { 420 } },

        },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Default',
        PlatoonTemplate = 'AISwarm LandAttack Default', 
        Priority = 101,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'GrowthFormation',
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Small',
        PlatoonTemplate = 'AISwarm LandAttack Small', 
        Priority = 102,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'GrowthFormation',
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Medium',
        PlatoonTemplate = 'AISwarm LandAttack Medium', 
        Priority = 103,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'GrowthFormation',
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Large',
        PlatoonTemplate = 'AISwarm LandAttack Large', 
        Priority = 100,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'GrowthFormation',
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Assault',
        PlatoonTemplate = 'AISwarm LandAttack Assault', 
        Priority = 100,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'AttackFormation',
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0,
            },
        },        
        BuilderConditions = { },
    },

    Builder {
        BuilderName = 'AISwarm LandAttack Raid',
        PlatoonTemplate = 'AISwarm LandAttack Raid', 
        Priority = 101,
        InstanceCount = 15,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = false,
            MarkerType = 'Mass',            
            MoveFirst = 'Random',
            MoveNext = 'Threat',
            ThreatType = 'Economy',			    
            FindHighestThreat = false,						
            AvoidBases = true,
            AvoidBasesRadius = 75,
            AggressiveMove = true,      
            AvoidClosestRadius = 50,
        },        
        BuilderConditions = { },
    },
}
