local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")

local busoLoop = nil
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
            if dist < nearest and dist < 100 then
                nearest = mob
                nearestDist = dist
            end
        end
    end
    return nearest
end

-- Hook que redireciona mira para o inimigo mais próximo
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}
    if tostring(method) == "FireServer" then
        if tostring(args[1]) == "RemoteEvent" then
            if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
                if S and S.FastAttack then
                    local enemy = GetNearestEnemy()
                    if enemy then
                        local hrpMob = enemy:FindFirstChild("HumanoidRootPart")
                        if hrpMob then
                            args[2] = hrpMob.Position
                            return oldNamecall(unpack(args))
                        end
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
            task.wait(0.1)
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
-- AUTOCLICK (spamma ataque automaticamente)
-- ============================================================
function Combat:StartAttackLoop()
    if attackLoop then return end
    local VirtualUser = game:GetService("VirtualUser")
    attackLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end
            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end
            if not char:FindFirstChildOfClass("Tool") then continue end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(1280, 672))
            end)
        end
    end)
end

function Combat:Attack() end

Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttackLoop()

return Combat
