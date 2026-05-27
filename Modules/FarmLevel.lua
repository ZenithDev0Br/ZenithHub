local FarmLevel = {
    Enabled = false -- Ativado e desativado exclusivamente pelo seu BloxFruitsUI.lua
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function GetScript(path)
    local url = "https://raw.githubusercontent.com/ZenithDev0Br/ZenithHub/refs/heads/main/Modules/" .. path
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if success then return result else warn("[ZenithHub] Erro ao carregar módulo: " .. path) return nil end
end

local AutoQuest = GetScript("AutoQuest.lua")
local Tween     = GetScript("Tween.lua")
local Combat    = GetScript("Combat.lua")
local Weapon    = GetScript("Weapon.lua")
local BringMob  = GetScript("BringMob.lua")

local function FindEnemy(enemyName)
    local closestEnemy = nil
    local shortestDistance = math.huge
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

function FarmLevel:Start()
    task.spawn(function()
        while self.Enabled do
            task.wait(0.1) -- Ritmo otimizado para não travar
            
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.Humanoid.Health <= 0 then
                    return
                end

                -- Puxa as configurações em tempo real da sua UI
                local Modules = getgenv().ZenithHub and getgenv().ZenithHub.Modules
                local Settings = Modules and Modules.FarmSettings

                local QuestData = AutoQuest:GetQuestData()
                if not QuestData then return end

                -- PASSO 1: SE NÃO TIVER MISSÃO, VAI PEGAR (NPC)
                if not AutoQuest:HasQuest() then
                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(QuestData.QuestPosition)
                    else
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(QuestData.QuestPosition)
                    end
                    
                    local distanceToNPC = (LocalPlayer.Character.HumanoidRootPart.Position - QuestData.QuestPosition).Magnitude
                    if distanceToNPC < 20 then
                        AutoQuest:StartQuest()
                    end
                
                -- PASSO 2: SE JÁ TIVER MISSÃO, VAI EXECUTAR O FARM
                else
                    local Enemy = FindEnemy(QuestData.Enemy)

                    -- Pega a altura e distância configuradas nos Sliders da UI (ou usa padrões seguros)
                    local attackHeight = Settings and Settings.AttackHeight or 5
                    local attackDistance = Settings and Settings.AttackDistance or 0

                    if Enemy and Enemy:FindFirstChild("HumanoidRootPart") then
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        local distanceToEnemy = (LocalPlayer.Character.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Magnitude
                        
                        -- Se o monstro foi carregado mas está longe, vai voando (Tween) até ele
                        if distanceToEnemy > 150 then
                            if Tween and Tween.MoveTo then
                                Tween:MoveTo(Enemy.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance))
                            else
                                LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                            end
                        else
                            -- Se já estiver perto, se posiciona em cima dele para começar a bater
                            LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                            
                            -- Só junta os monstros se a Toggle "Bring Mobs" estiver ligada na UI
                            if Settings and Settings.BringMobs and BringMob and BringMob.Active then 
                                BringMob:Cluster(QuestData.Enemy) 
                            end

                            -- Só ataca se a Toggle "Fast Attack" estiver ligada na UI
                            if Settings and Settings.FastAttack and Combat and Combat.Attack then 
                                Combat:Attack() 
                            end
                        end
                    else
                        -- 🔥 [AQUI ESTAVA O BUG!] 🔥
                        -- Se não achou nenhum monstro perto (porque você acabou de pegar a quest e eles não carregaram),
                        -- o boneco voa até a área de spawn deles (EnemyPosition), forçando o jogo a carregar os monstros!
                        local EnemySpawn = QuestData.EnemyPosition or QuestData.MonsterPosition or QuestData.QuestPosition
                        if EnemySpawn then
                            if Tween and Tween.MoveTo then
                                Tween:MoveTo(EnemySpawn)
                            else
                                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(EnemySpawn)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

return FarmLevel
