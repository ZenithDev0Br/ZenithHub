local Combat = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- CONFIG
-- =========================

local attackCooldown = 0.01
local lastAttack = 0

-- =========================
-- COMBAT FRAMEWORK
-- =========================

local function GetCombatFramework()

    local PlayerScripts =
        LocalPlayer:FindFirstChild("PlayerScripts")

    if not PlayerScripts then
        return nil
    end

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
-- STOP ATTACK ANIMATIONS
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
-- FAST ATTACK
-- =========================

function Combat:Attack()

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

            -- Ataque nativo
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

function Combat:Start()

    task.spawn(function()

        while task.wait() do

            pcall(function()

                if LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChild(
                    "Humanoid"
                )
                and LocalPlayer.Character.Humanoid.Health > 0 then

                    Combat:Attack()
                end
            end)
        end
    end)
end

return Combat
