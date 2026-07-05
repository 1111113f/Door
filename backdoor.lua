-- ServerCommands.lua v3.0
-- Чистая структура, нормальные команды, без мусора

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local ServerCommands = {}
ServerCommands.__index = ServerCommands

function ServerCommands.new()
    local self = setmetatable({}, ServerCommands)
    self.activeFly = {} -- Трекинг активных полётов
    self.spawnedObjects = {} -- Трекинг заспавненных объектов
    return self
end

-- Утилиты
function ServerCommands:getPlayer(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == name:lower() or p.DisplayName:lower() == name:lower() then
            return p
        end
    end
    return nil
end

function ServerCommands:getCharacter(player)
    return player and player.Character
end

function ServerCommands:getHumanoid(player)
    local char = self:getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

function ServerCommands:getHRP(player)
    local char = self:getCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ========== КОМАНДЫ ==========

-- Убить игрока (target или all)
function ServerCommands:kill(targetName, admin)
    if targetName == "all" then
        for _, p in ipairs(Players:GetPlayers()) do
            local hum = self:getHumanoid(p)
            if hum then hum.Health = 0 end
        end
        return "💀 All players killed"
    else
        local target = self:getPlayer(targetName)
        if not target then return "❌ Player not found: " .. targetName end
        local hum = self:getHumanoid(target)
        if hum then hum.Health = 0 end
        return "💀 Killed " .. target.Name
    end
end

-- Телепорт к игроку
function ServerCommands:tpto(targetName, admin)
    if not targetName or targetName == "" then
        return "❌ Usage: tpto [username]"
    end
    
    local target = self:getPlayer(targetName)
    if not target then return "❌ Player not found: " .. targetName end
    
    local targetHrp = self:getHRP(target)
    local adminHrp = self:getHRP(admin)
    
    if not targetHrp or not adminHrp then
        return "❌ Character not loaded"
    end
    
    adminHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 3, 5)
    return "📍 Teleported to " .. target.Name
end

-- Телепорт игрока к админу
function ServerCommands:bring(targetName, admin)
    if not targetName or targetName == "" then
        return "❌ Usage: bring [username]"
    end
    
    local target = self:getPlayer(targetName)
    if not target then return "❌ Player not found: " .. targetName end
    
    local targetHrp = self:getHRP(target)
    local adminHrp = self:getHRP(admin)
    
    if not targetHrp or not adminHrp then
        return "❌ Character not loaded"
    end
    
    targetHrp.CFrame = adminHrp.CFrame * CFrame.new(0, 0, 5)
    return "📍 Brought " .. target.Name .. " to you"
end

-- Взрыв в позиции админа
function ServerCommands:explode(radiusStr, admin)
    local radius = tonumber(radiusStr) or 30
    local hrp = self:getHRP(admin)
    if not hrp then return "❌ Character not found" end
    
    local explosion = Instance.new("Explosion")
    explosion.Position = hrp.Position
    explosion.BlastRadius = math.clamp(radius, 10, 100)
    explosion.BlastPressure = 500000
    explosion.DestroyJointRadiusPercent = 0 -- Не ломает joints полностью
    explosion.Parent = workspace
    
    -- Не убиваем админа
    explosion.Hit:Connect(function(hit)
        local hum = hit:FindFirstAncestorOfClass("Humanoid")
        if hum and hum.Parent ~= admin.Character then
            hum:TakeDamage(100)
        end
    end)
    
    return "💥 Explosion! Radius: " .. radius
end

-- Спавн блоков вокруг цели
function ServerCommands:blocks(targetName, admin)
    local target = targetName == "all" and nil or self:getPlayer(targetName)
    local targets = {}
    
    if targetName == "all" then
        targets = Players:GetPlayers()
    elseif target then
        table.insert(targets, target)
    else
        return "❌ Player not found: " .. targetName
    end
    
    local count = 0
    for _, p in ipairs(targets) do
        local hrp = self:getHRP(p)
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
end

-- Очистка блоков
function ServerCommands:clear(_, admin)
    local count = 0
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name == "AdminBlock" or v.Name == "AdminEffect" then
            v:Destroy()
            count = count + 1
        end
    end
    return "🧹 Cleared " .. count .. " objects"
