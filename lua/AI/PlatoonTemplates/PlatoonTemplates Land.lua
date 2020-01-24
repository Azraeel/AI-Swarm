
-- ==== Global Form platoons ==== --
PlatoonTemplate {
    Name = 'CDR Attack',
    Plan = 'ACUAttackAIUveso',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    }
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Early Raid',
    Plan = 'GuardMarkerSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
          1,
          4,
          'attack',
          'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Small',
    Plan = 'AttackForceAISwarm', 
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 
          10, 
          15, 
          'attack', 
          'none' }, 
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Medium',
    Plan = 'AttackForceAISwarm', 
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 
          20, 
          35, 
          'attack', 
          'none' }, 
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Large',
    Plan = 'AttackForceAISwarm', 
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, 
          25, 
          50, 
          'attack', 
          'none' }, 
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Rapid Deployment',
    Plan = 'GuardMarkerSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
          10,
          15,
          'attack',
          'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Base Siege',
    Plan = 'LandAttackAIUveso', -- The platoon function to use.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.INDIRECTFIRE - (categories.INDIRECTFIRE * categories.TECH1) * (categories.TECH2 + categories.TECH3) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, -- Type of units.
          3, -- Min number of units.
          15, -- Max number of units.
          'attack', -- platoon types: 'support', 'attack', 'scout',
          'AttackFormation' }, -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Special Ops',
    Plan = 'GuardMarkerSwarm',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
          4,
          12,
          'attack',
          'GrowthFormation' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro Small',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
          5,
          15,
          'attack',
          'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Micro Big',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
          15,
          25,
          'attack',
          'none' },
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Experimental',
    Plan = 'LandAttackAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT,
          1,
          3,
          'attack',
          'GrowthFormation' },
    },
}


PlatoonTemplate {
    Name = 'U1 LandDFBot',
    FactionSquads = {
        UEF = {
            { 'uel0106', 1, 1, 'attack', 'None' }
        },
        Aeon = {
            { 'ual0106', 1, 1, 'attack', 'None' }
        },
        Cybran = {
            { 'url0106', 1, 1, 'attack', 'None' }
        },
        Seraphim = {
            { 'xsl0201', 1, 1, 'attack', 'none' }
        },
        Nomads = {
            { 'xnl0106', 1, 1, 'attack', 'none' }
        },
    }
}
PlatoonTemplate {
    Name = 'T2AttackTank',
    FactionSquads = {
        UEF = {
            { 'del0204', 1, 1, 'attack', 'None' },
        },
        Cybran = { #DUNCAN - Was UEF in orig
            { 'drl0204', 1, 1, 'attack', 'None' },
        },
    },
}
PlatoonTemplate {
    Name = 'T2AeonBlaze',
    FactionSquads = {
        Aeon = {
            { 'xal0203', 1, 1, 'attack', 'None' }
        },
    },
}
PlatoonTemplate {
    Name = 'T2MobileShields',
    FactionSquads = {
        UEF = {
            { 'uel0307', 1, 1, 'support', 'none' }
        },
        Aeon = {
            { 'ual0307', 1, 1, 'support', 'none' }
        },
    }
}


