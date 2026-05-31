-- ╔══════════════════════════════════════╗
-- ║        REMOTE SPY - by Script        ║
-- ║    GUI arrastável | Copiar código    ║
-- ╚══════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════
--         CONFIGURAÇÕES
-- ══════════════════════════════
local MAX_LOGS = 200
local logs = {}
local selectedLog = nil
local isPaused = false
local filterText = ""

-- ══════════════════════════════
--         CRIAR GUI
-- ══════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RemoteSpy_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer.PlayerGui
end

-- Janela principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Borda brilhante
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(80, 140, 255)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.4
Stroke.Parent = MainFrame

-- Sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = MainFrame

-- ══════════════════════════════
--           TOPBAR
-- ══════════════════════════════
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

-- Fix canto inferior do topbar
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 8)
TopFix.Position = UDim2.new(0, 0, 1, -8)
TopFix.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

-- Ícone / Título
local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 20, 0, 20)
TitleIcon.Position = UDim2.new(0, 12, 0.5, -10)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "◈"
TitleIcon.TextColor3 = Color3.fromRGB(80, 140, 255)
TitleIcon.TextSize = 16
TitleIcon.Font = Enum.Font.GothamBold
TitleIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 36, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Remote Spy"
Title.TextColor3 = Color3.fromRGB(220, 230, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 200, 1, 0)
SubTitle.Position = UDim2.new(0, 108, 0, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "v1.0"
SubTitle.TextColor3 = Color3.fromRGB(80, 140, 255)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Botão Minimizar
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -68, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 220)
MinBtn.TextSize = 12
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- ══════════════════════════════
--         TOOLBAR
-- ══════════════════════════════
local ToolBar = Instance.new("Frame")
ToolBar.Name = "ToolBar"
ToolBar.Size = UDim2.new(1, 0, 0, 38)
ToolBar.Position = UDim2.new(0, 0, 0, 36)
ToolBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ToolBar.BorderSizePixel = 0
ToolBar.Parent = MainFrame

-- Filtro de busca
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 180, 0, 24)
SearchBox.Position = UDim2.new(0, 8, 0.5, -12)
SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
SearchBox.Text = ""
SearchBox.PlaceholderText = "🔍 Filtrar remotes..."
SearchBox.TextColor3 = Color3.fromRGB(200, 210, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 85, 110)
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.BorderSizePixel = 0
SearchBox.Parent = ToolBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(50, 60, 100)
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBox

-- Botão Pause/Resume
local PauseBtn = Instance.new("TextButton")
PauseBtn.Size = UDim2.new(0, 76, 0, 24)
PauseBtn.Position = UDim2.new(0, 196, 0.5, -12)
PauseBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
PauseBtn.Text = "⏸ Pausar"
PauseBtn.TextColor3 = Color3.fromRGB(80, 220, 120)
PauseBtn.TextSize = 11
PauseBtn.Font = Enum.Font.GothamBold
PauseBtn.BorderSizePixel = 0
PauseBtn.Parent = ToolBar

local PauseCorner = Instance.new("UICorner")
PauseCorner.CornerRadius = UDim.new(0, 6)
PauseCorner.Parent = PauseBtn

-- Botão Limpar
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 66, 0, 24)
ClearBtn.Position = UDim2.new(0, 278, 0.5, -12)
ClearBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
ClearBtn.Text = "🗑 Limpar"
ClearBtn.TextColor3 = Color3.fromRGB(220, 90, 90)
ClearBtn.TextSize = 11
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.BorderSizePixel = 0
ClearBtn.Parent = ToolBar

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

-- Contador
local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0, 120, 1, 0)
CountLabel.Position = UDim2.new(1, -124, 0, 0)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "0 remotes"
CountLabel.TextColor3 = Color3.fromRGB(90, 100, 140)
CountLabel.TextSize = 11
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.Parent = ToolBar

