local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii(true)

if not categories.STEALTHFIELD then categories.STEALTHFIELD = categories.SHIELD end

-- The timing will never be perfect on stopping T1 Production, but 25 minutes is obviously too long for Swarm. 
-- Maybe some kind of condition, that stops this from being purely a Timer Function. 
-- We'll try Land Ratio for right now.

--local AfterDirectCombat = function( self, aiBrain )
--	
--	if GetGameTimeSeconds() > 1800 and aiBrain.MyLandRatio > 1.5 then
--		return 0, false
--	end
--	
--	return self.Priority,true
--end


local WeHaveAnAdvantage = function( self, aiBrain )
	
	if aiBrain.MyLandRatio > 3.0 then
		return 0, false
	end
	
	return self.Priority,true
end

local HaveLessThanFiveT3LandFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.LAND * categories.TECH3, false, true )) < 5 then
	
		return 500, true
		
	end

	
	return 0, false
	
end


BuilderGroup { BuilderGroupName = 'Swarm Land Scout Builders',                             
    BuildersType = 'FactoryBuilder',
    
    Builder { BuilderName = 'U1R Land Scout',
        PlatoonTemplate = 'T1LandScout',
        Priority = 510,
        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 240 } }, 

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeOverTimeSwarm', { 0.2, 2 } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.LAND * categories.MOBILE * categories.SCOUT - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },
    
    Builder { BuilderName = 'U1R Land Scout - Battle',
        PlatoonTemplate = 'T1LandScout',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'GreaterThanGameTimeSeconds', { 240 } }, 

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconIncomeOverTimeSwarm', { 0.2, 2 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.SCOUT - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },
}

