print("UI START")

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

print("LIB LOADED")

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Test",
    ScriptFolder = "ZenithHub"
})

print("WINDOW CREATED")

Window:Notify({
    Title = "Zenith",
    Content = "Loaded",
    Duration = 5
})

print("UI END")
