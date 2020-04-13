PlatoonTemplate {
    Name = 'Swarm Sea Attack',
    Plan = 'NavalAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.ENGINEER - categories.NUKE, 1, 100, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'Swarm SeaNuke',
    Plan = 'NavalForceAI',
    GlobalSquads = {
        { categories.NAVAL * categories.NUKE, 1, 1, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'S4-ExperimentalSea 1 1',
    Plan = 'NavalAttackAISwarm',
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE - categories.ENGINEER, 1, 1, 'attack', 'none' }
    },
}

-- Fix: This Template is missing in Nomads Mod
PlatoonTemplate {
    Name = 'T3SubKiller',
    FactionSquads = {
        Seraphim = {
            { 'xss0304', 1, 1, 'attack', 'None' },
        },
    },
}

