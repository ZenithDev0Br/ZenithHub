local AutoQuest = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ BASE DE DADOS COM COORDENADAS ADICIONADAS ]]
_G.QuestConfig = {
    {
        MinLevel = 0,
        MaxLevel = 9,
        NPCName = "Bandit Quest Giver",
        QuestNameInGame = "Bandits",
        QuestNumber = 1,
        MobName = "Bandit",
        -- Adicionado as posições que faltavam para o FarmLevel ler:
        QuestPosition = Vector3.new(1059, 16, 1549),
        EnemyPosition = Vector3.new(1145, 17, 1630)
    },
    {
        MinLevel = 10,
        MaxLevel = 14,
        NPCName = "Monkey Quest Giver",
        QuestNameInGame = "JungleQuest",
        QuestNumber = 1,
        MobName = "Monkey",
        QuestPosition = Vector3.new(-1598, 37, 153),
        EnemyPosition = Vector3.new(-1610, 36, 230)
    }
}

-- [[ RETORNA OS DADOS DA QUEST PARA O OUTRO SCRIPT ]]
function AutoQuest:GetQuestData()
    local level = LocalPlayer.Data.Level.Value
    for _, dados in pairs(_G.QuestConfig) do
        if level >= dados.MinLevel and level <= dados.MaxLevel then
            return {
                Enemy = dados.MobName,
                QuestName = dados.QuestNameInGame,
                QuestID = dados.QuestNumber,
                QuestPosition = dados.QuestPosition,
                EnemyPosition = dados.EnemyPosition
            }
        end
    end
    -- Padrão caso não ache o nível (Bandits)
    local padrao = _G.QuestConfig[1]
    return {
        Enemy = padrao.MobName,
        QuestName = padrao.QuestNameInGame,
        QuestID = padrao.QuestNumber,
        QuestPosition = padrao.QuestPosition,
        EnemyPosition = padrao.EnemyPosition
    }
end

-- [[ VERIFICA SE JÁ TEM MISSÃO NA TELA ]]
function AutoQuest:HasQuest()
    local myFolder = LocalPlayer.PlayerGui:FindFirstChild("my")
    if myFolder then
        local questFrame = myFolder:FindFirstChild("Quest") or myFolder:FindFirstChild("quest")
        if questFrame and questFrame.Visible then
            return true
        end
    end
    return false
end

-- [[ INICIA A MISSÃO VIA REPLICATED STORAGE ]]
function AutoQuest:StartQuest()
    local dados = self:GetQuestData()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    
    if Remote then
        Remote:InvokeServer("StartQuest", dados.QuestName, dados.QuestID)
    end
end

-- Removeu-se o loop antigo que conflitava com o FarmLevel.lua

return AutoQuest
