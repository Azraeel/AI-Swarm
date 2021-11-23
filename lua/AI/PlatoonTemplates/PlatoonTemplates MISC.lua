
PlatoonTemplate {
    Name = 'AddToMassExtractorUpgradePlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.MASSEXTRACTION * (categories.TECH1 + categories.TECH2 + categories.TECH3) , 1, 300, 'support', 'none' }
    },
} 

PlatoonTemplate {
    Name = 'AddToNukePlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.STRUCTURE * categories.NUKE * (categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL) , 1, 300, 'support', 'none' }
    },
}

PlatoonTemplate {
    Name = 'AddToAntiNukePlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.STRUCTURE * categories.DEFENSE * categories.ANTIMISSILE * categories.TECH3 , 1, 300, 'support', 'none' }
    },
}

PlatoonTemplate {
    Name = 'AddToArtilleryPlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { (categories.STRUCTURE * categories.ARTILLERY * ( categories.TECH3 + categories.EXPERIMENTAL )) + categories.SATELLITE , 1, 300, 'support', 'none' }
    },
}

PlatoonTemplate {
    Name = 'S1EngineerTransfer',
    Plan = 'TransferAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.ENGINEER * categories.TECH1, 1, 1, 'support', 'none' },
    },
}

PlatoonTemplate {
    Name = 'S2EngineerTransfer',
    Plan = 'TransferAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.ENGINEER * categories.TECH2, 1, 1, 'support', 'none' },
    },
}

PlatoonTemplate {
    Name = 'SACUEngineerTransfer',
    Plan = 'TransferAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.ENGINEER * categories.SUBCOMMANDER, 1, 1, 'support', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AddShieldToACUChampionPlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { (categories.MOBILE * categories.SHIELD) + (categories.MOBILE * categories.STEALTHFIELD) * (categories.TECH2 + categories.TECH3), 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddTankToACUChampionPlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL, 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'AddAAToACUChampionPlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.ANTIAIR, 1, 1, 'support', 'none' }
    },
}

PlatoonTemplate {
    Name = 'S1Reclaim',
    Plan = 'ReclaimAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.COMMAND, 1, 1, "support", "None" }
    },
}

PlatoonTemplate {
    Name = 'T2TacticalLauncherSwarm',
    Plan = 'TMLAISwarm',
    GlobalSquads = {
        { categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM, 1, 1, 'attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'CommanderBuilderSwarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'support', 'None' }
    },
}


PlatoonTemplate {
    Name = 'T1EngineerBuilderSwarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },        
}

PlatoonTemplate {
    Name = 'T1EngineerBuilderMexSwarm',
    Plan = 'MexBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },        
}

PlatoonTemplate {
    Name = 'T2EngineerBuilderSwarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH2 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },        
}

PlatoonTemplate {
    Name = 'T3EngineerBuilderSUBSwarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.SUBCOMMANDER * ( categories.ENGINEERPRESET + categories.RASPRESET ) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T3EngineerBuildernoSUBSwarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'EngineerBuilderALLTECHSwarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * (categories.TECH1 + categories.TECH2 + categories.TECH3 + categories.SUBCOMMANDER) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'EngineerBuilderT2T3Swarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * (categories.TECH2 + categories.TECH3) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'EngineerBuilderT3&SUBSwarm',
    Plan = 'EngineerBuildAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * (categories.TECH3 + categories.RASPRESET + categories.ENGINEERPRESET) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T1EngineerAssistSwarm',
    Plan = 'ManagerEngineerAssistAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T2EngineerAssistSwarm',
    Plan = 'ManagerEngineerAssistAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH2 - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T3EngineerAssistnoSUB',
    Plan = 'ManagerEngineerAssistAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T3EngineerAssistSUB',
    Plan = 'ManagerEngineerAssistAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * categories.SUBCOMMANDER * ( categories.ENGINEERPRESET + categories.RASPRESET ) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'EngineerAssistALLTECH',
    Plan = 'ManagerEngineerAssistAISwarm',
    GlobalSquads = {
        { categories.ENGINEER * (categories.TECH1 + categories.TECH2 + categories.TECH3 + categories.SUBCOMMANDER) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}