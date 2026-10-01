-- StarterPlayer > StarterPlayerScripts > LocalScript_v2
-- Advanced Hack Menu with Aim + Enhanced ESP
-- Press RightShift to toggle menu

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local MENU_KEY = Enum.KeyCode.RightShift
local menuOpen = false

local state = {
	flight = false,
	infiniteJump = false,
	noClip = false,
	godMode = false,
	glow = false,
	esp = false,
	aim = false,
	aimSpeed = 0.15,
	aimRadius = 100,
	walkSpeed = 16,
	jumpPower = 50,
}

local espTargets = {}
local aimConnection = nil

-- ===== UTILITIES =====
local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
	local character = getCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local character = getCharacter()
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function makeCorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = obj
end

local function makeStroke(obj, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = 0.2
	stroke.Parent = obj
end

-- ===== MAIN GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HackMenuGuiV2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.new(0, 380, 0, 650)
menu.Position = UDim2.new(0, 30, 0, 40)
menu.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
menu.BackgroundTransparency = 0.08
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = screenGui
makeCorner(menu, 16)
makeStroke(menu, Color3.fromRGB(0, 255, 170), 2)

-- ===== HEADER =====
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
header.BackgroundTransparency = 0.12
header.BorderSizePixel = 0
header.Parent = menu
makeCorner(header, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "⚡ HACK MENU v2"
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(0, 255, 170)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -90, 0, 20)
subtitle.Position = UDim2.new(0, 12, 0, 32)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Aim • ESP • Flight"
subtitle.TextSize = 12
subtitle.TextColor3 = Color3.fromRGB(150, 200, 180)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -46, 0.5, -18)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = header
makeCorner(closeBtn, 10)

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {
		BackgroundTransparency = 0.05
	}):Play()
end)

closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {
		BackgroundTransparency = 0.2
	}):Play()
end)

-- ===== SCROLL FRAME =====
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -18, 1, -80)
scroll.Position = UDim2.new(0, 9, 0, 66)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
scroll.CanvasSize = UDim2.new(0, 0, 0, 1800)
scroll.Parent = menu

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- ===== MENU COMPONENTS =====
local function makeButton(labelText, desc, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 68)
	holder.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	holder.BorderSizePixel = 0
	holder.Parent = scroll
	makeCorner(holder, 12)
	makeStroke(holder, Color3.fromRGB(0, 255, 170), 1)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = holder

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 28)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = labelText
	titleLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = holder

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -20, 0, 24)
	descLabel.Position = UDim2.new(0, 12, 0, 36)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
	descLabel.TextSize = 12
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = holder

	button.MouseButton1Click:Connect(function()
		callback()
		holder.BackgroundTransparency = 0.2
		task.wait(0.1)
		holder.BackgroundTransparency = 0
	end)

	button.MouseEnter:Connect(function()
		TweenService:Create(holder, TweenInfo.new(0.18), {
			BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(holder, TweenInfo.new(0.18), {
			BackgroundColor3 = Color3.fromRGB(20, 20, 26)
		}):Play()
	end)

	return holder
end

local function makeToggle(labelText, desc, key, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 74)
	holder.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	holder.BorderSizePixel = 0
	holder.Parent = scroll
	makeCorner(holder, 12)
	makeStroke(holder, Color3.fromRGB(0, 255, 170), 1)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -90, 0, 28)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = labelText
	titleLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = holder

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -90, 0, 24)
	descLabel.Position = UDim2.new(0, 12, 0, 36)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
	descLabel.TextSize = 12
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = holder

	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 60, 0, 28)
	toggleBg.Position = UDim2.new(1, -70, 0.5, -14)
	toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	toggleBg.BorderSizePixel = 0
	toggleBg.Parent = holder
	makeCorner(toggleBg, 14)

	local toggleKnob = Instance.new("Frame")
	toggleKnob.Size = UDim2.new(0, 22, 0, 22)
	toggleKnob.Position = UDim2.new(0, 4, 0.5, -11)
	toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleKnob.BorderSizePixel = 0
	toggleKnob.Parent = toggleBg
	makeCorner(toggleKnob, 11)

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, 0, 1, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = ""
	toggleBtn.Parent = holder

	local function refresh()
		local enabled = state[key]
		if enabled then
			toggleBg.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
			TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
				Position = UDim2.new(1, -26, 0.5, -11)
			}):Play()
		else
			toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 4, 0.5, -11)
			}):Play()
		end
	end

	toggleBtn.MouseButton1Click:Connect(function()
		state[key] = not state[key]
		callback(state[key])
		refresh()
	end)

	toggleBtn.MouseEnter:Connect(function()
		TweenService:Create(holder, TweenInfo.new(0.18), {
			BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		}):Play()
	end)

	toggleBtn.MouseLeave:Connect(function()
		TweenService:Create(holder, TweenInfo.new(0.18), {
			BackgroundColor3 = Color3.fromRGB(20, 20, 26)
		}):Play()
	end)

	refresh()
	return holder
