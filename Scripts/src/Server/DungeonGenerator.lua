
local boundingBox = game.Workspace:WaitForChild("plat")
local baseplate = game.Workspace:WaitForChild("Baseplate")
local PQ = require(script:WaitForChild("PQ"))

local PathFinding = require(script:WaitForChild("Pathfinding2"))
local size = boundingBox.Size
local cframe = boundingBox.CFrame
local dungeonRoom = game.Workspace:WaitForChild("DungeonRoom")

-- Calculate XZ bounds
local minX = cframe.Position.X - size.X / 2
local maxX = cframe.Position.X + size.X / 2
local minZ = cframe.Position.Z - size.Z / 2
local maxZ = cframe.Position.Z + size.Z / 2

local existingLines = {}

local function getRandomPositionXZ()
	local remainderX = math.abs(16 - minX % 16) 
	local remainderZ = math.abs(16 - minZ % 16)
	
	local randomX = (remainderX + minX) + (16 * math.random(1,19))
	local randomZ = (remainderZ + minZ) + (16 * math.random(1,19))

	return Vector3.new(randomX, boundingBox.Position.Y +16, randomZ)
end

local function createGraph(list)
	local graph = {}
	
	for i, part in pairs(list) do 
		graph [part.Name] = {}
		
	end
	return graph
end


local function addWeightedEdge (graph, from, to, num)
	local lineKey = from.. "-"..to
	
	if existingLines[lineKey] then
		return
	end
	table.insert(graph[from] , {startnode = from, endnode = to, distance = num})
	
	existingLines[lineKey] = true
end

local function generateRandomBlocks(numBlocks)
	local blocks = {}
	local block 
	
	local DungeonRoom = game.Workspace:WaitForChild("DungeonRoom")
	for i = 1, numBlocks do
		repeat
			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Include
			overlapParams.FilterDescendantsInstances = blocks
			
			block = DungeonRoom:Clone()
			block.Name = "Room" .. tostring(i)
			block:SetPrimaryPartCFrame(CFrame.new(getRandomPositionXZ()))
			block.Parent = game.Workspace

			local partsInBox = game.Workspace:GetPartBoundsInBox(block.PrimaryPart.CFrame,block.HitBox.Size * 2 ,overlapParams)
			
			if #partsInBox == 0 then
				local doorName = "doorNode" .. tostring(math.random(1,4))
				local doorNode = block:FindFirstChild(doorName)
				doorNode.Name = "chosenDoor".. tostring(i)
				table.insert(blocks, block)
			else
				
				block:Destroy()
			end
			
			
		until #partsInBox == 0	
	end

	return blocks
end

 
local function createLinesBetweenPoints(validEdges,points)
	
	local graph = createGraph(points)
	print(validEdges)
	for p, tri in pairs(validEdges) do
		for i = 1, #tri do
			for k = i +1 , #tri do

				local pointA = tri[i]
				local pointB = tri[k]
				local distance = (pointA.Position - pointB.Position).Magnitude
				
				--[[local line = Instance.new("Part")
				line.Name = "Line" .. pointA.Name .. "-" .. pointB.Name
				line.Size = Vector3.new(0.2, 0.2, distance) -- Length of the line
				line.Position = (pointA.Position + pointB.Position) / 2 -- Midpoint between the points
				line.Anchored = true
				line.Parent = workspace -- Parent the line to the workspace--]]
				

				-- Set the orientation using CFrame
				local direction = (pointB.Position - pointA.Position).Unit -- Direction from pointA to pointB
				--line.CFrame = CFrame.new(line.Position, line.Position + direction) -- Align the part
				
				addWeightedEdge(graph, pointA.Name, pointB.Name, distance )
				addWeightedEdge(graph,pointB.Name, pointA.Name, distance)
			end
		end	
	end
	
	return graph
end 

