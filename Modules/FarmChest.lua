local FarmChest = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local chestLoop = nil
local isTeleporting = false
local chestsCollectedThisSession = 0

-- ============================================================
-- FUNÇÃO DE TELEPORTE / TWEEN OTIMIZADA
-- ============================================================
local function TeleportToChest(targetCFrame)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    isTeleporting = true
    
    pcall(function()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)

    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local speed = (S and S.TweenSpeed) or (_G.SaveData and _G.SaveData["TweenSpeed_Save"]) or 350
    local tweenTime = distance / speed

    local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    
    isTeleporting = false
end

-- ============================================================
-- SISTEMA AUTOMÁTICO DE SERVER HOP
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
                task.wait(1)
                if game.JobId ~= game.JobId then break end
            end
        end
    end
end

-- ============================================================
-- ENCONTRAR O BAÚ MAIS PRÓXIMO
-- ============================================================
local function GetClosestChest()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestChest = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and (string.find(obj.Name, "Chest") or string.find(obj.Name, "Chest1") or string.find(obj.Name, "Chest2") or string.find(obj.Name, "Chest3")) then
            if obj.Transparency < 1 and obj.Size.Magnitude > 1 then
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
-- VERIFICAÇÃO DE ITENS RAROS (STOP WITH ITEM)
-- ============================================================
local function HasRareItem()
    -- Verifica na Mochila (Backpack) e na mão do personagem (Character)
    local items = { "Fist of Darkness", "God's Chalice", "Punho da Escuridão", "Cálice de Deus" }
    
    for _, itemName in ipairs(items) do
        if LocalPlayer.Backpack:FindFirstChild(itemName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName)) then
            return true
        end
    end
    return false
end

-- ============================================================
-- CONTROLADORES PRINCIPAIS (START / STOP)
-- ============================================================
function FarmChest:Start()
    if self.Enabled then return end
    self.Enabled = true
    chestsCollectedThisSession = 0

    chestLoop = task.spawn(function()
        while self.Enabled do
            task.wait(0.05)

            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            
            -- O farm roda se o Chest Normal OU o Chest HOP estiverem ativos na UI
            local isNormalActive = S and S.AutoFarmChest
            local isHopActive = S and S.AutoFarmChestHop
            
            if not isNormalActive and not isHopActive then 
                break 
            end

            -- PROTEÇÃO: Stop With Item
            if S and S.StopWithItem and HasRareItem() then
                print("[ZenithHub] Item raro detectado! Parando Farm Chest de segurança.")
                break
            end

            -- PROTEÇÃO: Amount Chest Limiter
            local maxChests = S and S.AmountChest or 30
            if chestsCollectedThisSession >= maxChests then
                print("[ZenithHub] Limite de baús atingido nesta sessão ("..tostring(maxChests).."). Parando.")
                break
            end

            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
                continue 
            end

            local targetChest = GetClosestChest()

            if targetChest and targetChest.Parent then
                TeleportToChest(targetChest.CFrame)
                task.wait(0.15)
                chestsCollectedThisSession = chestsCollectedThisSession + 1
            else
                -- LÓGICA DE FIM DE MAPA
                if not isTeleporting then
                    if isHopActive then
                        print("[ZenithHub] Baús esgotados. Iniciando Server Hop...")
                        pcall(HopServer)
                        task.wait(3)
                    else
                        -- Se for o farm normal, espera 5 segundos antes de procurar respawn
                        print("[ZenithHub] Sem baús no mapa. Aguardando respawn...")
                        task.wait(5)
                    end
                end
            end
        end
        
        self:Stop()
    end)
end

function FarmChest:Stop()
    self.Enabled = false
    
    -- Desliga os Toggles visualmente na tabela de settings da UI
    local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    if S then
        S.AutoFarmChest = false
        S.AutoFarmChestHop = false
    end
    
    if chestLoop then
        task.cancel(chestLoop)
        chestLoop = nil
    end

    -- Restaura colisões normais do corpo
    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
    print("[ZenithHub] Módulo FarmChest Parado.")
end

return FarmChest
