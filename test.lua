print("Hello from loadstring!")
local Players = game:GetService("Players")
for _, p in ipairs(Players:GetPlayers()) do
    print("Player: " .. p.Name)
end
return "Test OK"
