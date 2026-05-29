local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")
local SegmentHit = Net:WaitForChild("SegmentHit")

local fastAttackLoop = nil
local autoClickLoop  = nil
local busoLoop       = nil
local hitboxLoop     = nil

local function IsAlive(character)
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
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

local function StopAllAttacks()
    if fastAttackLoop then task.cancel(fastAttackLoop); fastAttackLoop = nil end
    if autoClickLoop  then task.cancel(autoClickLoop);  autoClickLoop  = nil end
end

-- ============================================================
-- FAST ATTACK (SegmentHit)
-- ============================================================
function Combat:StartAttack()
    StopAllAttacks()

    fastAttackLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end

            local char = LocalPlayer.Character
            if not char or not IsAlive(char) then continue end

            local enemies, basePart = GetNearestEnemies(100)
            if #enemies > 0 and basePart then
                pcall(function()
                    SegmentHit:FireServer(basePart, enemies)
                end)
            end
        end
    end)

    autoClickLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end

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
            if not char or not IsAlive(char) then continue end
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

function Combat:Attack()
    -- loops contínuos cuidam de tudo
end

Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttack()

return Combat
