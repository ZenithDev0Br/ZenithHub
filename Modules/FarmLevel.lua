if not getgenv().ZenithHub then getgenv().ZenithHub = { Modules = {} } end
local FarmLevel = {}
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LP = game:GetService("Players").LocalPlayer

local noclipConnection = nil
local activeTween = nil
_G.CurrentMobName = ""

function FarmLevel:ToggleNoClip(enabled)
    if enabled then
        if not noclipConnection then
            noclipConnection = RS.Stepped:Connect(function()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    for _, v in pairs(LP.Character:GetChildren()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                    -- Anti-Queda
                    if not LP.Character.HumanoidRootPart:FindFirstChild("AntiFall") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "AntiFall"
                        bv.MaxForce = Vector3.new(0, 99999, 0)
                        bv.Velocity = Vector3.zero
                        bv.Parent = LP.Character.HumanoidRootPart
                    end
                end
            end)
        end
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local bv = LP.Character.HumanoidRootPart:FindFirstChild("AntiFall")
            if bv then bv:Destroy() end
        end
    end
end

function FarmLevel:AutoFarm(enabled)
    _G.AutoFarmLevel = enabled
    self:ToggleNoClip(enabled)

    task.spawn(function()
        while _G.AutoFarmLevel and task.wait() do
            -- Chama o novo MÓDULO DE QUEST
            local QuestModule = getgenv().ZenithHub.Modules.Quest
            if not QuestModule then task.wait(1); continue end
            
            local myLevel = LP.leaderstats.Level.Value
            local qData = QuestModule:GetCurrentQuest(myLevel)
            _G.CurrentMobName = qData.Mob 
            
            -- Se JÁ TEM a quest, vai caçar os monstros
            if QuestModule:HasActiveQuest(LP) then
                local targetMob = nil
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == qData.Mob and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        targetMob = v
                        break
                    end
                end
                
                if targetMob then
                    local targetPos = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, _G.AttackHeight, _G.AttackDistance)
                    local dist = (LP.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude
                    
                    if dist > 5 then
                        local info = TweenInfo.new(dist / _G.TweenSpeed, Enum.EasingStyle.Linear)
                        activeTween = TS:Create(LP.Character.HumanoidRootPart, info, {CFrame = targetPos})
                        activeTween:Play()
                    else
                        if activeTween then activeTween:Cancel() end
                        LP.Character.HumanoidRootPart.CFrame = targetPos
                    end
                else
                    -- Bicho não spawnou, espera um pouco
                    task.wait(0.5)
                end
            else
                -- SE NÃO TEM A QUEST, MANDA PEGAR!
                QuestModule:TakeQuest(qData)
                task.wait(0.5) -- Pausa rápida para o servidor processar a quest
            end
        end
    end)
end

getgenv().ZenithHub.Modules.FarmLevel = FarmLevel
return FarmLevel
