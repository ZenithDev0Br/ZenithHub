local AutoQuest = {}

-- [[ CONFIGURAÇÕES PRINCIPAIS ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ PASSO 2: BANCO DE DADOS POR NÍVEL (ADAPTADO) ]]
-- Em vez de colocar coordenadas fixas, o script vai buscar o NPC e os Mobs pelo nome no mapa automaticamente!
local QuestDatabase = {
    {
        MinLevel = 0,
        MaxLevel = 9,
        NPCName = "Bandit Quest Giver",
        QuestNameInGame = "Bandits",
        QuestNumber = 1,
        MobName = "Bandit"
    },
    {
        MinLevel = 10,
        MaxLevel = 14,
        NPCName = "Monkey Quest Giver",
        QuestNameInGame = "JungleQuest", -- Altere para o nome real da quest do seu jogo
        QuestNumber = 1,
        MobName = "Monkey"
    }
    -- Você pode continuar adicionando as outras faixas de nível aqui seguindo o padrão
}

-- [[ FUNÇÃO PARA PEGAR OS DADOS BASEADO NO SEU NÍVEL ]]
local function ObterDadosDaMissao()
    local level = LocalPlayer.Data.Level.Value
    for _, dados in pairs(QuestDatabase) do
        if level >= dados.MinLevel and level <= dados.MaxLevel then
            return dados
        end
    end
    return QuestDatabase[1] -- Retorna a primeira (Bandits) por padrão caso não ache o nível
end

-- [[ FUNÇÃO HASQUEST (SUA DESCOBERTA NO DEX) ]]
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

-- [[ PASSO 3: TELEPORTE SEGURO (TWEEN) ]]
function _G.TweenTo(CFrameTarget)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local Distance = (Root.Position - CFrameTarget.p).Magnitude
    local Speed = 300 
    local Time = Distance / Speed

    local Tween = TweenService:Create(Root, TweenInfo.new(Time, Enum.EasingStyle.Linear), {CFrame = CFrameTarget})
    Tween:Play()
    Tween.Completed:Wait()
end

-- [[ PASSO 4: PEGAR A MISSÃO VIA REMOTE ]]
function _G.TakeQuest(dados)
    local NPC = workspace:FindFirstChild(dados.NPCName, true) -- Busca o NPC em qualquer pasta do mapa
    
    if NPC and NPC:FindFirstChild("HumanoidRootPart") then
        print("[Zenith] Voando até o NPC: " .. dados.NPCName)
        _G.TweenTo(NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        task.wait(0.5)
        
        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if Remote then
            Remote:InvokeServer("StartQuest", dados.QuestNameInGame, dados.QuestNumber)
        end
    else
        print("[Zenith] ERRO: NPC não encontrado: " .. dados.NPCName)
    end
end

-- [[ PASSO 5: COMBATE AUTOMÁTICO ]]
function _G.FarmMobs(dados)
    local enemyFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs") or workspace
    
    for _, mob in pairs(enemyFolder:GetChildren()) do
        if mob.Name == dados.MobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and _G.HasQuest() then
            
            while mob.Humanoid.Health > 0 and _G.HasQuest() do
                task.wait()
                
                local Character = LocalPlayer.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                
                if Root and mob:FindFirstChild("HumanoidRootPart") then
                    -- Prende o jogador 5 studs acima do monstro para não tomar dano
                    Root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    
                    -- Equipar a ferramenta (Espada/Estilo de luta) e Atacar
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

-- [[ PASSO 6: JUNTAR TUDO NO CICLO DO LOOP ]]
task.spawn(function()
    while true do
        task.wait(1)
        
        -- Só executa se o botão de farm do Zenith Hub estiver ligado
        if _G.FarmLevel or _G.AutoFarm then
            local dadosAtuais = ObterDadosDaMissao()
            
            if not _G.HasQuest() then
                _G.TakeQuest(dadosAtuais)
            else
                _G.FarmMobs(dadosAtuais)
            end
        end
    end
end)

-- Vincula as funções para o ZenithHub ler ao carregar o módulo
AutoQuest.HasQuest = _G.HasQuest
AutoQuest.TakeQuest = _G.TakeQuest
AutoQuest.FarmMobs = _G.FarmMobs

return AutoQuest
