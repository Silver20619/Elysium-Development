
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local sendInfo = game:GetService("ServerStorage"):WaitForChild("SendInfo")
local ProximityPromptActivated = ReplicatedStorage.ProximityPromptEvents:WaitForChild("ProximityPromptActivated")

local InventoryServer = require(script.Parent.Parent:WaitForChild("InventoryServer"))


ProximityPromptActivated.OnServerEvent:Connect(function(player, itemID)
	print(player.Name .. " activated a ProximityPrompt for item ID: " .. itemID)
	--sendInfo:Fire(player,itemID)
	InventoryServer.UpdateInv(player,itemID)
	
end)
