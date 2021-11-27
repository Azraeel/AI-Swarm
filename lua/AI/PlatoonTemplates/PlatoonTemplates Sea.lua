PlatoonTemplate {
    Name = 'Swarm Sea Attack',
    Plan = 'NavalAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL + (categories.NAVAL * categories.EXPERIMENTAL) - categories.CARRIER - categories.ENGINEER - categories.NUKE, 1, 100, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'Swarm SeaNuke',
    Plan = 'NavalForceAI',
    GlobalSquads = {
        { categories.NAVAL * categories.NUKE, 1, 1, 'Attack', 'none' }
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

