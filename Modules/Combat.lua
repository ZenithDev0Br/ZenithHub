local Combat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ESPERA O JOGO CARREGAR COMPLETAMENTE
repeat task.wait() until game:IsLoaded()

-- AGORA sim, pega os remotes com WaitForChild
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RE = Net:WaitForChild("RE")

local RegisterAttack = RE:WaitForChild("RegisterAttack")
local RegisterHit = RE:WaitForChild("RegisterHit")

print("RegisterAttack encontrado:", RegisterAttack ~= nil)
print("RegisterHit encontrado:", RegisterHit ~= nil)

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

-- FAST ATTACK CORRETO (igual ao Zyn Hub)
function Combat:StartAttackLoop()
    local delayTime = 0.15
    
    -- Loop 1
    task.spawn(function()  
        while true do  
            task.wait(delayTime)  
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings  
            if not (S and S.FastAttack and S.AutoFarmLevel) then continue end  

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
    
    -- Loop 2 (Zyn Hub roda DOIS loops idênticos)
    task.spawn(function()  
        while true do  
            task.wait(delayTime)  
            local S = getgenv().ZenithHub and getgenv().ZenithHub.Modules.FarmSettings  
            if not (S and S.FastAttack and S.AutoFarmLevel) then continue end  

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

return Combat
