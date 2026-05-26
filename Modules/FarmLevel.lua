local FarmLevel = {}
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local LP = game:GetService("Players").LocalPlayer

local noclipConnection = nil

-- Função de NoClip (Atravessar paredes)
function FarmLevel:ToggleNoClip(enabled)
    if enabled then
        if not noclipConnection then
            noclipConnection = RS.Stepped:Connect(function()
                if LP.Character then
                    for _, v in pairs(LP.Character:GetChildren()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- Lógica de pegar quest (Ainda precisa da lista de nomes de Quests e NPCs)
function FarmLevel:TakeQuest()
    -- No Blox Fruits, usamos o CommF_ para pegar a missão.
    -- Exemplo: game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "NOME_DA_QUEST", 1)
    -- Como as quests mudam por level, precisamos definir a lista de quests depois!
end

function FarmLevel:AutoFarm(enabled)
    _G.AutoFarmLevel = enabled
    self:ToggleNoClip(enabled) -- Liga/Desliga o NoClip junto com o Farm

    task.spawn(function()
        while _G.AutoFarmLevel and task.wait() do
            
            -- Aqui entraria a verificação: Se não tiver quest, pega a quest.
            -- if not LP.PlayerGui.Main.Quest.Visible then self:TakeQuest() end

            local Target = self:GetClosestEnemy()
            if Target and Target:FindFirstChild("HumanoidRootPart") then
                -- Matemática da posição: Altura e Distância
                local targetPos = Target.HumanoidRootPart.CFrame * CFrame.new(0, _G.AttackHeight, _G.AttackDistance)
                
                local distance = (LP.Character.HumanoidRootPart.Position - targetPos.Position).Magnitude
                local info = TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear)
                
                local tween = TS:Create(LP.Character.HumanoidRootPart, info, {CFrame = targetPos})
                tween:Play()
                
                -- Se chegar muito perto, para o tween para não ficar "dançando"
                if distance < 10 then
                    tween:Cancel()
                    LP.Character.HumanoidRootPart.CFrame = targetPos
                else
                    tween.Completed:Wait()
                end
            end
        end
    end)
end

function FarmLevel:GetClosestEnemy()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            local d = (v.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then closest = v; dist = d end
        end
    end
    return closest
end

getgenv().ZenithHub.Modules.FarmLevel = FarmLevel
return FarmLevel
