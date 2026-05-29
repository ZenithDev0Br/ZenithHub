local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommE = Remotes:WaitForChild("CommE")
local CommF = Remotes:WaitForChild("CommF_")

-- ============================================================
-- BUSO AUTOMÁTICO (método correto do Zyn Hub original)
-- ============================================================
local busoLoop = nil
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(0.1)
            local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (Settings and Settings.AutoBuso) then continue end

            local char = LocalPlayer.Character
            if not char or char.Humanoid.Health <= 0 then continue end

            -- Verifica pela part "HasBuso" no personagem, igual ao Zyn Hub original
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
local hitboxLoop = nil
function Combat:StartHitbox()
    if hitboxLoop then return end
    hitboxLoop = RunService.Stepped:Connect(function()
        local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
        local hitboxSize = Settings and Settings.HitboxSize or 15

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
-- FAST ATTACK (VirtualInputManager)
-- ============================================================
function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or character.Humanoid.Health <= 0 then return end

    local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local attackSpeed = Settings and Settings.AttackSpeed or 0.1

    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)

    task.wait(attackSpeed)
end

-- Inicia ao carregar o módulo
Combat:StartBuso()
Combat:StartHitbox()

return Combat
