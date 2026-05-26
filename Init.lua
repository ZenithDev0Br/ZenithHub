--[[
    ZenithHub Init
]]

local ZenithHub = {}
getgenv().ZenithHub = ZenithHub

ZenithHub.Version = "0.0.1"

local function Load(File)
    local Success, Result = pcall(function()
        return loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/main/" .. File
            )
        )()
    end)

    if not Success then
        warn("[ZenithHub] Failed loading:", File)
        warn(Result)
    end

    return Result
end

ZenithHub.Core = Load("Core.lua")

Load("Main.lua")
