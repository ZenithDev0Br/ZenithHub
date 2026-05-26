-- ============================================================================
-- 3. CRIAÇÃO DA INTERFACE GRÁFICA (UI)
-- ============================================================================
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = Library:MakeWindow({
    Title = "Zenith Hub",
    SubTitle = "Simple Panel",
    ScriptFolder = "ZenithHub"
})

local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "Home"
})

-- Usando AddTextLabel, que costuma ser mais amigável para atualizações contínuas
local label = Tab:AddTextLabel("Loading...")

task.spawn(function()
    while task.wait(1) do
        local InfoService = getgenv().ZenithHub.Modules.InfoService
        
        if InfoService and InfoService.Data then
            local d = InfoService.Data

            local mirageStatus  = d.Mirage and "🟢 Spawned!" or "🔴 Not Found"
            local kitsuneStatus  = d.Kitsune and "🟢 Spawned!" or "🔴 Not Found"
            local factoryStatus = d.Factory and "🟢 Active!" or "🔴 Inactive"
            local timeStatus    = d.FullMoon and "🌕 Night" or "☀️ Day"

            local text =
                "Level: " .. tostring(d.Level or 0) .. "\n" ..
                "Sea: " .. tostring(d.Sea or "Unknown") .. "\n" ..
                "Fruit: " .. tostring(d.Fruit or "None") .. "\n" ..
                "----------------------------------\n" ..
                "Mirage Island: " .. mirageStatus .. "\n" ..
                "Kitsune Island: " .. kitsuneStatus .. "\n" ..
                "Factory Event: " .. factoryStatus .. "\n" ..
                "World Time: " .. timeStatus

            -- Tenta os métodos mais comuns para atualizar o texto na Redz Lib
            pcall(function()
                if label.SetText then
                    label:SetText(text)
                elseif label.SetDesc then
                    label:SetDesc(text)
                elseif label.Set then
                    label:Set(text)
                end
            end)
        else
            pcall(function()
                if label.SetText then label:SetText("Aguardando InfoService carregar...") end
            end)
        end
    end
end)
