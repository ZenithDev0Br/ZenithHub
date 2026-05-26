if _G.ZenithHubLoading then return end
_G.ZenithHubLoading = true

local BASE = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/main/"

local function load(file)
    local ok, res = pcall(function()
        return game:HttpGet(BASE .. file)
    end)

    if not ok then
        warn("[ZenithHub] Failed:", file)
        return
    end

    local fn = loadstring(res)
    if fn then fn() end
end

-- CORE FIRST
load("Main.lua")

-- MODULES
load("Modules/InfoService.lua")
load("Modules/FarmSettings.lua")
load("Modules/FarmLevel.lua")

-- UI LAST
load("BloxFruitsUI.lua")

_G.ZenithHubLoading = false

print("[ZenithHub] Loaded")
