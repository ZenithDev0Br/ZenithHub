local ZenithHub = getgenv().ZenithHub

local Settings = ZenithHub.Modules.FarmSettings

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local Farm = {}

Farm.Enabled = false

-- CHARACTER
function Farm:GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ROOT
function Farm:GetRoot()
    local char = self:GetCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

-- GET CLOSEST MOB
function Farm:GetClosestMob()

    local enemies = workspace:FindFirstChild("Enemies")

    if not enemies then
        return nil
    end

    local closest = nil
    local shortest = math.huge

    for _, mob in pairs(enemies:GetChildren()) do

        local hrp = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChild("Humanoid")

        if hrp and hum and hum.Health > 0 then

            local distance = (
                hrp.Position - self:GetRoot().Position
            ).Magnitude

            if distance < shortest then
                shortest = distance
                closest = mob
            end

        end
    end

    return closest
end

-- EQUIP WEAPON
function Farm:EquipWeapon()

    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if not backpack then
        return
    end

    local character = self:GetCharacter()

    for _, tool in pairs(backpack:GetChildren()) do

        if tool:IsA("Tool") then

            if Settings.SelectedWeapon == "Melee"
                and tool.ToolTip == "Melee" then

                character.Humanoid:EquipTool(tool)
                return
            end

            if Settings.SelectedWeapon == "Sword"
                and tool.ToolTip == "Sword" then

                character.Humanoid:EquipTool(tool)
                return
            end

            if Settings.SelectedWeapon == "Gun"
                and tool.ToolTip == "Gun" then

                character.Humanoid:EquipTool(tool)
                return
            end

            if Settings.SelectedWeapon == "Devil Fruit"
                and tool.ToolTip == "Blox Fruit" then

                character.Humanoid:EquipTool(tool)
                return
            end

        end
    end
end

-- TWEEN
function Farm:TweenTo(position)

    local root = self:GetRoot()

    local tween = TweenService:Create(
        root,
        TweenInfo.new(
            0.8,
            Enum.EasingStyle.Linear
        ),
        {
            CFrame = CFrame.new(position)
        }
    )

    tween:Play()

    return tween
end

-- ATTACK
function Farm:Attack()

    VirtualUser:Button1Down(Vector2.new(0, 0))
    task.wait()
    VirtualUser:Button1Up(Vector2.new(0, 0))

end

-- BRING MOBS
function Farm:BringMobs(target)

    if not Settings.BringMobs then
        return
    end

    local enemies = workspace:FindFirstChild("Enemies")

    if not enemies then
        return
    end

    for _, mob in pairs(enemies:GetChildren()) do

        if mob ~= target then

            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hum = mob:FindFirstChild("Humanoid")

            if hrp and hum and hum.Health > 0 then

                hrp.CFrame =
                    target.HumanoidRootPart.CFrame *
                    CFrame.new(
                        math.random(-5,5),
                        0,
                        math.random(-5,5)
                    )

            end
        end
    end
end

-- MAIN LOOP
function Farm:Start()

    if self.Enabled then
        return
    end

    self.Enabled = true

    task.spawn(function()

        while self.Enabled do
            task.wait(0.15)

            if not Settings.AutoFarmLevel then
                continue
            end

            local mob = self:GetClosestMob()

            if mob
                and mob:FindFirstChild("HumanoidRootPart")
                and mob:FindFirstChild("Humanoid") then

                local mobPos =
                    mob.HumanoidRootPart.Position +
                    Vector3.new(0, 5, 0)

                self:EquipWeapon()

                self:TweenTo(mobPos)

                if Settings.BringMobs then
                    self:BringMobs(mob)
                end

                if Settings.FastAttack then
                    self:Attack()
                end

            end
        end
    end)
end

-- STOP
function Farm:Stop()
    self.Enabled = false
end

ZenithHub.Modules.FarmLevel = Farm

Farm:Start()

return Farm
