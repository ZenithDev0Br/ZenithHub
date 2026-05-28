local Combat = {
    Active = true
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

-- =========================
-- CONFIG
-- =========================

local attackCooldown = 0.01 -- Velocidade de metralhadora
local lastAttack = 0
local loopRunning = false

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
-- FAST ATTACK (Estilo Zyn Hub)
-- =========================

function Combat:Attack()
    if not self.Active then return end

    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

    -- Força equipar a arma se ela estiver na Mochila (Backpack)
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool then
        local BackpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if BackpackTool then
            Humanoid:EquipTool(BackpackTool)
            Tool = BackpackTool
        end
    end

    if not Tool then return end

    local currentTime = tick()
    if (currentTime - lastAttack) < attackCooldown then return end
    lastAttack = currentTime

    pcall(function()
        -- 1. Remove as animações para tirar o lag visual e acelerar os hits
        StopAnimations(Character)

        -- 2. Dispara o clique nativo direto na viewport do jogo (Igual aos inputs do Zyn Hub)
        -- Parâmetros: MouseButton1 (0), Estado Pressionado (true/false), Instância do jogo
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        -- Fallback de segurança caso o executor restrinja o InputManager
        Tool:Activate()
    end)
end

-- =========================
-- LOOP CONTROL
-- =========================

function Combat:Start()
    if loopRunning then return end 
    loopRunning = true
    self.Active = true

    task.spawn(function()
        while loopRunning do
            task.wait(attackCooldown) 

            if not self.Active then
                task.wait(0.1) 
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
