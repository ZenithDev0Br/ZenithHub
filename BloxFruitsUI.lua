local ZenithHub = getgenv().ZenithHub
local Info = ZenithHub.Modules.InfoService

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Blox Fruits",
    ScriptFolder = "by ZenithHub"
})

local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

local Label = ""

Tab:AddParagraph("Status", "Loading...")

task.spawn(function()
    while task.wait(1) do

        local d = Info.Data

        local fruit = d.Fruit ~= "None" and d.Fruit or "🔴"

        local function icon(v)
            return v and "🟢" or "🔴"
        end

        Label =
        "Level: " .. d.Level .. "\n" ..
        "Sea: " .. d.Sea .. "\n" ..
        "Fruit: " .. fruit .. "\n\n" ..
        "Full Moon: " .. icon(d.FullMoon) .. "\n" ..
        "Mirage: " .. icon(d.Mirage) .. "\n" ..
        "Kitsune: " .. icon(d.Kitsune) .. "\n" ..
        "Factory: " .. icon(d.Factory)

        Tab:Clear()
        Tab:AddParagraph("Status", Label)

    end
end)
