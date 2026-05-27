local BringMob = {
    Active = true -- Controle interno do módulo
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function BringMob:Cluster(enemyName)
    if not self.Active then return end
    
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    -- Define onde os monstros vão se acumular (na posição do inimigo principal que você está focando)
    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    local targetCFrame = Root.CFrame * CFrame.new(0, -5, 0) -- Coloca os mobs um pouco abaixo de você

    for _, enemy in pairs(folder:GetChildren()) do
        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid then
                -- Verifica se o monstro está em uma distância aceitável para ser puxado (evita teleportar o mapa todo)
                local distance = (Root.Position - enemyRoot.Position).Magnitude
                if distance < 300 then
                    
                    -- Desativa temporariamente a colisão para eles não se empurrarem
                    if enemy:FindFirstChild("UpperTorso") then enemy.UpperTorso.CanCollide = false end
                    if enemy:FindFirstChild("Head") then enemy.Head.CanCollide = false end
                    
                    -- Prende o monstro na posição de ataque
                    enemyRoot.CFrame = targetCFrame
                    
                    -- Otimização: Força o monstro a não andar para longe usando propriedades de física do Roblox
                    enemyRoot.Velocity = Vector3.new(0, 0, 0)
                    enemyRoot.RotVelocity = Vector3.new(0, 0, 0)
                    
                    -- Desativa o "Sit" se o monstro bugar
                    if enemyHumanoid.Sit then enemyHumanoid.Sit = false end
                end
            end
        end
    end
end

return BringMob
