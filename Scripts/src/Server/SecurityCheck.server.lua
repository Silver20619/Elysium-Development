local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Delete = ReplicatedStorage.InventoryEvents:WaitForChild("DeleteRequest")

local InventoryServer = require(script.Parent:WaitForChild("InventoryServer"))


Delete.OnServerInvoke = function(player, spot, stackID, quantity)
	quantity = quantity or 0

	InventoryServer.DeleteItem(player, spot, stackID, quantity)

	local updatedInventory = InventoryServer.SendInv(player)
	print(updatedInventory)
	
	return updatedInventory
end

