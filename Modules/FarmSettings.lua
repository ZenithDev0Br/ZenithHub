local ZenithHub = getgenv().ZenithHub

local Settings = {}

-- [[ CONFIGURAÇÕES DE ARMA ]]
-- Alterado para 'WeaponType' para dar match com o seu modulo Weapon.lua
Settings.WeaponType = "Melee" 

-- [[ CONFIGURAÇÕES DE COMBATE ]]
Settings.FastAttack = true
Settings.BringMobs = true

-- [[ CONFIGURAÇÕES DE MOVIMENTO / SLIDERS ]]
-- Adicionado os valores padrão que a sua UI e o FarmLevel.lua usam
Settings.TweenSpeed = 300
Settings.AttackHeight = 5
Settings.AttackDistance = 0

-- [[ CONFIGURAÇÕES DE FARM (TOGGLES) ]]
Settings.AutoFarmLevel = false
Settings.AutoFarmBones = false
Settings.AutoBoss = false -- Sincronizado com o nome usado na sua interface (AutoBoss)

-- [[ INJEÇÃO NO AMBIENTE DO ZENITH HUB ]]
ZenithHub.Modules = ZenithHub.Modules or {}
ZenithHub.Modules.FarmSettings = Settings

return Settings
