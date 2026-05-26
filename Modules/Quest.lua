if not getgenv().ZenithHub then getgenv().ZenithHub = { Modules = {} } end
local Quest = {}

-- Lista Completa de Quests (Do Level Máximo ao Level 1)
Quest.List = {
    -------------------------------------------------------------------------------
    -- SEA 3 (Terceiro Mar) | Levels 1500 - 2525
    -------------------------------------------------------------------------------
    -- Tiki Outpost
    {Level = 2525, Mob = "Star-gazer", QuestName = "TikiQuest2", QuestNum = 2},
    {Level = 2500, Mob = "Isle Explorer", QuestName = "TikiQuest2", QuestNum = 1},
    {Level = 2475, Mob = "Sun-kissed Warrior", QuestName = "TikiQuest1", QuestNum = 2},
    {Level = 2450, Mob = "Isle Champion", QuestName = "TikiQuest1", QuestNum = 1},
    -- Sea of Treats
    {Level = 2400, Mob = "Snow Demonic", QuestName = "CandyQuest1", QuestNum = 2},
    {Level = 2375, Mob = "Candy Pirate", QuestName = "CandyQuest1", QuestNum = 1},
    {Level = 2350, Mob = "Candy Rebel", QuestName = "ChocQuest2", QuestNum = 2},
    {Level = 2325, Mob = "Sweet Thief", QuestName = "ChocQuest2", QuestNum = 1},
    {Level = 2300, Mob = "Chocolate Bar Battler", QuestName = "ChocQuest1", QuestNum = 2},
    {Level = 2275, Mob = "Cocoa Warrior", QuestName = "ChocQuest1", QuestNum = 1},
    -- Cake / Ice Cream / Peanut
    {Level = 2250, Mob = "Head Baker", QuestName = "CakeQuest2", QuestNum = 2},
    {Level = 2225, Mob = "Baking Staff", QuestName = "CakeQuest2", QuestNum = 1},
    {Level = 2200, Mob = "Cake Guard", QuestName = "CakeQuest1", QuestNum = 2},
    {Level = 2175, Mob = "Cookie Crafter", QuestName = "CakeQuest1", QuestNum = 1},
    {Level = 2150, Mob = "Ice Cream Commander", QuestName = "IceCreamQuest", QuestNum = 2},
    {Level = 2125, Mob = "Ice Cream Chef", QuestName = "IceCreamQuest", QuestNum = 1},
    {Level = 2100, Mob = "Peanut President", QuestName = "NutsQuest", QuestNum = 2},
    {Level = 2075, Mob = "Peanut Scout", QuestName = "NutsQuest", QuestNum = 1},
    -- Haunted Castle
    {Level = 2050, Mob = "Possessed Mummy", QuestName = "HauntedQuest2", QuestNum = 2},
    {Level = 2025, Mob = "Demonic Soul", QuestName = "HauntedQuest2", QuestNum = 1},
    {Level = 2000, Mob = "Living Zombie", QuestName = "HauntedQuest1", QuestNum = 2},
    {Level = 1975, Mob = "Reborn Skeleton", QuestName = "HauntedQuest1", QuestNum = 1},
    -- Floating Turtle
    {Level = 1925, Mob = "Musketeer Pirate", QuestName = "FloatingTurtleQuest3", QuestNum = 2},
    {Level = 1900, Mob = "Jungle Pirate", QuestName = "FloatingTurtleQuest3", QuestNum = 1},
    {Level = 1850, Mob = "Mythological Pirate", QuestName = "FloatingTurtleQuest2", QuestNum = 2},
    {Level = 1825, Mob = "Forest Pirate", QuestName = "FloatingTurtleQuest2", QuestNum = 1},
    {Level = 1800, Mob = "Fishman Captain", QuestName = "FloatingTurtleQuest", QuestNum = 2},
    {Level = 1775, Mob = "Fishman Raider", QuestName = "FloatingTurtleQuest", QuestNum = 1},
    -- Great Tree
    {Level = 1725, Mob = "Marine Rear Admiral", QuestName = "GreatTreeQuest", QuestNum = 2},
    {Level = 1700, Mob = "Marine Commodore", QuestName = "GreatTreeQuest", QuestNum = 1},
    -- Hydra Island
    {Level = 1650, Mob = "Giant Islander", QuestName = "HydraQuest", QuestNum = 4},
    {Level = 1625, Mob = "Female Islander", QuestName = "HydraQuest", QuestNum = 3},
    {Level = 1600, Mob = "Dragon Crew Archer", QuestName = "HydraQuest", QuestNum = 2},
    {Level = 1575, Mob = "Dragon Crew Warrior", QuestName = "HydraQuest", QuestNum = 1},
    -- Port Town
    {Level = 1525, Mob = "Pistol Billionaire", QuestName = "PortTownQuest", QuestNum = 2},
    {Level = 1500, Mob = "Pirate Millionaire", QuestName = "PortTownQuest", QuestNum = 1},

    -------------------------------------------------------------------------------
    -- SEA 2 (Segundo Mar) | Levels 700 - 1500
    -------------------------------------------------------------------------------
    -- Forgotten Island
    {Level = 1450, Mob = "Sea Soldier", QuestName = "ForgottenQuest", QuestNum = 2},
    {Level = 1425, Mob = "Water Fighter", QuestName = "ForgottenQuest", QuestNum = 1},
    -- Ice Castle
    {Level = 1375, Mob = "Snow Lurker", QuestName = "IceCastleQuest", QuestNum = 2},
    {Level = 1350, Mob = "Arctic Warrior", QuestName = "IceCastleQuest", QuestNum = 1},
    -- Cursed Ship
    {Level = 1325, Mob = "Ship Officer", QuestName = "ShipQuest2", QuestNum = 2},
    {Level = 1300, Mob = "Ship Steward", QuestName = "ShipQuest2", QuestNum = 1},
    {Level = 1275, Mob = "Ship Engineer", QuestName = "ShipQuest1", QuestNum = 2},
    {Level = 1250, Mob = "Ship Deckhand", QuestName = "ShipQuest1", QuestNum = 1},
    -- Hot and Cold
    {Level = 1200, Mob = "Lava Pirate", QuestName = "FireQuest", QuestNum = 2},
    {Level = 1175, Mob = "Magma Ninja", QuestName = "FireQuest", QuestNum = 1},
    {Level = 1125, Mob = "Horned Warrior", QuestName = "IceQuest", QuestNum = 2},
    {Level = 1100, Mob = "Lab Subordinate", QuestName = "IceQuest", QuestNum = 1},
    -- Snow Mountain
    {Level = 1050, Mob = "Winter Warrior", QuestName = "FrostQuest", QuestNum = 2},
    {Level = 1000, Mob = "Snow Trooper", QuestName = "FrostQuest", QuestNum = 1},
    -- Graveyard
    {Level = 975, Mob = "Vampire", QuestName = "ZombieQuest", QuestNum = 2},
    {Level = 950, Mob = "Zombie", QuestName = "ZombieQuest", QuestNum = 1},
    -- Green Zone
    {Level = 900, Mob = "Marine Captain", QuestName = "MarineQuest", QuestNum = 2},
    {Level = 875, Mob = "Marine Lieutenant", QuestName = "MarineQuest", QuestNum = 1},
    -- Kingdom of Rose
    {Level = 800, Mob = "Factory Staff", QuestName = "Area2Quest", QuestNum = 2},
    {Level = 775, Mob = "Swan Pirate", QuestName = "Area2Quest", QuestNum = 1},
    {Level = 725, Mob = "Mercenary", QuestName = "Area1Quest", QuestNum = 2},
    {Level = 700, Mob = "Raider", QuestName = "Area1Quest", QuestNum = 1},

    -------------------------------------------------------------------------------
    -- SEA 1 (Primeiro Mar) | Levels 1 - 700
    -------------------------------------------------------------------------------
    -- Fountain City
    {Level = 650, Mob = "Galley Captain", QuestName = "FountainQuest", QuestNum = 2},
    {Level = 625, Mob = "Galley Pirate", QuestName = "FountainQuest", QuestNum = 1},
    -- Upper Skylands
    {Level = 550, Mob = "Royal Soldier", QuestName = "SkyExp2Quest", QuestNum = 2},
    {Level = 525, Mob = "Royal Squad", QuestName = "SkyExp2Quest", QuestNum = 1},
    {Level = 475, Mob = "Shanda", QuestName = "SkyExp1Quest", QuestNum = 2},
    {Level = 450, Mob = "God's Guard", QuestName = "SkyExp1Quest", QuestNum = 1},
    -- Underwater City
    {Level = 400, Mob = "Fishman Commando", QuestName = "FishmanQuest", QuestNum = 2},
    {Level = 375, Mob = "Fishman Warrior", QuestName = "FishmanQuest", QuestNum = 1},
    -- Magma Village
    {Level = 325, Mob = "Military Spy", QuestName = "MagmaQuest", QuestNum = 2},
    {Level = 300, Mob = "Military Soldier", QuestName = "MagmaQuest", QuestNum = 1},
    -- Colosseum
    {Level = 275, Mob = "Gladiator", QuestName = "ColosseumQuest", QuestNum = 2},
    {Level = 225, Mob = "Toga Warrior", QuestName = "ColosseumQuest", QuestNum = 1},
    -- Prison
    {Level = 190, Mob = "Prisoner", QuestName = "PrisonerQuest", QuestNum = 1},
    -- Skylands
    {Level = 175, Mob = "Dark Master", QuestName = "SkyQuest", QuestNum = 2},
    {Level = 150, Mob = "Sky Bandit", QuestName = "SkyQuest", QuestNum = 1},
    -- Frozen Village
    {Level = 100, Mob = "Snowman", QuestName = "SnowQuest", QuestNum = 2},
    {Level = 90, Mob = "Snow Bandit", QuestName = "SnowQuest", QuestNum = 1},
    -- Desert
    {Level = 75, Mob = "Desert Officer", QuestName = "DesertQuest", QuestNum = 2},
    {Level = 60, Mob = "Desert Bandit", QuestName = "DesertQuest", QuestNum = 1},
    -- Pirate Village
    {Level = 45, Mob = "Brute", QuestName = "BuggyQuest1", QuestNum = 2},
    {Level = 30, Mob = "Pirate", QuestName = "BuggyQuest1", QuestNum = 1},
    -- Jungle
    {Level = 20, Mob = "Gorilla", QuestName = "JungleQuest", QuestNum = 2},
    {Level = 10, Mob = "Monkey", QuestName = "JungleQuest", QuestNum = 1},
    -- Starter Island (Pirate / Marine)
    {Level = 1, Mob = "Bandit", QuestName = "BanditQuest1", QuestNum = 1}
}

-- Retorna qual quest o jogador deve fazer baseado no level atual
function Quest:GetCurrentQuest(playerLevel)
    for _, q in ipairs(self.List) do
        if playerLevel >= q.Level then
            return q
        end
    end
    -- Se o nível for muito baixo (por alguma falha), ele cai na última da tabela (Level 1)
    return self.List[#self.List]
end

-- Verifica se a interface de Quest está ativa na tela
function Quest:HasActiveQuest(player)
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui and playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest") then
        if playerGui.Main.Quest.Visible then
            return true
        end
    end
    return false
end

-- Chama o servidor para pegar a missão
function Quest:TakeQuest(questData)
    local commF = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if commF and commF:FindFirstChild("CommF_") then
        commF.CommF_:InvokeServer("StartQuest", questData.QuestName, questData.QuestNum)
    end
end

getgenv().ZenithHub.Modules.Quest = Quest
return Quest

