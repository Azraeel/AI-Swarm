local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'

local BasePanicZone, BaseMilitaryZone, BaseEnemyZone = import('/mods/AI-Swarm/lua/AI/swarmutilities.lua').GetDangerZoneRadii()

local MaxCapFactory = 0.015 -- 0.015% of all units can be factories (STRUCTURE * FACTORY)
local MaxCapStructure = 0.12 -- 12% of all units can be structures (STRUCTURE -MASSEXTRACTION -DEFENSE -FACTORY)

local HaveLessThanFiveT2LandFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.LAND * categories.TECH2, false, true )) >= 5 then
        return 0, false
	end
	
	return self.Priority,true
end

local HaveLessThanThreeT2AirFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.AIR * categories.TECH2, false, true )) >= 3 then
        return 0, false
	end
	
	return self.Priority,true
end

local HaveLessThanThreeT2NavalFactory = function( self, aiBrain )
	
	if table.getn( aiBrain:GetListOfUnits( categories.FACTORY * categories.NAVAL * categories.TECH2, false, true )) >= 3 then
        return 0, false
	end
	
	return self.Priority,true
end

-- ===================================================-======================================================== --
-- ==                                       Early T1 Phase - Adaptive                                        == --
-- ===================================================-======================================================== --

BuilderGroup {
    BuilderGroupName = 'Swarm Factory Builders Naval',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'S1 Sea Factory 1st',
        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',
        Priority = 655,
        DelayEqualBuildPlattons = {'Factories', 3},
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL - categories.SUPPORTFACTORY } },

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 250, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }},

            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1SeaFactory',
                },
            }
        }
    },
    -- ================== --
    --    TECH 1 Enemy    --
    -- ================== --
    Builder {
        BuilderName = 'Swarm Naval Factory Mass > MassStorage',

        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 600,

        PriorityFunction = HaveLessThanThreeT2NavalFactory,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},
            
            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 250, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }},          
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.TECH1 * categories.NAVAL }},
           
            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapFactory , '<', categories.STRUCTURE * categories.FACTORY * categories.NAVAL } }, 
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1SeaFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Naval Factory Enemy - Naval Ratio',
        
        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanThreeT2NavalFactory,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { UCBC, 'NavalStrengthRatioLessThan', { 1.5 } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 250, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.NAVAL * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                NearMarkerType = 'Naval Area',
                LocationRadius = 90,
                Location = 'LocationType',
                BuildStructures = {
                    'T1SeaFactory',
                },
            }
        }
    },
}

-- Perhaps adjusting the Factory Priority and Such depending on aiBrain.SelfExtractorCount is Viable?
-- Perhaps turning back on factory incase Mass Income Late Game allows additional factory building specifically.
-- Straight up building on T2-T3 Factories. 
-- Were going to start allowing T2-T3 Factories to be built straight up. 
-- This is because of how the Tech Progression is so fast and eco is so good nowadays especially on mass maps that its viable for Swarm.