local function superTriangle()
	
	local doubleSizeX = size.X * 3
	local doubleSizeZ = size.Z 

	-- Calculate the doubled minimum and maximum bounds
	local doubleminX = cframe.Position.X - doubleSizeX / 2
	local doubleminZ = cframe.Position.Z - doubleSizeZ / 2
	local doublemaxX = cframe.Position.X + doubleSizeX / 2
	

	-- Define the points
	local a = Vector3.new(doubleminX, cframe.Y, doubleminZ) -- Bottom-left corner
	local b = Vector3.new(doublemaxX, cframe.Y, doubleminZ) -- Bottom-right corner
	local c = Vector3.new(cframe.Position.X, cframe.Y, maxZ * 2 ) -- Top-center
	local triangle = {a,b,c}
	
	local partTri = {} 
	
	----- TODO THIS FOR LOOP IS FOR DEBUGGING. IT SHOWS WHERE THE SUPER TRIANGLE IS BEING GENERATED DO NOT DELETE
	
	for i, pos in pairs(triangle) do           
		local corner = Instance.new("Part")
		corner.Parent = workspace
		corner.Anchored = true
		corner.Size = Vector3.new(1,1,1)
		corner.Position = pos
		table.insert(partTri,corner)
	end
	
	
	return partTri
end
 


local function calculateCircumcenter2D(triangle)
	
	local A = triangle[1].Position
	
	local B = triangle[2].Position
	local C = triangle[3].Position
	
	local x1, z1 = A.X, A.Z
	local x2, z2 = B.X, B.Z
	local x3, z3 = C.X, C.Z

	local d = 2 * (x1 * (z2 - z3) + x2 * (z3 - z1) + x3 * (z1 - z2))

	if d == 0 then
		return nil, "Points are collinear; no circumcenter exists."
	end

	local cx = ((x1^2 + z1^2) * (z2 - z3) + (x2^2 + z2^2) * (z3 - z1) + (x3^2 + z3^2) * (z1 - z2)) / d
	local cz = ((x1^2 + z1^2) * (x3 - x2) + (x2^2 + z2^2) * (x1 - x3) + (x3^2 + z3^2) * (x2 - x1)) / d

	return Vector3.new(cx, 0, cz) -- Circumcenter in the xz plane
end

local function calculateCircumradius(circumcenter, vertex)
	
	return (circumcenter - vertex).Magnitude
end



local function separate(blockTable)
	local notSeparated = true

	while notSeparated do
		notSeparated = false

		for _, part in pairs(blockTable) do 
			if not pushAway(part,blockTable) then
				notSeparated = true
			end
		end
	end
end

local function pushAways (room,roomTable)
	local touchingBlockList = workspace:GetPartsInPart(room)
	local parms = RaycastParams.new()
	parms.FilterDescendantsInstances = touchingBlockList
	parms.FilterType = Enum.RaycastFilterType.Include
	
		for i, part in touchingBlockList do
			local direction = (part.Position - room.Position).Unit
			direction = Vector3.new(direction.X , 0 , direction.Z)
		
			--- if we are still in the boxs then
			
	--[[		if workspace:Raycast(room, direction* -10, parms) then
				while w
				
			end
			
			--room.Position = room.Position + direction * -10 --]]
		end
end




local function isTriangleSkinny(triangle)
	local A, B, C = triangle[1].Position, triangle[2].Position, triangle[3].Position

	-- Compute edge lengths
	local AB = (B - A).Magnitude
	local BC = (C - B).Magnitude
	local CA = (A - C).Magnitude

	-- Compute semi-perimeter
	local s = (AB + BC + CA) / 2  

	-- Compute area using Heron's formula
	local area = math.sqrt(s * (s - AB) * (s - BC) * (s - CA))

	-- Compute perimeter
	local perimeter = AB + BC + CA

	-- Compute aspect ratio (normalized area)
	local aspectRatio = (4 * area) / (perimeter * perimeter)  

	-- If the ratio is too low, it's too skinny
	if aspectRatio < 0.02 then  
		print("This triangle is too skinny")
		return false
	end

	return true
end


local function delaunayTriangulation(points)
	
	
	local super = superTriangle() -- List to hold triangles (edges between points)
	
	local triangles = {}
	table.insert(triangles,super)

	
	for i = 1, #points - 2 do
		for j = i + 1, #points - 1 do
			for k = j + 1, #points do
				table.insert(triangles, {points[i], points[j], points[k]})
			end
		end
	end
	
	return triangles
end


local function secondChance (center,radius,point)
	local distance = (center - point.Position).magnitude
	
	if distance >= radius then
		return true
		
	else 
		return false
	end
		
end		

