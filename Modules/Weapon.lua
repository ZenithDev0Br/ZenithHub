-- Modules/Weapon.lua
local Weapon = {}

Weapon.Equipped = nil

function Weapon:Equip(name)
    self.Equipped = name
end

function Weapon:GetEquipped()
    return self.Equipped
end

return Weapon
