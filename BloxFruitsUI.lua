local ZenithHub = getgenv().ZenithHub
local Info = ZenithHub.Modules.InfoService

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Info Panel",
    ScriptFolder = "ZenithHub"
})

local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

local label = Tab:AddParagraph("Status", "Loading...")

task.spawn(function()
    while task.wait(1) do

        local d = Info.Data

        local function icon(v)
            return v and "🟢" or "🔴"
        end

        local text =
        "Level: " .. d.Level .. "\n" ..
        "Sea: " .. d.Sea .. "\n" ..
        "Fruit: " .. d.Fruit .. "\n\n" ..
        "FullMoon: " .. icon(d.FullMoon) .. "\n" ..
        "Mirage: " .. icon(d.Mirage) .. "\n" ..
        "Kitsune: " .. icon(d.Kitsune) .. "\n" ..
        "Factory: " .. icon(d.Factory)

        label:Set(text)

    end
end)
