local Combat = {}

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lastAttack = 0
local attackCooldown = 0.05 -- Velocidade do Fast Attack (pode ajustar se quiser mais rápido)

function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or character.Humanoid.Health <= 0 then return end
    
    -- Só ataca se o jogador estiver segurando alguma arma (Tool) na mão
    local equippedWeapon = character:FindFirstChildOfClass("Tool")
    
    if equippedWeapon then
        if tick() - lastAttack >= attackCooldown then
            lastAttack = tick()
            
            -- Simula o clique esquerdo perfeitamente na tela
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(50, 50))
        end
    end
end

return Combat
