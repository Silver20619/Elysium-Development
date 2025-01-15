local RS = game:GetService("ReplicatedStorage")
local battleTrigger = RS:WaitForChild("battleTrigger")
local battlespot1 = CFrame.new(-376.18, 2, 209.82) 
local battlespot2 = CFrame.new(-377.43, 2, 195.47)
local battleSuccess = RS:WaitForChild("battleSuccess")


battleTrigger.OnServerEvent:Connect(function(player,enemy)
	
	local char = player.Character
	local root = char:WaitForChild("HumanoidRootPart")
	local enemyRoot = enemy:WaitForChild("HumanoidRootPart")
	char.Humanoid.WalkSpeed = 0
	enemy.Humanoid.WalkSpeed = 0
	root.CFrame = battlespot1
	enemyRoot.CFrame = battlespot2
	battleSuccess:FireClient(player,enemy.Name)
	
end)


