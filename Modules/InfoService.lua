-- [[ ZENITH HUB - BACKEND (InfoService) ]] --

if not getgenv().ZenithHub then getgenv().ZenithHub = {} end
if not getgenv().ZenithHub.Modules then getgenv().ZenithHub.Modules = {} end

-- Fallback para o Core do teu script principal não quebrar
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
    Mirage = false,
    Kitsune = false,
    FullMoon = false,
    Factory = false,
    MoonProgress = "Verificando..."
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

-- Substitui apenas esta função no teu InfoService:
function Info:GetMoonProgress()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then return "Céu não encontrado" end
    
    local texture = tostring(sky.MoonTextureId)
    
    -- Filtro inteligente: procura o final do número da ID (assim não importa o começo do link)
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
    elseif texture:find("4000") or texture:find("9014238216") then
        return "🌓 Faltam 6 luas"
    elseif texture:find("8693") then
        return "🌔 Faltam 7 luas"
    end
    
    -- Fallback de emergência (caso o jogo mude de ID, ele mostra o número bruto para sabermos qual é)
    local rawId = texture:match("%d+") or "Sem ID"
    return "Fase Antiga/Nova (ID: " .. rawId .. ")"
end

function Info:ScanWorld()
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        for _, v in ipairs(mapFolder:GetChildren()) do
            local n = v.Name:lower()
            if n:find("mirage") or n:find("mystic") then self.Data.Mirage = true
            elseif n:find("kitsune") then self.Data.Kitsune = true
            elseif n:find("factory") or n:find("core") then self.Data.Factory = true
            end
        end
    end
    for _, v in ipairs(Workspace:GetChildren()) do
        local n = v.Name:lower()
        if n:find("mirage") or n:find("mystic") then self.Data.Mirage = true
        elseif n:find("kitsune") then self.Data.Kitsune = true
        elseif n:find("factory") and v:FindFirstChild("Core") then self.Data.Factory = true
        end
    end
end

function Info:Start()
    task.spawn(function()
        while task.wait(1) do
            local successLevel, level = pcall(function() return Core:GetLevel() end)
            self.Data.Sea = self:GetSea()
            self.Data.Fruit = self:GetFruit()
            self.Data.Level = successLevel and level or 0
            self.Data.FullMoon = (Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6)
            self.Data.MoonProgress = self:GetMoonProgress()
            
            self.Data.Mirage = false
            self.Data.Kitsune = false
            self.Data.Factory = false
            self:ScanWorld()
        end
    end)
end

getgenv().ZenithHub.Modules.InfoService = Info
Info:Start()
print("[ZenithHub] InfoService iniciado com sucesso!")
