-- Should we have Teleport SACUs -- Function is completely done with improvements... 
-- But Currectly unsure if we should be throwing valuable Buildpower into a base and basically gifting mass.

-- Currently I'll be testing it out tho...


PlatoonTemplate {
    Name = 'S3 SACU Teleport 1 1',
    Plan = 'S3 SACUTeleportAISwarm',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 1, 1, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'S3 SACU Teleport 3 3',
    Plan = 'S3 SACUTeleportAISwarm',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 3, 3, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'S3 SACU Teleport 6 6',
    Plan = 'S3 SACUTeleportAISwarm',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 6, 6, 'Attack', 'None' }
    },        
}
PlatoonTemplate {
    Name = 'S3 SACU Teleport 9 9',
    Plan = 'S3 SACUTeleportAISwarm',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 9, 9, 'Attack', 'None' }
    },        
} 
PlatoonTemplate {
    Name = 'S3 SACU Fight 3 7',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.SUBCOMMANDER - categories.ENGINEERPRESET - categories.RASPRESET, 3, 7, 'Attack', 'None' }
    },        
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU RAMBO',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.RAMBOPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU RAMBO preset 12345',
    FactionSquads = {
        UEF = {
            { 'uel0301_RAMBO', 1, 1, 'Attack', 'None' }
        },
        Aeon = {
            { 'ual0301_RAMBO', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_RAMBO', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_RAMBO', 1, 1, 'Attack', 'none' }
        },
        Nomads = {
            { 'xnl0301_RAMBO', 1, 1, 'Attack', 'none' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU ENGINEER',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.ENGINEERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU ENGINEER preset 12345',
    FactionSquads = {
        UEF = {
            { 'uel0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Aeon = {
            { 'ual0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
        Nomads = {
            { 'xnl0301_ENGINEER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU RAS',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.RASPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU RAS preset 123x5',
    FactionSquads = {
        UEF = {
            { 'uel0301_RAS', 1, 1, 'Attack', 'None' }
        },
        Aeon = {
            { 'ual0301_RAS', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_RAS', 1, 1, 'Attack', 'None' }
        },
        Nomads = {
            { 'xnl0301_RAS', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU COMBAT',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.COMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU COMBAT preset 1x34x',
    FactionSquads = {
        UEF = {
            { 'uel0301_COMBAT', 1, 1, 'Attack', 'None' }
        },
        Cybran = {
            { 'url0301_COMBAT', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_COMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU NANOCOMBAT',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.NANOCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU NANOCOMBAT preset x2x4x',
    FactionSquads = {
        Aeon = {
            { 'ual0301_NANOCOMBAT', 1, 1, 'Attack', 'None' }
        },
        Seraphim = {
            { 'xsl0301_NANOCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU BUBBLESHIELD',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.BUBBLESHIELDPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU BUBBLESHIELD preset 1xxxx',
    FactionSquads = {
        UEF = {
            { 'uel0301_BUBBLESHIELD', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU INTELJAMMER',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.INTELJAMMERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU INTELJAMMER preset 1xxxx',
    FactionSquads = {
        UEF = {
            { 'uel0301_INTELJAMMER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU SIMPLECOMBAT',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.SIMPLECOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU SIMPLECOMBAT preset x2xxx',
    FactionSquads = {
        Aeon = {
            { 'ual0301_SIMPLECOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU SHIELDCOMBAT',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.SHIELDCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU SHIELDCOMBAT preset x2xxx',
    FactionSquads = {
        Aeon = {
            { 'ual0301_SHIELDCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU ANTIAIR',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.ANTIAIRPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU ANTIAIR preset xx3xx',
    FactionSquads = {
        Cybran = {
            { 'url0301_ANTIAIR', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU STEALTH',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.STEALTHPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU STEALTH preset xx3xx',
    FactionSquads = {
        Cybran = {
            { 'url0301_STEALTH', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU CLOAK',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.CLOAKPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU CLOAK preset xx3xx',
    FactionSquads = {
        Cybran = {
            { 'url0301_CLOAK', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU MISSILE',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.MISSILEPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU MISSILE preset xxx4x',
    FactionSquads = {
        Seraphim = {
            { 'xsl0301_MISSILE', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU ADVANCEDCOMBAT',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.ADVANCEDCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU ADVANCEDCOMBAT preset xxx4x',
    FactionSquads = {
        Seraphim = {
            { 'xsl0301_ADVANCEDCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU ROCKET',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.ROCKETPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU ROCKET preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_ROCKET', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------

PlatoonTemplate {
    Name = 'S3 SACU ANTINAVAL',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.ANTINAVALPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU ANTINAVAL preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_ANTINAVAL', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU AMPHIBIOUS',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.AMPHIBIOUSPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU AMPHIBIOUS preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_AMPHIBIOUS', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU GUNSLINGER',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.GUNSLINGERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU GUNSLINGER preset  xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_GUNSLINGER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU NATURALPRODUCER',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.NATURALPRODUCERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU NATURALPRODUCER preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_NATURALPRODUCER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU DEFAULT',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.DEFAULTPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU DEFAULT preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_DEFAULT', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU HEAVYTROOPER',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.HEAVYTROOPERPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU HEAVYTROOPER preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_HEAVYTROOPER', 1, 1, 'Attack', 'None' }
        },
    }
}

-- ------------------------------------------------------------------------------------------------
PlatoonTemplate {
    Name = 'S3 SACU FASTCOMBAT',
    Plan = 'HeroFightPlatoonSwarm',
    GlobalSquads = {
        { categories.FASTCOMBATPRESET , 1, 1, 'support', 'none' }
    },
}
PlatoonTemplate {
    Name = 'S3 SACU FASTCOMBAT preset xxxx5',
    FactionSquads = {
        Nomads = {
            { 'xnl0301_FASTCOMBAT', 1, 1, 'Attack', 'None' }
        },
    }
}