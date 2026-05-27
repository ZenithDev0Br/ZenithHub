local Weapon = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Você pode mudar para "Melee", "Sword" ou "Fruit" depois pela sua UI
Weapon.SelectedType = "Melee" 

function Weapon:Equip()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    
    -- Se já tiver algo na mão, não precisa equipar de novo
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            return
        end
    end
    
    -- Procura a arma na Backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            -- Pega a ferramenta disponível para bater
            if tool:IsA("Tool") then
                char.Humanoid:EquipTool(tool)
                break
            end
        end
    end
end

return Weapon
