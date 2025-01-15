local LootRandomizer = {}
---- Services
local SS = game:GetService("ServerStorage")

---- Module Scripts
local LootPool = require(SS.ItemData.BaseDungeon:WaitForChild("LootPool")) 
local InventoryServer = require(script.Parent:WaitForChild("InventoryServer"))

local function chooseItem ()
	local randomNum = math.random(1,10)
	
	local counter = 0

	for rarity, item in pairs(LootPool) do
		local weight = item.weight
		counter += weight
		if randomNum <= counter then
			return {name = item.name,
					description = item.description,
					quantity = math.random(1,3),
					id = item.id}
		end
	end
end

function mergeLoot (lootTable,loot)
	if next(lootTable) == nil then return false end
	
	for _,item in pairs(lootTable) do
		if item.id == loot.id then
			item.quantity = item.quantity + loot.quantity
			print("We are merging: " .. item.name .. " quantity is now: " .. item.quantity)
			return item
		end
	end
	
	return false
end

function LootRandomizer.randomizer ()
	local num = math.random(1,3)
	print("We got ".. num .. " items")
	local itemTable = {}
	
	for i =1 , num do
		local item = chooseItem()
		if mergeLoot(itemTable,item) == false then
			table.insert(itemTable,item)
		end
	--table.insert(itemTable,item)
	end
	
	return(itemTable)
end
return LootRandomizer