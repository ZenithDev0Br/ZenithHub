local ZenithHub = getgenv().ZenithHub

local Settings = {}

-- WEAPON DEFAULT
Settings.SelectedWeapon = "Melee"

-- COMBAT DEFAULTS
Settings.FastAttack = true
Settings.BringMobs = true

-- FARM
Settings.AutoFarmLevel = false
Settings.AutoFarmBones = false
Settings.AutoAnnihilateBosses = false

ZenithHub.Modules = ZenithHub.Modules or {}
ZenithHub.Modules.FarmSettings = Settings

return Settings