end

local function makeSlider(labelText, desc, minValue, maxValue, key, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 92)
	holder.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	holder.BorderSizePixel = 0
	holder.Parent = scroll
	makeCorner(holder, 12)
	makeStroke(holder, Color3.fromRGB(0, 255, 170), 1)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 26)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = labelText
	titleLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = holder

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, -90, 0, 20)
	descLabel.Position = UDim2.new(0, 12, 0, 34)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.Gotham
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
	descLabel.TextSize = 11
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 22)
	valueLabel.Position = UDim2.new(1, -62, 0, 32)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.Text = string.format("%.1f", state[key])
	valueLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = holder

	local sliderBG = Instance.new("Frame")
	sliderBG.Size = UDim2.new(1, -24, 0, 8)
	sliderBG.Position = UDim2.new(0, 12, 0, 62)
	sliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	sliderBG.BorderSizePixel = 0
	sliderBG.Parent = holder
	makeCorner(sliderBG, 4)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((state[key] - minValue) / (maxValue - minValue), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
	fill.BorderSizePixel = 0
	fill.Parent = sliderBG
	makeCorner(fill, 4)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Position = UDim2.new((state[key] - minValue) / (maxValue - minValue), -8, 0.5, -8)
	knob.Parent = sliderBG
	makeCorner(knob, 10)

	local dragging = false

	local function updateFromMouse()
		local mouseX = UserInputService:GetMouseLocation().X
		local startX = sliderBG.AbsolutePosition.X
		local percent = math.clamp((mouseX - startX) / sliderBG.AbsoluteSize.X, 0, 1)
		local value = minValue + ((maxValue - minValue) * percent)
		
		state[key] = math.floor(value * 10) / 10
		valueLabel.Text = string.format("%.1f", state[key])
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -8, 0.5, -8)
		callback(state[key])
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

-- ===== FEATURES =====

