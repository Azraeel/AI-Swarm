
BaseBuilderTemplate {
    BaseTemplateName = 'SwarmTerrorTemplate',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== ACU ==== --
        -----------------------------------------------------------------------------
        -- Build Main Base (only once). Land/Air factory and basic Energy
        'UC ACU Attack Former',
        
        -----------------------------------------------------------------------------
        -- ==== Expansion Builders ==== --
        -----------------------------------------------------------------------------
        -- Build an Expansion
        'Swarm Expansion Builder',

        -----------------------------------------------------------------------------
        -- ==== SCU ==== --
        -----------------------------------------------------------------------------

        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Produce Engineers
        'Swarm Engineer Builders',
        'Swarm SACU Builder',

        -- Engineer Tasks
        'Swarm Engineer Assistees',
        'Swarm Engineer Reclaim',
        'Swarm Engineering Support Builder',

        -- Build MassExtractors / Creators
        'U1 MassBuilders',
        'U123 ExtractorUpgrades',
        'U1 MassStorage Builder',

        -- Build Power Tech 1,2,3
        'U123 Energy Builders',

        -- Build Land/Air Factories
        'Swarm Factory Builders 1st',
        'Swarm Factory Builders ADAPTIVE',
        'Swarm Factory Builders RECOVER',
        'Swarm Gate Builders',
        
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'Swarm Factory Upgrader Rush',
        -- Build Air Staging Platform to refill and repair air units.
        'Swarm Air Staging Platform Builders',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Builders Ratio',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'AISwarm Platoon Builder',

        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Air Builders',
        'Swarm Air Transport Builders',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'Swarm Air Formers',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Experimental Builders',
        'Swarm Air Experimental Builders',
        'U4 Economic Experimental Builders',
        'Paragon Turbo Builder',
        'Paragon Turbo Factory',
        'Paragon Turbo Air',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Experimental Formers',
        'Swarm Air Experimental Formers PanicZone',
        'Swarm Air Experimental Formers MilitaryZone',
        'Swarm Air Experimental Formers EnemyZone',
        'Swarm Air Experimental Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Shields Builder',
        'Swarm Shields Upgrader',
        
        'U234 Repair Shields Former',

        -----------------------------------------------------------------------------
        -- ==== Defense and Strategic BUILDERS ==== --
        -----------------------------------------------------------------------------
        'Swarm Strategic Builder',
        'Swarm T2 Tactical Missile Defenses Builder',
        'Swarm SMD Builder',
        
        -- Build Anti Air near AirFactories
        'Swarm Defense Anti Air Builders',
        -- Ground Defense Builder
        'Swarm Defense Anti Ground Builders',

        -----------------------------------------------------------------------------
        -- ==== FireBase BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 FirebaseBuilders',

        -----------------------------------------------------------------------------
        -- ==== Sniper Former ==== --
        -----------------------------------------------------------------------------
        'U3 SACU Teleport Formers',

        -- We need this even if we have Omni View to get target informations for experimentals attack.
        -----------------------------------------------------------------------------
        -- ==== Scout BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Scout Builders',
        'Swarm Air Scout Builders',

        -----------------------------------------------------------------------------
        -- ==== Scout FORMER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Scout Formers',
        'Swarm Air Scout Formers', 

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'U1 Land Radar Builders',
        'U1 Land Radar Upgrader',

        'CounterIntelBuilders',

        'AeonOptics',
        'CybranOptics',

    },
    -- Not used by Uveso's AI. We always need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 5,
            Air = 5,
            Sea = 2,
            Gate = 4,
        },
        EngineerCount = {
            Tech1 = 6,
            Tech2 = 3,
            Tech3 = 3,
            SCU = 3,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        return -1
    end,
    FirstBaseFunction = function(aiBrain)
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if personality == 'swarmterror' or personality == 'swarmterrorcheat' then
            --LOG('### M-FirstBaseFunction '..personality)
            return 2000, 'swarmterror'
        end
        return -1
    end,
}
