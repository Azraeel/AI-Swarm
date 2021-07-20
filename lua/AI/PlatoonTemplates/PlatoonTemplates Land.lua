
-- ==== Global Form platoons ==== --
PlatoonTemplate {
    Name = 'CDR Attack Swarm',
    Plan = 'ACUChampionPlatoonSwarm',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro - Intercept',
    Plan = 'InterceptorAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND + (categories.MOBILE * categories.EXPERIMENTAL) - categories.ANTIAIR - categories.ENGINEER - categories.SCOUT, 4, 100, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro - Standard',
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND + (categories.MOBILE * categories.EXPERIMENTAL) - categories.ANTIAIR - categories.ENGINEER - categories.SCOUT, 4, 50, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm T1 Spam',
    Plan = 'HuntAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.MOBILE * categories.TECH1 - categories.EXPERIMENTAL - categories.ANTIAIR - categories.ENGINEER - categories.SCOUT, 2, 100, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Mass Raid',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 2, 3, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Mass Raid Large',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 4, 15, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Early Guard Marker',
    Plan = 'GuardMarkerSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 3,10, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm - Guard Marker - Pressure',
    Plan = 'GuardMarkerSwarm',    
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
    Plan = 'LandAttackAISwarm',
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
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
        3,
        3,
        'attack',
        'GrowthFormation' },
    },
}

PlatoonTemplate {
    Name = 'Hero Fight 1 48',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.SHIELD - categories.STEALTHFIELD - categories.ANTIAIR - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 48, 'Attack', 'none' },
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

-----------------------

-- Archived As This is Mainly for Sorian Edit AI Mod Now -- 

-- Archived Unlocked --

-----------------------

PlatoonTemplate {
    Name = 'AI-Swarm Attack Force - United Land - Small',
    Plan = 'AttackForceAISwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER, 0, 5, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 15, 40, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 4, 15, 'artillery', 'none' },

        { categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 8, 'guard', 'none' },

        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 5, 'support', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AI-Swarm Attack Force - United Land - Large',
    Plan = 'AttackForceAISwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER, 1, 10, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 40, 100, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 10, 30, 'artillery', 'none' },

        { categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 15, 'guard', 'none' },

        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 3, 9, 'support', 'none' },
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


