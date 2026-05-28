local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Complete Panel",
    ScriptFolder = "ZenithHub"
})

local ZenithHub = getgenv().ZenithHub
local Modules = ZenithHub and ZenithHub.Modules or {}
local Settings = Modules.FarmSettings
local FarmLevel = Modules.FarmLevel

-- ============================================================================
-- ABA 1: MAIN (Status do Mundo)
-- ============================================================================
local Tab = Window:MakeTab({ Title = "Main", Icon = "Home" })
local label = Tab:AddParagraph("Player & World Status", "Aguardando sincronização...")

task.spawn(function()
    while task.wait(1) do
        local InfoService = Modules.InfoService
        if InfoService and InfoService.Data then
            local d = InfoService.Data
            local text = string.format("Level: %s | Sea: %s\nFruit: %s\n------------------\nMoon: %s | Time: %s\n------------------\nMirage: %s | Kitsune: %s\nFactory: %s",
                tostring(d.Level or 0), tostring(d.Sea or "Unknown"), tostring(d.Fruit or "None"), 
                tostring(d.MoonProgress or "..."), (d.FullMoon and "🌕 Noite" or "☀️ Dia"), 
                (d.Mirage and "🟢" or "🔴"), (d.Kitsune and "🟢" or "🔴"), (d.Factory and "🟢" or "🔴"))
            pcall(function() label:SetDescription(text) end)
        end
    end
end)

-- ============================================================================
-- ABA 2: FARM
-- ============================================================================
local RunService = game:GetService("RunService")
task.spawn(function()
    RunService.Stepped:Connect(function()
        if Settings and Settings.AutoFarmLevel then
            local character = game.Players.LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
end)

local FarmTab = Window:MakeTab({ Title = "Farm", Icon = "Sword" })
FarmTab:AddSection("Farm Settings")

FarmTab:AddDropdown({
    Name = "Select Weapon",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = Settings and Settings.WeaponType or "Melee",
    Callback = function(v)
        if Settings then Settings.WeaponType = v end
    end
})

FarmTab:AddToggle({
    Name = "Fast Attack",
    Default = Settings and Settings.FastAttack or false,
    Callback = function(v)
        if Settings then Settings.FastAttack = v end
    end
})

FarmTab:AddToggle({
    Name = "Bring Mobs",
    Default = Settings and Settings.BringMobs or false,
    Callback = function(v)
        if Settings then Settings.BringMobs = v end
    end
})

FarmTab:AddSection("Movement")

FarmTab:AddSlider({
    Name = "Tween Speed", Min = 100, Max = 600, Default = Settings and Settings.TweenSpeed or 300,
    Callback = function(v) if Settings then Settings.TweenSpeed = v end end
})

FarmTab:AddSlider({
    Name = "Attack Height", Min = 0, Max = 40, Default = Settings and Settings.AttackHeight or 5,
    Callback = function(v) if Settings then Settings.AttackHeight = v end end
})

FarmTab:AddSlider({
    Name = "Attack Distance", Min = -20, Max = 20, Default = Settings and Settings.AttackDistance or 0,
    Callback = function(v) if Settings then Settings.AttackDistance = v end end
})

FarmTab:AddSection("Main Farm")

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = Settings and Settings.AutoFarmLevel or false,
    Callback = function(v)
        if Settings then Settings.AutoFarmLevel = v end
        
        -- Sincroniza dinamicamente com o cérebro do FarmLevel
        FarmLevel = Modules.FarmLevel or FarmLevel
        if FarmLevel then
            FarmLevel.Enabled = v
            if v then
                FarmLevel:Start() -- Executa o loop do FarmLevel.lua
            end
        else
            warn("[ZenithHub] Módulo FarmLevel não encontrado ao ativar Toggle.")
        end
    end
})

return true
