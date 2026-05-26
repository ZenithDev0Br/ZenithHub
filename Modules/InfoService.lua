-- [[ ZENITH HUB - SCRIPT COMPLETO COM FRUTA SPAWNADA E FROZEN ISLAND ]] --

-- 1. INICIALIZAÇÃO DO AMBIENTE GLOBAL
if not getgenv().ZenithHub then
    getgenv().ZenithHub = {}
end
if not getgenv().ZenithHub.Modules then
    getgenv().ZenithHub.Modules = {}
end

-- Fallback de segurança para o nível do jogador
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

-- ============================================================================
-- 2. MÓDULO BACKEND (InfoService)
-- ============================================================================
local Info = {}

Info.Data = {
    Level = 0,
    Sea = "Unknown",
    Fruit = "None",
    Mirage = false,
    Kitsune = false,
    FrozenIsland = false, -- Nova variável para a Frozen Island
    FruitSpawned = false, -- Nova variável para Fruta no Chão
    FullMoon = false,
    Factory = false,
    MoonProgress = "Verificando..."
}

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Detectar o Sea (Mundo) atual via PlaceId
function Info:GetSea()
    local id = game.PlaceId
    if id == 2753915549 then return "Sea 1" end
    if id == 4442272183 then return "Sea 2" end
    if id == 7449423635 then return "Sea 3" end
    return "Unknown"
end

-- Pega a fruta REAL que comeu e está ativa no personagem
function Info:GetFruit()
    local foldersToSearch = {"Data", "leaderstats", "Stats", "PlayerData"}
    for _, folderName in ipairs(foldersToSearch) do
        local folder = LP:FindFirstChild(folderName)
        if folder then
            local fruitValue = folder:FindFirstChild("Fruit") or folder:FindFirstChild("DevilFruit")
            if fruitValue and fruitValue.Value ~= "" then
                local name = tostring(fruitValue.Value):gsub("%-", " ")
                return name
            end
        end
    end
    
    local character = LP.Character
    if character then
        for _, v in ipairs(character:GetChildren()) do
            if v:IsA("Tool") and (v.Name:lower():find("fruit") or v.Name:lower():find("sand")) then
                return v.Name:gsub("%-", " ")
            end
        end
    end
    
    return "No Fruit"
end

-- Contador de luas corrigido com filtro curto
function Info:GetMoonProgress()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then return "Céu não encontrado" end
    
    local texture = tostring(sky.MoonTextureId)
    
    if texture:find("9431") or texture:find("Full") or texture:find("9013498700") then 
        return "🌕 É HOJE! (0 luas faltam)"
    elseif texture:find("9051") or texture:find("9014138839") then 
        return "¾️ Falta 1 lua (Amanhã)"
    elseif texture:find("4490") then 
        return "🌗 Faltam 2 luas"
    elseif texture:find("0171") then 
        return "🌘 Faltam 3 luas"
    elseif texture:find("3656") or texture:find("50625484") then 
        return "🌑 Faltam 4 luas (Lua Nova)"
    elseif texture:find("0532") then 
        return "🌒 Faltam 5 luas"
    elseif texture:find("50086") or texture:find("4000") or texture:find("9014238216") then 
        return "🌓 Faltam 6 luas (Crescente)"
    elseif texture:find("8693") then 
        return "🌔 Faltam 7 luas"
    end
    
    local rawId = texture:match("%d+") or "Sem ID"
    return "Fase Desconhecida (ID: " .. rawId .. ")"
end

