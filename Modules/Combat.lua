local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommE = Remotes:WaitForChild("CommE")
local CommF = Remotes:WaitForChild("CommF_")

-- Ken: verifica pela tag do CollectionService, igual ao Zyn Hub original
local function HasKen()
    local char = LocalPlayer.Character
    return char and CollectionService:HasTag(char, "Ken")
end

-- Loop do Ken (roda enquanto AutoKen estiver true)
local kenLoop = nil
function Combat:StartKen()
    if kenLoop then return end
    kenLoop = task.spawn(function()
        while true do
            task.wait(0.2)
            local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (Settings and Settings.AutoKen) then continue end
            if not HasKen() then
                pcall(function()
                    CommE:FireServer("Ken", true)
                end)
            end
        end
    end)
end

function Combat:Attack()
    local character = LocalPlayer.Character
    if not character or character.Humanoid.Health <= 0 then return end

    -- Clique físico simulado para disparar animação
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(300, 300))
    end)

    -- Remote de ataque do servidor
    if CommF then
        task.spawn(function()
            pcall(function()
                CommF:InvokeServer("Attack", 0)
            end)
        end)
    end
end

-- Inicia o loop do Ken automaticamente ao carregar o módulo
Combat:StartKen()

return Combat
