
local boundingBox = game.Workspace:WaitForChild("plat")
local baseplate = game.Workspace:WaitForChild("Baseplate")
local PQ = require(script:WaitForChild("PQ"))

local size = boundingBox.Size
local cframe = boundingBox.CFrame

-- Calculate XZ bounds
local minX = cframe.Position.X - size.X / 2
local maxX = cframe.Position.X + size.X / 2
local minZ = cframe.Position.Z - size.Z / 2
local maxZ = cframe.Position.Z + size.Z / 2

local existingLines = {}

local function getRandomPositionXZ()
	-- Generate random X and Z
	local randomX = math.random() * (maxX - minX) + minX
	local randomZ = math.random() * (maxZ - minZ) + minZ

	-- Return the random position with the fixed Y
	return Vector3.new(randomX, 0, randomZ)
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
	for i = 1, numBlocks do
		local block = Instance.new("Part")
		block.Name = "Room" .. tostring(i)
		block.Size = Vector3.new(math.random(1), math.random(1), math.random(1)) * 2
		block.Position = getRandomPositionXZ()
		block.Anchored = true
		block.Parent = game.Workspace
		table.insert(blocks, block)

	end

	--separate(blocks)
	for _, part in blocks do
		part.Size = part.Size/2
	end
	return blocks
end

 
local function createLinesBetweenPoints(validEdges,points)
	
	local graph = createGraph(points)
	
	for p, tri in pairs(validEdges) do
		for i = 1, #tri do
			for k = i +1 , #tri do

				local pointA = tri[i]
				local pointB = tri[k]
				local distance = (pointA.Position - pointB.Position).Magnitude

			--[[	local line = Instance.new("Part")
				line.Name = "Line" .. pointA.Name .. "-" .. pointB.Name
				line.Size = Vector3.new(0.2, 0.2, distance) -- Length of the line
				line.Position = (pointA.Position + pointB.Position) / 2 -- Midpoint between the points
				line.Anchored = true
				line.Parent = workspace -- Parent the line to the workspace
				

				-- Set the orientation using CFrame
				local direction = (pointB.Position - pointA.Position).Unit -- Direction from pointA to pointB
				line.CFrame = CFrame.new(line.Position, line.Position + direction) -- Align the part--]]
				
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
	local a = Vector3.new(doubleminX, 0, doubleminZ) -- Bottom-left corner
	local b = Vector3.new(doublemaxX, 0, doubleminZ) -- Bottom-right corner
	local c = Vector3.new(cframe.Position.X, 0, maxZ * 2 ) -- Top-center
	local triangle = {a,b,c}
	
	local partTri = {}
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
 


--[[local numberOfBlocks = 20 -- Number of blocks to spawn



local blockSize = Vector3.new(5, 5, 5) -- Size of each block
local spawnAreaSize = Vector3.new(100, 0, 100) -- Size of the spawning area
local blocks = {} -- Store spawned blocks

-- Function to check if two blocks overlap
local function isOverlapping(pos1, size1, pos2, size2)
	return math.abs(pos1.X - pos2.X) < (size1.X / 2 + size2.X / 2) and
		math.abs(pos1.Y - pos2.Y) < (size1.Y / 2 + size2.Y / 2) and
		math.abs(pos1.Z - pos2.Z) < (size1.Z / 2 + size2.Z / 2)
end

-- Generate a random position within the spawn area
local function getRandomPosition()
	return Vector3.new(
		math.random(-spawnAreaSize.X / 2, spawnAreaSize.X / 2),
		math.random(-spawnAreaSize.Y / 2, spawnAreaSize.Y / 2),
		math.random(-spawnAreaSize.Z / 2, spawnAreaSize.Z / 2)
	)
end

-- Spawn blocks
for i = 1, numberOfBlocks do
	local newPosition
	local isValidPosition = false

	-- Find a valid position
	repeat
		newPosition = getRandomPosition()
		isValidPosition = true

		for _, block in ipairs(blocks) do
			if isOverlapping(newPosition, blockSize, block.Position, block.Size) then
				isValidPosition = false
				break
			end
		end
	until isValidPosition

	-- Create the block
	local newBlock = Instance.new("Part")
	newBlock.Size = blockSize
	newBlock.Position = newPosition
	newBlock.Anchored = true
	newBlock.Parent = workspace

	-- Store the block for future overlap checks
	table.insert(blocks, newBlock)
end--]]


