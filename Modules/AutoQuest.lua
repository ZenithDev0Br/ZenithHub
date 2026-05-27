local AutoQuest = {}

-- Serviços do Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")

-- IDs Oficiais dos mapas do Blox Fruits
local PlaceID = game.PlaceId
local Sea1_ID = 2753915549
local Sea2_ID = 4442272023
local Sea3_ID = 7449423635

-- Links Oficiais do seu GitHub
local Link_Sea1 = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/refs/heads/main/Modules/QuestData/Sea1.lua"
local Link_Sea2 = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/refs/heads/main/Modules/QuestData/Sea2.lua"
local Link_Sea3 = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/refs/heads/main/Modules/QuestData/Sea3.lua"

-- Função que baixa as tabelas direto do seu GitHub
local function LoadQuests()
    local success, result
    if PlaceID == Sea1_ID then
        success, result = pcall(function() return loadstring(game:HttpGet(Link_Sea1))() end)
    elseif PlaceID == Sea2_ID then
        success, result = pcall(function() return loadstring(game:HttpGet(Link_Sea2))() end)
    elseif PlaceID == Sea3_ID then
        success, result = pcall(function() return loadstring(game:HttpGet(Link_Sea3))() end)
    else
        warn("[ZenithHub] Não foi possível identificar o Sea atual pelo PlaceID.")
        return {}
    end

    if success and type(result) == "table" then
        print("[ZenithHub] Quests carregadas com sucesso!")
        return result
    else
        warn("[ZenithHub] Erro crítico ao baixar as quests:", result)
        return {}
    end
end

AutoQuest.Quests = LoadQuests()

function AutoQuest:GetLevel()
    local Data = LocalPlayer:FindFirstChild("Data")
    if not Data then return 0 end
    local Level = Data:FindFirstChild("Level")
    return Level and Level.Value or 0
end

function AutoQuest:GetQuestData()
    local Level = self:GetLevel()
    for _, Quest in ipairs(self.Quests) do
        if Level >= Quest.Min and Level <= Quest.Max then
            return Quest
        end
    end
end

-- Detecção aprimorada e direta da Quest na sua PlayerGui
function AutoQuest:HasQuest()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if PlayerGui then
        local Main = PlayerGui:FindFirstChild("Main")
        if Main then
            local QuestFrame = Main:FindFirstChild("Quest")
            if QuestFrame and QuestFrame.Visible == true then
                return true
            end
        end
    end
    return false
end

local db = false -- Trava de segurança contra spam do servidor
function AutoQuest:StartQuest()
    if self:HasQuest() or db then return false end
    
    local QuestData = self:GetQuestData()
    if not QuestData or #self.Quests == 0 then return false end

    db = true
    local Success, Result = pcall(function()
        return CommF:InvokeServer(
            "StartQuest",
            QuestData.QuestName,
            QuestData.QuestLevel
        )
    end)
    
    -- Pausa essencial para a interface do jogo atualizar antes do próximo ciclo
    task.wait(1.5) 
    db = false

    if Success then
        print("[ZenithHub] Solicitada nova quest:", QuestData.Enemy)
        return true
    end
    return false
end

return AutoQuest
