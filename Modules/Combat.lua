local Combat = {}

local Vim = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variável de controle de tempo para evitar cliques infinitos travando o jogo
local lastAttack = 0
local attackCooldown = 0.05 -- Ajuste para acelerar ou desacelerar (0.05 é bem rápido)

function Combat:Attack()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    
    -- Só ataca se você estiver vivo e com uma ferramenta (arma) na mão
    if Humanoid and Humanoid.Health > 0 and Character:FindFirstChildOfClass("Tool") then
        local currentTime = tick()
        
        if (currentTime - lastAttack) >= attackCooldown then
            lastAttack = currentTime
            
            -- Simula o clique físico (Pressiona e Solta) na coordenada 0, 0 da tela
            Vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            Vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end

return Combat