-- Combat / Aim Tab
local function toggleAim()
	state.aim = not state.aim
	
	if state.aim then
		if aimConnection then
			aimConnection:Disconnect()
		end
		
		aimConnection = RunService.RenderStepped:Connect(function()
			if not state.aim then
				aimConnection:Disconnect()
				return
			end

			local root = getRoot()
			local hum = getHumanoid()
			if not root or not hum then return end

			local closestPlayer = nil
			local closestDistance = state.aimRadius

			for _, otherPlayer in ipairs(Players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Character then
					local otherHum = otherPlayer.Character:FindFirstChildOfClass("Humanoid")
					local otherHead = otherPlayer.Character:FindFirstChild("Head")
					
					if otherHum and otherHead and otherHum.Health > 0 then
						local distance = (root.Position - otherHead.Position).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closestPlayer = otherPlayer
						end
					end
				end
			end

			if closestPlayer and closestPlayer.Character then
				local targetHead = closestPlayer.Character:FindFirstChild("Head")
				if targetHead then
					local direction = (targetHead.Position - root.Position).Unit
					local newCFrame = CFrame.new(root.Position, root.Position + direction)
					root.CFrame = root.CFrame:Lerp(newCFrame, state.aimSpeed)
				end
			end
		end)
	else
		if aimConnection then
			aimConnection:Disconnect()
			aimConnection = nil
		end
	end

	return state.aim
end

-- ESP Enhanced
local function toggleESP()
	state.esp = not state.esp
	
	if state.esp then
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character then
				local head = otherPlayer.Character:FindFirstChild("Head")
				if head then
					local existing = head:FindFirstChild("ESPBillboard")
					if existing then existing:Destroy() end

					local billboard = Instance.new("BillboardGui")
					billboard.Name = "ESPBillboard"
					billboard.Size = UDim2.new(0, 140, 0, 50)
					billboard.Adornee = head
					billboard.AlwaysOnTop = true
					billboard.MaxDistance = 1000
					billboard.Parent = head

					-- Background
					local bg = Instance.new("Frame")
					bg.Size = UDim2.new(1, 0, 1, 0)
					bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					bg.BackgroundTransparency = 0.3
					bg.BorderSizePixel = 0
					bg.Parent = billboard
					makeCorner(bg, 6)

					-- Player name
					local nameLabel = Instance.new("TextLabel")
					nameLabel.Size = UDim2.new(1, 0, 0, 20)
					nameLabel.BackgroundTransparency = 1
					nameLabel.Text = otherPlayer.Name
					nameLabel.Font = Enum.Font.GothamBold
					nameLabel.TextSize = 14
					nameLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
					nameLabel.Parent = billboard

					-- Health bar
					local healthBg = Instance.new("Frame")
					healthBg.Size = UDim2.new(1, -8, 0, 8)
					healthBg.Position = UDim2.new(0, 4, 0, 22)
					healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					healthBg.BorderSizePixel = 0
					healthBg.Parent = billboard
					makeCorner(healthBg, 3)

					local healthFill = Instance.new("Frame")
					healthFill.Name = "Fill"
					healthFill.Size = UDim2.new(1, 0, 1, 0)
					healthFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
					healthFill.BorderSizePixel = 0
					healthFill.Parent = healthBg
					makeCorner(healthFill, 3)

					-- Distance
					local distLabel = Instance.new("TextLabel")
					distLabel.Name = "Distance"
					distLabel.Size = UDim2.new(1, 0, 0, 18)
					distLabel.Position = UDim2.new(0, 0, 0, 32)
					distLabel.BackgroundTransparency = 1
					distLabel.Text = "Dist: ?"
					distLabel.Font = Enum.Font.Gotham
					distLabel.TextSize = 11
					distLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
					distLabel.Parent = billboard

					-- Update loop
					local updateConnection
					updateConnection = RunService.RenderStepped:Connect(function()
						if not billboard.Parent or not state.esp then
							updateConnection:Disconnect()
							billboard:Destroy()
							return
						end

						local otherHum = otherPlayer.Character and otherPlayer.Character:FindFirstChildOfClass("Humanoid")
						if otherHum then
							local healthPercent = otherHum.Health / otherHum.MaxHealth
							healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
							
							-- Color health bar
							if healthPercent > 0.5 then
								healthFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
							elseif healthPercent > 0.25 then
								healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
							else
								healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
							end
						end

						local distance = (root.Position - head.Position).Magnitude
						distLabel.Text = "Dist: " .. math.floor(distance) .. "m"
					end)
				end
			end
		end
	else
		-- Remove all ESP
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer.Character then
				local head = otherPlayer.Character:FindFirstChild("Head")
				if head then
					local billboard = head:FindFirstChild("ESPBillboard")
					if billboard then
						billboard:Destroy()
					end
				end
			end
		end
	end

	return state.esp
end

-- Flight
local function toggleFlight()
	state.flight = not state.flight
	local root = getRoot()
	if not root then return state.flight end

	if state.flight then
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Name = "HackFlightVelocity"
		bv.Parent = root

		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not state.flight then
				connection:Disconnect()
				if root:FindFirstChild("HackFlightVelocity") then
					root.HackFlightVelocity:Destroy()
				end
				return
			end

			local move = Vector3.new(0, 0, 0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				move += root.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				move -= root.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				move += root.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				move -= root.CFrame.RightVector
			end

			if move.Magnitude > 0 then
				move = move.Unit * 50
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				move += Vector3.new(0, 1, 0) * 25
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				move -= Vector3.new(0, 1, 0) * 25
			end

			root.HackFlightVelocity.Velocity = move
		end)
	else
		if root:FindFirstChild("HackFlightVelocity") then
			root.HackFlightVelocity:Destroy()
		end
	end

	return state.flight
end

-- Infinite Jump
local function toggleInfiniteJump()
	state.infiniteJump = not state.infiniteJump
	if state.infiniteJump then
		local connection
		connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
				if state.infiniteJump then
					local hum = getHumanoid()
					if hum then
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				else
					connection:Disconnect()
				end
			end
		end)
	end
	return state.infiniteJump
