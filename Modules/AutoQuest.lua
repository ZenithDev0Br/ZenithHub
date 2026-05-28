local AutoQuest = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ BASE DE DADOS COMPLETA (SEA 1 & SEA 2) ]] --
-- Mapeado com base na tabela oficial que você enviou!
_G.QuestConfig = {
    -- === SEA 1 ===
    { MinLevel = 0,    MaxLevel = 9,    NPCName = "Bandit Quest Giver",       QuestNameInGame = "BanditQuest",        QuestNumber = 1, MobName = "Bandit" },
    { MinLevel = 10,   MaxLevel = 14,   NPCName = "Adventurer",               QuestNameInGame = "JungleQuest",        QuestNumber = 1, MobName = "Monkey" },
    { MinLevel = 15,   MaxLevel = 19,   NPCName = "Adventurer",               QuestNameInGame = "JungleQuest",        QuestNumber = 2, MobName = "Gorilla" },
    { MinLevel = 20,   MaxLevel = 29,   NPCName = "Adventurer",               QuestNameInGame = "JungleQuest",        QuestNumber = 3, MobName = "Gorilla King" },
    { MinLevel = 30,   MaxLevel = 39,   NPCName = "Pirate Adventurer",        QuestNameInGame = "BuggyQuest",         QuestNumber = 1, MobName = "Pirate" },
    { MinLevel = 40,   MaxLevel = 54,   NPCName = "Pirate Adventurer",        QuestNameInGame = "BuggyQuest",         QuestNumber = 2, MobName = "Brute" },
    { MinLevel = 55,   MaxLevel = 59,   NPCName = "Pirate Adventurer",        QuestNameInGame = "BuggyQuest",         QuestNumber = 3, MobName = "Bobby" }, -- Chef Boss
    { MinLevel = 60,   MaxLevel = 74,   NPCName = "Desert Adventurer",        QuestNameInGame = "DesertQuest",        QuestNumber = 1, MobName = "Desert Bandit" },
    { MinLevel = 75,   MaxLevel = 89,   NPCName = "Desert Adventurer",        QuestNameInGame = "DesertQuest",        QuestNumber = 2, MobName = "Desert Officer" },
    { MinLevel = 90,   MaxLevel = 99,   NPCName = "Villager",                 QuestNameInGame = "SnowQuest",          QuestNumber = 1, MobName = "Snow Bandit" },
    { MinLevel = 100,  MaxLevel = 104,  NPCName = "Villager",                 QuestNameInGame = "SnowQuest",          QuestNumber = 2, MobName = "Snowman" },
    { MinLevel = 105,  MaxLevel = 119,  NPCName = "Villager",                 QuestNameInGame = "SnowQuest",          QuestNumber = 3, MobName = "Yeti" },
    { MinLevel = 120,  MaxLevel = 129,  NPCName = "Marine",                   QuestNameInGame = "MarineQuest",        QuestNumber = 1, MobName = "Chief Petty Officer" },
    { MinLevel = 130,  MaxLevel = 149,  NPCName = "Marine",                   QuestNameInGame = "MarineQuest",        QuestNumber = 2, MobName = "Vice Admiral" },
    { MinLevel = 150,  MaxLevel = 174,  NPCName = "Sky Adventurer",           QuestNameInGame = "SkyQuest",           QuestNumber = 1, MobName = "Sky Bandit" },
    { MinLevel = 175,  MaxLevel = 189,  NPCName = "Sky Adventurer",           QuestNameInGame = "SkyQuest",           QuestNumber = 2, MobName = "Dark Master" },
    { MinLevel = 190,  MaxLevel = 209,  NPCName = "Jail Keeper",              QuestNameInGame = "PrisonQuest",        QuestNumber = 1, MobName = "Prisoner" },
    { MinLevel = 210,  MaxLevel = 219,  NPCName = "Jail Keeper",              QuestNameInGame = "PrisonQuest",        QuestNumber = 2, MobName = "Dangerous Prisoner" },
    { MinLevel = 220,  MaxLevel = 229,  NPCName = "Warden",                   QuestNameInGame = "PrisonQuest",        QuestNumber = 3, MobName = "Warden" },
    { MinLevel = 230,  MaxLevel = 239,  NPCName = "Warden",                   QuestNameInGame = "PrisonQuest",        QuestNumber = 4, MobName = "Chief Warden" },
    { MinLevel = 240,  MaxLevel = 249,  NPCName = "Warden",                   QuestNameInGame = "PrisonQuest",        QuestNumber = 5, MobName = "Swan" },
    { MinLevel = 250,  MaxLevel = 274,  NPCName = "Colosseum Quest Giver",    QuestNameInGame = "ColosseumQuest",     QuestNumber = 1, MobName = "Toga Warrior" },
    { MinLevel = 275,  MaxLevel = 299,  NPCName = "Colosseum Quest Giver",    QuestNameInGame = "ColosseumQuest",     QuestNumber = 2, MobName = "Gladiator" },
    { MinLevel = 300,  MaxLevel = 324,  NPCName = "The Mayor",                QuestNameInGame = "MagmaQuest",         QuestNumber = 1, MobName = "Military Soldier" },
    { MinLevel = 325,  MaxLevel = 349,  NPCName = "The Mayor",                QuestNameInGame = "MagmaQuest",         QuestNumber = 2, MobName = "Military Spy" },
    { MinLevel = 350,  MaxLevel = 374,  NPCName = "The Mayor",                QuestNameInGame = "MagmaQuest",         QuestNumber = 3, MobName = "Magma Admiral" },
    { MinLevel = 375,  MaxLevel = 399,  NPCName = "King Neptune",             QuestNameInGame = "FishmanQuest",       QuestNumber = 1, MobName = "Fishman Warrior" },
    { MinLevel = 400,  MaxLevel = 424,  NPCName = "King Neptune",             QuestNameInGame = "FishmanQuest",       QuestNumber = 2, MobName = "Fishman Commando" },
    { MinLevel = 425,  MaxLevel = 449,  NPCName = "King Neptune",             QuestNameInGame = "FishmanQuest",       QuestNumber = 3, MobName = "Fishman Lord" },
    { MinLevel = 450,  MaxLevel = 474,  NPCName = "Mole",                     QuestNameInGame = "SkyQuest2",          QuestNumber = 1, MobName = "God's Guard" },
    { MinLevel = 475,  MaxLevel = 499,  NPCName = "Mole",                     QuestNameInGame = "SkyQuest2",          QuestNumber = 2, MobName = "Shanda" },
    { MinLevel = 500,  MaxLevel = 524,  NPCName = "Mole",                     QuestNameInGame = "SkyQuest2",          QuestNumber = 3, MobName = "Wysper" },
    { MinLevel = 525,  MaxLevel = 549,  NPCName = "Sky Quest Giver 2",        QuestNameInGame = "SkyQuest3",          QuestNumber = 1, MobName = "Royal Squad" },
    { MinLevel = 550,  MaxLevel = 574,  NPCName = "Sky Quest Giver 2",        QuestNameInGame = "SkyQuest3",          QuestNumber = 2, MobName = "Royal Soldier" },
    { MinLevel = 575,  MaxLevel = 624,  NPCName = "Sky Quest Giver 2",        QuestNameInGame = "SkyQuest3",          QuestNumber = 3, MobName = "Thunder God" },
    { MinLevel = 625,  MaxLevel = 649,  NPCName = "Freezeburg Quest Giver",   QuestNameInGame = "FountainQuest",      QuestNumber = 1, MobName = "Galley Pirate" },
    { MinLevel = 650,  MaxLevel = 674,  NPCName = "Freezeburg Quest Giver",   QuestNameInGame = "FountainQuest",      QuestNumber = 2, MobName = "Galley Captain" },
    { MinLevel = 675,  MaxLevel = 699,  NPCName = "Freezeburg Quest Giver",   QuestNameInGame = "FountainQuest",      QuestNumber = 3, MobName = "Cyborg" },

    -- === SEA 2 ===
    { MinLevel = 700,  MaxLevel = 724,  NPCName = "Area 1 Quest Giver",       QuestNameInGame = "Area1Quest",         QuestNumber = 1, MobName = "Raider" },
    { MinLevel = 725,  MaxLevel = 749,  NPCName = "Area 1 Quest Giver",       QuestNameInGame = "Area1Quest",         QuestNumber = 2, MobName = "Mercenary" },
    { MinLevel = 750,  MaxLevel = 774,  NPCName = "Area 1 Quest Giver",       QuestNameInGame = "Area1Quest",         QuestNumber = 3, MobName = "Diamond" },
    { MinLevel = 775,  MaxLevel = 799,  NPCName = "Area 2 Quest Giver",       QuestNameInGame = "Area2Quest",         QuestNumber = 1, MobName = "Swan Pirate" },
    { MinLevel = 800,  MaxLevel = 849,  NPCName = "Area 2 Quest Giver",       QuestNameInGame = "Area2Quest",         QuestNumber = 2, MobName = "Factory Staff" },
    { MinLevel = 850,  MaxLevel = 874,  NPCName = "Area 2 Quest Giver",       QuestNameInGame = "Area2Quest",         QuestNumber = 3, MobName = "Jeremy" },
    { MinLevel = 875,  MaxLevel = 899,  NPCName = "Marine Quest Giver",       QuestNameInGame = "GreenZoneQuest",     QuestNumber = 1, MobName = "Marine Lieutenant" },
    { MinLevel = 900,  MaxLevel = 924,  NPCName = "Marine Quest Giver",       QuestNameInGame = "GreenZoneQuest",     QuestNumber = 2, MobName = "Marine Captain" },
    { MinLevel = 925,  MaxLevel = 949,  NPCName = "Marine Quest Giver",       QuestNameInGame = "GreenZoneQuest",     QuestNumber = 3, MobName = "Fajita" }, -- Orbitus Boss
    { MinLevel = 950,  MaxLevel = 974,  NPCName = "Graveyard Quest Giver",    QuestNameInGame = "GraveyardQuest",     QuestNumber = 1, MobName = "Zombie" },
    { MinLevel = 975,  MaxLevel = 999,  NPCName = "Graveyard Quest Giver",    QuestNameInGame = "GraveyardQuest",     QuestNumber = 2, MobName = "Vampire" },
    { MinLevel = 1000, MaxLevel = 1049, NPCName = "Snow Quest Giver",         QuestNameInGame = "SnowMountainQuest",  QuestNumber = 1, MobName = "Snow Trooper" },
    { MinLevel = 1050, MaxLevel = 1099, NPCName = "Snow Quest Giver",         QuestNameInGame = "SnowMountainQuest",  QuestNumber = 2, MobName = "Winter Warrior" },
    { MinLevel = 1100, MaxLevel = 1124, NPCName = "Ice Quest Giver",          QuestNameInGame = "HotAndColdQuest",    QuestNumber = 1, MobName = "Lab Subordinate" },
    { MinLevel = 1125, MaxLevel = 1149, NPCName = "Ice Quest Giver",          QuestNameInGame = "HotAndColdQuest",    QuestNumber = 2, MobName = "Horned Warrior" },
    { MinLevel = 1150, MaxLevel = 1174, NPCName = "Ice Quest Giver",          QuestNameInGame = "HotAndColdQuest",    QuestNumber = 3, MobName = "Smoke Admiral" },
    { MinLevel = 1175, MaxLevel = 1199, NPCName = "Fire Quest Giver",         QuestNameInGame = "HotAndColdQuest",    QuestNumber = 1, MobName = "Magma Ninja" },
    { MinLevel = 1200, MaxLevel = 1249, NPCName = "Fire Quest Giver",         QuestNameInGame = "HotAndColdQuest",    QuestNumber = 2, MobName = "Lava Pirate" },
    { MinLevel = 1250, MaxLevel = 1274, NPCName = "Rear Crew Quest Giver",    QuestNameInGame = "CursedShipQuest",    QuestNumber = 1, MobName = "Ship Deckhand" },
    { MinLevel = 1275, MaxLevel = 1299, NPCName = "Rear Crew Quest Giver",    QuestNameInGame = "CursedShipQuest",    QuestNumber = 2, MobName = "Ship Engineer" },
    { MinLevel = 1300, MaxLevel = 1324, NPCName = "Front Crew Quest Giver",   QuestNameInGame = "CursedShipQuest",    QuestNumber = 1, MobName = "Ship Steward" },
    { MinLevel = 1325, MaxLevel = 1349, NPCName = "Front Crew Quest Giver",   QuestNameInGame = "CursedShipQuest",    QuestNumber = 2, MobName = "Ship Officer" },
    { MinLevel = 1350, MaxLevel = 1374, NPCName = "Frost Quest Giver",        QuestNameInGame = "IceCastleQuest",     QuestNumber = 1, MobName = "Arctic Warrior" },
    { MinLevel = 1375, MaxLevel = 1399, NPCName = "Frost Quest Giver",        QuestNameInGame = "IceCastleQuest",     QuestNumber = 2, MobName = "Snow Lurker" },
    { MinLevel = 1400, MaxLevel = 1424, NPCName = "Frost Quest Giver",        QuestNameInGame = "IceCastleQuest",     QuestNumber = 3, MobName = "Awakened Ice Admiral" },
    { MinLevel = 1425, MaxLevel = 1449, NPCName = "Forgotten Quest Giver",   QuestNameInGame = "ForgottenQuest",     QuestNumber = 1, MobName = "Sea Soldier" },
    { MinLevel = 1450, MaxLevel = 1474, NPCName = "Forgotten Quest Giver",   QuestNameInGame = "ForgottenQuest",     QuestNumber = 2, MobName = "Water Fighter" },
    { MinLevel = 1475, MaxLevel = 9999, NPCName = "Forgotten Quest Giver",   QuestNameInGame = "ForgottenQuest",     QuestNumber = 3, MobName = "Tide Keeper" }
}

