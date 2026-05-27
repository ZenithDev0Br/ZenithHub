local Tween = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Tween:MoveTo(targetPosition, speed)
    speed = speed or 300 -- Velocidade padrão (studs por segundo)
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local distance = (hrp.Position - targetPosition).Magnitude
    local duration = distance / speed
    
    -- Evita travar se já estiver no local
    if distance < 5 then return end
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    
    -- Ancorar o personagem durante o vôo evita queda por gravidade
    hrp.Anchored = true
    tween:Play()
    tween.Completed:Wait()
    hrp.Anchored = false
end

return Tween
