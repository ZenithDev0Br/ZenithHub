local Combat = {
    Active = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- CONFIG
-- =========================

local attackCooldown = 0.01
local lastAttack = 0
local loopRunning = false -- Guard para evitar loops paralelos

-- =========================
-- COMBAT FRAMEWORK
-- =========================

local function GetCombatFramework()
    local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if not PlayerScripts then return nil end

    local Script = PlayerScripts:FindFirstChild("CombatFramework", true)
    if not Script then return nil end

    local ok, env = pcall(function()
        return getsenv(Script)
    end)

    return (ok and env) or nil
end

local function GetController()
    local Framework = GetCombatFramework()
    if Framework and Framework.activeController then
        return Framework.activeController
    end
    return nil
end

-- =========================
-- STOP ATTACK ANIMATIONS
-- =========================

local function StopAnimations(Character)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    if not Animator then return end

    for _, anim in pairs(Animator:GetPlayingAnimationTracks()) do
        local animName = anim.Animation and anim.Animation.Name:lower() or ""

        if animName:match("attack")
        or animName:match("slash")
        or animName:match("combat")
        or animName:match("hit") then
            pcall(function() anim:Stop() end)
        end
    end
end

-- =========================
-- FAST ATTACK
-- =========================

function Combat:Attack()
    if not self.Active then return end

    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

    -- Busca tool no personagem ou na mochila como fallback
    local Tool = Character:FindFirstChildOfClass("Tool")
        or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")

    if not Tool then return end

    local currentTime = tick()
    if (currentTime - lastAttack) < attackCooldown then return end
    lastAttack = currentTime

    -- Lê hitbox das settings externas se disponível
    local ZenithHub = getgenv().ZenithHub
    local Settings = ZenithHub and ZenithHub.Modules and ZenithHub.Modules.FarmSettings
    local hitbox = Settings and Settings.HitboxSize or 60

    pcall(function()
        StopAnimations(Character)

        local Controller = GetController()

        if Controller then
            Controller.timeToNextAttack = 0
            Controller.hitboxMagnitude  = hitbox
            Controller.attacking        = false
            Controller.blocking         = false
            Controller.increment        = 3
            Controller.equipped         = true

            if Controller.attack then
                Controller:attack()
            else
                Tool:Activate()
            end
        else
            Tool:Activate()
        end
    end)
end

-- =========================
-- LOOP CONTROL
-- =========================

function Combat:Start()
    if loopRunning then return end -- Bloqueia loops duplicados
    loopRunning = true
    self.Active = true

    task.spawn(function()
        while loopRunning do
            task.wait(attackCooldown) -- Respeita o cooldown real

            if not self.Active then
                task.wait(0.1) -- Pausa leve quando inativo
                continue
            end

            pcall(function()
                local Character = LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

                if Character and Humanoid and Humanoid.Health > 0 then
                    Combat:Attack()
                end
            end)
        end
    end)
end

function Combat:Stop()
    self.Active  = false
    loopRunning  = false
end

return Combat