BuilderGroup { BuilderGroupName = 'Swarm Adaptive Factory Build',
    BuildersType = 'EngineerBuilder',

    Builder {
        BuilderName = 'Swarm Land Factory Mass > MassStorage',

        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanFiveT2LandFactory,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },
            
            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }},         
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildClose = false,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    
    Builder {
        BuilderName = 'Swarm Land Factory Enemy - Land Ratio',

        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanFiveT2LandFactory,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { UCBC, 'LandStrengthRatioLessThan', { 1.5 } },

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Air Factory Mass > MassStorage',

        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 645,

        DelayEqualBuildPlattons = {'Factories', 3},

        PriorityFunction = HaveLessThanThreeT2AirFactory,

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'Back',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Air Factory > Air Ratio',

        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanThreeT2AirFactory,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'AirStrengthRatioLessThan', { 1 } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 0.85, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH1 + categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'Back',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',  
                },
            }
        }
    },

    -- Here Begins T2 Factories

    Builder {
        BuilderName = 'Swarm Land Factory Mass > MassStorage - T2',

        PlatoonTemplate = 'EngineerBuilderT2T3Swarm',

        Priority = 700,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },
            
            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},         
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildClose = false,
                BuildStructures = {
                    'T2SupportLandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Air Factory Mass > MassStorage - T2',

        PlatoonTemplate = 'EngineerBuilderT2T3Swarm',

        Priority = 695,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'Back',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T2SupportAirFactory',  
                },
            }
        }
    },

    -- Here Begins T3 Factories

    Builder {
        BuilderName = 'Swarm Land Factory Mass > MassStorage - T3',

        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',

        Priority = 935,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { MIBC, 'CanPathToCurrentEnemySwarm', { true, 'LocationType' } },
            
            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.02 }},         
            
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 2, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) }},
           
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.FACTORY * categories.LAND * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'Forward',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildClose = false,
                BuildStructures = {
                    'T3SupportLandFactory',
                },
            }
        }
    },

    Builder {
        BuilderName = 'Swarm Air Factory Mass > MassStorage - T3',

        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',

        Priority = 935,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.02 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, categories.STRUCTURE * categories.FACTORY * categories.AIR * (categories.TECH2 + categories.TECH3) }},
        },
        BuilderType = 'Any',
        BuilderData = {
            BuildClose = false,
            Construction = {
                AdjacencyBias = 'Back',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T3SupportAirFactory',  
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Factory Builders Expansions',
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'All Land Factory Expansions',

        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanFiveT2LandFactory,

        InstanceCount = 1,                                                      -- Number of plattons that will be formed with this template.

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },

            { UCBC, 'CanPathLandBaseToLandTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.LAND }},

            { UCBC, 'LandStrengthRatioLessThan', { 1.25 } },

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.LAND * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'ForwardClose',
                AdjacencyPriority = {
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },

    Builder { BuilderName = 'All Air Factory Expansions',

        PlatoonTemplate = 'EngineerBuilderALLTECHSwarm',

        Priority = 650,

        PriorityFunction = HaveLessThanThreeT2AirFactory, 

        InstanceCount = 1,

        DelayEqualBuildPlattons = {'Factories', 3},

        BuilderConditions = {
            { UCBC, 'CheckBuildPlattonDelay', { 'Factories' }},

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },

            { UCBC, 'CanPathNavalBaseToNavalTargetsSwarm', {  'LocationType', categories.STRUCTURE * categories.FACTORY * categories.AIR }},

            { UCBC, 'AirStrengthRatioLessThan', { 0.75 } },

            { EBC, 'MassToFactoryRatioBaseCheckSwarm', { 'LocationType' } },

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }}, 

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.FACTORY * categories.AIR * categories.TECH1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyBias = 'BackClose',
                AdjacencyPriority = {
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH2,
                    categories.HYDROCARBON,
                    categories.ENERGYPRODUCTION * categories.TECH1,
                    categories.MASSEXTRACTION,
                    categories.MASSPRODUCTION,
                },
                Location = 'LocationType',
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Gate Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U-T3 Gate Cap - Main Base',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 1350,
        BuilderConditions = {
        	{ EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.02, 1.03 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'IsEngineerNotBuildingSwarm', { categories.STRUCTURE * categories.GATE * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Gate' } },

            { UCBC, 'BuildOnlyOnLocationSwarm', { 'LocationType', 'MAIN' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.MASSPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.MASSEXTRACTION * categories.TECH3,
                },
                BuildClose = true,
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3QuantumGate',
                },
            }
        }
    },

    Builder { BuilderName = 'U-T3 Gate Cap - Expansions',
        PlatoonTemplate = 'EngineerBuilderT3&SUBSwarm',
        Priority = 1300,
        BuilderConditions = {
        	{ EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.03, 1.04 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'IsEngineerNotBuildingSwarm', { categories.STRUCTURE * categories.GATE * categories.TECH3 }},

            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * categories.TECH3 } },

            { UCBC, 'BuildNotOnLocationSwarm', { 'LocationType', 'MAIN' } },

            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Gate' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyPriority = {
                    categories.MASSPRODUCTION * categories.TECH3,
                    categories.ENERGYPRODUCTION * categories.TECH3,
                    categories.MASSEXTRACTION * categories.TECH3,
                },
                BuildClose = true,
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3QuantumGate',
                },
            }
        }
    },
}

BuilderGroup { BuilderGroupName = 'Swarm Air Staging Platform Builders',                               -- BuilderGroupName, initalized from AIBaseTemplates in "\lua\AI\AIBaseTemplates\"
    BuildersType = 'EngineerBuilder',
    
    Builder { BuilderName = 'U-T1 Air Staging 1st',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
          
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.STRUCTURE * categories.ENERGYPRODUCTION * (categories.TECH2 + categories.TECH3) } },
            
            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } }, 

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.0, 1.0 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 200, 2000}},
           
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder { BuilderName = 'U-T1 Air Staging',
        PlatoonTemplate = 'T1EngineerBuilderSwarm',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'HaveUnitRatioVersusEnemySwarm', { 0.05, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM, '<', categories.MOBILE * categories.AIR } },

            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},

            { EBC, 'GreaterThanEconTrendOverTimeSwarm', { 0.0, 0.0 } },

            { EBC, 'GreaterThanEconEfficiencyOverTimeSwarm', { 1.01, 1.02 }},

            { EBC, 'GreaterThanEconStorageCurrentSwarm', { 100, 1000}},

            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM }},

            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.STRUCTURE * categories.AIRSTAGINGPLATFORM  }},
           
            { UCBC, 'HaveUnitRatioVersusCapSwarm', { MaxCapStructure , '<', categories.STRUCTURE - categories.MASSEXTRACTION - categories.DEFENSE - categories.FACTORY } },
        },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 1,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T2AirStagingPlatform',
                },
                Location = 'LocationType',
            }
        }
    },
} 

