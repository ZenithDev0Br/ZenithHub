local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Complete Panel",
    ScriptFolder = "ZenithHub"
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommE = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommE")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Helper para pegar Settings sempre atualizado
local function S()
    return getgenv().ZenithHub and getgenv().ZenithHub.Modules and getgenv().ZenithHub.Modules.FarmSettings
end

local function M()
    return getgenv().ZenithHub and getgenv().ZenithHub.Modules
end

-- ============================================================================
-- ABA 1: MAIN
-- ============================================================================
local Tab = Window:MakeTab({ Title = "Main", Icon = "Home" })
local label = Tab:AddParagraph("Player & World Status", "Aguardando sincronização...")

task.spawn(function()
    while task.wait(1) do
        local Modules = M()
        local InfoService = Modules and Modules.InfoService
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
    Default = "Melee",
    Callback = function(v)
        local s = S()
        if s then s.WeaponType = v end
    end
})

FarmTab:AddToggle({
    Name = "Fast Attack",
    Default = true,
    Callback = function(v)
        local s = S()
        if s then s.FastAttack = v end
    end
})

FarmTab:AddSlider({
    Name = "Attack Speed (delay)",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Callback = function(v)
        local s = S()
        if s then s.AttackSpeed = v end
    end
})

FarmTab:AddToggle({
    Name = "Bring Mobs",
    Default = true,
    Callback = function(v)
        local s = S()
        if s then s.BringMobs = v end
    end
})

FarmTab:AddSection("Haki / Habilidades")

FarmTab:AddToggle({
    Name = "Auto Buso (Armamento)",
    Default = true,
    Callback = function(v)
        local s = S()
        if s then s.AutoBuso = v end
    end
})

FarmTab:AddToggle({
    Name = "Auto Observação",
    Default = false,
    Callback = function(v)
        local s = S()
        if s then s.AutoObs = v end
        if v then
            task.spawn(function()
                while s and s.AutoObs do
                    pcall(function() CommE:FireServer("Observation", true) end)
                    task.wait(1)
                end
            end)
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Race V3/V4",
    Default = false,
    Callback = function(v)
        local s = S()
        if s then s.AutoV3V4 = v end
        if v then
            task.spawn(function()
                while s and s.AutoV3V4 do
                    pcall(function() CommF:InvokeServer("RaceSkill") end)
                    task.wait(1)
                end
            end)
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Awakening V4",
    Default = false,
    Callback = function(v)
        local s = S()
        if s then s.AutoAwaken = v end
        if v then
            task.spawn(function()
                while s and s.AutoAwaken do
                    pcall(function() CommE:FireServer("ActivateAwakening", true) end)
                    task.wait(1)
                end
            end)
        end
    end
})

FarmTab:AddSection("Movement")

FarmTab:AddSlider({
    Name = "Tween Speed", Min = 100, Max = 600, Default = 300,
    Callback = function(v)
        local s = S()
        if s then s.TweenSpeed = v end
    end
})

FarmTab:AddSlider({
    Name = "Attack Height", Min = 0, Max = 50, Default = 5,
    Callback = function(v)
        local s = S()
        if s then s.AttackHeight = v end
    end
})

FarmTab:AddSlider({
    Name = "Attack Distance", Min = -20, Max = 20, Default = 0,
    Callback = function(v)
        local s = S()
        if s then s.AttackDistance = v end
    end
})

FarmTab:AddSection("Main Farm")

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(v)
        local s = S()
        if s then s.AutoFarmLevel = v end

        local Modules = M()
        local FarmLevel = Modules and Modules.FarmLevel
        if FarmLevel then
            if v then FarmLevel:Start() else FarmLevel:Stop() end
        else
            warn("[ZenithHub] Módulo FarmLevel não encontrado.")
        end
    end
})

FarmTab:AddToggle({
    Name = "Auto Farm Bones",
    Default = false,
    Callback = function(v)
        local s = S()
        if s then s.AutoFarmBones = v end
    end
})

FarmTab:AddToggle({
    Name = "Auto Boss",
    Default = false,
    Callback = function(v)
        local s = S()
        if s then s.AutoBoss = v end
    end
})

return true
