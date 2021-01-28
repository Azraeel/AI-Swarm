PlatoonTemplate {
    Name = 'S123-TorpedoBomber 1 100',    
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 100, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Fighter Intercept 1 2', 
    Plan = 'InterceptorAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 2, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'Swarm Fighter Intercept 3 5', 
    Plan = 'InterceptorAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 5, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'Swarm Fighter Intercept 10', 
    Plan = 'InterceptorAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 10, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'Swarm Fighter Intercept 20', 
    Plan = 'InterceptorAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 20, 20, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'Swarm Fighter Intercept 30 50', 
    Plan = 'InterceptorAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 30, 50, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Bomber Intercept 1 3', 
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 3, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Bomber Intercept 3 5', 
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 3, 5, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Bomber Intercept 15 20', 
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 15, 20, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Gunship Intercept 3 5',
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK * (categories.TECH1 + categories.TECH2) - categories.HIGHALTAIR - categories.TRANSPORTFOCUS - categories.ANTINAVY , 3, 5, 'Attack', 'none' }
    }
}

PlatoonTemplate {
    Name = 'Swarm Gunship Intercept 15 20', 
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.ANTINAVY, 15, 20, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Gunship/Bomber Intercept 1 2',
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 1, 2, 'Attack', 'GrowthFormation' }
    }
}

PlatoonTemplate {
    Name = 'Swarm Gunship/Bomber Intercept 3 5',
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY , 3, 5, 'Attack', 'GrowthFormation' }
    }
}

PlatoonTemplate {
    Name = 'AntiGround Bomber/Gunship Mix', 
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 500, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'GunshipAttack',
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.BOMBER - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.SCOUT, 5, 100, 'Attack', 'GrowthFormation' },
    }
}

-- Swarm Experimental Air Formers --

PlatoonTemplate {
    Name = 'S Air Attack Experimental',
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL - categories.SCOUT, 1, 1, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'S Air Attack Experimental - Group',
    Plan = 'BomberGunshipAISwarm',
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL - categories.SCOUT, 4, 8, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'T1AirScoutFormSwarm',
    Plan = 'ScoutingAISwarm',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT * categories.TECH1, 1, 1, 'scout', 'None' },
    }
}

PlatoonTemplate {
    Name = 'T3AirScoutFormSwarm',
    Plan = 'ScoutingAISwarm',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT * categories.TECH3, 1, 1, 'scout', 'None' },
    }
}
