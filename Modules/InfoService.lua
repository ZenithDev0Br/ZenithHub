local ZenithHub = getgenv().ZenithHub
local Core = ZenithHub.Core

local Info = {}

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

Info.Data = {
    Level = 0,
    Sea = "Unknown",
    Fruit = "None",
    Mirage = false,
    Kitsune = false,
    Factory = false,
    FullMoon = false
}

-- SEA
function Info:GetSea()
    local id = game.PlaceId

    if id == 2753915549 then return "Sea 1" end
    if id == 4442272183 then return "Sea 2" end
    if id == 7449423635 then return "Sea 3" end

    return "Unknown"
end

-- FRUIT
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

-- WORLD SCAN (LIGHT)
function Info:Scan()
    for _,v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") then
            local n = v.Name:lower()

            if n:find("mirage") then
                self.Data.Mirage = true
            elseif n:find("kitsune") then
                self.Data.Kitsune = true
            elseif n:find("factory") then
                self.Data.Factory = true
            end
        end
    end
end

-- LOOP (AGORA PERMITIDO SÓ NO MODULES)
function Info:Start()

    task.spawn(function()
        while task.wait(1) do

            self.Data.Level = Core:GetLevel()
            self.Data.Sea = self:GetSea()
            self.Data.Fruit = self:GetFruit()
            self.Data.FullMoon = (game:GetService("Lighting").ClockTime < 6 or game:GetService("Lighting").ClockTime > 18)

            self.Data.Mirage = false
            self.Data.Kitsune = false
            self.Data.Factory = false

            self:Scan()

        end
    end)

end

getgenv().ZenithHub.Modules.InfoService = Info

Info:Start()

return Info