--[[local function isPointInCircumcircle()
	local P = game.Workspace:WaitForChild("P").Position
	print("P x position is: ".. P.X .. " and P y position is: " .. P.Y)

	local ax, ay, az = A.X, A.Y, A.Z
	local bx, by, bz = B.X, B.Y, B.Z
	local cx, cy, cz = C.X, C.Y, C.Z
	local px, py, pz = P.X, P.Y, P.Z

	-- Create the 4x4 matrix for the determinant
	local matrix = {
		{ax, ay, az, ax^2 + ay^2 + az^2},
		{bx, by, bz, bx^2 + by^2 + bz^2},
		{cx, cy, cz, cx^2 + cy^2 + cz^2},
		{px, py, pz, px^2 + py^2 + pz^2}
	}

	-- Function to calculate the determinant of a 4x4 matrix
	local function det4x4(m)
		local det = m[1][1] * (
			m[2][2] * (m[3][3] * m[4][4] - m[3][4] * m[4][3]) 
			- m[2][3] * (m[3][2] * m[4][4] - m[3][4] * m[4][2]) 
				+ m[2][4] * (m[3][2] * m[4][3] - m[3][3] * m[4][2])
		) 
		- m[1][2] * (
			m[2][1] * (m[3][3] * m[4][4] - m[3][4] * m[4][3]) 
			- m[2][3] * (m[3][1] * m[4][4] - m[3][4] * m[4][1]) 
				+ m[2][4] * (m[3][1] * m[4][3] - m[3][3] * m[4][1])
		) 
			+ m[1][3] * (
				m[2][1] * (m[3][2] * m[4][4] - m[3][4] * m[4][2]) 
				- m[2][2] * (m[3][1] * m[4][4] - m[3][4] * m[4][1]) 
				+ m[2][4] * (m[3][1] * m[4][2] - m[3][2] * m[4][1])
			) 
		- m[1][4] * (
			m[2][1] * (m[3][2] * m[4][3] - m[3][3] * m[4][2]) 
			- m[2][2] * (m[3][1] * m[4][3] - m[3][3] * m[4][1]) 
				+ m[2][3] * (m[3][1] * m[4][2] - m[3][2] * m[4][1])
		)
		return det
	end
	-- Calculate the determinant
	local det = det4x4(matrix)

	if det > 0 then
		print("We are inside the circle")
	elseif det < 0 then
		print("We are outside of the circle")
	elseif det == 0 then
		print("We are on the circumcircle")
	end

	print(det)

	return det > 0
end--]]

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

local function rotateDirection90DegreesX(direction)
	return Vector3.new(direction.X, direction.Z, -direction.Y) * math.random (1,10)
end

local function rotateDirection90DegreesZ(direction)
	return Vector3.new(-direction.Y, direction.X, direction.Z) *math.random(5,15)
end

local function pushAway(room,roomTable)
	local partsInside = workspace:GetPartsInPart(room)
	for i, part in partsInside do
		if part ~= room then
			local direction = (room.Position - part.Position).Unit
			direction = Vector3.new(direction.X , 0 , direction.Z)
			room.Position = room.Position + direction * -10 
			
			if workspace:FindPartOnRay(Ray.new(room.Position, direction * -10)) then
				direction = rotateDirection90DegreesX(rotateDirection90DegreesZ(direction)) 
				
				return false
			end
			wait(0.5)
			
		end
		
	end
	return true
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




