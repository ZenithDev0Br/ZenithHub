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

-- Criamos o parágrafo original
local label = Tab:AddParagraph("Status do Jogador e Mundo", "Aguardando sincronização...")

task.spawn(function()
    while task.wait(1) do
        local InfoService = getgenv().ZenithHub.Modules.InfoService
        
        if InfoService and InfoService.Data then
            local d = InfoService.Data

            local mirageStatus  = d.Mirage and "🟢 Spawned!" or "🔴 Not Found"
            local kitsuneStatus = d.Kitsune and "🟢 Spawned!" or "🔴 Not Found"
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

            -- Agora usando a função exata da documentação da Wand UI / Redz V5
            pcall(function()
                label:SetDescription(text)
            end)
        else
            pcall(function()
                label:SetDescription("Aguardando InfoService carregar...")
            end)
        end
    end
end)
