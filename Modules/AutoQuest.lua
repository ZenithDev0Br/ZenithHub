local AutoQuest = {}

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Sea1 =
loadstring(readfile("ZenithHub/Modules/QuestData/Sea1.lua"))()

local Sea2 =
loadstring(readfile("ZenithHub/Modules/QuestData/Sea2.lua"))()

local Sea3 =
loadstring(readfile("ZenithHub/Modules/QuestData/Sea3.lua"))()

AutoQuest.Quests = {}

-- MERGE
for _, v in pairs(Sea1) do
    table.insert(AutoQuest.Quests, v)
end

for _, v in pairs(Sea2) do
    table.insert(AutoQuest.Quests, v)
end

for _, v in pairs(Sea3) do
    table.insert(AutoQuest.Quests, v)
end

function AutoQuest:GetLevel()

    local data =
        LocalPlayer:FindFirstChild("Data")

    if not data then
        return 0
    end

    local level =
        data:FindFirstChild("Level")

    return level and level.Value or 0
end

function AutoQuest:GetQuest()

    local level = self:GetLevel()

    for _, quest in pairs(self.Quests) do

        if level >= quest.Min
            and level <= quest.Max then

            return quest
        end
    end
end

function AutoQuest:HasQuest()

    local gui =
        LocalPlayer.PlayerGui:FindFirstChild("Main")

    if not gui then
        return false
    end

    local quest =
        gui:FindFirstChild("Quest")

    return quest and quest.Visible
end

function AutoQuest:StartQuest()

    local questData = self:GetQuest()

    if not questData then
        return
    end

    local remotes =
        game.ReplicatedStorage:FindFirstChild("Remotes")

    if remotes and remotes:FindFirstChild("CommF_") then

        remotes.CommF_:InvokeServer(
            "StartQuest",
            questData.QuestName,
            questData.QuestLevel
        )

    end
end

return AutoQuest
