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

-- Helper para mandar notificação nativa do Roblox na tela
local function EnviarNotificacao(titulo, mensagem, tempo)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = titulo,
            Text = mensagem,
            Duration = tempo or 5
        })
    end)
end

-- ============================================================
-- FUNÇÃO DE TELEPORTE / TWEEN OTIMIZADA (Com Noclip Real)
-- ============================================================
local function TeleportToChest(targetCFrame)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    isTeleporting = true
    
    -- Ativa o Noclip em background para o boneco atravessar tudo sem travar
    local noclipConnection
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if not isTeleporting or not character then
            if noclipConnection then noclipConnection:Disconnect() end
            return
        end
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
    
    if noclipConnection then noclipConnection:Disconnect() end
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
-- ENCONTRAR O BAÚ MAIS PRÓXIMO (SISTEMA DE VARREDURA INTEGRAL)
-- ============================================================
local function GetClosestChest()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestChest = nil
    local shortestDistance = math.huge

    -- Varre absolutamente tudo criado dentro do Workspace (Pastas, Ilhas, Modelos)
    local descendants = Workspace:GetDescendants()
    
    for i = 1, #descendants do
        local obj = descendants[i]
        -- Verifica se é uma BasePart e se o nome contém "Chest" (Ex: Chest1, Chest2, Chest3, Chest_Silver)
        if obj:IsA("BasePart") and string.find(obj.Name, "Chest") then
            -- Ignora apenas baús invisíveis de decoração (RootParts ou triggers)
            if obj.Transparency < 1 then
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
    print("[ZenithHub] Loop de monitoramento de baús ativado.")

    chestLoop = task.spawn(function()
        while self.Enabled do
            task.wait(0.1) -- Delay leve para evitar uso desnecessário de CPU no loop

            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            
            -- Checa se o Toggle principal "Auto Farm Chest" está ligado na UI
            local isNormalActive = S and S.AutoFarmChest
            local isHopActive = S and S.AutoFarmChestHop
            
            if not isNormalActive then 
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

            -- Executa a busca profunda pelo baú mais perto
            local targetChest = GetClosestChest()

            if targetChest and targetChest.Parent then
                print("[ZenithHub] Baú encontrado! Teleportando para: " .. targetChest.Name)
                TeleportToChest(targetChest.CFrame)
                task.wait(0.2) -- Garante que o Roblox registre o toque físico e te dê o dinheiro
                chestsCollectedThisSession = chestsCollectedThisSession + 1
            else
                -- Se não achou nenhum baú no mapa inteiro
                if not isTeleporting then
                    if isHopActive then
                        EnviarNotificacao("Zenith Hub", "Teleport in 10 minutes", 5)
                        task.wait(2) -- Delay estratégico para a notificação aparecer antes do kick do Hop
                        pcall(HopServer)
                        task.wait(5)
                    else
                        print("[ZenithHub] Nenhum baú disponível no mapa. Aguardando respawn...")
                        task.wait(4) -- Espera 4 segundos antes de checar o mapa de novo
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

    -- Devolve colisões normais do corpo
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
