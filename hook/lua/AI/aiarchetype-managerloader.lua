
TheOldSetupMainBase = SetupMainBase
function SetupMainBase(aiBrain)

    local simMods = __active_mods or {}
    local InstalledMods = {}
    for index, moddata in simMods do
        -- save the modname as index and set it to true.
        InstalledMods[moddata.name] = true
        -- Debug line for the debuglog [F9]
        LOG('Swarm: found Mod with name: '..moddata.name..' - UID: '..moddata.uid )
    end

    if InstalledMods['AI-Uveso'] then
    	TheOldSetupMainBase(aiBrain)
    else
        TheOldSetupMainBase(aiBrain)
        repeat
        print("sa: This version of Swarm for AI req___  Uveso-AI")
        WaitTicks(70)
        until GetGameTimeSeconds() > 60
    end
end