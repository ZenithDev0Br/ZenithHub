local FarmSettings = {}
local LP = game:GetService("Players").LocalPlayer

-- Configurações Globais
_G.TweenSpeed = 300 -- Menor = Mais lento
_G.AttackHeight = 5 -- Altura acima do mob

-- Função de Fast Attack (Persistente)
function FarmSettings:FastAttack(enabled)
    _G.FastAttack = enabled
    if enabled then
        task.spawn(function()
            while _G.FastAttack and task.wait() do
                local Combat = LP.Character:FindFirstChildOfClass("Tool")
                if Combat and Combat:FindFirstChild("RemoteFunction") then
                    Combat.RemoteFunction:InvokeServer("Attack")
                end
            end
        end)
    end
end

-- Função de Bring Mobs (Persistente)
function FarmSettings:BringMobs(enabled)
    _G.BringMobs = enabled
    task.spawn(function()
        while _G.BringMobs and task.wait(0.5) do
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("HumanoidRootPart") then
                    v.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end
    end)
end

getgenv().ZenithHub.Modules.FarmSettings = FarmSettings
return FarmSettings
