local AutoQuest = {}

-- [[ CONFIGURAÇÕES PRINCIPAIS ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ TABELA DE QUESTS ]]
_G.QuestConfig = {
    ["Bandit"] = {
        NPCName = "Bandits Quest Giver",
        QuestNameInGame = "Bandits",
        QuestNumber = 1,
        MobName = "Bandit",
        LevelRequired = 0
    }
}

-- [[ FUNÇÃO HASQUEST (CORRIGIDA VIA DEX) ]]
function _G.HasQuest()
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
function _G.TweenTo(CFrameTarget)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    -- Usando .p para garantir compatibilidade no Delta
    local Distance = (Root.Position - CFrameTarget.p).Magnitude
    local Speed = 300 
    local Time = Distance / Speed

    local Tween = TweenService:Create(Root, TweenInfo.new(Time, Enum.EasingStyle.Linear), {CFrame = CFrameTarget})
    Tween:Play()
    Tween.Completed:Wait()
end

-- [[ FUNÇÃO PARA PEGAR A MISSÃO ]]
function _G.TakeQuest(QuestKey)
    local config = _G.QuestConfig[QuestKey]
    if not config then return end

    local NPC = workspace:FindFirstChild(config.NPCName) or (workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild(config.NPCName))
    
    if NPC and NPC:FindFirstChild("HumanoidRootPart") then
        _G.TweenTo(NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        task.wait(0.5)
        
        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if Remote then
            Remote:InvokeServer("StartQuest", config.QuestNameInGame, config.QuestNumber)
        end
    end
end

-- [[ FUNÇÃO PARA MATAR OS MONSTROS ]]
function _G.FarmMobs(QuestKey)
    local config = _G.QuestConfig[QuestKey]
    if not config then return end

    for _, mob in pairs(workspace:GetChildren()) do
        if mob.Name == config.MobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and _G.HasQuest() then
            while mob.Humanoid.Health > 0 and _G.HasQuest() do
                task.wait()
                
                local Character = LocalPlayer.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                
                if Root and mob:FindFirstChild("HumanoidRootPart") then
                    Root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    
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

-- Vincula as funções à tabela que o ZenithHub vai ler ao carregar
AutoQuest.HasQuest = _G.HasQuest
AutoQuest.TakeQuest = _G.TakeQuest
AutoQuest.FarmMobs = _G.FarmMobs

-- Retorna o módulo para o loader do script do menu funcionar
return AutoQuest
