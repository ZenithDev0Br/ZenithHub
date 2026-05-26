local FarmSettings = {}

-- Configurações padrão
_G.SelectedWeapon = "Melee"
_G.FastAttack = false
_G.BringMobs = false

function FarmSettings:ToggleFastAttack(bool)
    _G.FastAttack = bool
    -- Aqui você pode inserir o código do Fast Attack (Hook de Metatable ou loop de clique)
    print("Fast Attack: " .. (bool and "ON" or "OFF"))
end

function FarmSettings:SetWeapon(weapon)
    _G.SelectedWeapon = weapon
    print("Weapon set to: " .. weapon)
end

getgenv().ZenithHub.Modules.FarmSettings = FarmSettings
return FarmSettings
