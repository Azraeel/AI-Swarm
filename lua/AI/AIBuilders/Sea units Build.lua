local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxAttackForce = 0.45     

-- this function will turn a builder off if the enemy is not active in the water
local IsEnemyNavalActive = function( self, aiBrain, manager )

	if aiBrain.MyNavalRatio and (aiBrain.MyNavalRatio > .01 and aiBrain.MyNavalRatio <= 10) then
        --LOG("*AI DEBUG "..aiBrain.Nickname.." enemy naval is active at "..repr(aiBrain.MyNavalRatio))
		return 500, true

	end

	return 0, true
	
end

local HaveLessThanTwoT2NavalFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.NAVAL - categories.TECH1, false, true )) < 2 then
	
		return 500, true
		
	end

	
	return 0, false
	
end

local HaveLessThanTwoT3NavalFactory = function( self, aiBrain )

	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.NAVAL * categories.TECH3, false, true )) < 2 then
	
		return 500, true
		
	end

	return 0, false
	
end

-- ================== --
-- Build T1 T2 T3 SEA --
-- ================== --

-- ALL PRIORITIES ARE SET TO 500 --
-- Production is purely decided by Priority Functions
-- usually controlled by naval ratio and number of factories producing that unit

-- reduction of Builder Conditions is the next goal 
-- Silly Conditions like CanPathNavalBaseToNavalTargetsSwarm can be completely removed and opt for continus production
-- if Navy is contested, instead we can opt for Bombardment Ship production et Battleships and Missile Ships, Cruisers too.

-- As I thought Navy has been a complete success or although the Bombardment Ship Production needs a specific Platoon Function.


BuilderGroup { BuilderGroupName = 'Swarm Naval Builders',    

    BuildersType = 'FactoryBuilder',

    Builder { BuilderName = 'T1SeaFrigate - Swarm',

        PlatoonTemplate = 'T1SeaFrigate',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT2NavalFactory,

        BuilderConditions = {
            { UCBC, 'NavalStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.FRIGATE * categories.NAVAL }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T1SeaSub - Swarm',

        PlatoonTemplate = 'T1SeaSub',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT2NavalFactory,

        BuilderConditions = {
            { UCBC, 'NavalStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.T1SUBMARINE * categories.NAVAL }},
        },

        BuilderType = 'Sea',

    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2SeaDestroyer - Swarm',

        PlatoonTemplate = 'T2SeaDestroyer',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3NavalFactory,

        BuilderConditions = {
            { UCBC, 'NavalStrengthRatioLessThan', { 3 } },

        	{ EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.DESTROYER * categories.NAVAL * categories.TECH2 }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T2SeaCruiser - Swarm',

        PlatoonTemplate = 'T2SeaCruiser',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3NavalFactory,

        BuilderConditions = {
            { UCBC, 'NavalStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.CRUISER * categories.NAVAL * categories.TECH2 }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T2SeaCruiser - Swarm - Reactive',

        PlatoonTemplate = 'T2SeaCruiser',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3NavalFactory,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 1.5 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.CRUISER * categories.NAVAL * categories.TECH2 }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T2SubKiller - Swarm',

        PlatoonTemplate = 'T2SubKiller',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3NavalFactory,

        BuilderConditions = {
            { UCBC, 'NavalStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.T2SUBMARINE * categories.NAVAL * categories.TECH2 }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T2ShieldBoat - Swarm',

        PlatoonTemplate = 'T2ShieldBoat',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3NavalFactory,

        BuilderConditions = {
            { UCBC, 'NavalStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.SHIELD * categories.NAVAL * categories.TECH2 }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T2CounterIntelBoat - Swarm',

        PlatoonTemplate = 'T2CounterIntelBoat',

        Priority = 500,

        PriorityFunction = HaveLessThanTwoT3NavalFactory,

        BuilderConditions = {
            { UCBC, 'NavalStrengthRatioLessThan', { 3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.STEALTH * categories.NAVAL * categories.TECH2 }},
        },

        BuilderType = 'Sea',

    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3SeaBattleship - Swarm',

        PlatoonTemplate = 'T3SeaBattleship',

        Priority = 500,

        BuilderConditions = {
        	{ EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.BATTLESHIP * categories.NAVAL * categories.TECH3 }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T3Battlecruiser - Swarm',

        PlatoonTemplate = 'T3Battlecruiser',

        Priority = 500,

        PriorityFunction = IsEnemyNavalActive,

        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.CRUISER * categories.NAVAL * categories.TECH3 }},
        },

        BuilderType = 'Sea',

    },

    Builder { BuilderName = 'T2SeaCruiser - Swarm - Reactive - Tech3',

        PlatoonTemplate = 'T2SeaCruiser',

        Priority = 500,

        BuilderConditions = {
            { UCBC, 'AirStrengthRatioLessThan', { 1.5 } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH3 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 5, categories.CRUISER * categories.NAVAL * categories.TECH2 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T3SubKiller - Swarm',

        PlatoonTemplate = 'T3SubKiller',

        Priority = 500,

        PriorityFunction = IsEnemyNavalActive,

        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.SUBMERSIBLE * categories.NAVAL * categories.TECH3 }},
        },
        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T3MissileBoat - Swarm',

        PlatoonTemplate = 'T3MissileBoat',

        Priority = 500,

        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.BATTLESHIP * categories.INDIRECTFIRE * categories.NAVAL * categories.TECH3 }},
        },

        BuilderType = 'Sea',
    },

    Builder { BuilderName = 'T3SeaNukeSub - Swarm',

        PlatoonTemplate = 'T3SeaNukeSub',

        Priority = 500,

        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.15, 1.15 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.NUKE * categories.NAVAL }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.NUKE * categories.NAVAL * categories.TECH3 }},
        },
        BuilderType = 'Sea',
    },
}

