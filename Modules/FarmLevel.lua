local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local loopRunning = false -- TRAVA DE SEGURANÇA PARA EVITAR LAG

-- Função para travar o boneco no ar sem usar forças físicas bugadas
local function setCharacterAnchor(hrp, state)
    if hrp and hrp:IsA("BasePart") then
        hrp.Anchored = state
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
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                setCharacterAnchor(hrp, false)
                task.wait(0.5)
                continue
            end
            
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                -- Verifica se o personagem está vivo e pronto para o farm
                if not character or not hrp or character.Humanoid.Health <= 0 then
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
                        setCharacterAnchor(hrp, false)
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
                    setCharacterAnchor(hrp, false) -- Desanconra TOTAL para o Tween funcionar livremente
                    
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
                        
                        -- Posição calculada em relação ao mob
                        local targetCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        -- Só atualiza a posição se o mob se mover de verdade (evita tremedeira visual)
                        if (hrp.Position - targetCFrame.Position).Magnitude > 1 then
                            setCharacterAnchor(hrp, false) -- Solta só para teleportar
                            hrp.CFrame = targetCFrame
                            task.wait(0.01) -- Micro-espera para o motor aceitar a física
                        end
                        
                        setCharacterAnchor(hrp, true) -- Trava o boneco no ar enquanto bate
                        
                        if Settings.BringMobs and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        if Settings.FastAttack and Combat and Combat.Attack then 
                            Combat:Attack() 
                        end
                    else
                        -- Se não achou o mob, desancora para voar até o spawn deles
                        setCharacterAnchor(hrp, false)
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
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        setCharacterAnchor(hrp, false)
    end)
end

function FarmLevel:Stop()
    self.Enabled = false
    loopRunning = false
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    setCharacterAnchor(hrp, false)
end

return FarmLevel