-- ══════════════════════════════
--       PAINEL ESQUERDO (Lista)
-- ══════════════════════════════
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Size = UDim2.new(0, 230, 1, -74)
LeftPanel.Position = UDim2.new(0, 0, 0, 74)
LeftPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

-- Divisor
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 1, -74)
Divider.Position = UDim2.new(0, 230, 0, 74)
Divider.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Header da lista
local ListHeader = Instance.new("TextLabel")
ListHeader.Size = UDim2.new(1, 0, 0, 24)
ListHeader.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
ListHeader.Text = "  REMOTES CAPTURADOS"
ListHeader.TextColor3 = Color3.fromRGB(80, 140, 255)
ListHeader.TextSize = 10
ListHeader.Font = Enum.Font.GothamBold
ListHeader.TextXAlignment = Enum.TextXAlignment.Left
ListHeader.BorderSizePixel = 0
ListHeader.Parent = LeftPanel

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -24)
ScrollFrame.Position = UDim2.new(0, 0, 0, 24)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 140, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = LeftPanel

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 1)
ListLayout.Parent = ScrollFrame

-- ══════════════════════════════
--       PAINEL DIREITO (Detalhes)
-- ══════════════════════════════
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Size = UDim2.new(1, -231, 1, -74)
RightPanel.Position = UDim2.new(0, 231, 0, 74)
RightPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = MainFrame

-- Tabs do painel direito
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
TabBar.BorderSizePixel = 0
TabBar.Parent = RightPanel

local function makeTab(text, xPos, active)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 90, 1, -4)
    tab.Position = UDim2.new(0, xPos, 0, 2)
    tab.BackgroundColor3 = active and Color3.fromRGB(25, 35, 65) or Color3.fromRGB(14, 14, 22)
    tab.Text = text
    tab.TextColor3 = active and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(80, 85, 110)
    tab.TextSize = 11
    tab.Font = Enum.Font.GothamBold
    tab.BorderSizePixel = 0
    tab.Parent = TabBar
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 5)
    tc.Parent = tab
    return tab
end

local TabInfo = makeTab("📋 Info", 4, true)
local TabCode = makeTab("</> Código", 98, false)

-- Área de info
local InfoArea = Instance.new("ScrollingFrame")
InfoArea.Name = "InfoArea"
InfoArea.Size = UDim2.new(1, -8, 1, -38)
InfoArea.Position = UDim2.new(0, 4, 0, 32)
InfoArea.BackgroundTransparency = 1
InfoArea.BorderSizePixel = 0
InfoArea.ScrollBarThickness = 3
InfoArea.ScrollBarImageColor3 = Color3.fromRGB(80, 140, 255)
InfoArea.CanvasSize = UDim2.new(0, 0, 0, 0)
InfoArea.Parent = RightPanel

local InfoLayout = Instance.new("UIListLayout")
InfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
InfoLayout.Padding = UDim.new(0, 4)
InfoLayout.Parent = InfoArea

-- Área de código
local CodeArea = Instance.new("Frame")
CodeArea.Name = "CodeArea"
CodeArea.Size = UDim2.new(1, -8, 1, -38)
CodeArea.Position = UDim2.new(0, 4, 0, 32)
CodeArea.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
CodeArea.BorderSizePixel = 0
CodeArea.Visible = false
CodeArea.Parent = RightPanel

local CodeCorner = Instance.new("UICorner")
CodeCorner.CornerRadius = UDim.new(0, 6)
CodeCorner.Parent = CodeArea

local CodeStroke = Instance.new("UIStroke")
CodeStroke.Color = Color3.fromRGB(40, 50, 80)
CodeStroke.Thickness = 1
CodeStroke.Parent = CodeArea

local CodeScroll = Instance.new("ScrollingFrame")
CodeScroll.Size = UDim2.new(1, 0, 1, -36)
CodeScroll.BackgroundTransparency = 1
CodeScroll.BorderSizePixel = 0
CodeScroll.ScrollBarThickness = 3
CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 140, 255)
CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
CodeScroll.Parent = CodeArea

