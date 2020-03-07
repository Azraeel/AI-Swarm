PlatoonTemplate {
    Name = 'AirAttackThreat',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR - categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.ANTINAVY - categories.SCOUT, 
          1, -- Min number of units.
          100, -- Max number of units.
          'Attack', -- platoon types: 'support', 'attack', 'scout',
          'None' } -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'U123-TorpedoBomber 1 100',    
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 100, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate {
    Name = 'BomberAttack',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER * (categories.TECH1 + categories.TECH2) - categories.TECH3 - categories.EXPERIMENTAL - categories.ANTINAVY - categories.SCOUT, 1, 100, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'SpecialOpsBomberAttack',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 - categories.EXPERIMENTAL - categories.ANTINAVY - categories.SCOUT, 5, 100, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'GunshipAttack',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.SCOUT, 5, 100, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'AISwarm AirAttack Experimental',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL - categories.ANTINAVY - categories.SCOUT, 1, 3, 'Attack', 'none' },
    },
}