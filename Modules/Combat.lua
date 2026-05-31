local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local AttackDelays = {
    ["Normal Attack"]     = 0.25,
    ["Fast Attack"]       = 0.15,
    ["Super Attack"]      = 0.05,
    ["Bear Attack"]       = 0.1,
    ["Super Bear Attack"] = 0.01,
}

local function IsAlive(character)
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

local function StopAllAttacks()
    if _G.FastAttackLoop1 then task.cancel(_G.FastAttackLoop1); _G.FastAttackLoop1 = nil end
    if _G.FastAttackLoop2 then task.cancel(_G.FastAttackLoop2); _G.FastAttackLoop2 = nil end
    if _G.AutoClickLoop   then task.cancel(_G.AutoClickLoop);   _G.AutoClickLoop   = nil end
end

local FastAttack1 = { Distance = 100 }

function FastAttack1:Attack(BasePart, OthersEnemies)
    if not BasePart or #OthersEnemies == 0 then return end
    RegisterAttack:FireServer(0)
    RegisterHit:FireServer(BasePart, OthersEnemies)
end

function FastAttack1:GetNearestEnemies()
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
                if dist < self.Distance then
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

local FastAttack2 = { Distance = 100 }

function FastAttack2:Attack(BasePart, OthersEnemies)
    if not BasePart or #OthersEnemies == 0 then return end
    RegisterAttack:FireServer(0)
    RegisterHit:FireServer(BasePart, OthersEnemies)
end

function FastAttack2:AttackNearest()
    local OthersEnemies = {}
    local BasePart = nil
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local function ProcessFolder(folder)
        if not folder then return nil end
        for _, enemy in ipairs(folder:GetChildren()) do
            local head = enemy:FindFirstChild("Head")
            if head and IsAlive(enemy) and enemy ~= char then
                local dist = (char.HumanoidRootPart.Position - head.Position).Magnitude
                if dist < self.Distance then
                    table.insert(OthersEnemies, {enemy, head})
                    BasePart = head
                end
            end
        end
        return BasePart
    end

    local Part1 = ProcessFolder(workspace:FindFirstChild("Enemies"))
    local Part2 = ProcessFolder(workspace:FindFirstChild("Characters"))

    if #OthersEnemies > 0 then
        self:Attack(Part1 or Part2, OthersEnemies)
    end
end

local function StartAttacksWithMode(mode)
    StopAllAttacks()

    local delayTime = AttackDelays[mode] or 0.15
    _G.Settings = _G.Settings or {}
    _G.Settings.FastAttackMode = mode
    _G.Settings.FastAttack = true
    _G.Settings.AutoClick = true

    _G.FastAttackLoop1 = task.spawn(function()
        while _G.Settings.FastAttack do
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if S and S.AutoFarmLevel then
                local char = LocalPlayer.Character
                if char and IsAlive(char) then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool.ToolTip ~= "Gun" then
                        local enemies, basePart = FastAttack1:GetNearestEnemies()
                        if #enemies > 0 and basePart then
                            FastAttack1:Attack(basePart, enemies)
                        end
                    end
                end
            end
            task.wait(delayTime)
        end
    end)

    _G.FastAttackLoop2 = task.spawn(function()
        while _G.Settings.FastAttack do
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if S and S.AutoFarmLevel then
                local char = LocalPlayer.Character
                if char and IsAlive(char) then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool.ToolTip ~= "Gun" then
                        FastAttack2:AttackNearest()
                    end
                end
            end
            task.wait(delayTime)
        end
    end)

    _G.AutoClickLoop = task.spawn(function()
        while _G.Settings.AutoClick do
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if S and S.AutoFarmLevel then
                local char = LocalPlayer.Character
                if char and IsAlive(char) and char:FindFirstChildOfClass("Tool") then
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    end)
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ============================================================
-- BUSO AUTOMÁTICO
-- ============================================================
function Combat:StartBuso()
    task.spawn(function()
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
    task.spawn(function()
        while true do
            task.wait(0.5)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            local hitboxSize = S and S.HitboxSize or 15
            local char = LocalPlayer.Character
            if not char then continue end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        sethiddenproperty(part, "HitboxSize", Vector3.new(hitboxSize, hitboxSize, hitboxSize))
                    end)
                end
            end
        end
    end)
end

function Combat:Attack() end

-- Inicia tudo ao carregar
Combat:StartBuso()
Combat:StartHitbox()
StartAttacksWithMode("Fast Attack")

return Combat
