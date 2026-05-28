local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

function FarmLevel:Start()
    local ZenithHub = getgenv().ZenithHub
    local Modules = ZenithHub and ZenithHub.Modules
    if not Modules then return end

    local AutoQuest = Modules.AutoQuest
    local Tween     = Modules.Tween
    local Combat    = Modules.Combat
    local Weapon    = Modules.Weapon
    local BringMob  = Modules.BringMob
    local Settings  = Modules.FarmSettings

    task.spawn(function()
        while self.Enabled and Settings.AutoFarmLevel do
            task.wait(0.1)
            
            pcall(function()
                -- Verifica se o personagem está vivo e pronto para o farm
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.Humanoid.Health <= 0 then
                    return
                end

                local QuestData = AutoQuest:GetQuestData()
                if not QuestData then return end

                -- ============================================================
                -- PROTEÇÃO SEGUNDA: SE O SEU BONECO ESTIVER COM QUEST DE BOSS, ABANDONA
                -- ============================================================
                if AutoQuest:HasQuest() then
                    -- Lista de verificação para garantir que o script não foque em alvos demorados
                    local nomeInimigo = QuestData.Enemy:lower()
                    if nomeInimigo:match("king") or nomeInimigo:match("admiral") or nomeInimigo:match("warden") or nomeInimigo:match("cyborg") or nomeInimigo:match("bobby") or nomeInimigo:match("yeti") or nomeInimigo:match("jeremy") or nomeInimigo:match("fajita") or nomeInimigo:match("tide") then
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if Remote then
                            Remote:InvokeServer("AbandonQuest") -- Cancela a quest do boss imediatamente
                            task.wait(0.5)
                            return
                        end
                    end
                end

                -- ============================================================
                -- SISTEMA DE MOVIMENTAÇÃO E DIÁLOGO COM O QUEST GIVER
                -- ============================================================
                if not AutoQuest:HasQuest() then
                    -- 1. Voa/Teleporta até o NPC da Quest atual do seu nível
                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(CFrame.new(QuestData.QuestPosition))
                    else
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(QuestData.QuestPosition)
                    end
                    
                    -- 2. Calcula a distância matemática real até o NPC
                    local distanceToNPC = (LocalPlayer.Character.HumanoidRootPart.Position - QuestData.QuestPosition).Magnitude
                    
                    -- Se estiver perto o suficiente do Quest Giver
                    if distanceToNPC < 25 then
                        -- Pausa curta para estabilizar a física do jogo e evitar bloqueio de anti-cheat
                        task.wait(0.3) 
                        
                        -- Dispara o Remote para pegar a missão
                        AutoQuest:StartQuest()
                        
                        -- Aguarda o servidor registrar a Quest na tela antes do próximo ciclo do loop
                        task.wait(0.5)
                    end
                
                -- ============================================================
                -- ROTINA DE COMBATE (FARM ATIVO DE MONSTROS COMUNS)
                -- ============================================================
                else
                    -- Procura o mob comum correto na Workspace do servidor
                    local targetMob = nil
                    local folder = Workspace:FindFirstChild("Enemies") or Workspace
                    for _, v in pairs(folder:GetChildren()) do
                        if v.Name == QuestData.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMob = v
                            break
                        end
                    end

                    -- Configurações de posicionamento da sua UI (Configurações do Farm)
                    local attackHeight = Settings and Settings.AttackHeight or 5
                    local attackDistance = Settings and Settings.AttackDistance or 0

                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        -- Equipar ferramenta de ataque (Sword, Melee, Fruit, etc.)
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        -- Posiciona o personagem de forma segura em cima/atrás do hitbox do mob comum
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        -- Puxa todos os mobs iguais próximos para o mesmo ponto (Bring Mobs)
                        if Settings.BringMobs and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        -- Executa os cliques de ataque ultra-rápidos (Fast Attack)
                        if Settings.FastAttack and Combat and Combat.Attack then 
                            Combat:Attack() 
                        end
                    else
                        -- Se os monstros comuns limparam do mapa, vai até a área de spawn deles para forçar a renderização
                        if QuestData.EnemyPosition then
                            if Tween and Tween.MoveTo then
                                Tween:MoveTo(CFrame.new(QuestData.EnemyPosition))
                            else
                                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(QuestData.EnemyPosition)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

return FarmLevel
