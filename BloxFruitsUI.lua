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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommE = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommE")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

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
    Name = "Attack Height", Min = 0, Max = 50, Default = (Settings and Settings.AttackHeight) or 22,
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
        FarmLevel = Modules.FarmLevel or FarmLevel
        if FarmLevel then
            if v then FarmLevel:Start() else FarmLevel:Stop() end
        else
            warn("[ZenithHub] Módulo FarmLevel não encontrado.")
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

-- ============================================================================
-- ABA 3: HAKI / HABILIDADES
-- ============================================================================
local HakiTab = Window:MakeTab({ Title = "Haki", Icon = "Star" })
HakiTab:AddSection("Armamento")

-- Ken: loop automático via CollectionService tag (igual Zyn Hub original)
HakiTab:AddToggle({
    Name = "Auto Ken (Armamento)",
    Default = Settings and Settings.AutoKen or true,
    Callback = function(v)
        if Settings then Settings.AutoKen = v end
    end
})

-- Buso: dispara uma vez ao ligar
HakiTab:AddToggle({
    Name = "Auto Buso",
    Default = Settings and Settings.AutoBuso or false,
    Callback = function(v)
        if Settings then Settings.AutoBuso = v end
        if v then
            task.spawn(function()
                while Settings and Settings.AutoBuso do
                    pcall(function() CommE:FireServer("Buso") end)
                    task.wait(1)
                end
            end)
        end
    end
})

HakiTab:AddSection("Raça / Awakening")

-- V3/V4 da Raça
HakiTab:AddToggle({
    Name = "Auto Race V3/V4",
    Default = Settings and Settings.AutoV3V4 or false,
    Callback = function(v)
        if Settings then Settings.AutoV3V4 = v end
        if v then
            task.spawn(function()
                while Settings and Settings.AutoV3V4 do
                    pcall(function() CommF:InvokeServer("RaceSkill") end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- Awakening V4
HakiTab:AddToggle({
    Name = "Auto Awakening V4",
    Default = Settings and Settings.AutoAwaken or false,
    Callback = function(v)
        if Settings then Settings.AutoAwaken = v end
        if v then
            task.spawn(function()
                while Settings and Settings.AutoAwaken do
                    pcall(function() CommE:FireServer("ActivateAwakening", true) end)
                    task.wait(1)
                end
            end)
        end
    end
})

HakiTab:AddSection("Observação")

-- Haki da Observação
HakiTab:AddToggle({
    Name = "Auto Observação",
    Default = Settings and Settings.AutoObs or false,
    Callback = function(v)
        if Settings then Settings.AutoObs = v end
        if v then
            task.spawn(function()
                while Settings and Settings.AutoObs do
                    pcall(function() CommE:FireServer("Observation", true) end)
                    task.wait(1)
                end
            end)
        end
    end
})

return true
