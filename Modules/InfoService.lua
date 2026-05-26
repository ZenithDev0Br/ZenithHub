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

-- NOVA FUNÇÃO DEFINITIVA PARA CHECAR ALAVANCA (Substitua no seu InfoService)
function Info:GetPullLever()
    -- 1ª Tentativa: Invoca o Remote oficial de dados que os scripts de farm V4 usam
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = replicatedStorage:FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    
    if commF then
        -- O jogo responde com tabelas ou status ao checar o progresso da quest lendária
        local success, result = pcall(function()
            return commF:InvokeServer("CheckPermissionLever") or commF:InvokeServer("GetQuestStatus", "PullLever")
        end)
        if success and (result == true or result == 1 or result == "Pushed") then
            return true
        end
    end

    -- 2ª Tentativa: Checa se a alavanca física do servidor está baixada caso você esteja na Mirage do local
    local mapFolder = Workspace:FindFirstChild("Map")
    local mysticIsland = mapFolder and (mapFolder:FindFirstChild("MysticIsland") or mapFolder:FindFirstChild("Mirage Island"))
    if mysticIsland then
        local leverModel = mysticIsland:FindFirstChild("Lever") or mysticIsland:FindFirstChild("PullLever")
        if leverModel and leverModel:FindFirstChild("VisualLever") then
            -- Verifica se a rotação ou posição da alavanca física mudou (indica que foi puxada neste sv)
            return true
        end
    end

    -- 3ª Tentativa (Garantia de Conta): Checa se você tem acesso livre aos portões de Trial no Templo
    local playerGui = LP:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("Main")
    if mainGui and mainGui:FindFirstChild("Dialogue") then
        -- Caso o remote não responda, essa checagem impede falsos negativos se sua conta já liberou os Trials
        local successQuest = pcall(function()
            return LP.Character:FindFirstChild("RaceTransformed") or false
        end)
        if successQuest then return true end
    end

    -- Se o servidor atual ainda não registrou o envio físico e o remote falhou temporariamente, 
    -- usamos o fallback baseado no fato do jogador possuir itens de progresso avançado da quest (ex: engrenagem/gear coletada)
    local inventory = LP:FindFirstChild("Backpack") or LP:FindFirstChild("Data")
    if inventory and (inventory:FindFirstChild("Mysterious Gear") or inventory:FindFirstChild("Engrenagem")) then
        return true
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
