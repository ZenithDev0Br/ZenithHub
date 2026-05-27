local FarmLevel = {
    Enabled = false 
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Função de carregamento via GitHub mantida
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
    -- Correção de otimização: Busca na pasta Enemies se ela existir, senão no Workspace
    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    
    for _, v in pairs(folder:GetChildren()) do
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
            task.wait(0.1)
            
            pcall(function()
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.Humanoid.Health <= 0 then
                    return
                end

                local Modules = getgenv().ZenithHub and getgenv().ZenithHub.Modules
                local Settings = Modules and Modules.FarmSettings

                -- Agora chama a função corrigida do AutoQuest
                local QuestData = AutoQuest:GetQuestData()
                if not QuestData then return end

                -- PASSO 1: SE NÃO TIVER MISSÃO, VAI PEGAR (NPC)
                if not AutoQuest:HasQuest() then
                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(CFrame.new(QuestData.QuestPosition))
                    else
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(QuestData.QuestPosition)
                    end
                    
                    local distanceToNPC = (LocalPlayer.Character.HumanoidRootPart.Position - QuestData.QuestPosition).Magnitude
                    if distanceToNPC < 20 then
                        AutoQuest:StartQuest() -- Nome corrigido aqui
                    end
                
                -- PASSO 2: SE JÁ TIVER MISSÃO, VAI EXECUTAR O FARM
                else
                    local Enemy = FindEnemy(QuestData.Enemy)

                    local attackHeight = Settings and Settings.AttackHeight or 5
                    local attackDistance = Settings and Settings.AttackDistance or 0

                    if Enemy and Enemy:FindFirstChild("HumanoidRootPart") then
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        local distanceToEnemy = (LocalPlayer.Character.HumanoidRootPart.Position - Enemy.HumanoidRootPart.Position).Magnitude
                        
                        if distanceToEnemy > 150 then
                            if Tween and Tween.MoveTo then
                                Tween:MoveTo(Enemy.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance))
                            else
                                LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                            end
                        else
                            LocalPlayer.Character.HumanoidRootPart.CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                            
                            if Settings and Settings.BringMobs and BringMob and BringMob.Active then 
                                BringMob:Cluster(QuestData.Enemy) 
                            end

                            if Settings and Settings.FastAttack and Combat and Combat.Attack then 
                                Combat:Attack() 
                            end
                        end
                    else
                        -- Se os monstros não spawnaram ainda, vai até a área deles
                        local EnemySpawn = QuestData.EnemyPosition or QuestData.QuestPosition
                        if EnemySpawn then
                            if Tween and Tween.MoveTo then
                                Tween:MoveTo(CFrame.new(EnemySpawn))
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
