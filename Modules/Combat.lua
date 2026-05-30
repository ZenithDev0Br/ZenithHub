local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")

local busoLoop   = nil
local hitboxLoop = nil

-- ============================================================
-- BUSO AUTOMÁTICO
-- ============================================================
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.AutoBuso) then continue end
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then continue end
            if not char:FindFirstChild("HasBuso") then
                pcall(function()
                    CommF:InvokeServer("Buso")
                end)
            end
        end
    end)
end

-- ============================================================
-- MAGNUS HITBOX (sempre ativo)
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
function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or character.Humanoid.Health <= 0 then return end

    local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local attackSpeed = S and S.AttackSpeed or 0.1

    -- Remote fixo de ataque
    local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")

    -- Busca o remote de hit numérico (muda por sessão)
    local HitRemote = nil
    for _, v in pairs(Net:GetChildren()) do
        if v:IsA("RemoteEvent") and tonumber(v.Name) then
            HitRemote = v
            break
        end
    end

    -- Busca o mob mais próximo
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local targetMob = nil
    local targetPart = nil

    if hrp then
        local folder = workspace:FindFirstChild("Enemies")
        if folder then
            local closest = math.huge
            for _, mob in pairs(folder:GetChildren()) do
                local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                local hum = mob:FindFirstChild("Humanoid")
                if mobHrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - mobHrp.Position).Magnitude
                    if dist < closest then
                        closest = dist
                        targetMob = mob
                        targetPart = mob:FindFirstChild("UpperTorso") or mobHrp
                    end
                end
            end
        end
    end

    pcall(function()
        if RegisterAttack then
            RegisterAttack:FireServer(0.5)
        end
        if HitRemote and targetMob and targetPart then
            HitRemote:FireServer(targetMob, targetPart, {targetMob}, nil, "096172ac")
        end
    end)

    task.wait(attackSpeed)
end

-- Inicia ao carregar
Combat:StartBuso()
Combat:StartHitbox()

return Combat
