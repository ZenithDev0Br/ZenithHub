local Combat = {}

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lastAttack = 0
local attackCooldown = 0.05 -- Mantém a mesma velocidade super rápida de antes

function Combat:Attack()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    local currentTool = Character and Character:FindFirstChildOfClass("Tool")
    
    -- Só ataca se você estiver vivo e com uma ferramenta (arma) na mão
    if Humanoid and Humanoid.Health > 0 and currentTool then
        local currentTime = tick()
        
        if (currentTime - lastAttack) >= attackCooldown then
            lastAttack = currentTime
            
            -- CORREÇÃO DO ERRO: Ativa a arma via código sem dar cliques físicos na tela
            -- Isso impede que os menus de quests fechem ou fiquem bugando
            pcall(function()
                -- Método 1: Força a arma a se ativar diretamente no servidor
                currentTool:Activate()
                
                -- Método 2: Simula o clique do mouse direto no ambiente de jogo (proteção extra para registrar o dano)
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(50, 50)) -- Clica numa área neutra fora da hitbox do diálogo do NPC
            end)
        end
    end
end

return Combat
