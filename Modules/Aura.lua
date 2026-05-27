-- Modules/Aura.lua
local Aura = {}

Aura.Enabled = false

function Aura:SetEnabled(value)
    self.Enabled = value and true or false
end

function Aura:IsEnabled()
    return self.Enabled
end

return Aura
