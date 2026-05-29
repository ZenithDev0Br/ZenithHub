local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")

-- Remotes do fast attack igual ao Zyn Hub original
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit    = Net:WaitForChild("RE/RegisterHit")

local fastAttackLoop1 = nil
local fastAttackLoop2 = nil
local autoClickLoop   = nil
local busoLoop        = nil
local hitboxLoop      = nil

local AttackDelays = {
    ["Normal Attack"]    = 0.25,
    ["Fast Attack"]      = 0.15,
    ["Super Attack"]     = 0.05,
    ["Bear Attack"]      = 0.1,
    ["Super Bear Attack"]= 0.01,
}

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
                    table.insert(OthersEnemies, { enemy, head })
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
    if fastAttackLoop1 then task.cancel(fastAttackLoop1); fastAttackLoop1 = nil end
    if fastAttackLoop2 then task.cancel(fastAttackLoop2); fastAttackLoop2 = nil end
    if autoClickLoop   then task.cancel(autoClickLoop);   autoClickLoop   = nil end
end

-- ============================================================
-- FAST ATTACK (igual ao Zyn Hub — RegisterAttack + RegisterHit)
-- ============================================================
function Combat:StartAttack()
    StopAllAttacks()

    local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local mode = "Fast Attack"
    local delayTime = AttackDelays[mode]
    local distance = 100

    -- Loop 1: RegisterAttack + RegisterHit (alcance infinito)
    fastAttackLoop1 = task.spawn(function()
        while true do
            task.wait(delayTime)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end
            local char = LocalPlayer.Character
            if not char or not IsAlive(char) then continue end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool.ToolTip ~= "Gun" then
                local enemies, basePart = GetNearestEnemies(distance)
                if #enemies > 0 and basePart then
                    pcall(function()
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(basePart, enemies)
                    end)
                end
            end
        end
    end)

    -- Loop 2: segundo loop igual ao Zyn Hub para garantir o hit
    fastAttackLoop2 = task.spawn(function()
        while true do
            task.wait(delayTime)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.FastAttack) then continue end
            local char = LocalPlayer.Character
            if not char or not IsAlive(char) then continue end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool.ToolTip ~= "Gun" then
                local enemies, basePart = GetNearestEnemies(distance)
                if #enemies > 0 and basePart then
                    pcall(function()
                        RegisterAttack:FireServer(0)
                        RegisterHit:FireServer(basePart, enemies)
                    end)
                end
            end
        end
    end)

    -- Loop 3: VirtualUser click para disparar animação
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

-- Método Attack chamado pelo FarmLevel (mantém compatibilidade)
function Combat:Attack()
    -- O ataque agora é feito pelos loops contínuos do StartAttack
    -- Esse método fica vazio pois os loops já cuidam de tudo
end

-- Inicia tudo ao carregar
Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttack()

return Combat
