local FarmChest = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local chestLoop = nil
local isTeleporting = false

-- ============================================================
-- FUNÇÃO DE TELEPORTE / TWEEN OTIMIZADA (Igual ao seu Core)
-- ============================================================
local function TeleportToChest(targetCFrame)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    isTeleporting = true
    
    -- Ignora colisões para não prender no mapa
    pcall(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)

    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local speed = 300 -- Velocidade segura para não tomar Kick por Teleport
    local tweenTime = distance / speed

    local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    isTeleporting = false
end

-- ============================================================
-- SISTEMA AUTOMÁTICO DE SERVER HOP (Troca de Servidor se acabar)
-- ============================================================
local function HopServer()
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(api))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                end)
                task.wait(2)
            end
        end
    end
end

-- ============================================================
-- ENCONTRAR O BAÚ MAIS PRÓXIMO NO MAPA
-- ============================================================
local function GetClosestChest()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestChest = nil
    local shortestDistance = math.huge

    -- Procura baús instanciados no Workspace
    for _, obj in ipairs(Workspace:GetChildren()) do
        if string.find(obj.Name, "Chest") and obj:IsA("Part") then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestChest = obj
            end
        end
    end

    -- Fallback: Caso o jogo jogue os baús em pastas específicas do mapa
    if not closestChest then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if string.find(obj.Name, "Chest") and obj:IsA("Part") and not obj:SetAttribute("Collected") then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestChest = obj
                end
            end
        end
    end

    return closestChest
end

-- ============================================================
-- CONTROLE DE INÍCIO DO FARM DE BAÚS
-- ============================================================
function FarmChest:Start()
    if chestLoop then return end

    _[span_1](start_span)G.AutoFarmChest = true[span_1](end_span) -[span_2](start_span)- Registra globalmente nas flags do seu Hub[span_2](end_span)

    chestLoop = task.spawn(function()
        while _G.AutoFarmChest do
            task.wait(0.1)

            -- Verifica as configurações da sua UI (ZenithHub) ou Toggles Globais
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            local isActive = _G.AutoFarmChest or (S and S.AutoFarmChest)

            if not isActive then continue end

            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then continue end

            -- Localiza o baú mais perto
            local targetChest = GetClosestChest()

            if targetChest and targetChest.Parent then
                -- Executa o Tween até o baú
                TeleportToChest(targetChest.CFrame)
                
                -- Pequena folga para registrar a colisão e coletar o dinheiro
                task.wait(0.2)
            else
                -- Se não existirem mais baús no mapa, inicia o Server Hop automaticamente
                if not isTeleporting then
                    pcall(function()
                        HopServer()
                    end)
                    task.wait(5) -- Evita spam de requisições HTTP caso o teleport demore
                end
            end
        end
    end)
end

-- ============================================================
-- PARAR O FARM DE BAÚS
-- ============================================================
function FarmChest:Stop()
    _G.AutoFarmChest = false
    if chestLoop then
        task.cancel(chestLoop)
        chestLoop = nil
    end
end

return FarmChest

