-- [[ ZENITH HUB - BACKEND ATUALIZADO (InfoService + Pull Lever & Prehistoric) ]] --

if not getgenv().ZenithHub then getgenv().ZenithHub = {} end
if not getgenv().ZenithHub.Modules then getgenv().ZenithHub.Modules = {} end

if not getgenv().ZenithHub.Core then
    getgenv().ZenithHub.Core = {
        GetLevel = function() 
            local lp = game:GetService("Players").LocalPlayer
            local data = lp:FindFirstChild("Data") or lp:FindFirstChild("leaderstats")
            local level = data and (data:FindFirstChild("Level") or data:FindFirstChild("Lv"))
            return level and level.Value or 0
        end
    }
end

local Core = getgenv().ZenithHub.Core
local Info = {}

Info.Data = {
    Level = 0,
    Sea = "Unknown",
    Fruit = "None",
    PullLever = false, -- Status da Alavanca
    Mirage = false,
    Kitsune = false,
    FrozenIsland = false,
    PrehistoricIsland = false, -- Status da Prehistoric
    FruitSpawned = false,
    FullMoon = false,
    Factory = false,
    MoonProgress = "Verificando...",
    CursedCaptain = false,
    Darkbeard = false,
    CakePrince = false,
    DoughKing = false,
    RipIndra = false
}

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

function Info:GetSea()
    local id = game.PlaceId
    if id == 2753915549 then return "Sea 1" end
    if id == 4442272183 then return "Sea 2" end
    if id == 7449423635 then return "Sea 3" end
    return "Unknown"
end

function Info:GetFruit()
    local foldersToSearch = {"Data", "leaderstats", "Stats", "PlayerData"}
    for _, folderName in ipairs(foldersToSearch) do
        local folder = LP:FindFirstChild(folderName)
        if folder then
            local fruitValue = folder:FindFirstChild("Fruit") or folder:FindFirstChild("DevilFruit")
            if fruitValue and fruitValue.Value ~= "" then
                return tostring(fruitValue.Value):gsub("%-", " ")
            end
        end
    end
    return "No Fruit"
end

-- Pega se a alavanca da Mirage/Raça V4 já foi puxada pelo jogador na conta dele
function Info:GetPullLever()
    -- No Blox Fruits, o progresso de quests e alavancas fica na pasta "Variables" do jogador
    local variables = LP:FindFirstChild("Variables")
    if variables then
        local lever = variables:FindFirstChild("PullLever") or variables:FindFirstChild("Lever") or variables:FindFirstChild("DungeonLever")
        if lever then
            return lever.Value == true or lever.Value == 1
        end
    end
    return false
end

function Info:GetMoonProgress()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then return "Céu não encontrado" end
    local texture = tostring(sky.MoonTextureId)
    
    if texture:find("9431") or texture:find("Full") or texture:find("9013498700") then return "🌕 É HOJE! (0 luas faltam)"
    elseif texture:find("9051") or texture:find("9014138839") then return "¾️ Falta 1 lua (Amanhã)"
    elseif texture:find("4490") then return "🌗 Faltam 2 luas"
    elseif texture:find("0171") then return "🌘 Faltam 3 luas"
    elseif texture:find("3656") or texture:find("50625484") then return "🌑 Faltam 4 luas (Lua Nova)"
    elseif texture:find("0532") then return "🌒 Faltam 5 luas"
    elseif texture:find("50086") or texture:find("4000") or texture:find("9014238216") then return "🌓 Faltam 6 luas (Crescente)"
    elseif texture:find("8693") then return "🌔 Faltam 7 luas"
    end
    return "Fase Desconhecida"
end

-- Scanner Avançado do Mundo
function Info:ScanWorld()
    -- 1. Varredura na pasta Map
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, v in ipairs(mapFolder:GetChildren()) do
            local n = v.Name:lower()
            if n:find("mirage") or n:find("mystic") then self.Data.Mirage = true
            elseif n:find("kitsune") then self.Data.Kitsune = true
            elseif n:find("frozen") then self.Data.FrozenIsland = true
            elseif n:find("prehistoric") or n:find("dinosaur") then self.Data.PrehistoricIsland = true
            elseif n:find("factory") or n:find("core") then self.Data.Factory = true
            end
        end
    end

    -- 2. Varredura direta no Workspace
    for _, v in ipairs(Workspace:GetChildren()) do
        local n = v.Name:lower()
        
        if n:find("mirage") or n:find("mystic") then self.Data.Mirage = true
        elseif n:find("kitsune") then self.Data.Kitsune = true
        elseif n:find("frozen") then self.Data.FrozenIsland = true
        elseif n:find("prehistoric") or n:find("dinosaur") then self.Data.PrehistoricIsland = true
        elseif n:find("factory") and v:FindFirstChild("Core") then self.Data.Factory = true
        
        -- Fruta no chão
        elseif v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("Fruta")) then
            self.Data.FruitSpawned = true
        elseif v:IsA("Model") and (v.Name:find("Fruit") or v.Name:find("Fruta")) then
            self.Data.FruitSpawned = true
        
        -- Bosses Vivos
        elseif v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local bossName = v.Name
            if bossName == "Cursed Captain" then self.Data.CursedCaptain = true
            elseif bossName == "Darkbeard" then self.Data.Darkbeard = true
            elseif bossName == "Cake Prince" then self.Data.CakePrince = true
            elseif bossName == "Dough King" then self.Data.DoughKing = true
            elseif bossName == "rip_indra True Form" or bossName == "rip_indra" then self.Data.RipIndra = true
            end
        end
    end
    
    -- 3. Pasta extra de NPCs (Enemies)
    local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace:FindFirstChild("NPCs")
    if enemiesFolder then
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local bossName = v.Name
                if bossName == "Cursed Captain" then self.Data.CursedCaptain = true
                elseif bossName == "Darkbeard" then self.Data.Darkbeard = true
                elseif bossName == "Cake Prince" then self.Data.CakePrince = true
                elseif bossName == "Dough King" then self.Data.DoughKing = true
                elseif bossName == "rip_indra True Form" or bossName == "rip_indra" then self.Data.RipIndra = true
                end
            end
        end
    end
end

function Info:Start()
    task.spawn(function()
        while task.wait(1) do
            local successLevel, level = pcall(function() return Core:GetLevel() end)
            self.Data.Sea = self:GetSea()
            self.Data.Fruit = self:GetFruit()
            self.Data.PullLever = self:GetPullLever() -- Atualiza a alavanca
            self.Data.Level = successLevel and level or 0
            self.Data.FullMoon = (Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6)
            self.Data.MoonProgress = self:GetMoonProgress()

            -- Reseta os status antes de re-escanear
            self.Data.Mirage = false
            self.Data.Kitsune = false
            self.Data.FrozenIsland = false
            self.Data.PrehistoricIsland = false
            self.Data.FruitSpawned = false
            self.Data.Factory = false
            self.Data.CursedCaptain = false
            self.Data.Darkbeard = false
            self.Data.CakePrince = false
            self.Data.DoughKing = false
            self.Data.RipIndra = false

            self:ScanWorld()
        end
    end)
end

getgenv().ZenithHub.Modules.InfoService = Info
Info:Start()
print("[ZenithHub] Module InfoService carregado com todas as funções!")
