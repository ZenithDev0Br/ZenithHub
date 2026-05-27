local FarmLevel = {
    Enabled = false -- Controlado pela sua interface (BloxFruitsUI.lua)
}

-- Serviços essenciais
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- CARREGANDO OS SEUS MÓDULOS DIRETO DO GITHUB ORIGINAL
-- ========================================================
local function GetScript(path)
    local url = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/refs/heads/main/Modules/" .. path
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    
    if success then 
        return result 
    else 
        warn("[ZenithHub] Erro ao carregar módulo: " .. path .. " | Erro: " .. tostring(result)) 
        return nil 
    end
end

-- Puxando os módulos com os nomes exatos do seu repositório
local AutoQuest = GetScript("AutoQuest.lua")
local Tween     = GetScript("Tween.lua")
local Combat    = GetScript("Combat.lua")
local Weapon    = GetScript("Weapon.lua")
local BringMob  = GetScript("BringMob.lua")

-- ========================================================
-- FUNÇÃO PARA ENCONTRAR OS MONSTROS DA QUEST
-- ========================================================
local function FindEnemy(enemyName)
    local closestEnemy = nil
    local shortestDistance = math.huge

    -- Procura no Workspace por inimigos vivos com o nome da Quest
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == enemyName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if v:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    closestEnemy = v
                    shortestDistance = distance
                end
            end
        end
    end
    return closestEnemy
end

-- ========================================================
-- LOOP PRINCIPAL DO AUTO FARM LEVEL
-- ========================================================
function FarmLevel:Start()
    task.spawn(function()
        while self.Enabled do
            task.wait() -- Impede o Roblox de travar
            
            pcall(function()
                -- Verifica se o player está vivo e carregado
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.Humanoid.Health <= 0 then
                    return
                end

                -- Pega qual quest o jogador deve fazer pelo level
                local QuestData = AutoQuest:GetQuestData()
                if not QuestData then 
                    return 
                end

                -- FASE 1: PEGAR A QUEST (Se não tiver uma ativa)
                if not AutoQuest:HasQuest() then
                    -- Voa/Teleporta até o NPC da Quest
                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(QuestData.QuestPosition)
                    else
                        -- Caso seu Tween use outra função, ele teleporta direto:
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(QuestData.QuestPosition)
                    end
                    
                    -- Se estiver perto do NPC, aceita a quest
                    local distanceToNPC = (LocalPlayer.Character.HumanoidRootPart.Position - QuestData.QuestPosition).Magnitude
                    if distanceToNPC < 15 then
                        AutoQuest:StartQuest()
                        task.wait(0.5)
                    end
                
                -- FASE 2: MATAR OS MONSTROS (Se já tiver com a quest na tela)
                else
                    local Enemy = FindEnemy(QuestData.Enemy)

                    if Enemy and Enemy:FindFirstChild("HumanoidRootPart") then
                        -- Equipa o estilo de luta/espada/fruta (via Weapon.lua)
                        if Weapon and Weapon.Equip then
                            Weapon:Equip()
                        end 

                        -- Junta os monstros perto de você (via BringMob.lua)
                        if BringMob and BringMob.Active then
                            BringMob:Cluster(QuestData.Enemy)
                        end

                        -- Posiciona você em cima do monstro com segurança para não tomar hit
                        LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)

                        -- Desce o soco/usa skills (via Combat.lua)
                        if Combat and Combat.Attack then
                            Combat:Attack()
                        end
                    else
                        -- Se os monstros não spawnaram, fica esperando no local deles
                        if Tween and Tween.MoveTo then
                            Tween:MoveTo(QuestData.QuestPosition)
                        else
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(QuestData.QuestPosition)
                        end
                    end
                end
            end)
        end
    end)
end

return FarmLevel
