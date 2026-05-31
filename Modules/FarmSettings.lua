local Settings = {}

-- ============================================================================
-- WEAPON
-- ============================================================================
Settings.WeaponType = "Melee"

-- ============================================================================
-- COMBAT
-- ============================================================================
Settings.FastAttack = true
Settings.AttackSpeed = 0.1
Settings.BringMobs = true

-- HITBOX
Settings.HitboxSize = 15

-- ============================================================================
-- HAKI
-- ============================================================================
Settings.AutoBuso = true
Settings.AutoObs = false
Settings.AutoV3V4 = false
Settings.AutoAwaken = false

-- ============================================================================
-- MOVEMENT
-- ============================================================================
Settings.TweenSpeed = 300
Settings.AttackHeight = 22
Settings.AttackDistance = 0

-- ============================================================================
-- FARM
-- ============================================================================
Settings.AutoFarmLevel = false
Settings.AutoFarmBones = false
Settings.AutoBoss = false

-- CHEST FARM
Settings.AmountChest = 30
Settings.AutoFarmChest = false
Settings.AutoFarmChestHop = false
Settings.StopWithItem = false

-- ============================================================================
-- VISUAL
-- ============================================================================
Settings.EspChest = false
Settings.EspFruits = false
Settings.EspFlower = false
Settings.EspIslands = false
Settings.EspGear = false
Settings.EspPlayers = false

-- ============================================================================
-- GLOBAL LINK
-- ============================================================================
getgenv().ZenithHub = getgenv().ZenithHub or {}
getgenv().ZenithHub.Modules = getgenv().ZenithHub.Modules or {}

getgenv().ZenithHub.Modules.FarmSettings = Settings

return Settings
