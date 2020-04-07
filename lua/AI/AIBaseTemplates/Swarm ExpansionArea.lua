#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'SwarmExpansionArea',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'Swarm Engineer Builders',            -- Priority = 900
        -- Assistees
        'Swarm Engineer Assistees',
        -- Reclaim mass
        'Swarm Engineer Reclaim',

        -----------------------------------------------------------------------------
        -- ==== Energy ==== --
        -----------------------------------------------------------------------------
        -- Build Power Tech 1,2,3
        'U123 Energy Builders',                       -- Priority = 1100

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Land/Air Factories
        'Swarm Factory Builders Expansions',
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
            Land = 7,
            Air = 1,
            Sea = 1,
            Gate = 0,
        },
        EngineerCount = {
            Tech1 = 2,
            Tech2 = 2,
            Tech3 = 1,
            SCU = 0,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        if markerType ~= 'Expansion Area' then
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
