local Weapon = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Weapon:Equip()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("Humanoid") then return end
    
    -- Se você já estiver segurando QUALQUER ferramenta, não precisa equipar de novo
    if Character:FindFirstChildOfClass("Tool") then return end
    
    -- Busca qual o tipo de arma selecionada na UI do ZenithHub
    local Modules = getgenv().ZenithHub and getgenv().ZenithHub.Modules
    local Settings = Modules and Modules.FarmSettings
    local weaponPreference = Settings and Settings.WeaponType or "Melee" -- Padrão: Melee (Estilo de luta)

    -- Procura o item correto dentro da Backpack (Mochila)
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local deveEquipar = false
            
            -- Lógica para identificar o tipo de arma pelo ToolType ou nome interno do Blox Fruits
            if weaponPreference == "Melee" and (tool:FindFirstChild("Melee") or tool.ToolTip == "Melee") then
                deveEquipar = true
            elseif weaponPreference == "Sword" and (tool:FindFirstChild("Sword") or tool.ToolTip == "Sword") then
                deveEquipar = true
            elseif weaponPreference == "Blox Fruit" and (tool:FindFirstChild("Blox Fruit") or tool.ToolTip == "Blox Fruit") then
                deveEquipar = true
            end
            
            -- Se achar uma ferramenta que encaixe mas a UI não definiu ToolTip,
            -- o script tenta pegar a primeira ferramenta útil que achar na mochila como segurança
            if not deveEquipar and weaponPreference == "Melee" and tool.Name == "Combat" then
                deveEquipar = true
            end

            if deveEquipar then
                Character.Humanoid:EquipTool(tool)
                break
            end
        end
    end
end

return Weapon