local function removeFalseDelaunayDisks(points, triangles)
	local validEdges = {}
	
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = points

	for x, edge in ipairs(triangles) do
		
		local valid = true
		
		local excludePoints = {edge[1],edge[2],edge[3]}
		
		local center = calculateCircumcenter2D(edge)
		
		if center then 

			local radius = calculateCircumradius(center,edge[1].Position)

			local parts = workspace:GetPartBoundsInRadius(center,radius,overlapParams)


			for i, point in parts do
				if not table.find(excludePoints,point) then
					if not secondChance(center,radius,point) then
						valid = false
						break
					end
				end
			end

			if valid  then
				if isTriangleSkinny(edge,radius) then
					table.insert(validEdges, edge)
				end
			end
		end
	end
	
	
	return validEdges
end


local function PrimsAlgorithm(graph, startNode)
	local MST = {}  -- Store the Minimum Spanning Tree
	local randomLines = {}
	local pq = PQ.new()
	local visited = {}

	-- Mark the starting node as visited
	
	visited[startNode] = true

	-- Add all edges from the start node to the priority queue
	for _, edge in ipairs(graph[startNode]) do
		pq:Enqueue(edge)
	end
	
	-- Process the priority queue
	while not pq:IsEmpty() do
		local root = pq:Dequeue()
		local from = root.startnode
		local to = root.endnode
		local distance = root.distance 
		

		-- Check if the destination node has already been visited
		if not visited[to]then
			-- Add the edge to MST
			table.insert(MST, {From = from, To = to, Distance = distance})
			visited[to] = true

			-- Add all edges of the newly visited node to the priority queue
			for _, newEdge in ipairs(graph[to]) do
				local ranNum = math.random(1,10)
				if not visited[newEdge.endnode] then
					pq:Enqueue(newEdge)
 					
					 
				elseif newEdge.endnode ~= from and ranNum == 1 and #randomLines < 11 then 
					table.insert(randomLines, {From = newEdge.startnode, To = newEdge.endnode, Distance = newEdge.distance})
				end
		
		  	end
		end
		
	end
	
	for i , line in pairs(randomLines) do
		table.insert(MST, line)
	end
	
	return MST
end

local function getPart(node)
	local num = string.match(node,"%d+")

	local room = game.Workspace:FindFirstChild("Room" .. tostring(num))

	local point = room:FindFirstChild("chosenDoor" .. tostring(num))

	return point
end

local function createLines(mst)
	
	for i, node in pairs(mst) do
		
		local pointA = getPart(node.From)
		local pointB = getPart(node.To)
		
		
		local distance = (pointA.Position - pointB.Position).Magnitude
		local direction = (pointB.Position - pointA.Position).Unit

		local line = Instance.new("Part")
		line.Name = "Line" .. pointA.Name .. "-" .. pointB.Name
		line.Size = Vector3.new(0.2, 0.2, distance) -- Length of the line
		line.Position = (pointA.Position + pointB.Position) / 2 -- Midpoint between the points
		line.Anchored = true
		line.Color = Color3.fromRGB(0, 255, 0)
		line.Parent = workspace
		line.CFrame = CFrame.new(line.Position, line.Position + direction)
		
	end
	
end   


-- Main function to generate and triangulate blocks
local function main()
	local hitBoxes = {}
	local numBlocks = 10
	local blocks = generateRandomBlocks(numBlocks)
	
	print(blocks)
	-- Extract the points (positions) of the blocks
	local points = {}
	for x, block in ipairs(blocks) do
		local room = blocks[x]
		local doorNode = room:FindFirstChild("chosenDoor" .. tostring(x))
		local hitBox = room:FindFirstChild("HitBox")
		
		table.insert(points,doorNode)
		table.insert(hitBoxes,hitBox)
	end

	-- Perform Delaunay Triangulation
	local triangles = delaunayTriangulation(points)

	-- Remove false Delaunay disk edges
	local validEdges = removeFalseDelaunayDisks(points, triangles)
	
	
	-- Create lines for valid edges and creates the graph for the prims algorithm 
	local graph = createLinesBetweenPoints(validEdges,points)
	
	print("this is the graph")
	print(graph)
	
	local MST = PrimsAlgorithm(graph,"chosenDoor" .. tostring(math.random(1,numBlocks)))
	
	createLines(MST)
	
	
	for _, path in pairs(MST) do
		local start = getPart(path.From).Position
		local goal = getPart(path.To).Position
		
		local path =PathFinding:createPath(start,goal,hitBoxes) 
		
		repeat task.wait() until path
		
	end
	
	
end

-- Run the main function
main()
