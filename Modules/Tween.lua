local TweenModule = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function TweenModule:MoveTo(targetCFrame)
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    -- Puxa a velocidade configurada no Slider da sua UI
    local Modules = getgenv().ZenithHub and getgenv().ZenithHub.Modules
    local Settings = Modules and Modules.FarmSettings
    local Speed = Settings and Settings.TweenSpeed or 300

    local Distance = (Root.Position - targetCFrame.Position).Magnitude
    
    if Distance < 5 then
        Root.CFrame = targetCFrame
        return
    end

    local Time = Distance / Speed
    local Info = TweenInfo.new(Time, Enum.EasingStyle.Linear)
    local Tween = TweenService:Create(Root, Info, {CFrame = targetCFrame})
    
    Tween:Play()
    Tween.Completed:Wait() -- Espera chegar para continuar o farm
end

return TweenModule