local CodeLabel = Instance.new("TextLabel")
CodeLabel.Size = UDim2.new(1, -12, 1, 0)
CodeLabel.Position = UDim2.new(0, 8, 0, 0)
CodeLabel.BackgroundTransparency = 1
CodeLabel.Text = "-- Selecione um remote para ver o código"
CodeLabel.TextColor3 = Color3.fromRGB(130, 145, 190)
CodeLabel.TextSize = 12
CodeLabel.Font = Enum.Font.Code
CodeLabel.TextXAlignment = Enum.TextXAlignment.Left
CodeLabel.TextYAlignment = Enum.TextYAlignment.Top
CodeLabel.TextWrapped = true
CodeLabel.RichText = true
CodeLabel.Parent = CodeScroll

-- Botão copiar código
local CopyCodeBtn = Instance.new("TextButton")
CopyCodeBtn.Size = UDim2.new(1, -8, 0, 28)
CopyCodeBtn.Position = UDim2.new(0, 4, 1, -32)
CopyCodeBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 100)
CopyCodeBtn.Text = "📋 Copiar Código"
CopyCodeBtn.TextColor3 = Color3.fromRGB(120, 180, 255)
CopyCodeBtn.TextSize = 12
CopyCodeBtn.Font = Enum.Font.GothamBold
CopyCodeBtn.BorderSizePixel = 0
CopyCodeBtn.Parent = CodeArea

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyCodeBtn

-- Placeholder quando nada está selecionado
local PlaceholderLabel = Instance.new("TextLabel")
PlaceholderLabel.Size = UDim2.new(1, 0, 1, 0)
PlaceholderLabel.BackgroundTransparency = 1
PlaceholderLabel.Text = "◈\n\nSelecione um remote\nna lista para ver detalhes"
PlaceholderLabel.TextColor3 = Color3.fromRGB(50, 55, 80)
PlaceholderLabel.TextSize = 13
PlaceholderLabel.Font = Enum.Font.Gotham
PlaceholderLabel.Parent = InfoArea

-- ══════════════════════════════
--         FUNÇÕES AUXILIARES
-- ══════════════════════════════
local function makeInfoRow(label, value, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = InfoArea

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 5)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 90, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(80, 140, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -100, 1, 0)
    val.Position = UDim2.new(0, 100, 0, 0)
    val.BackgroundTransparency = 1
    val.Text = tostring(value)
    val.TextColor3 = Color3.fromRGB(190, 200, 230)
    val.TextSize = 11
    val.Font = Enum.Font.Gotham
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.TextTruncate = Enum.TextTruncate.AtEnd
    val.Parent = row

    return row
end

local function serializeArg(arg)
    local t = typeof(arg)
    if t == "string" then
        return string.format("%q", arg)
    elseif t == "number" then
        return tostring(arg)
    elseif t == "boolean" then
        return tostring(arg)
    elseif t == "Instance" then
        return "game" .. arg:GetFullName():gsub("^[^.]+", "")
    elseif t == "Vector3" then
        return string.format("Vector3.new(%g, %g, %g)", arg.X, arg.Y, arg.Z)
    elseif t == "CFrame" then
        local p = arg.Position
        return string.format("CFrame.new(%g, %g, %g)", p.X, p.Y, p.Z)
    elseif t == "Color3" then
        return string.format("Color3.new(%g, %g, %g)", arg.R, arg.G, arg.B)
    elseif t == "nil" then
        return "nil"
    elseif t == "table" then
        return "{...}"
    else
        return "["..t.."]"
    end
end

