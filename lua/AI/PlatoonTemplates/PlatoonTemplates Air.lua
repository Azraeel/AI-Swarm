PlatoonTemplate {
    Name = 'AirAttack',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR - categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.ANTINAVY, 
          1, -- Min number of units.
          30, -- Max number of units.
          'Attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' } -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'BomberAttack',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 15, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipAttack',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 1, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipMassHunter',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 1, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'MassHunterBomber',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * (categories.TECH1 + categories.TECH2) * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 7, 'Attack', 'GrowthFormation' },
    },
}
