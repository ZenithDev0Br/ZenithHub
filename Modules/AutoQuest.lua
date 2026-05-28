local AutoQuest = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ BANCO DE DADOS OFICIAL - INCLUINDO MARINE E PIRATE STARTER ]] --
_G.QuestConfig = {
    -- === SEA 1 ===
    { MinLevel = 0,    MaxLevel = 9,    NPCName = "Marine Leader",            QuestNameInGame = "MarineQuest",        QuestNumber = 1, MobName = "Trainee" }, -- ADICIONADO: Starter Marine
    { MinLevel = 0,    MaxLevel = 9,    NPCName = "Bandit Quest Giver",       QuestNameInGame = "BanditQuest1",       QuestNumber = 1, MobName = "Bandit" },  -- Starter Pirate
    { MinLevel = 10,   MaxLevel = 14,   NPCName = "Adventurer",               QuestNameInGame = "JungleQuest",        QuestNumber = 1, MobName = "Monkey" },
    { MinLevel = 15,   MaxLevel = 29,   NPCName = "Adventurer",               QuestNameInGame = "JungleQuest",        QuestNumber = 2, MobName = "Gorilla" }, 
    { MinLevel = 30,   MaxLevel = 39,   NPCName = "Pirate Adventurer",        QuestNameInGame = "BuggyQuest1",        QuestNumber = 1, MobName = "Pirate" },
    { MinLevel = 40,   MaxLevel = 59,   NPCName = "Pirate Adventurer",        QuestNameInGame = "BuggyQuest1",        QuestNumber = 2, MobName = "Brute" },  
    { MinLevel = 60,   MaxLevel = 74,   NPCName = "Desert Adventurer",        QuestNameInGame = "DesertQuest",        QuestNumber = 1, MobName = "Desert Bandit" },
    { MinLevel = 75,   MaxLevel = 89,   NPCName = "Desert Adventurer",        QuestNameInGame = "DesertQuest",        QuestNumber = 2, MobName = "Desert Officer" },
    { MinLevel = 90,   MaxLevel = 99,   NPCName = "Villager",                 QuestNameInGame = "SnowQuest",          QuestNumber = 1, MobName = "Snow Bandit" },
    { MinLevel = 100,  MaxLevel = 119,  NPCName = "Villager",                 QuestNameInGame = "SnowQuest",          QuestNumber = 2, MobName = "Snowman" }, 
    { MinLevel = 120,  MaxLevel = 149,  NPCName = "Marine",                   QuestNameInGame = "MarineQuest2",       QuestNumber = 1, MobName = "Chief Petty Officer" }, 
    { MinLevel = 150,  MaxLevel = 174,  NPCName = "Sky Adventurer",           QuestNameInGame = "SkyQuest",           QuestNumber = 1, MobName = "Sky Bandit" },
    { MinLevel = 175,  MaxLevel = 224,  NPCName = "Sky Adventurer",           QuestNameInGame = "SkyQuest",           QuestNumber = 2, MobName = "Dark Master" }, 
    { MinLevel = 225,  MaxLevel = 249,  NPCName = "Colosseum Quest Giver",    QuestNameInGame = "ColosseumQuest",     QuestNumber = 1, MobName = "Toga Warrior" },
    { MinLevel = 250,  MaxLevel = 299,  NPCName = "Colosseum Quest Giver",    QuestNameInGame = "ColosseumQuest",     QuestNumber = 2, MobName = "Gladiator" },
    { MinLevel = 300,  MaxLevel = 324,  NPCName = "The Mayor",                QuestNameInGame = "MagmaQuest",         QuestNumber = 1, MobName = "Military Soldier" },
    { MinLevel = 325,  MaxLevel = 374,  NPCName = "The Mayor",                QuestNameInGame = "MagmaQuest",         QuestNumber = 2, MobName = "Military Spy" }, 
    { MinLevel = 375,  MaxLevel = 399,  NPCName = "King Neptune",             QuestNameInGame = "FishmanQuest",       QuestNumber = 1, MobName = "Fishman Warrior" },
    { MinLevel = 400,  MaxLevel = 624,  NPCName = "King Neptune",             QuestNameInGame = "FishmanQuest",       QuestNumber = 2, MobName = "Fishman Commando" }, 
    { MinLevel = 625,  MaxLevel = 649,  NPCName = "Freezeburg Quest Giver",   QuestNameInGame = "FountainQuest",      QuestNumber = 1, MobName = "Galley Pirate" },
    { MinLevel = 650,  MaxLevel = 699,  NPCName = "Freezeburg Quest Giver",   QuestNameInGame = "FountainQuest",      QuestNumber = 2, MobName = "Galley Captain" }, 

    -- === SEA 2 ===
    { MinLevel = 700,  MaxLevel = 724,  NPCName = "Area 1 Quest Giver",       QuestNameInGame = "Area1Quest",         QuestNumber = 1, MobName = "Raider" },
    { MinLevel = 725,  MaxLevel = 774,  NPCName = "Area 1 Quest Giver",       QuestNameInGame = "Area1Quest",         QuestNumber = 2, MobName = "Mercenary" }, 
    { MinLevel = 775,  MaxLevel = 799,  NPCName = "Area 2 Quest Giver",       QuestNameInGame = "Area2Quest",         QuestNumber = 1, MobName = "Swan Pirate" },
    { MinLevel = 800,  MaxLevel = 874,  NPCName = "Area 2 Quest Giver",       QuestNameInGame = "Area2Quest",         QuestNumber = 2, MobName = "Factory Staff" }, 
    { MinLevel = 875,  MaxLevel = 899,  NPCName = "Marine Quest Giver",       QuestNameInGame = "MarineQuest3",       QuestNumber = 1, MobName = "Marine Lieutenant" },
    { MinLevel = 900,  MaxLevel = 949,  NPCName = "Marine Quest Giver",       QuestNameInGame = "MarineQuest3",       QuestNumber = 2, MobName = "Marine Captain" }, 
    { MinLevel = 950,  MaxLevel = 974,  NPCName = "Graveyard Quest Giver",    QuestNameInGame = "ZombieQuest",        QuestNumber = 1, MobName = "Zombie" },
    { MinLevel = 975,  MaxLevel = 999,  NPCName = "Graveyard Quest Giver",    QuestNameInGame = "ZombieQuest",        QuestNumber = 2, MobName = "Vampire" },
    { MinLevel = 1000, MaxLevel = 1049, NPCName = "Snow Quest Giver",         QuestNameInGame = "SnowMountainQuest",  QuestNumber = 1, MobName = "Snow Trooper" },
    { MinLevel = 1050, MaxLevel = 1099, NPCName = "Snow Quest Giver",         QuestNameInGame = "SnowMountainQuest",  QuestNumber = 2, MobName = "Winter Warrior" },
    { MinLevel = 1100, MaxLevel = 1124, NPCName = "Ice Quest Giver",          QuestNameInGame = "IceSideQuest",       QuestNumber = 1, MobName = "Lab Subordinate" },
    { MinLevel = 1125, MaxLevel = 1174, NPCName = "Ice Quest Giver",          QuestNameInGame = "IceSideQuest",       QuestNumber = 2, MobName = "Horned Warrior" }, 
    { MinLevel = 1175, MaxLevel = 1200, NPCName = "Forgotten Quest Giver",   QuestNameInGame = "ForgottenQuest",     QuestNumber = 1, MobName = "Sea Soldier" },
    { MinLevel = 1201, MaxLevel = 1499, NPCName = "Forgotten Quest Giver",   QuestNameInGame = "ForgottenQuest",     QuestNumber = 2, MobName = "Water Fighter" }, 

    -- === SEA 3 ===
    { MinLevel = 1500, MaxLevel = 1524, NPCName = "Port Town Quest Giver",    QuestNameInGame = "PiratePortQuest",    QuestNumber = 1, MobName = "Pirate Millionaire" },
    { MinLevel = 1525, MaxLevel = 1574, NPCName = "Port Town Quest Giver",    QuestNameInGame = "PiratePortQuest",    QuestNumber = 2, MobName = "Pistol Billionaire" }, 
    { MinLevel = 1575, MaxLevel = 1599, NPCName = "Hydra Island Quest Giver", QuestNameInGame = "AmazonQuest",        QuestNumber = 1, MobName = "Dragon Crew Warrior" },
    { MinLevel = 1600, MaxLevel = 1699, NPCName = "Hydra Island Quest Giver", QuestNameInGame = "AmazonQuest",        QuestNumber = 2, MobName = "Dragon Crew Archer" }, 
    { MinLevel = 1700, MaxLevel = 1724, NPCName = "Great Tree Quest Giver",   QuestNameInGame = "MarineTreeIsland",   QuestNumber = 1, MobName = "Marine Commodore" },
    { MinLevel = 1725, MaxLevel = 1774, NPCName = "Great Tree Quest Giver",   QuestNameInGame = "MarineTreeIsland",   QuestNumber = 2, MobName = "Marine Rear Admiral" }, 
    { MinLevel = 1775, MaxLevel = 1799, NPCName = "Turtle Quest Giver",       QuestNameInGame = "DeepForestIsland3",  QuestNumber = 1, MobName = "Fishman Raider" },
    { MinLevel = 1800, MaxLevel = 1824, NPCName = "Turtle Quest Giver",       QuestNameInGame = "DeepForestIsland3",  QuestNumber = 2, MobName = "Fishman Captain" },
    { MinLevel = 1825, MaxLevel = 1849, NPCName = "Turtle Quest Giver 2",     QuestNameInGame = "DeepForestIsland",   QuestNumber = 1, MobName = "Forest Pirate" },
    { MinLevel = 1850, MaxLevel = 1974, NPCName = "Turtle Quest Giver 2",     QuestNameInGame = "DeepForestIsland",   QuestNumber = 2, MobName = "Mythological Pirate" }, 
    { MinLevel = 1975, MaxLevel = 1999, NPCName = "Haunted Quest Giver",      QuestNameInGame = "HauntedQuest1",      QuestNumber = 1, MobName = "Reborn Skeleton" },
    { MinLevel = 2000, MaxLevel = 2024, NPCName = "Haunted Quest Giver",      QuestNameInGame = "HauntedQuest1",      QuestNumber = 2, MobName = "Living Zombie" },
    { MinLevel = 2025, MaxLevel = 2049, NPCName = "Haunted Quest Giver 2",    QuestNameInGame = "HauntedQuest2",      QuestNumber = 1, MobName = "Demonic Soul" },
    { MinLevel = 2050, MaxLevel = 2199, NPCName = "Haunted Quest Giver 2",    QuestNameInGame = "HauntedQuest2",      QuestNumber = 2, MobName = "Posessed Mummy" }, 
    { MinLevel = 2200, MaxLevel = 2224, NPCName = "Cookie Quest Giver",       QuestNameInGame = "CakeQuest1",         QuestNumber = 1, MobName = "Cookie Crafter" },
    { MinLevel = 2225, MaxLevel = 2249, NPCName = "Cookie Quest Giver",       QuestNameInGame = "CakeQuest1",         QuestNumber = 2, MobName = "Cake Guard" },
    { MinLevel = 2250, MaxLevel = 2274, NPCName = "Cake Quest Giver",         QuestNameInGame = "CakeQuest2",         QuestNumber = 1, MobName = "Baking Staff" },
    { MinLevel = 2275, MaxLevel = 9999, NPCName = "Cake Quest Giver",         QuestNameInGame = "CakeQuest2",         QuestNumber = 2, MobName = "Head Baker" }
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

-- [[ BUSCA INTELIGENTE: SE ADAPTA A CONTA MARINE OU PIRATE ]] --
function AutoQuest:GetQuestData()
    local level = LocalPlayer.Data.Level.Value
    local configAlvo = nil

    -- Correção de time: Se o player for lvl 0-9, checa o time (Marine ou Pirate) para escolher o NPC inicial correto
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

    -- Se não for nível inicial ou não achar por time, roda a varredura normal de nível
    if not configAlvo then
        for _, dados in pairs(_G.QuestConfig) do
            if level >= dados.MinLevel and level <= dados.MaxLevel then
                configAlvo = dados
                break
            end
        end
    end

    -- Fallback final de segurança
    configAlvo = configAlvo or _G.QuestConfig[2]

    local posNPC = EncontrarPosicaoNoMapa(configAlvo.NPCName) or Vector3.new(1059, 16, 1549)
    local posMob = EncontrarPosicaoNoMapa(configAlvo.MobName) or posNPC

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