-- Average Condition Count is 5-6
BuilderGroup { BuilderGroupName = 'Swarm Land Builders Ratio',                       
    BuildersType = 'FactoryBuilder',
    
    -- ============ --
    --    TECH 1    --
    -- ============ --
    Builder { BuilderName = 'T1 Land Opening Queue',

        PlatoonTemplate = 'T1LandOpeningQueue',

        Priority = 505, 

        BuilderConditions = {
            { UCBC, 'LessThanGameTimeSeconds', { 60 * 3 } },

            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.ENGINEER }},
        },
        BuilderType = 'Land', 
    },

    Builder { BuilderName = 'T1LandDFTank - Swarm',

        PlatoonTemplate = 'T1LandDFTank',

        Priority = 500,

        PriorityFunction = WeHaveAnAdvantage,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 10, categories.LAND * categories.MOBILE * categories.DIRECTFIRE }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandArtillery  - Swarm',

        PlatoonTemplate = 'T1LandArtillery',

        Priority = 500,

        PriorityFunction = WeHaveAnAdvantage,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.INDIRECTFIRE }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T1LandAA - Swarm',

        PlatoonTemplate = 'T1LandAA',

        Priority = 500,

        PriorityFunction = WeHaveAnAdvantage,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'AirStrengthRatioLessThan', { 1.1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.7, 0.8 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.01}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH1 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.LAND * categories.MOBILE * categories.ANTIAIR }}, -- too much AA in the early game
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 2    --
    -- ============ --
    Builder { BuilderName = 'T2LandDFTank - Swarm',

        PlatoonTemplate = 'T2LandDFTank',

        Priority = 500,

        PriorityFunction = HaveLessThanFiveT3LandFactory,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH2 }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 40, categories.DIRECTFIRE * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2AttackTank - Swarm',

        PlatoonTemplate = 'T2AttackTank',

        Priority = 500,

        PriorityFunction = HaveLessThanFiveT3LandFactory,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH2 }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 40, categories.DIRECTFIRE * categories.LAND * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandArtillery - Swarm',

        PlatoonTemplate = 'T2LandArtillery',

        Priority = 500,

        PriorityFunction = HaveLessThanFiveT3LandFactory,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'LandStrengthRatioGreaterThan', { 1.1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.LAND * categories.TECH2 }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.INDIRECTFIRE * categories.LAND * categories.TECH2 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH2 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },


    -- Note these will build like they have t3 priority 

    Builder { BuilderName = 'T2MobileShields - Swarm',

        PlatoonTemplate = 'T2MobileShields',

        Priority = 550,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 2, 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * (categories.TECH2 * categories.TECH3) - categories.ENGINEER }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.SHIELD }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.MOBILE * categories.LAND * categories.SHIELD }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T2LandAA - Swarm',

        PlatoonTemplate = 'T2LandAA',

        Priority = 500,

        PriorityFunction = HaveLessThanFiveT3LandFactory,

        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { UCBC, 'AirStrengthRatioLessThan', { 1.1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.8, 0.9 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * (categories.TECH2 + categories.TECH3) - categories.ENGINEER }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH2 }},
        },
        BuilderType = 'Land',
    },

    -- ============ --
    --    TECH 3    --
    -- ============ --
    Builder { BuilderName = 'T3ArmoredAssault - Swarm',
        PlatoonTemplate = 'T3ArmoredAssault',
        Priority = 550,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 
            
            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.LAND * categories.FACTORY * categories.TECH3 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 55, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandBot - Swarm',
        PlatoonTemplate = 'T3LandBotSwarm',
        Priority = 550,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconIncomeOverTimeSwarm', { 3.5, 100 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } }, -- Swarm likes to upgrade his expansion factory to t3 first, which isn't that good.

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 55, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LightBot - Swarm',
        PlatoonTemplate = 'T3LightBotSwarm',
        Priority = 550,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1, 3 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 0.95 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.uel0303 + categories.url0303 } },

            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 55, categories.DIRECTFIRE * categories.LAND * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3SniperBots - Swarm',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 550,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 2, 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 6, categories.DIRECTFIRE * categories.LAND * categories.SNIPER * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandArtillery - Swarm',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 550,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'LandStrengthRatioGreaterThan', { 1.1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3MobileMissile - Swarm',
        PlatoonTemplate = 'T3MobileMissile',
        Priority = 550,
        BuilderConditions = {
            { MIBC, 'FactionIndex', { 1 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'LandStrengthRatioGreaterThan', { 1.1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.INDIRECTFIRE * categories.LAND * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3MobileShieldSwarm - Swarm',

        PlatoonTemplate = 'T3MobileShieldSwarm',

        Priority = 550,

        BuilderConditions = {
            { MIBC, 'FactionIndex', { 4 }}, -- 1: UEF, 2: Aeon, 3: Cybran, 4: Seraphim, 5: Nomads 

            { UCBC, 'UnitCapCheckLess', { 0.90 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 6, categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.TECH3 - categories.ENGINEER }},

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.SHIELD }},

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 3, categories.MOBILE * categories.LAND * categories.SHIELD }},
        },
        BuilderType = 'Land',
    },

    Builder { BuilderName = 'T3LandAA - Swarm',
        PlatoonTemplate = 'T3LandAA',
        Priority = 550,
        BuilderConditions = {
            { UCBC, 'UnitCapCheckLess', { 0.95 } },

            { UCBC, 'AirStrengthRatioLessThan', { 1.1 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.95, 1.0 }},

            { EBC, 'GreaterThanEconStorageRatioSwarm', { 0.01, 0.10}},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.FACTORY * categories.LAND * categories.TECH3 }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 } },

            { UCBC, 'PoolLessAtLocation', { 'LocationType', 2, categories.LAND * categories.MOBILE * categories.ANTIAIR * categories.TECH3 }},
        },
        BuilderType = 'Land',
    },
}

