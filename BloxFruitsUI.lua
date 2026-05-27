-- [[ ZENITH HUB - FRONTEND COMPLETO ]] --

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Complete Panel",
    ScriptFolder = "ZenithHub"
})

-- Garante que o ambiente global exista antes de carregar a UI
getgenv().ZenithHub = getgenv().ZenithHub or {}
getgenv().ZenithHub.Modules = getgenv().ZenithHub.Modules or {}

local Modules = getgenv().ZenithHub.Modules
local Settings = Modules.FarmSettings
local FarmLevel = Modules.FarmLevel -- Puxa o módulo carregado pelo teu Loader

-- ============================================================================
-- ABA 1: MAIN
-- ============================================================================
local Tab = Window:MakeTab({ Title = "Main", Icon = "Home" })
local label = Tab:AddParagraph("Player & World Status", "Aguardando sincronização...")

task.spawn(function()
    while task.wait(1) do
        local InfoService = Modules.InfoService
        if InfoService and InfoService.Data then
            local d = InfoService.Data
            local text = string.format("Level: %s | Sea: %s\nFruit: %s | Pull Lever: %s\n------------------\nMoon: %s | Time: %s\n------------------\nMirage: %s | Kitsune: %s\nFrozen: %s | Prehistoric: %s\nFactory: %s\n------------------\n🔱 BOSSES STATUS:\n• Cursed Captain: %s\n• Darkbeard: %s\n• Cake Prince: %s\n• Dough King: %s\n• rip_indra: %s",
                tostring(d.Level or 0), tostring(d.Sea or "Unknown"), tostring(d.Fruit or "None"), 
                d.PullLever and "🟢 Sim" or "🔴 Não", tostring(d.MoonProgress or "..."), 
                (d.FullMoon and "🌕 Noite" or "☀️ Dia"), 
                (d.Mirage and "🟢" or "🔴"), (d.Kitsune and "🟢" or "🔴"), (d.FrozenIsland and "🟢" or "🔴"), (d.PrehistoricIsland and "🟢" or "🔴"), 
                (d.Factory and "🟢" or "🔴"), 
                (d.CursedCaptain and "✅" or "❌"), (d.Darkbeard and "✅" or "❌"), (d.CakePrince and "✅" or "❌"), (d.DoughKing and "✅" or "❌"), (d.RipIndra and "✅" or "❌"))
            pcall(function() label:SetDescription(text) end)
        end
    end
end)


-- ============================================================================
-- ABA 2: FARM
-- ============================================================================

-- 🚀 [SISTEMA DE NOCLIP AUTOMÁTICO] 🚀
local RunService = game:GetService("RunService")
task.spawn(function()
    RunService.Stepped:Connect(function()
        if Settings and Settings.AutoFarmLevel then
            local character = game.Players.LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

local FarmTab = Window:MakeTab({
    Title = "Farm",
    Icon = "Sword"
})

-- SETTINGS
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

-- MOVEMENT
FarmTab:AddSection("Movement")

FarmTab:AddSlider({
    Name = "Tween Speed",
    Min = 100,
    Max = 600,
    Default = Settings and Settings.TweenSpeed or 300,
    Callback = function(v)
        if Settings then Settings.TweenSpeed = v end
    end
})

FarmTab:AddSlider({
    Name = "Attack Height",
    Min = 0,
    Max = 40,
    Default = Settings and Settings.AttackHeight or 5,
    Callback = function(v)
        if Settings then Settings.AttackHeight = v end
    end
})

FarmTab:AddSlider({
    Name = "Attack Distance",
    Min = -20,
    Max = 20,
    Default = Settings and Settings.AttackDistance or 0,
    Callback = function(v)
        if Settings then Settings.AttackDistance = v end
    end
})

-- MAIN FARM
FarmTab:AddSection("Main Farm")

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = Settings and Settings.AutoFarmLevel or false,
    Callback = function(v)
        if Settings then Settings.AutoFarmLevel = v end
        
        -- Atualiza a referência caso o Loader tenha demorado a carregar o módulo
        FarmLevel = Modules.FarmLevel or FarmLevel 
        
        if FarmLevel then
            FarmLevel.Enabled = v
            if v then
                FarmLevel:Start()
            end
        else
            warn("[ZenithHub] Erro: O módulo 'FarmLevel' não foi encontrado na tabela Modules.")
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Farm Bones",
    Default = Settings and Settings.AutoFarmBones or false,
    Callback = function(v)
        if Settings then Settings.AutoFarmBones = v end
    end
})

FarmTab:AddToggle({
    Name = "Auto Boss",
    Default = Settings and Settings.AutoBoss or false,
    Callback = function(v)
        if Settings then Settings.AutoBoss = v end
    end
})

