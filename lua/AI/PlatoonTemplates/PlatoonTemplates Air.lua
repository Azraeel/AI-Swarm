PlatoonTemplate {
    Name = 'AirAttack',
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR - categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.ANTINAVY - categories.SCOUT, 
          8, -- Min number of units.
          30, -- Max number of units.
          'Attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' } -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'BomberAttack',
    Plan = 'HuntAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY - categories.SCOUT, 2, 15, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipAttack',
    Plan = 'GunshipHuntAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.SCOUT, 4, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipMassHunter',
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.SCOUT, 4, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'MassHunterBomber',
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * (categories.TECH1 + categories.TECH2) * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY - categories.SCOUT, 3, 7, 'Attack', 'GrowthFormation' },
    },
}
PlatoonTemplate {
    Name = 'AISwarm AirAttack Experimental',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL - categories.ANTINAVY - categories.SCOUT, 1, 3, 'Attack', 'GrowthFormation' },
    },
}