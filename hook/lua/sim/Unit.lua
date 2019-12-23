
local SwUnitClass = Unit
Unit = Class(SwUnitClass) {

    -- prevent capturing
    OnStopBeingCaptured = function(self, captor)
        OldUnitClass.OnStopBeingCaptured(self, captor)
        local aiBrain = self:GetAIBrain()
        if aiBrain.Uveso then
            self:Kill()
        end
    end,

}
