-- [[ ZENITH HUB - FRONTEND (Apenas a UI Atualizada) ]] --

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

-- Criar o parágrafo onde as informações vão aparecer atualizadas
local label = Tab:AddParagraph("Status do Jogador e Mundo", "Aguardando sincronização...")

-- Loop automático de atualização da interface
task.spawn(function()
    while task.wait(1) do
        local InfoService = getgenv().ZenithHub and getgenv().ZenithHub.Modules and getgenv().ZenithHub.Modules.InfoService
        
        if InfoService and InfoService.Data then
            local d = InfoService.Data

            -- Formatação visual dos novos status
            local mirageStatus  = d.Mirage and "🟢 Spawned!" or "🔴 Not Found"
            local kitsuneStatus = d.Kitsune and "🟢 Spawned!" or "🔴 Not Found"
            local frozenStatus  = d.FrozenIsland and "🟢 Active!" or "🔴 Not Found"
            local fruitSpStatus = d.FruitSpawned and "🟢 SPAWNADA NO CHÃO!" or "🔴 Nenhuma"
            local factoryStatus = d.Factory and "🟢 Active!" or "🔴 Inactive"
            local timeStatus    = d.FullMoon and "🌕 Noite" or "☀️ Dia"

            -- Montagem do texto do painel
            local text =
                "Level: " .. tostring(d.Level or 0) .. "\n" ..
                "Sea: " .. tostring(d.Sea or "Unknown") .. "\n" ..
                "Fruit: " .. tostring(d.Fruit or "None") .. "\n" ..
                "----------------------------------\n" ..
                "Ciclo Lunar: " .. tostring(d.MoonProgress or "Verificando...") .. "\n" ..
                "Período Atual: " .. timeStatus .. "\n" ..
                "----------------------------------\n" ..
                "Fruta no Mapa: " .. fruitSpStatus .. "\n" ..
                "Mirage Island: " .. mirageStatus .. "\n" ..
                "Kitsune Island: " .. kitsuneStatus .. "\n" ..
                "Frozen Island: " .. frozenStatus .. "\n" ..
                "Factory Event: " .. factoryStatus

            -- Atualiza usando o método oficial da documentação (SetDescription)
            pcall(function()
                label:SetDescription(text)
            end)
        else
            pcall(function()
                label:SetDescription("Erro: InfoService (Módulo de dados) não foi executado ou ainda está a carregar...")
            end)
        end
    end
end)
