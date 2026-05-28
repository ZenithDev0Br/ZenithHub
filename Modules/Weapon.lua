local Weapon = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Weapon:Equip()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("Humanoid") then return end
    if Character:FindFirstChildOfClass("Tool") then return end

    local Modules = getgenv().ZenithHub and getgenv().ZenithHub.Modules
    local Settings = Modules and Modules.FarmSettings
    local weaponPreference = Settings and Settings.WeaponType or "Melee"

    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local deveEquipar = false

            if weaponPreference == "Melee" and (tool:FindFirstChild("Melee") or tool.ToolTip == "Melee" or tool.Name == "Combat") then
                deveEquipar = true
            elseif weaponPreference == "Sword" and (tool:FindFirstChild("Sword") or tool.ToolTip == "Sword") then
                deveEquipar = true
            elseif weaponPreference == "Blox Fruit" and (tool:FindFirstChild("Blox Fruit") or tool.ToolTip == "Blox Fruit") then
                deveEquipar = true
            elseif weaponPreference == "Gun" and (tool:FindFirstChild("Gun") or tool.ToolTip == "Gun") then
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
