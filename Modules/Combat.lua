local Settings = {}

-- ARMA
Settings.WeaponType = "Melee"

-- COMBAT
Settings.FastAttack  = true
Settings.AttackSpeed = 0.1  -- velocidade do fast attack (segundos entre cada hit)
Settings.BringMobs   = true

-- HAKI / HABILIDADES
Settings.AutoBuso   = true  -- Buso (Armamento) sempre ativo
Settings.AutoV3V4   = false
Settings.AutoAwaken = false
Settings.AutoObs    = false -- Observação

-- MOVIMENTO
Settings.TweenSpeed     = 300
Settings.AttackHeight   = 22
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
