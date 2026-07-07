-- Тестовый скрипт для проверки LocalScript инжекции
print("[TEST] Script started!")

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

print("[TEST] Player: " .. plr.Name)

-- Создаём простое GUI для проверки
local gui = Instance.new("ScreenGui")
gui.Name = "TestGUI"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
frame.BorderSizePixel = 2
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "✅ LOCAL SCRIPT WORKS!\nPlayer: " .. plr.Name
label.TextColor3 = Color3.fromRGB(0, 0, 0)
label.Font = Enum.Font.Code
label.TextSize = 20
label.Parent = frame

print("[TEST] GUI created successfully!")

-- Проверяем эксплойт-эмуляцию
if getgenv then
    print("[TEST] getgenv available: " .. tostring(getgenv() ~= nil))
end

if writefile then
    print("[TEST] writefile available")
    writefile("test.txt", "Hello from test!")
    print("[TEST] readfile: " .. readfile("test.txt"))
end

print("[TEST] All checks passed!")
return "Test completed"
