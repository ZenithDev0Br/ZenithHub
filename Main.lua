--[[
    ZenithHub Main
]]

local ZenithHub = getgenv().ZenithHub
local Core = ZenithHub.Core

Core:Notify("ZenithHub Loaded")

local Settings = {
    AutoFarm = false
}

task.spawn(function()
    while task.wait() do
        pcall(function()

            if Settings.AutoFarm then
                local Root = Core:GetRoot()

                if Root then
                    -- Farm logic
                end
            end

        end)
    end
end)