-- ===================================================-======================================================== --
--                                         Land Scouts Formbuilder                                              --
-- ===================================================-======================================================== --
BuilderGroup { BuilderGroupName = 'Swarm Land Scout Formers',                               
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

-- Swarm struggles to defend his expansions and other assets, perhaps we should extend platoons towards Expansion bases. 
-- Forward towards --> Expansion.lua to see to the rest of this commentation. 
-- Viewing the LandAttackAISwarm, Having a hard time justifying the usage compared to what other ais do with things like an Upgraded HuntAI 
-- even compared to a Player.

-- Threat Ratio Tuning has been more effective then I thought it would be.
-- He's be able to really turn merging into an effective tool and really not overextend via HuntAI and EnemyZone Formers not forming till he absolutely knows he's in a winning position.
-- This needs to be continually expanded upon especially to his Air which needs to effectively support his land platoons and his naval platoons.

BuilderGroup {
    BuilderGroupName = 'AISwarm Platoon Builder',
    BuildersType = 'PlatoonFormBuilder', 

    Builder {
        BuilderName = 'AI-Swarm Standard Land - Basic',    

        PlatoonTemplate = 'AISwarm LandAttack Micro - Basic',        

        PlatoonAddPlans = { 'DistressResponseAISwarm' },

        Priority = 652,                                          

        InstanceCount = 1,          

        BuilderType = 'Any',

        BuilderConditions = {
            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderData = {
            UseFormation = 'None',
            DistressRange = 100,
            ThreatSupport = 35,
            PlatoonLimit = 12,
            LocationType = 'LocationType',
            PrioritizedCategories = {
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.STRUCTURE * categories.DEFENSE,
                categories.MOBILE * categories.LAND,
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.ALLUNITS,
            }, 
        },
    },

    Builder {
        BuilderName = 'AI-Swarm Standard Land - Advanced - Combat',

        PlatoonTemplate = 'AISwarm LandAttack Micro - Standard', 

        PlatoonAddPlans = { 'DistressResponseAISwarm', 'PlatoonDistressAISwarm' },

        Priority = 650,

        InstanceCount = 4,

        BuilderType = 'Any',

        BuilderConditions = { 
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderData = {
            SearchRadius = BaseEnemyZone,
            LocationType = 'LocationType',
            UseFormation = 'None',
            PlatoonLimit = 25,
            AggressiveMove = false,
            DistressRange = 100,
            ThreatSupport = 75,
            TargetSearchPriorities = {
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.ENGINEER,
                categories.ENERGYPRODUCTION,
                categories.ENERGYSTORAGE,
                categories.MASSEXTRACTION,
                categories.MASSFABRICATION,
                categories.ALLUNITS,
            },
            PrioritizedCategories = {
                categories.COMMAND,
                categories.EXPERIMENTAL,
                categories.MOBILE * categories.LAND * categories.INDIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.DIRECTFIRE,
                categories.MOBILE * categories.LAND * categories.ANTIAIR,
                categories.MOBILE * categories.LAND,
                categories.ENGINEER,
                categories.ENERGYPRODUCTION,
                categories.ENERGYSTORAGE,
                categories.MASSEXTRACTION,
                categories.MASSFABRICATION,
                categories.ALLUNITS,
            },
        },     
    }, 

    Builder {
        BuilderName = 'AI-Swarm Standard Land - Advanced - Economic',

        PlatoonTemplate = 'AISwarm LandAttack Micro - Standard', 

        PlatoonAddPlans = { 'DistressResponseAISwarm', 'PlatoonDistressAISwarm' },

        Priority = 650,

        InstanceCount = 2,

        BuilderType = 'Any',

        BuilderConditions = { 
            { UCBC, 'EnemyUnitsGreaterAtLocationRadiusSwarm', {  BaseEnemyZone, 'LocationType', 0, categories.MOBILE * categories.LAND - categories.NAVAL}}, -- radius, LocationType, unitCount, categoryEnemy
        },
        BuilderData = {
            SearchRadius = BaseEnemyZone,
            LocationType = 'LocationType',
            UseFormation = 'None',
            PlatoonLimit = 25,
            AggressiveMove = false,
            DistressRange = 100,
            ThreatSupport = 75,
            TargetSearchPriorities = {
                categories.ENGINEER,
                categories.ENERGYPRODUCTION,
                categories.ENERGYSTORAGE,
                categories.MASSEXTRACTION,
                categories.MASSFABRICATION,
                categories.STRUCTURE * categories.DEFENSE,
                categories.MOBILE * categories.LAND,
                categories.ALLUNITS,
            },
            PrioritizedCategories = {
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.ENERGYSTORAGE,
                categories.MASSFABRICATION,
                categories.STRUCTURE * categories.DEFENSE,
                categories.MOBILE * categories.LAND,
                categories.ALLUNITS,
            },
        },     
    }, 
}

BuilderGroup {
    BuilderGroupName = 'S3 SACU Formers',                              
    BuildersType = 'PlatoonFormBuilder',
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

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 1000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's

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

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 3000.0 } }, -- relative income (wee need 10000 energy for a teleport. x3 SACU's

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

BuilderGroup {
    BuilderGroupName = 'Swarm AI Defense Formers',                         
    BuildersType = 'PlatoonFormBuilder',
    
    Builder {
        BuilderName = 'AISwarm Raid Early Game',

        PlatoonTemplate = 'AISwarm Mass Raid',

        Priority = 652,

        InstanceCount = 2,

        BuilderType = 'Any',

        BuilderConditions = {  
            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'LessThanGameTimeSeconds', { 300 } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.ENGINEER }},      	
        },
        BuilderData = {
            MarkerType = 'Mass',            
            MoveFirst = 'Random',
            MoveNext = 'Threat',
            ThreatType = 'Economy',			    -- Type of threat to use for gauging attacks
            FindHighestThreat = true,			-- Don't find high threat targets
            MaxThreatThreshold = 185,			-- If threat is higher than this, do not attack
            MinThreatThreshold = 58,			-- If threat is lower than this, do not attack
            AvoidBases = true,
            AvoidBasesRadius = 150,
            AggressiveMove = true,      
            AvoidClosestRadius = 50,
            EarlyRaid = true,
            TargetSearchPriorities = { 
                categories.STRUCTURE * categories.ECONOMIC
            },
            PrioritizedCategories = {   
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.ENERGYSTORAGE,
                categories.MOBILE * categories.LAND,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
            },
        },    
    },

    Builder {
        BuilderName = 'Swarm Mass Raid Standard',       

        PlatoonTemplate = 'AISwarm Mass Raid Large',    

        Priority = 650,                                     

        InstanceCount = 2,                              

        BuilderType = 'Any',

        BuilderConditions = {   
            { UCBC, 'GreaterThanGameTimeSeconds', { 300 } },

            { UCBC, 'LessThanGameTimeSeconds', { 720 } },
            
            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.ENGINEER } },
        },
        BuilderData = {
            IncludeWater = false,
            IgnoreFriendlyBase = true,
            LocationType = 'LocationType',
            MaxPathDistance = BaseEnemyZone, -- custom property to set max distance before a transport will be requested only used by GuardMarker plan
            FindHighestThreat = true,			-- Don't find high threat targets
            MaxThreatThreshold = 158,			-- If threat is higher than this, do not attack
            MinThreatThreshold = 58,		    -- If threat is lower than this, do not attack
            AvoidBases = true,
            AvoidBasesRadius = 135,
            AggressiveMove = false,      
            AvoidClosestRadius = 10,
            UseFormation = 'NoFormation',
            TargetSearchPriorities = { 
                categories.STRUCTURE * categories.ECONOMIC
            },
            PrioritizedCategories = {  
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.ENERGYSTORAGE, 
                categories.MOBILE * categories.LAND,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
            },
        },
    },

    Builder {
        BuilderName = 'Swarm Mass Raid Standard - Extended', 

        PlatoonTemplate = 'AISwarm Mass Raid Large',               

        Priority = 653,                                     

        InstanceCount = 2,                            

        BuilderType = 'Any',

        BuilderConditions = {   
            --{ UCBC, 'ScalePlatoonSizeSwarm', { 'LocationType', 'LAND', categories.MOBILE * categories.LAND - categories.ENGINEER - categories.EXPERIMENTAL } },

            { UCBC, 'GreaterThanGameTimeSeconds', { 720 } },

            { UCBC, 'LessThanGameTimeSeconds', { 1500 } },

            { UCBC, 'LandStrengthRatioGreaterThan', { 1.2 } },
            
            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },

            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.ENGINEER } },
        },
        BuilderData = {
            IncludeWater = false,
            IgnoreFriendlyBase = true,
            LocationType = 'LocationType',
            MaxPathDistance = BaseEnemyZone, -- custom property to set max distance before a transport will be requested only used by GuardMarker plan
            FindHighestThreat = true,			-- Don't find high threat targets
            MaxThreatThreshold = 158,			-- If threat is higher than this, do not attack
            MinThreatThreshold = 58,		    -- If threat is lower than this, do not attack
            AvoidBases = true,
            AvoidBasesRadius = 120,
            AggressiveMove = false,      
            AvoidClosestRadius = 10,
            UseFormation = 'NoFormation',
            TargetSearchPriorities = { 
                categories.STRUCTURE * categories.ECONOMIC
            },
            PrioritizedCategories = {  
                categories.ENGINEER,
                categories.MASSEXTRACTION,
                categories.ENERGYPRODUCTION,
                categories.ENERGYSTORAGE, 
                categories.MOBILE * categories.LAND,
                categories.STRUCTURE * categories.DEFENSE,
                categories.STRUCTURE,
            },
        },
    },
}

