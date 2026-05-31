if _G.ZenithHubLoading then
    return
end

_G.ZenithHubLoading = true

local BASE =
    "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/main/"

local function LoadFile(Path)

    local Success, Response = pcall(function()
        return game:HttpGet(BASE .. Path)
    end)

    if not Success then
        warn("[ZenithHub] Failed to load:", Path)
        return nil
    end

    local Compiled, Error =
        loadstring(Response)

    if not Compiled then
        warn("[ZenithHub] Compile error:", Path, Error)
        return nil
    end

    local ExecuteSuccess, Result =
        pcall(Compiled)

    if not ExecuteSuccess then
        warn("[ZenithHub] Runtime error:", Path, Result)
        return nil
    end

    return Result
end

-- GLOBAL
getgenv().ZenithHub =
    getgenv().ZenithHub or {}

local ZenithHub =
    getgenv().ZenithHub

ZenithHub.Modules =
    ZenithHub.Modules or {}

ZenithHub.Connections =
    ZenithHub.Connections or {}

ZenithHub.Loaded = false

-- MAIN
local Main =
    LoadFile("Main.lua")

if Main then
    ZenithHub.Main = Main
end

-- MODULES
local ModuleFiles = {

    -- SERVICES
    "Modules/InfoService.lua",

    -- SETTINGS
    "Modules/FarmSettings.lua",

    -- CORE FARM
    "Modules/FarmLevel.lua",
    "Modules/AutoQuest.lua",
    "Modules/FarmChest.lua",

    -- MOVEMENT
    "Modules/Tween.lua",

    -- COMBAT
    "Modules/Combat.lua",
    "Modules/Weapon.lua",
    "Modules/Aura.lua",

    -- MOB SYSTEM
    "Modules/BringMob.lua",
    "Modules/MobScanner.lua",
    "Modules/Target.lua"
}

for _, File in ipairs(ModuleFiles) do

    local Module =
        LoadFile(File)

    if Module then

        local Name =
            File:match("([^/]+)%.lua$")

        ZenithHub.Modules[Name] =
            Module

        print("[ZenithHub] Module Loaded:", Name)
    end
end

-- START INFOSERVICE
if ZenithHub.Modules.InfoService
and ZenithHub.Modules.InfoService.Start then

    task.spawn(function()

        local Success, Error =
            pcall(function()
                ZenithHub.Modules.InfoService:Start()
            end)

        if not Success then
            warn("[ZenithHub] InfoService Error:", Error)
        end
    end)
end

-- UI LAST
local UI =
    LoadFile("BloxFruitsUI.lua")

if UI then
    ZenithHub.UI = UI
end

ZenithHub.Loaded = true
_G.ZenithHubLoading = false

warn("[ZenithHub] Successfully Loaded")
