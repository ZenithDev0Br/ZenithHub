local Combat = {}

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Controle de tempo para o Fast Attack
local lastAttack = 0
local attackCooldown = 0.05 -- Velocidade ultra rápida (pode diminuir para 0.01 se o exploit aguentar)

function Combat:Attack()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    local currentTool = Character and Character:FindFirstChildOfClass("Tool")
    
    -- Só executa o ataque se o seu personagem estiver vivo e segurando uma arma
    if Humanoid and Humanoid.Health > 0 and currentTool then
        local currentTime = tick()
        
        if (currentTime - lastAttack) >= attackCooldown then
            lastAttack = currentTime
            
            pcall(function()
                -- 1. Ativa a ferramenta internamente (dispara o soco/espada direto no servidor)
                currentTool:Activate()
                
                -- 2. Simula o clique 3D no ambiente em uma área neutra (garante o registro do dano)
                -- Sem dar cliques físicos na coordenada (0,0), evitando fechar menus de missões
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(50, 50))
            end)
        end
    end
end

return Combat
