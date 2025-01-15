local enemyAi = require(script.Parent:WaitForChild("EnemyAi"))
local RS = game:GetService("ReplicatedStorage")
local battleTrigger = RS:WaitForChild("battleTrigger")
local playersTurn = RS.BattleEvent:WaitForChild("playersTurn")
local moveSelect = RS.BattleEvent:WaitForChild("moveSelect")

local function speedCheck()
	
end

battleTrigger.OnServerEvent:Connect(function(player,mob)
	local turnOrder = {player,mob}
	local trackOrderIndex = 1
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	
	local function nextTurn()
		local currentplayer = turnOrder[trackOrderIndex]
		
		if currentplayer == player then
			print("it the players turn")
			playersTurn:FireClient(player,mob)
			
		else
			enemyAi.ez(humanoid)
			trackOrderIndex = (trackOrderIndex % # turnOrder) + 1
			nextTurn()
		end
	end	
		nextTurn()
	
	moveSelect.OnServerEvent:Connect(function(player,button)
		print(button)
		trackOrderIndex = (trackOrderIndex % # turnOrder) + 1
		nextTurn()
	end)
end)
