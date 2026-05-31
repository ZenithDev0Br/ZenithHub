local Esp = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espConnection = nil

-- Cache para evitar criar tabelas vazias toda hora na memória
local v3_zero = Vector3.new(0, 0, 0)

local function S()
    return getgenv().ZenithHub and getgenv().ZenithHub.Modules and getgenv().ZenithHub.Modules.FarmSettings
end

-- ============================================================
-- RENDERIZADOR ULTRA OTIMIZADO
-- ============================================================
local function AplicarEspGenerico(obj, nomeExibicao, cor, tagUnica)
    if not obj or obj:FindFirstChild(tagUnica) then return end

    -- Pega a parte física sem usar loops pesados
    local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")) or obj
    if not primary or not primary:IsA("BasePart") then return end

    local folder = Instance.new("Folder")
    folder.Name = tagUnica
    folder.Parent = obj

    -- Highlight nativo (Super otimizado pelo motor do Roblox)
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillColor = cor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Adornee = obj
    highlight.Parent = folder

    -- Billboard estático (A distância é calculada sem recriar objetos)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Billboard"
    billboard.Size = UDim2.new(0, 140, 0, 35)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = primary
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = cor
    label.TextStrokeTransparency = 0.2
    label.TextSize = 11
    label.Font = Enum.Font.SourceSansBold
    label.Text = nomeExibicao
    label.Parent = billboard
    
    label:SetAttribute("BaseName", nomeExibicao)
end

local function LimparEspEspecifico(tagUnica, escopo)
    local alvos = escopo or Workspace:GetChildren()
    for i = 1, #alvos do
        local obj = alvos[i]
        local esp = obj and obj:FindFirstChild(tagUnica)
        if esp then esp:Destroy() end
    end
end

-- ============================================================
-- ATUALIZADOR DE DISTÂNCIA CIRÚRGICO (SEM ALOCAÇÃO DE MEMÓRIA)
-- ============================================================
local function AtualizarDistancias()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local pos = hrp.Position

    -- 1. Atualiza Baús direto da pasta deles (Rápido)
    local chestFolder = Workspace:FindFirstChild("ChestModels")
    if chestFolder then
        local children = chestFolder:GetChildren()
        for i = 1, #children do
            local obj = children[i]
            local esp = obj:FindFirstChild("ZenithChestESP")
            local billboard = esp and esp:FindFirstChild("Billboard")
            local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
            if label and billboard.Adornee then
                local dist = math.floor((billboard.Adornee.Position - pos).Magnitude)
                label.Text = string.format("%s\n[%sm]", label:GetAttribute("BaseName") or obj.Name, tostring(dist))
            end
        end
    end

    -- 2. Atualiza Players
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local p = allPlayers[i]
        if p ~= LocalPlayer and p.Character then
            local esp = p.Character:FindFirstChild("ZenithPlayerESP")
            local billboard = esp and esp:FindFirstChild("Billboard")
            local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
            if label and billboard.Adornee then
                local dist = math.floor((billboard.Adornee.Position - pos).Magnitude)
                label.Text = string.format("%s\n[%sm]", label:GetAttribute("BaseName") or p.Name, tostring(dist))
            end
        end
    end

    -- 3. Atualiza Frutas e Flores no Workspace Principal
    local rootChildren = Workspace:GetChildren()
    for i = 1, #rootChildren do
        local obj = rootChildren[i]
        for _, tag in ipairs({"ZenithFruitESP", "ZenithFlowerESP", "ZenithIslandESP"}) do
            local esp = obj:FindFirstChild(tag)
            local billboard = esp and esp:FindFirstChild("Billboard")
            local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
            if label and billboard.Adornee then
                local dist = math.floor((billboard.Adornee.Position - pos).Magnitude)
                label.Text = string.format("%s\n[%sm]", label:GetAttribute("BaseName") or obj.Name, tostring(dist))
            end
        end
    end
end