end

-- No Clip
local function toggleNoclip()
	state.noClip = not state.noClip
	local character = getCharacter()
	if not character then return state.noClip end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not state.noClip
		end
	end
	return state.noClip
end

-- God Mode
local function toggleGodMode()
	state.godMode = not state.godMode
	local hum = getHumanoid()
	if not hum then return state.godMode end
	if state.godMode then
		hum.MaxHealth = 9e9
		hum.Health = 9e9
	else
		hum.MaxHealth = 100
		hum.Health = 100
	end
	return state.godMode
end

-- Glow
local function toggleGlow()
	state.glow = not state.glow
	local character = getCharacter()
	if not character then return state.glow end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = state.glow and Enum.Material.Neon or Enum.Material.SmoothPlastic
			if state.glow then
				part.Color = Color3.fromRGB(0, 255, 170)
			end
		end
	end
	return state.glow
end

-- ===== BUILD MENU =====

-- Combat Section
Instance.new("TextLabel").Parent = scroll  -- Spacer
local combatSection = Instance.new("TextLabel")
combatSection.Size = UDim2.new(1, 0, 0, 28)
combatSection.BackgroundTransparency = 1
combatSection.Font = Enum.Font.GothamBold
combatSection.Text = "⚔ COMBAT"
combatSection.TextColor3 = Color3.fromRGB(255, 100, 100)
combatSection.TextSize = 14
combatSection.TextXAlignment = Enum.TextXAlignment.Left
combatSection.Parent = scroll

makeToggle("Aim Bot", "Auto-aim at enemies", "aim", toggleAim)
makeSlider("Aim Speed", "Higher = faster lock", 0.1, 0.5, "aimSpeed", function(value)
	state.aimSpeed = value
end)
makeSlider("Aim Radius", "Detect range (studs)", 50, 500, "aimRadius", function(value)
	state.aimRadius = value
end)

-- Visual Section
local visualSection = Instance.new("TextLabel")
visualSection.Size = UDim2.new(1, 0, 0, 28)
visualSection.BackgroundTransparency = 1
visualSection.Font = Enum.Font.GothamBold
visualSection.Text = "👁 VISUAL"
visualSection.TextColor3 = Color3.fromRGB(100, 180, 255)
visualSection.TextSize = 14
visualSection.TextXAlignment = Enum.TextXAlignment.Left
visualSection.Parent = scroll

makeToggle("ESP Advanced", "See players + health", "esp", toggleESP)
makeToggle("Glow", "Neon player effect", "glow", toggleGlow)

