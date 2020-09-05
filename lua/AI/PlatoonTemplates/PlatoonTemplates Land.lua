
-- ==== Global Form platoons ==== --
PlatoonTemplate {
    Name = 'CDR Attack',
    Plan = 'ACUAttackAISwarm',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'AISwarm Intercept',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 1, 100, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro - Standard',
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 4, 50, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'Hero Fight 5 48',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.SHIELD - categories.STEALTHFIELD - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 4, 48, 'Attack', 'none' },
        { categories.MOBILE * (categories.SHIELD + categories.STEALTHFIELD) - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 0, 8, 'support', 'none' }
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
        Cybran = { #DUNCAN - Was UEF in orig
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


