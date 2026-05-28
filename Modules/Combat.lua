local Combat = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lastAttack = 0
local attackCooldown = 0.01 -- Mais estável

-- Variável para controlar a frequência do BringMob para não lagar o servidor
local lastBring = 0
local bringCooldown = 0.1 -- Roda a cada 100ms (perfeito para a física do Roblox)

-- Pega o CombatFramework corretamente via getsenv
local CombatFramework = nil
pcall(function()
    CombatFramework = getsenv(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
end)

-- Pega controller atual
local function GetController()
    if CombatFramework and CombatFramework.activeController then
        return CombatFramework.activeController
    end
    return nil
end

-- Remove APENAS as animações de ataque (evita bugar o teleporte do farm)
local function StopAnimations(Character)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    if not Animator then return end

    for _, anim in pairs(Animator:GetPlayingAnimationTracks()) do
        local animName = anim.Animation and anim.Animation.Name:lower() or ""
        -- Só para animações que pareçam com ataques, deixando as de voo/movimento livres
        if animName:match("attack") or animName:match("slash") or animName:match("combat") or animName:match("hit") then
            pcall(function()
                anim:Stop()
            end)
        end
    end
end

-- Expande hitbox
local function ExpandHitbox(enemyName)
    local Enemies = workspace:FindFirstChild("Enemies")
    if not Enemies then return end

    for _, enemy in pairs(Enemies:GetChildren()) do
        if enemy.Name == enemyName
        and enemy:FindFirstChild("Humanoid")
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy.Humanoid.Health > 0 then

            local root = enemy.HumanoidRootPart

            -- 25x25x25 é o tamanho ideal e seguro contra detecção
            root.Size = Vector3.new(25, 25, 25)
            root.Transparency = 0.7
            root.CanCollide = false

            enemy.Humanoid.WalkSpeed = 0
            enemy.Humanoid.JumpPower = 0

            pcall(function()
                enemy.Humanoid:ChangeState(11) -- Trava o bicho na física para não cair do mapa
            end)
        end
    end
end

-- Bring mob otimizado para não sobrecarregar a rede do jogo
local function BringMob(enemyName)
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local Enemies = workspace:FindFirstChild("Enemies")
    if not Enemies then return end

    for _, enemy in pairs(Enemies:GetChildren()) do
        if enemy.Name == enemyName
        and enemy:FindFirstChild("Humanoid")
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy.Humanoid.Health > 0 then
            
            -- Desativa colisões para passarem por dentro das paredes da Jungle
            pcall(function()
                enemy.HumanoidRootPart.CanCollide = false
                if enemy:FindFirstChild("Head") then enemy.Head.CanCollide = false end
            end)

            -- Puxa o monstro para 5 studs na sua frente
            enemy.HumanoidRootPart.CFrame = HRP.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

function Combat:Attack(enemyName)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")
    local Tool = Character and Character:FindFirstChildOfClass("Tool")

    if not Character or not Humanoid or Humanoid.Health <= 0 or not Tool then
        return
    end

    local currentTime = tick()

    -- Executa BringMob e Hitbox em um tempo ligeiramente diferente para evitar lag físico
    if enemyName and (currentTime - lastBring) >= bringCooldown then
        lastBring = currentTime
        pcall(function()
            BringMob(enemyName)
            ExpandHitbox(enemyName)
        end)
    end

    -- Trava do Cooldown de Ataque (Metralhadora)
    if (currentTime - lastAttack) < attackCooldown then
        return
    end
    lastAttack = currentTime

    pcall(function()
        local Controller = GetController()

        -- Remove apenas animações pesadas de soco/espada
        StopAnimations(Character)

        if Controller then
            -- Fast attack real manipulando as variáveis do jogo
            Controller.timeToNextAttack = 0
            Controller.hitboxMagnitude = 60

            -- Reseta estados de trava do próprio Blox Fruits
            Controller.attacking = false
            Controller.blocking = false
            Controller.increment = 3
            Controller.equipped = true

            -- Executa o ataque nativo perfeito
            if Controller.attack then
                Controller:attack()
            end
        else
            -- Fallback caso o script do jogo demore a carregar o getsenv
            Tool:Activate()
        end
    end)
end

return Combat
