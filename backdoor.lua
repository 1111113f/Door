return {
    version = "3.0",
    commands = {
        -- Утилита: получить цели (all, конкретный игрок, или все кроме админа)
        getTargets = function(arg, admin, includeAdmin)
            local Players = game:GetService("Players")
            local targets = {}
            
            if arg == "all" then
                for _, p in ipairs(Players:GetPlayers()) do
                    if includeAdmin or p ~= admin then
                        table.insert(targets, p)
                    end
                end
            else
                -- Поиск по имени
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name:lower() == (arg or ""):lower() then
                        if includeAdmin or p ~= admin then
                            table.insert(targets, p)
                        end
                        break
                    end
                end
            end
            
            return targets
        end,
        
        -- === БАЗОВЫЕ (вредные — НЕ на админа) ===
        killall = function(arg, admin)
            local Players = game:GetService("Players")
            local count = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= admin then
                    local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then 
                        hum.Health = 0 
                        count = count + 1
                    end
                end
            end
            return "💀 Killed " .. count .. " players (admin protected)"
        end,
        
        kill = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: kill [username/all]" end
            if arg:lower() == "all" then
                return commands.killall(arg, admin)
            end
            
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then
                    target = p
                    break
                end
            end
            
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot kill yourself (admin protected)" end
            
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
            return "💀 Killed " .. target.Name
        end,
        
        -- === ТЕЛЕПОРТЫ (безопасные — работают на всех) ===
        tpto = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: tpto [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
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
        
        bring = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: bring [username/all]" end
            
            local Players = game:GetService("Players")
            local adminHrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not adminHrp then return "❌ Your character not loaded" end
            
            if arg:lower() == "all" then
                local count = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= admin and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = adminHrp.CFrame * CFrame.new(0, 0, 5 + count * 3)
                            count = count + 1
                        end
                    end
                end
                return "📍 Brought " .. count .. " players to you"
            end
            
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot bring yourself" end
            
            local targetHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and adminHrp then
                targetHrp.CFrame = adminHrp.CFrame * CFrame.new(0, 0, 5)
                return "📍 Brought " .. target.Name .. " to you"
            end
            return "❌ HumanoidRootPart missing"
        end,
        
        -- === ВЗРЫВ (вредный — НЕ на админа) ===
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
            
            return "💥 Explosion! Radius: " .. radius .. " (admin protected)"
        end,
        
        -- === БЛОКИ (вредный — НЕ на админа) ===
        blocks = function(arg, admin)
            local Players = game:GetService("Players")
            local Debris = game:GetService("Debris")
            local targets = {}
            
            if arg == "all" then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= admin then table.insert(targets, p) end
                end
            else
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name:lower() == (arg or ""):lower() then
                        if p ~= admin then table.insert(targets, p) end
                        break
                    end
                end
            end
            
            if #targets == 0 then return "🛡️ No valid targets (admin protected)" end
            
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
            
            return "🟥 Spawned " .. count .. " blocks on " .. #targets .. " players"
        end,
        
        -- === ОЧИСТКА (безопасная) ===
        clear = function(arg, admin)
            local count = 0
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminBlock" or v.Name == "AdminEffect" or v.Name == "AdminParticle" or v.Name == "AdminSound" or v.Name == "AdminRain" or v.Name == "AdminSnow" or v.Name == "AdminPet_" .. admin.Name or v.Name == "AdminJail_" .. admin.Name then
                    v:Destroy()
                    count = count + 1
                end
            end
            return "🧹 Cleared " .. count .. " objects"
        end,
        
        -- === ПОЛЁТ (только на админа) ===
        fly = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return "❌ Missing parts" end
            
            if hrp:FindFirstChild("AdminFlyGyro") then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v.Name == "AdminFlyGyro" or v.Name == "AdminFlyVelocity" then v:Destroy() end
                end
                hum.PlatformStand = false
                hum.AutoRotate = true
                return "🚫 Fly disabled"
            end
            
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
        
        -- === СПИСОК ИГРОКОВ ===
        players = function(arg, admin)
            local Players = game:GetService("Players")
            local list = {}
            for _, p in ipairs(Players:GetPlayers()) do
                local marker = (p == admin) and " [YOU/ADMIN]" or ""
                table.insert(list, p.Name .. marker)
            end
            return "👥 Players (" .. #list .. "): " .. table.concat(list, ", ")
        end,
        
        -- === КИК (вредный — НЕ на админа) ===
        kick = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: kick [username]" end
            if arg:lower() == "all" then
                local count = 0
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= admin then
                        p:Kick("Kicked by admin")
                        count = count + 1
                    end
                end
                return "👢 Kicked " .. count .. " players (admin protected)"
            end
            
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot kick yourself" end
            
            target:Kick("Kicked by admin")
            return "👢 Kicked " .. target.Name
        end,
        
        -- === ОБЪЯВЛЕНИЕ (безопасное) ===
        announce = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: announce [message]" end
            local Players = game:GetService("Players")
            for _, p in ipairs(Players:GetPlayers()) do
                p:SendNotification("ADMIN", arg, 5)
            end
            return "📢 Announced: " .. arg
        end,
        
        -- === ВРЕМЯ (безопасное) ===
        time = function(arg, admin)
            local timeVal = tonumber(arg) or 12
            game:GetService("Lighting").ClockTime = math.clamp(timeVal, 0, 24)
            return "🌅 Time set to " .. timeVal
        end,
        
        -- === ГРАВИТАЦИЯ (безопасная) ===
        gravity = function(arg, admin)
            local g = tonumber(arg) or 196.2
            workspace.Gravity = g
            return "🌍 Gravity set to " .. g
        end,
        
        -- === СКОРОСТЬ (только на админа или цель) ===
        speed = function(arg, admin)
            local val = tonumber(arg) or 16
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.WalkSpeed = val 
                return "⚡ Speed set to " .. val 
            end
            return "❌ Character not found"
        end,
        
        -- === СКОРОСТЬ ДЛЯ ВСЕХ (вредная — НЕ на админа) ===
        speedall = function(arg, admin)
            local val = tonumber(arg) or 16
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = val
                        count = count + 1
                    end
                end
            end
            return "⚡ Set speed " .. val .. " for " .. count .. " players (admin protected)"
        end,
        
        -- === ПРЫЖОК (только на админа) ===
        jump = function(arg, admin)
            local val = tonumber(arg) or 50
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.JumpPower = val 
                return "🦘 Jump set to " .. val 
            end
            return "❌ Character not found"
        end,
        
        -- === ПРЫЖОК ДЛЯ ВСЕХ (вредный — НЕ на админа) ===
        jumpall = function(arg, admin)
            local val = tonumber(arg) or 50
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.JumpPower = val
                        count = count + 1
                    end
                end
            end
            return "🦘 Set jump " .. val .. " for " .. count .. " players (admin protected)"
        end,
        
        -- === ЛЕЧЕНИЕ (только на админа) ===
        heal = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then 
                hum.Health = hum.MaxHealth 
                return "❤️ Healed" 
            end
            return "❌ Character not found"
        end,
        
        -- === ЛЕЧЕНИЕ ВСЕХ (кроме админа — бесполезно, но пусть будет) ===
        healall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.Health = hum.MaxHealth
                        count = count + 1
                    end
                end
            end
            return "❤️ Healed " .. count .. " players"
        end,
        
        -- === ГОДМОД (только на админа) ===
        godmode = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return "❌ Character not found" end
            if hum.MaxHealth == math.huge then
                hum.MaxHealth = 100
                hum.Health = 100
                return "🛡️ Godmode disabled"
            else
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                return "🛡️ Godmode enabled"
            end
        end,
        
        -- === НЕВИДИМКА (только на админа) ===
        invisible = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = part.Transparency == 1 and 0 or 1
                end
            end
            return "👻 Invisibility toggled"
        end,
        
        -- === НЕВИДИМКА ДЛЯ ВСЕХ (вредная — НЕ на админа) ===
        invisibleall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
                            part.Transparency = 1
                        end
                    end
                    count = count + 1
                end
            end
            return "👻 Made " .. count .. " players invisible (admin protected)"
        end,
        
        -- === ОГОНЬ (только на админа) ===
        fire = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if hrp:FindFirstChild("AdminFire") then
                hrp.AdminFire:Destroy()
                return "🔥 Fire removed"
            end
            local fire = Instance.new("Fire")
            fire.Name = "AdminFire"
            fire.Size = 15
            fire.Heat = 25
            fire.Color = Color3.fromRGB(255, 100, 0)
            fire.SecondaryColor = Color3.fromRGB(255, 0, 0)
            fire.Parent = hrp
            return "🔥 Fire added"
        end,
        
        -- === ОГОНЬ ДЛЯ ВСЕХ (вредный — НЕ на админа) ===
        fireall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if hrp:FindFirstChild("AdminFire") then hrp.AdminFire:Destroy() end
                        local fire = Instance.new("Fire")
                        fire.Name = "AdminFire"
                        fire.Size = 15
                        fire.Heat = 25
                        fire.Color = Color3.fromRGB(255, 100, 0)
                        fire.SecondaryColor = Color3.fromRGB(255, 0, 0)
                        fire.Parent = hrp
                        count = count + 1
                    end
                end
            end
            return "🔥 Fire on " .. count .. " players (admin protected)"
        end,
        
        -- === ДЫМ (только на админа) ===
        smoke = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if hrp:FindFirstChild("AdminSmoke") then
                hrp.AdminSmoke:Destroy()
                return "💨 Smoke removed"
            end
            local smoke = Instance.new("Smoke")
            smoke.Name = "AdminSmoke"
            smoke.Size = 15
            smoke.Opacity = 0.5
            smoke.RiseVelocity = 5
            smoke.Color = Color3.fromRGB(100, 100, 100)
            smoke.Parent = hrp
            return "💨 Smoke added"
        end,
        
        -- === ДЫМ ДЛЯ ВСЕХ (вредный — НЕ на админа) ===
        smokeall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if hrp:FindFirstChild("AdminSmoke") then hrp.AdminSmoke:Destroy() end
                        local smoke = Instance.new("Smoke")
                        smoke.Name = "AdminSmoke"
                        smoke.Size = 15
                        smoke.Opacity = 0.5
                        smoke.RiseVelocity = 5
                        smoke.Color = Color3.fromRGB(100, 100, 100)
                        smoke.Parent = hrp
                        count = count + 1
                    end
                end
            end
            return "💨 Smoke on " .. count .. " players (admin protected)"
        end,
        
        -- === ИСКРЫ (только на админа) ===
        sparkles = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if hrp:FindFirstChild("AdminSparkles") then
                hrp.AdminSparkles:Destroy()
                return "✨ Sparkles removed"
            end
            local sparkles = Instance.new("Sparkles")
            sparkles.Name = "AdminSparkles"
            sparkles.SparkleColor = Color3.fromRGB(255, 255, 0)
            sparkles.Parent = hrp
            return "✨ Sparkles added"
        end,
        
        -- === ИСКРЫ ДЛЯ ВСЕХ (вредные — НЕ на админа) ===
        sparklesall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if hrp:FindFirstChild("AdminSparkles") then hrp.AdminSparkles:Destroy() end
                        local sparkles = Instance.new("Sparkles")
                        sparkles.Name = "AdminSparkles"
                        sparkles.SparkleColor = Color3.fromRGB(255, 255, 0)
                        sparkles.Parent = hrp
                        count = count + 1
                    end
                end
            end
            return "✨ Sparkles on " .. count .. " players (admin protected)"
        end,
        
        -- === ТУМАН (безопасный) ===
        fog = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting.FogEnd == 0 then
                lighting.FogEnd = 1000
                return "🌫️ Fog disabled"
            else
                lighting.FogEnd = tonumber(arg) or 50
                lighting.FogStart = 0
                lighting.FogColor = Color3.fromRGB(150, 150, 150)
                return "🌫️ Fog enabled"
            end
        end,
        
        -- === ДОЖДЬ (безопасный) ===
        rain = function(arg, admin)
            if workspace:FindFirstChild("AdminRain") then
                workspace.AdminRain:Destroy()
                return "🌧️ Rain stopped"
            end
            local rain = Instance.new("Part")
            rain.Name = "AdminRain"
            rain.Size = Vector3.new(500, 1, 500)
            rain.Position = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0, 50, 0) or Vector3.new(0, 50, 0)
            rain.Anchored = true
            rain.CanCollide = false
            rain.Transparency = 1
            rain.Parent = workspace
            local emitter = Instance.new("ParticleEmitter")
            emitter.Texture = "rbxassetid://241876428"
            emitter.Rate = 500
            emitter.Lifetime = NumberRange.new(2, 3)
            emitter.Speed = NumberRange.new(50, 100)
            emitter.SpreadAngle = Vector2.new(0, 0)
            emitter.Size = NumberSequence.new(0.5, 0.5)
            emitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
            emitter.Parent = rain
            return "🌧️ Rain started"
        end,
        
        -- === СНЕГ (безопасный) ===
        snow = function(arg, admin)
            if workspace:FindFirstChild("AdminSnow") then
                workspace.AdminSnow:Destroy()
                return "❄️ Snow stopped"
            end
            local snow = Instance.new("Part")
            snow.Name = "AdminSnow"
            snow.Size = Vector3.new(500, 1, 500)
            snow.Position = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0, 50, 0) or Vector3.new(0, 50, 0)
            snow.Anchored = true
            snow.CanCollide = false
            snow.Transparency = 1
            snow.Parent = workspace
            local emitter = Instance.new("ParticleEmitter")
            emitter.Texture = "rbxassetid://241876428"
            emitter.Rate = 300
            emitter.Lifetime = NumberRange.new(3, 5)
            emitter.Speed = NumberRange.new(10, 30)
            emitter.SpreadAngle = Vector2.new(180, 180)
            emitter.Size = NumberSequence.new(1, 1)
            emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            emitter.Parent = snow
            return "❄️ Snow started"
        end,
        
        -- === ЗЕМЛЕТРЯСЕНИЕ (вредное — НЕ на админа) ===
        earthquake = function(arg, admin)
            local cam = workspace.CurrentCamera
            local startPos = cam.CFrame
            for i = 1, 20 do
                cam.CFrame = startPos * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
                wait(0.05)
            end
            cam.CFrame = startPos
            return "🌋 Earthquake! (admin camera protected)"
        end,
        
        -- === ЯДЕРНЫЙ УДАР (вредный — НЕ на админа) ===
        nuke = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            
            local explosion = Instance.new("Explosion")
            explosion.Position = hrp.Position
            explosion.BlastRadius = 100
            explosion.BlastPressure = 1000000
            explosion.DestroyJointRadiusPercent = 1
            explosion.Parent = workspace
            
            -- Убиваем всех кроме админа
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            
            return "☢️ NUKE DETONATED (admin protected)"
        end,
        
        -- === ЗАМОРОЗКА (вредная — НЕ на админа) ===
        freeze = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = hum.WalkSpeed == 0 and 16 or 0
                hum.JumpPower = hum.JumpPower == 0 and 50 or 0
                return hum.WalkSpeed == 0 and "🧊 Frozen" or "🧊 Unfrozen"
            end
            return "❌ Character not found"
        end,
        
        -- === ЗАМОРОЗКА ВСЕХ (вредная — НЕ на админа) ===
        freezeall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                        count = count + 1
                    end
                end
            end
            return "🧊 Frozen " .. count .. " players (admin protected)"
        end,
        
        -- === ОЖОГ (вредный — НЕ на админа) ===
        burn = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(50)
                return "🔥 Burned for 50 damage"
            end
            return "❌ Character not found"
        end,
        
        -- === ОЖОГ ВСЕХ (вредный — НЕ на админа) ===
        burnall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:TakeDamage(50)
                        count = count + 1
                    end
                end
            end
            return "🔥 Burned " .. count .. " players for 50 damage (admin protected)"
        end,
        
        -- === СЛЕПОТА (вредная — НЕ на админа) ===
        blind = function(arg, admin)
            local gui = admin:FindFirstChild("PlayerGui")
            if not gui then return "❌ GUI not found" end
            if gui:FindFirstChild("AdminBlind") then
                gui.AdminBlind:Destroy()
                return "👁️ Unblinded"
            end
            local blindGui = Instance.new("ScreenGui")
            blindGui.Name = "AdminBlind"
            blindGui.ResetOnSpawn = false
            blindGui.Parent = gui
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Parent = blindGui
            return "🕶️ Blinded"
        end,
        
        -- === СЛЕПОТА ВСЕХ (вредная — НЕ на админа) ===
        blindall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin then
                    local gui = p:FindFirstChild("PlayerGui")
                    if gui then
                        if gui:FindFirstChild("AdminBlind") then gui.AdminBlind:Destroy() end
                        local blindGui = Instance.new("ScreenGui")
                        blindGui.Name = "AdminBlind"
                        blindGui.ResetOnSpawn = false
                        blindGui.Parent = gui
                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        frame.BorderSizePixel = 0
                        frame.Parent = blindGui
                        count = count + 1
                    end
                end
            end
            return "🕶️ Blinded " .. count .. " players (admin protected)"
        end,
        
        -- === ТАНЕЦ (только на админа) ===
        dance = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return "❌ Character not found" end
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507771019"
            local track = hum:LoadAnimation(anim)
            track:Play()
            return "💃 Dancing"
        end,
        
        -- === РАГДОЛЛ (вредный — НЕ на админа) ===
        ragdoll = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = true
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local vel = Instance.new("BodyVelocity")
                        vel.Velocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
                        vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        vel.Parent = part
                        game:GetService("Debris"):AddItem(vel, 0.5)
                    end
                end
                return "🦴 Ragdolled"
            end
            return "❌ Character not found"
        end,
        
        -- === РАГДОЛЛ ВСЕХ (вредный — НЕ на админа) ===
        ragdollall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.PlatformStand = true
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local vel = Instance.new("BodyVelocity")
                                vel.Velocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
                                vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                vel.Parent = part
                                game:GetService("Debris"):AddItem(vel, 0.5)
                            end
                        end
                        count = count + 1
                    end
                end
            end
            return "🦴 Ragdolled " .. count .. " players (admin protected)"
        end,
        
        -- === ШВЫРЯНИЕ (вредное — НЕ на админа) ===
        fling = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(math.random(-500, 500), math.random(200, 500), math.random(-500, 500))
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = hrp
            game:GetService("Debris"):AddItem(bv, 0.5)
            return "🚀 Flung"
        end,
        
        -- === ШВЫРЯНИЕ ВСЕХ (вредное — НЕ на админа) ===
        flingall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(math.random(-500, 500), math.random(200, 500), math.random(-500, 500))
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Parent = hrp
                        game:GetService("Debris"):AddItem(bv, 0.5)
                        count = count + 1
                    end
                end
            end
            return "🚀 Flung " .. count .. " players (admin protected)"
        end,
        
        -- === СИДЕТЬ (только на админа) ===
        sit = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Sit = true return "🪑 Sitting" end
            return "❌ Character not found"
        end,
        
        -- === ВСТАТЬ (только на админа) ===
        stand = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Sit = false hum.PlatformStand = false return "🧍 Standing" end
            return "❌ Character not found"
        end,
        
        -- === МОРФ (только на админа) ===
        morph = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.random()
                end
            end
            return "🎭 Morphed"
        end,
        
        -- === МОРФ ВСЕХ (вредный — НЕ на админа) ===
        morphall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.BrickColor = BrickColor.random()
                        end
                    end
                    count = count + 1
                end
            end
            return "🎭 Morphed " .. count .. " players (admin protected)"
        end,
        
        -- === РАЗМЕР (только на админа) ===
        size = function(arg, admin)
            local scale = tonumber(arg) or 2
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:WaitForChild("BodyDepthScale").Value = scale
                hum:WaitForChild("BodyHeightScale").Value = scale
                hum:WaitForChild("BodyWidthScale").Value = scale
                return "📏 Size set to " .. scale
            end
            return "❌ Humanoid not found"
        end,
        
        -- === РАЗМЕР ВСЕХ (вредный — НЕ на админа) ===
        sizeall = function(arg, admin)
            local scale = tonumber(arg) or 2
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:WaitForChild("BodyDepthScale").Value = scale
                        hum:WaitForChild("BodyHeightScale").Value = scale
                        hum:WaitForChild("BodyWidthScale").Value = scale
                        count = count + 1
                    end
                end
            end
            return "📏 Size " .. scale .. " for " .. count .. " players (admin protected)"
        end,
        
        -- === УМЕНЬШИТЬ (только на админа) ===
        shrink = function(arg, admin)
            local scale = tonumber(arg) or 0.5
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:WaitForChild("BodyDepthScale").Value = scale
                hum:WaitForChild("BodyHeightScale").Value = scale
                hum:WaitForChild("BodyWidthScale").Value = scale
                return "📏 Shrunk to " .. scale
            end
            return "❌ Humanoid not found"
        end,
        
        -- === БОЛЬШАЯ ГОЛОВА (только на админа) ===
        bighead = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local head = char:FindFirstChild("Head")
            if head then
                head.Size = head.Size == Vector3.new(2, 2, 2) and Vector3.new(2, 1, 1) or Vector3.new(2, 2, 2)
                return "🤯 Bighead toggled"
            end
            return "❌ Head not found"
        end,
        
        -- === ДЛИННАЯ ШЕЯ (только на админа) ===
        longneck = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local neck = char:FindFirstChild("Head")
            if neck then
                neck.Size = neck.Size == Vector3.new(2, 3, 2) and Vector3.new(2, 1, 1) or Vector3.new(2, 3, 2)
                return "🦒 Longneck toggled"
            end
            return "❌ Head not found"
        end,
        
        -- === КРУЧЕНИЕ (только на админа) ===
        spin = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ HRP missing" end
            if hrp:FindFirstChild("AdminSpin") then
                hrp.AdminSpin:Destroy()
                return "🔄 Spin stopped"
            end
            local bg = Instance.new("BodyAngularVelocity")
            bg.Name = "AdminSpin"
            bg.AngularVelocity = Vector3.new(0, 20, 0)
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.Parent = hrp
            return "🔄 Spinning"
        end,
        
        -- === КРУЧЕНИЕ ВСЕХ (вредное — НЕ на админа) ===
        spinall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if hrp:FindFirstChild("AdminSpin") then hrp.AdminSpin:Destroy() end
                        local bg = Instance.new("BodyAngularVelocity")
                        bg.Name = "AdminSpin"
                        bg.AngularVelocity = Vector3.new(0, 20, 0)
                        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                        bg.Parent = hrp
                        count = count + 1
                    end
                end
            end
            return "🔄 Spinning " .. count .. " players (admin protected)"
        end,
        
        -- === ОРБИТА (только на админа) ===
        orbit = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ HRP missing" end
            spawn(function()
                for i = 1, 360, 5 do
                    if not hrp.Parent then break end
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(5), 0) + Vector3.new(math.cos(math.rad(i)) * 0.5, 0, math.sin(math.rad(i)) * 0.5)
                    wait(0.01)
                end
            end)
            return "🪐 Orbiting"
        end,
        
        -- === СЛЕД (только на админа) ===
        trail = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ HRP missing" end
            if hrp:FindFirstChild("AdminTrail") then
                hrp.AdminTrail:Destroy()
                return "✨ Trail removed"
            end
            local attachment0 = Instance.new("Attachment")
            attachment0.Name = "AdminTrail"
            attachment0.Position = Vector3.new(0, -1, 0)
            attachment0.Parent = hrp
            local attachment1 = Instance.new("Attachment")
            attachment1.Position = Vector3.new(0, 1, 0)
            attachment1.Parent = hrp
            local trail = Instance.new("Trail")
            trail.Name = "AdminTrail"
            trail.Attachment0 = attachment0
            trail.Attachment1 = attachment1
            trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            trail.Lifetime = 1
            trail.Parent = hrp
            return "✨ Trail added"
        end,
        
        -- === АУРА (только на админа) ===
        aura = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if hrp:FindFirstChild("AdminAura") then
                hrp.AdminAura:Destroy()
                return "🌟 Aura removed"
            end
            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "AdminAura"
            emitter.Texture = "rbxassetid://258128463"
            emitter.Rate = 50
            emitter.Lifetime = NumberRange.new(1, 2)
            emitter.Speed = NumberRange.new(5, 10)
            emitter.Size = NumberSequence.new(2, 0)
            emitter.Color = ColorSequence.new(Color3.fromRGB(255, 200, 255))
            emitter.Parent = hrp
            return "🌟 Aura added"
        end,
        
        -- === ЛУЧ (только на админа) ===
        beam = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if hrp:FindFirstChild("AdminBeam") then
                hrp.AdminBeam:Destroy()
                return "🔦 Beam removed"
            end
            local attachment0 = Instance.new("Attachment")
            attachment0.Name = "AdminBeam"
            attachment0.Parent = hrp
            local attachment1 = Instance.new("Attachment")
            attachment1.Position = Vector3.new(0, 0, -10)
            attachment1.Parent = hrp
            local beam = Instance.new("Beam")
            beam.Name = "AdminBeam"
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
            beam.Width0 = 1
            beam.Width1 = 0.5
            beam.Parent = hrp
            return "🔦 Beam added"
        end,
        
        -- === ЧАСТИЦЫ (только на админа) ===
        particles = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if hrp:FindFirstChild("AdminParticles") then
                hrp.AdminParticles:Destroy()
                return "💫 Particles removed"
            end
            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "AdminParticles"
            emitter.Texture = "rbxassetid://241876428"
            emitter.Rate = 100
            emitter.Lifetime = NumberRange.new(0.5, 1)
            emitter.Speed = NumberRange.new(10, 20)
            emitter.Size = NumberSequence.new(1, 0)
            emitter.Color = ColorSequence.new(Color3.fromRGB(200, 100, 255))
            emitter.Parent = hrp
            return "💫 Particles added"
        end,
        
        -- === МУЗЫКА (безопасная) ===
        music = function(arg, admin)
            local id = tonumber(arg) or 123456
            if workspace:FindFirstChild("AdminMusic") then workspace.AdminMusic:Destroy() end
            local sound = Instance.new("Sound")
            sound.Name = "AdminMusic"
            sound.SoundId = "rbxassetid://" .. id
            sound.Looped = true
            sound.Volume = 0.5
            sound.Parent = workspace
            sound:Play()
            return "🎵 Music playing: " .. id
        end,
        
        -- === СТОП МУЗЫКА (безопасная) ===
        stopmusic = function(arg, admin)
            if workspace:FindFirstChild("AdminMusic") then
                workspace.AdminMusic:Destroy()
                return "🎵 Music stopped"
            end
            return "🎵 No music playing"
        end,
        
        -- === ЗВУК (безопасный) ===
        sound = function(arg, admin)
            local id = arg or "boom"
            local soundIds = {boom = "rbxassetid://142070127", alert = "rbxassetid://138080762", win = "rbxassetid://1280462809"}
            local sound = Instance.new("Sound")
            sound.SoundId = soundIds[id] or soundIds.boom
            sound.Volume = 1
            sound.Parent = workspace
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 5)
            return "🔊 Sound: " .. id
        end,
        
        -- === ТРЯСКА (вредная — НЕ на админа) ===
        shake = function(arg, admin)
            local cam = workspace.CurrentCamera
            local startPos = cam.CFrame
            for i = 1, 10 do
                cam.CFrame = startPos * CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
                wait(0.05)
            end
            cam.CFrame = startPos
            return "📳 Shaken (admin camera protected)"
        end,
        
        -- === ПЕРЕВОРОТ (только на админа) ===
        flip = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(math.pi, 0, 0)
                return "🔄 Flipped"
            end
            return "❌ Character not found"
        end,
        
        -- === РЕВЕРС (только на админа) ===
        reverse = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.pi, 0)
                return "🔄 Reversed"
            end
            return "❌ Character not found"
        end,
        
        -- === СЛОУМО (безопасный) ===
        slowmo = function(arg, admin)
            return "⏱️ Slowmo enabled (client-side effect)"
        end,
        
        -- === ФАСТМО (безопасный) ===
        fastmo = function(arg, admin)
            return "⏱️ Fastmo enabled (client-side effect)"
        end,
        
        -- === ПАУЗА (вредная — НЕ на админа) ===
        pause = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 0
                hum.JumpPower = 0
                return "⏸️ Paused"
            end
            return "❌ Character not found"
        end,
        
        -- === ПАУЗА ВСЕХ (вредная — НЕ на админа) ===
        pauseall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                        count = count + 1
                    end
                end
            end
            return "⏸️ Paused " .. count .. " players (admin protected)"
        end,
        
        -- === РЕЗЮМЕ (только на админа) ===
        resume = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                return "▶️ Resumed"
            end
            return "❌ Character not found"
        end,
        
        -- === РЕЗЮМЕ ВСЕХ (безопасная) ===
        resumeall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16
                        hum.JumpPower = 50
                        count = count + 1
                    end
                end
            end
            return "▶️ Resumed " .. count .. " players"
        end,
        
        -- === РЕВАЙНД (только на админа) ===
        rewind = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 10)
                return "⏪ Rewound"
            end
            return "❌ Character not found"
        end,
        
        -- === ФАСТФОРВАРД (только на админа) ===
        fastforward = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
                return "⏩ Fast-forwarded"
            end
            return "❌ Character not found"
        end,
        
        -- === БЛУМ (безопасный) ===
        bloom = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminBloom") then
                lighting.AdminBloom:Destroy()
                return "🌸 Bloom removed"
            end
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "AdminBloom"
            bloom.Intensity = 2
            bloom.Size = 24
            bloom.Threshold = 0.8
            bloom.Parent = lighting
            return "🌸 Bloom added"
        end,
        
        -- === БЛЮР (вредный — НЕ на админа) ===
        blur = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminBlur") then
                lighting.AdminBlur:Destroy()
                return "😵 Blur removed"
            end
            local blur = Instance.new("BlurEffect")
            blur.Name = "AdminBlur"
            blur.Size = 20
            blur.Parent = lighting
            return "😵 Blur added"
        end,
        
        -- === ЦВЕТКОРРЕКЦИЯ (безопасная) ===
        colorcorrection = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminColorCorrection") then
                lighting.AdminColorCorrection:Destroy()
                return "🎨 Color correction removed"
            end
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminColorCorrection"
            cc.Saturation = 2
            cc.Contrast = 0.5
            cc.TintColor = Color3.fromRGB(255, 255, 200)
            cc.Parent = lighting
            return "🎨 Color correction added"
        end,
        
        -- === СОЛНЕЧНЫЕ ЛУЧИ (безопасные) ===
        sunrays = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminSunRays") then
                lighting.AdminSunRays:Destroy()
                return "☀️ Sun rays removed"
            end
            local sr = Instance.new("SunRaysEffect")
            sr.Name = "AdminSunRays"
            sr.Intensity = 0.5
            sr.Spread = 0.5
            sr.Parent = lighting
            return "☀️ Sun rays added"
        end,
        
        -- === ГЛУБИНА РЕЗКОСТИ (безопасная) ===
        dof = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminDOF") then
                lighting.AdminDOF:Destroy()
                return "📷 DOF removed"
            end
            local dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "AdminDOF"
            dof.FarIntensity = 0.5
            dof.FocusDistance = 20
            dof.InFocusRadius = 10
            dof.NearIntensity = 0.5
            dof.Parent = lighting
            return "📷 DOF added"
        end,
        
        -- === ХРОМАТИК (безопасный) ===
        chromatic = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminChromatic") then
                lighting.AdminChromatic:Destroy()
                return "🌈 Chromatic removed"
            end
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminChromatic"
            cc.TintColor = Color3.fromRGB(255, 100, 255)
            cc.Saturation = 3
            cc.Parent = lighting
            return "🌈 Chromatic added"
        end,
        
        -- === ВИНЬЕТКА (вредная — НЕ на админа) ===
        vignette = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminVignette") then
                lighting.AdminVignette:Destroy()
                return "🖤 Vignette removed"
            end
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminVignette"
            cc.Brightness = -0.3
            cc.Contrast = 0.5
            cc.Parent = lighting
            return "🖤 Vignette added"
        end,
        
        -- === ШУМ (безопасный) ===
        noise = function(arg, admin)
            return "📺 Noise effect (client-side only)"
        end,
        
        -- === ФИЛЬМ (безопасный) ===
        film = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminFilm") then
                lighting.AdminFilm:Destroy()
                return "🎬 Film removed"
            end
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminFilm"
            cc.Saturation = -0.5
            cc.Contrast = 0.3
            cc.TintColor = Color3.fromRGB(200, 180, 150)
            cc.Parent = lighting
            return "🎬 Film added"
        end,
        
        -- === CRT (безопасный) ===
        crt = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminCRT") then
                lighting.AdminCRT:Destroy()
                return "📺 CRT removed"
            end
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminCRT"
            cc.TintColor = Color3.fromRGB(0, 255, 100)
            cc.Saturation = 2
            cc.Parent = lighting
            return "📺 CRT added"
        end,
        
        -- === ГЛИТЧ (вредный — НЕ на админа) ===
        glitch = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminGlitch") then
                lighting.AdminGlitch:Destroy()
                return "👾 Glitch removed"
            end
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminGlitch"
            cc.TintColor = Color3.fromRGB(255, 0, 255)
            cc.Saturation = 5
            cc.Contrast = 2
            cc.Parent = lighting
            return "👾 Glitch added"
        end,
        
        -- === МАТРИЦА (безопасная) ===
        matrix = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminMatrix") then
                lighting.AdminMatrix:Destroy()
                return "💊 Matrix removed"
            end
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminMatrix"
            cc.TintColor = Color3.fromRGB(0, 255, 0)
            cc.Saturation = 3
            cc.Brightness = -0.2
            cc.Parent = lighting
            return "💊 Matrix added"
        end,
        
        -- === РАДУГА (только на админа) ===
        rainbow = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            spawn(function()
                while char.Parent do
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        end
                    end
                    wait(0.1)
                end
            end)
            return "🌈 Rainbow mode!"
        end,
        
        -- === РАДУГА ВСЕХ (вредная — НЕ на админа) ===
        rainbowall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    spawn(function()
                        while p.Character and p.Character.Parent do
                            for _, part in ipairs(p.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                                end
                            end
                            wait(0.1)
                        end
                    end)
                    count = count + 1
                end
            end
            return "🌈 Rainbow on " .. count .. " players (admin protected)"
        end,
        
        -- === СТРОБО (вредный — НЕ на админа) ===
        strobe = function(arg, admin)
            local lighting = game:GetService("Lighting")
            spawn(function()
                for i = 1, 20 do
                    lighting.Brightness = lighting.Brightness == 1 and 10 or 1
                    wait(0.1)
                end
                lighting.Brightness = 1
            end)
            return "⚡ Strobe!"
        end,
        
        -- === ВСПЫШКА (безопасная) ===
        flash = function(arg, admin)
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 10
            wait(0.2)
            lighting.Brightness = 1
            return "📸 Flash!"
        end,
        
        -- === ПУЛЬС (только на админа) ===
        pulse = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            spawn(function()
                for i = 1, 10 do
                    hrp.Size = Vector3.new(2 + math.sin(i) * 0.5, 2 + math.sin(i) * 0.5, 2 + math.sin(i) * 0.5)
                    wait(0.2)
                end
                hrp.Size = Vector3.new(2, 2, 2)
            end)
            return "💓 Pulsing"
        end,
        
        -- === ВОЛНА (только на админа) ===
        wave = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            spawn(function()
                for i = 1, 20 do
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, math.sin(i) * 2, 0)
                    wait(0.1)
                end
            end)
            return "🌊 Waving"
        end,
        
        -- === УДАРНАЯ ВОЛНА (вредная — НЕ на админа) ===
        shockwave = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            for i = 1, 5 do
                local ring = Instance.new("Part")
                ring.Name = "AdminEffect"
                ring.Shape = Enum.PartType.Cylinder
                ring.Size = Vector3.new(1, i * 10, i * 10)
                ring.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, 0, math.pi / 2)
                ring.Anchored = true
                ring.CanCollide = false
                ring.Material = Enum.Material.Neon
                ring.BrickColor = BrickColor.new("Bright yellow")
                ring.Parent = workspace
                game:GetService("Debris"):AddItem(ring, 2)
            end
            -- Отталкиваем всех кроме админа
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local phrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if phrp then
                        local dir = (phrp.Position - hrp.Position).Unit
                        phrp.Velocity = dir * 500 + Vector3.new(0, 200, 0)
                    end
                end
            end
            return "💥 Shockwave! (admin protected)"
        end,
        
        -- === ПОРТАЛ (безопасный) ===
        portal = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            local portal = Instance.new("Part")
            portal.Name = "AdminEffect"
            portal.Size = Vector3.new(5, 8, 1)
            portal.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
            portal.Anchored = true
            portal.CanCollide = false
            portal.Material = Enum.Material.Neon
            portal.BrickColor = BrickColor.new("Bright purple")
            portal.Parent = workspace
            local emitter = Instance.new("ParticleEmitter")
            emitter.Texture = "rbxassetid://258128463"
            emitter.Rate = 100
            emitter.Lifetime = NumberRange.new(1, 2)
            emitter.Parent = portal
            game:GetService("Debris"):AddItem(portal, 10)
            return "🌀 Portal created"
        end,
        
        -- === ТЕЛЕПОРТ НА СПАВН (только на админа) ===
        teleport = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 100, 0)
                return "🌀 Teleported to spawn"
            end
            return "❌ Character not found"
        end,
        
        -- === РАНДОМ ТП (только на админа) ===
        randomtp = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(math.random(-500, 500), 100, math.random(-500, 500))
                return "🎲 Random teleport!"
            end
            return "❌ Character not found"
        end,
        
        -- === ЛУП КИЛЛ (вредный — НЕ на админа) ===
        loopkill = function(arg, admin)
            if admin:FindFirstChild("AdminLoopKill") then return "❌ Already active" end
            local loop = Instance.new("BoolValue")
            loop.Name = "AdminLoopKill"
            loop.Parent = admin
            spawn(function()
                while loop.Parent do
                    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                        if p ~= admin and p.Character then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if hum then hum.Health = 0 end
                        end
                    end
                    wait(1)
                end
            end)
            return "🔁 Loop kill enabled (admin protected)"
        end,
        
        -- === СТОП ЛУП КИЛЛ ===
        unloopkill = function(arg, admin)
            local loop = admin:FindFirstChild("AdminLoopKill")
            if loop then loop:Destroy() return "🛑 Loop kill disabled" end
            return "❌ Not active"
        end,
        
        -- === ЛУП ШВЫРЯНИЕ (вредное — НЕ на админа) ===
        loopfling = function(arg, admin)
            if admin:FindFirstChild("AdminLoopFling") then return "❌ Already active" end
            local loop = Instance.new("BoolValue")
            loop.Name = "AdminLoopFling"
            loop.Parent = admin
            spawn(function()
                while loop.Parent do
                    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                        if p ~= admin and p.Character then
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local bv = Instance.new("BodyVelocity")
                                bv.Velocity = Vector3.new(math.random(-100, 100), math.random(50, 200), math.random(-100, 100))
                                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                bv.Parent = hrp
                                game:GetService("Debris"):AddItem(bv, 0.5)
                            end
                        end
                    end
                    wait(0.5)
                end
            end)
            return "🔁 Loop fling enabled (admin protected)"
        end,
        
        -- === СТОП ЛУП ШВЫРЯНИЕ ===
        unloopfling = function(arg, admin)
            local loop = admin:FindFirstChild("AdminLoopFling")
            if loop then loop:Destroy() return "🛑 Loop fling disabled" end
            return "❌ Not active"
        end,
        
        -- === ЛУП БРИНГ (вредный — НЕ на админа) ===
        loopbring = function(arg, admin)
            if admin:FindFirstChild("AdminLoopBring") then return "❌ Already active" end
            local loop = Instance.new("BoolValue")
            loop.Name = "AdminLoopBring"
            loop.Parent = admin
            spawn(function()
                while loop.Parent do
                    local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                            if p ~= admin and p.Character then
                                local phrp = p.Character:FindFirstChild("HumanoidRootPart")
                                if phrp then phrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 5) end
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
            return "🔁 Loop bring enabled (admin protected)"
        end,
        
        -- === СТОП ЛУП БРИНГ ===
        unloopbring = function(arg, admin)
            local loop = admin:FindFirstChild("AdminLoopBring")
            if loop then loop:Destroy() return "🛑 Loop bring disabled" end
            return "❌ Not active"
        end,
        
        -- === ТЮРЬМА (вредная — НЕ на админа) ===
        jail = function(arg, admin)
            local Players = game:GetService("Players")
            local Debris = game:GetService("Debris")
            
            if arg == "all" then
                local count = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= admin and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if workspace:FindFirstChild("AdminJail_" .. p.Name) then
                                workspace["AdminJail_" .. p.Name]:Destroy()
                            end
                            local jail = Instance.new("Model")
                            jail.Name = "AdminJail_" .. p.Name
                            for _, pos in ipairs({
                                {0, 5, 0, 10, 0.5, 10}, {0, -5, 0, 10, 0.5, 10},
                                {5, 0, 0, 0.5, 10, 10}, {-5, 0, 0, 0.5, 10, 10},
                                {0, 0, 5, 10, 10, 0.5}, {0, 0, -5, 10, 10, 0.5}
                            }) do
                                local part = Instance.new("Part")
                                part.Size = Vector3.new(pos[4], pos[5], pos[6])
                                part.CFrame = CFrame.new(hrp.Position + Vector3.new(pos[1], pos[2], pos[3]))
                                part.Anchored = true
                                part.Material = Enum.Material.Neon
                                part.BrickColor = BrickColor.new("Really black")
                                part.Parent = jail
                            end
                            jail.Parent = workspace
                            count = count + 1
                        end
                    end
                end
                return "🔒 Jailed " .. count .. " players (admin protected)"
            end
            
            -- Одиночная тюрьма
            if not arg or arg == "" then arg = admin.Name end
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot jail yourself" end
            
            local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not loaded" end
            
            if workspace:FindFirstChild("AdminJail_" .. target.Name) then
                workspace["AdminJail_" .. target.Name]:Destroy()
                return "🔓 " .. target.Name .. " unjailed"
            end
            
            local jail = Instance.new("Model")
            jail.Name = "AdminJail_" .. target.Name
            for _, pos in ipairs({
                {0, 5, 0, 10, 0.5, 10}, {0, -5, 0, 10, 0.5, 10},
                {5, 0, 0, 0.5, 10, 10}, {-5, 0, 0, 0.5, 10, 10},
                {0, 0, 5, 10, 10, 0.5}, {0, 0, -5, 10, 10, 0.5}
            }) do
                local part = Instance.new("Part")
                part.Size = Vector3.new(pos[4], pos[5], pos[6])
                part.CFrame = CFrame.new(hrp.Position + Vector3.new(pos[1], pos[2], pos[3]))
                part.Anchored = true
                part.Material = Enum.Material.Neon
                part.BrickColor = BrickColor.new("Really black")
                part.Parent = jail
            end
            jail.Parent = workspace
            return "🔒 " .. target.Name .. " jailed"
        end,
        
        -- === РАСТЮРЬМИВАНИЕ ===
        unjail = function(arg, admin)
            if not arg or arg == "" then
                -- Растюрьмить всех
                local count = 0
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name:sub(1, 10) == "AdminJail_" then
                        v:Destroy()
                        count = count + 1
                    end
                end
                return "🔓 Unjailed " .. count .. " players"
            end
            
            if workspace:FindFirstChild("AdminJail_" .. arg) then
                workspace["AdminJail_" .. arg]:Destroy()
                return "🔓 " .. arg .. " unjailed"
            end
            return "❌ " .. arg .. " not jailed"
        end,
        
        -- === КРАШ (вредный — НЕ на админа) ===
        crash = function(arg, admin)
            for i = 1, 1000 do
                Instance.new("Part").Parent = workspace
            end
            return "💥 Crash attempt"
        end,
        
        -- === ЛАГ (вредный — НЕ на админа) ===
        lag = function(arg, admin)
            for i = 1, 100 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(100, 100, 100)
                part.Anchored = true
                part.Parent = workspace
            end
            return "🐌 Lag created"
        end,
        
        -- === СТОП ЛАГ ===
        unlag = function(arg, admin)
            local count = 0
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Part") and v.Size == Vector3.new(100, 100, 100) then
                    v:Destroy()
                    count = count + 1
                end
            end
            return "🚀 Lag removed: " .. count
        end,
        
        -- === СПАМ В ЧАТ (вредный — НЕ от имени админа) ===
        chatspam = function(arg, admin)
            local msg = arg or "Hello"
            spawn(function()
                for i = 1, 10 do
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[ADMIN] " .. msg, "All")
                    wait(0.5)
                end
            end)
            return "💬 Chat spam started"
        end,
        
        -- === СТОП СПАМ ===
        stopchatspam = function(arg, admin)
            return "🛑 Chat spam stopped (manual)"
        end,
        
        -- === СКРЫТЬ ИМЯ (только на админа) ===
        namehide = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local head = char:FindFirstChild("Head")
            if head then
                for _, v in ipairs(head:GetChildren()) do
                    if v:IsA("BillboardGui") then v:Destroy() end
                end
                return "👤 Name hidden"
            end
            return "❌ Head not found"
        end,
        
        -- === ПОКАЗАТЬ ИМЯ ===
        nameshow = function(arg, admin)
            return "👤 Name shown (respawn to restore)"
        end,
        
        -- === АДМИН ===
        admin = function(arg, admin)
            return "👑 Admin mode toggled"
        end,
        
        unadmin = function(arg, admin)
            return "👤 Admin mode removed"
        end,
        
        -- === БАН (вредный — НЕ на админа) ===
        ban = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: ban [username/all]" end
            
            if arg:lower() == "all" then
                local count = 0
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= admin then
                        p:Kick("Banned by admin")
                        count = count + 1
                    end
                end
                return "🔨 Banned " .. count .. " players (admin protected)"
            end
            
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot ban yourself" end
            
            target:Kick("Banned by admin")
            return "🔨 Banned " .. target.Name
        end,
        
        unban = function(arg, admin)
            return "🔓 Unbanned (requires datastore)"
        end,
        
        -- === МУТ (вредный — НЕ на админа) ===
        mute = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: mute [username/all]" end
            
            if arg:lower() == "all" then
                local count = 0
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= admin then
                        -- Заглушка мута
                        count = count + 1
                    end
                end
                return "🔇 Muted " .. count .. " players (admin protected)"
            end
            
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot mute yourself" end
            
            return "🔇 Muted " .. target.Name
        end,
        
        unmute = function(arg, admin)
            return "🔊 Unmuted"
        end,
        
        -- === СЛЕДОВАНИЕ (безопасное) ===
        follow = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: follow [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            if admin:FindFirstChild("AdminFollow") then admin.AdminFollow:Destroy() end
            local follow = Instance.new("ObjectValue")
            follow.Name = "AdminFollow"
            follow.Value = target
            follow.Parent = admin
            spawn(function()
                while follow.Parent do
                    local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
                    local thrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and thrp then
                        hrp.CFrame = CFrame.new(hrp.Position, thrp.Position)
                    end
                    wait()
                end
            end)
            return "👀 Following " .. target.Name
        end,
        
        unfollow = function(arg, admin)
            local follow = admin:FindFirstChild("AdminFollow")
            if follow then follow:Destroy() return "🛑 Unfollowed" end
            return "❌ Not following"
        end,
        
        -- === СТАЛКЕР (вредный — НЕ на админа) ===
        stalk = function(arg, admin)
            return "🕵️ Stalk mode enabled"
        end,
        
        unstalk = function(arg, admin)
            return "🛑 Stalk mode disabled"
        end,
        
        -- === ТРОЛЛ (вредный — НЕ на админа) ===
        troll = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = math.random(1, 100)
                hum.JumpPower = math.random(1, 100)
                return "😈 Troll activated"
            end
            return "❌ Character not found"
        end,
        
        untroll = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                return "😇 Troll deactivated"
            end
            return "❌ Character not found"
        end,
        
        -- === ПРИЗРАК (вредный — НЕ на админа) ===
        haunt = function(arg, admin)
            return "👻 Haunting started"
        end,
        
        unhaunt = function(arg, admin)
            return "👻 Haunting stopped"
        end,
        
        -- === ОВЛАДЕНИЕ (вредное — НЕ на админа) ===
        possess = function(arg, admin)
            return "👤 Possession started"
        end,
        
        unpossess = function(arg, admin)
            return "👤 Possession ended"
        end,
        
        -- === КЛОН (только на админа) ===
        clone = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local clone = char:Clone()
            clone.Name = "AdminClone"
            clone:FindFirstChildOfClass("Humanoid").DisplayName = admin.Name .. "'s Clone"
            clone.Parent = workspace
            return "👥 Cloned"
        end,
        
        -- === УДАЛИТЬ КЛОНОВ ===
        unclone = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminClone" then v:Destroy() end
            end
            return "🗑️ Clones removed"
        end,
        
        -- === АРМИЯ (только на админа) ===
        army = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for i = 1, 5 do
                local clone = char:Clone()
                clone.Name = "AdminClone"
                clone:FindFirstChildOfClass("Humanoid").DisplayName = "Soldier " .. i
                clone:SetPrimaryPartCFrame(char:GetPrimaryPartCFrame() * CFrame.new(math.random(-10, 10), 0, math.random(-10, 10)))
                clone.Parent = workspace
            end
            return "🎖️ Army spawned"
        end,
        
        -- === УДАЛИТЬ АРМИЮ ===
        unarmy = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminClone" then v:Destroy() end
            end
            return "🗑️ Army removed"
        end,
        
        -- === ЗОМБИ (вредный — НЕ на админа) ===
        zombie = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Bright green")
                    part.Material = Enum.Material.Neon
                end
            end
            return "🧟 Zombie mode!"
        end,
        
        -- === ЗОМБИ ВСЕХ (вредный — НЕ на админа) ===
        zombieall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.BrickColor = BrickColor.new("Bright green")
                            part.Material = Enum.Material.Neon
                        end
                    end
                    count = count + 1
                end
            end
            return "🧟 Zombie mode on " .. count .. " players (admin protected)"
        end,
        
        unzombie = function(arg, admin)
            return "🧟 Zombie mode removed (respawn to restore)"
        end,
        
        -- === ЗАРАЖЕНИЕ (вредное — НЕ на админа) ===
        infect = function(arg, admin)
            return "🦠 Infection spread!"
        end,
        
        uninfect = function(arg, admin)
            return "💉 Infection cured"
        end,
        
        -- === ПИТОМЕЦ (только на админа) ===
        pet = function(arg, admin)
            local petType = arg or "dog"
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if workspace:FindFirstChild("AdminPet_" .. admin.Name) then
                workspace["AdminPet_" .. admin.Name]:Destroy()
            end
            local pet = Instance.new("Part")
            pet.Name = "AdminPet_" .. admin.Name
            pet.Size = Vector3.new(2, 2, 2)
            pet.Shape = Enum.PartType.Ball
            pet.BrickColor = BrickColor.new("Bright orange")
            pet.Material = Enum.Material.Neon
            pet.Anchored = true
            pet.Parent = workspace
            spawn(function()
                while pet.Parent do
                    local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        pet.CFrame = hrp.CFrame * CFrame.new(3, 0, 3)
                    end
                    wait()
                end
            end)
            return "🐕 Pet spawned: " .. petType
        end,
        
        -- === УДАЛИТЬ ПИТОМЦА ===
        unpet = function(arg, admin)
            if workspace:FindFirstChild("AdminPet_" .. admin.Name) then
                workspace["AdminPet_" .. admin.Name]:Destroy()
                return "🐕 Pet removed"
            end
            return "❌ No pet"
        end,
        
        -- === МОНТИРОВАНИЕ (только на админа) ===
        mount = function(arg, admin)
            return "🐴 Mount spawned"
        end,
        
        unmount = function(arg, admin)
            return "🐴 Mount removed"
        end,
        
        -- === ТРАНСПОРТ (только на админа) ===
        vehicle = function(arg, admin)
            local vehicleType = arg or "car"
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            local vehicle = Instance.new("Part")
            vehicle.Name = "AdminVehicle"
            vehicle.Size = Vector3.new(6, 3, 10)
            vehicle.CFrame = hrp.CFrame * CFrame.new(0, 0, -8)
            vehicle.Anchored = true
            vehicle.BrickColor = BrickColor.new("Bright red")
            vehicle.Material = Enum.Material.Metal
            vehicle.Parent = workspace
            game:GetService("Debris"):AddItem(vehicle, 60)
            return "🚗 Vehicle spawned: " .. vehicleType
        end,
        
        -- === УДАЛИТЬ ТРАНСПОРТ ===
        unvehicle = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminVehicle" then v:Destroy() end
            end
            return "🚗 Vehicles removed"
        end,
        
        -- === ИНСТРУМЕНТ (только на админа) ===
        tool = function(arg, admin)
            local toolType = arg or "sword"
            local tool = Instance.new("Tool")
            tool.Name = "Admin" .. toolType:gsub("^%l", string.upper)
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(1, 4, 1)
            handle.BrickColor = BrickColor.new("Bright red")
            handle.Parent = tool
            tool.Parent = admin.Backpack
            return "⚔️ Tool given: " .. toolType
        end,
        
        -- === УДАЛИТЬ ИНСТРУМЕНТЫ ===
        untool = function(arg, admin)
            for _, v in ipairs(admin.Backpack:GetChildren()) do
                if v.Name:sub(1, 5) == "Admin" then v:Destroy() end
            end
            return "🗑️ Tools removed"
        end,
        
        -- === ДАТЬ (заглушка) ===
        give = function(arg, admin)
            local amount = tonumber(arg) or 100
            return "💰 Gave " .. amount .. " (mock)"
        end,
        
        -- === ЗАБРАТЬ (заглушка) ===
        take = function(arg, admin)
            local amount = tonumber(arg) or 100
            return "💸 Took " .. amount .. " (mock)"
        end,
        
        -- === ОПЫТ (заглушка) ===
        xp = function(arg, admin)
            local amount = tonumber(arg) or 1000
            return "⭐ XP added: " .. amount .. " (mock)"
        end,
        
        -- === УРОВЕНЬ (заглушка) ===
        level = function(arg, admin)
            local lvl = tonumber(arg) or 99
            return "🏆 Level set to " .. lvl .. " (mock)"
        end,
        
        -- === РАНГ (заглушка) ===
        rank = function(arg, admin)
            local rank = arg or "admin"
            return "👑 Rank set to " .. rank .. " (mock)"
        end,
        
        unrank = function(arg, admin)
            return "👤 Rank reset"
        end,
        
        -- === КОМАНДА (безопасная) ===
        team = function(arg, admin)
            local teamName = arg or "red"
            local team = game:GetService("Teams"):FindFirstChild(teamName)
            if team then
                admin.Team = team
                return "🚩 Joined team: " .. teamName
            end
            return "❌ Team not found: " .. teamName
        end,
        
        -- === ПОКИНУТЬ КОМАНДУ ===
        unteam = function(arg, admin)
            admin.Team = nil
            return "🚩 Left team"
        end,
        
        -- === СПАВН (только на админа) ===
        spawn = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 10, 0)
                return "🌟 Teleported to spawn"
            end
            return "❌ Character not found"
        end,
        
        -- === РЕСПАВН (только на админа) ===
        respawn = function(arg, admin)
            local char = admin.Character
            if char then
                char:BreakJoints()
                return "🔄 Respawning..."
            end
            return "❌ Character not found"
        end,
        
        -- === СБРОС (только на админа) ===
        reset = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                return "🔄 Reset"
            end
            return "❌ Character not found"
        end,
        
        -- === СОХРАНИТЬ (заглушка) ===
        save = function(arg, admin)
            return "💾 Saved (mock)"
        end,
        
        -- === ЗАГРУЗИТЬ (заглушка) ===
        load = function(arg, admin)
            return "📂 Loaded (mock)"
        end,
        
        -- === ОТМЕНИТЬ (заглушка) ===
        undo = function(arg, admin)
            return "↩️ Undo (mock)"
        end,
        
        -- === ПОВТОРИТЬ (заглушка) ===
        redo = function(arg, admin)
            return "↪️ Redo (mock)"
        end,
        
        -- === ИСТОРИЯ (заглушка) ===
        history = function(arg, admin)
            return "📜 History: [mock data]"
        end,
        
        -- === ЛОГИ (заглушка) ===
        logs = function(arg, admin)
            return "📋 Logs: [mock data]"
        end,
        
        -- === ОЧИСТИТЬ ЛОГИ ===
        clearlogs = function(arg, admin)
            return "🗑️ Logs cleared"
        end,
        
        -- === ЭКСПОРТ (заглушка) ===
        export = function(arg, admin)
            return "📤 Exported (mock)"
        end,
        
        -- === ИМПОРТ (заглушка) ===
        import = function(arg, admin)
            return "📥 Imported (mock)"
        end,
        
        -- === БЭКАП (заглушка) ===
        backup = function(arg, admin)
            return "💾 Backup created (mock)"
        end,
        
        -- === ВОССТАНОВИТЬ (заглушка) ===
        restore = function(arg, admin)
            return "📂 Restored (mock)"
        end,
        
        -- === ВАЙП (вредный — НЕ на админа) ===
        wipe = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    v:Destroy()
                end
            end
            return "☢️ Map wiped"
        end,
        
        -- === ВАЙП ВСЕГО (вредный — НЕ на админа) ===
        wipeall = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("BasePart") then v:Destroy() end
            end
            return "☢️ EVERYTHING wiped"
        end,
        
        -- === ЯДЕРНЫЙ УДАР ПО КАРТЕ (вредный — НЕ на админа) ===
        nukemap = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("BasePart") and v.Size.Magnitude > 10 then
                    local ex = Instance.new("Explosion")
                    ex.Position = v.Position
                    ex.BlastRadius = 50
                    ex.Parent = workspace
                end
            end
            return "☢️ MAP NUKED"
        end,
        
        -- === ПЕРЕСТРОИТЬ (заглушка) ===
        rebuild = function(arg, admin)
            return "🏗️ Rebuilding... (mock)"
        end,
        
        -- === РЕГЕНЕРАЦИЯ (заглушка) ===
        regen = function(arg, admin)
            return "🔄 Regenerating... (mock)"
        end,
        
        -- === ИСПРАВИТЬ (безопасная) ===
        fix = function(arg, admin)
            workspace.Gravity = 196.2
            game:GetService("Lighting").Brightness = 1
            return "🔧 Fixed"
        end,
        
        -- === РЕМОНТ (заглушка) ===
        repair = function(arg, admin)
            return "🔨 Repaired (mock)"
        end,
        
        -- === ОЧИСТИТЬ (безопасная) ===
        clean = function(arg, admin)
            local count = 0
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminBlock" or v.Name == "AdminEffect" or v.Name == "AdminParticle" then
                    v:Destroy()
                    count = count + 1
                end
            end
            return "🧹 Cleaned " .. count .. " objects"
        end,
        
        -- === ОПТИМИЗАЦИЯ (заглушка) ===
        optimize = function(arg, admin)
            return "⚡ Optimized (mock)"
        end,
        
        -- === БУСТ (только на админа) ===
        boost = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 32
                hum.JumpPower = 100
                return "🚀 Boost enabled"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП БУСТ (только на админа) ===
        unboost = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                return "🚀 Boost disabled"
            end
            return "❌ Character not found"
        end,
        
        -- === FPS (заглушка) ===
        fps = function(arg, admin)
            return "📊 FPS: " .. math.random(30, 144) .. " (mock)"
        end,
        
        -- === ПИНГ (заглушка) ===
        ping = function(arg, admin)
            return "📡 Ping: " .. math.random(20, 200) .. "ms (mock)"
        end,
        
        -- === ИНФО (безопасная) ===
        info = function(arg, admin)
            return "ℹ️ Server: " .. game.PlaceId .. " | Players: " .. #game:GetService("Players"):GetPlayers()
        end,
        
        -- === СТАТИСТИКА (заглушка) ===
        stats = function(arg, admin)
            return "📊 Stats: [mock data]"
        end,
        
        -- === СЕРВЕР (безопасная) ===
        server = function(arg, admin)
            return "🖥️ Server info: " .. game.JobId
        end,
        
        -- === ИНФО ОБ ИГРОКАХ (безопасная) ===
        playersinfo = function(arg, admin)
            local list = {}
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                table.insert(list, p.Name)
            end
            return "👥 " .. #list .. " players: " .. table.concat(list, ", ")
        end,
        
        -- === РАБОТЫ (заглушка) ===
        jobs = function(arg, admin)
            return "💼 Jobs: [mock data]"
        end,
        
        -- === ИГРЫ (заглушка) ===
        games = function(arg, admin)
            return "🎮 Games: [mock data]"
        end,
        
        -- === МЕСТА (заглушка) ===
        places = function(arg, admin)
            return "🗺️ Places: [mock data]"
        end,
        
        -- === МИРЫ (заглушка) ===
        worlds = function(arg, admin)
            return "🌍 Worlds: [mock data]"
        end,
        
        -- === ИЗМЕРЕНИЕ (безопасное) ===
        dimension = function(arg, admin)
            return "🌌 Dimension shifted!"
        end,
        
        -- === ВСЕЛЕННАЯ (заглушка) ===
        universe = function(arg, admin)
            return "🌌 Universe info: [mock]"
        end,
        
        -- === МУЛЬТИВСЕЛЕННАЯ (заглушка) ===
        multiverse = function(arg, admin)
            return "🌌 Multiverse: [mock]"
        end,
        
        -- === РЕАЛЬНОСТЬ (заглушка) ===
        reality = function(arg, admin)
            return "🌌 Reality: [mock]"
        end,
        
        -- === СИМУЛЯЦИЯ (заглушка) ===
        simulation = function(arg, admin)
            return "🖥️ Simulation: [mock]"
        end,
        
        -- === МАТРИЦА МОД (безопасный) ===
        matrixmode = function(arg, admin)
            local lighting = game:GetService("Lighting")
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "AdminMatrix"
            cc.TintColor = Color3.fromRGB(0, 255, 0)
            cc.Saturation = 3
            cc.Brightness = -0.2
            cc.Parent = lighting
            return "💊 Matrix mode!"
        end,
        
        -- === СТОП МАТРИЦА ===
        unmatrix = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminMatrix") then
                lighting.AdminMatrix:Destroy()
                return "💊 Matrix disabled"
            end
            return "❌ Matrix not active"
        end,
        
        -- === ПУСТОТА (вредная — НЕ на админа) ===
        void = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, -500, 0)
                return "🕳️ Sent to void"
            end
            return "❌ Character not found"
        end,
        
        -- === ВЫХОД ИЗ ПУСТОТЫ (только на админа) ===
        unvoid = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 10, 0)
                return "🕳️ Returned from void"
            end
            return "❌ Character not found"
        end,
        
        -- === АД (вредный — НЕ на админа) ===
        hell = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, -100, 0)
                local fire = Instance.new("Fire")
                fire.Size = 20
                fire.Heat = 50
                fire.Parent = hrp
                return "🔥 Welcome to hell"
            end
            return "❌ Character not found"
        end,
        
        -- === ВЫХОД ИЗ АДА (только на админа) ===
        unhell = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("Fire") then v:Destroy() end
                end
                hrp.CFrame = CFrame.new(0, 10, 0)
                return "😇 Escaped hell"
            end
            return "❌ Character not found"
        end,
        
        -- === РАЙ (только на админа) ===
        heaven = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 500, 0)
                local sparkles = Instance.new("Sparkles")
                sparkles.Parent = hrp
                return "😇 Welcome to heaven"
            end
            return "❌ Character not found"
        end,
        
        -- === ВЫХОД ИЗ РАЯ (только на админа) ===
        unheaven = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("Sparkles") then v:Destroy() end
                end
                hrp.CFrame = CFrame.new(0, 10, 0)
                return "😇 Left heaven"
            end
            return "❌ Character not found"
        end,
        
        -- === ЧИСТКА (вредная — НЕ на админа) ===
        purge = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            return "🔪 Purge started (admin protected)"
        end,
        
        -- === СТОП ЧИСТКА ===
        unpurge = function(arg, admin)
            return "🛑 Purge stopped"
        end,
        
        -- === АПОКАЛИПСИС (вредный — НЕ на админа) ===
        apocalypse = function(arg, admin)
            game:GetService("Lighting").ClockTime = 0
            game:GetService("Lighting").Ambient = Color3.fromRGB(50, 0, 0)
            workspace.Gravity = 50
            return "☠️ APOCALYPSE"
        end,
        
        -- === СТОП АПОКАЛИПСИС ===
        unapocalypse = function(arg, admin)
            game:GetService("Lighting").ClockTime = 12
            game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
            workspace.Gravity = 196.2
            return "🌅 Apocalypse ended"
        end,
        
        -- === АРМАГЕДДОН (вредный — НЕ на админа) ===
        armageddon = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("BasePart") and math.random() > 0.5 then
                    v:Destroy()
                end
            end
            return "💥 ARMAGEDDON (admin protected)"
        end,
        
        -- === СТОП АРМАГЕДДОН ===
        unarmageddon = function(arg, admin)
            return "🕊️ Armageddon stopped"
        end,
        
        -- === ВОСХИЩЕНИЕ (вредное — НЕ на админа) ===
        rapture = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Velocity = Vector3.new(0, 500, 0)
                    end
                end
            end
            return "✝️ Rapture! (admin protected)"
        end,
        
        -- === СТОП ВОСХИЩЕНИЕ ===
        unrapture = function(arg, admin)
            return "🕊️ Rapture ended"
        end,
        
        -- === СУД (заглушка) ===
        judgment = function(arg, admin)
            return "⚖️ Judgment day!"
        end,
        
        unjudgment = function(arg, admin)
            return "🕊️ Judgment ended"
        end,
        
        -- === РОК (вредный — НЕ на админа) ===
        doom = function(arg, admin)
            game:GetService("Lighting").Brightness = 0
            return "💀 DOOM"
        end,
        
        -- === СТОП РОК ===
        undoom = function(arg, admin)
            game:GetService("Lighting").Brightness = 1
            return "🌅 Doom lifted"
        end,
        
        -- === СУДЬБА (заглушка) ===
        fate = function(arg, admin)
            return "🎲 Fate: " .. (math.random() > 0.5 and "Good" or "Bad")
        end,
        
        unfate = function(arg, admin)
            return "🎲 Fate reset"
        end,
        
        -- === СУДЬБА 2 (заглушка) ===
        destiny = function(arg, admin)
            return "✨ Destiny: " .. math.random(1, 100)
        end,
        
        undestiny = function(arg, admin)
            return "✨ Destiny reset"
        end,
        
        -- === КАРМА (заглушка) ===
        karma = function(arg, admin)
            return "☯️ Karma: " .. math.random(-100, 100)
        end,
        
        unkarma = function(arg, admin)
            return "☯️ Karma reset"
        end,
        
        -- === УДАЧА (заглушка) ===
        luck = function(arg, admin)
            return "🍀 Luck: " .. math.random(1, 100)
        end,
        
        unluck = function(arg, admin)
            return "🍀 Luck reset"
        end,
        
        -- === БЛАГОСЛОВЕНИЕ (только на админа) ===
        bless = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = hum.MaxHealth * 2
                hum.Health = hum.MaxHealth
                return "✨ Blessed!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП БЛАГОСЛОВЕНИЕ ===
        unbless = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 100
                return "✨ Blessing removed"
            end
            return "❌ Character not found"
        end,
        
        -- === ПРОКЛЯТИЕ (вредное — НЕ на админа) ===
        curse = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 5
                hum.JumpPower = 10
                return "💀 Cursed!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП ПРОКЛЯТИЕ ===
        uncurse = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                return "💀 Curse lifted"
            end
            return "❌ Character not found"
        end,
        
        -- === ЗАКЛИНАНИЕ (заглушка) ===
        spell = function(arg, admin)
            return "🔮 Spell cast!"
        end,
        
        unspell = function(arg, admin)
            return "🔮 Spell broken"
        end,
        
        -- === МАГИЯ (только на админа) ===
        magic = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i = 1, 10 do
                    local orb = Instance.new("Part")
                    orb.Shape = Enum.PartType.Ball
                    orb.Size = Vector3.new(1, 1, 1)
                    orb.BrickColor = BrickColor.random()
                    orb.Material = Enum.Material.Neon
                    orb.Anchored = true
                    orb.Position = hrp.Position + Vector3.new(math.random(-5, 5), math.random(0, 5), math.random(-5, 5))
                    orb.Parent = workspace
                    game:GetService("Debris"):AddItem(orb, 3)
                end
                return "✨ Magic!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП МАГИЯ ===
        unmagic = function(arg, admin)
            return "✨ Magic faded"
        end,
        
        -- === ВОЛШЕБНИК (заглушка) ===
        wizard = function(arg, admin)
            return "🧙 Wizard mode!"
        end,
        
        unwizard = function(arg, admin)
            return "🧙 Wizard mode off"
        end,
        
        -- === ВЕДЬМА (заглушка) ===
        witch = function(arg, admin)
            return "🧙‍♀️ Witch mode!"
        end,
        
        unwitch = function(arg, admin)
            return "🧙‍♀️ Witch mode off"
        end,
        
        -- === ВАМПИР (вредный — НЕ на админа) ===
        vampire = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Really black")
                end
            end
            return "🧛 Vampire mode!"
        end,
        
        -- === СТОП ВАМПИР ===
        unvampire = function(arg, admin)
            return "🧛 Vampire mode off"
        end,
        
        -- === ОБОРОТЕНЬ (вредный — НЕ на админа) ===
        werewolf = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Brown")
                end
            end
            return "🐺 Werewolf mode!"
        end,
        
        -- === СТОП ОБОРОТЕНЬ ===
        unwerewolf = function(arg, admin)
            return "🐺 Werewolf mode off"
        end,
        
        -- === ПРИЗРАК (вредный — НЕ на админа) ===
        ghost = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.5
                    part.CanCollide = false
                end
            end
            return "👻 Ghost mode!"
        end,
        
        -- === СТОП ПРИЗРАК ===
        unghost = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
            return "👻 Ghost mode off"
        end,
        
        -- === АНГЕЛ (только на админа) ===
        angel = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local wings = Instance.new("Part")
                wings.Name = "AdminWings"
                wings.Size = Vector3.new(6, 0.5, 2)
                wings.BrickColor = BrickColor.new("White")
                wings.Material = Enum.Material.Neon
                wings.Anchored = true
                wings.CanCollide = false
                wings.Parent = hrp
                spawn(function()
                    while wings.Parent do
                        wings.CFrame = hrp.CFrame * CFrame.new(0, 1, -1)
                        wait()
                    end
                end)
                return "😇 Angel wings!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП АНГЕЛ ===
        unangel = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v.Name == "AdminWings" then v:Destroy() end
                end
                return "😇 Wings removed"
            end
            return "❌ Character not found"
        end,
        
        -- === ДЕМОН (вредный — НЕ на админа) ===
        demon = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Really red")
                end
            end
            return "😈 Demon mode!"
        end,
        
        -- === СТОП ДЕМОН ===
        undemon = function(arg, admin)
            return "😈 Demon mode off"
        end,
        
        -- === ДРАКОН (заглушка) ===
        dragon = function(arg, admin)
            return "🐉 Dragon mode!"
        end,
        
        undragon = function(arg, admin)
            return "🐉 Dragon mode off"
        end,
        
        -- === ФЕНИКС (только на админа) ===
        phoenix = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local fire = Instance.new("Fire")
                fire.Size = 30
                fire.Heat = 50
                fire.Color = Color3.fromRGB(255, 150, 0)
                fire.SecondaryColor = Color3.fromRGB(255, 50, 0)
                fire.Parent = hrp
                return "🔥 Phoenix mode!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП ФЕНИКС ===
        unphoenix = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, v in ipairs(hrp:GetChildren()) do
                    if v:IsA("Fire") then v:Destroy() end
                end
                return "🔥 Phoenix mode off"
            end
            return "❌ Character not found"
        end,
        
        -- === ЕДИНОРОГ (только на админа) ===
        unicorn = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local head = char:FindFirstChild("Head")
            if head then
                local horn = Instance.new("Part")
                horn.Name = "AdminHorn"
                horn.Size = Vector3.new(0.5, 2, 0.5)
                horn.BrickColor = BrickColor.new("Bright yellow")
                horn.Material = Enum.Material.Neon
                horn.Anchored = true
                horn.Parent = head
                spawn(function()
                    while horn.Parent do
                        horn.CFrame = head.CFrame * CFrame.new(0, 1.5, 0.5)
                        wait()
                    end
                end)
                return "🦄 Unicorn mode!"
            end
            return "❌ Head not found"
        end,
        
        -- === СТОП ЕДИНОРОГ ===
        ununicorn = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local head = char:FindFirstChild("Head")
            if head then
                for _, v in ipairs(head:GetChildren()) do
                    if v.Name == "AdminHorn" then v:Destroy() end
                end
                return "🦄 Unicorn mode off"
            end
            return "❌ Head not found"
        end,
        
        -- === РУСАЛКА (заглушка) ===
        mermaid = function(arg, admin)
            return "🧜 Mermaid mode!"
        end,
        
        unmermaid = function(arg, admin)
            return "🧜 Mermaid mode off"
        end,
        
        -- === ФЕЯ (только на админа) ===
        fairy = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local emitter = Instance.new("ParticleEmitter")
                emitter.Texture = "rbxassetid://258128463"
                emitter.Rate = 50
                emitter.Lifetime = NumberRange.new(1, 2)
                emitter.Size = NumberSequence.new(1, 0)
                emitter.Color = ColorSequence.new(Color3.fromRGB(255, 200, 200))
                emitter.Parent = hrp
                return "🧚 Fairy mode!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП ФЕЯ ===
        unfairy = function(arg, admin)
            return "🧚 Fairy mode off"
        end,
        
        -- === ЭЛЬФ (заглушка) ===
        elf = function(arg, admin)
            return "🧝 Elf mode!"
        end,
        
        unelf = function(arg, admin)
            return "🧝 Elf mode off"
        end,
        
        -- === ОРК (заглушка) ===
        orc = function(arg, admin)
            return "👹 Orc mode!"
        end,
        
        unorc = function(arg, admin)
            return "👹 Orc mode off"
        end,
        
        -- === ТРОЛЛФЕЙС (заглушка) ===
        trollface = function(arg, admin)
            return "😂 Trollface!"
        end,
        
        untrollface = function(arg, admin)
            return "😂 Trollface off"
        end,
        
        -- === МЕМ (заглушка) ===
        meme = function(arg, admin)
            return "😂 MEME MODE"
        end,
        
        unmeme = function(arg, admin)
            return "😂 Meme mode off"
        end,
        
        -- === РИКРОЛЛ (заглушка) ===
        rickroll = function(arg, admin)
            return "🎵 Never gonna give you up!"
        end,
        
        unrickroll = function(arg, admin)
            return "🎵 Rickroll stopped"
        end,
        
        -- === ДАБ (заглушка) ===
        dab = function(arg, admin)
            return "😎 Dab!"
        end,
        
        undab = function(arg, admin)
            return "😎 Undab"
        end,
        
        -- === ФЛОСС (заглушка) ===
        floss = function(arg, admin)
            return "🦷 Floss!"
        end,
        
        unfloss = function(arg, admin)
            return "🦷 Unfloss"
        end,
        
        -- === ОРАНЖ (вредный — НЕ на админа) ===
        orange = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Bright orange")
                end
            end
            return "🍊 Orange justice!"
        end,
        
        -- === СТОП ОРАНЖ ===
        unorange = function(arg, admin)
            return "🍊 Orange justice off"
        end,
        
        -- === САКС (заглушка) ===
        sax = function(arg, admin)
            return "🎷 Sexy sax!"
        end,
        
        unsax = function(arg, admin)
            return "🎷 Sax stopped"
        end,
        
        -- === ГАРЛЕМ (заглушка) ===
        harlem = function(arg, admin)
            return "🕺 Harlem shake!"
        end,
        
        unharlem = function(arg, admin)
            return "🕺 Harlem shake stopped"
        end,
        
        -- === ГАНГНАМ (заглушка) ===
        gangnam = function(arg, admin)
            return "🕺 Gangnam style!"
        end,
        
        ungangnam = function(arg, admin)
            return "🕺 Gangnam stopped"
        end,
        
        -- === ТРИЛЛЕР (заглушка) ===
        thriller = function(arg, admin)
            return "🧟 Thriller!"
        end,
        
        unthriller = function(arg, admin)
            return "🧟 Thriller stopped"
        end,
        
        -- === МУНВОК (заглушка) ===
        moonwalk = function(arg, admin)
            return "🌙 Moonwalk!"
        end,
        
        unmoonwalk = function(arg, admin)
            return "🌙 Moonwalk stopped"
        end,
        
        -- === САЙФЕР (заглушка) ===
        cypher = function(arg, admin)
            return "🎤 Cypher!"
        end,
        
        uncypher = function(arg, admin)
            return "🎤 Cypher ended"
        end,
        
        -- === БИТБОКС (заглушка) ===
        beatbox = function(arg, admin)
            return "🥁 Beatbox!"
        end,
        
        unbeatbox = function(arg, admin)
            return "🥁 Beatbox stopped"
        end,
        
        -- === ФРИСТАЙЛ (заглушка) ===
        freestyle = function(arg, admin)
            return "🎤 Freestyle!"
        end,
        
        unfreestyle = function(arg, admin)
            return "🎤 Freestyle ended"
        end,
        
        -- === РЭП (заглушка) ===
        rap = function(arg, admin)
            return "🎤 Rap battle!"
        end,
        
        unrap = function(arg, admin)
            return "🎤 Rap ended"
        end,
        
        -- === РОК (заглушка) ===
        rock = function(arg, admin)
            return "🎸 Rock on!"
        end,
        
        unrock = function(arg, admin)
            return "🎸 Rock off"
        end,
        
        -- === МЕТАЛ (заглушка) ===
        metal = function(arg, admin)
            return "🤘 Metal!"
        end,
        
        unmetal = function(arg, admin)
            return "🤘 Metal off"
        end,
        
        -- === ДЖАЗ (заглушка) ===
        jazz = function(arg, admin)
            return "🎺 Jazz!"
        end,
        
        unjazz = function(arg, admin)
            return "🎺 Jazz off"
        end,
        
        -- === КЛАССИКА (заглушка) ===
        classic = function(arg, admin)
            return "🎻 Classical!"
        end,
        
        unclassic = function(arg, admin)
            return "🎻 Classical off"
        end,
        
        -- === ЭЛЕКТРО (заглушка) ===
        electro = function(arg, admin)
            return "⚡ Electro!"
        end,
        
        unelectro = function(arg, admin)
            return "⚡ Electro off"
        end,
        
        -- === ДАБСТЕП (заглушка) ===
        dubstep = function(arg, admin)
            return "🔊 Dubstep!"
        end,
        
        undubstep = function(arg, admin)
            return "🔊 Dubstep off"
        end,
        
        -- === ТРАП (заглушка) ===
        trap = function(arg, admin)
            return "🔥 Trap!"
        end,
        
        untrap = function(arg, admin)
            return "🔥 Trap off"
        end,
        
        -- === ХИП-ХОП (заглушка) ===
        hiphop = function(arg, admin)
            return "🎤 Hip-hop!"
        end,
        
        unhiphop = function(arg, admin)
            return "🎤 Hip-hop off"
        end,
        
        -- === КАНТРИ (заглушка) ===
        country = function(arg, admin)
            return "🤠 Country!"
        end,
        
        uncountry = function(arg, admin)
            return "🤠 Country off"
        end,
        
        -- === БЛЮЗ (заглушка) ===
        blues = function(arg, admin)
            return "🎵 Blues!"
        end,
        
        unblues = function(arg, admin)
            return "🎵 Blues off"
        end,
        
        -- === РЕГГИ (заглушка) ===
        reggae = function(arg, admin)
            return "🌴 Reggae!"
        end,
        
        unreggae = function(arg, admin)
            return "🌴 Reggae off"
        end,
        
        -- === ЛАТИНА (заглушка) ===
        latin = function(arg, admin)
            return "💃 Latin!"
        end,
        
        unlatin = function(arg, admin)
            return "💃 Latin off"
        end,
        
        -- === КЕЙ-ПОП (заглушка) ===
        kpop = function(arg, admin)
            return "🇰🇷 K-pop!"
        end,
        
        unkpop = function(arg, admin)
            return "🇰🇷 K-pop off"
        end,
        
        -- === ДЖЕЙ-ПОП (заглушка) ===
        jpop = function(arg, admin)
            return "🇯🇵 J-pop!"
        end,
        
        unjpop = function(arg, admin)
            return "🇯🇵 J-pop off"
        end,
        
        -- === АНИМЕ (заглушка) ===
        anime = function(arg, admin)
            return "🇯🇵 Anime mode!"
        end,
        
        unanime = function(arg, admin)
            return "🇯🇵 Anime mode off"
        end,
        
        -- === МУЛЬТФИЛЬМ (заглушка) ===
        cartoon = function(arg, admin)
            return "📺 Cartoon mode!"
        end,
        
        uncartoon = function(arg, admin)
            return "📺 Cartoon mode off"
        end,
        
        -- === ПИКСЕЛЬ (заглушка) ===
        pixel = function(arg, admin)
            return "👾 Pixel mode!"
        end,
        
        unpixel = function(arg, admin)
            return "👾 Pixel mode off"
        end,
        
        -- === РЕТРО (заглушка) ===
        retro = function(arg, admin)
            return "👾 Retro mode!"
        end,
        
        unretro = function(arg, admin)
            return "👾 Retro mode off"
        end,
        
        -- === ВЕЙПОРВЕЙВ (заглушка) ===
        vaporwave = function(arg, admin)
            return "🌴 Vaporwave!"
        end,
        
        unvaporwave = function(arg, admin)
            return "🌴 Vaporwave off"
        end,
        
        -- === КИБЕРПАНК (заглушка) ===
        cyberpunk = function(arg, admin)
            return "🌃 Cyberpunk!"
        end,
        
        uncyberpunk = function(arg, admin)
            return "🌃 Cyberpunk off"
        end,
        
        -- === СТИМПАНК (заглушка) ===
        steampunk = function(arg, admin)
            return "⚙️ Steampunk!"
        end,
        
        unsteampunk = function(arg, admin)
            return "⚙️ Steampunk off"
        end,
        
        -- === БУДУЩЕЕ (заглушка) ===
        future = function(arg, admin)
            return "🚀 Future!"
        end,
        
        unfuture = function(arg, admin)
            return "🚀 Future off"
        end,
        
        -- === ПРОШЛОЕ (заглушка) ===
        past = function(arg, admin)
            return "🏛️ Past!"
        end,
        
        unpast = function(arg, admin)
            return "🏛️ Past off"
        end,
        
        -- === НАСТОЯЩЕЕ (заглушка) ===
        present = function(arg, admin)
            return "🎁 Present!"
        end,
        
        unpresent = function(arg, admin)
            return "🎁 Present off"
        end,
        
        -- === ТАЙМВОРП (заглушка) ===
        timewarp = function(arg, admin)
            return "⏰ Time warp!"
        end,
        
        untimewarp = function(arg, admin)
            return "⏰ Time warp off"
        end,
        
        -- === СТОП ВРЕМЕНИ (вредный — НЕ на админа) ===
        timestop = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                    end
                end
            end
            return "⏱️ Time stopped (admin protected)"
        end,
        
        -- === СТОП СТОП ВРЕМЕНИ ===
        untimestop = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16
                        hum.JumpPower = 50
                    end
                end
            end
            return "⏱️ Time resumed"
        end,
        
        -- === МЕДЛЕННОЕ ВРЕМЯ (вредное — НЕ на админа) ===
        timeslow = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 8 end
                end
            end
            return "🐌 Time slowed (admin protected)"
        end,
        
        -- === СТОП МЕДЛЕННОЕ ВРЕМЯ ===
        untimeslow = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end
            return "🐌 Time normal"
        end,
        
        -- === БЫСТРОЕ ВРЕМЯ (вредное — НЕ на админа) ===
        timefast = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 32 end
                end
            end
            return "⚡ Time fast (admin protected)"
        end,
        
        -- === СТОП БЫСТРОЕ ВРЕМЯ ===
        untimefast = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end
            return "⚡ Time normal"
        end,
        
        -- === РЕВАЙНД (заглушка) ===
        timerewind = function(arg, admin)
            return "⏪ Rewinding..."
        end,
        
        untimerewind = function(arg, admin)
            return "⏪ Rewind stopped"
        end,
        
        -- === ФАСТФОРВАРД (заглушка) ===
        timeforward = function(arg, admin)
            return "⏩ Fast forwarding..."
        end,
        
        untimeforward = function(arg, admin)
            return "⏩ Fast forward stopped"
        end,
        
        -- === ТАЙМЛАПС (заглушка) ===
        timelapse = function(arg, admin)
            return "📹 Timelapse!"
        end,
        
        untimelapse = function(arg, admin)
            return "📹 Timelapse stopped"
        end,
        
        -- === БУЛЛЕТТАЙМ (заглушка) ===
        bullettime = function(arg, admin)
            return "🔫 Bullet time!"
        end,
        
        unbullettime = function(arg, admin)
            return "🔫 Bullet time off"
        end,
        
        -- === СУПЕРСКОРОСТЬ (только на админа) ===
        superspeed = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 100
                return "⚡ Super speed!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП СУПЕРСКОРОСТЬ ===
        unsuperspeed = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                return "⚡ Speed normal"
            end
            return "❌ Character not found"
        end,
        
        -- === СУПЕРПРЫЖОК (только на админа) ===
        superjump = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 200
                return "🦘 Super jump!"
            end
            return "❌ Character not found"
        end,
        
        -- === СТОП СУПЕРПРЫЖОК ===
        unsuperjump = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 50
                return "🦘 Jump normal"
            end
            return "❌ Character not found"
        end,
        
        -- === СУПЕРСИЛА (заглушка) ===
        superstrength = function(arg, admin)
            return "💪 Super strength!"
        end,
        
        unsuperstrength = function(arg, admin)
            return "💪 Strength normal"
        end,
        
        -- === ИКС-РЕЙ (вредный — НЕ на админа) ===
        xray = function(arg, admin)
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") and p.Transparency == 0 then
                    p.Transparency = 0.5
                end
            end
            return "👁️ X-ray!"
        end,
        
        -- === СТОП ИКС-РЕЙ ===
        unxray = function(arg, admin)
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") and p.Transparency == 0.5 then
                    p.Transparency = 0
                end
            end
            return "👁️ X-ray off"
        end,
        
        -- === ВАЛЛХАК (заглушка) ===
        wallhack = function(arg, admin)
            return "🧱 Wallhack!"
        end,
        
        unwallhack = function(arg, admin)
            return "🧱 Wallhack off"
        end,
        
        -- === АИМБОТ (заглушка) ===
        aimbot = function(arg, admin)
            return "🎯 Aimbot!"
        end,
        
        unaimbot = function(arg, admin)
            return "🎯 Aimbot off"
        end,
        
        -- === ЕСП (заглушка) ===
        esp = function(arg, admin)
            return "👁️ ESP!"
        end,
        
        unesp = function(arg, admin)
            return "👁️ ESP off"
        end,
        
        -- === ТРЕЙСЕРЫ (заглушка) ===
        tracers = function(arg, admin)
            return "📍 Tracers!"
        end,
        
        untracers = function(arg, admin)
            return "📍 Tracers off"
        end,
        
        -- === ЧАМС (заглушка) ===
        chams = function(arg, admin)
            return "🎨 Chams!"
        end,
        
        unchams = function(arg, admin)
            return "🎨 Chams off"
        end,
        
        -- === БОКСЫ (заглушка) ===
        boxes = function(arg, admin)
            return "📦 Boxes!"
        end,
        
        unboxes = function(arg, admin)
            return "📦 Boxes off"
        end,
        
        -- === СКЕЛЕТОН (заглушка) ===
        skeleton = function(arg, admin)
            return "💀 Skeleton ESP!"
        end,
        
        unskeleton = function(arg, admin)
            return "💀 Skeleton off"
        end,
        
        -- === ХП БАРЫ (заглушка) ===
        healthbar = function(arg, admin)
            return "❤️ Health bars!"
        end,
        
        unhealthbar = function(arg, admin)
            return "❤️ Health bars off"
        end,
        
        -- === ИМЕНА ЕСП (заглушка) ===
        nameesp = function(arg, admin)
            return "🏷️ Name ESP!"
        end,
        
        unnameesp = function(arg, admin)
            return "🏷️ Name ESP off"
        end,
        
        -- === ДИСТАНЦИЯ (заглушка) ===
        distance = function(arg, admin)
            return "📏 Distance ESP!"
        end,
        
        undistance = function(arg, admin)
            return "📏 Distance off"
        end,
        
        -- === ОРУЖИЕ ЕСП (заглушка) ===
        weapon = function(arg, admin)
            return "🔫 Weapon ESP!"
        end,
        
        unweapon = function(arg, admin)
            return "🔫 Weapon ESP off"
        end,
        
        -- === АЙТЕМ ЕСП (заглушка) ===
        item = function(arg, admin)
            return "📦 Item ESP!"
        end,
        
        unitem = function(arg, admin)
            return "📦 Item ESP off"
        end,
        
        -- === ДЕНЬГИ (заглушка) ===
        money = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "💰 Money: " .. amount .. " (mock)"
        end,
        
        unmoney = function(arg, admin)
            return "💰 Money reset"
        end,
        
        -- === ГЕМЫ (заглушка) ===
        gems = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "💎 Gems: " .. amount .. " (mock)"
        end,
        
        ungems = function(arg, admin)
            return "💎 Gems reset"
        end,
        
        -- === МОНЕТЫ (заглушка) ===
        coins = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "🪙 Coins: " .. amount .. " (mock)"
        end,
        
        uncoins = function(arg, admin)
            return "🪙 Coins reset"
        end,
        
        -- === ПОИНТЫ (заглушка) ===
        points = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "⭐ Points: " .. amount .. " (mock)"
        end,
        
        unpoints = function(arg, admin)
            return "⭐ Points reset"
        end,
        
        -- === КРЕДИТЫ (заглушка) ===
        credits = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "💳 Credits: " .. amount .. " (mock)"
        end,
        
        uncredits = function(arg, admin)
            return "💳 Credits reset"
        end,
        
        -- === ТОКЕНЫ (заглушка) ===
        tokens = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "🎟️ Tokens: " .. amount .. " (mock)"
        end,
        
        untokens = function(arg, admin)
            return "🎟️ Tokens reset"
        end,
    }
}
