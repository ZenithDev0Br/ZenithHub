local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RegisterAttack = Remotes:WaitForChild("Validator") or ReplicatedStorage:WaitForChild("Effect"):WaitForChild("Container"):FindFirstChild("Death") -- Fallback dinâmico de segurança

function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or character.Humanoid.Health <= 0 then return end

    -- 1. Executa o clique físico simulado para disparar a animação da arma
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(300, 300))
    end)

    -- 2. Dispara o Remote de validação de ataque do servidor (Fast Attack Bypass)
    local CommF = Remotes:FindFirstChild("CommF_")
    if CommF then
        task.spawn(function()
            pcall(function()
                -- Envia o registro de ataque padrão (Zyn Hub Engine)
                CommF:InvokeServer("Attack", 0)
            end)
        end)
    end
end

return Combat
