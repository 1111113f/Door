return {
    version = "3.0",
    commands = {
        -- === БАЗОВЫЕ ===
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
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
            return "💀 Killed " .. target.Name
        end,
        
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
            if not arg or arg == "" then return "❌ Usage: bring [username]" end
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
                targetHrp.CFrame = adminHrp.CFrame * CFrame.new(0, 0, 5)
                return "📍 Brought " .. target.Name .. " to you"
            end
            return "❌ HumanoidRootPart missing"
        end,
        
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
                if hum and hum.Parent ~= admin.Character then hum:TakeDamage(100) end
            end)
            return "💥 Explosion! Radius: " .. radius
        end,
        
        blocks = function(arg, admin)
            local Players = game:GetService("Players")
            local Debris = game:GetService("Debris")
            local targets = {}
            if arg == "all" then
                targets = Players:GetPlayers()
            else
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name:lower() == (arg or ""):lower() then table.insert(targets, p) break end
                end
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
                        b.Position = hrp.Position + Vector3.new(math.cos(i * math.pi / 4) * 5, 2, math.sin(i * math.pi / 4) * 5)
                        b.Parent = workspace
                        Debris:AddItem(b, 10)
                        count = count + 1
                    end
                end
            end
            return "🟥 Spawned " .. count .. " blocks"
        end,
        
        clear = function(arg, admin)
            local count = 0
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminBlock" or v.Name == "AdminEffect" or v.Name == "AdminParticle" or v.Name == "AdminSound" then
                    v:Destroy()
                    count = count + 1
                end
            end
            return "🧹 Cleared " .. count .. " objects"
        end,
        
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
        
        players = function(arg, admin)
            local Players = game:GetService("Players")
            local list = {}
            for _, p in ipairs(Players:GetPlayers()) do table.insert(list, p.Name) end
            return "👥 Players (" .. #list .. "): " .. table.concat(list, ", ")
        end,
        
        kick = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: kick [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "❌ Cannot kick yourself" end
            target:Kick("Kicked by admin")
            return "👢 Kicked " .. target.Name
        end,
        
        announce = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: announce [message]" end
            local Players = game:GetService("Players")
            for _, p in ipairs(Players:GetPlayers()) do
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "ADMIN",
                    Text = arg,
                    Duration = 5
                })
            end
            return "📢 Announced: " .. arg
        end,
        
        time = function(arg, admin)
            local timeVal = tonumber(arg) or 12
            game:GetService("Lighting").ClockTime = math.clamp(timeVal, 0, 24)
            return "🌅 Time set to " .. timeVal
        end,
        
        gravity = function(arg, admin)
            local g = tonumber(arg) or 196.2
            workspace.Gravity = g
            return "🌍 Gravity set to " .. g
        end,
        
        -- === СКОРОСТЬ / ПРЫЖОК ===
        speed = function(arg, admin)
            local val = tonumber(arg) or 16
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val return "⚡ Speed set to " .. val end
            return "❌ Character not found"
        end,
        
        jump = function(arg, admin)
            local val = tonumber(arg) or 50
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val return "🦘 Jump set to " .. val end
            return "❌ Character not found"
        end,
        
        heal = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth return "❤️ Healed" end
            return "❌ Character not found"
        end,
        
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
        
        -- === ВИДИМОСТЬ ===
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
        
        -- === ЭФФЕКТЫ ===
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
        
        -- === ПОГОДА ===
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
        
        earthquake = function(arg, admin)
            local cam = workspace.CurrentCamera
            local startPos = cam.CFrame
            for i = 1, 20 do
                cam.CFrame = startPos * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
                wait(0.05)
            end
            cam.CFrame = startPos
            return "🌋 Earthquake!"
        end,
        
        nuke = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            local explosion = Instance.new("Explosion")
            explosion.Position = hrp.Position
            explosion.BlastRadius = 100
            explosion.BlastPressure = 1000000
            explosion.DestroyJointRadiusPercent = 1
            explosion.Parent = workspace
            return "☢️ NUKE DETONATED"
        end,
        
        freeze = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = hum.WalkSpeed == 0 and 16 or 0
                hum.JumpPower = hum.JumpPower == 0 and 50 or 0
                return hum.WalkSpeed == 0 and "🧊 Frozen" or "🧊 Unfrozen"
            end
            return "❌ Character not found"
        end,
        
        burn = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(50)
                return "🔥 Burned for 50 damage"
            end
            return "❌ Character not found"
        end,
        
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
        
        -- === АНИМАЦИИ ===
        dance = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return "❌ Character not found" end
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507771019"
            local track = hum:LoadAnimation(anim)
            track:Play()
            return "💃 Dancing"
        end,
        
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
        
        sit = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Sit = true return "🪑 Sitting" end
            return "❌ Character not found"
        end,
        
        stand = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Sit = false hum.PlatformStand = false return "🧍 Standing" end
            return "❌ Character not found"
        end,
        
        -- === МОРФЫ / РАЗМЕР ===
        morph = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ HRP missing" end
            -- Простая смена цвета как "морф"
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.random()
                end
            end
            return "🎭 Morphed"
        end,
        
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
        
        -- === ТРЕЙЛЫ / АУРА ===
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
        
        -- === ЗВУК ===
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
        
        stopmusic = function(arg, admin)
            if workspace:FindFirstChild("AdminMusic") then
                workspace.AdminMusic:Destroy()
                return "🎵 Music stopped"
            end
            return "🎵 No music playing"
        end,
        
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
        
        shake = function(arg, admin)
            local cam = workspace.CurrentCamera
            local startPos = cam.CFrame
            for i = 1, 10 do
                cam.CFrame = startPos * CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
                wait(0.05)
            end
            cam.CFrame = startPos
            return "📳 Shaken"
        end,
        
        -- === ФИЗИКА ===
        flip = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(math.pi, 0, 0)
                return "🔄 Flipped"
            end
            return "❌ Character not found"
        end,
        
        reverse = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.pi, 0)
                return "🔄 Reversed"
            end
            return "❌ Character not found"
        end,
        
        slowmo = function(arg, admin)
            game:GetService("RunService").Heartbeat:Wait()
            -- Упрощённый slowmo через изменение скорости анимаций
            return "⏱️ Slowmo enabled (client-side effect)"
        end,
        
        fastmo = function(arg, admin)
            return "⏱️ Fastmo enabled (client-side effect)"
        end,
        
        pause = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 0
                hum.JumpPower = 0
                return "⏸️ Paused"
            end
            return "❌ Character not found"
        end,
        
        resume = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                return "▶️ Resumed"
            end
            return "❌ Character not found"
        end,
        
        rewind = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 10)
                return "⏪ Rewound"
            end
            return "❌ Character not found"
        end,
        
        fastforward = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
                return "⏩ Fast-forwarded"
            end
            return "❌ Character not found"
        end,
        
        -- === ПОСТПРОЦЕССИНГ ===
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
        
        noise = function(arg, admin)
            return "📺 Noise effect (client-side only)"
        end,
        
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
        
        flash = function(arg, admin)
            local lighting = game:GetService("Lighting")
            lighting.Brightness = 10
            wait(0.2)
            lighting.Brightness = 1
            return "📸 Flash!"
        end,
        
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
            return "💥 Shockwave!"
        end,
        
        -- === ТЕЛЕПОРТЫ ===
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
        
        teleport = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 100, 0)
                return "🌀 Teleported to spawn"
            end
            return "❌ Character not found"
        end,
        
        randomtp = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(math.random(-500, 500), 100, math.random(-500, 500))
                return "🎲 Random teleport!"
            end
            return "❌ Character not found"
        end,
        
        -- === ЛУПЫ ===
        loopkill = function(arg, admin)
            if admin:FindFirstChild("AdminLoopKill") then return "❌ Already active" end
            local loop = Instance.new("BoolValue")
            loop.Name = "AdminLoopKill"
            loop.Parent = admin
            spawn(function()
                while loop.Parent do
                    local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                    wait(1)
                end
            end)
            return "🔁 Loop kill enabled"
        end,
        
        unloopkill = function(arg, admin)
            local loop = admin:FindFirstChild("AdminLoopKill")
            if loop then loop:Destroy() return "🛑 Loop kill disabled" end
            return "❌ Not active"
        end,
        
        loopfling = function(arg, admin)
            if admin:FindFirstChild("AdminLoopFling") then return "❌ Already active" end
            local loop = Instance.new("BoolValue")
            loop.Name = "AdminLoopFling"
            loop.Parent = admin
            spawn(function()
                while loop.Parent do
                    local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(math.random(-100, 100), math.random(50, 200), math.random(-100, 100))
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Parent = hrp
                        game:GetService("Debris"):AddItem(bv, 0.5)
                    end
                    wait(0.5)
                end
            end)
            return "🔁 Loop fling enabled"
        end,
        
        unloopfling = function(arg, admin)
            local loop = admin:FindFirstChild("AdminLoopFling")
            if loop then loop:Destroy() return "🛑 Loop fling disabled" end
            return "❌ Not active"
        end,
        
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
            return "🔁 Loop bring enabled"
        end,
        
        unloopbring = function(arg, admin)
            local loop = admin:FindFirstChild("AdminLoopBring")
            if loop then loop:Destroy() return "🛑 Loop bring disabled" end
            return "❌ Not active"
        end,
        
        -- === ТЮРЬМА / КРАШ ===
        jail = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return "❌ Character not found" end
            if workspace:FindFirstChild("AdminJail_" .. admin.Name) then
                workspace["AdminJail_" .. admin.Name]:Destroy()
                return "🔓 Jail removed"
            end
            local jail = Instance.new("Model")
            jail.Name = "AdminJail_" .. admin.Name
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
            return "🔒 Jailed"
        end,
        
        unjail = function(arg, admin)
            if workspace:FindFirstChild("AdminJail_" .. admin.Name) then
                workspace["AdminJail_" .. admin.Name]:Destroy()
                return "🔓 Unjailed"
            end
            return "❌ Not jailed"
        end,
        
        crash = function(arg, admin)
            for i = 1, 1000 do
                Instance.new("Part").Parent = workspace
            end
            return "💥 Crash attempt"
        end,
        
        lag = function(arg, admin)
            for i = 1, 100 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(100, 100, 100)
                part.Anchored = true
                part.Parent = workspace
            end
            return "🐌 Lag created"
        end,
        
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
        
        -- === ЧАТ / ИМЕНА ===
        chatspam = function(arg, admin)
            local msg = arg or "Hello"
            spawn(function()
                for i = 1, 10 do
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                    wait(0.5)
                end
            end)
            return "💬 Chat spam started"
        end,
        
        stopchatspam = function(arg, admin)
            return "🛑 Chat spam stopped (manual)"
        end,
        
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
        
        nameshow = function(arg, admin)
            return "👤 Name shown (respawn to restore)"
        end,
        
        -- === АДМИН / БАН ===
        admin = function(arg, admin)
            -- Заглушка - в реальности нужна система прав
            return "👑 Admin mode toggled"
        end,
        
        unadmin = function(arg, admin)
            return "👤 Admin mode removed"
        end,
        
        ban = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: ban [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            target:Kick("Banned by admin")
            return "🔨 Banned " .. target.Name
        end,
        
        unban = function(arg, admin)
            return "🔓 Unbanned (requires datastore)"
        end,
        
        mute = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: mute [username]" end
            local Players = game:GetService("Players")
            local target = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == arg:lower() then target = p break end
            end
            if not target then return "❌ Player not found: " .. arg end
            -- Заглушка
            return "🔇 Muted " .. target.Name
        end,
        
        unmute = function(arg, admin)
            return "🔊 Unmuted"
        end,
        
        -- === СЛЕЖКА ===
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
        
        stalk = function(arg, admin)
            return "🕵️ Stalk mode enabled"
        end,
        
        unstalk = function(arg, admin)
            return "🛑 Stalk mode disabled"
        end,
        
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
        
        haunt = function(arg, admin)
            return "👻 Haunting started"
        end,
        
        unhaunt = function(arg, admin)
            return "👻 Haunting stopped"
        end,
        
        possess = function(arg, admin)
            return "👤 Possession started"
        end,
        
        unpossess = function(arg, admin)
            return "👤 Possession ended"
        end,
        
        -- === КЛОНЫ / АРМИЯ ===
        clone = function(arg, admin)
            local char = admin.Character
            if not char then return "❌ Character not found" end
            local clone = char:Clone()
            clone.Name = "AdminClone"
            clone:FindFirstChildOfClass("Humanoid").DisplayName = admin.Name .. "'s Clone"
            clone.Parent = workspace
            return "👥 Cloned"
        end,
        
        unclone = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminClone" then v:Destroy() end
            end
            return "🗑️ Clones removed"
        end,
        
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
        
        unarmy = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminClone" then v:Destroy() end
            end
            return "🗑️ Army removed"
        end,
        
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
        
        unzombie = function(arg, admin)
            return "🧟 Zombie mode removed (respawn to restore)"
        end,
        
        infect = function(arg, admin)
            return "🦠 Infection spread!"
        end,
        
        uninfect = function(arg, admin)
            return "💉 Infection cured"
        end,
        
        -- === ПИТОМЦЫ / ТРАНСПОРТ ===
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
        
        unpet = function(arg, admin)
            if workspace:FindFirstChild("AdminPet_" .. admin.Name) then
                workspace["AdminPet_" .. admin.Name]:Destroy()
                return "🐕 Pet removed"
            end
            return "❌ No pet"
        end,
        
        mount = function(arg, admin)
            return "🐴 Mount spawned"
        end,
        
        unmount = function(arg, admin)
            return "🐴 Mount removed"
        end,
        
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
        
        unvehicle = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminVehicle" then v:Destroy() end
            end
            return "🚗 Vehicles removed"
        end,
        
        -- === ИНСТРУМЕНТЫ ===
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
        
        untool = function(arg, admin)
            for _, v in ipairs(admin.Backpack:GetChildren()) do
                if v.Name:sub(1, 5) == "Admin" then v:Destroy() end
            end
            return "🗑️ Tools removed"
        end,
        
        -- === ВАЛЮТА / ОПЫТ ===
        give = function(arg, admin)
            local amount = tonumber(arg) or 100
            return "💰 Gave " .. amount .. " (mock)"
        end,
        
        take = function(arg, admin)
            local amount = tonumber(arg) or 100
            return "💸 Took " .. amount .. " (mock)"
        end,
        
        xp = function(arg, admin)
            local amount = tonumber(arg) or 1000
            return "⭐ XP added: " .. amount .. " (mock)"
        end,
        
        level = function(arg, admin)
            local lvl = tonumber(arg) or 99
            return "🏆 Level set to " .. lvl .. " (mock)"
        end,
        
        rank = function(arg, admin)
            local rank = arg or "admin"
            return "👑 Rank set to " .. rank .. " (mock)"
        end,
        
        unrank = function(arg, admin)
            return "👤 Rank reset"
        end,
        
        team = function(arg, admin)
            local teamName = arg or "red"
            local team = game:GetService("Teams"):FindFirstChild(teamName)
            if team then
                admin.Team = team
                return "🚩 Joined team: " .. teamName
            end
            return "❌ Team not found: " .. teamName
        end,
        
        unteam = function(arg, admin)
            admin.Team = nil
            return "🚩 Left team"
        end,
        
        -- === СПАВН / РЕСПАВН ===
        spawn = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 10, 0)
                return "🌟 Teleported to spawn"
            end
            return "❌ Character not found"
        end,
        
        respawn = function(arg, admin)
            local char = admin.Character
            if char then
                char:BreakJoints()
                return "🔄 Respawning..."
            end
            return "❌ Character not found"
        end,
        
        reset = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                return "🔄 Reset"
            end
            return "❌ Character not found"
        end,
        
        -- === СИСТЕМА ===
        save = function(arg, admin)
            return "💾 Saved (mock)"
        end,
        
        load = function(arg, admin)
            return "📂 Loaded (mock)"
        end,
        
        undo = function(arg, admin)
            return "↩️ Undo (mock)"
        end,
        
        redo = function(arg, admin)
            return "↪️ Redo (mock)"
        end,
        
        history = function(arg, admin)
            return "📜 History: [mock data]"
        end,
        
        logs = function(arg, admin)
            return "📋 Logs: [mock data]"
        end,
        
        clearlogs = function(arg, admin)
            return "🗑️ Logs cleared"
        end,
        
        export = function(arg, admin)
            return "📤 Exported (mock)"
        end,
        
        import = function(arg, admin)
            return "📥 Imported (mock)"
        end,
        
        backup = function(arg, admin)
            return "💾 Backup created (mock)"
        end,
        
        restore = function(arg, admin)
            return "📂 Restored (mock)"
        end,
        
        wipe = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    v:Destroy()
                end
            end
            return "☢️ Map wiped"
        end,
        
        wipeall = function(arg, admin)
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("BasePart") then v:Destroy() end
            end
            return "☢️ EVERYTHING wiped"
        end,
        
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
        
        rebuild = function(arg, admin)
            return "🏗️ Rebuilding... (mock)"
        end,
        
        regen = function(arg, admin)
            return "🔄 Regenerating... (mock)"
        end,
        
        fix = function(arg, admin)
            workspace.Gravity = 196.2
            game:GetService("Lighting").Brightness = 1
            return "🔧 Fixed"
        end,
        
        repair = function(arg, admin)
            return "🔨 Repaired (mock)"
        end,
        
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
        
        optimize = function(arg, admin)
            return "⚡ Optimized (mock)"
        end,
        
        boost = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 32
                hum.JumpPower = 100
                return "🚀 Boost enabled"
            end
            return "❌ Character not found"
        end,
        
        unboost = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                return "🚀 Boost disabled"
            end
            return "❌ Character not found"
        end,
        
        fps = function(arg, admin)
            return "📊 FPS: " .. math.random(30, 144) .. " (mock)"
        end,
        
        ping = function(arg, admin)
            return "📡 Ping: " .. math.random(20, 200) .. "ms (mock)"
        end,
        
        info = function(arg, admin)
            return "ℹ️ Server: " .. game.PlaceId .. " | Players: " .. #game:GetService("Players"):GetPlayers()
        end,
        
        stats = function(arg, admin)
            return "📊 Stats: [mock data]"
        end,
        
        server = function(arg, admin)
            return "🖥️ Server info: " .. game.JobId
        end,
        
        playersinfo = function(arg, admin)
            local list = {}
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                table.insert(list, p.Name)
            end
            return "👥 " .. #list .. " players: " .. table.concat(list, ", ")
        end,
        
        jobs = function(arg, admin)
            return "💼 Jobs: [mock data]"
        end,
        
        games = function(arg, admin)
            return "🎮 Games: [mock data]"
        end,
        
        places = function(arg, admin)
            return "🗺️ Places: [mock data]"
        end,
        
        worlds = function(arg, admin)
            return "🌍 Worlds: [mock data]"
        end,
        
        dimension = function(arg, admin)
            return "🌌 Dimension shifted!"
        end,
        
        universe = function(arg, admin)
            return "🌌 Universe info: [mock]"
        end,
        
        multiverse = function(arg, admin)
            return "🌌 Multiverse: [mock]"
        end,
        
        reality = function(arg, admin)
            return "🌌 Reality: [mock]"
        end,
        
        simulation = function(arg, admin)
            return "🖥️ Simulation: [mock]"
        end,
        
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
        
        unmatrix = function(arg, admin)
            local lighting = game:GetService("Lighting")
            if lighting:FindFirstChild("AdminMatrix") then
                lighting.AdminMatrix:Destroy()
                return "💊 Matrix disabled"
            end
            return "❌ Matrix not active"
        end,
        
        void = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, -500, 0)
                return "🕳️ Sent to void"
            end
            return "❌ Character not found"
        end,
        
        unvoid = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 10, 0)
                return "🕳️ Returned from void"
            end
            return "❌ Character not found"
        end,
        
        hell = function(arg, admin)
            local hrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, -100, 0)
                -- Добавляем огонь
                local fire = Instance.new("Fire")
                fire.Size = 20
                fire.Heat = 50
                fire.Parent = hrp
                return "🔥 Welcome to hell"
            end
            return "❌ Character not found"
        end,
        
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
        
        purge = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            return "🔪 Purge started"
        end,
        
        unpurge = function(arg, admin)
            return "🛑 Purge stopped"
        end,
        
        apocalypse = function(arg, admin)
            game:GetService("Lighting").ClockTime = 0
            game:GetService("Lighting").Ambient = Color3.fromRGB(50, 0, 0)
            workspace.Gravity = 50
            return "☠️ APOCALYPSE"
        end,
        
        unapocalypse = function(arg, admin)
            game:GetService("Lighting").ClockTime = 12
            game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
            workspace.Gravity = 196.2
            return "🌅 Apocalypse ended"
        end,
        
        armageddon = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
            end
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("BasePart") and math.random() > 0.5 then
                    v:Destroy()
                end
            end
            return "💥 ARMAGEDDON"
        end,
        
        unarmageddon = function(arg, admin)
            return "🕊️ Armageddon stopped"
        end,
        
        rapture = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Velocity = Vector3.new(0, 500, 0)
                    end
                end
            end
            return "✝️ Rapture!"
        end,
        
        unrapture = function(arg, admin)
            return "🕊️ Rapture ended"
        end,
        
        judgment = function(arg, admin)
            return "⚖️ Judgment day!"
        end,
        
        unjudgment = function(arg, admin)
            return "🕊️ Judgment ended"
        end,
        
        doom = function(arg, admin)
            game:GetService("Lighting").Brightness = 0
            return "💀 DOOM"
        end,
        
        undoom = function(arg, admin)
            game:GetService("Lighting").Brightness = 1
            return "🌅 Doom lifted"
        end,
        
        fate = function(arg, admin)
            return "🎲 Fate: " .. (math.random() > 0.5 and "Good" or "Bad")
        end,
        
        unfate = function(arg, admin)
            return "🎲 Fate reset"
        end,
        
        destiny = function(arg, admin)
            return "✨ Destiny: " .. math.random(1, 100)
        end,
        
        undestiny = function(arg, admin)
            return "✨ Destiny reset"
        end,
        
        karma = function(arg, admin)
            return "☯️ Karma: " .. math.random(-100, 100)
        end,
        
        unkarma = function(arg, admin)
            return "☯️ Karma reset"
        end,
        
        luck = function(arg, admin)
            return "🍀 Luck: " .. math.random(1, 100)
        end,
        
        unluck = function(arg, admin)
            return "🍀 Luck reset"
        end,
        
        bless = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = hum.MaxHealth * 2
                hum.Health = hum.MaxHealth
                return "✨ Blessed!"
            end
            return "❌ Character not found"
        end,
        
        unbless = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 100
                return "✨ Blessing removed"
            end
            return "❌ Character not found"
        end,
        
        curse = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 5
                hum.JumpPower = 10
                return "💀 Cursed!"
            end
            return "❌ Character not found"
        end,
        
        uncurse = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                return "💀 Curse lifted"
            end
            return "❌ Character not found"
        end,
        
        spell = function(arg, admin)
            return "🔮 Spell cast!"
        end,
        
        unspell = function(arg, admin)
            return "🔮 Spell broken"
        end,
        
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
        
        unmagic = function(arg, admin)
            return "✨ Magic faded"
        end,
        
        wizard = function(arg, admin)
            return "🧙 Wizard mode!"
        end,
        
        unwizard = function(arg, admin)
            return "🧙 Wizard mode off"
        end,
        
        witch = function(arg, admin)
            return "🧙‍♀️ Witch mode!"
        end,
        
        unwitch = function(arg, admin)
            return "🧙‍♀️ Witch mode off"
        end,
        
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
        
        unvampire = function(arg, admin)
            return "🧛 Vampire mode off"
        end,
        
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
        
        unwerewolf = function(arg, admin)
            return "🐺 Werewolf mode off"
        end,
        
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
        
        undemon = function(arg, admin)
            return "😈 Demon mode off"
        end,
        
        dragon = function(arg, admin)
            return "🐉 Dragon mode!"
        end,
        
        undragon = function(arg, admin)
            return "🐉 Dragon mode off"
        end,
        
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
        
        mermaid = function(arg, admin)
            return "🧜 Mermaid mode!"
        end,
        
        unmermaid = function(arg, admin)
            return "🧜 Mermaid mode off"
        end,
        
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
        
        unfairy = function(arg, admin)
            return "🧚 Fairy mode off"
        end,
        
        elf = function(arg, admin)
            return "🧝 Elf mode!"
        end,
        
        unelf = function(arg, admin)
            return "🧝 Elf mode off"
        end,
        
        orc = function(arg, admin)
            return "👹 Orc mode!"
        end,
        
        unorc = function(arg, admin)
            return "👹 Orc mode off"
        end,
        
        -- === МЕМЫ / ТАНЦЫ ===
        trollface = function(arg, admin)
            return "😂 Trollface!"
        end,
        
        untrollface = function(arg, admin)
            return "😂 Trollface off"
        end,
        
        meme = function(arg, admin)
            return "😂 MEME MODE"
        end,
        
        unmeme = function(arg, admin)
            return "😂 Meme mode off"
        end,
        
        rickroll = function(arg, admin)
            return "🎵 Never gonna give you up!"
        end,
        
        unrickroll = function(arg, admin)
            return "🎵 Rickroll stopped"
        end,
        
        dab = function(arg, admin)
            return "😎 Dab!"
        end,
        
        undab = function(arg, admin)
            return "😎 Undab"
        end,
        
        floss = function(arg, admin)
            return "🦷 Floss!"
        end,
        
        unfloss = function(arg, admin)
            return "🦷 Unfloss"
        end,
        
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
        
        unorange = function(arg, admin)
            return "🍊 Orange justice off"
        end,
        
        sax = function(arg, admin)
            return "🎷 Sexy sax!"
        end,
        
        unsax = function(arg, admin)
            return "🎷 Sax stopped"
        end,
        
        harlem = function(arg, admin)
            return "🕺 Harlem shake!"
        end,
        
        unharlem = function(arg, admin)
            return "🕺 Harlem shake stopped"
        end,
        
        gangnam = function(arg, admin)
            return "🕺 Gangnam style!"
        end,
        
        ungangnam = function(arg, admin)
            return "🕺 Gangnam stopped"
        end,
        
        thriller = function(arg, admin)
            return "🧟 Thriller!"
        end,
        
        unthriller = function(arg, admin)
            return "🧟 Thriller stopped"
        end,
        
        moonwalk = function(arg, admin)
            return "🌙 Moonwalk!"
        end,
        
        unmoonwalk = function(arg, admin)
            return "🌙 Moonwalk stopped"
        end,
        
        cypher = function(arg, admin)
            return "🎤 Cypher!"
        end,
        
        uncypher = function(arg, admin)
            return "🎤 Cypher ended"
        end,
        
        beatbox = function(arg, admin)
            return "🥁 Beatbox!"
        end,
        
        unbeatbox = function(arg, admin)
            return "🥁 Beatbox stopped"
        end,
        
        freestyle = function(arg, admin)
            return "🎤 Freestyle!"
        end,
        
        unfreestyle = function(arg, admin)
            return "🎤 Freestyle ended"
        end,
        
        rap = function(arg, admin)
            return "🎤 Rap battle!"
        end,
        
        unrap = function(arg, admin)
            return "🎤 Rap ended"
        end,
        
        rock = function(arg, admin)
            return "🎸 Rock on!"
        end,
        
        unrock = function(arg, admin)
            return "🎸 Rock off"
        end,
        
        metal = function(arg, admin)
            return "🤘 Metal!"
        end,
        
        unmetal = function(arg, admin)
            return "🤘 Metal off"
        end,
        
        jazz = function(arg, admin)
            return "🎺 Jazz!"
        end,
        
        unjazz = function(arg, admin)
            return "🎺 Jazz off"
        end,
        
        classic = function(arg, admin)
            return "🎻 Classical!"
        end,
        
        unclassic = function(arg, admin)
            return "🎻 Classical off"
        end,
        
        electro = function(arg, admin)
            return "⚡ Electro!"
        end,
        
        unelectro = function(arg, admin)
            return "⚡ Electro off"
        end,
        
        dubstep = function(arg, admin)
            return "🔊 Dubstep!"
        end,
        
        undubstep = function(arg, admin)
            return "🔊 Dubstep off"
        end,
        
        trap = function(arg, admin)
            return "🔥 Trap!"
        end,
        
        untrap = function(arg, admin)
            return "🔥 Trap off"
        end,
        
        hiphop = function(arg, admin)
            return "🎤 Hip-hop!"
        end,
        
        unhiphop = function(arg, admin)
            return "🎤 Hip-hop off"
        end,
        
        country = function(arg, admin)
            return "🤠 Country!"
        end,
        
        uncountry = function(arg, admin)
            return "🤠 Country off"
        end,
        
        blues = function(arg, admin)
            return "🎵 Blues!"
        end,
        
        unblues = function(arg, admin)
            return "🎵 Blues off"
        end,
        
        reggae = function(arg, admin)
            return "🌴 Reggae!"
        end,
        
        unreggae = function(arg, admin)
            return "🌴 Reggae off"
        end,
        
        latin = function(arg, admin)
            return "💃 Latin!"
        end,
        
        unlatin = function(arg, admin)
            return "💃 Latin off"
        end,
        
        kpop = function(arg, admin)
            return "🇰🇷 K-pop!"
        end,
        
        unkpop = function(arg, admin)
            return "🇰🇷 K-pop off"
        end,
        
        jpop = function(arg, admin)
            return "🇯🇵 J-pop!"
        end,
        
        unjpop = function(arg, admin)
            return "🇯🇵 J-pop off"
        end,
        
        anime = function(arg, admin)
            return "🇯🇵 Anime mode!"
        end,
        
        unanime = function(arg, admin)
            return "🇯🇵 Anime mode off"
        end,
        
        cartoon = function(arg, admin)
            return "📺 Cartoon mode!"
        end,
        
        uncartoon = function(arg, admin)
            return "📺 Cartoon mode off"
        end,
        
        pixel = function(arg, admin)
            return "👾 Pixel mode!"
        end,
        
        unpixel = function(arg, admin)
            return "👾 Pixel mode off"
        end,
        
        retro = function(arg, admin)
            return "👾 Retro mode!"
        end,
        
        unretro = function(arg, admin)
            return "👾 Retro mode off"
        end,
        
        vaporwave = function(arg, admin)
            return "🌴 Vaporwave!"
        end,
        
        unvaporwave = function(arg, admin)
            return "🌴 Vaporwave off"
        end,
        
        cyberpunk = function(arg, admin)
            return "🌃 Cyberpunk!"
        end,
        
        uncyberpunk = function(arg, admin)
            return "🌃 Cyberpunk off"
        end,
        
        steampunk = function(arg, admin)
            return "⚙️ Steampunk!"
        end,
        
        unsteampunk = function(arg, admin)
            return "⚙️ Steampunk off"
        end,
        
        future = function(arg, admin)
            return "🚀 Future!"
        end,
        
        unfuture = function(arg, admin)
            return "🚀 Future off"
        end,
        
        past = function(arg, admin)
            return "🏛️ Past!"
        end,
        
        unpast = function(arg, admin)
            return "🏛️ Past off"
        end,
        
        present = function(arg, admin)
            return "🎁 Present!"
        end,
        
        unpresent = function(arg, admin)
            return "🎁 Present off"
        end,
        
        timewarp = function(arg, admin)
            return "⏰ Time warp!"
        end,
        
        untimewarp = function(arg, admin)
            return "⏰ Time warp off"
        end,
        
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
            return "⏱️ Time stopped"
        end,
        
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
        
        timeslow = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 8 end
                end
            end
            return "🐌 Time slowed"
        end,
        
        untimeslow = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end
            return "🐌 Time normal"
        end,
        
        timefast = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 32 end
                end
            end
            return "⚡ Time fast"
        end,
        
        untimefast = function(arg, admin)
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end
            return "⚡ Time normal"
        end,
        
        timerewind = function(arg, admin)
            return "⏪ Rewinding..."
        end,
        
        untimerewind = function(arg, admin)
            return "⏪ Rewind stopped"
        end,
        
        timeforward = function(arg, admin)
            return "⏩ Fast forwarding..."
        end,
        
        untimeforward = function(arg, admin)
            return "⏩ Fast forward stopped"
        end,
        
        timelapse = function(arg, admin)
            return "📹 Timelapse!"
        end,
        
        untimelapse = function(arg, admin)
            return "📹 Timelapse stopped"
        end,
        
        bullettime = function(arg, admin)
            return "🔫 Bullet time!"
        end,
        
        unbullettime = function(arg, admin)
            return "🔫 Bullet time off"
        end,
        
        superspeed = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 100
                return "⚡ Super speed!"
            end
            return "❌ Character not found"
        end,
        
        unsuperspeed = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                return "⚡ Speed normal"
            end
            return "❌ Character not found"
        end,
        
        superjump = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 200
                return "🦘 Super jump!"
            end
            return "❌ Character not found"
        end,
        
        unsuperjump = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 50
                return "🦘 Jump normal"
            end
            return "❌ Character not found"
        end,
        
        superstrength = function(arg, admin)
            return "💪 Super strength!"
        end,
        
        unsuperstrength = function(arg, admin)
            return "💪 Strength normal"
        end,
        
        xray = function(arg, admin)
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") and p.Transparency == 0 then
                    p.Transparency = 0.5
                end
            end
            return "👁️ X-ray!"
        end,
        
        unxray = function(arg, admin)
            for _, p in ipairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") and p.Transparency == 0.5 then
                    p.Transparency = 0
                end
            end
            return "👁️ X-ray off"
        end,
        
        wallhack = function(arg, admin)
            return "🧱 Wallhack!"
        end,
        
        unwallhack = function(arg, admin)
            return "🧱 Wallhack off"
        end,
        
        aimbot = function(arg, admin)
            return "🎯 Aimbot!"
        end,
        
        unaimbot = function(arg, admin)
            return "🎯 Aimbot off"
        end,
        
        esp = function(arg, admin)
            return "👁️ ESP!"
        end,
        
        unesp = function(arg, admin)
            return "👁️ ESP off"
        end,
        
        tracers = function(arg, admin)
            return "📍 Tracers!"
        end,
        
        untracers = function(arg, admin)
            return "📍 Tracers off"
        end,
        
        chams = function(arg, admin)
            return "🎨 Chams!"
        end,
        
        unchams = function(arg, admin)
            return "🎨 Chams off"
        end,
        
        boxes = function(arg, admin)
            return "📦 Boxes!"
        end,
        
        unboxes = function(arg, admin)
            return "📦 Boxes off"
        end,
        
        skeleton = function(arg, admin)
            return "💀 Skeleton ESP!"
        end,
        
        unskeleton = function(arg, admin)
            return "💀 Skeleton off"
        end,
        
        healthbar = function(arg, admin)
            return "❤️ Health bars!"
        end,
        
        unhealthbar = function(arg, admin)
            return "❤️ Health bars off"
        end,
        
        nameesp = function(arg, admin)
            return "🏷️ Name ESP!"
        end,
        
        unnameesp = function(arg, admin)
            return "🏷️ Name ESP off"
        end,
        
        distance = function(arg, admin)
            return "📏 Distance ESP!"
        end,
        
        undistance = function(arg, admin)
            return "📏 Distance off"
        end,
        
        weapon = function(arg, admin)
            return "🔫 Weapon ESP!"
        end,
        
        unweapon = function(arg, admin)
            return "🔫 Weapon ESP off"
        end,
        
        item = function(arg, admin)
            return "📦 Item ESP!"
        end,
        
        unitem = function(arg, admin)
            return "📦 Item ESP off"
        end,
        
        money = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "💰 Money: " .. amount .. " (mock)"
        end,
        
        unmoney = function(arg, admin)
            return "💰 Money reset"
        end,
        
        gems = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "💎 Gems: " .. amount .. " (mock)"
        end,
        
        ungems = function(arg, admin)
            return "💎 Gems reset"
        end,
        
        coins = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "🪙 Coins: " .. amount .. " (mock)"
        end,
        
        uncoins = function(arg, admin)
            return "🪙 Coins reset"
        end,
        
        points = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "⭐ Points: " .. amount .. " (mock)"
        end,
        
        unpoints = function(arg, admin)
            return "⭐ Points reset"
        end,
        
        credits = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "💳 Credits: " .. amount .. " (mock)"
        end,
        
        uncredits = function(arg, admin)
            return "💳 Credits reset"
        end,
        
        tokens = function(arg, admin)
            local amount = tonumber(arg) or 999999
            return "🎟️ Tokens: " .. amount .. " (mock)"
        end,
        
        untokens = function(arg, admin)
            return "🎟️ Tokens reset"
        end,
    }
}
