local Esp = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espConnection = nil

-- Helper para pegar as configurações da UI
local function S()
    return getgenv().ZenithHub and getgenv().ZenithHub.Modules and getgenv().ZenithHub.Modules.FarmSettings
end

-- ============================================================
-- FUNÇÃO CORE: GERADOR DE ESP PADRÃO (OTIMIZADO)
-- ============================================================
local function AplicarEspGenerico(obj, nomeExibicao, cor, tagUnica)
    if not obj or obj:FindFirstChild(tagUnica) then return end

    local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
    if not primary or not primary:IsA("BasePart") then return end

    local folder = Instance.new("Folder")
    folder.Name = tagUnica
    folder.Parent = obj

    -- Caixa / Silhueta
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillColor = cor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = obj
    highlight.Parent = folder

    -- Texto flutuante
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Billboard"
    billboard.Size = UDim2.new(0, 160, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = primary
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = cor
    label.TextStrokeTransparency = 0
    label.TextSize = 12
    label.Font = Enum.Font.SourceSansBold
    label.Text = nomeExibicao
    label.Parent = billboard
end

local function LimparEspEspecifico(tagUnica, escopo)
    local targets = escopo or Workspace:GetDescendants()
    for _, obj in ipairs(targets) do
        local esp = obj:FindFirstChild(tagUnica)
        if esp then esp:Destroy() end
    end
end

-- ============================================================
-- ATUALIZAÇÃO DINÂMICA DE DISTÂNCIAS
-- ============================================================
local function AtualizarDistancias()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Loop por todos os Billboards criados pelo ZenithHub para atualizar distância
    for _, obj in ipairs(Workspace:GetDescendants()) do
        for _, tag in ipairs({"ZenithChestESP", "ZenithPlayerESP", "ZenithFruitESP", "ZenithFlowerESP", "ZenithIslandESP", "ZenithGearESP"}) do
            local esp = obj:FindFirstChild(tag)
            local billboard = esp and esp:FindFirstChild("Billboard")
            local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
            
            if label and billboard.Adornee then
                local dist = math.floor((billboard.Adornee.Position - hrp.Position).Magnitude)
                -- Mantém o nome original e adiciona a distância embaixo
                local nomeBase = label:GetAttribute("BaseName") or label.Text:split("\n")[1]
                if not label:GetAttribute("BaseName") then label:SetAttribute("BaseName", nomeBase) end
                
                label.Text = string.format("%s\n[%sm]", nomeBase, tostring(dist))
            end
        end
    end
end

-- ============================================================
-- CONTROLADORES DE VARREDURA (FRAMEWORK HEARTBEAT)
-- ============================================================
function Esp:Start()
    if self.Enabled then return end
    self.Enabled = true

    local contador = 0
    espConnection = RunService.Heartbeat:Connect(function()
        local s = S()
        if not s then return end

        contador = contador + 1
        
        -- Varredura a cada 45 frames para gerenciar novos spawns sem travar o celular
        if contador % 45 == 0 then
            
            -- 1. ESP CHEST
            if s.EspChest then
                local folder = Workspace:FindFirstChild("ChestModels")
                local targets = folder and folder:GetChildren() or Workspace:GetDescendants()
                for _, obj in ipairs(targets) do
                    if obj:IsA("Model") and string.find(obj.Name, "Chest") then
                        AplicarEspGenerico(obj, obj.Name, Color3.fromRGB(255, 185, 0), "ZenithChestESP")
                    end
                end
            else
                LimparEspEspecifico("ZenithChestESP")
            end

            -- 2. ESP PLAYERS
            if s.EspPlayers then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        AplicarEspGenerico(p.Character, p.DisplayName or p.Name, Color3.fromRGB(0, 200, 255), "ZenithPlayerESP")
                    end
                end
            else
                LimparEspEspecifico("ZenithPlayerESP")
            end

            -- 3. ESP FRUITS
            if s.EspFruits then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) and (string.find(obj.Name, "Fruit") or obj:FindFirstChild("Handle")) then
                        if obj:FindFirstChild("Handle") and not Players:GetPlayerFromCharacter(obj.Parent) then
                            AplicarEspGenerico(obj, "🍎 " .. obj.Name:gsub("Fruit", ""), Color3.fromRGB(180, 0, 255), "ZenithFruitESP")
                        end
                    end
                end
            else
                LimparEspEspecifico("ZenithFruitESP", Workspace:GetChildren())
            end

            -- 4. ESP FLOWER (Quest V2) -- NOVO!
            if s.EspFlower then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if string.find(obj.Name, "Flower1") or string.find(obj.Name, "Flower2") then
                        local cor = string.find(obj.Name, "Flower1") and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 50, 255)
                        local nome = string.find(obj.Name, "Flower1") and "🌸 Flores Vermelha" or "🔷 Flores Azul"
                        AplicarEspGenerico(obj, nome, cor, "ZenithFlowerESP")
                    end
                end
            else
                LimparEspEspecifico("ZenithFlowerESP", Workspace:GetChildren())
            end

            -- 5. ESP ISLANDS (Mirage / Sea Events) -- NOVO!
            if s.EspIslands then
                -- Procura no Workspace e na pasta de mapas do mar
                local localedIslands = Workspace:FindFirstChild("SeaIslands") or Workspace
                for _, obj in ipairs(localedIslands:GetChildren()) do
                    if obj:IsA("Model") and (string.find(obj.Name, "Mirage") or string.find(obj.Name, "Island")) then
                        AplicarEspGenerico(obj, "🏝️ " .. obj.Name, Color3.fromRGB(0, 255, 100), "ZenithIslandESP")
                    end
                end
            else
                LimparEspEspecifico("ZenithIslandESP")
            end

            -- 6. ESP GEAR (Engrenagem do V4 na Mirage) -- NOVO!
            if s.EspGear then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(obj.Name, "Gear") then
                        AplicarEspGenerico(obj, "⚙️ Blue Gear V4", Color3.fromRGB(255, 50, 50), "ZenithGearESP")
                    end
                end
            else
                LimparEspEspecifico("ZenithGearESP")
            end

        end

        AtualizarDistancias()
    end)
end

function Esp:Stop()
    self.Enabled = false
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    LimparEspEspecifico("ZenithChestESP")
    LimparEspEspecifico("ZenithPlayerESP")
    LimparEspEspecifico("ZenithFruitESP")
    LimparEspEspecifico("ZenithFlowerESP")
    LimparEspEspecifico("ZenithIslandESP")
    LimparEspEspecifico("ZenithGearESP")
end

-- Monitor global ativo em background
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
