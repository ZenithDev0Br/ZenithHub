local ZenithHub = getgenv().ZenithHub
local Core = ZenithHub.Core

local Info = {}

Info.Data = {
    Level = 0,
    Sea = "Unknown",
    Fruit = "None"
}

function Info:GetSea()
    local id = game.PlaceId

    if id == 2753915549 then return "Sea 1" end
    if id == 4442272183 then return "Sea 2" end
    if id == 7449423635 then return "Sea 3" end

    return "Unknown"
end

function Info:GetFruit()
    local bp = game.Players.LocalPlayer:FindFirstChild("Backpack")
    if not bp then return "None" end

    for _,v in pairs(bp:GetChildren()) do
        if v:IsA("Tool") then
            return v.Name
        end
    end

    return "None"
end

function Info:Start()

    task.spawn(function()
        while task.wait(1.5) do
            self.Data.Level = Core:GetLevel()
            self.Data.Sea = self:GetSea()
            self.Data.Fruit = self:GetFruit()
        end
    end)

end

ZenithHub.Modules = ZenithHub.Modules or {}
ZenithHub.Modules.InfoService = Info

Info:Start()

return Info
