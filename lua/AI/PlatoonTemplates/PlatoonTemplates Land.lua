
-- ==== Global Form platoons ==== --
PlatoonTemplate {
    Name = 'CDR Attack Swarm',
    Plan = 'ACUChampionPlatoonSwarm',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro - Standard',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND + (categories.MOBILE * categories.EXPERIMENTAL) - categories.ANTIAIR - categories.ENGINEER - categories.SCOUT, 4, 25, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm T1 Spam',
    Plan = 'HuntAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.MOBILE * categories.TECH1 - categories.ANTIAIR - categories.ENGINEER - categories.SCOUT, 2, 100, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Mass Raid',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER, 1, 3, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Mass Raid Large',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER, 3, 15, 'attack', 'none' },
        { categories.TECH1 * categories.LAND * categories.MOBILE - categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER, 0, 6, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Standard Guard Marker',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER, 3, 10, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Large Guard Marker',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 8, 20, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm - Guard Base',
    Plan = 'GuardBaseSwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 5, 20, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm - Experimental Group', 
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
        1,
        1,
        'attack',
        'GrowthFormation' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm - Experimental', 
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
        3,
        3,
        'attack',
        'GrowthFormation' },
    },
}

PlatoonTemplate {
    Name = 'T1EngineerGuardSwarm',
    Plan = 'None',
    GlobalSquads = {
        { categories.DIRECTFIRE * categories.TECH1 * categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER, 1, 3, 'guard', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T3ExperimentalAAGuard',
    Plan = 'GuardUnit',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * (categories.TECH3 + categories.TECH2) * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER, 3, 15, 'guard', 'None' },
    },
}

PlatoonTemplate {
    Name = 'S1 LandDFBot',
    FactionSquads = {
        UEF = {
            { 'uel0106', 1, 1, 'attack', 'None' }
        },
        Aeon = {
            { 'ual0106', 1, 1, 'attack', 'None' }
        },
        Cybran = {
            { 'url0106', 1, 1, 'attack', 'None' }
        },
        Seraphim = {
            { 'xsl0201', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0106', 1, 1, 'attack', 'none' }
        },
    }
}
PlatoonTemplate {
    Name = 'T2AttackTank',
    FactionSquads = {
        UEF = {
            { 'del0204', 1, 1, 'attack', 'None' },
        },
        Cybran = { 
            { 'drl0204', 1, 1, 'attack', 'None' },
        },
    },
}
PlatoonTemplate {
    Name = 'T2AeonBlaze',
    FactionSquads = {
        Aeon = {
            { 'xal0203', 1, 1, 'attack', 'None' }
        },
    },
}
PlatoonTemplate {
    Name = 'T2MobileShields',
    FactionSquads = {
        UEF = {
            { 'uel0307', 1, 1, 'support', 'none' }
        },
        Aeon = {
            { 'ual0307', 1, 1, 'support', 'none' }
        },
    }
}

-- Remove Loyalist and Titans -- Just Not Effective In-Game
PlatoonTemplate {
    Name = 'T3LandBotSwarm',
    FactionSquads = {
        Aeon = {
            { 'ual0303', 1, 1, 'attack', 'none' },
        },
        Seraphim = {
            { 'xsl0303', 1, 1, 'attack', 'none' },
        },
    }
}

-- Added Loyalist and Titans, back into the game; now with Micro Abilities they are now viable. --
PlatoonTemplate {
    Name = 'T3LightBotSwarm',
    FactionSquads = {
        UEF = {
            { 'uel0303', 1, 1, 'attack', 'none' },
        },
        Cybran = {
            { 'url0303', 1, 1, 'attack', 'none' },
        },
    }
}


