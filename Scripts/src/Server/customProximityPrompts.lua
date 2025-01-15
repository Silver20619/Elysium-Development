local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SS = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local customPrompt = ReplicatedStorage:WaitForChild("elysiumPrompt")

-- Rarity Colors
local rarityColors = {
	Common = Color3.new(0.227451, 0.227451, 0.227451),
	Uncommon = Color3.new(0.352941, 0.8, 0.0705882),
	Rare = Color3.new(0.0313725, 0.498039, 1),
	Legendary = Color3.new(0.890196, 0.792157, 0.0352941),
	Cursed = Color3.new(0.670588, 0.101961, 1)
}

-- Helper function to get or create the ScreenGui
local function getScreenGui()
	local screenGui = playerGui:FindFirstChild("ProximityPrompts")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ProximityPrompts"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = SS
	end
	return screenGui
end

-- function to set colors to rarity based on rarityColors
local function setRarityColor(frame, rarity)
	local color = rarityColors[rarity]
	if color then
		frame.BackgroundColor3 = color
	else
		frame.BackgroundColor3 = rarityColors["Common"] -- Default to common if rarity not found
	end
end

-- Function to create the custom prompt
local function createPrompt(prompt, inputType, gui)

	local promptUI = customPrompt:Clone()
	local frame = promptUI:WaitForChild("Frame")
	local bottomFrame = frame:WaitForChild("Bottom")
	local middleFrame = frame:WaitForChild("Middle")
	local topFrame = frame:WaitForChild("Top")

	-- UI Elements
	
	local rarityType = frame.Bottom:FindFirstChild("rarity")
	local descriptionType = middleFrame:FindFirstChild("description")
	local itemClass = topFrame:FindFirstChild("itemClassifcation")
	local item = topFrame:FindFirstChild("itemName")
	local itemQuantity = topFrame:FindFirstChild("quantity")

	-- Update UI from the ProximityPrompt's attributes
	local function raritySpecifications(rarityValue)
			if rarityValue == "Legendary" then
				for _, textElement in ipairs({item, descriptionType, rarityType, itemClass, itemQuantity}) do
				textElement.FontFace = Font.fromId(12187376739)
				
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 165, 0))
				})
				uiGradient.Rotation = 90
				uiGradient.Parent = textElement
				
		
				end
			end
		if rarityValue == "Cursed" then
			-- Function to scramble a string
			local function scrambleText(text)
				local textArray = {string.byte(text, 1, #text)}  -- Convert text to an array of byte values
				for i = #textArray, 2, -1 do
					local j = math.random(i)  -- Get a random index
					textArray[i], textArray[j] = textArray[j], textArray[i]  -- Swap the characters
				end
				return string.char(table.unpack(textArray))  -- Convert back to string
			end

			-- Function to apply the scramble effect to text elements
			local function scrambleTextElement(textElement, originalText, duration)
				local elapsedTime = 0
				while elapsedTime < duration do
					local scrambledText = scrambleText(originalText)
					textElement.Text = scrambledText
					wait(0.1)  -- Adjust this to control the speed of the scramble
					elapsedTime = elapsedTime + 0.1  -- Increment the time
				end
				-- After scrambling for the set duration, set the final text
				textElement.Text = "May cursed energy flow through you."
			end

			-- Apply the UI gradient and font changes, then start scrambling text
			for _, textElement in ipairs({item, descriptionType, rarityType, itemClass, itemQuantity}) do
				textElement.FontFace = Font.fromId(12187376739)

				local uiGradient = Instance.new("UIGradient")
				uiGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(238, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(64, 37, 172))
				})
				uiGradient.Rotation = 90
				uiGradient.Parent = textElement

				-- Start scrambling the text randomly after some delay or interval
				spawn(function()
					wait(math.random(1, 5))  -- Random delay before starting the scramble
					local originalText = textElement.Text
					scrambleTextElement(textElement, originalText, 5)  -- Scramble for 5 seconds
				end)
			end
		end

