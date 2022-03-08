PlatoonTemplate {
    Name = 'S123-TorpedoBomber 1 100',    
    Plan = 'AirAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 100, 'Attack', 'AttackFormation' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Fighter Intercept 1 10', 
    Plan = 'AirHuntAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 10, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'Swarm Fighter Intercept 10 40', 
    Plan = 'AirHuntAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.HIGHALTAIR - categories.GROUNDATTACK - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL - categories.ANTINAVY, 10, 40, 'Attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'Swarm Bomber Small', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER  - (categories.BOMBER * categories.TECH3) - categories.EXPERIMENTAL - categories.ANTINAVY, 2, 5, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Bomber Big', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER  - (categories.BOMBER * categories.TECH3) - categories.EXPERIMENTAL - categories.ANTINAVY, 5, 15, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Gunship Small', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.ANTINAVY, 2, 10, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm Gunship Big', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.ANTINAVY, 5, 20, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'AntiGround Bomber/Gunship Small', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - (categories.BOMBER * categories.TECH3) - categories.EXPERIMENTAL - categories.ANTINAVY, 2, 10, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'AntiGround Bomber/Gunship Big', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * ( categories.GROUNDATTACK + categories.BOMBER ) - (categories.BOMBER * categories.TECH3) - categories.EXPERIMENTAL - categories.ANTINAVY, 5, 20, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm T3 Bomber Intercept 1 2', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 2, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm T3 Bomber Intercept 5 10', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 - categories.EXPERIMENTAL - categories.ANTINAVY, 2, 5, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'Swarm T3 Bomber Intercept 15 30', 
    Plan = 'StrikeForceAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER * categories.TECH3 - categories.EXPERIMENTAL - categories.ANTINAVY, 15, 30, 'Attack', 'none' },
    }
}

-- Swarm Experimental Air Formers --

PlatoonTemplate {
    Name = 'S Air Attack Experimental',
    Plan = 'AirAISwarm',
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL - categories.SCOUT, 1, 1, 'Attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'S Air Attack Experimental - Group',
    Plan = 'AirAISwarm',
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

PlatoonTemplate {
    Name = 'T1AirScoutSwarm',
    FactionSquads = {
        UEF = {
            { 'uea0101', 3, 3, 'scout', 'GrowthFormation' }
        },
        Aeon = {
            { 'uaa0101', 3, 3, 'scout', 'GrowthFormation' }
        },
        Cybran = {
            { 'ura0101', 3, 3, 'scout', 'GrowthFormation' }
        },
        Seraphim = {
            { 'xsa0101', 3, 3, 'scout', 'GrowthFormation' }
        },
    }
}
