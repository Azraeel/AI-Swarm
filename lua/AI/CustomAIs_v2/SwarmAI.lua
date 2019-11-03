#****************************************************************************
#**
#**  File     :  /lua/AI/CustomAIs_v2/UvesoAI.lua
#**  Author(s): Uveso
#**
#**  Summary  : Utility File to insert custom AI into the game.
#**
#****************************************************************************

AI = {
    AIList = {
        {
            key = 'swarmterror',
            name = "<LOC Swarm_0003>AI: Swarm Terror",
        },
    },
    -- key names must have the word "cheat" included, or we won't get omniview
    CheatAIList = {
        {
            key = 'swarmterrorcheat',
            name = "<LOC Swarm_0007>AIx: Swarm Terror",
        },
        {
            key = 'swarmtestcheat', -- This name will be used in the basetemplate "Swarm Test BaseTemplate.lua"
            name = "AIx: Swarm Test",
        },

    },
}
