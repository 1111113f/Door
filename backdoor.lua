return {
    version = "2.0",
    commands = {
        -- Убивает всех игроков
        killall = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChild("Humanoid")
                if hum then hum.Health = 0 end
            end
            return "💀 All players killed"
        end,
        
        -- Устанавливает скорость (всем или конкретному игроку)
        speed = function(arg, admin)
            local speed = tonumber(arg) or 100
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = speed end
            end
            return "⚡ Speed set to " .. speed .. " for all"
        end,
        
        -- Спавнит красные блоки вокруг ВСЕХ игроков
        blocks = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for i = 1, 8 do
                        local b = Instance.new("Part")
                        b.Name = "RedBlock"
                        b.Size = Vector3.new(2, 2, 2)
                        b.BrickColor = BrickColor.new("Bright red")
                        b.Material = Enum.Material.Neon
                        b.Anchored = true
                        b.CanCollide = false
                        b.Position = hrp.Position + Vector3.new(
                            math.cos(i * math.pi / 4) * 5,
                            2,
                            math.sin(i * math.pi / 4) * 5
                        )
                        b.Parent = workspace
                        game:GetService("Debris"):AddItem(b, 10)
                    end
                end
            end
            return "🟥 Red blocks spawned around all players"
        end,
        
        -- Взрыв
        explode = function(arg, admin)
            local radius = tonumber(arg) or 50
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local explosion = Instance.new("Explosion")
                explosion.Position = hrp.Position
                explosion.BlastRadius = radius
                explosion.BlastPressure = 500000
                explosion.Parent = workspace
            end
            return "💥 Explosion! Radius: " .. radius
        end,
        
        -- Телепорт к игроку
        tpto = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: tpto [username]" end
            local target = game:GetService("Players"):FindFirstChild(arg)
            if not target then return "❌ Player not found: " .. arg end
            if not target.Character or not admin.Character then return "❌ Character not loaded" end
            
            local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local adminHrp = admin.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and adminHrp then
                adminHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                return "📍 Teleported to " .. arg
            end
            return "❌ HumanoidRootPart missing"
        end,
        
        -- Очистка блоков
        clear = function(arg, admin)
            local count = 0
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "RedBlock" then
                    v:Destroy()
                    count = count + 1
                end
            end
            return "🧹 Cleared " .. count .. " blocks"
        end,
        
        -- Прыжок
        jump = function(arg, admin)
            local power = tonumber(arg) or 100
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChild("Humanoid")
                if hum then hum.JumpPower = power end
            end
            return "🦘 Jump power: " .. power
        end,
        
        -- Полёт (вкл/выкл)
        fly = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then return "❌ Missing parts" end
            
            -- Простой полёт через BodyGyro + BodyVelocity
            if hrp:FindFirstChild("FlyGyro") then
                hrp.FlyGyro:Destroy()
                hrp.FlyVelocity:Destroy()
                hum.PlatformStand = false
                return "🚫 Fly disabled"
            else
                local bg = Instance.new("BodyGyro")
                bg.Name = "FlyGyro"
                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bg.CFrame = hrp.CFrame
                bg.Parent = hrp
                
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVelocity"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
                
                hum.PlatformStand = true
                return "✈️ Fly enabled (use WASD + Space/Shift)"
            end
        end,
        
        -- Список игроков
        players = function(arg, admin)
            local list = {}
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                table.insert(list, p.Name)
            end
            return "👥 Players: " .. table.concat(list, ", ")
        end,
    }
}
