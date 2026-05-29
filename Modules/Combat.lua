local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:FindFirstChild("CommF_")  -- Pode ser nil, usar pcall depois

-- Remotes para Fast Attack (Zyn Hub style)
local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit = Net:FindFirstChild("RE/RegisterHit")
local hasFastAttackRemotes = RegisterAttack ~= nil and RegisterHit ~= nil

local busoLoop = nil
local hitboxConnection = nil
local fastAttackLoop = nil
local autoClickLoop = nil

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

local function isAlive(character)
    local hum = character and character:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function getNearestEnemy(distanceLimit)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, math.huge end

    local closestEnemy = nil
    local closestPart = nil
    local closestDist = distanceLimit or math.huge

    -- Inimigos na pasta Enemies
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            local hum = enemy:FindFirstChild("Humanoid")
            local root = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head")
            if hum and hum.Health > 0 and root then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestEnemy = enemy
                    closestPart = root
                end
            end
        end
    end

    -- Outros personagens (jogadores)
    local charactersFolder = workspace:FindFirstChild("Characters")
    if charactersFolder then
        local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
        local ignoreTeam = settings and settings.IgnoreSameTeam or false
        local myTeam = LocalPlayer.Team

        for _, otherChar in ipairs(charactersFolder:GetChildren()) do
            if otherChar ~= char then
                local hum = otherChar:FindFirstChild("Humanoid")
                local root = otherChar:FindFirstChild("HumanoidRootPart") or otherChar:FindFirstChild("Head")
                if hum and hum.Health > 0 and root then
                    if ignoreTeam then
                        local player = Players:GetPlayerFromCharacter(otherChar)
                        if player and player.Team == myTeam then
                            goto continue
                        end
                    end
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestEnemy = otherChar
                        closestPart = root
                    end
                end
            end
            ::continue::
        end
    end

    return closestEnemy, closestPart, closestDist
end

-- ============================================================
-- BUSO AUTOMÁTICO
-- ============================================================
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (settings and settings.AutoBuso) then
                continue
            end
            local char = LocalPlayer.Character
            if not char or not isAlive(char) then
                continue
            end
            if not char:FindFirstChild("HasBuso") then
                pcall(function()
                    if CommF then
                        CommF:InvokeServer("Buso")
                    end
                end)
            end
        end
    end)
end

-- ============================================================
-- HITBOX EXPANSION (otimizada)
-- ============================================================
function Combat:StartHitbox()
    if hitboxConnection then return end
    hitboxConnection = RunService.Stepped:Connect(function()
        local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
        local hitboxSize = settings and settings.HitboxSize or 15
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    -- Tenta propriedades comuns de hitbox
                    sethiddenproperty(part, "HitboxSize", Vector3.new(hitboxSize, hitboxSize, hitboxSize))
                    -- Fallback para outros jogos
                    sethiddenproperty(part, "Size", Vector3.new(hitboxSize, hitboxSize, hitboxSize))
                end)
            end
        end
    end)
end

-- ============================================================
-- FAST ATTACK (Zyn Hub style)
-- ============================================================
function Combat:FastAttack()
    local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    if not (settings and settings.FastAttack) then return end

    -- Se remotes não existem, usa fallback de clique (somente se AutoClick estiver ativo)
    if not hasFastAttackRemotes then
        if settings.AutoClick then
            self:Attack()
        end
        return
    end

    local enemy, hitPart, dist = getNearestEnemy(settings.FastAttackRange or 100)
    if not enemy or not hitPart then return end

    local others = { { enemy, hitPart } }  -- Formato esperado pelo RegisterHit
    pcall(function()
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(hitPart, others)
    end)
end

-- ============================================================
-- AUTO CLICK (VirtualUser)
-- ============================================================
function Combat:Attack()
    local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    if not (settings and settings.AutoClick) then return end

    local char = LocalPlayer.Character
    if not char or not isAlive(char) then return end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(1280, 672))
    end)
end

-- ============================================================
-- LOOPS PRINCIPAIS (com verificação dinâmica)
-- ============================================================
function Combat:StartFastAttackLoop()
    if fastAttackLoop then return end
    fastAttackLoop = task.spawn(function()
        while true do
            self:FastAttack()
            local settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            local delay = (settings and settings.FastAttackDelay) or 0.15
            task.wait(delay)
        end
    end)
end

function Combat:StartAutoClickLoop()
    if autoClickLoop then return end
    autoClickLoop = task.spawn(function()
        while true do
            self:Attack()
            task.wait(0.1)  -- Delay fixo para clique normal
        end
    end)
end

-- ============================================================
-- INICIALIZAÇÃO
-- ============================================================
Combat:StartBuso()
Combat:StartHitbox()
Combat:StartFastAttackLoop()
Combat:StartAutoClickLoop()

return Combat
