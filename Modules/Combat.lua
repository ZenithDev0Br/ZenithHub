local Combat = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lastAttack = 0
local attackCooldown = 0.01 -- Mais estável

-- Pega o CombatFramework corretamente
local CombatFramework = nil

pcall(function()
    CombatFramework =
        getsenv(
            LocalPlayer.PlayerScripts:WaitForChild("CombatFramework")
        )
end)

-- Pega controller atual
local function GetController()
    if CombatFramework
    and CombatFramework.activeController then

        return CombatFramework.activeController
    end

    return nil
end

-- Remove animações de ataque
local function StopAnimations(Character)
    local Humanoid =
        Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    local Animator =
        Humanoid:FindFirstChildOfClass("Animator")

    if not Animator then
        return
    end

    for _, anim in pairs(
        Animator:GetPlayingAnimationTracks()
    ) do
        pcall(function()
            anim:Stop()
        end)
    end
end

-- Expande hitbox
local function ExpandHitbox(enemyName)
    local Enemies =
        workspace:FindFirstChild("Enemies")

    if not Enemies then
        return
    end

    for _, enemy in pairs(Enemies:GetChildren()) do

        if enemy.Name == enemyName
        and enemy:FindFirstChild("Humanoid")
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy.Humanoid.Health > 0 then

            local root = enemy.HumanoidRootPart

            root.Size = Vector3.new(25,25,25)
            root.Transparency = 0.7
            root.CanCollide = false

            enemy.Humanoid.WalkSpeed = 0
            enemy.Humanoid.JumpPower = 0

            pcall(function()
                enemy.Humanoid:ChangeState(11)
            end)
        end
    end
end

-- Bring mob
local function BringMob(enemyName)
    local Character = LocalPlayer.Character
    local HRP =
        Character and Character:FindFirstChild("HumanoidRootPart")

    if not HRP then
        return
    end

    local Enemies =
        workspace:FindFirstChild("Enemies")

    if not Enemies then
        return
    end

    for _, enemy in pairs(Enemies:GetChildren()) do

        if enemy.Name == enemyName
        and enemy:FindFirstChild("Humanoid")
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy.Humanoid.Health > 0 then

            enemy.HumanoidRootPart.CFrame =
                HRP.CFrame * CFrame.new(0,0,-5)
        end
    end
end

function Combat:Attack(enemyName)

    local Character = LocalPlayer.Character

    local Humanoid =
        Character and Character:FindFirstChild("Humanoid")

    local Tool =
        Character and Character:FindFirstChildOfClass("Tool")

    if not Character
    or not Humanoid
    or Humanoid.Health <= 0
    or not Tool then
        return
    end

    local currentTime = tick()

    if (currentTime - lastAttack) < attackCooldown then
        return
    end

    lastAttack = currentTime

    pcall(function()

        local Controller = GetController()

        -- Bring + Hitbox
        if enemyName then
            BringMob(enemyName)
            ExpandHitbox(enemyName)
        end

        -- Remove animações
        StopAnimations(Character)

        if Controller then

            -- Fast attack real
            Controller.timeToNextAttack = 0
            Controller.hitboxMagnitude = 60

            -- Reseta estados
            Controller.attacking = false
            Controller.blocking = false
            Controller.increment = 3

            -- Equipa arma
            Controller.equipped = true

            -- Ataque nativo
            if Controller.attack then
                Controller:attack()
            end

        else
            -- Fallback
            Tool:Activate()
        end
    end)
end

return Combat
