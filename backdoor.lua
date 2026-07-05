return {
    version = "3.0",
    commands = {
        -- Убить игрока (target или all)
        killall = function(arg, admin)
            local Players = game:GetService("Players")
            for _, p in ipairs(Players:GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
            end
            return "💀 All players killed"
        end,
        
        kill = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: kill [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then
                    target = p
                    break
                end
            end
            if not target then return "❌ Player not found: " .. arg end
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
            return "💀 Killed " .. target.Name
        end,
        
        -- Телепорт к игроку
        tpto = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: tpto [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then
                    target = p
                    break
                end
            end
            if not target then return "❌ Player not found: " .. arg end
            if not target.Character or not admin.Character then return "❌ Character not loaded" end
            
            local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local adminHrp = admin.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and adminHrp then
                adminHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 3, 5)
                return "📍 Teleported to " .. target.Name
            end
            return "❌ HumanoidRootPart missing"
        end,
        
        -- Телепорт игрока к админу
        bring = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: bring [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then
                    target = p
                    break
                end
            end
            if not target then return "❌ Player not found: " .. arg end
            if not target.Character or not admin.Character then return "❌ Character not loaded" end
            
            local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local adminHrp = admin.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and adminHrp then
                targetHrp.CFrame = adminHrp.CFrame * CFrame.new(0, 0, 5)
                return "📍 Brought " .. target.Name .. " to you"
            end
            return "❌ HumanoidRootPart missing"
        end,
        
        -- Взрыв
        explode = function(arg, admin)
            local radius = tonumber(arg) or 30
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            
            local explosion = Instance.new("Explosion")
            explosion.Position = hrp.Position
            explosion.BlastRadius = math.clamp(radius, 10, 100)
            explosion.BlastPressure = 500000
            explosion.DestroyJointRadiusPercent = 0
            explosion.Parent = workspace
            
            explosion.Hit:Connect(function(hit)
                local hum = hit:FindFirstAncestorOfClass("Humanoid")
                if hum and hum.Parent ~= admin.Character then
                    hum:TakeDamage(100)
                end
            end)
            
            return "💥 Explosion! Radius: " .. radius
        end,
        
        -- Спавн блоков
        blocks = function(arg, admin)
            local Players = game:GetService("Players")
            local Debris = game:GetService("Debris")
            local targets = {}
            
            if arg == "all" then
                targets = Players:GetPlayers()
            else
                local target = nil
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name:lower() == (arg or ""):lower() then
                        target = p
                        break
                    end
                end
                if target then table.insert(targets, target) end
            end
            
            if #targets == 0 then return "❌ No targets found" end
            
            local count = 0
            for _, p in ipairs(targets) do
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for i = 1, 8 do
                        local b = Instance.new("Part")
                        b.Name = "AdminBlock"
                        b.Size = Vector3.new(2, 2, 2)
                        b.BrickColor = BrickColor.new("Bright red")
                        b.Material = Enum.Material.Neon
                        b.Anchored = true
                        b.CanCollide = false
                        b.Shape = Enum.PartType.Ball
                        b.Position = hrp.Position + Vector3.new(
                            math.cos(i * math.pi / 4) * 5,
                            2,
                            math.sin(i * math.pi / 4) * 5
                        )
                        b.Parent = workspace
                        Debris:AddItem(b, 10)
                        count = count + 1
                    end
                end
            end
            
            return "🟥 Spawned " .. count .. " blocks"
        end,
        
        -- Очистка
        clear = function(arg, admin)
            local count = 0
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminBlock" or v.Name == "AdminEffect" then
                    v:Destroy()
                    count = count + 1
                end
            end
            return "🧹 Cleared " .. count .. " objects"
        end,
        
        -- Полёт
        fly = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return "❌ Missing parts" end
            
            -- Проверяем, уже летает ли
            if hrp:FindFirstChild("AdminFlyGyro") then
                -- Выключить
                for _, v in ipairs(hrp:GetChildren()) do
                    if v.Name == "AdminFlyGyro" or v.Name == "AdminFlyVelocity" then
                        v:Destroy()
                    end
                end
                hum.PlatformStand = false
                hum.AutoRotate = true
                return "🚫 Fly disabled"
            end
            
            -- Включить
            local bg = Instance.new("BodyGyro")
            bg.Name = "AdminFlyGyro"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 10000
            bg.D = 100
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            
            local bv = Instance.new("BodyVelocity")
            bv.Name = "AdminFlyVelocity"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            
            hum.PlatformStand = true
            hum.AutoRotate = false
            
            return "✈️ Fly enabled"
        end,
        
        -- Список игроков
        players = function(arg, admin)
            local Players = game:GetService("Players")
            local list = {}
            for _, p in ipairs(Players:GetPlayers()) do
                table.insert(list, p.Name)
            end
            return "👥 Players (" .. #list .. "): " .. table.concat(list, ", ")
        end,
        
        -- Кик
        kick = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: kick [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then
                    target = p
                    break
                end
            end
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "❌ Cannot kick yourself" end
            
            target:Kick("Kicked by admin")
            return "👢 Kicked " .. target.Name
        end,
        
        -- Сообщение
        announce = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: announce [message]" end
            local Players = game:GetService("Players")
            for _, p in ipairs(Players:GetPlayers()) do
                p:SendNotification("Admin Message", arg, 5)
            end
            return "📢 Announced: " .. arg
        end,
        
        -- Время
        time = function(arg, admin)
            local timeVal = tonumber(arg) or 12
            game:GetService("Lighting").ClockTime = math.clamp(timeVal, 0, 24)
            return "🌅 Time set to " .. timeVal
        end,
        
        -- Гравитация
        gravity = function(arg, admin)
            local g = tonumber(arg) or 196.2
            workspace.Gravity = g
            return "🌍 Gravity set to " .. g
        end,
    }
}
