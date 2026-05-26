local ZenithHub = getgenv().ZenithHub
local Core = ZenithHub.Core

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub : Blox Fruits",
    SubTitle = "Mobile Edition",
    ScriptFolder = "ZenithHub"
})

ZenithHub.Window = Window

--// Minimizer
local Minimizer = Window:NewMinimizer({
    KeyCode = Enum.KeyCode.LeftControl
})

Minimizer:CreateMobileMinimizer({
    Image = "rbxassetid://10734950309",
    BackgroundColor3 = Color3.fromRGB(25,25,25)
})

--// Tabs
local FarmTab = Window:MakeTab({
    Title = "Farm",
    Icon = "Sword"
})

local CombatTab = Window:MakeTab({
    Title = "Combat",
    Icon = "Shield"
})

local TeleportTab = Window:MakeTab({
    Title = "Teleport",
    Icon = "Map"
})

local PlayerTab = Window:MakeTab({
    Title = "Player",
    Icon = "User"
})

--// Toggles
FarmTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",

    Callback = function(Value)
        ZenithHub.Settings.AutoFarm = Value
    end
})

CombatTab:AddToggle({
    Name = "Auto Haki",
    Default = true,
    Flag = "AutoHaki",

    Callback = function(Value)
        ZenithHub.Settings.AutoHaki = Value
    end
})

PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Increment = 1,
    Default = 16,

    Callback = function(Value)
        local Humanoid = Core:GetHumanoid()

        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
})

Window:Notify({
    Title = "Zenith Hub",
    Content = "UI Loaded Successfully",
    Duration = 5
})
