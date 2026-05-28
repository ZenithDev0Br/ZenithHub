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

    -- Puxa as configurações da UI em tempo real para saber onde posicionar os mobs
    local ZenithHub = getgenv().ZenithHub
    local Settings = ZenithHub and ZenithHub.Modules and ZenithHub.Modules.FarmSettings
    local attackHeight = Settings and Settings.AttackHeight or 5

    -- Define o ponto de acúmulo exatamente na altura onde o combate deve acontecer
    -- Em vez de jogar os mobs para baixo, vamos trazer eles para a altura padrão dos seus ataques
    local targetCFrame = Root.CFrame * CFrame.new(0, -attackHeight, 0)

    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    
    for _, enemy in pairs(folder:GetChildren()) do
        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid then
                local distance = (Root.Position - enemyRoot.Position).Magnitude
                if distance < 350 then -- Alcance bom para juntar o spot todo
                    
                    -- 🔥 CORREÇÃO DA COLISÃO FANTASMA: Desativa a colisão de TODAS as partes do monstro
                    -- Isso impede que eles se empurrem para dentro das paredes ou do chão!
                    for _, part in pairs(enemy:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    -- Se o monstro estiver vivo, desativa temporariamente os estados de animação que fazem ele andar
                    if enemyHumanoid.Health > 0 then
                        enemyHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                    
                    -- Prende o monstro na posição exata de ataque, perfeitamente alinhado abaixo de você
                    enemyRoot.CFrame = targetCFrame
                    
                    -- Zera totalmente as forças físicas para eles não saírem voando com o lag
                    enemyRoot.Velocity = Vector3.new(0, 0, 0)
                    enemyRoot.RotVelocity = Vector3.new(0, 0, 0)
                    
                    if enemyHumanoid.Sit then enemyHumanoid.Sit = false end
                end
            end
        end
    end
end

return BringMob
