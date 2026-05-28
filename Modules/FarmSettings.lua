local Settings = {}

-- ARMA
Settings.WeaponType = "Melee"

-- COMBAT
Settings.FastAttack = true
Settings.BringMobs = true

-- HAKI / HABILIDADES
Settings.AutoKen    = true  -- Ken (Armamento) sempre ativo
Settings.AutoBuso   = false -- Buso (reativa manualmente)
Settings.AutoV3V4   = false -- RaceSkill V3/V4
Settings.AutoAwaken = false -- Awakening V4
Settings.AutoObs    = false -- Haki da Observação

-- MOVIMENTO
Settings.TweenSpeed    = 300
Settings.AttackHeight  = 22
Settings.AttackDistance = 0

-- FARMS
Settings.AutoFarmLevel = false
Settings.AutoFarmBones = false
Settings.AutoBoss      = false

-- Vínculo global
getgenv().ZenithHub = getgenv().ZenithHub or {}
getgenv().ZenithHub.Modules = getgenv().ZenithHub.Modules or {}
getgenv().ZenithHub.Modules.FarmSettings = Settings

return Settings
