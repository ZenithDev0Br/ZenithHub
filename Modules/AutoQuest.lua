-- [[ CONFIGURAÇÕES PRINCIPAIS ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ SUAS TABELAS DE QUESTS ]]
-- Aqui você pode puxar ou colar as tabelas do Niki (SIA1, SIA2)
-- Montei esse exemplo para o script saber o que fazer:
local QuestConfig = {
    ["Bandit"] = {
        NPCName = "Quest Giver",
        QuestNameInGame = "Bandits",
        QuestNumber = 1,
        MobName = "Bandit",
        LevelRequired = 0
    }
    -- Você pode adicionar as outras missões seguindo essa lógica
}

-- [[ FUNÇÃO HASQUEST (CORRIGIDA VIA DEX) ]]
function HasQuest()
    local myFolder = LocalPlayer.PlayerGui:FindFirstChild("my")
    if myFolder then
        local questFrame = myFolder:FindFirstChild("Quest") or myFolder:FindFirstChild("quest")
        if questFrame and questFrame.Visible then
            return true
        end
    end
    return false
end

-- [[ FUNÇÃO DE MOVIMENTAÇÃO (TWEEN) ]]
function TweenTo(CFrameTarget)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local Distance = (Root.Position - CFrameTarget.p).Magnitude
    local Speed = 300 -- Velocidade do teleporte/voo
    local Time = Distance / Speed

    local Tween = TweenService:Create(Root, TweenInfo.new(Time, Enum.EasingStyle.Linear), {CFrame = CFrameTarget})
    Tween:Play()
    Tween.Completed:Wait()
end

-- [[ FUNÇÃO PARA PEGAR A MISSÃO ]]
function TakeQuest(QuestKey)
    local config = QuestConfig[QuestKey]
    if not config then return end

    -- Procura o NPC no mapa (geralmente ficam em workspace.NPCs ou direto no workspace)
    local NPC = workspace:FindFirstChild(config.NPCName) or (workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild(config.NPCName))
    
    if NPC and NPC:FindFirstChild("HumanoidRootPart") then
        -- Vai até o NPC
        TweenTo(NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        task.wait(0.5)
        
        -- Dispara o Remote padrão do Blox Fruits para pegar a quest
        -- (Se o seu jogo usar outro sistema, altere essa linha do Remote)
        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if Remote then
            Remote:InvokeServer("StartQuest", config.QuestNameInGame, config.QuestNumber)
        end
    end
end

-- [[ FUNÇÃO PARA MATAR OS MONSTROS ]]
function FarmMobs(QuestKey)
    local config = QuestConfig[QuestKey]
    if not config then return end

    -- Procura os inimigos no workspace
    for _, mob in pairs(workspace:GetChildren()) do
        -- Verifica se é o monstro certo, se está vivo e se você ainda tem a quest
        if mob.Name == config.MobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and HasQuest() then
            while mob.Humanoid.Health > 0 and HasQuest() do
                task.wait()
                
                local Character = LocalPlayer.Character
                local Root = Character Vomit and Character:FindFirstChild("HumanoidRootPart")
                
                if Root and mob:FindFirstChild("HumanoidRootPart") then
                    -- Teleporta e prende o seu personagem em cima do monstro (auto-farm padrão)
                    Root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    
                    -- Código para auto-clique/ataque (Ativa a ferramenta na mão)
                    local Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool")
                    if Tool then
                        Character.Humanoid:EquipTool(Tool)
                        Tool:Activate()
                    end
                end
            end
        end
    end
end

-- [[ LOOP PRINCIPAL DO AUTO QUEST ]]
task.spawn(function()
    while true do
        task.wait(0.5)
        
        -- Defina aqui qual chave da tabela usar (Você pode linkar com o seu sistema de nível)
        local CurrentQuest = "Bandit" 
        
        if not HasQuest() then
            -- Se não tiver quest na pasta 'my', vai pegar
            TakeQuest(CurrentQuest)
        else
            -- Se já tiver a quest, vai farmar os bixos
            FarmMobs(CurrentQuest)
        end
    end
end)
