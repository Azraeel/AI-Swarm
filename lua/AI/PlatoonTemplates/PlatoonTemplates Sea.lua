PlatoonTemplate {
    Name = 'Swarm Sea Attack Small',
    Plan = 'NavalAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.ENGINEER, 3, 10, 'Attack', 'GrowthFormation' }
    },
}

PlatoonTemplate {
    Name = 'Swarm Sea Attack Medium',
    Plan = 'NavalAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.ENGINEER, 5, 20, 'Attack', 'GrowthFormation' }
    },
}

PlatoonTemplate {
    Name = 'Swarm Sea Attack Large',
    Plan = 'NavalAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER - categories.ENGINEER, 10, 40, 'Attack', 'GrowthFormation' }
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

