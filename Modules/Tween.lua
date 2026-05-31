local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Tween = {}
local LocalPlayer = Players.LocalPlayer

function Tween:MoveTo(targetCFrame)
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local speed = (settings and settings.TweenSpeed) or 300

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local time = distance / speed

    local tweenInfo = TweenInfo.new(
        math.clamp(time, 0.05, 2),
        Enum.EasingStyle.Linear
    )

    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()

    return tween
end

return Tween
