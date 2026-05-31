local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")

local busoLoop   = nil
local hitboxLoop = nil
local attackLoop = nil

local function IsAlive(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function GetNearestEnemy()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, nearestDist = nil, math.huge
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end

    for _, mob in ipairs(folder:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
        local hrpMob = mob:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and hrpMob then
            local dist = (hrp.Position - hrpMob.Position).Magnitude
            if dist < nearestDist and dist < 100 then
                nearest = mob
                nearestDist = dist
            end
        end
    end
    return nearest
end

-- ============================================================
-- NAMECALL HOOK — corrigido para Remotes folder
-- ============================================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}

    if tostring(method) == "FireServer" then
        local remote = args[1]
        if typeof(remote) == "Instance" and remote:IsA("RemoteEvent")
        and remote.Parent == Net -- CORREÇÃO: parent é ReplicatedStorage.Remotes
        and tonumber(remote.Name) -- CORREÇÃO: nome numérico
        and typeof(args[2]) == "string"
        and typeof(args[3]) == "number"
        and typeof(args[4]) == "Instance" then

            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if S and S.FastAttack and S.AutoFarmLevel then
                local enemy = GetNearestEnemy()
                if enemy then
                    local targetPart = enemy:FindFirstChild("LeftUpperArm")
                        or enemy:FindFirstChild("RightHand")
                        or enemy:FindFirstChild("UpperTorso")
                        or enemy:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        args[4] = targetPart
                        return oldNamecall(unpack(args))
                    end
                end
            end
        end
    end

    return oldNamecall(...)
end)
setreadonly(mt, true)

-- ============================================================
-- BUSO AUTOMÁTICO
-- ============================================================
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.AutoBuso) then continue end
            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end
            if not char:FindFirstChild("HasBuso") then
                pcall(function() CommF:InvokeServer("Buso") end)
            end
        end
    end)
end

-- ============================================================
-- HITBOX
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
-- FAST ATTACK — só roda se AutoFarmLevel estiver ligado
-- ============================================================
function Combat:StartAttackLoop()
    if attackLoop then return end
    attackLoop = task.spawn(function()
        while true do
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings

            if not (S and S.FastAttack and S.AutoFarmLevel) then
                task.wait(0.1)
                continue
            end

            local char = LocalPlayer.Character
            if not IsAlive(char) or not char:FindFirstChildOfClass("Tool") then
                task.wait(0.1)
                continue
            end

            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(640, 360, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(640, 360, 0, false, game, 1)
            end)

            task.wait(0.05)
        end
    end)
end

function Combat:Attack() end

Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttackLoop()

return Combat
