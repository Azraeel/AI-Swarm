
-- ==== Global Form platoons ==== --
PlatoonTemplate {
    Name = 'CDR Attack',
    Plan = 'ACUAttackAIUveso',
    GlobalSquads = {
        { categories.COMMAND, 1, 1, 'Attack', 'none' }
    }
}
PlatoonTemplate {
    Name = 'AISwarm LandAttack Default',
    Plan = 'LandAttackAIUveso', -- The platoon function to use.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, -- Type of units.
          4, -- Min number of units.
          8, -- Max number of units.
          'attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' }, -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Small',
    Plan = 'LandAttackAIUveso', -- The platoon function to use.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, -- Type of units.
          5, -- Min number of units.
          10, -- Max number of units.
          'attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' }, -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Medium',
    Plan = 'LandAttackAIUveso', -- The platoon function to use.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, -- Type of units.
          8, -- Min number of units.
          14, -- Max number of units.
          'attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' }, -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Large',
    Plan = 'LandAttackAIUveso', -- The platoon function to use.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, -- Type of units.
          10, -- Min number of units.
          19, -- Max number of units.
          'attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' }, -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
    },
}

PlatoonTemplate {
    Name = 'AISwarm LandAttack Raid',
    Plan = 'LandAttackAIUveso', -- The platoon function to use.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - (categories.INDIRECTFIRE * (categories.TECH2 + categories.TECH3)) - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, -- Type of units.
          6, -- Min number of units.
          12, -- Max number of units.
          'attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' }, -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
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
    Name = 'AISwarm LandAttack Experimental',
    Plan = 'LandAttackAIUveso', -- The platoon function to use.
    GlobalSquads = {
        { categories.MOBILE * categories.LAND * categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT, -- Type of units.
          1, -- Min number of units.
          3, -- Max number of units.
          'attack', -- platoon types: 'support', 'attack', 'scout',
          'GrowthFormation' }, -- platoon move formations: 'None', 'AttackFormation', 'GrowthFormation',
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


