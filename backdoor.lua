return {
    version = "5.4",
    commands = {
        -- Утилита: поиск игрока по имени
        findPlayer = function(name)
            local Players = game:GetService("Players")
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower() == name:lower() then return p end
            end
            return nil
        end,
        
        -- === БАЗОВЫЕ ===
        killall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin then
                    local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0; count = count + 1 end
                end
            end
            return "💀 Killed " .. count .. " players (admin protected)"
        end,
        
        kill = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: kill [username/all]" end
            if arg:lower() == "all" then return commands.killall(arg, admin) end
            
            local target = commands.findPlayer(arg)
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot kill yourself" end
            
            local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
            return "💀 Killed " .. target.Name
        end,
        
        tpto = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: tpto [username]" end
            local target = commands.findPlayer(arg)
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
            
            local adminHrp = admin.Character and admin.Character:FindFirstChild("HumanoidRootPart")
            if not adminHrp then return "❌ Your character not loaded" end
            
            if arg:lower() == "all" then
                local count = 0
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
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
            
            local target = commands.findPlayer(arg)
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot bring yourself" end
            
            local targetHrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp and adminHrp then
                targetHrp.CFrame = adminHrp.CFrame * CFrame.new(0, 0, 5)
                return "📍 Brought " .. target.Name .. " to you"
            end
            return "❌ HumanoidRootPart missing"
        end,
        
        kick = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: kick [username/all]" end
            
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
            
            local target = commands.findPlayer(arg)
            if not target then return "❌ Player not found: " .. arg end
            if target == admin then return "🛡️ Cannot kick yourself" end
            
            target:Kick("Kicked by admin")
            return "👢 Kicked " .. target.Name
        end,
        
        blocks = function(arg, admin)
            local Debris = game:GetService("Debris")
            local targets = {}
            
            if arg == "all" then
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                    if p ~= admin then table.insert(targets, p) end
                end
            else
                local target = commands.findPlayer(arg or "")
                if target and target ~= admin then table.insert(targets, target) end
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
        
        clear = function(arg, admin)
            local count = 0
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Name == "AdminBlock" or v.Name == "AdminEffect" or v.Name == "AdminParticle" or v.Name == "AdminSound" or v.Name == "AdminRain" or v.Name == "AdminSnow" then
                    v:Destroy()
                    count = count + 1
                end
            end
            return "🧹 Cleared " .. count .. " objects"
        end,
        
        players = function(arg, admin)
            local list = {}
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                local marker = (p == admin) and " [YOU/ADMIN]" or ""
                table.insert(list, p.Name .. marker)
            end
            return "👥 Players (" .. #list .. "): " .. table.concat(list, ", ")
        end,
        
        -- === ВРЕДНЫЕ (с защитой админа) ===
        freeze = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = hum.WalkSpeed == 0 and 16 or 0
                hum.JumpPower = hum.JumpPower == 0 and 50 or 0
                return hum.WalkSpeed == 0 and "🧊 Frozen" or "🧊 Unfrozen"
            end
            return "❌ Character not found"
        end,
        
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
        
        burn = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(50)
                return "🔥 Burned for 50 damage"
            end
            return "❌ Character not found"
        end,
        
        burnall = function(arg, admin)
            local count = 0
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:TakeDamage(50); count = count + 1 end
                end
            end
            return "🔥 Burned " .. count .. " players for 50 damage (admin protected)"
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
        
        jail = function(arg, admin)
            if arg == "all" then
                local count = 0
                for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
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
            
            if not arg or arg == "" then arg = admin.Name end
            local target = commands.findPlayer(arg)
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
        
        unjail = function(arg, admin)
            if not arg or arg == "" then
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
        
        -- === САМО НА СЕБЯ ===
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
        
        -- === ОБЩИЕ ===
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
        
        speed = function(arg, admin)
            local val = tonumber(arg) or 16
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val; return "⚡ Speed set to " .. val end
            return "❌ Character not found"
        end,
        
        jump = function(arg, admin)
            local val = tonumber(arg) or 50
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val; return "🦘 Jump set to " .. val end
            return "❌ Character not found"
        end,
        
        heal = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = hum.MaxHealth; return "❤️ Healed" end
            return "❌ Character not found"
        end,
        
        godmode = function(arg, admin)
            local hum = admin.Character and admin.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return "❌ Character not found" end
            if hum.MaxHealth == math.huge then
                hum.MaxHealth = 100; hum.Health = 100
                return "🛡️ Godmode disabled"
            else
                hum.MaxHealth = math.huge; hum.Health = math.huge
                return "🛡️ Godmode enabled"
            end
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
                if hum and hum.Parent ~= admin.Character then
                    hum:TakeDamage(100)
                end
            end)
            return "💥 Explosion! Radius: " .. radius .. " (admin protected)"
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
            
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                if p ~= admin and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            return "☢️ NUKE DETONATED (admin protected)"
        end,
        
        announce = function(arg, admin)
            if not arg or arg == "" then return "❌ Usage: announce [message]" end
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                p:SendNotification("ADMIN", arg, 5)
            end
            return "📢 Announced: " .. arg
        end,
    }
}
