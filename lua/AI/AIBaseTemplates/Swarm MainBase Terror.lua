
BaseBuilderTemplate {
    BaseTemplateName = 'SwarmTerrorTemplate',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== ACU ==== --
        -----------------------------------------------------------------------------
        -- Build Main Base (only once). Land/Air factory and basic Energy
        'SC ACU Attack Former',
        
        -----------------------------------------------------------------------------
        -- ==== Expansion Builders ==== --
        -----------------------------------------------------------------------------
        -- Build an Expansion
        'Swarm Expansion Builder',

        -----------------------------------------------------------------------------
        -- ==== SCU ==== --
        -----------------------------------------------------------------------------

        'Swarm Engineer Transfer from MainBase',

        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Produce Engineers
        'Swarm Engineer Builders',
        'Swarm SACU Builder',
        'Swarm Hive+Kennel Upgrade',

        -- Engineer Tasks
        'Swarm Engineer Assistees',
        'Swarm Engineer Reclaim',
        'Swarm Engineering Support Builder',

        -- Build MassExtractors / Creators
        'S1 MassBuilders',
        'S123 ExtractorUpgrades SWARM', 
        'S1 MassStorage Builder',

        -- Build Power Tech 1,2,3
        'S123 Energy Builders',

        -- Build Land/Air Factories
        'Swarm ACU Initial Opener',
        'Swarm Factory Builder',
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
        'S3 SACU Formers',

        'Swarm AI Defense Formers',
        'Swarm AI United Land Formers', 

        -----------------------------------------------------------------------------
        -- ==== Air Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Air Builders',

        -----------------------------------------------------------------------------
        -- ==== Air Units FORMER==== --
        -----------------------------------------------------------------------------
        'Swarm Air Formers',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Experimental Builders',
        'Swarm Air Experimental Builders',
        'S4 Economic Experimental Builders',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Experimental Formers',
        'Swarm Air Experimental Formers',

        -----------------------------------------------------------------------------
        -- ==== Structure Shield BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Shields Builder',
        'Swarm Shields Upgrader',

        -----------------------------------------------------------------------------
        -- ==== Defense and Strategic BUILDERS ==== --
        -----------------------------------------------------------------------------
        'Swarm Strategic Builder',
        'Strategic Platoon Formers',
        'Swarm T2 Tactical Missile Defenses Builder',
        'Swarm SMD Builder',
        
        -- Build Anti Air near AirFactories
        'Swarm Defense Anti Air Builders',
        -- Ground Defense Builder
        'Swarm Defense Anti Ground Builders',

        -----------------------------------------------------------------------------
        -- ==== Reactive & Adaptive BUILDERS ==== --
        -----------------------------------------------------------------------------
        'Swarm Transports - Water Map',
        'Swarm Land Builders - Water Map',
        'Swarm Factory Builder - Water Map',
        'Swarm Amphibious Formers',

        'Swarm Adaptive Factory Build',
        'Swarm Adaptive Air Build',
        -----------------------------------------------------------------------------
        -- ==== Scout BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Scout Builders',

        -----------------------------------------------------------------------------
        -- ==== Scout FORMER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Scout Formers',
        'Swarm Air Scout Formers', 

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'S1 Land Radar Builders', 
        'S1 Land Radar Upgrader',

        'CounterIntelBuilders',

        'AeonOptics',
        'CybranOptics',

    },
    -- Not used by Swarm AI. We always need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 10,
            Air = 8,
            Sea = 6,
            Gate = 2,
        },
        EngineerCount = {
            Tech1 = 12,
            Tech2 = 5,
            Tech3 = 4,
            SCU = 12,
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