-------------------
-- Sonar Builder --                                      
-------------------

BuilderGroup { BuilderGroupName = 'Swarm Sonar Builders',                              

    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'S1 Sonar',

        PlatoonTemplate = 'T1EngineerBuilderSwarm',

        Priority = 200,

        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 1, (categories.SONAR * categories.STRUCTURE - categories.TECH3) + (categories.MOBILESONAR * categories.TECH3) } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.ENGINEER * categories.TECH1 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL } },
            
            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.40, 0.90 } },
        },

        BuilderType = 'Any',

        BuilderData = {

            Construction = {

                BuildStructures = {

                    'T1Sonar',
                },

                Location = 'LocationType',

            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Sonar Upgraders',                         

    BuildersType = 'PlatoonFormBuilder',
    
    Builder { BuilderName = 'S1 Sonar Upgrade',

        PlatoonTemplate = 'T1SonarUpgrade',

        Priority = 200,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SONAR * categories.TECH1}},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.90, 0.90 } },  
        },

        BuilderType = 'Any',

    },
    
    Builder { BuilderName = 'S2 Sonar Upgrade',

        PlatoonTemplate = 'T2SonarUpgrade',

        Priority = 300,

        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SONAR * categories.TECH2}},
            
            { MIBC, 'FactionIndex', { 1, 2, 3, 5 }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.90, 0.90 } },
        },

        BuilderType = 'Any',

    },
}

-----------------------
-- NAVAL Formbuilder --
-----------------------

BuilderGroup { BuilderGroupName = 'Swarm Naval Formers',   

    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Swarm Panic Sea',     

        PlatoonTemplate = 'Swarm Sea Attack',      

        Priority = 100,    

        InstanceCount = 1,     

        BuilderData = {
            SearchRadius = BasePanicZone,       

            AggressiveMove = true,                

            AttackEnemyStrength = 100,                   

            TargetSearchCategory = categories.MOBILE * categories.NAVAL + categories.LAND - categories.SCOUT,      

            MoveToCategories = {                                                
                categories.EXPERIMENTAL * categories.NAVAL,
                categories.MOBILE * categories.NAVAL,
            },
        },

        BuilderConditions = { },

        BuilderType = 'Any',                                                 
    },

    Builder {
        BuilderName = 'Swarm Military Sea',                              
        PlatoonTemplate = 'Swarm Sea Attack',   

        Priority = 100,         

        InstanceCount = 1,    

        BuilderData = {

            SearchRadius = BaseMilitaryZone,   

            AggressiveMove = true,        

            AttackEnemyStrength = 100,   

            TargetSearchCategory = categories.MOBILE * categories.NAVAL + categories.LAND,      

            MoveToCategories = {                                               
                categories.NAVAL * categories.DEFENSE,
                categories.MOBILE * categories.NAVAL,
            },
        },

        BuilderConditions = {                                                   
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 6, categories.MOBILE * categories.NAVAL } },
        },

        BuilderType = 'Any',                                                    
    },

    Builder {
        BuilderName = 'Swarm Enemy Sea - Rush',

        PlatoonTemplate = 'Swarm Sea Attack',

        Priority = 100,

        InstanceCount = 1,

        BuilderData = {

            SearchRadius = BaseEnemyZone,     

            AggressiveMove = true,      

            AttackEnemyStrength = 105,   

            TargetSearchCategory = categories.NAVAL * categories.STRUCTURE * categories.FACTORY + categories.LAND,   

            MoveToCategories = {                                             
                categories.NAVAL * categories.STRUCTURE * categories.FACTORY,
                categories.MOBILE * categories.NAVAL,
            },

        },

        BuilderConditions = {    
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 5, categories.MOBILE * categories.NAVAL } },
        },

        BuilderType = 'Any',
    },

    Builder {
        BuilderName = 'Swarm Enemy Sea - General',

        PlatoonTemplate = 'Swarm Sea Attack',

        Priority = 100,

        InstanceCount = 3,

        BuilderData = {

            SearchRadius = BaseEnemyZone,   

            AggressiveMove = true,      

            AttackEnemyStrength = 100,   

            TargetSearchCategory = categories.STRUCTURE + categories.NAVAL + categories.LAND,     

            MoveToCategories = {                                              
                categories.MOBILE * categories.NAVAL,
                categories.EXPERIMENTAL,
                categories.ALLUNITS,
            },
        },

        BuilderConditions = {                                                  
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 15, categories.MOBILE * categories.NAVAL } },
        },

        BuilderType = 'Any',

    },

    Builder {
        BuilderName = 'Nuke Submarine Active NukeAI',
        PlatoonTemplate = 'Swarm SeaNuke',
        PlatoonAddPlans = { 'NukePlatoonAISwarm', },
        Priority = 100,
        InstanceCount = 20,
        BuilderType = 'Any',
        BuilderData = {
            UseFormation = 'AttackFormation',
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0, 
                PrimaryThreatTargetType = 'Naval',
                SecondaryThreatTargetType = 'Economy',
                SecondaryThreatWeight = 0.1,
                WeakAttackThreatWeight = 1,
                VeryNearThreatWeight = 10,
                NearThreatWeight = 5,
                MidThreatWeight = 1,
                FarThreatWeight = 1,
            },
        },
        BuilderConditions = { },
    },
}