-- ZenithHub Loader

if getgenv().ZenithHubLoaded then
    return
end

getgenv().ZenithHubLoaded = true

local ok, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/main/Init.lua")
end)

if not ok then
    warn("Failed to load Init.lua")
    return
end

local init = loadstring(result)
if init then
    init()
end
