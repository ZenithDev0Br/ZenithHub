local ZenithHub = getgenv().ZenithHub or {}
getgenv().ZenithHub = ZenithHub

local Core = {}

Core.Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting")
}

Core.Player = Core.Services.Players.LocalPlayer

function Core:GetCharacter()
    return self.Player.Character or self.Player.CharacterAdded:Wait()
end

function Core:GetLevel()
    local data = self.Player:FindFirstChild("Data")
    local level = data and data:FindFirstChild("Level")
    return level and level.Value or 0
end

function Core:IsMobile()
    local UIS = game:GetService("UserInputService")
    return UIS.TouchEnabled and not UIS.MouseEnabled
end

ZenithHub.Core = Core

return Core
