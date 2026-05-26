local FarmLevel = {}
local TS = game:GetService("TweenService")
local LP = game:GetService("Players").LocalPlayer

function FarmLevel:AutoFarm(enabled)
    _G.AutoFarmLevel = enabled
    task.spawn(function()
        while _G.AutoFarmLevel and task.wait() do
            local Target = self:GetClosestEnemy()
            if Target and Target:FindFirstChild("HumanoidRootPart") then
                local targetPos = Target.HumanoidRootPart.CFrame * CFrame.new(0, _G.AttackHeight, 0)
                
                -- Cálculo de tempo baseado na velocidade (_G.TweenSpeed)
                local distance = (LP.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude
                local info = TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear)
                
                local tween = TS:Create(LP.Character.HumanoidRootPart, info, {CFrame = targetPos})
                tween:Play()
                tween.Completed:Wait()
            end
        end
    end)
end

function FarmLevel:GetClosestEnemy()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local d = (v.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then closest = v; dist = d end
        end
    end
    return closest
end

getgenv().ZenithHub.Modules.FarmLevel = FarmLevel
return FarmLevel
