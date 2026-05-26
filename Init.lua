local ZenithHub = {}

getgenv().ZenithHub = ZenithHub

ZenithHub.Version = "1.0.0"

ZenithHub.Settings = {
    Enabled = true
}

ZenithHub.UI = {}
ZenithHub.Modules = {}

local BaseURL = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/main/"

local function Load(file)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(BaseURL .. file))()
    end)

    if not ok then
        warn("Error loading:", file)
        return nil
    end

    return res
end

ZenithHub.Core = Load("Core.lua")

Load("Modules/InfoService.lua")
Load("BloxFruitsUI.lua")
Load("Main.lua")

print("ZenithHub Loaded")
