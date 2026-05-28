local BringMob = {
    Active = true
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local TweenInfoBring = TweenInfo.new(
    0.45, -- Velocidade suave idêntica ao Zyn Hub
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

local MaxBringMobs = 3  -- Limite seguro contra lag e ban
local BringRange = 250   -- Alcance máximo do puxão

function BringMob:Cluster(enemyName)
    if not self.Active then return end
    
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    -- Coleta as configurações da UI/Config de forma segura
    local ZenithHub = getgenv().ZenithHub
    local Settings = ZenithHub and ZenithHub.Modules and ZenithHub.Modules.FarmSettings
    
    -- Verifica se o toggle de "Bring Mobs" está ativo na sua UI
    if Settings and Settings.BringMobs == false then return end

    -- Ativa a rede de física para conseguir puxar de longe
    pcall(function()  
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)  
    end)  

    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    local baseEnemy = nil

    -- 1️⃣ PASSO: Encontra o primeiro monstro vivo para servir de "âncora" fixa no chão
    for _, enemy in pairs(folder:GetChildren()) do
        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                baseEnemy = enemy
                break
            end
        end
    end

    if not baseEnemy then return end
    local baseRoot = baseEnemy:FindFirstChild("HumanoidRootPart")
    if not baseRoot then return end

    -- 2️⃣ PASSO: Trava a posição original do monstro no chão (Igual ao Zyn Hub!)
    if not baseEnemy:GetAttribute("LockedPosition") then
        baseEnemy:SetAttribute("LockedPosition", baseRoot.Position)
    end
    
    -- Esta é a posição fixa onde todos os monstros vão se agrupar no chão!
    local centralTargetPosition = baseEnemy:GetAttribute("LockedPosition")

    -- 3️⃣ PASSO: Puxa todos os monstros próximos para essa mesma posição fixa
    local count = 0
    for _, enemy in pairs(folder:GetChildren()) do
        if count >= MaxBringMobs then break end

        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid and not enemyRoot:GetAttribute("Tweening") then
                local distance = (Root.Position - enemyRoot.Position).Magnitude
                
                if distance <= BringRange then
                    count = count + 1
                    
                    -- Desativa colisões para os monstros não prenderem no cenário
                    for _, part in pairs(enemy:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    enemyRoot:SetAttribute("Tweening", true)  

                    -- Faz o Tween para a posição fixa no chão, e NÃO para debaixo do player
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
