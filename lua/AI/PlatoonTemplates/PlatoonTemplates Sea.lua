PlatoonTemplate {
    Name = 'Swarm Sea Attack Small',
    Plan = 'NavalForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.ENGINEER - categories.NUKE, 3, 10, 'Attack', 'GrowthFormation' }
    },
}

PlatoonTemplate {
    Name = 'Swarm Sea Attack Medium',
    Plan = 'NavalForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.ENGINEER - categories.NUKE, 5, 20, 'Attack', 'GrowthFormation' }
    },
}

PlatoonTemplate {
    Name = 'Swarm Sea Attack Large',
    Plan = 'NavalForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.ENGINEER - categories.NUKE, 10, 40, 'Attack', 'GrowthFormation' }
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
    Name = 'U4-ExperimentalSea 1 1',
    Plan = 'NavalAttackAIUveso',
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