-- [[ SISTEMA SMART DE DETECÇÃO DE LOCALIZAÇÃO ]] --
-- Função que busca o NPC/Monstro no mapa dinamicamente para obter a coordenada exata
local function EncontrarPosicaoNoMapa(nomeDoObjeto)
    local objeto = workspace:FindFirstChild(nomeDoObjeto, true)
    if objeto and objeto:FindFirstChild("HumanoidRootPart") then
        return objeto.HumanoidRootPart.Position
    end
    -- Fallback/Segurança: Se o mob não estiver renderizado perto, tenta buscar na pasta de Spawns nativa do jogo
    local spawnFolder = workspace:FindFirstChild("SpawnPoints", true)
    if spawnFolder and spawnFolder:FindFirstChild(nomeDoObjeto) then
        return spawnFolder[nomeDoObjeto].Position
    end
    return nil
end

-- [[ RETORNA OS DADOS E MAPEA AS POSIÇÕES EM TEMPO REAL ]] --
function AutoQuest:GetQuestData()
    local level = LocalPlayer.Data.Level.Value
    local configAlvo = _G.QuestConfig[1] -- Padrão Inicial (Bandits)

    for _, dados in pairs(_G.QuestConfig) do
        if level >= dados.MinLevel and level <= dados.MaxLevel then
            configAlvo = dados
            break
        end
    end

    -- Escaneia o mapa para descobrir onde o NPC e os Mobs estão spawnados agora
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

-- [[ VERIFICA SE JÁ TEM MISSÃO NA TELA ]] --
function AutoQuest:HasQuest()
    local myFolder = LocalPlayer.PlayerGui:FindFirstChild("my")
    if myFolder then
        local questFrame = myFolder:FindFirstChild("Quest") or myFolder:FindFirstChild("quest")
        if questFrame and questFrame.Visible then
            return true
        end
    end
    
    local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible then
        return true
    end
    
    return false
end

-- [[ INICIA A MISSÃO VIA REMOTE OFICIAL ]] --
function AutoQuest:StartQuest()
    local dados = self:GetQuestData()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    
    if Remote then
        -- Envia o comando nativo do Blox Fruits aceitando a quest correta do seu nível
        Remote:InvokeServer("StartQuest", dados.QuestName, dados.QuestID)
    else
        warn("[ZenithHub] Remote principal 'CommF_' não foi encontrado no ReplicatedStorage.")
    end
end

return AutoQuest
