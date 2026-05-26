-- [[ ZENITH HUB - FRONTEND ]] --

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Simple Panel",
    ScriptFolder = "ZenithHub"
})

-- MAIN TAB
local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

-- FARM TAB
local FarmTab = Window:MakeTab({
    Title = "Farm",
    Icon = "Sword"
})

-- ═══════════════════════════════
-- FARM SETTINGS
-- ═══════════════════════════════

FarmTab:AddSection("Farm Settings")

_G.SelectedWeapon = "Melee"

FarmTab:AddDropdown({
    Name = "Select Weapon",
    Options = {"Melee", "Sword", "Devil Fruit", "Gun"},
    Default = "Melee",
    Callback = function(WeaponSelected)
        _G.SelectedWeapon = WeaponSelected
    end
})

_G.FastAttack = false

FarmTab:AddToggle({
    Name = "Fast Attack (Auto Click)",
    Default = false,
    Callback = function(Value)
        _G.FastAttack = Value
    end
})

_G.BringMobs = false

FarmTab:AddToggle({
    Name = "Bring Mobs (Juntar Monstros)",
    Default = false,
    Callback = function(Value)
        _G.BringMobs = Value
    end
})

-- ═══════════════════════════════
-- MAIN FARM
-- ═══════════════════════════════

FarmTab:AddSection("Main Farm")

_G.AutoFarmLevel = false

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(Value)
        _G.AutoFarmLevel = Value
    end
})

-- ═══════════════════════════════
-- MATERIALS
-- ═══════════════════════════════

FarmTab:AddSection("Automations & Materials")

_G.AutoFarmBones = false

FarmTab:AddToggle({
    Name = "Auto Farm Bones (Sea 3)",
    Default = false,
    Callback = function(Value)
        _G.AutoFarmBones = Value
    end
})

_G.AutoAnnihilateBosses = false

FarmTab:AddToggle({
    Name = "Auto Attack Spawned Bosses",
    Default = false,
    Callback = function(Value)
        _G.AutoAnnihilateBosses = Value
    end
})

-- ═══════════════════════════════
-- MAIN INFO UI
-- ═══════════════════════════════

local label = Tab:AddParagraph(
    "Player & World Status",
    "Aguardando sincronização..."
)

task.spawn(function()
    while task.wait(1) do

        local InfoService =
            getgenv().ZenithHub and
            getgenv().ZenithHub.Modules and
            getgenv().ZenithHub.Modules.InfoService

        if InfoService and InfoService.Data then

            local d = InfoService.Data

            local mirageStatus      = d.Mirage and "🟢 Spawnada!" or "🔴 Não Encontrada"
            local kitsuneStatus     = d.Kitsune and "🟢 Spawnada!" or "🔴 Não Encontrada"
            local frozenStatus      = d.FrozenIsland and "🟢 Ativa!" or "🔴 Não Encontrada"
            local prehistoricStatus = d.PrehistoricIsland and "🟢 Spawnada!" or "🔴 Não Encontrada"
            local fruitSpStatus     = d.FruitSpawned and "🟢 SPAWNADA NO CHÃO!" or "🔴 Nenhuma"
            local factoryStatus     = d.Factory and "🟢 Ativo!" or "🔴 Inativo"
            local timeStatus        = d.FullMoon and "🌕 Noite" or "☀️ Dia"

            local leverStatus = d.PullLever and "🟢 Puxada! (Ativa)" or "🔴 Não Puxada"

            local ccStatus    = d.CursedCaptain and "🟢 VIVO!" or "🔴 Morto/Inativo"
            local dbStatus    = d.Darkbeard and "🟢 VIVO!" or "🔴 Morto/Inativo"
            local cpStatus    = d.CakePrince and "🟢 VIVO!" or "🔴 Não invocado"
            local dkStatus    = d.DoughKing and "🟢 VIVO!" or "🔴 Não invocado"
            local indraStatus = d.RipIndra and "🟢 VIVO!" or "🔴 Sem Névoa"

            local text =
                "Level: " .. tostring(d.Level or 0) ..
                " | Sea: " .. tostring(d.Sea or "Unknown") .. "\n" ..

                "Fruit: " .. tostring(d.Fruit or "None") .. "\n" ..
                "Pull Lever: " .. leverStatus .. "\n" ..

                "----------------------------------\n" ..

                "Moon Cycle: " .. tostring(d.MoonProgress or "Verificando...") .. "\n" ..
                "Current Time: " .. timeStatus .. "\n" ..

                "----------------------------------\n" ..

                "Fruit on Map: " .. fruitSpStatus .. "\n" ..
                "Mirage Island: " .. mirageStatus .. "\n" ..
                "Kitsune Island: " .. kitsuneStatus .. "\n" ..
                "Frozen Island: " .. frozenStatus .. "\n" ..
                "Prehistoric Island: " .. prehistoricStatus .. "\n" ..
                "Factory Event: " .. factoryStatus .. "\n" ..

                "----------------------------------\n" ..

                "🔱 BOSSES STATUS:\n" ..
                "• Cursed Captain: " .. ccStatus .. "\n" ..
                "• Darkbeard: " .. dbStatus .. "\n" ..
                "• Cake Prince: " .. cpStatus .. "\n" ..
                "• Dough King: " .. dkStatus .. "\n" ..
                "• rip_indra: " .. indraStatus

            pcall(function()
                label:SetDescription(text)
            end)

        else

            pcall(function()
                label:SetDescription(
                    "Erro: InfoService não encontrado..."
                )
            end)

        end
    end
end)
