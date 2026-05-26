repeat task.wait() until game:IsLoaded()

local ZenithHub = getgenv().ZenithHub
local Info = ZenithHub.Modules.InfoService

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Info System",
    ScriptFolder = "ZenithHub"
})

local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

Tab:AddParagraph("Status", "Loading...")

task.spawn(function()
    while task.wait(1) do
        local ok, err = pcall(function()
            local d = Info.Data

            local function icon(v)
                return v and "🟢" or "🔴"
            end

            local fruit = d.Fruit ~= "None" and d.Fruit or "🔴"

            local label =
                "Level: " .. tostring(d.Level) .. "\n" ..
                "Sea: " .. tostring(d.Sea) .. "\n" ..
                "Fruit: " .. tostring(fruit) .. "\n\n" ..
                "Full Moon: " .. icon(d.FullMoon) .. "\n" ..
                "Mirage: " .. icon(d.Mirage) .. "\n" ..
                "Kitsune: " .. icon(d.Kitsune) .. "\n" ..
                "Factory: " .. icon(d.Factory)

            -- Se a lib não suportar atualizar texto, não use Clear em loop.
            -- Aqui você vai precisar do método real da sua UI para update.
            print(label)
        end)

        if not ok then
            warn("[ZenithHub UI] update error:", err)
        end
    end
end)
