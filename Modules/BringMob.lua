local BringMob = {
    Active = true
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function BringMob:Cluster(enemyName)
    if not self.Active then return end
    
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local ZenithHub = getgenv().ZenithHub
    local Settings = ZenithHub and ZenithHub.Modules and ZenithHub.Modules.FarmSettings
    local attackHeight = Settings and Settings.AttackHeight or 5

    -- Ponto base: exatamente abaixo do player
    local basePosition = Root.CFrame * CFrame.new(0, -attackHeight, 0)

    local folder = Workspace:FindFirstChild("Enemies") or Workspace

    local index = 0 -- Contador para empilhar os mobs

    for _, enemy in pairs(folder:GetChildren()) do
        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid then
                local distance = (Root.Position - enemyRoot.Position).Magnitude
                if distance < 350 then

                    -- Desativa colisão para evitar empurrões físicos
                    for _, part in pairs(enemy:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end

                    -- Trava o estado físico do humanoid
                    if enemyHumanoid.Health > 0 then
                        enemyHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end

                    -- 🔽 Empilha cada mob ligeiramente abaixo do anterior
                    -- index 0 = primeiro mob fica em -attackHeight
                    -- index 1 = -attackHeight - 2, etc.
                    local stackOffset = index * -2 -- 2 studs de separação vertical
                    local targetCFrame = Root.CFrame * CFrame.new(0, -attackHeight + stackOffset, 0)

                    enemyRoot.CFrame = targetCFrame

                    -- Zera física completamente
                    enemyRoot.Velocity = Vector3.new(0, 0, 0)
                    enemyRoot.RotVelocity = Vector3.new(0, 0, 0)

                    if enemyHumanoid.Sit then enemyHumanoid.Sit = false end

                    index = index + 1 -- Próximo mob vai um pouco mais abaixo
                end
            end
        end
    end
end

return BringMob
