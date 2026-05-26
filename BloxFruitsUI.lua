local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "UI System",
    ScriptFolder = "ZenithHub"
})

local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

Tab:AddToggle({
    Name = "Enable System",
    Default = false,
    Callback = function(v)
        getgenv().ZenithHub.Settings.Enabled = v
    end
})

Window:Notify({
    Title = "Loaded",
    Content = "UI initialized successfully",
    Duration = 5
})
