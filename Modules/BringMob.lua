local BringMob = {
    Active = true
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Configurações de tempo e suavidade baseadas no Open Source
local TweenInfoBring = TweenInfo.new(
    0.45, -- Velocidade ideal do puxão suave
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

local MaxBringMobs = 3  -- Limite seguro para não dar lag ou ban por teletransporte
local BringRange = 250   -- Alcance máximo do puxão (studs)

function BringMob:Cluster(enemyName)
    if not self.Active then return end
    
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    -- Força a rede de física a aceitar o controle do mob à distância
    pcall(function()  
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)  
    end)  

    -- Puxa as configurações de altura da sua UI
    local ZenithHub = getgenv().ZenithHub
    local Settings = ZenithHub and ZenithHub.Modules and ZenithHub.Modules.FarmSettings
    local attackHeight = Settings and Settings.AttackHeight or 5

    -- O ponto exato onde os mobs vão se juntar
    local targetCFrame = Root.CFrame * CFrame.new(0, -attackHeight, 0)
    local targetPosition = targetCFrame.Position

    local folder = Workspace:FindFirstChild("Enemies") or Workspace
    local count = 0
    
    for _, enemy in pairs(folder:GetChildren()) do
        if count >= MaxBringMobs then break end -- Não puxa mais do que o limite para evitar bugs

        if enemy.Name == enemyName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")
            
            if enemyRoot and enemyHumanoid and not enemyRoot:GetAttribute("Tweening") then
                local distance = (Root.Position - enemyRoot.Position).Magnitude
                
                if distance <= BringRange then
                    count = count + 1
                    
                    -- Desativa colisões para eles passarem por dentro das paredes/chão sem travar
                    for _, part in pairs(enemy:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    -- Ativa a trava de movimento para não sobrecarregar
                    enemyRoot:SetAttribute("Tweening", true)  

                    -- Cria o movimento suave idêntico ao do Maru/Zyn Hub
                    local tween = TweenService:Create(  
                        enemyRoot,  
                        TweenInfoBring,  
                        { CFrame = CFrame.new(targetPosition) }  
                    )  

                    tween:Play()  
                    
                    -- Quando a animação de puxar acabar, libera para o próximo ajuste
                    tween.Completed:Once(function()  
                        if enemyRoot then  
                            enemyRoot:SetAttribute("Tweening", false)  
                            -- Trava de física agressiva após o puxão
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
