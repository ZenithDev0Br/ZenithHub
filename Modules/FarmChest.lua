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

-- Helper para mandar notificação usando a Redz Library instalada na sua UI
local function EnviarNotificacao(titulo, mensagem, tempo)
    pcall(function()
        -- Tenta usar o próprio sistema de notificação do jogo ou do hub
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = titulo,
            Text = mensagem,
            Duration = tempo or 5
        })
    end)
end

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
            
            -- REGRA REQUISITADA: O farm SÓ roda se o "Auto Farm Chest" principal estiver ligado!
            local isNormalActive = S and S.AutoFarmChest
            local isHopActive = S and S.AutoFarmChestHop
            
            if not isNormalActive then 
                -- Se o farm principal desligar, desliga tudo
                break 
            end

            -- PROTEÇÃO: Stop With Item
            if S and S.StopWithItem and HasRareItem() then
                EnviarNotificacao("Zenith Hub", "Item raro detectado! Parando Farm por segurança.", 7)
                break
            end

            -- PROTEÇÃO: Amount Chest Limiter
            local maxChests = S and S.AmountChest or 30
            if chestsCollectedThisSession >= maxChests then
                EnviarNotificacao("Zenith Hub", "Limite de baús atingido nesta sessão.", 5)
                break
            end

            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
                continue 
            end

            local targetChest = GetClosestChest()

            if targetChest and targetChest.Parent then
                -- Teleporta e coleta
                TeleportToChest(targetChest.CFrame)
                task.wait(0.15)
                chestsCollectedThisSession = chestsCollectedThisSession + 1
            else
                -- LÓGICA DE FIM DE BAÚS NO MAPA
                if not isTeleporting then
                    -- REGRA REQUISITADA: Só faz Hop se o botão de Hop estiver ligado JUNTO com o Auto Farm Chest
                    if isHopActive then
                        -- Envia a notificação que você pediu antes de pular de servidor
                        EnviarNotificacao("Zenith Hub", "Teleport in 10 minutes", 5)
                        
                        print("[ZenithHub] Baús esgotados. Aguardando timer para Server Hop...")
                        task.wait(5) -- Pequeno delay de segurança antes de forçar o teleport
                        
                        pcall(HopServer)
                        task.wait(3)
                    else
                        -- Se o Hop estiver desligado, apenas aguarda o respawn normal dos baús no mesmo servidor
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
    print("[ZenithHub] Módulo FarmChest totalmente parado.")
end

return FarmChest
