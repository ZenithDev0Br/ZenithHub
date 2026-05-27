local AutoQuest = {}

-- Serviços do Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")

-- IDs Oficiais dos mapas do Blox Fruits para checagem de Sea
local PlaceID = game.PlaceId
local Sea1_ID = 2753915549
local Sea2_ID = 4442272023
local Sea3_ID = 7449423635

-- ========================================================
-- ⚠️ DETALHE IMPORTANTE: COLOQUE SEUS LINKS RAW DO GITHUB AQUI
-- ========================================================
local Link_Sea1 = "https://raw.githubusercontent.com/SeuUsuario/SeuRepositorio/main/QuestData/Sea1.lua"
local Link_Sea2 = "https://raw.githubusercontent.com/SeuUsuario/SeuRepositorio/main/QuestData/Sea2.lua"
local Link_Sea3 = "https://raw.githubusercontent.com/SeuUsuario/SeuRepositorio/main/QuestData/Sea3.lua"

-- Função que baixa as tabelas direto do GitHub usando HttpGet e Loadstring
local function LoadQuests()
    local success, result
    
    if PlaceID == Sea1_ID then
        success, result = pcall(function() 
            return loadstring(game:HttpGet(Link_Sea1))() 
        end)
    elseif PlaceID == Sea2_ID then
        success, result = pcall(function() 
            return loadstring(game:HttpGet(Link_Sea2))() 
        end)
    elseif PlaceID == Sea3_ID then
        success, result = pcall(function() 
            return loadstring(game:HttpGet(Link_Sea3))() 
        end)
    else
        warn("[Quest] Não foi possível identificar o Sea atual pelo PlaceID.")
        return {}
    end

    if success and type(result) == "table" then
        print("[Quest] Quests baixadas do GitHub com sucesso!")
        return result
    else
        warn("[Quest] Erro crítico ao baixar do GitHub. Verifique os links RAW. Erro: ", result)
        return {}
    end
end

-- Define as quests carregando do GitHub de forma dinâmica
AutoQuest.Quests = LoadQuests()

-- Retorna o level atual do jogador baseado nos dados salvos do Blox Fruits
function AutoQuest:GetLevel()
    local Data = LocalPlayer:FindFirstChild("Data")
    if not Data then return 0 end

    local Level = Data:FindFirstChild("Level")
    return Level and Level.Value or 0
end

-- Procura na tabela qual a quest certa para o level atual do jogador
function AutoQuest:GetQuestData()
    local Level = self:GetLevel()

    for _, Quest in ipairs(self.Quests) do
        if Level >= Quest.Min and Level <= Quest.Max then
            return Quest
        end
    end
end

-- Verifica se o jogador já está com alguma Quest ativa na tela
function AutoQuest:HasQuest()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return false end

    local Main = PlayerGui:FindFirstChild("Main")
    if not Main then return false end

    local Quest = Main:FindFirstChild("Quest")
    if not Quest then return false end

    return Quest.Visible
end

-- Função principal para pegar a Quest no servidor
function AutoQuest:StartQuest()
    -- Se já tiver quest, não faz nada e retorna verdadeiro
    if self:HasQuest() then
        return true
    end

    local QuestData = self:GetQuestData()

    -- Se não achar quest para o level ou a tabela estiver vazia, cancela
    if not QuestData or #self.Quests == 0 then
        return false
    end

    -- Dispara o Remote de pegar quest de forma segura usando pcall
    local Success, Result = pcall(function()
        return CommF:InvokeServer(
            "StartQuest",
            QuestData.QuestName,
            QuestData.QuestLevel
        )
    end)

    if Success then
        print("[Quest] Quest iniciada com sucesso:", QuestData.Enemy)
        return true
    end

    warn("[Quest] Erro ao enviar solicitação ao servidor:", Result)
    return false
end

-- Loop em segundo plano que roda a cada 1 segundo procurando quests para pegar
task.spawn(function()
    while task.wait(1) do
        AutoQuest:StartQuest()
    end
end)

return AutoQuest
