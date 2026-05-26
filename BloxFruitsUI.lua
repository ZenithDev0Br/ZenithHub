-- [[ ZENITH HUB - FRONTEND (Nomes em Inglês / Informações em Português) ]] --

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
local label = Tab:AddParagraph("Player & World Status", "Aguardando sincronização...")

-- Loop automático de atualização da interface
task.spawn(function()
    while task.wait(1) do
        local InfoService = getgenv().ZenithHub and getgenv().ZenithHub.Modules and getgenv().ZenithHub.Modules.InfoService
        
        if InfoService and InfoService.Data then
            local d = InfoService.Data

            -- Formatação de Ilhas e Eventos do Mundo
            local mirageStatus      = d.Mirage and "🟢 Spawnada!" or "🔴 Não Encontrada"
            local kitsuneStatus     = d.Kitsune and "🟢 Spawnada!" or "🔴 Não Encontrada"
            local frozenStatus      = d.FrozenIsland and "🟢 Ativa!" or "🔴 Não Encontrada"
            local prehistoricStatus = d.PrehistoricIsland and "🟢 Spawnada!" or "🔴 Não Encontrada"
            local fruitSpStatus     = d.FruitSpawned and "🟢 SPAWNADA NO CHÃO!" or "🔴 Nenhuma"
            local factoryStatus     = d.Factory and "🟢 Ativo!" or "🔴 Inativo"
            local timeStatus        = d.FullMoon and "🌕 Noite" or "☀️ Dia"

            -- Formatação do Status do Player
            local leverStatus = d.PullLever and "🟢 Puxada! (Ativa)" or "🔴 Não Puxada"

            -- Formatação do Status dos Bosses Globais
            local ccStatus    = d.CursedCaptain and "🟢 VIVO!" or "🔴 Morto/Inativo"
            local dbStatus    = d.Darkbeard and "🟢 VIVO!" or "🔴 Morto/Inativo"
            local cpStatus    = d.CakePrince and "🟢 VIVO (Vá matar)!" or "🔴 Não invocado" 
            local dkStatus    = d.DoughKing and "🟢 VIVO (DOUGH KING)!" or "🔴 Não invocado"
            local indraStatus = d.RipIndra and "🟢 VIVO (Névoa Ativa)!" or "🔴 Sem Névoa"

            -- Montagem do texto estruturado com TÍTULOS EM INGLÊS e STATUS EM PORTUGUÊS
            local text =
                "Level: " .. tostring(d.Level or 0) .. " | Sea: " .. tostring(d.Sea or "Unknown") .. "\n" ..
                "Fruit: " .. tostring(d.Fruit or "None") .. "\n" ..
                "Pull Lever: " .. leverStatus .. "\n" ..
                "----------------------------------\n" ..
                "Moon Cycle: " .. tostring(d.MoonProgress or "Verificando...") .. "\n" ..
                "Current Time: " .. timeStatus .. "\n" ..
                "----------------------------------\n" ..
                "Fruit on Map: " .. fruitSpStatus .. "\n" ..
                "Mirage Island: " .. mirageStatus .. "\n" ..
                "Kitsune Island: " .. kitsuneStatus .. "\n" ..
                "Frozen Island: " .. frozenStatus .. "\n" ..
                "Prehistoric Island: " .. prehistoricStatus .. "\n" ..
                "Factory Event: " .. factoryStatus .. "\n" ..
                "----------------------------------\n" ..
                "🔱 BOSSES STATUS:\n" ..
                "• Cursed Captain: " .. ccStatus .. "\n" ..
                "• Darkbeard: " .. dbStatus .. "\n" ..
                "• Cake Prince: " .. cpStatus .. "\n" ..
                "• Dough King: " .. dkStatus .. "\n" ..
                "• rip_indra (True Form): " .. indraStatus

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
