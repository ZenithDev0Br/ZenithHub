--[[
    ZenithHub Loader
]]

if getgenv().ZenithHubLoaded then
    return warn("ZenithHub already loaded.")
end

getgenv().ZenithHubLoaded = true

local Success, Response = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/main/Init.lua")
end)

if not Success then
    return warn("Failed to fetch Init.lua")
end

local Init = loadstring(Response)

if Init then
    Init()
else
    warn("Failed to execute Init.lua")
end
