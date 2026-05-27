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

-- ============================================================================
-- ABA 2: FARM
-- ============================================================================
local FarmTab = Window:MakeTab({
    Title = "Farm",
    Icon = "Sword"
})

local ZenithHub =
    getgenv().ZenithHub

local Modules =
    ZenithHub.Modules

local FarmSettings =
    Modules.FarmSettings

local FarmLevel =
    Modules.FarmLevel

-- ============================================================================
-- FARM SETTINGS
-- ============================================================================
FarmTab:AddSection("Farm Settings")

FarmTab:AddDropdown({
    Name = "Select Weapon",
    Options = {
        "Melee",
        "Sword",
        "Devil Fruit",
        "Gun"
    },
    Default = FarmSettings.SelectedWeapon,

    Callback = function(Value)
        FarmSettings.SelectedWeapon = Value
    end
})

FarmTab:AddToggle({
    Name = "Fast Attack",
    Default = FarmSettings.FastAttack,

    Callback = function(Value)
        FarmSettings.FastAttack = Value
    end
})

FarmTab:AddToggle({
    Name = "Bring Mobs",
    Default = FarmSettings.BringMobs,

    Callback = function(Value)
        FarmSettings.BringMobs = Value
    end
})

-- ============================================================================
-- MOVEMENT SETTINGS
-- ============================================================================
FarmTab:AddSection("Movement")

FarmTab:AddSlider({
    Name = "Tween Speed",
    Min = 100,
    Max = 600,
    Increment = 10,
    Default = FarmSettings.TweenSpeed,

    Callback = function(Value)
        FarmSettings.TweenSpeed = Value
    end
})

FarmTab:AddSlider({
    Name = "Attack Height",
    Min = 0,
    Max = 40,
    Increment = 1,
    Default = FarmSettings.AttackHeight,

    Callback = function(Value)
        FarmSettings.AttackHeight = Value
    end
})

FarmTab:AddSlider({
    Name = "Attack Distance",
    Min = -20,
    Max = 20,
    Increment = 1,
    Default = FarmSettings.AttackDistance,

    Callback = function(Value)
        FarmSettings.AttackDistance = Value
    end
})

-- ============================================================================
-- MAIN FARM
-- ============================================================================
FarmTab:AddSection("Main Farm")

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = FarmSettings.AutoFarmLevel,

    Callback = function(Value)

        FarmSettings.AutoFarmLevel = Value

        if FarmLevel and FarmLevel.AutoFarm then
            FarmLevel:AutoFarm(Value)
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Farm Bones",
    Default = FarmSettings.AutoFarmBones,

    Callback = function(Value)
        FarmSettings.AutoFarmBones = Value
    end
})

FarmTab:AddToggle({
    Name = "Auto Boss",
    Default = FarmSettings.AutoAnnihilateBosses,

    Callback = function(Value)
        FarmSettings.AutoAnnihilateBosses = Value
    end
})

-- ============================================================================
-- STATUS
-- ============================================================================
FarmTab:AddSection("Status")

local StatusLabel =
    FarmTab:AddParagraph(
        "Farm Status",
        "Idle..."
    )

task.spawn(function()

    while task.wait(1) do

        local Status =
            FarmSettings.AutoFarmLevel
            and "🟢 Farming"
            or "🔴 Stopped"

        local Enemy =
            FarmLevel.CurrentEnemy
            or "None"

        local Quest =
            FarmLevel.CurrentQuest
            or "None"

        local Text =
            "Status: " .. Status .. "\n" ..
            "Enemy: " .. Enemy .. "\n" ..
            "Quest: " .. Quest .. "\n" ..
            "Weapon: " .. FarmSettings.SelectedWeapon

        pcall(function()
            StatusLabel:SetDescription(Text)
        end)
    end
end)