end

-- Полёт (НОРМАЛЬНЫЙ — через BodyGyro + BodyVelocity + Heartbeat)
function ServerCommands:fly(speedStr, admin)
    local char = admin.Character
    if not char then return "❌ Character not found" end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return "❌ Missing parts" end
    
    -- Если уже летает — выключить
    if self.activeFly[admin.UserId] then
        self.activeFly[admin.UserId] = nil
        for _, v in ipairs(hrp:GetChildren()) do
            if v.Name == "AdminFlyGyro" or v.Name == "AdminFlyVelocity" then
                v:Destroy()
            end
        end
        hum.PlatformStand = false
        hum.AutoRotate = true
        return "🚫 Fly disabled"
    end
    
    -- Включить полёт
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
    
    self.activeFly[admin.UserId] = true
    
    -- Коннект для управления (сервер не может ловить input, 
    -- но мы можем обновлять CFrame по Heartbeat если нужно)
    -- Для полноценного управления клиент должен слать направление
    
    return "✈️ Fly enabled (Speed: " .. (tonumber(speedStr) or 50) .. ")"
end

-- Обновление полёта (вызывать из клиента)
function ServerCommands:flyUpdate(direction, admin)
    if not self.activeFly[admin.UserId] then return end
    local char = admin.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local bv = hrp and hrp:FindFirstChild("AdminFlyVelocity")
    local bg = hrp and hrp:FindFirstChild("AdminFlyGyro")
    
    if not hrp or not bv or not bg then return end
    
    local speed = 50
    local camCF = CFrame.lookAt(hrp.Position, hrp.Position + hrp.CFrame.LookVector)
    
    -- direction: {x, y, z} от клиента
    local dir = typeof(direction) == "table" and Vector3.new(direction[1], direction[2], direction[3]) or Vector3.new(0, 0, 0)
    
    bv.Velocity = camCF:VectorToWorldSpace(dir * speed)
    bg.CFrame = camCF
end

-- Список игроков
function ServerCommands:players(_, admin)
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local status = p == admin and " (YOU)" or ""
        table.insert(list, p.Name .. status)
    end
    return "👥 Players (" .. #list .. "): " .. table.concat(list, ", ")
end

-- Кик игрока
function ServerCommands:kick(targetName, admin)
    if not targetName or targetName == "" then
        return "❌ Usage: kick [username]"
    end
    
    local target = self:getPlayer(targetName)
    if not target then return "❌ Player not found: " .. targetName end
    if target == admin then return "❌ Cannot kick yourself" end
    
    target:Kick("Kicked by admin")
    return "👢 Kicked " .. target.Name
end

-- Сообщение всем
function ServerCommands:announce(msg, admin)
    if not msg or msg == "" then return "❌ Usage: announce [message]" end
    
    for _, p in ipairs(Players:GetPlayers()) do
        -- Можно использовать TextChatService или старый чат
        local success = pcall(function()
            game:GetService("TextChatService"):DisplayBubble(p.Character.Head, "[ADMIN] " .. msg)
        end)
        if not success then
            -- Fallback для старого чата
            game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer("[ADMIN] " .. msg, "All")
        end
    end
    
    return "📢 Announced: " .. msg
end

-- Время дня
function ServerCommands:time(timeStr, admin)
    local timeVal = tonumber(timeStr) or 12
    game:GetService("Lighting").ClockTime = math.clamp(timeVal, 0, 24)
    return "🌅 Time set to " .. timeVal
end

-- Гравитация
function ServerCommands:gravity(gStr, admin)
    local g = tonumber(gStr) or 196.2
    workspace.Gravity = g
    return "🌍 Gravity set to " .. g
end

-- ========== ОБРАБОТЧИК ==========

function ServerCommands:execute(cmd, arg, admin)
    local handler = self[cmd]
    if not handler then
        return "❌ Unknown command: " .. cmd
    end
    
    local success, result = pcall(function()
        return handler(self, arg, admin)
    end)
    
    if success then
        return result
    else
        warn("Command error: " .. tostring(result))
        return "❌ Error executing " .. cmd .. ": " .. tostring(result)
    end
end

return ServerCommands
