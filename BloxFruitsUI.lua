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
            local text = string.format(
                "Level: %s | Sea: %s\nFruit: %s | Pull Lever: %s\n------------------\nMoon: %s | Time: %s\n------------------\nMirage: %s | Kitsune: %s\nFrozen: %s | Prehistoric: %s\nFactory: %s\n------------------\n🔱 BOSSES STATUS:\n• Cursed Captain: %s\n• Darkbeard: %s\n• Cake Prince: %s\n• Dough King: %s\n• rip_indra: %s",
                tostring(d.Level or 0), tostring(d.Sea or "Unknown"), tostring(d.Fruit or "None"),
                d.PullLever and "🟢 Sim" or "🔴 Não", tostring(d.MoonProgress or "..."),
                (d.FullMoon and "🌕 Noite" or "☀️ Dia"),
                (d.Mirage and "🟢" or "🔴"), (d.Kitsune and "🟢" or "🔴"),
                (d.FrozenIsland and "🟢" or "🔴"), (d.PrehistoricIsland and "🟢" or "🔴"),
                (d.Factory and "🟢" or "🔴"),
                (d.CursedCaptain and "✅" or "❌"), (d.Darkbeard and "✅" or "❌"),
                (d.CakePrince and "✅" or "❌"), (d.DoughKing and "✅" or "❌"),
                (d.RipIndra and "✅" or "❌")
            )
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

-- Velocidade do Fast Attack (menor = mais rápido)
FarmTab:AddSlider({
    Name = "Attack Speed (delay)",
    Min = 0,
    Max = 1,
    Default = Settings and Settings.AttackSpeed or 0.1,
    Callback = function(v)
        if Settings then Settings.AttackSpeed = v end
    end
})

FarmTab:AddToggle({
    Name = "Bring Mobs",
    Default = Settings and Settings.BringMobs or false,
    Callback = function(v)
        if Settings then Settings.BringMobs = v end
    end
})

FarmTab:AddSection("Haki / Habilidades")

-- Buso (Armamento)
FarmTab:AddToggle({
    Name = "Auto Buso (Armamento)",
    Default = Settings and Settings.AutoBuso or true,
    Callback = function(v)
        if Settings then Settings.AutoBuso = v end
    end
})

-- Observação
FarmTab:AddToggle({
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

-- Race V3/V4
FarmTab:AddToggle({
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
FarmTab:AddToggle({
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

FarmTab:AddSection("Movement")

FarmTab:AddSlider({
    Name = "Tween Speed", Min = 100, Max = 600,
    Default = Settings and Settings.TweenSpeed or 300,
    Callback = function(v) if Settings then Settings.TweenSpeed = v end end
})

FarmTab:AddSlider({
    Name = "Attack Height", Min = 0, Max = 50,
    Default = (Settings and Settings.AttackHeight) or 22,
    Callback = function(v) if Settings then Settings.AttackHeight = v end end
})

FarmTab:AddSlider({
    Name = "Attack Distance", Min = -20, Max = 20,
    Default = Settings and Settings.AttackDistance or 0,
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

return true
