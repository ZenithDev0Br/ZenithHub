local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommE = Remotes:WaitForChild("CommE")
local CommF = Remotes:WaitForChild("CommF_")

-- ============================================================
-- BUSO AUTOMÁTICO
-- ============================================================
local function HasBuso()
    local char = LocalPlayer.Character
    return char and CollectionService:HasTag(char, "Buso")
end

local busoLoop = nil
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(0.2)
            local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (Settings and Settings.AutoBuso) then continue end
            if not HasBuso() then
                pcall(function()
                    CommE:FireServer("Buso", true)
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
-- FAST ATTACK
-- ============================================================
function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or character.Humanoid.Health <= 0 then return end

    local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local attackSpeed = Settings and Settings.AttackSpeed or 0.1

    pcall(function()
        CommF:InvokeServer("Attack", 0)
    end)

    task.wait(attackSpeed)
end

-- Inicia ao carregar o módulo
Combat:StartBuso()
Combat:StartHitbox()

return Combat
