local AutoQuest = {}

local Players =
    game:GetService("Players")

local ReplicatedStorage =
    game:GetService("ReplicatedStorage")

local LocalPlayer =
    Players.LocalPlayer

local Remotes =
    ReplicatedStorage:WaitForChild("Remotes")

local CommF =
    Remotes:WaitForChild("CommF_")

AutoQuest.Quests = {

    {
        Min = 1,
        Max = 15,
        QuestName = "BanditQuest1",
        QuestLevel = 1,
        Enemy = "Bandit",
        QuestPosition = Vector3.new(1060, 17, 1547)
    },

    {
        Min = 15,
        Max = 30,
        QuestName = "JungleQuest",
        QuestLevel = 1,
        Enemy = "Monkey",
        QuestPosition = Vector3.new(-1604, 37, 152)
    }
}

function AutoQuest:GetLevel()

    local Data =
        LocalPlayer:FindFirstChild("Data")

    if not Data then
        return 0
    end

    local Level =
        Data:FindFirstChild("Level")

    return Level and Level.Value or 0
end

function AutoQuest:GetQuestData()

    local Level =
        self:GetLevel()

    for _, Quest in ipairs(self.Quests) do

        if Level >= Quest.Min
        and Level <= Quest.Max then

            return Quest
        end
    end
end

function AutoQuest:HasQuest()

    local PlayerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    if not PlayerGui then
        return false
    end

    local Main =
        PlayerGui:FindFirstChild("Main")

    if not Main then
        return false
    end

    local Quest =
        Main:FindFirstChild("Quest")

    if not Quest then
        return false
    end

    return Quest.Visible
end

function AutoQuest:StartQuest()

    if self:HasQuest() then
        return true
    end

    local QuestData =
        self:GetQuestData()

    if not QuestData then
        warn("[Quest] Quest não encontrada")
        return false
    end

    local Success, Result =
        pcall(function()

            return CommF:InvokeServer(
                "StartQuest",
                QuestData.QuestName,
                QuestData.QuestLevel
            )
        end)

    if Success then

        print("[Quest] Quest iniciada:",
            QuestData.Enemy)

        return true
    end

    warn("[Quest] Erro:",
        Result)

    return false
end

return AutoQuest
