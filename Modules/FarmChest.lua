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

-- Helper de Notificação
local function EnviarNotificacao(titulo, message, tempo)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = titulo,
            Text = message,
            Duration = tempo or 5
        })
    end)
end

-- ============================================================
-- TWEEN / TELEPORTE COM NOCLIP ATIVO
-- ============================================================
local function TeleportToChest(targetCFrame)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    isTeleporting = true
    
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
-- SERVER HOP PUBLIC
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
-- PROCURAR BAÚS INTERNOS (CHESTMODELS)
-- ============================================================
local function GetClosestChest()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end

    local closestChestModel = nil
    local closestChestCFrame = nil
    local shortestDistance = math.huge

    local chestModelsFolder = Workspace:FindFirstChild("ChestModels")
    local targets = chestModelsFolder and chestModelsFolder:GetChildren() or Workspace:GetDescendants()

    for i = 1, #targets do
        local obj = targets[i]
        
        if obj:IsA("Model") and string.find(obj.Name, "Chest") and not obj:GetAttribute("Collected") then
            local primary = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart") or obj:FindFirstChild("Part")
            
            if primary and primary.Transparency < 1 then
                local dist = (primary.Position - hrp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestChestModel = obj
                    closestChestCFrame = primary.CFrame
                end
            end
        end
    end

    return closestChestCFrame, closestChestModel
end

-- ============================================================
-- VERIFICAÇÃO DE ITEM RARO
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
-- LOOP PRINCIPAL
-- ============================================================
function FarmChest:Start()
    if self.Enabled then return end
    self.Enabled = true
    chestsCollectedThisSession = 0

    chestLoop = task.spawn(function()
        while self.Enabled do
            task.wait(0.05)

            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            local isNormalActive = S and S.AutoFarmChest
            local isHopActive = S and S.AutoFarmChestHop
            
            if not isNormalActive then break end

            if S and S.StopWithItem and HasRareItem() then
                EnviarNotificacao("Zenith Hub", "Item raro detectado! Farm parado.", 7)
                break
            end

            -- Checagem Real do Limite do Slider da UI
            local maxChests = S and S.AmountChest or 30
            if chestsCollectedThisSession >= maxChests then
                EnviarNotificacao("Zenith Hub", "Limite real de baús atingido: " .. tostring(maxChests), 5)
                break
            end

            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
                continue 
            end

            -- Retorna a CFrame e a instância do modelo do baú
            local targetCFrame, targetModel = GetClosestChest()

            if targetCFrame and targetModel then
                TeleportToChest(targetCFrame)
                
                -- Marca o baú como coletado localmente para o loop ignorar ele imediatamente
                targetModel:SetAttribute("Collected", true)
                
                -- Soma +1 real na contagem geral e dá um cooldown para o baú sumir da memória
                chestsCollectedThisSession = chestsCollectedThisSession + 1
                task.wait(0.25) 
            else
                if not isTeleporting then
                    if isHopActive then
                        EnviarNotificacao("Zenith Hub", "Teleport in 10 minutes", 5)
                        task.wait(2)
                        pcall(HopServer)
                        task.wait(5)
                    else
                        -- Se não achou nada e o HOP tá desligado, dorme 3 segundos para economizar CPU
                        task.wait(3)
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
    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

return FarmChest
