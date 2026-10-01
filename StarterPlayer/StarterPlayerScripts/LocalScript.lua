-- StarterPlayer > StarterPlayerScripts > LocalScript
-- Full hack-style menu (client-side only)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toggleKey = Enum.KeyCode.RightShift
local menuOpen = false

local state = {
	flight = false,
	infiniteJump = false,
	noClip = false,
	godMode = false,
	glow = false,
	esp = false,
	walkSpeed = 16,
	jumpPower = 50,
}

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
	local character = getCharacter()
	return character:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
	local character = getCharacter()
	return character:FindFirstChild("HumanoidRootPart")
end

local function createCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function createStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = 0.2
	stroke.Parent = instance
	return stroke
end

local function setLabelColor(label, color)
	label.TextColor3 = color
end

local gui = Instance.new("ScreenGui")
gui.Name = "HackMenuGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.new(0, 360, 0, 560)
menu.Position = UDim2.new(0, 30, 0, 40)
menu.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
menu.BackgroundTransparency = 0.1
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui
createCorner(menu, 16)
createStroke(menu, Color3.fromRGB(0, 255, 170), 1)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 54)
header.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.Parent = menu
createCorner(header, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "HACK MENU"
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(10, 10, 15)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -42, 0.5, -17)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = header
createCorner(closeBtn, 10)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -18, 1, -72)
scroll.Position = UDim2.new(0, 9, 0, 60)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
scroll.Parent = menu

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function makeButton(labelText, description, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 64)
	holder.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	holder.BorderSizePixel = 0
	holder.Parent = scroll
	createCorner(holder, 12)
	createStroke(holder, Color3.fromRGB(0, 255, 170), 1)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = holder

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 26)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = labelText
titleLabel.TextColor3 = Color3.fromRGB(0,255,170)
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = holder

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -20, 0, 22)
	descLabel.Position = UDim2.new(0, 12, 0, 34)
	descLabel.BackgroundTransparency = 1	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = description
descLabel.TextColor3 = Color3.fromRGB(180,180,180)
descLabel.TextSize = 12
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.Parent = holder

	button.MouseButton1Click:Connect(function()
		callback()
	end)

	button.MouseEnter:Connect(function()
		TweenService:Create(holder, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(holder, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(24, 24, 30)}):Play()
	end)

	return holder
end

local function makeToggle(labelText, description, valueKey, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 70)
	holder.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	holder.BorderSizePixel = 0
	holder.Parent = scroll
	createCorner(holder, 12)
	createStroke(holder, Color3.fromRGB(0,255,170), 1)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -90, 0, 26)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = labelText
titleLabel.TextColor3 = Color3.fromRGB(0,255,170)
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = holder

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -90, 0, 22)
	descLabel.Position = UDim2.new(0, 12, 0, 34)
	descLabel.BackgroundTransparency = 1	descLabel.Font = Enum.Font.Gotham
descLabel.Text = description
descLabel.TextColor3 = Color3.fromRGB(180,180,180)
descLabel.TextSize = 12
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.Parent = holder

	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 54, 0, 26)
	toggleBg.Position = UDim2.new(1, -64, 0.5, -13)
	toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	toggleBg.BorderSizePixel = 0
	toggleBg.Parent = holder
	createCorner(toggleBg, 13)

	local toggleKnob = Instance.new("Frame")
	toggleKnob.Size = UDim2.new(0, 20, 0, 20)
	toggleKnob.Position = UDim2.new(0, 4, 0.5, -10)
	toggleKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	toggleKnob.BorderSizePixel = 0
	toggleKnob.Parent = toggleBg
	createCorner(toggleKnob, 10)

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, 0, 1, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = ""
	toggleBtn.Parent = holder

	local function refreshToggle()
		local enabled = state[valueKey]
		if enabled then
			toggleBg.BackgroundColor3 = Color3.fromRGB(0,255,170)
			toggleKnob.Position = UDim2.new(1, -24, 0.5, -10)
		else
			toggleBg.BackgroundColor3 = Color3.fromRGB(80,80,80)
			toggleKnob.Position = UDim2.new(0, 4, 0.5, -10)
		end
	end

	toggleBtn.MouseButton1Click:Connect(function()
		state[valueKey] = not state[valueKey]
		callback(state[valueKey])
		refreshToggle()
	end)

	refreshToggle()
	return holder
end

local function makeSlider(labelText, description, minValue, maxValue, valueKey, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 82)
	holder.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	holder.BorderSizePixel = 0
	holder.Parent = scroll
	createCorner(holder, 12)
	createStroke(holder, Color3.fromRGB(0,255,170), 1)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 24)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = labelText
titleLabel.TextColor3 = Color3.fromRGB(0,255,170)
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = holder

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -90, 0, 18)
	descLabel.Position = UDim2.new(0, 12, 0, 32)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
