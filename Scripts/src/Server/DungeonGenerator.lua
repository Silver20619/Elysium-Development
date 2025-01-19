--[[local numOfRooms = 20
local x = 100
local y = 100



local function Generate()
	for i = 1 , numOfRooms do 
		local part = Instance.new("Part")
		part.Size = Vector3.new(math.random(1,10), 2, math.random(1,10))
		part.Position = Vector3.new(5, 10, 0) -- Spread parts along X-axis
		part.Anchored = true
		part.Parent = workspace
		
	end
	
end

Generate()--]]


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


local function generateRandomBlocks(numBlocks)
	local blocks = {}
	for i = 1, numBlocks do
		local block = Instance.new("Part")
		block.Size = Vector3.new(4, 1, 4)
		block.Position = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
		block.Anchored = true
		block.Parent = game.Workspace
		table.insert(blocks, block)
	end
	return blocks
end

local function delaunayTriangulation(points)
	-- Simple implementation of Delaunay Triangulation (mocked for brevity)
	-- For actual triangulation, you may need an external library or algorithm like Bowyer-Watson

	local triangles = {} -- List to hold triangles (edges between points)

	-- Mocking some Delaunay connections for simplicity
	for i = 1, #points - 1 do
		for j = i + 1, #points do
			table.insert(triangles, {points[i], points[j]})
		end
	end

	return triangles
end

local function createLinesBetweenPoints(points)
	for _, edge in ipairs(points) do
		local part = Instance.new("Part")
		part.Size = Vector3.new(0.2, 0.2, (edge[1].Position - edge[2].Position).Magnitude)
		part.Position = (edge[1].Position + edge[2].Position) / 2
		part.Anchored = true
		part.Parent = game.Workspace

		local direction = (edge[2].Position - edge[1].Position).unit
		part.CFrame = CFrame.new(part.Position, part.Position + direction)
	end
end 

local function removeFalseDelaunayDisks(points, triangles)
	local validEdges = {}

	for _, edge in ipairs(triangles) do
		-- Checking the Delaunay Disk condition (mocked)
		local valid = true
		local center = (edge[1].Position + edge[2].Position) / 2
		local radius = (edge[1].Position - edge[2].Position).Magnitude / 2

		-- Simple condition to check if there's another point within the disk (mocked for simplicity)
		for _, point in ipairs(points) do
			if (point.Position - center).Magnitude < radius then
				valid = false
				break
			end
		end

		if valid then
			table.insert(validEdges, edge)
		end
	end

	return validEdges
end

-- Main function to generate and triangulate blocks
local function main()
	local numBlocks = 15
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

	-- Create lines for valid edges
	createLinesBetweenPoints(validEdges)
end

-- Run the main function
main()