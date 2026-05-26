local Core = {}

Core.Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    RunService = game:GetService("RunService")
}

Core.Player = Core.Services.Players.LocalPlayer

function Core:GetCharacter()
    return self.Player.Character or self.Player.CharacterAdded:Wait()
end

function Core:GetRoot()
    local char = self:GetCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

function Core:GetLevel()
    local data = self.Player:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 0
end

return Core
