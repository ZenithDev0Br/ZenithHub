local BringMob = {
    Active = true
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local TweenInfoBring = TweenInfo.new(
    0.3, -- Ficou um pouco mais rápido para puxar de longe antes do bicho resetar
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

local MaxBringMobs = 10  -- Aumentado para pegar todos os macacos da Jungle
local BringRange = 1000   -- Aumentado drasticamente para cobrir as ilhas da Jungle

function BringMob:Cluster(enemyName)
    if not self.Active then return end
    
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local ZenithHub = getgenv().ZenithHub
    local Settings = ZenithHub and ZenithHub.Modules and ZenithHub.Modules.FarmSettings
    
    if Settings and Settings.BringMobs == false then return end

    -- Força a rede de física do Roblox a aceitar controle de alvos distantes
    pcall(function()  
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)  
    end)  

    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    
    -- CONFIGURAÇÃO DA ÂNCORA: Calcula a posição exata do CHÃO embaixo do seu player flutuante
    -- Isso garante que, não importa onde você esteja na Jungle, os bichos juntam exatamente abaixo de você!
    local centralTargetPosition = Vector3.new(Root.Position.X, Root.Position.Y - 20, Root.Position.Z)

    local count = 0
    for _, enemy in pairs(folder:GetChildren()) do
        if count >= MaxBringMobs then break end

        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid and not enemyRoot:GetAttribute("Tweening") then
                -- Calcula a distância real da Jungle
                local distance = (Root.Position - enemyRoot.Position).Magnitude
                
                if distance <= BringRange then
                    count = count + 1
                    
                    -- Desativa colisão para os macacos atravessarem as árvores e pontes da Jungle
                    for _, part in pairs(enemy:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    enemyRoot:SetAttribute("Tweening", true)  

                    -- Puxa o monstro para o ponto central de ataque abaixo de você
                    local tween = TweenService:Create(  
                        enemyRoot,  
                        TweenInfoBring,  
                        { CFrame = CFrame.new(centralTargetPosition) }  
                    )  

                    tween:Play()  
                    
                    tween.Completed:Once(function()  
                        if enemyRoot then  
                            enemyRoot:SetAttribute("Tweening", false)  
                            enemyRoot.Velocity = Vector3.new(0, 0, 0)
                            if enemyHumanoid:GetState() ~= Enum.HumanoidStateType.Physics then
                                enemyHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
                            end
                        end  
                    end)
                end
            end
        end
    end
end

return BringMob
