if getgenv().ZenithHubLoaded then
    return
end

getgenv().ZenithHubLoaded = true

local BaseURL = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/main/"

local function Load(file)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(BaseURL .. file))()
    end)

    if not ok then
        warn("Load failed:", file)
        return nil
    end

    return res
end

-- CORE FIRST
getgenv().ZenithHub = {}
ZenithHub.Modules = {}
ZenithHub.Settings = {}

ZenithHub.Core = Load("Main.lua")

-- MODULES
Load("Modules/InfoService.lua")

-- UI LAST
Load("BloxFruitsUI.lua")

print("ZenithHub Loaded")
