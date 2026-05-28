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

    -- Puxa as configurações da UI em tempo real
    local ZenithHub = getgenv().ZenithHub
    local Settings = ZenithHub and ZenithHub.Modules and ZenithHub.Modules.FarmSettings
    local attackHeight = Settings and Settings.AttackHeight or 5

    -- Define o ponto exato onde os monstros vão se acumular
    local targetCFrame = Root.CFrame * CFrame.new(0, -attackHeight, 0)

    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    
    for _, enemy in pairs(folder:GetChildren()) do
        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid then
                local distance = (Root.Position - enemyRoot.Position).Magnitude
                if distance < 350 then -- Alcance do puxão
                    
                    -- 🔥 DESATIVA COLISÃO E ÂNCORA DE TODAS AS PEÇAS
                    for _, part in pairs(enemy:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Anchored = false -- Garante que nenhuma peça está travada no chão pelo jogo
                        end
                    end
                    
                    -- Prende o monstro na posição de ataque embaixo de você
                    enemyRoot.CFrame = targetCFrame
                    
                    -- 🔥 TRAVA DE FÍSICA AGRESSIVA (Evita que o monstro tente andar ou usar skills)
                    enemyRoot.Velocity = Vector3.new(0, 0, 0)
                    enemyRoot.RotVelocity = Vector3.new(0, 0, 0)
                    
                    -- Força o Humanoid a entrar em estado de Física para desativar a IA do script do jogo
                    if enemyHumanoid.Health > 0 and enemyHumanoid:GetState() ~= Enum.HumanoidStateType.Physics then
                        enemyHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                    
                    if enemyHumanoid.Sit then enemyHumanoid.Sit = false end
                end
            end
        end
    end
end

return BringMob
