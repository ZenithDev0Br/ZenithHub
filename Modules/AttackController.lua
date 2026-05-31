local AttackController = {}

function AttackController:GetOffsetCFrame(targetCFrame)
    local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings

    local height = (settings and settings.AttackHeight) or 22
    local distance = (settings and settings.AttackDistance) or 0

    return targetCFrame * CFrame.new(0, height, distance)
end

function AttackController:ApplyPosition(hrp, targetCFrame)
    if not hrp then return end
    hrp.CFrame = self:GetOffsetCFrame(targetCFrame)
end

return AttackController
