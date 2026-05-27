local BringMob = {}
BringMob.Active = true -- Ativado por padrão

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function BringMob:Cluster(enemyName)
    if not self.Active then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos = char.HumanoidRootPart.Position

    -- Varre o mapa procurando os monstros da sua quest
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == enemyName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if v:FindFirstChild("HumanoidRootPart") then
                local distance = (v.HumanoidRootPart.Position - myPos).Magnitude
                
                -- Se o monstro estiver num raio de 350 studs, puxa ele
                if distance < 350 then
                    -- Desativa a física dele pra ele não cair ou te empurrar
                    if not v.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(0, 0, 0)
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Parent = v.HumanoidRootPart
                    end
                    
                    -- Coloca o monstro exatamente na sua frente
                    v.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                end
            end
        end
    end
end

return BringMob