local function generateCode(log)
    local remotePath = "game" .. log.remote:GetFullName():gsub("^[^.]+", "")
    local args = {}
    for _, a in ipairs(log.args) do
        table.insert(args, serializeArg(a))
    end
    local argsStr = table.concat(args, ", ")

    if log.remoteType == "RemoteEvent" then
        return string.format(
            "-- Remote Spy | %s\nlocal remote = %s\nremote:FireServer(%s)",
            log.name, remotePath, argsStr
        )
    elseif log.remoteType == "RemoteFunction" then
        return string.format(
            "-- Remote Spy | %s\nlocal remote = %s\nlocal result = remote:InvokeServer(%s)\nprint(result)",
            log.name, remotePath, argsStr
        )
    end
    return "-- Tipo desconhecido"
end

-- ══════════════════════════════
--       ATUALIZAR DETALHES
-- ══════════════════════════════
local function showDetails(log)
    selectedLog = log

    -- Limpar info
    for _, child in ipairs(InfoArea:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    PlaceholderLabel.Visible = false

    makeInfoRow("Nome:", log.name, 1)
    makeInfoRow("Tipo:", log.remoteType, 2)
    makeInfoRow("Path:", log.remote:GetFullName(), 3)
    makeInfoRow("Chamadas:", log.count, 4)
    makeInfoRow("Args (#):", #log.args, 5)

    -- Args detalhados
    for i, arg in ipairs(log.args) do
        makeInfoRow("Arg "..i..":", serializeArg(arg), 5 + i)
    end

    InfoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Wait()
    InfoArea.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 8)

    -- Código
    local code = generateCode(log)
    CodeLabel.Text = code
    task.wait()
    CodeScroll.CanvasSize = UDim2.new(0, 0, 0, CodeLabel.AbsoluteSize.Y + 10)
end

-- ══════════════════════════════
--         ADICIONAR LOG
-- ══════════════════════════════
local logMap = {}

local function addOrUpdateLog(remote, remoteType, args)
    if isPaused then return end

    local key = remote:GetFullName()

    -- Filtro
    if filterText ~= "" and not key:lower():find(filterText:lower(), 1, true) then return end

    if logMap[key] then
        local log = logMap[key]
        log.count = log.count + 1
        log.args = args
        log.label.Text = string.format(" %s  ×%d", log.name, log.count)

        if selectedLog == log then
            showDetails(log)
        end
        return
    end

    -- Novo log
    local log = {
        remote = remote,
        remoteType = remoteType,
        name = remote.Name,
        args = args,
        count = 1,
    }

    -- Item da lista
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, 0, 0, 28)
    item.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    item.Text = ""
    item.BorderSizePixel = 0
    item.LayoutOrder = #logs + 1
    item.Parent = ScrollFrame

    local typeTag = Instance.new("Frame")
    typeTag.Size = UDim2.new(0, 3, 0.7, 0)
    typeTag.Position = UDim2.new(0, 4, 0.15, 0)
    typeTag.BackgroundColor3 = remoteType == "RemoteEvent"
        and Color3.fromRGB(80, 200, 120)
        or Color3.fromRGB(255, 180, 60)
    typeTag.BorderSizePixel = 0
    typeTag.Parent = item
    local tagCorner = Instance.new("UICorner")
    tagCorner.CornerRadius = UDim.new(1, 0)
    tagCorner.Parent = typeTag

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -14, 1, 0)
    nameLabel.Position = UDim2.new(0, 12, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = " " .. remote.Name .. "  ×1"
    nameLabel.TextColor3 = Color3.fromRGB(190, 200, 240)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = item

    log.item = item
    log.label = nameLabel
    logMap[key] = log
    table.insert(logs, log)

    -- Scroll automático
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.CanvasSize.Y.Offset)

    -- Limite de logs
    if #logs > MAX_LOGS then
        local oldest = table.remove(logs, 1)
        logMap[oldest.remote:GetFullName()] = nil
        oldest.item:Destroy()
    end

    CountLabel.Text = #logs .. " remotes"

    item.MouseButton1Click:Connect(function()
        -- Desmarcar anterior
        for _, l in ipairs(logs) do
            l.item.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
            l.label.TextColor3 = Color3.fromRGB(190, 200, 240)
        end
        item.BackgroundColor3 = Color3.fromRGB(22, 30, 55)
        nameLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
        showDetails(log)
    end)
