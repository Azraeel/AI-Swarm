
BaseBuilderTemplate {
    BaseTemplateName = 'TestTemplate', -- This name is used in the FirstBaseFunction on the end of this file
    Builders = {

        -- This platoon will build the first factory
        -- The platoon is defined in \lua\AI\AIBuilders\Factory.lua
--        'S1 Factory Builders',

        -- This platoon will build 6 engineers
        -- The platoon is defined in \lua\AI\AIBuilders\Engineer.lua
--        'S1 Engineer Builders',

        -- This platoon will build massextractors
        -- The platoon is defined in \lua\AI\AIBuilders\Mass.lua
        'S1 MassBuilders',

        -- This platoon will build energy
        -- The platoon is defined in \lua\AI\AIBuilders\Energy.lua
--        'S1 Energy Builders',

        -- This platoon will build landunits in factories
        -- The platoon is defined in \lua\AI\AIBuilders\Land units Build.lua
--        'S1 Artillery',

        -- This platoon will form an attack platoon and send the units to the enemy
        -- The platoon is defined in \lua\AI\AIBuilders\Land units Move.lua
        --'Swarm Land Attack Formers',

    },
    -- Not used by Swarm AI. We always need intel in case the commander is dead.
    NonCheatBuilders = {

    },
    BaseSettings = {
        FactoryCount = {
            Land = 5,
            Air = 5,
            Sea = 4,
            Gate = 2,
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
    
    -- This file is for the mainabase, so we return -1 here.
    -- So this file will not used for expansions.
    ExpansionFunction = function(aiBrain, location, markerType)
        return -1
    end,
    
    -- Firstbase is the mainbase where the ACU starts.
    FirstBaseFunction = function(aiBrain)
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        -- These personalities are defined in the file "SwarmAI.lua"
        -- Actual there is only the "swarmtestcheat" sub-AI
        if personality == 'swarmtest' or personality == 'swarmtestcheat' then
            -- The name 'TestTemplate' is the name of the table on top of this file:
            return 1000, 'TestTemplate'
        end
        return -1
    end,
}
