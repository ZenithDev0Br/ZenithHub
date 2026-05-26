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
                end
            end)
        end
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    end
end

function FarmLevel:AutoFarm(enabled)
    _G.AutoFarmLevel = enabled
    self:ToggleNoClip(enabled)

    task.spawn(function()
        while _G.AutoFarmLevel and task.wait(0.5) do
            local QuestModule = getgenv().ZenithHub.Modules.Quest
            if not QuestModule then continue end
            
            local myLevel = LP.Data.Level.Value
            local qData = QuestModule:GetCurrentQuest(myLevel)
            _G.CurrentMobName = qData.Mob 
            
            -- FORÇA: Se a UI da quest sumir, ele tenta pegar novamente
            if not QuestModule:HasActiveQuest(LP) then
                QuestModule:TakeQuest(qData)
                task.wait(1)
            end
            
            -- LÓGICA DE MOVIMENTO E ATAQUE
            local targetMob = nil
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                -- Verifica se o bicho é da missão e se está vivo
                if v.Name == qData.Mob and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    targetMob = v
                    break
                end
            end
            
            if targetMob then
                local targetPos = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0) -- Fica 15 studs acima
                
                -- Se estiver longe, usa o Tween
                if (LP.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude > 10 then
                    local info = TweenInfo.new(0.5, Enum.EasingStyle.Linear) -- Tween mais rápido
                    if activeTween then activeTween:Cancel() end
                    activeTween = TS:Create(LP.Character.HumanoidRootPart, info, {CFrame = targetPos})
                    activeTween:Play()
                else
                    -- Já perto: para o tween e teletransporta para garantir
                    if activeTween then activeTween:Cancel() end
                    LP.Character.HumanoidRootPart.CFrame = targetPos
                end
            end
        end
    end)
end

getgenv().ZenithHub.Modules.FarmLevel = FarmLevel
return FarmLevel