end

-- ══════════════════════════════
--          HOOKS
-- ══════════════════════════════
local oldFireServer = Instance.new("RemoteEvent").FireServer
local oldInvokeServer = Instance.new("RemoteFunction").InvokeServer

hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and self:IsA("RemoteEvent") then
        task.defer(function()
            pcall(addOrUpdateLog, self, "RemoteEvent", args)
        end)
    elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
        task.defer(function()
            pcall(addOrUpdateLog, self, "RemoteFunction", args)
        end)
    end

    return oldFireServer(self, ...)
end)

-- ══════════════════════════════
--         CONTROLES UI
-- ══════════════════════════════
-- Tabs
local activeTab = "info"
TabInfo.MouseButton1Click:Connect(function()
    activeTab = "info"
    InfoArea.Visible = true
    CodeArea.Visible = false
    TabInfo.BackgroundColor3 = Color3.fromRGB(25, 35, 65)
    TabInfo.TextColor3 = Color3.fromRGB(80, 140, 255)
    TabCode.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    TabCode.TextColor3 = Color3.fromRGB(80, 85, 110)
end)

TabCode.MouseButton1Click:Connect(function()
    activeTab = "code"
    InfoArea.Visible = false
    CodeArea.Visible = true
    TabCode.BackgroundColor3 = Color3.fromRGB(25, 35, 65)
    TabCode.TextColor3 = Color3.fromRGB(80, 140, 255)
    TabInfo.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    TabInfo.TextColor3 = Color3.fromRGB(80, 85, 110)
end)

-- Copiar código
CopyCodeBtn.MouseButton1Click:Connect(function()
    if selectedLog then
        local code = generateCode(selectedLog)
        setclipboard(code)
        CopyCodeBtn.Text = "✓ Copiado!"
        CopyCodeBtn.BackgroundColor3 = Color3.fromRGB(20, 70, 40)
        CopyCodeBtn.TextColor3 = Color3.fromRGB(80, 220, 120)
        task.delay(1.5, function()
            CopyCodeBtn.Text = "📋 Copiar Código"
            CopyCodeBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 100)
            CopyCodeBtn.TextColor3 = Color3.fromRGB(120, 180, 255)
        end)
    end
end)

-- Pausar/Retomar
PauseBtn.MouseButton1Click:Connect(function()
    isPaused = not isPaused
    if isPaused then
        PauseBtn.Text = "▶ Retomar"
        PauseBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
        PauseBtn.TextColor3 = Color3.fromRGB(255, 160, 60)
    else
        PauseBtn.Text = "⏸ Pausar"
        PauseBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
        PauseBtn.TextColor3 = Color3.fromRGB(80, 220, 120)
    end
end)

-- Limpar
ClearBtn.MouseButton1Click:Connect(function()
    for _, l in ipairs(logs) do
        l.item:Destroy()
    end
    logs = {}
    logMap = {}
    selectedLog = nil
    PlaceholderLabel.Visible = true
    for _, child in ipairs(InfoArea:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    CodeLabel.Text = "-- Selecione um remote para ver o código"
    CountLabel.Text = "0 remotes"
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Filtro
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterText = SearchBox.Text
end)

-- Fechar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimizar
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ToolBar.Visible = not minimized
    LeftPanel.Visible = not minimized
    Divider.Visible = not minimized
    RightPanel.Visible = not minimized
    MainFrame.Size = minimized
        and UDim2.new(0, 580, 0, 36)
        or UDim2.new(0, 580, 0, 420)
    MinBtn.Text = minimized and "□" or "—"
end)

-- ══════════════════════════════
--        ARRASTAR GUI
-- ══════════════════════════════
local dragging = false
local dragStart = nil
local startPos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("[RemoteSpy] ✓ Carregado com sucesso!")
print("[RemoteSpy] Aguardando remotes...")
