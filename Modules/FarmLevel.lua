local Farm = {}

local ZenithHub =
    getgenv().ZenithHub

local Modules =
    ZenithHub.Modules

local Settings =
    Modules.FarmSettings

local AutoQuest =
    Modules.AutoQuest

function Farm:Start()

    task.spawn(function()

        while task.wait(1) do

            if not Settings.AutoFarmLevel then
                continue
            end

            if not AutoQuest:HasQuest() then

                AutoQuest:StartQuest()

                task.wait(2)
            end

            print("Farm ativo...")
        end
    end)
end

return Farm
