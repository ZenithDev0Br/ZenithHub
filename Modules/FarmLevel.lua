local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")

-- Função otimizada para checar a missão direto na interface do jogo
local function HasQuest()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local MainGui = PlayerGui and PlayerGui:FindFirstChild("Main")
    local QuestUI = MainGui and MainGui:FindFirstChild("Quest")
    
    -- Se a janelinha de missão estiver visível, significa que já temos uma missão ativa
    if QuestUI and QuestUI.Visible then
        return true
    end
    return false
end

-- ================================================
-- LOOP PRINCIPAL DE FARM (RODANDO NA VELOCIDADE MÁXIMA)
-- ================================================
task.spawn(function()
    while task.wait() do -- <-- task.wait() VAZIO roda na velocidade máxima dos frames do jogo (sem lagar)
        if _G.StartFarm then
            pcall(function()
                
                if not HasQuest() then
                    -- 🔴 ETAPA 1: NÃO TEM MISSÃO -> PEGAR INSTANTANEAMENTE
                    -- Pega os dados da missão atual com base no seu nível (substitua pela sua tabela/lógica)
                    local dados = ObterDadosDaMissaoPorNivel() 
                    
                    if dados then
                        -- Teleporta para o NPC da Missão
                        _tp(dados.NpcCFrame)
                        
                        -- Verifica se já chegou perto o suficiente do NPC para o jogo aceitar o remote
                        if (LocalPlayer.Character.HumanoidRootPart.Position - dados.NpcCFrame.Position).Magnitude <= 15 then
                            -- Dispara o Remote diretamente! Sem passar por diálogo lento de NPC
                            CommF:InvokeServer("StartQuest", dados.QuestName, dados.QuestID)
                            
                            -- ESPERA MÍNIMA: Apenas 0.1 segundos pro servidor registrar, nada de wait(1) ou wait(2)!
                            task.wait(0.1) 
                        end
                    end
                    
                else
                    -- 🟢 ETAPA 2: JÁ TEM MISSÃO -> VAI PRO MOB NO PRÓXIMO FRAME!
                    -- Procura o mob da sua missão que esteja vivo no workspace
                    local Mob = ProcurarInimigoVivo(dados.MobName)
                    
                    if Mob and Mob:FindFirstChild("HumanoidRootPart") then
                        -- Teleporta direto para cima do Mob e ativa o combate
                        _tp(Mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                        
                        -- Seu módulo de combate ataca aqui
                        if Combat and Combat.Attack then
                            Combat:Attack()
                        end
                    else
                        -- SALVAGUARDA: Se os mobs ainda não spawnaram, NÃO fique parado no NPC!
                        -- Vá para o ponto de Spawn dos mobs e espere eles nascerem lá!
                        _tp(dados.MobSpawnCFrame)
                    end
                end
                
            end)
        else
            -- Se o farm for desligado, dá uma folga pro script não floodar a CPU
            task.wait(0.5)
        end
    end
end)
