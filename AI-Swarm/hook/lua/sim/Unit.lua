
local SwarmUnit = Unit
Unit = Class(SwarmUnit) {

    -- Hook For AI-Swarm. prevent capturing
    OnStopBeingCaptured = function(self, captor)
        SwarmUnit.OnStopBeingCaptured(self, captor)
        local aiBrain = self:GetAIBrain()
        if aiBrain.Swarm then
            self:Kill()
        end
    end,

}
