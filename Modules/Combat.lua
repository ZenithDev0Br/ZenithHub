local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")  -- Voltei para WaitForChild

local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit = Net:FindFirstChild("RE/RegisterHit")
local hasFastAttackRemotes = RegisterAttack ~= nil and RegisterHit ~= nil

local busoLoop = nil
local hitboxLoop = nil
local fastAttackLoop = nil
local autoClickLoop = nil

-- Captura o controle do VirtualUser uma única vez
pcall(function()
    VirtualUser:CaptureController()
end)

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
-- BUSO AUTOMÁTICO (original)
-- ============================================================
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.AutoBuso) then
                continue
            end
            local char = LocalPlayer.Character
            if not char or not isAlive(char) then
                continue
            end
            if not char:FindFirstChild("HasBuso") then
                pcall(function()
                    CommF:InvokeServer("Buso")
                end)
            end
        end
    end)
end

-- ============================================================
-- HITBOX EXPANSION (original)
-- ============================================================
function Combat:StartHitbox()
    if hitboxLoop then return end
    hitboxLoop = RunService.Stepped:Connect(function()
        local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
        local hitboxSize = S and S.HitboxSize or 15
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    sethiddenproperty(part, "HitboxSize", Vector3.new(hitboxSize, hitboxSize, hitboxSize))
                end)
            end
        end
    end)
end

-- ============================================================
-- FAST ATTACK
-- ============================================================
function Combat:FastAttack()
    local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    if not (S and S.FastAttack) then return end

    if not hasFastAttackRemotes then
        -- Fallback: só clica se o AutoClick também estiver ativo
        if S.AutoClick then
            self:Attack()
        end
        return
    end

    local enemy, hitPart = getNearestEnemy(S.FastAttackRange or 100)
    if not enemy or not hitPart then return end

    local others = { { enemy, hitPart } }
    pcall(function()
        RegisterAttack:FireServer(0)
        RegisterHit:FireServer(hitPart, others)
    end)
end

-- ============================================================
-- AUTO CLICK (VirtualUser) - com CaptureController já chamado
-- ============================================================
function Combat:Attack()
    local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    if not (S and S.AutoClick) then return end

    local char = LocalPlayer.Character
    if not char or not isAlive(char) then return end

    pcall(function()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(1280, 672))
    end)
end

-- ============================================================
-- LOOPS
-- ============================================================
function Combat:StartFastAttackLoop()
    if fastAttackLoop then return end
    fastAttackLoop = task.spawn(function()
        while true do
            self:FastAttack()
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            local delay = S and S.FastAttackDelay or 0.15
            task.wait(delay)
        end
    end)
end

function Combat:StartAutoClickLoop()
    if autoClickLoop then return end
    autoClickLoop = task.spawn(function()
        while true do
            self:Attack()
            task.wait(0.1)
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
