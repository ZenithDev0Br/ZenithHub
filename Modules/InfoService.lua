-- [[ ZENITH HUB - SCRIPT COMPLETO OTIMIZADO ]] --

-- 1. INICIALIZAÇÃO DO AMBIENTE GLOBAL
if not getgenv().ZenithHub then
    getgenv().ZenithHub = {}
end
if not getgenv().ZenithHub.Modules then
    getgenv().ZenithHub.Modules = {}
end

-- Proteção: Caso o seu script principal de 'Core' ainda não tenha carregado,
-- criamos um fallback para o GetLevel não quebrar o script.
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
    FullMoon = false,
    Factory = false
}

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Detectar o Sea (Mundo) atual
function Info:GetSea()
    local id = game.PlaceId
    if id == 2753915549 then return "Sea 1" end
    if id == 4442272183 then return "Sea 2" end
    if id == 7449423635 then return "Sea 3" end
    return "Unknown"
end

-- Detectar Fruta na mão ou no inventário
function Info:GetFruit()
    local function findFruitIn(parent)
        if not parent then return nil end
        for _, v in pairs(parent:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("Physical") or v.Name:find("Fruta")) then
                return v.Name
            end
        end
        return nil
    end
    return findFruitIn(LP.Character) or findFruitIn(LP:FindFirstChild("Backpack")) or "None"
end

-- Scanner de Mundo Otimizado (Zero Lag)
function Info:ScanWorld()
    local mapFolder = Workspace:FindFirstChild("Map")
    
    -- Escaneia a pasta interna onde eventos costumam nascer
    if mapFolder then
        for _, v in ipairs(mapFolder:GetChildren()) do
            local n = v.Name:lower()
            if n:find("mirage") or n:find("mystic") then
                self.Data.Mirage = true
            elseif n:find("kitsune") then
                self.Data.Kitsune = true
            elseif n:find("factory") or n:find("core") then
                self.Data.Factory = true
            end
        end
    end

    -- Escaneia a superfície do Workspace por garantia (Super leve)
    for _, v in ipairs(Workspace:GetChildren()) do
        local n = v.Name:lower()
        if n:find("mirage") or n:find("mystic") then
            self.Data.Mirage = true
        elseif n:find("kitsune") then
            self.Data.Kitsune = true
            -- Se achar a fábrica solta no Workspace principal do Sea 2
            -- Só ativa se o Core do evento estiver ativo
            if n:find("factory") and v:FindFirstChild("Core") then 
                self.Data.Factory = true
            end
        end
    end
end

-- Ciclo de dia/noite simples
function Info:GetFullMoon()
    return Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6
end

-- Inicia o Loop interno de atualização do InfoService
function Info:Start()
    task.spawn(function()
        while task.wait(1) do
            local successLevel, level = pcall(function() return Core:GetLevel() end)

            self.Data.Sea = self:GetSea()
            self.Data.Fruit = self:GetFruit()
            self.Data.Level = successLevel and level or 0
            self.Data.FullMoon = self:GetFullMoon()

            -- Reseta os status antes de checar novamente
            self.Data.Mirage = false
            self.Data.Kitsune = false
            self.Data.Factory = false

            self:ScanWorld()
        end
    end)
end

-- Registra e inicializa o serviço
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

local label = Tab:AddParagraph("Info", "Loading...")

-- Loop da UI: Lê os dados salvos no InfoService e exibe na tela
task.spawn(function()
    while task.wait(1) do
        local InfoService = getgenv().ZenithHub.Modules.InfoService
        
        if InfoService and InfoService.Data then
            local d = InfoService.Data

            -- Conversão visual de booleanos para status limpos
            local mirageStatus  = d.Mirage and "🟢 Spawned!" or "🔴 Not Found"
            local kitsuneStatus  = d.Kitsune and "🟢 Spawned!" or "🔴 Not Found"
            local factoryStatus = d.Factory and "🟢 Active!" or "🔴 Inactive"
            local timeStatus    = d.FullMoon and "🌕 Night" or "☀️ Day"

            -- Montagem do texto final
            local text =
                "Level: " .. tostring(d.Level or 0) .. "\n" ..
                "Sea: " .. tostring(d.Sea or "Unknown") .. "\n" ..
                "Fruit: " .. tostring(d.Fruit or "None") .. "\n" ..
                "----------------------------------\n" ..
                "Mirage Island: " .. mirageStatus .. "\n" ..
                "Kitsune Island: " .. kitsuneStatus .. "\n" ..
                "Factory Event: " .. factoryStatus .. "\n" ..
                "World Time: " .. timeStatus

            -- pcall de segurança para atualizar o texto da label
            pcall(function()
                label:Set(text)
            end)
        else
            pcall(function()
                label:Set("Aguardando InfoService carregar...")
            end)
        end
    end
end)
