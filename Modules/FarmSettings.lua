if not getgenv().ZenithHub then getgenv().ZenithHub = { Modules = {} } end
local FarmSettings = {}
local LP = game:GetService("Players").LocalPlayer

_G.FastAttack = true
_G.BringMobs = true
_G.TweenSpeed = 300
_G.AttackHeight = 15
_G.AttackDistance = 0

function FarmSettings:IsFarming()
    return _G.AutoFarmLevel or _G.AutoFarmBones or _G.AutoAnnihilateBosses
end

function FarmSettings:FastAttack(enabled)
    _G.FastAttack = enabled
    task.spawn(function()
        while task.wait(0.25) do -- Atualizado para 0.25 para evitar o kick de DMGDEBUG
            if _G.FastAttack and self:IsFarming() then
                pcall(function()
                    local Combat = LP.Character:FindFirstChildOfClass("Tool")
                    if Combat and Combat:FindFirstChild("RemoteFunction") then
                        Combat.RemoteFunction:InvokeServer("Attack")
                    end
                end)
            end
        end
    end)
end

function FarmSettings:BringMobs(enabled)
    _G.BringMobs = enabled
    task.spawn(function()
        while task.wait(0.5) do
            if _G.BringMobs and self:IsFarming() then
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v.Name == _G.CurrentMobName then
                        v.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    end
                end
            end
        end
    end)
end

getgenv().ZenithHub.Modules.FarmSettings = FarmSettings
return FarmSettings
