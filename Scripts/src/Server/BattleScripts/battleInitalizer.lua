local battleInitalizer = {}

---Services
local RS = game:GetService("ReplicatedStorage")

-----Modules Script
local InventoryServer = require(script.Parent.Parent:WaitForChild("InventoryServer"))

--- Variables
local battleTrigger = RS:WaitForChild("battleTrigger")
local battleSuccess = RS:WaitForChild("battleSuccess")
local battlespot1 = CFrame.new(-376.18, 2, 209.82) 
local battlespot2 = CFrame.new(-377.43, 2, 195.47)

----- Remote Function
battleTrigger.OnServerEvent:Connect(function(player,enemy)

	local char = player.Character
	local root = char:WaitForChild("HumanoidRootPart")
	local enemyRoot = enemy:WaitForChild("HumanoidRootPart")
	char.Humanoid.WalkSpeed = 0
	enemy.Humanoid.WalkSpeed = 0
	root.CFrame = battlespot1
	enemyRoot.CFrame = battlespot2
	battleSuccess:FireClient(player, enemy.Name, InventoryServer.SendInv(player))

end)

return battleInitalizer
