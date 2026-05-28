local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local loopRunning = false -- Evita duplicação de threads em background

-- Gerenciador de física para estabilizar o boneco no ar sem bugar o Tween
local function setCharacterAnchor(hrp, state)
    if hrp and hrp:IsA("BasePart") then
        hrp.Anchored = state
    end
end

function FarmLevel:Start()
    -- Carrega os módulos injetados na tabela central da ZenithHub
    local ZenithHub = getgenv().ZenithHub
    local Modules = ZenithHub and ZenithHub.Modules
    if not Modules then return warn("❌ ZenithHub Modules não encontrados!") end

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
            
            -- Se desligar o Farm na Interface, limpa o boneco e pausa o loop
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
                
                -- Se o jogador morrer, aguarda o respawn e solta a física
                if not character or not hrp or character.Humanoid.Health <= 0 then
                    return
                end

                -- ============================================================
                -- ESCUDO ANTI-DIÁLOGO (BYPASS DA UI DA ZYN HUB)
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
                -- SISTEMA ANTI-BOSS (ABANDONA MISSÕES IMPOSSÍVEIS PRO UP)
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
                -- LOGICA 1: NÃO TEM MISSÃO -> ANDAR ATÉ O NPC E PEGAR
                -- ============================================================
                if not AutoQuest:HasQuest() then
                    setCharacterAnchor(hrp, false) -- Desancora pro Tween fluir suave
                    
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
                -- LOGICA 2: TEM MISSÃO ATIVA -> ATACAR MONSTROS
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
                        -- Força o equip da arma selecionada na UI (Melee / Sword / Fruit)
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        -- Calcula o ponto de ataque seguro baseado nos sliders da UI
                        local targetCFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        -- Só altera a posição se o monstro se deslocar (Evita o jitter visual do boneco)
                        if (hrp.Position - targetCFrame.Position).Magnitude > 1 then
                            setCharacterAnchor(hrp, false) -- Libera a física para ajustar a posição
                            hrp.CFrame = targetCFrame
                            task.wait(0.01) -- Micro-espera necessária para a engine processar
                        end
                        
                        setCharacterAnchor(hrp, true) -- Trava o boneco rigidamente no ar
                        
                        -- Roda os scripts de agrupar inimigos e bater
                        if Settings.BringMobs and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        if Settings.FastAttack and Combat and Combat.Attack then 
                            Combat:Attack() 
                        end
                    else
                        -- Se os monstros morrerem, desancora e voa de volta para o ponto de spawn deles
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
        -- Garante que ao encerrar o script por completo, o boneco caia no chão e não fique preso voando
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
