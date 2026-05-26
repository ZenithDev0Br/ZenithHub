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
local FarmTab = Window:MakeTab({ Title = "Farm", Icon = "Sword" })

-- 1. Farm Settings
FarmTab:AddSection("Farm Settings")
FarmTab:AddDropdown({ Name = "Select Weapon", Options = {"Melee", "Sword", "Devil Fruit", "Gun"}, Default = "Melee", Callback = function(v) _G.SelectedWeapon = v end })
FarmTab:AddToggle({ Name = "Fast Attack", Default = false, Callback = function(v) getgenv().ZenithHub.Modules.FarmSettings:FastAttack(v) end })
FarmTab:AddToggle({ Name = "Bring Mobs", Default = false, Callback = function(v) getgenv().ZenithHub.Modules.FarmSettings:BringMobs(v) end })
FarmTab:AddSlider({ Name = "Tween Speed", Min = 100, Max = 600, Default = 300, Callback = function(v) _G.TweenSpeed = v end })
FarmTab:AddSlider({ Name = "Attack Height", Min = 0, Max = 20, Default = 5, Callback = function(v) _G.AttackHeight = v end })



-- 2. Main Farm
FarmTab:AddSection("Main Farm")
FarmTab:AddToggle({ Name = "Auto Farm Level", Default = false, Callback = function(v) getgenv().ZenithHub.Modules.FarmLevel:AutoFarm(v) end })
