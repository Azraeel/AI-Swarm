#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'SwarmExpansionAreaLarge',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'Swarm Expansion Engineer Builders',
        -- Assistees
        'Swarm Engineer Assistees',
        -- Reclaim mass
        'Swarm Engineer Reclaim',

        -----------------------------------------------------------------------------
        -- ==== Energy ==== --
        -----------------------------------------------------------------------------
        -- Build Power Tech 1,2,3
        'S123 Energy Builders',                       -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
        'T1 Phase Adaptiveness',
        -- Upgrade Factories TECH1->TECH2 and TECH2->TECH3
        'Swarm Factory Upgrader Rush',

        -----------------------------------------------------------------------------
        -- ==== Land Units BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Builders Ratio',
        'Swarm SACU Builder',

        -----------------------------------------------------------------------------
        -- ==== Land Units FORMER==== --
        -----------------------------------------------------------------------------
        'AISwarm Platoon Builder',

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
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Strategic Builder',
        'Strategic Platoon Formers',
        'Swarm T2 Tactical Missile Defenses Builder',
        'Swarm SMD Builder',
        'Swarm Defense Plus Builders',
        'Swarm Defense Plus Builders Expansion',
        
        -- Build Anti Air near AirFactories
        'Swarm Defense Anti Air Builders',
        -- Ground Defense Builder
        'Swarm Defense Anti Ground Builders',

        -----------------------------------------------------------------------------
        -- ==== Reactive BUILDERS ==== --
        -----------------------------------------------------------------------------
        'Swarm Transports - Water Map',
        'Swarm Land Builders - Water Map',
        'Swarm Factory Builder - Water Map',
        'Swarm Amphibious Formers',

        -----------------------------------------------------------------------------
        -- ==== FireBase BUILDER ==== --
        -----------------------------------------------------------------------------


        
        -- We need this even if we have Omni View to get target informations for experimentals attack.
        -----------------------------------------------------------------------------
        -- ==== Scout BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Scout Builders',

        -----------------------------------------------------------------------------
        -- ==== Scout FORMER ==== --
        -----------------------------------------------------------------------------
        'Swarm Land Scout Formers',
        'Swarm Air Scout Formers', 

    },
    -- We need intel in case the commander is dead.
    NonCheatBuilders = {

    },

    BaseSettings = {
        FactoryCount = {
            Land = 0,
            Air = 0,
            Sea = 0,
            Gate = 1,
        },
        EngineerCount = {
            Tech1 = 3,
            Tech2 = 5,
            Tech3 = 7,
            SCU = 2,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        if markerType ~= 'Large Expansion Area' then
            return -1
        end
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if personality == 'swarmgrowing' or personality == 'swarmgrowingcheat' 
        or personality == 'swarmterror' or personality == 'swarmterrorcheat'
        or personality == 'swarmeternal' or personality == 'swarmeternalcheat' then
            return 5000, 'swarmterror'
        end
    end,
}
