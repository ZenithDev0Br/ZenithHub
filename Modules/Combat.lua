local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModNet = Modules:WaitForChild("Net")
local RegisterAttack = ModNet:WaitForChild("RE/RegisterAttack")
local RegisterHit    = ModNet:WaitForChild("RE/RegisterHit")

local busoLoop   = nil
local hitboxLoop = nil

-- ============================================================
-- UTILS
-- ============================================================
local function IsAlive(char)
    return char
        and char:FindFirstChild("Humanoid")
        and char.Humanoid.Health > 0
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
            if not IsAlive(char) then continue end
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
-- FAST ATTACK (RE/RegisterAttack + RE/RegisterHit)
-- ============================================================
function Combat:StartAttackLoop()
    -- Loop 1: RegisterHit nos inimigos próximos
    task.spawn(function()
        while true do
            task.wait(0.15)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end

            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool or tool.ToolTip == "Gun" then continue end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local enemies = {}
            local basePart = nil

            for _, folder in ipairs({
                workspace:FindFirstChild("Enemies"),
                workspace:FindFirstChild("Characters")
            }) do
                if folder then
                    for _, mob in ipairs(folder:GetChildren()) do
                        local head = mob:FindFirstChild("Head")
                        if head and IsAlive(mob) and mob ~= char then
                            local dist = (hrp.Position - head.Position).Magnitude
                            if dist < 100 then
                                table.insert(enemies, { mob, head })
                                basePart = head
                            end
                        end
                    end
                end
            end

            if #enemies > 0 and basePart then
                pcall(function()
                    RegisterAttack:FireServer(0)
                    RegisterHit:FireServer(basePart, enemies)
                end)
            end
        end
    end)

    -- Loop 2: segundo disparo (cobre lag entre ticks)
    task.spawn(function()
        while true do
            task.wait(0.15)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end

            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool or tool.ToolTip == "Gun" then continue end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local enemies = {}
            local basePart = nil

            for _, folder in ipairs({
                workspace:FindFirstChild("Enemies"),
                workspace:FindFirstChild("Characters")
            }) do
                if folder then
                    for _, mob in ipairs(folder:GetChildren()) do
                        local head = mob:FindFirstChild("Head")
                        if head and IsAlive(mob) and mob ~= char then
                            local dist = (hrp.Position - head.Position).Magnitude
                            if dist < 100 then
                                table.insert(enemies, { mob, head })
                                basePart = head
                            end
                        end
                    end
                end
            end

            if #enemies > 0 and basePart then
                pcall(function()
                    RegisterAttack:FireServer(0)
                    RegisterHit:FireServer(basePart, enemies)
                end)
            end
        end
    end)

    -- Loop 3: AutoClick via VirtualUser (necessário para o servidor aceitar o hit)
    task.spawn(function()
        local VirtualUser = game:GetService("VirtualUser")
        while true do
            task.wait(0.1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end

            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end

            if char:FindFirstChildOfClass("Tool") then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(1280, 672))
                end)
            end
        end
    end)
end

-- Método chamado pelo FarmLevel (mantido por compatibilidade)
function Combat:Attack()
    -- Os loops cuidam de tudo automaticamente
end

-- Inicia ao carregar
Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttackLoop()

return Combat
