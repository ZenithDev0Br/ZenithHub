local Combat = {}

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

function Combat:GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function Combat:Equip(toolType)

    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if not backpack then
        return
    end

    local character = self:GetCharacter()

    for _, tool in pairs(backpack:GetChildren()) do

        if tool:IsA("Tool")
            and tool.ToolTip == toolType then

            character.Humanoid:EquipTool(tool)

            return tool
        end
    end
end

function Combat:Click()

    VirtualUser:Button1Down(Vector2.new(0,0))
    task.wait()
    VirtualUser:Button1Up(Vector2.new(0,0))

end

function Combat:Skill(key)

    game:GetService("VirtualInputManager"):SendKeyEvent(
        true,
        key,
        false,
        game
    )

    task.wait()

    game:GetService("VirtualInputManager"):SendKeyEvent(
        false,
        key,
        false,
        game
    )

end

return Combat
