local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
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

    -- Busca RE/RegisterAttack dinamicamente (nome muda por sessão)
    local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
        if RegisterAttack then
            RegisterAttack:FireServer(0.5)
        end
    end)

    task.wait(attackSpeed)
end

-- Inicia ao carregar
Combat:StartBuso()
Combat:StartHitbox()

return Combat
