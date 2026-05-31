local FarmLevel = {
    Enabled = false
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local noclipConnection = nil
local currentLoopID = 0

local function setNoClip(state)
    if state then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hum or hum.Health <= 0 then return end
    return char, hrp
end

function FarmLevel:Start()
    local ZenithHub = getgenv().ZenithHub
    local Modules = ZenithHub and ZenithHub.Modules
    if not Modules then return end

    local AutoQuest = Modules.AutoQuest
    local Tween = Modules.Tween
    local Combat = Modules.Combat
    local Weapon = Modules.Weapon
    local BringMob = Modules.BringMob
    local Settings = Modules.FarmSettings
    local AttackController = Modules.AttackController

    if self.Enabled then return end

    currentLoopID += 1
    local myLoopID = currentLoopID
    self.Enabled = true

    task.spawn(function()
        while self.Enabled and currentLoopID == myLoopID do
            task.wait(0.05)

            local character, hrp = getCharacter()
            if not character or not hrp then
                setNoClip(false)
                continue
            end

            local isFarmActive = Settings and Settings.AutoFarmLevel
            if not isFarmActive then
                setNoClip(false)
                continue
            end

            setNoClip(true)

            local QuestData = AutoQuest and AutoQuest:GetQuestData()
            if not QuestData then continue end

            -- ESCUDO UI
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local MainGui = PlayerGui and PlayerGui:FindFirstChild("Main")

            if MainGui then
                local dialogue = MainGui:FindFirstChild("Dialogue")
                if dialogue and dialogue.Visible then
                    dialogue.Visible = false
                end
            end

            -- QUEST CHECK
            if not AutoQuest:HasQuest() then
                local npcCFrame = CFrame.new(QuestData.QuestPosition) * CFrame.new(0, 12, 0)

                if Tween and Tween.MoveTo then
                    Tween:MoveTo(npcCFrame)
                else
                    hrp.CFrame = npcCFrame
                end

                if (hrp.Position - QuestData.QuestPosition).Magnitude < 30 then
                    AutoQuest:StartQuest()
                    task.wait(0.5)
                end

                continue
            end

            -- COMBATE
            local targetMob

            local folder = Workspace:FindFirstChild("Enemies") or Workspace
            for _, v in ipairs(folder:GetChildren()) do
                if v.Name == QuestData.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    targetMob = v
                    break
                end
            end

            if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                if Weapon and Weapon.Equip then
                    Weapon:Equip()
                end

                local targetCFrame = targetMob.HumanoidRootPart.CFrame

                if AttackController then
                    targetCFrame = AttackController:GetOffsetCFrame(targetCFrame)
                else
                    local Settings = Modules.FarmSettings
                    local height = Settings and Settings.AttackHeight or 22
                    local dist = Settings and Settings.AttackDistance or 0
                    targetCFrame = targetCFrame * CFrame.new(0, height, dist)
                end

                if (hrp.Position - targetCFrame.Position).Magnitude > 1 then
                    hrp.CFrame = targetCFrame
                end

                local bringMobsActive = Settings and Settings.BringMobs
                if bringMobsActive and BringMob and BringMob.Cluster then
                    BringMob:Cluster(QuestData.Enemy)
                end

                local fastAttack = Settings and Settings.FastAttack
                if fastAttack and Combat and Combat.Attack then
                    Combat:Attack()
                end
            else
                if QuestData.EnemyPosition then
                    local targetPos = typeof(QuestData.EnemyPosition) == "Vector3"
                        and CFrame.new(QuestData.EnemyPosition)
                        or QuestData.EnemyPosition

                    if Tween and Tween.MoveTo then
                        Tween:MoveTo(targetPos)
                    else
                        hrp.CFrame = targetPos
                    end
                end
            end
        end

        if currentLoopID == myLoopID then
            setNoClip(false)
        end
    end)
end

function FarmLevel:Stop()
    self.Enabled = false
    currentLoopID += 1
    setNoClip(false)
end

return FarmLevel
