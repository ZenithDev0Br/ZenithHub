local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ESPERA O JOGO CARREGAR
repeat task.wait() until game:IsLoaded()

-- ACESSA DIRETO: Net é a pasta, os remotes estão DENTRO dela com o nome "RE/..."
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

-- OS REMOTES JÁ ESTÃO DENTRO DA PASTA NET!
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

print("✅ RegisterAttack encontrado:", RegisterAttack ~= nil)
print("✅ RegisterHit encontrado:", RegisterHit ~= nil)

local function IsAlive(char)
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0
end

local function GetNearestEnemies(distance)
    local OthersEnemies = {}
    local BasePart = nil
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        return OthersEnemies, nil 
    end

    local function ProcessFolder(folder)  
        if not folder then return end  
        for _, enemy in ipairs(folder:GetChildren()) do  
            local head = enemy:FindFirstChild("Head")  
            if head and IsAlive(enemy) and enemy ~= char then  
                local dist = (char.HumanoidRootPart.Position - head.Position).Magnitude  
                if dist < distance then  
                    table.insert(OthersEnemies, {enemy, head})  
                    BasePart = head  
                end  
            end  
        end  
    end  

    ProcessFolder(workspace:FindFirstChild("Enemies"))  
    ProcessFolder(workspace:FindFirstChild("Characters"))  
    return OthersEnemies, BasePart
end

-- FAST ATTACK
function Combat:StartAttackLoop()
    local delayTime = 0.15
    
    -- Loop 1
    task.spawn(function()  
        while true do  
            task.wait(delayTime)  
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings  
            if not (S and S.FastAttack and S.AutoFarmLevel) then 
                task.wait(1)
                continue 
            end  

            local char = LocalPlayer.Character  
            if not IsAlive(char) then continue end  

            local tool = char:FindFirstChildOfClass("Tool")  
            if not tool or tool.ToolTip == "Gun" then continue end  

            local enemies, basePart = GetNearestEnemies(100)  
            if #enemies > 0 and basePart then  
                pcall(function()  
                    RegisterAttack:FireServer(0)  
                    RegisterHit:FireServer(basePart, enemies)  
                end)  
            end  
        end  
    end)  
    
    -- Loop 2 (Zyn Hub roda DOIS loops)
    task.spawn(function()  
        while true do  
            task.wait(delayTime)  
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings  
            if not (S and S.FastAttack and S.AutoFarmLevel) then 
                task.wait(1)
                continue 
            end  

            local char = LocalPlayer.Character  
            if not IsAlive(char) then continue end  

            local tool = char:FindFirstChildOfClass("Tool")  
            if not tool or tool.ToolTip == "Gun" then continue end  

            local enemies, basePart = GetNearestEnemies(100)  
            if #enemies > 0 and basePart then  
                pcall(function()  
                    RegisterAttack:FireServer(0)  
                    RegisterHit:FireServer(basePart, enemies)  
                end)  
            end  
        end  
    end)  
end

function Combat:StartBuso()
    task.spawn(function()
        while true do
            task.wait(1)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            if not (S and S.AutoBuso) then 
                task.wait(1)
                continue 
            end
            local char = LocalPlayer.Character
            if not IsAlive(char) then continue end
            if not char:FindFirstChild("HasBuso") then
                local CommF = ReplicatedStorage:FindFirstChild("Remotes"):WaitForChild("CommF_")
                pcall(function() CommF:InvokeServer("Buso") end)
            end
        end
    end)
end

function Combat:StartHitbox()
    task.spawn(function()
        while true do
            task.wait(0.5)
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings
            local hitboxSize = S and S.HitboxSize or 15
            local char = LocalPlayer.Character
            if not char then continue end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        sethiddenproperty(part, "HitboxSize", Vector3.new(hitboxSize, hitboxSize, hitboxSize))
                    end)
                end
            end
        end
    end)
end

Combat:StartBuso()
Combat:StartHitbox()
Combat:StartAttackLoop()

return Combat
