local BringMob = {
    Active = true -- Mantém o módulo ativo para o FarmLevel usar
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

function BringMob:Cluster(enemyName)
    if not self.Active then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local playerRoot = character.HumanoidRootPart

    -- Varre o Workspace procurando os monstros alvos
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == enemyName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local enemyRoot = v:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                -- Raio de puxada: 300 studs de distância do jogador
                local distance = (enemyRoot.Position - playerRoot.Position).Magnitude
                if distance < 300 then
                    
                    -- Desativa colisões pro mob não arrastar o seu personagem
                    enemyRoot.CanCollide = false
                    if v:FindFirstChild("Head") then
                        v.Head.CanCollide = false
                    end
                    
                    -- Junta o monstro na posição do farm (exatamente embaixo do player)
                    enemyRoot.CFrame = playerRoot.CFrame * CFrame.new(0, -5, 0)
                end
            end
        end
    end
end

return BringMob
