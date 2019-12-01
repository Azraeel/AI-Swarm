PlatoonTemplate {
    Name = 'AirAttack',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR - categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.ANTINAVY, 
          8, -- Min number of units.
          30, -- Max number of units.
          'Attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' } -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'BomberAttack',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 2, 15, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipAttack',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 4, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipMassHunter',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 4, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'MassHunterBomber',
    Plan = 'StrikeForceAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * (categories.TECH1 + categories.TECH2) * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 7, 'Attack', 'GrowthFormation' },
    },
}
PlatoonTemplate {
    Name = 'U4-ExperimentalInterceptor 1 1',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * (categories.TECH1 + categories.TECH2) * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 7, 'Attack', 'GrowthFormation' },
    },
}