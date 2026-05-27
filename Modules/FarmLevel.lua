local Farm = {}

local ZenithHub =
    getgenv().ZenithHub

local Modules =
    ZenithHub.Modules

local Settings =
    Modules.FarmSettings

function Farm:Start()

    task.spawn(function()

        while task.wait() do

            if not Settings.AutoFarmLevel then
                continue
            end

            print("Farmando...")
        end
    end)
end

return Farm
