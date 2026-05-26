local Core = getgenv().ZenithHub.Core
local Info = {}

Info.Data = {
    Level = 0,
    Sea = "Unknown",
    Fruit = "None",
    Mirage = false,
    Kitsune = false,
    FullMoon = false,
    Factory = false
}

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local LP = Players.LocalPlayer

-- Sea detect (real via PlaceId)
function Info:GetSea()
    local id = game.PlaceId

    if id == 2753915549 then return "Sea 1" end
    if id == 4442272183 then return "Sea 2" end
    if id == 7449423635 then return "Sea 3" end

    return "Unknown"
end

-- Fruit detect real (Backpack)
function Info:GetFruit()
    local bp = LP:FindFirstChild("Backpack")
    if not bp then return "None" end

    for _,v in pairs(bp:GetChildren()) do
        if v:IsA("Tool") then
            return v.Name
        end
    end

    return "None"
end

-- World scanner REAL
function Info:ScanWorld()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local n = v.Name:lower()

            if n:find("mirage") then
                self.Data.Mirage = true
            end

            if n:find("kitsune") then
                self.Data.Kitsune = true
            end

            if n:find("factory") then
                self.Data.Factory = true
            end
        end
    end
end

-- Full moon REAL (visual cycle only)
function Info:GetFullMoon()
    return Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6
end

function Info:Start()

    task.spawn(function()
        while task.wait(1) do

            self.Data.Sea = self:GetSea()
            self.Data.Fruit = self:GetFruit()
            self.Data.Level = Core:GetLevel()
            self.Data.FullMoon = self:GetFullMoon()

            self.Data.Mirage = false
            self.Data.Kitsune = false
            self.Data.Factory = false

            self:ScanWorld()

        end
    end)

end

getgenv().ZenithHub.Modules.InfoService = Info

return Info
