local Combat = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- CONFIG
-- =========================

local attackCooldown = 0.01
local bringCooldown = 0.1

local lastAttack = 0
local lastBring = 0

-- =========================
-- COMBAT FRAMEWORK
-- =========================

local function GetCombatFramework()

    local PlayerScripts =
        LocalPlayer:FindFirstChild("PlayerScripts")

    if not PlayerScripts then
        return nil
    end

    -- Procura CombatFramework em qualquer subpasta
    local Script =
        PlayerScripts:FindFirstChild("CombatFramework", true)

    if not Script then
        return nil
    end

    local ok, env = pcall(function()
        return getsenv(Script)
    end)

    if ok and env then
        return env
    end

    return nil
end

local function GetController()

    local Framework = GetCombatFramework()

    if Framework
    and Framework.activeController then

        return Framework.activeController
    end

    return nil
end

-- =========================
-- STOP ANIMATIONS
-- =========================

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

        local animName =
            anim.Animation
            and anim.Animation.Name:lower()
            or ""

        if animName:match("attack")
        or animName:match("slash")
        or animName:match("combat")
        or animName:match("hit") then

            pcall(function()
                anim:Stop()
            end)
        end
    end
end

-- =========================
-- HITBOX
-- =========================

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

            local root =
                enemy.HumanoidRootPart

            root.Size =
                Vector3.new(25,25,25)

            root.Transparency = 0.7
            root.CanCollide = false

            enemy.Humanoid.WalkSpeed = 0
            enemy.Humanoid.JumpPower = 0

            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero

            pcall(function()
                enemy.Humanoid:ChangeState(
                    Enum.HumanoidStateType.Physics
                )
            end)
        end
    end
end

-- =========================
-- BRING MOB
-- =========================

local function BringMob(enemyName)

    local Character =
        LocalPlayer.Character

    local HRP =
        Character
        and Character:FindFirstChild(
            "HumanoidRootPart"
        )

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

            local root =
                enemy.HumanoidRootPart

            local distance =
                (root.Position - HRP.Position).Magnitude

            -- Evita puxar mapa inteiro
            if distance <= 300 then

                root.CanCollide = false

                if enemy:FindFirstChild("Head") then
                    enemy.Head.CanCollide = false
                end

                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero

                root.CFrame =
                    HRP.CFrame
                    * CFrame.new(0,0,-5)
            end
        end
    end
end

-- =========================
-- FAST ATTACK
-- =========================

function Combat:Attack(enemyName)

    local Character =
        LocalPlayer.Character

    local Humanoid =
        Character
        and Character:FindFirstChildOfClass(
            "Humanoid"
        )

    local Tool =
        Character
        and Character:FindFirstChildOfClass(
            "Tool"
        )

    if not Character
    or not Humanoid
    or Humanoid.Health <= 0
    or not Tool then
        return
    end

    local currentTime = tick()

    -- Bring separado
    if enemyName
    and (currentTime - lastBring)
    >= bringCooldown then

        lastBring = currentTime

        pcall(function()
            BringMob(enemyName)
            ExpandHitbox(enemyName)
        end)
    end

    -- Cooldown ataque
    if (currentTime - lastAttack)
    < attackCooldown then
        return
    end

    lastAttack = currentTime

    pcall(function()

        StopAnimations(Character)

        local Controller =
            GetController()

        if Controller then

            -- Fast attack
            Controller.timeToNextAttack = 0
            Controller.hitboxMagnitude = 60

            -- Reset estados
            Controller.attacking = false
            Controller.blocking = false

            -- Combo bypass
            Controller.increment = 3

            -- Equipa arma
            Controller.equipped = true

            -- Ataque real
            if Controller.attack then
                Controller:attack()
            else
                Tool:Activate()
            end

        else
            -- Fallback
            Tool:Activate()
        end
    end)
end

-- =========================
-- AUTO LOOP
-- =========================

function Combat:Start(enemyName)

    task.spawn(function()

        while task.wait() do

            pcall(function()

                if LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild(
                    "Humanoid"
                )
                and LocalPlayer.Character.Humanoid.Health > 0 then

                    Combat:Attack(enemyName)
                end
            end)
        end
    end)
end

return Combat
