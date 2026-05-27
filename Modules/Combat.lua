local Combat = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Combat:Attack()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Varre o personagem para encontrar o estilo de luta/espada equipado
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            -- Ativa a ferramenta nativamente pelo código do jogo, zero simulação
            item:Activate() 
            break
        end
    end
end

return Combat
