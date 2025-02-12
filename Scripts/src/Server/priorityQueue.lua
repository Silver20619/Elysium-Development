local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue.new()
	return setmetatable({Heap = {}}, PriorityQueue)
end

local function Swap(heap, i, j)
	heap[i], heap[j] = heap[j], heap[i]
end

local function Comparator(child,parent) 
	--- If the child is smaller than the parent then swap
	return child.distance < parent.distance
	
end


function PriorityQueue:Enqueue(element)
	table.insert(self.Heap, element)

	local index = #self.Heap
	while index > 1 do
		local parent = math.floor(index / 2)
		print(self.Heap[index])
		print (self.Heap[parent])
		
		if Comparator(self.Heap[index] , self.Heap[parent]) then
			print("index is smaller ")
			Swap(self.Heap, parent, index)
			index = parent
		else
			break
		end
	end
end

function PriorityQueue:Dequeue()
	if #self.Heap == 0 then return nil end

	local root = self.Heap[1]
	self.Heap[1] = self.Heap[#self.Heap]
	table.remove(self.Heap)

	local index = 1
	while true do
		local left = index * 2
		local right = index * 2 + 1
		local smallest = index

		if left <= #self.Heap and Comparator(self.Heap[left], self.Heap[smallest]) then
			smallest = left
		end
		if right <= #self.Heap and Comparator(self.Heap[right], self.Heap[smallest]) then
			smallest = right
		end
		if smallest == index then break end

		Swap(self.Heap, index, smallest)
		index = smallest
	end

	return root
end

function PriorityQueue:Peek()
	return self.Heap[1]
end

function PriorityQueue:IsEmpty()
	return #self.Heap == 0
end

return PriorityQueue
