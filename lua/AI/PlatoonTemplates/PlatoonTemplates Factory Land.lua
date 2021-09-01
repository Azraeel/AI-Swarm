PlatoonTemplate { Name = 'T1LandOpeningQueue',
    FactionSquads = {
        UEF = {
            { 'uel0201', 1, 2, 'Attack', 'none' },		-- Striker Medium Tank
            { 'uel0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'uel0104', 1, 1, 'Attack', 'none' },      -- Mobile Anti-Air
            { 'uel0201', 1, 2, 'Attack', 'none' },      -- Striker Medium Tank
            --{ 'uel0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'uel0103', 1, 1, 'Attack', 'none' },      -- Artillery
            --{ 'uel0105', 1, 1, 'Support', 'None' },     -- Engineer
        },
        Aeon = {
            { 'ual0201', 1, 2, 'Attack', 'none' },		-- Light Hover tank
            { 'ual0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'ual0104', 1, 1, 'Attack', 'none' },      -- Mobile Anti-Air
            { 'ual0201', 1, 2, 'Attack', 'none' },      -- Light Hover tank
            --{ 'ual0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'ual0103', 1, 1, 'Attack', 'none' },      -- Artillery
            --{ 'ual0105', 1, 1, 'Support', 'None' },     -- Engineer
        },
        Cybran = {
            { 'url0107', 1, 2, 'Attack', 'none' },		-- Mantis
            { 'url0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'url0104', 1, 1, 'Attack', 'none' },      -- Mobile Anti-Air
            { 'url0107', 1, 2, 'Attack', 'none' },      -- Mantis
            --{ 'url0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'url0103', 1, 1, 'Attack', 'none' },      -- Artillery
            --{ 'url0105', 1, 1, 'Support', 'None' },     -- Engineer
        },
        Seraphim = {
            { 'xsl0201', 1, 2, 'Attack', 'none' },		-- Medium Tank
            { 'xsl0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'xsl0104', 1, 1, 'Attack', 'none' },      -- Mobile Anti-Air
            { 'xsl0201', 1, 2, 'Attack', 'none' },      -- Medium Tank
            --{ 'xsl0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'xsl0103', 1, 1, 'Attack', 'none' },      -- Artillery
            --{ 'xsl0105', 1, 1, 'Support', 'None' },     -- Engineer
        },
    }
}

--=====================================================--


PlatoonTemplate { Name = 'T1LandStandardQueue',
    FactionSquads = {
        UEF = {
            { 'uel0201', 1, 2, 'Attack', 'none' },		-- Striker Medium Tank
            { 'uel0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'uel0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'uel0201', 1, 2, 'Attack', 'none' },		-- Striker Medium Tank
            { 'uel0103', 1, 2, 'Artillery', 'None' },     -- Artillery
            { 'uel0201', 1, 1, 'Attack', 'none' },      -- Striker Medium Tank
            { 'uel0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'uel0201', 1, 1, 'Attack', 'none' },      -- Striker Medium Tank
        },
        Aeon = {
            { 'ual0201', 1, 2, 'Attack', 'none' },		-- Light Hover tank
            { 'ual0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'ual0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'ual0201', 1, 2, 'Attack', 'none' },		-- Light Hover tank
            { 'ual0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'ual0201', 1, 1, 'Attack', 'none' },      -- Light Hover tank
            { 'ual0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'ual0201', 1, 1, 'Attack', 'none' },      -- Light Hover tank
        },
        Cybran = {
            { 'url0107', 1, 2, 'Attack', 'none' },		-- Mantis
            { 'url0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'url0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'url0107', 1, 2, 'Attack', 'none' },		-- Mantis
            { 'url0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'url0107', 1, 1, 'Attack', 'none' },      -- Mantis
            { 'url0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'url0107', 1, 1, 'Attack', 'none' },      -- Mantis
        },
        Seraphim = {
            { 'xsl0201', 1, 2, 'Attack', 'none' },		-- Medium Tank
            { 'xsl0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'xsl0105', 1, 1, 'Support', 'None' },     -- Engineer
            { 'xsl0201', 1, 2, 'Attack', 'none' },		-- Medium Tank
            { 'xsl0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'xsl0201', 1, 1, 'Attack', 'none' },      -- Medium Tank
            { 'xsl0103', 1, 1, 'Artillery', 'None' },     -- Artillery
            { 'xsl0201', 1, 1, 'Attack', 'none' },      -- Medium Tank
        },
    }
}


--=====================================================--

PlatoonTemplate { Name = 'T2LandDefaultQueue',
    FactionSquads = {
        UEF = {
            { 'uel0202', 1, 5, 'Guard', 'none' },       -- Heavy Tank
            { 'del0204', 1, 4, 'Attack', 'none' },      -- Gatling Bot
            { 'uel0111', 1, 1, 'Artillery', 'none' },   -- MML
            { 'uel0205', 1, 2, 'Guard', 'none' },       -- AA
            { 'uel0307', 1, 1, 'Guard', 'none' },       -- Mobile Shield
        },
        Aeon = {
            { 'ual0202', 1, 6, 'Attack', 'none' },      -- Heavy Tank
            { 'ual0111', 1, 2, 'Artillery', 'none' },   -- MML
            { 'ual0205', 1, 1, 'Guard', 'none' },       -- AA
            { 'ual0307', 1, 1, 'Guard', 'none' },       -- Mobile Shield
        },
        Cybran = {
            { 'drl0204', 1, 5, 'Attack', 'none' },      -- Rocket Bot
            { 'url0202', 1, 5, 'Attack', 'none' },      -- Heavy Tank
            { 'url0111', 1, 1, 'Artillery', 'none' },   -- MML
            { 'url0205', 1, 2, 'Guard', 'none' },       -- AA
            { 'url0306', 1, 1, 'Guard', 'none' },       -- Mobile Stealth
        },
        Seraphim = {
            { 'xsl0202', 1, 7, 'Attack', 'none' },      -- Assault Bot
            { 'xsl0111', 1, 1, 'Artillery', 'none' },   -- MML
            { 'xsl0205', 1, 2, 'Guard', 'none' },       -- AA
        },
    }
}

PlatoonTemplate { Name = 'T3LandDefaultQueue',
    FactionSquads = {
        UEF = {
            { 'xel0305', 1, 8, 'Attack', 'none' },      -- Armored Assault Bot
            { 'uel0303', 1, 4, 'Attack', 'none' },      -- Heavy Assault Bot
            { 'uel0304', 1, 2, 'Artillery', 'none' },   -- artillery
            { 'xel0306', 1, 2, 'Artillery', 'none' },   -- artillery
            { 'delk002', 1, 2, 'Guard', 'none' },       -- AA
        },
        Aeon = {
            { 'ual0303', 1, 8, 'Attack', 'none' },      -- Heavy Assault Bot
            { 'xal0305', 1, 2, 'Attack', 'none' },      -- Sniper Bot
            { 'ual0304', 1, 2, 'Artillery', 'none' },   -- artillery
            { 'dal0310', 1, 1, 'Artillery', 'none' },   -- artillery
            { 'dalk003', 1, 2, 'Guard', 'none' },       -- AA
        },
        Cybran = {
            { 'xrl0305', 1, 7, 'Attack', 'none' },      -- Armored Assault Bot
            { 'url0303', 1, 3, 'Attack', 'none' },      -- Siege Assault Bot
            { 'url0304', 1, 2, 'Artillery', 'none' },   -- artillery
            { 'drlk001', 1, 2, 'Guard', 'none' },       -- AA
        },
        Seraphim = {
            { 'xsl0303', 1, 8, 'Attack', 'none' },       -- Siege Tank
            { 'xsl0305', 1, 3, 'Attack', 'none' },       -- Sniper Bot
            { 'xsl0304', 1, 2, 'Artillery', 'none' },   -- artillery
            { 'xsl0307', 1, 1, 'Guard', 'none' },       -- Mobile Shield
            { 'dslk004', 1, 1, 'Guard', 'none' },       -- AA
        },
    }
}