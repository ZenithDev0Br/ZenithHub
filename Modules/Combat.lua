local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
-- HOOK DE ATAQUE (intercepta e expande para mobs próximos)
-- ============================================================
function Combat:StartAttackHook()
    local hooked = false
    local oldFire
    oldFire = hookmetamethod(game, "__namecall", function(self, ...)
        local ok, method = pcall(getnamecallmethod)
        if ok and method == "FireServer" and tonumber(self.Name) and not hooked then
            local args = {...}
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if S and S.FastAttack then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hooked = true
                    local folder = workspace:FindFirstChild("Enemies")
                    if folder then
                        for _, mob in pairs(folder:GetChildren()) do
                            local hum = mob:FindFirstChild("Humanoid")
                            local mobPart = mob:FindFirstChild("RightHand") or mob:FindFirstChild("UpperTorso") or mob:FindFirstChild("HumanoidRootPart")
                            if hum and hum.Health > 0 and mobPart then
                                local dist = (hrp.Position - mobPart.Position).Magnitude
                                if dist < 100 then
                                    pcall(function()
                                        self:FireServer(args[1], args[2], mobPart, {}, nil, args[6])
                                    end)
                                end
                            end
                        end
                    end
                    hooked = false
                end
            end
        end
        return oldFire(self, ...)
    end)
end

-- Método chamado pelo FarmLevel
function Combat:Attack()
    -- O hook cuida de tudo automaticamente
end

-- Inicia ao carregar
Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttackHook()

return Combat