end
	
	-- Updates UI using Item Values predetermined inside Proximity Prompt
	local function updateUIFromPrompt()
		if prompt:FindFirstChild("itemType") then
			item.Text = prompt.itemType.Value
		end
		if prompt:FindFirstChild("itemClassType") then
			itemClass.Text = prompt.itemClassType.Value
		end
		if prompt:FindFirstChild("itemQuantityType") then
			itemQuantity.Text = prompt.itemQuantityType.Value
		end
		if prompt:FindFirstChild("descriptionType") then
			descriptionType.Text = prompt.descriptionType.Value
		end
		if prompt:FindFirstChild("rarityType") then
			local rarityValue = prompt.rarityType.Value
			setRarityColor(frame, rarityValue)
			rarityType.Text = prompt.rarityType.Value
			raritySpecifications(rarityValue)
		end 
	end  

	
		
		
		updateUIFromPrompt()
		

-- Functions for tweening
	local tweensForFadeOut = {}
	local tweensForFadeIn = {}
	local tweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local textTable = {item, descriptionType, rarityType, itemClass, itemQuantity}  -- Define the text objects

	for _, object in ipairs(textTable) do
		table.insert(tweensForFadeOut, TweenService:Create(object, tweenInfoFast, { TextTransparency = 1}))
		table.insert(tweensForFadeIn, TweenService:Create(object, tweenInfoFast, {TextTransparency = 0}))
	end

	table.insert(tweensForFadeOut, TweenService:Create(frame, tweenInfoFast, {Size = UDim2.fromScale(0, 1), BackgroundTransparency = 1, Visible = false}))
	table.insert(tweensForFadeIn, TweenService:Create(frame, tweenInfoFast, {Size = UDim2.fromScale(1.173, 1), BackgroundTransparency = 0.6, Visible = true}))

-- Functions for triggers
	local triggeredConnection
	local triggerEndedConnection
	

	triggeredConnection = prompt.Triggered:Connect(function()
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end
	end)
	triggerEndedConnection = prompt.TriggerEnded:Connect(function()
		for _, tween in ipairs(tweensForFadeIn) do
			tween:Play()
		end
	end)

	-- Attach the prompt to the GUI
	promptUI.Adornee = prompt.Parent
	promptUI.Parent = gui
	for _, tween in ipairs(tweensForFadeIn) do
		tween:Play()
	end

	-- Cleanup function to remove the prompt UI
	local function cleanupFunction()
		triggeredConnection:Disconnect()
		triggerEndedConnection:Disconnect()

		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end

		wait(0.7)

		promptUI.Parent = nil
	end

	return cleanupFunction
end

-- Function to control when the prompt should be interactable
local function onPromptShown(prompt)
	-- When the prompt is shown, set up the check
	local promptPart = prompt.Parent -- Assuming prompt is attached to the part
	local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local playerHumanoidRootPart = playerCharacter:WaitForChild("HumanoidRootPart")

	-- Track whether the prompt can be interacted with
	local canInteract = false
	local interactionDistance = 10  -- Only interact within 10 studs
	local maxVisibleDistance = 40  -- Visible up to 40 studs

	-- Update the prompt's activation based on distance
	local function updatePromptActivation()
		local distance = (promptPart.Position - playerHumanoidRootPart.Position).Magnitude
		if distance <= interactionDistance then
			-- Allow interaction
			prompt.Enabled = true
			canInteract = true
		else
			-- Prevent interaction
			prompt.Enabled = false
			canInteract = false
		end
	end

	-- Continuously check distance to update prompt state
	local distanceCheckConnection
	distanceCheckConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not prompt.Parent then
			-- Disconnect when the prompt is removed
			distanceCheckConnection:Disconnect()
		else
			updatePromptActivation()
		end
	end)

	-- Ensure the prompt is initially disabled for interaction
	updatePromptActivation()
end

-- Listen for ProximityPrompt events
ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Style == Enum.ProximityPromptStyle.Default then
		return
	end

	-- Set the maximum visible distance for the proximity prompt
	prompt.MaxActivationDistance = 40

	local gui = getScreenGui()
	local cleanupFunction = createPrompt(prompt, inputType, gui)

	-- Wait for the prompt to be hidden and clean up
	prompt.PromptHidden:Wait()
	cleanupFunction()

	-- Call the function to control interaction distance
	onPromptShown(prompt)
end)
