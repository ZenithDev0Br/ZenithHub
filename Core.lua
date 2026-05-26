local Core = {}

Core.Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

Core.LocalPlayer = Core.Services.Players.LocalPlayer

function Core:GetCharacter()
    return self.LocalPlayer.Character or self.LocalPlayer.CharacterAdded:Wait()
end

function Core:GetRoot()
    local char = self:GetCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

function Core:Notify(msg)
    print("[ZenithHub] " .. msg)
end

return Core
