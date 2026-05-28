local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local loopRunning = false -- TRAVA DE SEGURANÇA PARA EVITAR LAG

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

    -- Impede a criação de múltiplos loops se o cara clicar várias vezes no botão
    if loopRunning then return end 
    loopRunning = true
    self.Enabled = true

    task.spawn(function()
        while loopRunning and self.Enabled do
            task.wait(0.05)
            
            -- Se a tabela de configurações sumir ou o toggle for desativado, o loop pausa sem crashar
            if not Settings or not Settings.AutoFarmLevel then
                task.wait(0.5)
                continue
            end
            
            pcall(function()
                -- Verifica se o personagem está vivo e pronto para o farm
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.Humanoid.Health <= 0 then
                    return
                end

                -- ============================================================
                -- ESCUDO ANTI-DIÁLOGO: DESTRÓI QUALQUER JANELA PRESA NA TELA
                -- ============================================================
                local MainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Main")
                if MainGui then
                    if MainGui:FindFirstChild("Dialogue") and MainGui.Dialogue.Visible then
                        MainGui.Dialogue.Visible = false
                    end
                    if MainGui:FindFirstChild("Quest") and MainGui.Quest.Visible and not AutoQuest:HasQuest() then
                        MainGui.Quest.Visible = false
                    end
                end

                local QuestData = AutoQuest:GetQuestData()
                if not QuestData then return end

                -- ============================================================
                -- PROTEÇÃO CONTRA BOSS
                -- ============================================================
                if AutoQuest:HasQuest() then
                    local nomeInimigo = QuestData.Enemy:lower()
                    if nomeInimigo:match("king") or nomeInimigo:match("admiral") or nomeInimigo:match("warden") or nomeInimigo:match("cyborg") or nomeInimigo:match("bobby") or nomeInimigo:match("yeti") or nomeInimigo:match("jeremy") or nomeInimigo:match("fajita") or nomeInimigo:match("tide") then
                        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if Remote then
                            Remote:InvokeServer("AbandonQuest")
                            task.wait(0.2)
                            return
                        end
                    end
                end

                -- ============================================================
                -- SISTEMA DE MOVIMENTAÇÃO E PEGAR MISSÃO (BYPASS TOTAL)
                -- ============================================================
                if not AutoQuest:HasQuest() then
                    local npcTargetCFrame = CFrame.new(QuestData.QuestPosition) * CFrame.new(0, 12, 0)

                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(npcTargetCFrame)
                    else
                        LocalPlayer.Character.HumanoidRootPart.CFrame = npcTargetCFrame
                    end
                    
                    local distanceToNPC = (LocalPlayer.Character.HumanoidRootPart.Position - QuestData.QuestPosition).Magnitude
                    
                    if distanceToNPC < 25 then
                        task.wait(0.05) 
                        local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                        if Remote then
                            Remote:InvokeServer("StartQuest", QuestData.QuestName, QuestData.QuestID)
                        end
                        task.wait(0.2)
                    end
                
                -- ============================================================
                -- ROTINA DE COMBATE (FARM ATIVO DE MONSTROS COMUNS)
                -- ============================================================
                else
                    local targetMob = nil
                    local folder = Workspace:FindFirstChild("Enemies") or Workspace
                    for _, v in pairs(folder:GetChildren()) do
                        if v.Name == QuestData.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMob = v
                            break
                        end
                    end

                    local attackHeight = Settings and Settings.AttackHeight or 22 
                    local attackDistance = Settings and Settings.AttackDistance or 0

                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        -- Fica "colado" no mob atual
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        if Settings.BringMobs and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        if Settings.FastAttack and Combat and Combat.Attack then 
                            Combat:Attack() 
                        end
                    else
                        -- Corre atrás dos spawns vazios
                        if QuestData.EnemyPosition then
                            -- Usa verificação de typeof para evitar erro caso EnemyPosition não seja Vector3
                            local targetPos = typeof(QuestData.EnemyPosition) == "Vector3" and CFrame.new(QuestData.EnemyPosition) or QuestData.EnemyPosition
                            
                            if Tween and Tween.MoveTo then
                                Tween:MoveTo(targetPos)
                            else
                                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPos
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- Função vital para sua UI conseguir desligar o Farm completamente
function FarmLevel:Stop()
    self.Enabled = false
    loopRunning = false
end

return FarmLevel