descLabel.Text = description
descLabel.TextColor3 = Color3.fromRGB(180,180,180)
descLabel.TextSize = 11
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 20)
	valueLabel.Position = UDim2.new(1, -62, 0, 32)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.Text = tostring(state[valueKey])
	valueLabel.TextColor3 = Color3.fromRGB(0,255,170)
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = holder

	local sliderBG = Instance.new("Frame")
	sliderBG.Size = UDim2.new(1, -24, 0, 8)
	sliderBG.Position = UDim2.new(0, 12, 0, 58)
	sliderBG.BackgroundColor3 = Color3.fromRGB(40,40,45)
	sliderBG.BorderSizePixel = 0
	sliderBG.Parent = holder
	createCorner(sliderBG, 4)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((state[valueKey] - minValue) / (maxValue - minValue), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0,255,170)
	fill.BorderSizePixel = 0
	fill.Parent = sliderBG
	createCorner(fill, 4)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.BorderSizePixel = 0
	knob.Position = UDim2.new((state[valueKey] - minValue) / (maxValue - minValue), -7, 0.5, -7)
	knob.Parent = sliderBG
	createCorner(knob, 10)

	local dragging = false
	local function updateFromMouse()
		local mouseX = UserInputService:GetMouseLocation().X
		local startX = sliderBG.AbsolutePosition.X
		local endX = startX + sliderBG.AbsoluteSize.X
		local percent = math.clamp((mouseX - startX) / sliderBG.AbsoluteSize.X, 0, 1)
		local value = minValue + ((maxValue - minValue) * percent)
		value = math.floor(value + 0.5)
		state[valueKey] = value
		valueLabel.Text = tostring(value)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -7, 0.5, -7)
		callback(value)
	end

	sliderBG.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromMouse()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromMouse()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	return holder
end

makeToggle("Infinite Jump", "Jump without touching ground", "infiniteJump", function(enabled)
	if enabled then
		local hum = getHumanoid()
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

makeToggle("Flight", "Move through air freely", "flight", function(enabled)
	local hum = getHumanoid()
	local root = getRootPart()
	if not hum or not root then return end
	if enabled then
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = root
		root:SetAttribute("FlightBodyVelocity", bv)
		local loop
		loop = RunService.RenderStepped:Connect(function()
			if not state.flight then
				loop:Disconnect()
				if root:FindFirstChild("FlightBodyVelocity") then
					root.FlightBodyVelocity:Destroy()
				end
				return
			end
			local move = Vector3.new(0, 0, 0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += root.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= root.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += root.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= root.CFrame.RightVector end
			if move.Magnitude > 0 then move = move.Unit * 40 end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) * 18 end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) * 18 end
			root.FlightBodyVelocity.Velocity = move
		end)
	else
		if root:FindFirstChild("FlightBodyVelocity") then
			root.FlightBodyVelocity:Destroy()
		end
	end
end)

makeToggle("No Clip", "Clip through walls", "noClip", function(enabled)
	local character = getCharacter()
	if char then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not enabled
			end
		end
	end
end)

makeToggle("God Mode", "Take no damage", "godMode", function(enabled)
	local hum = getHumanoid()
	if not hum then return end
	if enabled then
		hum.MaxHealth = 9e9
		hum.Health = 9e9
	else
		hum.MaxHealth = 100
		hum.Health = 100
	end
end)

makeToggle("Glow", "Neon aesthetic", "glow", function(enabled)
	local character = getCharacter()
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = enabled and Enum.Material.Neon or Enum.Material.SmoothPlastic
			part.Color = enabled and Color3.fromRGB(0,255,170) or Color3.fromRGB(255,255,255)
		end
	end
end)

makeToggle("ESP", "See players through walls", "esp", function(enabled)
	local function refreshESP()
		for _, other in ipairs(Players:GetPlayers()) do
			if other ~= player and other.Character then
				local head = other.Character:FindFirstChild("Head")
				if not head then continue end
				if enabled then
					local bill = head:FindFirstChild("ESPBill")
					if bill then bill:Destroy() end
					local guiBill = Instance.new("BillboardGui")
					guiBill.Name = "ESPBill"
					guiBill.Size = UDim2.new(0, 120, 0, 30)
					guiBill.Adornee = head
					guiBill.AlwaysOnTop = true
					guiBill.Parent = head

					local label = Instance.new("TextLabel")
					label.Size = UDim2.new(1, 0, 1, 0)
					label.BackgroundTransparency = 1
					label.Text = other.Name
					label.Font = Enum.Font.GothamBold
					label.TextSize = 16
					label.TextColor3 = Color3.fromRGB(0,255,170)
					label.Parent = guiBill
				else
					local bill = head:FindFirstChild("ESPBill")
					if bill then bill:Destroy() end
				end
			end
		end
	end
	refreshESP()
end)

makeSlider("Walk Speed", "Set character speed", 16, 200, "walkSpeed", function(value)
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = value
	end
end)

makeSlider("Jump Power", "Set jump height", 50, 200, "jumpPower", function(value)
	local hum = getHumanoid()
	if hum then
		hum.JumpPower = value
	end
end)

makeButton("Reset Character", "Respawn fix", function()
	local character = getCharacter()
	if character then
		character:PivotTo(character:GetPivot() + Vector3.new(0, 3, 0))
	end
end)

makeButton("Close Menu", "Hide the menu", function()
	menuOpen = false
	menu.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
	menuOpen = false
	menu.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == toggleKey then
		menuOpen = not menuOpen
		menu.Visible = menuOpen
	end
end)

player.CharacterAdded:Connect(function(character)
	task.wait(0.2)
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = state.walkSpeed
		hum.JumpPower = state.jumpPower
	end
end)

print("Hack menu loaded. Press RightShift to open.")
