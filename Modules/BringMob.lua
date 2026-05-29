local BringMob = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local TweenInfoBring = TweenInfo.new(
    0.45,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

local function IsRaidMob(mob)
    local n = mob.Name:lower()
    if n:find("raid") or n:find("microchip") or n:find("island") then return true end
    if mob:GetAttribute("IsRaid") or mob:GetAttribute("RaidMob") or mob:GetAttribute("IsBoss") then return true end
    local hum = mob:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed == 0 then return true end
    if mob.Parent and tostring(mob.Parent):lower():find("_worldorigin") then return true end
    return false
end

function BringMob:Cluster(enemyName)
    local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local bringRange = Settings and Settings.BringRange or 235
    local maxBring = Settings and Settings.MaxBringMobs or 3

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Expande o SimulationRadius igual ao Zyn Hub original
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)

    -- CORREÇÃO: pega a posição do mob alvo como ponto de atração (PosMon)
    -- Se não achar o mob pelo nome, usa a posição do personagem como fallback
    local targetPos = hrp.Position
    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if mob.Name == enemyName and mob:FindFirstChild("HumanoidRootPart") 
        and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            targetPos = mob.HumanoidRootPart.Position
            break
        end
    end

    -- CORREÇÃO: traz TODOS os mobs vivos no range, igual ao Zyn Hub original
    local count = 0
    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if count >= maxBring then break end

        local hum = mob:FindFirstChild("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 and not IsRaidMob(mob) then
            local dist = (root.Position - targetPos).Magnitude

            if dist <= bringRange and not root:GetAttribute("Tweening") then
                count = count + 1
                root:SetAttribute("Tweening", true)

                local tween = TweenService:Create(
                    root,
                    TweenInfoBring,
                    { CFrame = CFrame.new(targetPos) }
                )
                tween:Play()
                tween.Completed:Once(function()
                    if root then
                        root:SetAttribute("Tweening", false)
                    end
                end)
            end
        end
    end
end

return BringMob