-- Scanner de Mundo Otimizado (Escaneia Ilhas, Eventos e Frutas no chão)
function Info:ScanWorld()
    -- 1. Verifica na pasta Map
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, v in ipairs(mapFolder:GetChildren()) do
            local n = v.Name:lower()
            if n:find("mirage") or n:find("mystic") then 
                self.Data.Mirage = true
            elseif n:find("kitsune") then 
                self.Data.Kitsune = true
            elseif n:find("frozen") then -- Deteta a Frozen Island na pasta Map
                self.Data.FrozenIsland = true
            elseif n:find("factory") or n:find("core") then 
                self.Data.Factory = true
            end
        end
    end

    -- 2. Verifica diretamente no Workspace (Ilhas e Frutas soltas)
    for _, v in ipairs(Workspace:GetChildren()) do
        local n = v.Name:lower()
        if n:find("mirage") or n:find("mystic") then 
            self.Data.Mirage = true
        elseif n:find("kitsune") then 
            self.Data.Kitsune = true
        elseif n:find("frozen") then -- Deteta a Frozen Island no Workspace
            self.Data.FrozenIsland = true
        elseif n:find("factory") and v:FindFirstChild("Core") then 
            self.Data.Factory = true
        -- DETETOR DE FRUTA SPAWNADA: Procura por modelos de fruta soltos no chão
        elseif v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("Fruta")) then
            self.Data.FruitSpawned = true
        elseif v:IsA("Model") and (v.Name:find("Fruit") or v.Name:find("Fruta") or v:FindFirstChild("Handle")) then
            -- Muitas frutas dropadas ficam como Model contendo um "Handle" e a palavra Fruit
            if v.Name:find("Fruit") or v.Name:find("Fruta") then
                self.Data.FruitSpawned = true
            end
        end
    end
end

-- Inicia o Loop interno do InfoService
function Info:Start()
    task.spawn(function()
        while task.wait(1) do
            local successLevel, level = pcall(function() return Core:GetLevel() end)

            self.Data.Sea = self:GetSea()
            self.Data.Fruit = self:GetFruit()
            self.Data.Level = successLevel and level or 0
            self.Data.FullMoon = (Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6)
            self.Data.MoonProgress = self:GetMoonProgress()

            -- Reseta os status antes de re-escanear o mapa
            self.Data.Mirage = false
            self.Data.Kitsune = false
            self.Data.FrozenIsland = false
            self.Data.FruitSpawned = false
            self.Data.Factory = false

            self:ScanWorld()
        end
    end)
end

getgenv().ZenithHub.Modules.InfoService = Info
Info:Start()

-- ============================================================================
-- 3. CRIAÇÃO DA INTERFACE GRÁFICA (UI)
-- ============================================================================
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Simple Panel",
    ScriptFolder = "ZenithHub"
})

local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

-- Criando o elemento usando o formato oficial da Wand UI
local label = Tab:AddParagraph("Status do Jogador e Mundo", "Aguardando sincronização...")

-- Loop de atualização visual da interface
task.spawn(function()
    while task.wait(1) do
        local InfoService = getgenv().ZenithHub.Modules.InfoService
        
        if InfoService and InfoService.Data then
            local d = InfoService.Data

            local mirageStatus  = d.Mirage and "🟢 Spawned!" or "🔴 Not Found"
            local kitsuneStatus = d.Kitsune and "🟢 Spawned!" or "🔴 Not Found"
            local frozenStatus  = d.FrozenIsland and "🟢 Active!" or "🔴 Not Found" -- Status Frozen Island
            local fruitSpStatus = d.FruitSpawned and "🟢 SPAWNADA NO CHÃO!" or "🔴 Nenhuma" -- Status Fruta no Chão
            local factoryStatus = d.Factory and "🟢 Active!" or "🔴 Inactive"
            local timeStatus    = d.FullMoon and "🌕 Noite" or "☀️ Dia"

            -- Montagem final das strings no painel
            local text =
                "Level: " .. tostring(d.Level or 0) .. "\n" ..
                "Sea: " .. tostring(d.Sea or "Unknown") .. "\n" ..
                "Fruit: " .. tostring(d.Fruit or "None") .. "\n" ..
                "----------------------------------\n" ..
                "Ciclo Lunar: " .. tostring(d.MoonProgress) .. "\n" ..
                "Período Atual: " .. timeStatus .. "\n" ..
                "----------------------------------\n" ..
                "Fruta no Mapa: " .. fruitSpStatus .. "\n" .. -- Linha da fruta no chão
                "Mirage Island: " .. mirageStatus .. "\n" ..
                "Kitsune Island: " .. kitsuneStatus .. "\n" ..
                "Frozen Island: " .. frozenStatus .. "\n" .. -- Linha da Frozen Island
                "Factory Event: " .. factoryStatus

            -- Modifica usando o método correto da documentação (SetDescription)
            pcall(function()
                label:SetDescription(text)
            end)
        else
            pcall(function()
                label:SetDescription("Aguardando InfoService carregar...")
            end)
        end
    end
end)
