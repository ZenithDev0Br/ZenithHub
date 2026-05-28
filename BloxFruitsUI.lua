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
            if v then
                FarmLevel:Start()
            else
                FarmLevel:Stop() -- CORREÇÃO: agora chama Stop() ao desligar
            end
        else
            warn("[ZenithHub] Módulo FarmLevel não encontrado ao ativar Toggle.")
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
