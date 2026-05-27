local FarmLevel = {}
local TS = game:GetService("TweenService")
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")

function FarmLevel:AutoFarm(enabled)
    _G.AutoFarmLevel = enabled
    
    task.spawn(function()
        while _G.AutoFarmLevel and task.wait() do
            local Modules = getgenv().ZenithHub.Modules
            local QuestMod = Modules.Quest
            local Remote = Modules.RemoteHandler
            
            -- 1. Verifica Level e Quest
            local myLevel = LP.Data.Level.Value
            local qData = QuestMod:GetCurrentQuest(myLevel)
            
            -- 2. Se não tem quest, pega
            if not QuestMod:HasActiveQuest(LP) then
                QuestMod:TakeQuest(qData)
                task.wait(1)
            end
            
            -- 3. Procura o mob
            local targetMob = nil
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == qData.Mob and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    targetMob = v
                    break
                end
            end
            
            -- 4. Lógica de Aproximação e Ataque
            if targetMob then
                local targetPos = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
                
                -- Teleporte/Tween para o mob
                if (LP.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude > 5 then
                    local dist = (LP.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude
                    local tween = TS:Create(LP.Character.HumanoidRootPart, TweenInfo.new(dist / 300, Enum.EasingStyle.Linear), {CFrame = targetPos})
                    tween:Play()
                else
                    -- Já colado no mob, força a posição
                    LP.Character.HumanoidRootPart.CFrame = targetPos
                    
                    -- Chama o ataque automático
                    local tool = LP.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("RemoteFunction") then
                        Remote:Invoke(tool.RemoteFunction.Name, "Attack")
                    end
                end
            end
        end
    end)
end

getgenv().ZenithHub.Modules.FarmLevel = FarmLevel
return FarmLevel