-- Movement Section
local movementSection = Instance.new("TextLabel")
movementSection.Size = UDim2.new(1, 0, 0, 28)
movementSection.BackgroundTransparency = 1
movementSection.Font = Enum.Font.GothamBold
movementSection.Text = "🚀 MOVEMENT"
movementSection.TextColor3 = Color3.fromRGB(200, 100, 255)
movementSection.TextSize = 14
movementSection.TextXAlignment = Enum.TextXAlignment.Left
movementSection.Parent = scroll

makeToggle("Flight", "Fly mode", "flight", toggleFlight)
makeToggle("Infinite Jump", "Unlimited jumps", "infiniteJump", toggleInfiniteJump)
makeToggle("No Clip", "Walk through walls", "noClip", toggleNoclip)
makeSlider("Walk Speed", "Movement speed", 16, 200, "walkSpeed", function(value)
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = value
	end
end)
makeSlider("Jump Power", "Jump height", 50, 200, "jumpPower", function(value)
	local hum = getHumanoid()
	if hum then
		hum.JumpPower = value
	end
end)

-- Survival Section
local survivalSection = Instance.new("TextLabel")
survivalSection.Size = UDim2.new(1, 0, 0, 28)
survivalSection.BackgroundTransparency = 1
survivalSection.Font = Enum.Font.GothamBold
survivalSection.Text = "🛡 SURVIVAL"
survivalSection.TextColor3 = Color3.fromRGB(100, 255, 100)
survivalSection.TextSize = 14
survivalSection.TextXAlignment = Enum.TextXAlignment.Left
survivalSection.Parent = scroll

makeToggle("God Mode", "Take no damage", "godMode", toggleGodMode)

-- Utilities Section
local utilitiesSection = Instance.new("TextLabel")
utilitiesSection.Size = UDim2.new(1, 0, 0, 28)
utilitiesSection.BackgroundTransparency = 1
utilitiesSection.Font = Enum.Font.GothamBold
utilitiesSection.Text = "🔧 UTILITIES"
utilitiesSection.TextColor3 = Color3.fromRGB(255, 200, 100)
utilitiesSection.TextSize = 14
utilitiesSection.TextXAlignment = Enum.TextXAlignment.Left
utilitiesSection.Parent = scroll

makeButton("Reset Character", "Respawn fix", function()
	local root = getRoot()
	if root then
		root.CFrame = root.CFrame + Vector3.new(0, 3, 0)
	end
end)

makeButton("Clear All", "Disable all hacks", function()
	state.flight = false
	state.infiniteJump = false
	state.noClip = false
	state.godMode = false
	state.glow = false
	state.esp = false
	state.aim = false
	
	if aimConnection then
		aimConnection:Disconnect()
	end
	
	local hum = getHumanoid()
	local root = getRoot()
	local character = getCharacter()
	
	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		hum.MaxHealth = 100
		hum.Health = 100
	end
	
	if root and root:FindFirstChild("HackFlightVelocity") then
		root.HackFlightVelocity:Destroy()
	end
	
	if character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
				part.Material = Enum.Material.SmoothPlastic
			end
		end
	end
	
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer.Character then
			local head = otherPlayer.Character:FindFirstChild("Head")
			if head then
				local billboard = head:FindFirstChild("ESPBillboard")
				if billboard then
					billboard:Destroy()
				end
			end
		end
	end
end)

makeButton("Close Menu", "Hide menu", function()
	menuOpen = false
	menu.Visible = false
end)

-- ===== MENU TOGGLE =====
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == MENU_KEY then
		menuOpen = not menuOpen
		menu.Visible = menuOpen
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	menuOpen = false
	menu.Visible = false
end)

-- ===== RESPAWN HANDLING =====
player.CharacterAdded:Connect(function(character)
	task.wait(0.2)
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = state.walkSpeed
		hum.JumpPower = state.jumpPower
	end
end)

print("✅ Hack Menu v2 loaded - Press RightShift to toggle")
print("🎯 Features: Aim Bot | Enhanced ESP | Flight | God Mode + More")
