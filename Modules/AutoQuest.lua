local AutoQuest = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ BANCO DE DADOS COMPLETO E OFICIAL (SEA 1, 2 E 3) COM ANTI-BUG DE CARREGAMENTO ]] --
_G.QuestConfig = {
    -- === SEA 1 ===
    { MinLevel = 0,    MaxLevel = 9,    NPCName = "Marine Leader",            QuestNameInGame = "MarineQuest",        QuestNumber = 1, MobName = "Trainee",              NPCPos = Vector3.new(-2707, 25, 807),    MobPos = Vector3.new(-2726, 25, 915) },
    { MinLevel = 0,    MaxLevel = 9,    NPCName = "Bandit Quest Giver",       QuestNameInGame = "BanditQuest1",       QuestNumber = 1, MobName = "Bandit",               NPCPos = Vector3.new(1059, 16, 1549),    MobPos = Vector3.new(1145, 17, 1630) },
    { MinLevel = 10,   MaxLevel = 14,   NPCName = "Adventurer",               QuestNameInGame = "JungleQuest",        QuestNumber = 1, MobName = "Monkey",               NPCPos = Vector3.new(-1611, 37, 153),    MobPos = Vector3.new(-1610, 22, 178) },
    { MinLevel = 15,   MaxLevel = 29,   NPCName = "Adventurer",               QuestNameInGame = "JungleQuest",        QuestNumber = 2, MobName = "Gorilla",              NPCPos = Vector3.new(-1611, 37, 153),    MobPos = Vector3.new(-1233, 6, -493) }, 
    { MinLevel = 30,   MaxLevel = 39,   NPCName = "Pirate Adventurer",        QuestNameInGame = "BuggyQuest1",        QuestNumber = 1, MobName = "Pirate",               NPCPos = Vector3.new(-1141, 5, 3856),    MobPos = Vector3.new(-1201, 5, 3926) },
    { MinLevel = 40,   MaxLevel = 59,   NPCName = "Pirate Adventurer",        QuestNameInGame = "BuggyQuest1",        QuestNumber = 2, MobName = "Brute",                NPCPos = Vector3.new(-1141, 5, 3856),    MobPos = Vector3.new(-1353, 15, 3328) },  
    { MinLevel = 60,   MaxLevel = 74,   NPCName = "Desert Adventurer",        QuestNameInGame = "DesertQuest",        QuestNumber = 1, MobName = "Desert Bandit",        NPCPos = Vector3.new(894, 6, 4388),      MobPos = Vector3.new(992, 6, 4441) },
    { MinLevel = 75,   MaxLevel = 89,   NPCName = "Desert Adventurer",        QuestNameInGame = "DesertQuest",        QuestNumber = 2, MobName = "Desert Officer",       NPCPos = Vector3.new(894, 6, 4388),      MobPos = Vector3.new(1185, 6, 4325) },
    { MinLevel = 90,   MaxLevel = 99,   NPCName = "Villager",                 QuestNameInGame = "SnowQuest",          QuestNumber = 1, MobName = "Snow Bandit",          NPCPos = Vector3.new(1386, 24, -1314),   MobPos = Vector3.new(1289, 26, -1342) },
    { MinLevel = 100,  MaxLevel = 119,  NPCName = "Villager",                 QuestNameInGame = "SnowQuest",          QuestNumber = 2, MobName = "Snowman",              NPCPos = Vector3.new(1386, 24, -1314),   MobPos = Vector3.new(1287, 149, -1504) }, 
    { MinLevel = 120,  MaxLevel = 149,  NPCName = "Marine",                   QuestNameInGame = "MarineQuest2",       QuestNumber = 1, MobName = "Chief Petty Officer",  NPCPos = Vector3.new(-5036, 24, 4323),   MobPos = Vector3.new(-4881, 23, 4322) }, 
    { MinLevel = 150,  MaxLevel = 174,  NPCName = "Sky Adventurer",           QuestNameInGame = "SkyQuest",           QuestNumber = 1, MobName = "Sky Bandit",           NPCPos = Vector3.new(-4840, 718, -2623), MobPos = Vector3.new(-4974, 718, -2620) },
    { MinLevel = 175,  MaxLevel = 224,  NPCName = "Sky Adventurer",           QuestNameInGame = "SkyQuest",           QuestNumber = 2, MobName = "Dark Master",          NPCPos = Vector3.new(-4840, 718, -2623), MobPos = Vector3.new(-5223, 743, -2225) }, 
    { MinLevel = 225,  MaxLevel = 249,  NPCName = "Colosseum Quest Giver",    QuestNameInGame = "ColosseumQuest",     QuestNumber = 1, MobName = "Toga Warrior",         NPCPos = Vector3.new(-1580, 7, -2982),   MobPos = Vector3.new(-1805, 7, -2763) },
    { MinLevel = 250,  MaxLevel = 299,  NPCName = "Colosseum Quest Giver",    QuestNameInGame = "ColosseumQuest",     QuestNumber = 2, MobName = "Gladiator",            NPCPos = Vector3.new(-1580, 7, -2982),   MobPos = Vector3.new(-1805, 7, -3318) },
    { MinLevel = 300,  MaxLevel = 324,  NPCName = "The Mayor",                QuestNameInGame = "MagmaQuest",         QuestNumber = 1, MobName = "Military Soldier",     NPCPos = Vector3.new(-5313, 12, 8516),   MobPos = Vector3.new(-5407, 11, 8448) },
    { MinLevel = 325,  MaxLevel = 374,  NPCName = "The Mayor",                QuestNameInGame = "MagmaQuest",         QuestNumber = 2, MobName = "Military Spy",         NPCPos = Vector3.new(-5313, 12, 8516),   MobPos = Vector3.new(-5816, 73, 8432) }, 
    { MinLevel = 375,  MaxLevel = 399,  NPCName = "King Neptune",             QuestNameInGame = "FishmanQuest",       QuestNumber = 1, MobName = "Fishman Warrior",      NPCPos = Vector3.new(61122, 18, 1567),   MobPos = Vector3.new(61002, 18, 1485) },
    { MinLevel = 400,  MaxLevel = 624,  NPCName = "King Neptune",             QuestNameInGame = "FishmanQuest",       QuestNumber = 2, MobName = "Fishman Commando",     NPCPos = Vector3.new(61122, 18, 1567),   MobPos = Vector3.new(62012, 18, 1435) }, 
    { MinLevel = 625,  MaxLevel = 649,  NPCName = "Freezeburg Quest Giver",   QuestNameInGame = "FountainQuest",      QuestNumber = 1, MobName = "Galley Pirate",        NPCPos = Vector3.new(5258, 39, 4050),    MobPos = Vector3.new(5562, 39, 3965) },
    { MinLevel = 650,  MaxLevel = 699,  NPCName = "Freezeburg Quest Giver",   QuestNameInGame = "FountainQuest",      QuestNumber = 2, MobName = "Galley Captain",       NPCPos = Vector3.new(5258, 39, 4050),    MobPos = Vector3.new(5654, 39, 4895) }, 

    -- === SEA 2 ===
    { MinLevel = 700,  MaxLevel = 724,  NPCName = "Area 1 Quest Giver",       QuestNameInGame = "Area1Quest",         QuestNumber = 1, MobName = "Raider",               NPCPos = Vector3.new(-425, 73, 1836),    MobPos = Vector3.new(-750, 73, 1720) },
    { MinLevel = 725,  MaxLevel = 774,  NPCName = "Area 1 Quest Giver",       QuestNameInGame = "Area1Quest",         QuestNumber = 2, MobName = "Mercenary",            NPCPos = Vector3.new(-425, 73, 1836),    MobPos = Vector3.new(-925, 73, 1315) }, 
    { MinLevel = 775,  MaxLevel = 799,  NPCName = "Area 2 Quest Giver",       QuestNameInGame = "Area2Quest",         QuestNumber = 1, MobName = "Swan Pirate",          NPCPos = Vector3.new(913, 120, 1312),    MobPos = Vector3.new(875, 121, 1412) },
    { MinLevel = 800,  MaxLevel = 874,  NPCName = "Area 2 Quest Giver",       QuestNameInGame = "Area2Quest",         QuestNumber = 2, MobName = "Factory Staff",        NPCPos = Vector3.new(913, 120, 1312),    MobPos = Vector3.new(315, 122, 1640) }, 
    { MinLevel = 875,  MaxLevel = 899,  NPCName = "Marine Quest Giver",       QuestNameInGame = "MarineQuest3",       QuestNumber = 1, MobName = "Marine Lieutenant",    NPCPos = Vector3.new(-5039, 24, -4715),  MobPos = Vector3.new(-4820, 23, -4645) },
    { MinLevel = 900,  MaxLevel = 949,  NPCName = "Marine Quest Giver",       QuestNameInGame = "MarineQuest3",       QuestNumber = 2, MobName = "Marine Captain",       NPCPos = Vector3.new(-5039, 24, -4715),  MobPos = Vector3.new(-5005, 23, -4435) }, 
    { MinLevel = 950,  MaxLevel = 974,  NPCName = "Graveyard Quest Giver",    QuestNameInGame = "ZombieQuest",        QuestNumber = 1, MobName = "Zombie",               NPCPos = Vector3.new(-5422, 8, -751),    MobPos = Vector3.new(-5660, 8, -735) },
    { MinLevel = 975,  MaxLevel = 999,  NPCName = "Graveyard Quest Giver",    QuestNameInGame = "ZombieQuest",        QuestNumber = 2, MobName = "Vampire",              NPCPos = Vector3.new(-5422, 8, -751),    MobPos = Vector3.new(-6015, 6, -1250) },
    { MinLevel = 1000, MaxLevel = 1049, NPCName = "Snow Quest Giver",         QuestNameInGame = "SnowMountainQuest",  QuestNumber = 1, MobName = "Snow Trooper",         NPCPos = Vector3.new(611, 401, -5462),   MobPos = Vector3.new(515, 401, -5380) },
    { MinLevel = 1050, MaxLevel = 1099, NPCName = "Snow Quest Giver",         QuestNameInGame = "SnowMountainQuest",  QuestNumber = 2, MobName = "Winter Warrior",       NPCPos = Vector3.new(611, 401, -5462),   MobPos = Vector3.new(1150, 425, -5300) },
    { MinLevel = 1100, MaxLevel = 1124, NPCName = "Ice Quest Giver",          QuestNameInGame = "IceSideQuest",       QuestNumber = 1, MobName = "Lab Subordinate",      NPCPos = Vector3.new(-6060, 16, -4905),  MobPos = Vector3.new(-5850, 16, -4915) },
    { MinLevel = 1125, MaxLevel = 1174, NPCName = "Ice Quest Giver",          QuestNameInGame = "IceSideQuest",       QuestNumber = 2, MobName = "Horned Warrior",       NPCPos = Vector3.new(-6060, 16, -4905),  MobPos = Vector3.new(-6370, 16, -4850) }, 
    { MinLevel = 1175, MaxLevel = 1200, NPCName = "Forgotten Quest Giver",   QuestNameInGame = "ForgottenQuest",     QuestNumber = 1, MobName = "Sea Soldier",          NPCPos = Vector3.new(-3055, 240, -10145), MobPos = Vector3.new(-3005, 240, -9980) },
    { MinLevel = 1201, MaxLevel = 1499, NPCName = "Forgotten Quest Giver",   QuestNameInGame = "ForgottenQuest",     QuestNumber = 2, MobName = "Water Fighter",        NPCPos = Vector3.new(-3055, 240, -10145), MobPos = Vector3.new(-3345, 240, -10540) }, 

    -- === SEA 3 ===
    { MinLevel = 1500, MaxLevel = 1524, NPCName = "Port Town Quest Giver",    QuestNameInGame = "PiratePortQuest",    QuestNumber = 1, MobName = "Pirate Millionaire",   NPCPos = Vector3.new(-290, 7, 5326),     MobPos = Vector3.new(-475, 7, 5310) },
    { MinLevel = 1525, MaxLevel = 1574, NPCName = "Port Town Quest Giver",    QuestNameInGame = "PiratePortQuest",    QuestNumber = 2, MobName = "Pistol Billionaire",   NPCPos = Vector3.new(-290, 7, 5326),     MobPos = Vector3.new(-280, 7, 5530) }, 
    { MinLevel = 1575, MaxLevel = 1599, NPCName = "Hydra Island Quest Giver", QuestNameInGame = "AmazonQuest",        QuestNumber = 1, MobName = "Dragon Crew Warrior",  NPCPos = Vector3.new(5700, 602, 190),    MobPos = Vector3.new(5790, 602, 110) },
    { MinLevel = 1600, MaxLevel = 1699, NPCName = "Hydra Island Quest Giver", QuestNameInGame = "AmazonQuest",        QuestNumber = 2, MobName = "Dragon Crew Archer",   NPCPos = Vector3.new(5700, 602, 190),    MobPos = Vector3.new(6050, 602, 230) }, 
    { MinLevel = 1700, MaxLevel = 1724, NPCName = "Great Tree Quest Giver",   QuestNameInGame = "MarineTreeIsland",   QuestNumber = 1, MobName = "Marine Commodore",     NPCPos = Vector3.new(4045, 8, -2630),    MobPos = Vector3.new(4410, 8, -2740) },
    { MinLevel = 1725, MaxLevel = 1774, NPCName = "Great Tree Quest Giver",   QuestNameInGame = "MarineTreeIsland",   QuestNumber = 2, MobName = "Marine Rear Admiral",  NPCPos = Vector3.new(4045, 8, -2630),    MobPos = Vector3.new(4650, 22, -3520) }, 
    { MinLevel = 1775, MaxLevel = 1799, NPCName = "Turtle Quest Giver",       QuestNameInGame = "DeepForestIsland3",  QuestNumber = 1, MobName = "Fishman Raider",       NPCPos = Vector3.new(-1565, 8, -14185),  MobPos = Vector3.new(-1805, 8, -14240) },
    { MinLevel = 1800, MaxLevel = 1824, NPCName = "Turtle Quest Giver",       QuestNameInGame = "DeepForestIsland3",  QuestNumber = 2, MobName = "Fishman Captain",      NPCPos = Vector3.new(-1565, 8, -14185),  MobPos = Vector3.new(-2120, 8, -14510) },
    { MinLevel = 1825, MaxLevel = 1849, NPCName = "Turtle Quest Giver 2",     QuestNameInGame = "DeepForestIsland",   QuestNumber = 1, MobName = "Forest Pirate",        NPCPos = Vector3.new(-2185, 45, -10210), MobPos = Vector3.new(-2350, 45, -10180) },
    { MinLevel = 1850, MaxLevel = 1974, NPCName = "Turtle Quest Giver 2",     QuestNameInGame = "DeepForestIsland",   QuestNumber = 2, MobName = "Mythological Pirate",  NPCPos = Vector3.new(-2185, 45, -10210), MobPos = Vector3.new(-2515, 45, -10520) }, 
    { MinLevel = 1975, MaxLevel = 1999, NPCName = "Haunted Quest Giver",      QuestNameInGame = "HauntedQuest1",      QuestNumber = 1, MobName = "Reborn Skeleton",      NPCPos = Vector3.new(-9515, 164, 5780),  MobPos = Vector3.new(-9345, 164, 5650) },
    { MinLevel = 2000, MaxLevel = 2024, NPCName = "Haunted Quest Giver",      QuestNameInGame = "HauntedQuest1",      QuestNumber = 2, MobName = "Living Zombie",        NPCPos = Vector3.new(-9515, 164, 5780),  MobPos = Vector3.new(-9610, 164, 6120) },
    { MinLevel = 2025, MaxLevel = 2049, NPCName = "Haunted Quest Giver 2",    QuestNameInGame = "HauntedQuest2",      QuestNumber = 1, MobName = "Demonic Soul",         NPCPos = Vector3.new(-9518, 164, 5130),  MobPos = Vector3.new(-9350, 164, 5020) },
    { MinLevel = 2050, MaxLevel = 2199, NPCName = "Haunted Quest Giver 2",    QuestNameInGame = "HauntedQuest2",      QuestNumber = 2, MobName = "Posessed Mummy",       NPCPos = Vector3.new(-9518, 164, 5130),  MobPos = Vector3.new(-9580, 164, 4820) }, 
    { MinLevel = 2200, MaxLevel = 2224, NPCName = "Cookie Quest Giver",       QuestNameInGame = "CakeQuest1",         QuestNumber = 1, MobName = "Cookie Crafter",       NPCPos = Vector3.new(-1160, 38, -14250), MobPos = Vector3.new(-1050, 38, -14150) },
    { MinLevel = 2225, MaxLevel = 2249, NPCName = "Cookie Quest Giver",       QuestNameInGame = "CakeQuest1",         QuestNumber = 2, MobName = "Cake Guard",           NPCPos = Vector3.new(-1160, 38, -14250), MobPos = Vector3.new(-1250, 38, -14510) },
    { MinLevel = 2250, MaxLevel = 2274, NPCName = "Cake Quest Giver",         QuestNameInGame = "CakeQuest2",         QuestNumber = 1, MobName = "Baking Staff",         NPCPos = Vector3.new(-1910, 38, -14225), MobPos = Vector3.new(-1805, 38, -14110) },
    { MinLevel = 2275, MaxLevel = 9999, NPCName = "Cake Quest Giver",         QuestNameInGame = "CakeQuest2",         QuestNumber = 2, MobName = "Head Baker",           NPCPos = Vector3.new(-1910, 38, -14225), MobPos = Vector3.new(-2020, 38, -14550) }
}

