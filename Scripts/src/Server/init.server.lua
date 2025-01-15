local InventoryServer = require(script:WaitForChild("InventoryServer"))
local battleInitalizer = require(script.BattleScripts:WaitForChild("battleInitalizer"))


local RS = game:GetService("ReplicatedStorage")
local UpdateInventory = RS.InventoryEvents:WaitForChild("UpdateInventory")
local battleTrigger = RS:WaitForChild("battleTrigger")


InventoryServer.Start()

UpdateInventory.OnServerInvoke = function(player)
	
	local data = InventoryServer.SendInv(player)
	print("this is other script")
	print(data)
	return data
end



