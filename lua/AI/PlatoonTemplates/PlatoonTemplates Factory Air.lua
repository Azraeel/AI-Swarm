-- We'll be Abandoning Queue Building soon, as Air Ratio has done greatly in allowing Swarm to take Air Control even in the Tournies.
-- Queues are slowing his reaction to the Ratio Change and Advantage. 
-- So we'll be transition back to Singular Builders.
-- Yes more builders but Swarm has the lowest count for Builders of All AI, so I feel comfortable increasing this count a little.

PlatoonTemplate {
    Name = 'SwarmAIFighterGroup',
    FactionSquads = {
        UEF = {
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'uea0102', 1, 3, 'attack', 'None' },
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Aeon = {
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'uaa0102', 1, 3, 'attack', 'None' },
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Cybran = {
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'ura0102', 1, 3, 'attack', 'None' },
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Seraphim = {
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'xsa0102', 1, 3, 'attack', 'None' },
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
    }
}

PlatoonTemplate {
    Name = 'SwarmAIT1AirAttack',
    FactionSquads = {
        UEF = {
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'uea0102', 1, 1, 'attack', 'GrowthFormation' }, -- T1 Fighter
            { 'uea0103', 1, 3, 'attack', 'GrowthFormation' }, -- T1 Bomber
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Aeon = {
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'uaa0102', 1, 1, 'attack', 'GrowthFormation' }, -- T1 Fighter
            { 'uaa0103', 1, 3, 'attack', 'GrowthFormation' }, -- T1 Bomber
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Cybran = {
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'ura0102', 1, 1, 'attack', 'GrowthFormation' }, -- T1 Fighter
            { 'ura0103', 1, 2, 'attack', 'GrowthFormation' }, -- T1 Bomber
            { 'xra0105', 1, 2, 'attack', 'GrowthFormation' }, -- T1 Gunship
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
            
        },
        Seraphim = {
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'xsa0102', 1, 1, 'attack', 'GrowthFormation' }, -- T1 Fighter
            { 'xsa0103', 1, 3, 'attack', 'GrowthFormation' }, -- T1 Bomber
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
    }
}

PlatoonTemplate {
    Name = 'SwarmAIFighterGroupT2',
    FactionSquads = {
        UEF = {
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'uea0102', 1, 3, 'attack', 'None' }, -- T1 Fighter
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },

        },
        Aeon = {
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'uaa0102', 1, 3, 'attack', 'None' }, -- T1 Fighter
            { 'xaa0202', 1, 1, 'attack', 'None' }, -- T2 Fighter
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Cybran = {
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'ura0102', 1, 3, 'attack', 'None' }, -- T1 Fighter
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Seraphim = {
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'xsa0102', 1, 3, 'attack', 'None' }, -- T1 Fighter
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
    }
}

PlatoonTemplate {
    Name = 'SwarmAIT2AirAttack',
    FactionSquads = {
        UEF = {
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'dea0202', 1, 2, 'attack', 'None' }, -- FighterBomber
            { 'uea0203', 1, 2, 'attack', 'None' }, -- Gunship
            { 'uea0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Aeon = {
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'xaa0202', 1, 1, 'attack', 'None' },-- Fighter
            { 'uaa0203', 1, 2, 'attack', 'None' },-- Gunship
            { 'uaa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Cybran = {
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'dra0202', 1, 2, 'attack', 'None' },-- FighterBomber
            { 'ura0203', 1, 2, 'attack', 'None' },-- Gunship
            { 'ura0101', 1, 1, 'attack', 'GrowthFormation' },
        },
        Seraphim = {
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
            { 'xsa0202', 1, 2, 'attack', 'None' },-- FighterBomber
            { 'xsa0203', 1, 2, 'attack', 'None' }, -- Gunship
            { 'xsa0101', 1, 1, 'attack', 'GrowthFormation' },
        },
    },
}

PlatoonTemplate { 
    Name = 'SwarmAIT3AirFighterGroup',
    FactionSquads = {
        UEF = {
            { 'uea0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'uea0303', 1, 3, 'Attack', 'none' },      -- Air Superiority Fighter
            { 'uea0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'uea0303', 1, 3, 'Attack', 'none' },   -- Air Superiority Fighter
            { 'uea0305', 1, 1, 'Guard', 'none' },   -- Gunship
         },
        Aeon = {
            { 'uaa0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'uaa0303', 1, 3, 'Attack', 'none' },      -- Air Superiority Fighter
            { 'uaa0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'uaa0303', 1, 3, 'Attack', 'none' },   -- Air Superiority Fighter
            { 'xaa0305', 1, 1, 'Guard', 'none' },   -- Gunship
        },
        Cybran = {
            { 'ura0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'ura0303', 1, 3, 'Attack', 'none' },      -- Air Superiority Fighter
            { 'ura0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'ura0303', 1, 3, 'Attack', 'none' },   -- Air Superiority Fighter
            { 'xra0305', 1, 1, 'Guard', 'none' },   -- Gunship
        },
        Seraphim = {
            { 'xsa0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'xsa0303', 1, 3, 'attack', 'none' },      -- Air Superiority Fighter
            { 'xsa0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'xsa0303', 1, 2, 'Attack', 'none' },   -- Air Superiority Fighter
        },
    }
}

PlatoonTemplate { 
    Name = 'SwarmAIT3AirAttackQueue',
    FactionSquads = {
        UEF = {
            { 'uea0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'uea0303', 1, 1, 'Attack', 'none' },      -- Air Superiority Fighter
            { 'uea0304', 1, 1, 'Artillery', 'none' },      -- Strategic Bomber
            { 'uea0305', 1, 2, 'Guard', 'none' },   -- Gunship
         },
        Aeon = {
            { 'uaa0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'uaa0304', 1, 1, 'Artillery', 'none' },      -- Strategic Bomber
            { 'uaa0303', 1, 1, 'Attack', 'none' },   -- Air Superiority Fighter
            { 'xaa0305', 1, 2, 'Guard', 'none' },   -- Gunship
        },
        Cybran = {
            { 'ura0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'ura0304', 2, 1, 'Artillery', 'none' },      -- Strategic Bomber
            { 'ura0303', 1, 1, 'Attack', 'none' },   -- Air Superiority Fighter
            { 'xra0305', 1, 2, 'Guard', 'none' },   -- Gunship
        },
        Seraphim = {
            { 'xsa0302', 1, 1, 'Attack', 'none' },      -- Scout
            { 'xsa0304', 1, 2, 'Artillery', 'none' },       -- Strategic Bomber
            { 'xsa0303', 1, 1, 'Attack', 'none' },   -- Air Superiority Fighter
        },
    }
}