local ZenithHub = getgenv().ZenithHub
local Core = ZenithHub.Core

local Settings = ZenithHub.Settings

Core:Notify("Main Loaded")

task.spawn(function()
    while task.wait(1) do

        if Settings.Enabled then
            local root = Core:GetRoot()
            if root then
                -- lógica principal do sistema
                print("Running main loop")
            end
        end

    end
end)
