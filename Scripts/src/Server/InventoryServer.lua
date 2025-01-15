local InventoryServer = {}


----- Services
local Player = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")


-----Modules
local itemInfo = require(SS.ItemData:WaitForChild("ItemInfo"))

----- Remote Events
local updateInventory = RS.InventoryEvents:WaitForChild("UpdateInventory")
local sendInfo = SS:WaitForChild("SendInfo")

------ Inventory Settings 
local invServer = {}
invServer.AllInventory={}
invServer.MaxStacksData = {
	Armor = 1,
	Weapon = 1,
	Consumable = 10,
	Cards = 1,
	Moves = 5
}

invServer.MaxStack = 11 -- -1
local updatedInv = nil

------- Functions List
function InventoryServer.CharacterAdded (char)
	print(char ," just spawned.")
end

function InventoryServer.PlayerAdded(player)
	print(player.Name .. " joined")
	
	if player.Character then
		task.spawn(InventoryServer.CharacterAdded,player.Character)
	end
	player.CharacterAdded:Connect(InventoryServer.CharacterAdded)
	
	invServer.AllInventory[player] = {
		Inventory = {},
		Weapon = {},
		Moves = {"0x2000", "0x2001", "0x2002", "0x2003"},
		Currency = 0,
		LastStackID = 0
	}
	InventoryServer.MakeStack(player,"0x1001")
end

function InventoryServer.Start()
	for i , player in pairs(Player:GetPlayers()) do 
		task.spawn(InventoryServer.PlayerAdded,player)
	end
	Player.PlayerAdded:Connect(InventoryServer.PlayerAdded)
end

function InventoryServer.FindStack(player, id, stackable)
	for i,stack in pairs(invServer.AllInventory[player].Inventory) do
		if stack.id == id and stack.quantity <  stackable then
			return stack
		end
		
	end
 	return nil  --- Returns nil if we can't find a stack to put the item in
end

function checkOverFlow(stack,num)
	if num == nil then return false end
	
	
	local maxSpace = stack.stackable - stack.quantity -- Space left in the stack

	if num > maxSpace then
		local overflow = num - maxSpace
		
		warn("We had an overflow :" .. overflow .. " items overflowed" )
		return overflow
	end
	 return false
	
	
end

function InventoryServer.MakeStack(player,id,num)
	num = num or 1
	local itemData = itemInfo.getItemById(id)
	
	local playerInventory = invServer.AllInventory[player].Inventory
	
	
	
	local stack = {
		id = id,
		quantity = num,
		stackable = itemData.stackable,
		StackID = invServer.AllInventory[player].LastStackID
	}
	
	invServer.AllInventory[player].LastStackID = invServer.AllInventory[player].LastStackID + 1
	table.insert(playerInventory,stack)
end

function InventoryServer.UpdateInv(player,id,num)
	num = num or 1
	
	if type(id) ~= "string" or string.sub(id , 1, 2) ~= "0x" then return end
	
	local itemData = itemInfo.getItemById(id)
	
	local playerInventory = invServer.AllInventory[player]
	
	local foundStack = InventoryServer.FindStack(player,id,itemData.stackable)
	
	--local overflow = checkOverFlow(foundStack, num)
	
	if foundStack then
		local overflow = checkOverFlow(foundStack, num) ---- This returns the amount of overflow that it is going to have if all of num was added to the stack
		
		if foundStack.quantity < foundStack.stackable and overflow == false then   ---- This checks to see if num can be safely added to the stack and without overflowing
			foundStack.quantity = foundStack.quantity + num 
			print("We did this because there is not over flow")
			
		elseif overflow and playerInventory.LastStackID + 1 < invServer.MaxStack then   -- This checks and sees if we do have an over flow and we are able to add in a new stack to fit the overflow 
			print("We did this because we have overflow and space")
			local canAdd = math.min(num, itemData.stackable - foundStack.quantity)   -- This checks and sees if we can add all of the numbers to the stack
			foundStack.quantity += canAdd --- This adds the amount that can be safely added 
			overflow -= canAdd --- It then subtracts the amount from the overflow 

			while overflow > 0 do
				if playerInventory.LastStackID + 1 < invServer.MaxStack then
					local stackSize = math.min(overflow, itemData.stackable)
					InventoryServer.MakeStack(player, id, stackSize)
					overflow -= stackSize
				else
					print("Inventory Full. You lost: " .. overflow .. " " .. itemData.name)
					break
				end
			end
		
		elseif overflow and playerInventory.LastStackID + 1 >= invServer.MaxStack then
			foundStack.quantity = foundStack.quantity + (num - overflow)
			print("We did this because there is overflow and there is no space")
			
		--[[elseif foundStack.quantity >= foundStack.stackable  and playerInventory.LastStackID < InventoryServer.MaxStack then
			InventoryServer.MakeStack(player,id)--]]	
		else
			print("Inventory is full ")
		end	
		
		
	--------- This is used when it is creating a new stack
	elseif #playerInventory.Inventory + 1 < invServer.MaxStack then
		if num > itemData.stackable then
			while num > 0 do
				if playerInventory.LastStackID + 1 < invServer.MaxStack then
					print("We did this because there was there was space and num was greater than stackable: " .. num .. "is left over")
					InventoryServer.MakeStack(player,id,itemData.stackable)
					num -= itemData.stackable
				else
					warn("No more room you lost: " .. num .. " " .. itemData.name )
					break
				end
			end
		
		else
			print("We did this because there was space to make a new stack and there is no overflow")
			InventoryServer.MakeStack(player,id,num)
		end
		
	else 
		print("Inventory is full")
	end
	print(invServer.AllInventory[player].Inventory)
end
	
function InventoryServer.DeleteItem(player,spot,stackID,quantity)
	local found = nil
	local newInv = invServer.AllInventory[player]
	for i,stack in pairs(invServer.AllInventory[player][spot]) do
		if stack.StackID == stackID then
			if quantity > 0 then

				stack.quantity = stack.quantity - quantity
				if stack.quantity <= 0 then
					table.remove(invServer.AllInventory[player][spot], i)
				end
				newInv = invServer.AllInventory[player]
			else
				table.remove(invServer.AllInventory[player][spot], i)

			end
			break
		end
	end
end


--[[sendInfo.Event:Connect(function(player,itemID)
	print(player)
	InventoryServer.UpdateInv(player,itemID)
end)--]]


function InventoryServer.SendInv(player)
	return invServer.AllInventory[player]
		 
end

function InventoryServer.GetPackage(player)
	
end


--[[function InventoryServer.AddMoves(player)
	
	for i,moves in pairs(InventoryServer.AllInventory[player].Moves) do
		local itemData = itemInfo.getItemById(moves)
		if itemData then
			InventoryServer.AllInventory[player].Moves[i] = itemData.name
		end
	end
	print (InventoryServer.AllInventory[player].Moves)
	
end--]]

return InventoryServer