local function filterTriangles(triangle,radius)
	local maxRatio = 5.0
	
	local A, B, C = triangle[1].Position , triangle[2].Position, triangle[3].Position
	local AB = (A - B).Magnitude
	local BC = (B - C).Magnitude
	local CA = (C - A).Magnitude
	
	local shortestEdge = math.min(AB, BC , CA)
	
	local edgeRatio = radius / shortestEdge
	
	if edgeRatio <= maxRatio then
		return true
		
	else 
		print("This triangle is to skinny")
		print(triangle)
		return false
	end
end


local function delaunayTriangulation(points)
	-- Simple implementation of Delaunay Triangulation (mocked for brevity)
	-- For actual triangulation, you may need an external library or algorithm like Bowyer-Watson
	
	local super = superTriangle() -- List to hold triangles (edges between points)
	
	local triangles = {}
	table.insert(triangles,super)

	-- Mocking some Delaunay connections for simplicity
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
		-- Checking the Delaunay Disk condition (mocked)
		local valid = true
		
		local excludePoints = {edge[1],edge[2],edge[3]}
		
		local center = calculateCircumcenter2D(edge)
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
			if filterTriangles(edge,radius) then
				table.insert(validEdges, edge)
			end
		end
	end
	
	
	return validEdges
end


local function PrimsAlgorithm(graph, startNode)
	local MST = {}  -- Store the Minimum Spanning Tree
	local randomLines = {}
	local maxLines = 5
	local pq = PQ.new()
	local visited = {}

	-- Mark the starting node as visited
	visited[startNode] = true

	-- Add all edges from the start node to the priority queue
	for _, edge in ipairs(graph[startNode]) do
		print(graph[startNode])
		pq:Enqueue(edge)
	end

	-- Process the priority queue
	while not pq:IsEmpty() do
		local root = pq:Dequeue()
		local from = root.startnode
		local to = root.endnode
		local distance = root.distance 

		-- Check if the destination node has already been visited
		if not visited[to] then
			-- Add the edge to MST
			table.insert(MST, {From = from, To = to, Distance = distance})
			visited[to] = true

			-- Add all edges of the newly visited node to the priority queue
			for _, newEdge in ipairs(graph[to]) do
				if not visited[newEdge.endnode] then
					pq:Enqueue(newEdge)
					--pq:Enqueue(to, newEdge.node, newEdge.distance)
				elseif randomLines[newEdge.endnode] and #randomLines 
				end
			end
		end
	end

	return MST
end


local function createLines(mst)
	for i, node in pairs(mst) do
		local pointA = game.Workspace:FindFirstChild(node.From)
		local pointB = game.Workspace:FindFirstChild(node.To)
		
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
--[[Print the result
print("Minimum Spanning Tree:")
for _, edge in ipairs(MST) do
	print(edge.From .. " -> " .. edge.To .. " (Weight: " .. edge.Weight .. ")")
end--]]

-- Main function to generate and triangulate blocks
local function main()
	local numBlocks = 50
	local blocks = generateRandomBlocks(numBlocks)

	-- Extract the points (positions) of the blocks
	local points = {}
	for _, block in ipairs(blocks) do
		table.insert(points, block)
	end

	-- Perform Delaunay Triangulation
	local triangles = delaunayTriangulation(points)

	-- Remove false Delaunay disk edges
	local validEdges = removeFalseDelaunayDisks(points, triangles)
	
	
	-- Create lines for valid edges and creates the graph for the prims algorithm 
	local graph = createLinesBetweenPoints(validEdges,points)
	
	print(graph)
	print("Room" .. tostring(math.random(1,numBlocks)))
	local MST =PrimsAlgorithm(graph,"Room" .. tostring(math.random(1,numBlocks)))
	createLines(MST)
	
	print ("this is the mst ")
	print(MST)
end

-- Run the main function
main()