local function EncontrarPosicaoNoMapa(nomeDoObjeto)
    local objeto = workspace:FindFirstChild(nomeDoObjeto, true)
    if objeto and objeto:FindFirstChild("HumanoidRootPart") then
        return objeto.HumanoidRootPart.Position
    end
    local spawnFolder = workspace:FindFirstChild("SpawnPoints", true)
    if spawnFolder and spawnFolder:FindFirstChild(nomeDoObjeto) then
        return spawnFolder[nomeDoObjeto].Position
    end
    return nil
end

function AutoQuest:GetQuestData()
    local level = LocalPlayer.Data.Level.Value
    local configAlvo = nil

    if level >= 0 and level <= 9 then
        local team = tostring(LocalPlayer.Team)
        for _, dados in pairs(_G.QuestConfig) do
            if team:match("Marine") and dados.NPCName == "Marine Leader" then
                configAlvo = dados
                break
            elseif (team:match("Pirate") or team:match("Changer")) and dados.NPCName == "Bandit Quest Giver" then
                configAlvo = dados
                break
            end
        end
    end

    if not configAlvo then
        for _, dados in pairs(_G.QuestConfig) do
            if level >= dados.MinLevel and level <= dados.MaxLevel then
                configAlvo = dados
                break
            end
        end
    end

    configAlvo = configAlvo or _G.QuestConfig[2]

    -- Pega a posição dinâmica ou usa o vetor fixo correspondente à ilha/sea atual!
    local posNPC = EncontrarPosicaoNoMapa(configAlvo.NPCName) or configAlvo.NPCPos or Vector3.new(1059, 16, 1549)
    local posMob = EncontrarPosicaoNoMapa(configAlvo.MobName) or configAlvo.MobPos or posNPC

    return {
        Enemy = configAlvo.MobName,
        QuestName = configAlvo.QuestNameInGame,
        QuestID = configAlvo.QuestNumber,
        NPCRealName = configAlvo.NPCName,
        QuestPosition = posNPC,
        EnemyPosition = posMob
    }
end

function AutoQuest:HasQuest()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return false end

    local caminhosQuest = {
        PlayerGui:FindFirstChild("my") and PlayerGui.my:FindFirstChild("Quest"),
        PlayerGui:FindFirstChild("my") and PlayerGui.my:FindFirstChild("quest"),
        PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("Quest"),
        PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("quest")
    }

    for _, frame in pairs(caminhosQuest) do
        if frame and frame.Visible and frame:FindFirstChild("Container") then
            return true
        end
    end
    return false
end

function AutoQuest:StartQuest()
    if self:HasQuest() then return end
    
    local dados = self:GetQuestData()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    
    if Remote then
        pcall(function()
            Remote:InvokeServer("StartQuest", dados.QuestName, dados.QuestID)
        end)
        
        task.spawn(function()
            task.wait(0.2)
            if not self:HasQuest() then
                local npc = workspace:FindFirstChild(dados.NPCRealName, true)
                if npc then
                    local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true) or npc:FindFirstChild("Interaction", true)
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end)
    end
end

return AutoQuest
