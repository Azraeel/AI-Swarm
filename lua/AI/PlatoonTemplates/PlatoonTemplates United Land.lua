PlatoonTemplate {
    Name = 'AISwarm Mass Raid',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 2, 3, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Mass Raid Large',
    Plan = 'MassRaidSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 4, 15, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm Early Guard Marker',
    Plan = 'GuardMarkerSwarm',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 3,10, 'attack', 'none' },
        --{ categories.LAND * categories.SCOUT, 0, 1, 'Guard', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm - Guard Marker - Pressure',
    Plan = 'GuardMarkerSwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 8, 20, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm - Guard Base',
    Plan = 'GuardBaseSwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 5, 20, 'attack', 'none' },
    },
}

-----------------------

-- Archived As This is Mainly for Sorian Edit AI Mod Now --

-----------------------

--[[ PlatoonTemplate {
    Name = 'AI-Swarm Attack Force - United Land - Small',
    Plan = 'AttackForceAISwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER, 0, 5, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 15, 40, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 4, 15, 'artillery', 'none' },

        { categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 8, 'guard', 'none' },

        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 1, 5, 'support', 'none' },
    },
}

PlatoonTemplate {
    Name = 'AI-Swarm Attack Force - United Land - Large',
    Plan = 'AttackForceAISwarm',    
    GlobalSquads = {
        { categories.LAND * categories.MOBILE * categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER, 1, 10, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.DIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 40, 100, 'attack', 'none' },

        { categories.LAND * categories.MOBILE * categories.INDIRECTFIRE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 10, 30, 'artillery', 'none' },

        { categories.LAND * categories.MOBILE * categories.ANTIAIR - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 0, 15, 'guard', 'none' },

        { categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 3, 9, 'support', 'none' },
    },
} ]]--

PlatoonTemplate {
    Name = 'AISwarm - Experimental - Group', 
    Plan = 'LandAttackAISwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
        2,
        15,
        'attack',
        'GrowthFormation' },
    },
}