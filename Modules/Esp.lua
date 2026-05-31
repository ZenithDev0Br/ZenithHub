local Esp = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espConnection = nil

-- Helpers para pegar as configurações da UI
local function S()
    return getgenv().ZenithHub and getgenv().ZenithHub.Modules and getgenv().ZenithHub.Modules.FarmSettings
end

-- ============================================================
-- FUNÇÕES DE LIMPEZA E CRIAÇÃO INDIVIDUAL (BAÚS)
-- ============================================================
local function CriarChestEsp(model)
    if model:FindFirstChild("ZenithChestESP") then return end

    local folder = Instance.new("Folder")
    folder.Name = "ZenithChestESP"
    folder.Parent = model

    -- Silhueta Amarela/Dourada através das paredes
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillColor = Color3.fromRGB(255, 185, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = folder

    -- Texto flutuante com distância
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Billboard"
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = model.PrimaryPart or model:FindFirstChildOfClass("BasePart") or model:FindFirstChild("Part")
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 220, 80)
    label.TextStrokeTransparency = 0
    label.TextSize = 11
    label.Font = Enum.Font.SourceSansBold
    label.Text = model.Name
    label.Parent = billboard
end

local function LimparChestEsp()
    local folder = Workspace:FindFirstChild("ChestModels")
    local targets = folder and folder:GetChildren() or Workspace:GetDescendants()
    for _, obj in ipairs(targets) do
        local esp = obj:FindFirstChild("ZenithChestESP")
        if esp then esp:Destroy() end
    end
end

-- ============================================================
-- FUNÇÕES DE LIMPEZA E CRIAÇÃO INDIVIDUAL (JOGADORES)
-- ============================================================
local function CriarPlayerEsp(player)
    if player == LocalPlayer then return end
    
    local function AplicarEsp(character)
        if not character or character:FindFirstChild("ZenithPlayerESP") then return end
        
        local folder = Instance.new("Folder")
        folder.Name = "ZenithPlayerESP"
        folder.Parent = character

        -- Silhueta Vermelha/Ciano para jogadores
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.FillColor = Color3.fromRGB(0, 200, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.6
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = folder

        -- Tag com Nome e Distância
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "Billboard"
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.Adornee = character:WaitForChild("HumanoidRootPart", 5)
        
        if billboard.Adornee then
            billboard.Parent = folder
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.TextSize = 12
            label.Font = Enum.Font.SourceSansBold
            label.Text = player.DisplayName or player.Name
            label.Parent = billboard
        end
    end

    if player.Character then AplicarEsp(player.Character) end
    player.CharacterAdded:Connect(AplicarEsp)
end

local function LimparPlayerEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local esp = player.Character:FindFirstChild("ZenithPlayerESP")
            if esp then esp:Destroy() end
        end
    end
end

-- ============================================================
-- ATUALIZAÇÃO DINÂMICA DE TEXTOS (DISTÂNCIA EM ESTUDOS)
-- ============================================================
local function AtualizarDistancias()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Atualiza distância dos Baús
    local folder = Workspace:FindFirstChild("ChestModels")
    local targets = folder and folder:GetChildren() or Workspace:GetDescendants()
    for _, obj in ipairs(targets) do
        local esp = obj:FindFirstChild("ZenithChestESP")
        local billboard = esp and esp:FindFirstChild("Billboard")
        local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
        if label and billboard.Adornee then
            local dist = math.floor((billboard.Adornee.Position - hrp.Position).Magnitude)
            label.Text = string.format("%s\n[%sm]", obj.Name, tostring(dist))
        end
    end

    -- Atualiza distância dos Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local esp = player.Character:FindFirstChild("ZenithPlayerESP")
            local billboard = esp and esp:FindFirstChild("Billboard")
            local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
            local p_hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if label and p_hrp then
                local dist = math.floor((p_hrp.Position - hrp.Position).Magnitude)
                local p_name = player.DisplayName or player.Name
                label.Text = string.format("%s\n[%sm]", p_name, tostring(dist))
            end
        end
    end
end

-- ============================================================
-- CONTROLADORES DE INICIALIZAÇÃO DO MÓDULO
-- ============================================================
function Esp:Start()
    if self.Enabled then return end
    self.Enabled = true

    -- Loop principal do ESP rodando na taxa de atualização do jogo (Sem lag)
    local contador = 0
    espConnection = RunService.Heartbeat:Connect(function()
        local s = S()
        if not s then return end

        contador = contador + 1
        -- Executa checagem de objetos a cada 30 frames para não pesar o processador
        if contador % 30 == 0 then
            -- Gerenciamento de Baús
            if s.EspChest then
                local folder = Workspace:FindFirstChild("ChestModels")
                local targets = folder and folder:GetChildren() or Workspace:GetDescendants()
                for i = 1, #targets do
                    local obj = targets[i]
                    if obj:IsA("Model") and string.find(obj.Name, "Chest") then
                        CriarChestEsp(obj)
                    end
                end
            else
                LimparChestEsp()
            end

            -- Gerenciamento de Players
            if s.EspPlayers then
                for _, player in ipairs(Players:GetPlayers()) do
                    CriarPlayerEsp(player)
                end
            else
                LimparPlayerEsp()
            end
        end

        -- Atualiza a numeração de distância a cada frame de renderização
        AtualizarDistancias()
    end)
end

function Esp:Stop()
    self.Enabled = false
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    LimparChestEsp()
    LimparPlayerEsp()
end

-- Ativação Automática assim que o Hub compilar o script
task.spawn(function()
    task.wait(1)
    Esp:Start()
end)

return Esp