-- ============================================================
-- LOOP PRINCIPAL DE VERIFICAÇÃO ESCALONADA
-- ============================================================
function Esp:Start()
    if self.Enabled then return end
    self.Enabled = true

    local frameCount = 0
    espConnection = RunService.Heartbeat:Connect(function()
        local s = S()
        if not s then return end

        frameCount = frameCount + 1
        
        -- Distâncias atualizam liso, mas as buscas por novos itens são divididas por tempo
        AtualizarDistancias()

        -- Roda a cada 60 frames (Aprox. 1 segundo) - Otimização de Baús, Players e Frutas
        if frameCount % 60 == 0 then
            if s.EspChest then
                local folder = Workspace:FindFirstChild("ChestModels")
                if folder then
                    local items = folder:GetChildren()
                    for i = 1, #items do
                        local obj = items[i]
                        if string.find(obj.Name, "Chest") then
                            AplicarEspGenerico(obj, obj.Name, Color3.fromRGB(255, 185, 0), "ZenithChestESP")
                        end
                    end
                end
            else
                local folder = Workspace:FindFirstChild("ChestModels")
                if folder then LimparEspEspecifico("ZenithChestESP", folder:GetChildren()) end
            end

            if s.EspPlayers then
                local plist = Players:GetPlayers()
                for i = 1, #plist do
                    local p = plist[i]
                    if p ~= LocalPlayer and p.Character then
                        AplicarEspGenerico(p.Character, p.DisplayName or p.Name, Color3.fromRGB(0, 200, 255), "ZenithPlayerESP")
                    end
                end
            else
                LimparEspEspecifico("ZenithPlayerESP", Workspace:GetChildren())
            end

            if s.EspFruits then
                local rItems = Workspace:GetChildren()
                for i = 1, #rItems do
                    local obj = rItems[i]
                    if (obj:IsA("Tool") or obj:IsA("Model")) and (string.find(obj.Name, "Fruit") or obj:FindFirstChild("Handle")) then
                        if obj:FindFirstChild("Handle") and not Players:GetPlayerFromCharacter(obj.Parent) then
                            AplicarEspGenerico(obj, "🍎 " .. obj.Name:gsub("Fruit", ""), Color3.fromRGB(180, 0, 255), "ZenithFruitESP")
                        end
                    end
                end
            else
                LimparEspEspecifico("ZenithFruitESP", Workspace:GetChildren())
            end
        end

        -- Roda a cada 120 frames (Aprox. 2 segundos) - Varreduras lentas para coisas fixas (Flores, Ilhas e Gear)
        if frameCount % 120 == 0 then
            if s.EspFlower then
                local rItems = Workspace:GetChildren()
                for i = 1, #rItems do
                    local obj = rItems[i]
                    if string.find(obj.Name, "Flower1") or string.find(obj.Name, "Flower2") then
                        local isRed = string.find(obj.Name, "Flower1")
                        local cor = isRed and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(30, 80, 255)
                        local nome = isRed and "🌸 Flor Vermelha" or "🔷 Flor Azul"
                        AplicarEspGenerico(obj, nome, cor, "ZenithFlowerESP")
                    end
                end
            else
                LimparEspEspecifico("ZenithFlowerESP", Workspace:GetChildren())
            end

            if s.EspIslands then
                local islandFolder = Workspace:FindFirstChild("SeaIslands") or Workspace
                local islands = islandFolder:GetChildren()
                for i = 1, #islands do
                    local obj = islands[i]
                    if obj:IsA("Model") and (string.find(obj.Name, "Mirage") or string.find(obj.Name, "Island")) then
                        AplicarEspGenerico(obj, "🏝️ " .. obj.Name, Color3.fromRGB(0, 255, 120), "ZenithIslandESP")
                    end
                end
            else
                local islandFolder = Workspace:FindFirstChild("SeaIslands")
                LimparEspEspecifico("ZenithIslandESP", islandFolder and islandFolder:GetChildren() or Workspace:GetChildren())
            end

            -- O ÚNICO que ainda precisa do GetDescendants (Gear da Mirage), mas agora roda super espaçado!
            if s.EspGear then
                local desc = Workspace:GetDescendants()
                for i = 1, #desc do
                    local obj = desc[i]
                    if obj:IsA("BasePart") and obj.Name == "Gear" then
                        AplicarEspGenerico(obj, "⚙️ Blue Gear V4", Color3.fromRGB(255, 50, 50), "ZenithGearESP")
                    end
                end
            else
                -- Limpa da memória sem revirar o mapa
                for _, p in ipairs(Workspace:GetChildren()) do
                    local esp = p:FindFirstChild("ZenithGearESP") or p:IsA("BasePart") and p:FindFirstChild("ZenithGearESP")
                    if esp then esp:Destroy() end
                end
            end
            
            -- Reseta o contador para evitar estouro numérico
            frameCount = 0
        end
    end)
end

function Esp:Stop()
    self.Enabled = false
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    local root = Workspace:GetChildren()
    local chestF = Workspace:FindFirstChild("ChestModels")
    
    LimparEspEspecifico("ZenithChestESP", chestF and chestF:GetChildren() or root)
    LimparEspEspecifico("ZenithPlayerESP", root)
    LimparEspEspecifico("ZenithFruitESP", root)
    LimparEspEspecifico("ZenithFlowerESP", root)
    LimparEspEspecifico("ZenithIslandESP", root)
    
    -- Limpeza total forçada de segurança
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.find(obj.Name, "Zenith") then obj:Destroy() end
    end
end

-- Gerenciador inteligente em background
task.spawn(function()
    while true do
        local s = S()
        if s and (s.EspChest or s.EspPlayers or s.EspFruits or s.EspFlower or s.EspIslands or s.EspGear) then
            if not Esp.Enabled then Esp:Start() end
        else
            if Esp.Enabled then Esp:Stop() end
        end
        task.wait(1)
    end
end)

return Esp
