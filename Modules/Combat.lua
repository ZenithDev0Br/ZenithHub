local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")

local busoLoop  = nil
local hitboxLoop = nil
local lastAttackTime = 0
local attackCooldown = 0.12 -- Velocidade máxima segura para Remotes sem tomar Kick

-- ============================================================
-- BUSO AUTOMÁTICO
-- ============================================================
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(0.5)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            
            local isBusoActive = false
            if S and S.AutoBuso then
                isBusoActive = true
            elseif _G.SaveData and _G.SaveData["AutoBuso_Save"] then
                isBusoActive = true
            elseif _G.AutoBuso then
                isBusoActive = true
            end

            if not isBusoActive then continue end

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
-- HITBOX EXPANDER (Aplica nos Inimigos)
-- ============================================================
function Combat:StartHitbox()
    if hitboxLoop then return end
    hitboxLoop = RunService.Stepped:Connect(function()
        local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
        local hitboxSize = (S and S.HitboxSize) or (_G.SaveData and _G.SaveData["HitboxSize_Save"]) or 15
        
        local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace
        
        pcall(function()
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:IsA("BasePart") then
                        hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    end)
end

-- ============================================================
-- FAST ATTACK VIA REMOTE (KILL AURA DETECT)
-- ============================================================
function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then return end

    local weapon = character:FindFirstChildOfClass("Tool")
    if not weapon then return end -- Só ataca se tiver com a arma na mão

    -- Trava de tempo estrita para o Anticheat do Blox Fruits não dar Kick
    if os.clock() - lastAttackTime < attackCooldown then return end
    lastAttackTime = os.clock()

    pcall(function()
        -- Tenta usar o CombatFramework nativo do jogo (Ataque Fantasma Perfeito)
        local CombatFramework = require(LocalPlayer.PlayerScripts.CombatFramework)
        local ActiveController = CombatFramework.activeController
        
        if ActiveController and ActiveController.active then
            -- Força o jogo a disparar o hit físico da arma
            ActiveController.attack()
        else
            -- FALLBACK: Se o framework falhar, injeta o Remote de ataque direto no servidor
            local remote = ReplicatedStorage:FindFirstChild("Modules") 
                and ReplicatedStorage.Modules:FindFirstChild("Net") 
                and ReplicatedStorage.Modules.Net:FindFirstChild("RE/WeaponRegister")
            
            if remote then
                remote:FireServer(weapon.Name)
            end
        end
    end)
end

-- Inicia em background
Combat:StartBuso()
Combat:StartHitbox()

return Combat
