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
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.Humanoid.Health <= 0 then
                    return
                end

                local QuestData = AutoQuest:GetQuestData()
                if not QuestData then return end

                -- SE NÃO TIVER MISSÃO, VAI ATÉ O NPC PEGAR
                if not AutoQuest:HasQuest() then
                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(CFrame.new(QuestData.QuestPosition))
                    else
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(QuestData.QuestPosition)
                    end
                    
                    local distanceToNPC = (LocalPlayer.Character.HumanoidRootPart.Position - QuestData.QuestPosition).Magnitude
                    if distanceToNPC < 20 then
                        AutoQuest:StartQuest()
                    end
                
                -- SE JÁ TIVER MISSÃO, VAI PRO COMBATE
                else
                    -- Procura o mob pelo nome retornado pelo AutoQuest
                    local targetMob = nil
                    local folder = Workspace:FindFirstChild("Enemies") or Workspace
                    for _, v in pairs(folder:GetChildren()) do
                        if v.Name == QuestData.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMob = v
                            break
                        end
                    end

                    local attackHeight = Settings and Settings.AttackHeight or 5
                    local attackDistance = Settings and Settings.AttackDistance or 0

                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        if Weapon and Weapon.Equip then Weapon:Equip() end 
                        
                        -- Posiciona em cima do monstro
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, attackHeight, attackDistance)
                        
                        if Settings.BringMobs and BringMob and BringMob.Cluster then 
                            BringMob:Cluster(QuestData.Enemy) 
                        end

                        if Settings.FastAttack and Combat and Combat.Attack then 
                            Combat:Attack() 
                        end
                    else
                        -- Se os monstros não carregaram na tela, vai até o Spawn deles forçar o carregamento
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
