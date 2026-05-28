local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local noclipConnection = nil
local currentLoopID = 0 -- Identificador único para cada execução do loop

-- Gerenciador de física para travar o boneco no ar de forma limpa
local function setCharacterAnchor(hrp, state)
    if hrp and hrp:IsA("BasePart") then
        hrp.Anchored = state
    end
end

-- Gerenciador estrito de NoClip via RunService
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
        -- Devolve a colisão normal para as partes do corpo
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
    local ZenithHub = getgenv().ZenithHub
    local Modules = ZenithHub and ZenithHub.Modules
    if not Modules then return end

    local AutoQuest = Modules.AutoQuest
    local Tween     = Modules.Tween
    local Combat    = Modules.Combat
    local Weapon    = Modules.Weapon
    local BringMob  = Modules.BringMob
    local Settings  = Modules.FarmSettings

    -- Se já estiver ativado, não faz nada
    if self.Enabled then return end 
    
    self.Enabled = true
    currentLoopID = currentLoopID + 1 -- Gera um novo ID único para esta thread
    local myLoopID = currentLoopID

    task.spawn(function()
        -- O loop só roda se o ID dele ainda for o ID atual do script
        while self.Enabled and currentLoopID == myLoopID do
            task.wait(0.05)
            
            -- Se a ID mudou no meio do caminho, corta a execução na hora (Anti-Ghosting)
            if currentLoopID ~= myLoopID then break end

            if not Settings or not Settings.AutoFarmLevel then
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

                -- Garante NoClip ativo apenas se esta thread ainda for a dona do script
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

                    local attackHeight = Settings and Settings.AttackHeight or 22 
                    local attackDistance = Settings and Settings.AttackDistance or 0

                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        local targetCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        if (hrp.Position - targetCFrame.Position).Magnitude > 1 then
                            setCharacterAnchor(hrp, false) 
                            hrp.CFrame = targetCFrame
                            task.wait(0.01) 
                        end
                        
                        -- Só ancora o boneco se a thread ainda for a ativa
                        if currentLoopID == myLoopID then
                            setCharacterAnchor(hrp, true) 
                        end
                        
                        if Settings.BringMobs and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        if Settings.FastAttack and Combat and Combat.Attack then 
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
        
        -- Segurança extra: se o loop terminar naturalmente e for o último loop válido, limpa tudo
        if currentLoopID == myLoopID then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            setCharacterAnchor(hrp, false)
            setNoClip(false)
        end
    end)
end

function FarmLevel:Stop()
    self.Enabled = false
    currentLoopID = currentLoopID + 1 -- Força a invalidação instantânea de qualquer loop que esteja rodando em background
    
    -- Força o reset imediato e absoluto de colisão e âncora
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    setCharacterAnchor(hrp, false)
    setNoClip(false)
end

return FarmLevel
