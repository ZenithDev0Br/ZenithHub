local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local noclipConnection = nil
local currentLoopID = 0 

local function setCharacterAnchor(hrp, state)
    if hrp and hrp:IsA("BasePart") then
        hrp.Anchored = state
    end
end

local function setNoClip(state)
    if state then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    if part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

function FarmLevel:Start()
    print("[ZenithDebug] Tentando iniciar FarmLevel:Start()...")
    
    local ZenithHub = getgenv().ZenithHub
    local Modules = ZenithHub and ZenithHub.Modules
    if not Modules then 
        warn("[ZenithDebug] ERRO CRÍTICO: ZenithHub.Modules não existe globalmente!")
        return 
    end

    local AutoQuest = Modules.AutoQuest
    local Tween     = Modules.Tween
    local Combat    = Modules.Combat
    local Weapon    = Modules.Weapon
    local BringMob  = Modules.BringMob
    local Settings  = Modules.FarmSettings

    -- Verificação de Módulos Essenciais
    if not AutoQuest then warn("[ZenithDebug] Módulo AutoQuest ausente!") end
    if not Tween then warn("[ZenithDebug] Módulo Tween ausente!") end

    if self.Enabled then 
        print("[ZenithDebug] FarmLevel já estava Enabled. Cancelando duplo clique.")
        return 
    end 
    
    self.Enabled = true
    currentLoopID = currentLoopID + 1 
    local myLoopID = currentLoopID

    print("[ZenithDebug] Loop Thread criada com Sucesso! ID:", myLoopID)

    task.spawn(function()
        while self.Enabled and currentLoopID == myLoopID do
            task.wait(0.05)
            
            if currentLoopID ~= myLoopID then break end

            -- ============================================================
            -- DETECTOR DE ESTADO DO TOGGLE (SE NÃO PASSAR DAQUI, O BOTÃO DA UI NÃO ATIVOU A CONFI)
            -- ============================================================
            -- Adaptado para aceitar tanto a tabela Settings quanto a global da Zyn Hub (_G.SaveData) se for o caso
            local isFarmActive = false
            if Settings and Settings.AutoFarmLevel then
                isFarmActive = true
            elseif _G.SaveData and _G.SaveData["AutoFarmLevel_Save"] then -- Fallback para salvar configs da Zyn Hub
                isFarmActive = true
            elseif _G.AutoFarmLevel then -- Fallback caso use variável global simples
                isFarmActive = true
            end

            if not isFarmActive then
                -- Se cair aqui, o loop está rodando em background mas esperando o sinal do botão
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                setCharacterAnchor(hrp, false)
                setNoClip(false)
                task.wait(0.5)
                continue
            end
            
            pcall(function()
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                
                if not character or not hrp or character.Humanoid.Health <= 0 then
                    setNoClip(false)
                    return
                end

                if currentLoopID == myLoopID then
                    setNoClip(true)
                end

                -- ============================================================
                -- ESCUDO ANTI-DIÁLOGO
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
                if not QuestData then 
                    -- Se o script printar isso, o seu módulo AutoQuest não está retornando os dados da Missão!
                    return 
                end

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
                -- LOGICA 1: PEGAR MISSÃO
                -- ============================================================
                if not AutoQuest:HasQuest() then
                    setCharacterAnchor(hrp, false) 
                    
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
                -- LOGICA 2: ATACAR MONSTROS
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

                    -- Pega os valores da UI ou define padrões seguros para não quebrar
                    local attackHeight = (Settings and Settings.AttackHeight) or (_G.SaveData and _G.SaveData["AttackHeight_Save"]) or 22
                    local attackDistance = (Settings and Settings.AttackDistance) or (_G.SaveData and _G.SaveData["AttackDistance_Save"]) or 0

                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        local targetCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        if (hrp.Position - targetCFrame.Position).Magnitude > 1 then
                            setCharacterAnchor(hrp, false) 
                            hrp.CFrame = targetCFrame
                            task.wait(0.01) 
                        end
                        
                        if currentLoopID == myLoopID then
                            setCharacterAnchor(hrp, true) 
                        end
                        
                        local bringMobsActive = (Settings and Settings.BringMobs) or (_G.SaveData and _G.SaveData["BringMobs_Save"])
                        if bringMobsActive and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        local fastAttackActive = (Settings and Settings.FastAttack) or (_G.SaveData and _G.SaveData["FastAttack_Save"])
                        if fastAttackActive and Combat and Combat.Attack then 
                            Combat:Attack() 
                        end
                    else
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
        
        if currentLoopID == myLoopID then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            setCharacterAnchor(hrp, false)
            setNoClip(false)
            print("[ZenithDebug] Loop finalizado de forma limpa.")
        end
    end)
end

function FarmLevel:Stop()
    print("[ZenithDebug] Executando FarmLevel:Stop()...")
    self.Enabled = false
    currentLoopID = currentLoopID + 1 
    
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    setCharacterAnchor(hrp, false)
    setNoClip(false)
end

return FarmLevel
