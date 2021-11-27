-- categories.FLOATING does not exist if all units with this category are disabled (mod manager)
if not categories.FLOATING then categories.FLOATING = categories.HOVER end

-- ==== Global Form platoons ==== --

PlatoonTemplate {
    Name = 'S123 Hover 1 10',
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.HOVER * categories.FLOATING - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 100, 'Attack', 'none' }
    }
}

PlatoonTemplate {
    Name = 'S123 Amphibious 1 10',
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AMPHIBIOUS - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 100, 'Attack', 'none' }
    }
}

PlatoonTemplate {
    Name = 'S1 LandSquads Amphibious',
    FactionSquads = {
        UEF = {
--            { 'abc0000', 1, 1, 'attack', 'none' }
        },
        Aeon = {
            { 'ual0201', 1, 1, 'attack', 'none' }
        },
        Cybran = {
--            { 'abc0000', 1, 1, 'attack', 'none' }
        },
        Seraphim = {
            { 'xsl0103', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0106', 1, 1, 'attack', 'none' },
        },
    }
}

PlatoonTemplate {
    Name = 'S2 LandSquads Amphibious',
    FactionSquads = {
        UEF = {
            { 'uel0203', 1, 1, 'attack', 'none' }
        },
        Aeon = {
            { 'xal0203', 1, 1, 'attack', 'none' }
        },
        Cybran = {
            { 'url0203', 1, 1, 'attack', 'none' }
        },
        Seraphim = {
            { 'xsl0203', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0203', 1, 1, 'attack', 'none' },
            { 'xnl0111', 1, 1, 'attack', 'none' }
        },
    }
}

PlatoonTemplate {
    Name = 'S3 LandSquads Amphibious',
    FactionSquads = {
        UEF = {
            { 'xel0305', 1, 1, 'attack', 'none' }
        },
        Aeon = {
            { 'dal0310', 1, 1, 'attack', 'none' }
        },
        Cybran = {
            { 'xrl0305', 1, 1, 'attack', 'none' }
        },
        Seraphim = {
            { 'xsl0303', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0303', 1, 1, 'attack', 'none' }
        },
    }
}
