
-- ==== Global Form platoons ==== --
PlatoonTemplate {
    Name = 'CDR Attack',
    Plan = 'ACUAttackAISwarm',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    }
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Intercept',
    Plan = 'InterceptorAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 1, 8, 'attack', 'none' },
        { categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 0, 3, 'artillery', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro Small',
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 4, 20, 'attack', 'none' },
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 1, 4, 'attack', 'none' },
        { categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 1, 5, 'artillery', 'none' },
        { categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 0, 4, 'guard', 'none' },
        -- { categories.LAND * categories.SCOUT, 0, 1, 'scout', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro Big',
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 8, 40, 'attack', 'none' },
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 1, 4, 'attack', 'none' },
        { categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 1, 12, 'artillery', 'none' },
        { categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 1, 8, 'guard', 'none' },
        -- { categories.LAND * categories.SCOUT, 0, 1, 'scout', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro Raid',
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.DIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 3, 20, 'attack', 'none' },
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 0, 4, 'attack', 'none' },
        { categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 0, 5, 'artillery', 'none' },
        { categories.MOBILE * categories.LAND * categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 0, 4, 'guard', 'none' },
        -- { categories.LAND * categories.SCOUT, 0, 1, 'scout', 'none' },
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
    Name = 'AISwarm LandAttack Experimental', 
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
        1,
        3,
        'attack',
        'GrowthFormation' },
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


