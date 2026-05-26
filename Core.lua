--[[
    ZenithHub Core
]]

local Core = {}

--// Services
Core.Players = game:GetService("Players")
Core.RunService = game:GetService("RunService")
Core.TweenService = game:GetService("TweenService")
Core.ReplicatedStorage = game:GetService("ReplicatedStorage")
Core.VirtualUser = game:GetService("VirtualUser")
Core.HttpService = game:GetService("HttpService")

--// Player
Core.LocalPlayer = Core.Players.LocalPlayer

function Core:GetCharacter()
    return self.LocalPlayer.Character
        or self.LocalPlayer.CharacterAdded:Wait()
end

function Core:GetHumanoid()
    local Character = self:GetCharacter()

    return Character:FindFirstChildOfClass("Humanoid")
end

function Core:GetRoot()
    local Character = self:GetCharacter()

    return Character:FindFirstChild("HumanoidRootPart")
end

function Core:Notify(Text)
    print("[ZenithHub]:", Text)
end

return Core
