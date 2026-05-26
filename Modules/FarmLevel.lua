local FarmLevel = {}
local LP = game:GetService("Players").LocalPlayer

function FarmLevel:Start()
    task.spawn(function()
        while task.wait(0.1) do
            if _G.AutoFarmLevel then
                -- LOGICA DE FARM AQUI
                -- Exemplo: 
                -- 1. Achar quest mais próxima
                -- 2. Teleportar para os mobs
                -- 3. Se _G.FastAttack for true, dar dano rápido
                -- 4. Se _G.BringMobs for true, mover os mobs para o player
            end
        end
    end)
end

function FarmLevel:Toggle(bool)
    _G.AutoFarmLevel = bool
    if bool then
        self:Start()
    end
end

getgenv().ZenithHub.Modules.FarmLevel = FarmLevel
return FarmLevel
