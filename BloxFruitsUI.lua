-- [[ ZENITH HUB - FRONTEND COMPLETO ]] --

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Complete Panel",
    ScriptFolder = "ZenithHub"
})

-- ============================================================================
-- ABA 1: MAIN
-- ============================================================================
local Tab = Window:MakeTab({ Title = "Main", Icon = "Home" })
local label = Tab:AddParagraph("Player & World Status", "Aguardando sincronização...")

task.spawn(function()
    while task.wait(1) do
        local InfoService = getgenv().ZenithHub and getgenv().ZenithHub.Modules and getgenv().ZenithHub.Modules.InfoService
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


-- 2 ABA: FARM
local Modules = getgenv().ZenithHub.Modules
local Settings = Modules.FarmSettings

local FarmTab =
    Window:MakeTab({
        Title = "Farm",
        Icon = "Sword"
    })

-- SETTINGS
FarmTab:AddSection("Farm Settings")

FarmTab:AddDropdown({
    Name = "Select Weapon",
    Options = {"Melee", "Sword", "Devil Fruit", "Gun"},
    Default = Settings.SelectedWeapon,
    Callback = function(v)
        Settings.SelectedWeapon = v
    end
})

FarmTab:AddToggle({
    Name = "Fast Attack",
    Default = Settings.FastAttack,
    Callback = function(v)
        Settings.FastAttack = v
    end
})

FarmTab:AddToggle({
    Name = "Bring Mobs",
    Default = Settings.BringMobs,
    Callback = function(v)
        Settings.BringMobs = v
    end
})

-- MOVEMENT
FarmTab:AddSection("Movement")

FarmTab:AddSlider({
    Name = "Tween Speed",
    Min = 100,
    Max = 600,
    Default = Settings.TweenSpeed,
    Callback = function(v)
        Settings.TweenSpeed = v
    end
})

FarmTab:AddSlider({
    Name = "Attack Height",
    Min = 0,
    Max = 40,
    Default = Settings.AttackHeight,
    Callback = function(v)
        Settings.AttackHeight = v
    end
})

FarmTab:AddSlider({
    Name = "Attack Distance",
    Min = -20,
    Max = 20,
    Default = Settings.AttackDistance,
    Callback = function(v)
        Settings.AttackDistance = v
    end
})

-- MAIN FARM
FarmTab:AddSection("Main Farm")

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = Settings.AutoFarmLevel,
    Callback = function(v)
        Settings.AutoFarmLevel = v
        
        -- Segurança para garantir que o módulo FarmLevel existe antes de chamar
        if FarmLevel then
            FarmLevel.Enabled = v
            if v then
                FarmLevel:Start() -- Liga o Farm assim que ativa o botão
            end
        else
            warn("[ZenithHub] Erro: O módulo 'FarmLevel' não está carregado na sua UI.")
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Farm Bones",
    Default = Settings.AutoFarmBones,
    Callback = function(v)
        Settings.AutoFarmBones = v
    end
})

FarmTab:AddToggle({
    Name = "Auto Boss",
    Default = Settings.AutoBoss,
    Callback = function(v)
        Settings.AutoBoss = v
    end
})
