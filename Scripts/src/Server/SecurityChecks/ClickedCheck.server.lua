local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")


local Clicked = RS.WorldEvents:WaitForChild("Clicked")

local InventoryServer = require(script.Parent.Parent:WaitForChild("InventoryServer"))
local Randomizer = require(script.Parent.Parent:WaitForChild("LootRandomizer"))
--local Randomizer = nil
local function valid(part,tag)
	if not part:IsDescendantOf(workspace) then
		warn("Invaild Part: " .. part)
		return false
	end
	
	local tags = CS:GetTags(part)
	for i,existingTag in ipairs(tags) do
		if existingTag == tag then
			return true
		end
	end
	warn("Invaild Tag" .. tag)
	return false
end

Clicked.OnServerInvoke = function (player,part)
	local loot = Randomizer.randomizer()
	
	for _, item in pairs(loot) do
		InventoryServer.UpdateInv(player,item.id,item.quantity)
	end
	
	return loot
	
end

