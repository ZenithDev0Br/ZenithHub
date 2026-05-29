local BringMob = {}

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local TweenInfoBring = TweenInfo.new(
    0.45, -- Velocidade de atração idêntica à Zyn Hub
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

-- Filtro para ignorar bosses e monstros de Raid bugados
local function IsRaidOrBossMob(mob)
    local name = mob.Name:lower()
    if name:find("raid") or name:find("microchip") or name:find("island") then  
        return true  
    end  
    if mob:GetAttribute("IsRaid") or mob:GetAttribute("RaidMob") or mob:GetAttribute("IsBoss") then  
        return true  
    end  
    local hum = mob:FindFirstChild("Humanoid")  
    if hum and hum.WalkSpeed == 0 then  
        return true  
    end  
    return false
end

function BringMob:Cluster(enemyName)
    local Settings = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
    local bringRange = Settings and Settings.BringRange or 235
    local maxBring = Settings and Settings.MaxBringMobs or 3

    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Força a rede do Roblox a aceitar controle da física dos monstros ao redor
    pcall(function()  
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)  
    end)  

    -- O ponto central é onde os monstros vão se agrupar (posição fixa gravada do primeiro mob)
    local targetMob = Workspace.Enemies:FindFirstChild(enemyName)
    local targetPos = nil

    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
        if not targetMob:GetAttribute("LockedPos") then
            targetMob:SetAttribute("LockedPos", targetMob.HumanoidRootPart.CFrame)
        end
        targetPos = targetMob:GetAttribute("LockedPos").Position
    else
        targetPos = hrp.Position
    end

    local count = 0
    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
        if count >= maxBring then break end

        if mob.Name == enemyName and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local hum = mob.Humanoid
            local m_hrp = mob.HumanoidRootPart

            if hum.Health > 0 and not IsRaidOrBossMob(mob) then
                local distance = (m_hrp.Position - hrp.Position).Magnitude

                if distance <= bringRange and not m_hrp:GetAttribute("Tweening") then
                    count = count + 1
                    m_hrp:SetAttribute("Tweening", true)

                    local tween = TweenService:Create(
                        m_hrp,
                        TweenInfoBring,
                        {CFrame = CFrame.new(targetPos)}
                    )
                    tween:Play()

                    tween.Completed:Once(function()
                        if m_hrp then
                            m_hrp:SetAttribute("Tweening", false)
                        end
                    end)
                end
            end
        end
    end
end

return BringMob
