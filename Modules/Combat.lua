local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Net = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Net:WaitForChild("CommF_")

local busoLoop  = nil
local hitboxLoop = nil

-- ============================================================
-- BUSO AUTOMÁTICO (CORRIGIDO)
-- ============================================================
function Combat:StartBuso()
    if busoLoop then return end
    busoLoop = task.spawn(function()
        while true do
            task.wait(0.5) -- Checagem a cada meio segundo é suficiente e poupa memória
            
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            
            -- Detecta se o AutoBuso está ligado na UI ou nas tabelas globais
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
            
            -- Se não estiver com o Haki ativo, invoca o servidor
            if not char:FindFirstChild("HasBuso") then
                pcall(function()
                    CommF:InvokeServer("Buso")
                end)
            end
        end
    end)
end

-- ============================================================
-- HITBOX EXPANDER (CORRIGIDO: APLICA NOS INIMIGOS)
-- ============================================================
function Combat:StartHitbox()
    if hitboxLoop then return end
    
    hitboxLoop = RunService.Stepped:Connect(function()
        local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
        
        -- Verifica se a Hitbox está ativa ou se usa tamanho padrão (Zyn Hub costuma usar BringMob, mas isso ajuda se faltar mob)
        local hitboxSize = (S and S.HitboxSize) or (_G.SaveData and _G.SaveData["HitboxSize_Save"]) or 15
        
        local enemiesFolder = Workspace:FindFirstChild("Enemies") or Workspace
        
        pcall(function()
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:IsA("BasePart") then
                        -- Expande a caixa de colisão do monstro com segurança para o clique acertar de longe
                        hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    end)
end

-- ============================================================
-- FAST ATTACK INSTANTÂNEO (MOBILE - CORRIGIDO SEM WAIT)
-- ============================================================
function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then return end

    -- Verifica se o player está segurando alguma ferramenta (arma/estilo de luta) antes de clicar
    if not character:FindFirstChildOfClass("Tool") then return end

    pcall(function()
        -- Envia os eventos de Touch iniciar e encerrar na mesma execução para clipping instantâneo
        VirtualInputManager:SendTouchEvent(0, Vector2.new(450, 250), true, game)
        VirtualInputManager:SendTouchEvent(0, Vector2.new(450, 250), false, game)
    end)
end

-- Inicia as escutas em background ao carregar o módulo
Combat:StartBuso()
Combat:StartHitbox()

return Combat
