local BringMob = {}

function BringMob:Bring(target)

    if not target then
        return
    end

    local enemies = workspace:FindFirstChild("Enemies")

    if not enemies then
        return
    end

    for _, mob in pairs(enemies:GetChildren()) do

        if mob ~= target then

            local hrp =
                mob:FindFirstChild("HumanoidRootPart")

            local hum =
                mob:FindFirstChild("Humanoid")

            if hrp and hum and hum.Health > 0 then

                hrp.CFrame =
                    target.HumanoidRootPart.CFrame *
                    CFrame.new(
                        math.random(-4,4),
                        0,
                        math.random(-4,4)
                    )

            end
        end
    end
end

return BringMob
