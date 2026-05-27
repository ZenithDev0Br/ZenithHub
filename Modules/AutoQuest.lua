local AutoQuest = {}

-- [[ CONFIGURAÇÕES PRINCIPAIS ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vim = game:GetService("VirtualInputManager") -- Injetando o simulador de cliques do tutorial

-- [[ PASSO 2: BASE DE DADOS DE NÍVEIS ]]
-- O script agora busca dinamicamente o NPC e o Monstro pelo nome correto no mapa
_G.QuestConfig = {
    {
        MinLevel = 0,
        MaxLevel = 9,
        NPCName = "Bandit Quest Giver", -- Corrigido para o singular padrão
        QuestNameInGame = "Bandits",
        QuestNumber = 1,
        MobName = "Bandit"
    },
    {
        MinLevel = 10,
        MaxLevel = 14,
        NPCName = "Monkey Quest Giver",
        QuestNameInGame = "JungleQuest",
        QuestNumber = 1,
        MobName = "Monkey"
    }
    -- Você pode continuar adicionando as outras ilhas aqui embaixo seguindo o padrão!
}

-- [[ FUNÇÃO PARA PEGAR OS DADOS BASEADO NO SEU NÍVEL ]]
local function ObterDadosDaMissao()
    local level = LocalPlayer.Data.Level.Value
    for _, dados in pairs(_G.QuestConfig) do
        if level >= dados.MinLevel and level <= dados.MaxLevel then
            return dados
        end
    end
    return _G.QuestConfig[1] -- Padrão (Bandits) caso não ache o nível
end

-- [[ FUNÇÃO HASQUEST (SUA DESCOBERTA VIA DEX MANTIDA!) ]]
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

-- [[ PASSO 3: TELEPORTE SEGURO (TWEEN COM .p COMPATÍVEL) ]]
function _G.TweenTo(CFrameTarget)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local Distance = (Root.Position - CFrameTarget.p).Magnitude
    if Distance < 5 then 
        Root.CFrame = CFrameTarget 
        return 
    end

    local Speed = 300 -- Velocidade segura para evitar kick
    local Time = Distance / Speed

    local Tween = TweenService:Create(Root, TweenInfo.new(Time, Enum.EasingStyle.Linear), {CFrame = CFrameTarget})
    Tween:Play()
    Tween.Completed:Wait()
end

-- [[ PASSO 4: PEGAR MISSÃO VIA REMOTE ]]
function _G.TakeQuest(dados)
    local NPC = workspace:FindFirstChild(dados.NPCName, true) -- Busca inteligente em qualquer pasta
    
    if NPC and NPC:FindFirstChild("HumanoidRootPart") then
        print("[Zenith-AutoQuest] Indo até o NPC: " .. dados.NPCName)
        _G.TweenTo(NPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        task.wait(0.2)
        
        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if Remote then
            Remote:InvokeServer("StartQuest", dados.QuestNameInGame, dados.QuestNumber)
        end
    else
        print("[Zenith-AutoQuest] NPC não encontrado: " .. dados.NPCName)
    end
end

-- [[ PASSO 5: COMBATE E ATAQUE AUTOMÁTICO (VIM + TOOL) ]]
function _G.FarmMobs(dados)
    local enemyFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs") or workspace
    
    for _, mob in pairs(enemyFolder:GetChildren()) do
        if mob.Name == dados.MobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and _G.HasQuest() then
            
            -- Só ataca se o farm continuar ativo no menu
            while mob.Humanoid.Health > 0 and _G.HasQuest() and (_G.FarmLevel or _G.AutoFarm) do
                task.wait(0.1) -- Velocidade do clique igual ao tutorial
                
                local Character = LocalPlayer.Character
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                
                if Root and mobRoot then
                    -- Prende o seu boneco 5 studs acima do monstro para não tomar dano
                    Root.CFrame = mobRoot.CFrame * CFrame.new(0, 5, 0)
                    
                    -- Puxa a ferramenta da Backpack (Espada/Estilo de luta)
                    local Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool")
                    if Tool then
                        Character.Humanoid:EquipTool(Tool)
                        Tool:Activate()
                    end
                    
                    -- Simula o clique físico na tela via VirtualInputManager do tutorial
                    Vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    Vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end
end

-- [[ PASSO 1 & 6: LOOP PRINCIPAL PROTEGIDO COM PCALL ]]
function ExecutarCicloFarm()
    -- Ativa com qualquer uma das variáveis comuns de menu ativadas
    if _G.FarmLevel or _G.AutoFarm or _G.Farm then
        local dadosAtuais = ObterDadosDaMissao()
        
        if not _G.HasQuest() then
            _G.TakeQuest(dadosAtuais)
        else
            _G.FarmMobs(dadosAtuais)
        end
    end
end

-- Thread rodando em background em modo de segurança
task.spawn(function()
    while true do
        local sucesso, erro = pcall(ExecutarCicloFarm)
        if not sucesso then
            print("[Zenith-AutoQuest] Erro no ciclo de farm: ", erro)
        end
        task.wait(0.5) -- Intervalo de segurança para não lagar o Delta
    end
end)

-- Vincula as funções para o ZenithHub reconhecer o módulo com sucesso
AutoQuest.HasQuest = _G.HasQuest
AutoQuest.TakeQuest = _G.TakeQuest
AutoQuest.FarmMobs = _G.FarmMobs

return AutoQuest
