local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local loopRunning = false -- TRAVA DE SEGURANÇA PARA EVITAR LAG
local bv = nil -- Guardar a força que impede o boneco de cair

-- Função interna para congelar o boneco no ar e tirar o lag da gravidade
local function updateAnchor(character, hrp)
    if not character or not hrp then return end
    if not bv or bv.Parent ~= hrp then
        if hrp:FindFirstChild("ZenithAnchor") then
            bv = hrp.ZenithAnchor
        else
            bv = Instance.new("BodyVelocity")
            bv.Name = "ZenithAnchor"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
        end
    end
end

local function removeAnchor()
    if bv then bv:Destroy() bv = nil end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local oldBv = hrp:FindFirstChild("ZenithAnchor")
        if oldBv then oldBv:Destroy() end
    end
end

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

    if loopRunning then return end 
    loopRunning = true
    self.Enabled = true

    task.spawn(function()
        while loopRunning and self.Enabled do
            task.wait(0.05)
            
            if not Settings or not Settings.AutoFarmLevel then
                removeAnchor()
                task.wait(0.5)
                continue
            end
            
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                -- Verifica se o personagem está vivo e pronto para o farm
                if not character or not hrp or character.Humanoid.Health <= 0 then
                    removeAnchor()
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
                        removeAnchor()
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
                    removeAnchor() -- Desliga a âncora para poder andar/teleportar até o NPC livremente
                    local npcTargetCFrame = CFrame.new(QuestData.QuestPosition) * CFrame.new(0, 12, 0)

                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(npcTargetCFrame)
                    else
                        hrp.CFrame = npcTargetCFrame
                    end
                    
                    local distanceToNPC = (hrp.Position - QuestData.QuestPosition).Magnitude
                    
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
                        
                        -- Ativa o estabilizador de física para parar de tremer
                        updateAnchor(character, hrp)
                        
                        -- Define a posição exata acima do mob
                        local targetCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        -- Só atualiza o CFrame se houver uma distância relevante (evita micro-tremores)
                        if (hrp.Position - targetCFrame.Position).Magnitude > 1 then
                            hrp.CFrame = targetCFrame
                        end
                        
                        if Settings.BringMobs and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        if Settings.FastAttack and Combat and Combat.Attack then 
                            Combat:Attack() 
                        end
                    else
                        -- Se não achou o mob, remove a âncora para se movimentar até o spawn deles
                        removeAnchor()
                        if QuestData.EnemyPosition then
                            local targetPos = typeof(QuestData.EnemyPosition) == "Vector3" and CFrame.new(QuestData.EnemyPosition) or QuestData.EnemyPosition
                            
                            if Tween and Tween.MoveTo then
                                Tween:MoveTo(targetPos)
                            else
                                hrp.CFrame = targetPos
                            end
                        end
                    end
                end
            end)
        end
        removeAnchor()
    end)
end

function FarmLevel:Stop()
    self.Enabled = false
    loopRunning = false
    removeAnchor()
end

return FarmLevel
