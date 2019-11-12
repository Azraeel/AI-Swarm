#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/TurtleExpansion.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'SwarmExpansionNaval',
    Builders = {
        -----------------------------------------------------------------------------
        -- ==== Engineer ==== --
        -----------------------------------------------------------------------------
        -- Build Engineers Tech 1,2,3 and SACU
        'Swarm Engineer Builders',            -- Priority = 900
        -- Assistees
        'Swarm Engineer Assistees',
        -- Return engineers back to base
        'Swarm Engineer Transfer To MainBase',

        -----------------------------------------------------------------------------
        -- ==== Factory ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Factories
        'Swarm Factory Builders Naval',
        -- Upgrade Naval Factories TECH1->TECH2 and TECH2->TECH3
        'Swarm Factory Upgrader Naval',

        -----------------------------------------------------------------------------
        -- ==== Sea Units BUILDER ==== --
        -----------------------------------------------------------------------------
        -- Build Naval Units
        'Swarm Naval Builders',

        -----------------------------------------------------------------------------
        -- ==== Sea Units FORMER ==== --
        -----------------------------------------------------------------------------
        'Swarm Naval Formers',

        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Naval Experimental Builders',
        
        -----------------------------------------------------------------------------
        -- ==== EXPERIMENTALS FORMER ==== --
        -----------------------------------------------------------------------------
        'Swarm Naval Experimental Formers PanicZone',
        'Swarm Naval Experimental Formers MilitaryZone',
        'Swarm Naval Experimental Formers EnemyZone',
        'Swarm Naval Experimental Formers Trasher',

        -----------------------------------------------------------------------------
        -- ==== Defenses BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm T2 Tactical Missile Defenses Builder',

        -----------------------------------------------------------------------------
        -- ==== Intel/CounterIntel BUILDER ==== --
        -----------------------------------------------------------------------------
        'Swarm Sonar Builders',
        'Swarm Sonar Upgraders', 

    },

    BaseSettings = {
        FactoryCount = {
            Land = 0,
            Air = 0,
            Sea = 3,
            Gate = 0,
        },
        EngineerCount = {
            Tech1 = 2,
            Tech2 = 1,
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
        if markerType ~= 'Naval Area' then
            return -1
        end
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if personality == 'swarmgrowing' or personality == 'swarmgrowingcheat' 
        or personality == 'swarmterror' or personality == 'swarmterrorcheat' 
        or personality == 'eternalswarm' or personality == 'eternalswarm' then
            return 5000, 'SwarmExpansionNaval'
        end
    end,
}
