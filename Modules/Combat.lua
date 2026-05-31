local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local busoLoop   = nil
local hitboxLoop = nil

local function IsAlive(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function GetNearestEnemies(distance)
    local OthersEnemies = {}
    local BasePart = nil
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return OthersEnemies, nil end

    local function ProcessFolder(folder)
        if not folder then return end
        for _, enemy in ipairs(folder:GetChildren()) do
            local head = enemy:FindFirstChild("Head")
            if head and IsAlive(enemy) and enemy ~= char then
                local dist = (char.HumanoidRootPart.Position - head.Position).Magnitude
                if dist < distance then
                    table.insert(OthersEnemies, {enemy, head})
                    BasePart = head
                end
            end
        end
    end

    ProcessFolder(workspace:FindFirstChild("Enemies"))
    ProcessFolder(workspace:FindFirstChild("Characters"))
    return OthersEnemies, BasePart
end

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
-- FAST ATTACK (igual ao Zyn Hub — RegisterAttack + RegisterHit)
-- ============================================================
function Combat:StartAttackLoop()
    -- Configura _G.Settings igual ao Zyn Hub original
    _G.Settings = _G.Settings or {}
    _G.Settings.AutoClick = true
    _G.Settings.FastAttack = true
    _G.Settings.FastAttackMode = "Fast Attack"

    local delayTime = 0.15

    -- Loop 1: RegisterAttack + RegisterHit
    _G.FastAttackLoop1 = task.spawn(function()
        while true do
            task.wait(delayTime)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack and S.AutoFarmLevel) then continue end

            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool or tool.ToolTip == "Gun" then continue end

            local enemies, basePart = GetNearestEnemies(100)
            if #enemies > 0 and basePart then
                pcall(function()
                    RegisterAttack:FireServer(0)
                    RegisterHit:FireServer(basePart, enemies)
                end)
            end
        end
    end)

    -- Loop 2: segundo loop igual ao Zyn Hub
    _G.FastAttackLoop2 = task.spawn(function()
        while true do
            task.wait(delayTime)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack and S.AutoFarmLevel) then continue end

            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool or tool.ToolTip == "Gun" then continue end

            local enemies, basePart = GetNearestEnemies(100)
            if #enemies > 0 and basePart then
                pcall(function()
                    RegisterAttack:FireServer(0)
                    RegisterHit:FireServer(basePart, enemies)
                end)
            end
        end
    end)

    -- Loop 3: AutoClick igual ao Zyn Hub
    _G.AutoClickLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.AutoFarmLevel) then continue end

            local char = LocalPlayer.Character
            if char and IsAlive(char) and char:FindFirstChildOfClass("Tool") then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                end)
            end
        end
    end)
end

function Combat:Attack() end

Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttackLoop()

return Combat
