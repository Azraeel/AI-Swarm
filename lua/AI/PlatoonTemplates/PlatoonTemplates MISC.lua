
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
    Name = 'AddEngineerToACUChampionPlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.STATIONASSISTPOD, 1, 1, 'support', 'none' }
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
    Name = 'AddSACUToACUChampionPlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.RASPRESET - categories.ENGINEERPRESET, 1, 1, 'support', 'none' }
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
    Name = 'AddGunshipACUChampionPlatoon',
    Plan = 'SwarmPlatoonMerger',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.TRANSPORTFOCUS, 1, 1, 'support', 'none' }
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
    Name = 'EngineerBuilder',
    Plan = 'EngineerBuildAISWARM',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH1 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },        
}

PlatoonTemplate {
    Name = 'T2EngineerBuilder',
    Plan = 'EngineerBuildAISWARM',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH2 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },        
}

PlatoonTemplate {
    Name = 'T3EngineerBuilderSUB',
    Plan = 'EngineerBuildAISWARM',
    GlobalSquads = {
        { categories.ENGINEER * categories.SUBCOMMANDER * ( categories.ENGINEERPRESET + categories.RASPRESET ) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T3EngineerBuildernoSUB',
    Plan = 'EngineerBuildAISWARM',
    GlobalSquads = {
        { categories.ENGINEER * categories.TECH3 - categories.SUBCOMMANDER - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'EngineerBuilderALLTECH',
    Plan = 'EngineerBuildAISWARM',
    GlobalSquads = {
        { categories.ENGINEER * (categories.TECH1 + categories.TECH2 + categories.TECH3) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'EngineerBuilderT2T3',
    Plan = 'EngineerBuildAISWARM',
    GlobalSquads = {
        { categories.ENGINEER * (categories.TECH2 + categories.TECH3) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}

PlatoonTemplate {
    Name = 'EngineerBuilderT3&SUB',
    Plan = 'EngineerBuildAISWARM',
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
        { categories.ENGINEER * (categories.TECH1 + categories.TECH2 + categories.TECH3) - categories.COMMAND, 1, 1, 'support', 'None' }
    },
}