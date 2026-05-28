local Settings = {}

-- CONFIGURAÇÕES DE ARMA
Settings.WeaponType = "Melee" -- "Melee", "Sword", "Blox Fruit"

-- COMBAT DEFAULTS
Settings.FastAttack = true
Settings.BringMobs = true

-- MOVIMENTO (SLIDERS DO FRONTEND)
Settings.TweenSpeed = 300
Settings.AttackHeight = 22  -- 🔥 CORRIGIDO: Padrão inicial agora é 22 para não morrer pros NPCs!
Settings.AttackDistance = 0

-- STATUS DOS FARMS (TOGGLES)
Settings.AutoFarmLevel = false
Settings.AutoFarmBones = false
Settings.AutoBoss = false

-- 🔥 VÍNCULO GLOBAL: Garante que o BringMob.lua e a UI leiam e alterem a MESMA tabela!
getgenv().ZenithHub = getgenv().ZenithHub or {}
getgenv().ZenithHub.Modules = getgenv().ZenithHub.Modules or {}
getgenv().ZenithHub.Modules.FarmSettings = Settings

return Settings
