
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local TOOL_NAME = "SnowballToy"
local MIN_FORWARD_SPEED = 20
local MAX_FORWARD_SPEED = 120
local MIN_UPWARD_LIFT = 25
local MAX_UPWARD_LIFT = 25
local WINDUP_DELAY = 0.7
local RELOAD_TIME = 2.0
local COOLDOWN_TIME = 0.15

if _G.N4T_SnowballCleanup then
	pcall(_G.N4T_SnowballCleanup)
end

local runtimeConnections = {}
local tool

local function bind(connection)
	table.insert(runtimeConnections, connection)
	return connection
end

local function removeSnowballUI()
	local pGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not pGui then return end

	for _, obj in ipairs(pGui:GetDescendants()) do
		if obj.Name == "SnowballOnlyRow" or obj:GetAttribute("N4TSnowballOnlyRow") == true then
			pcall(function() obj:Destroy() end)
		end
	end

	for _, obj in ipairs(pGui:GetDescendants()) do
		if obj.Name == "SnowballSlot" or obj:GetAttribute("N4TSnowballSlot") == true then
			pcall(function() obj:Destroy() end)
		end
	end
end

local function removeSnowballWorldObjects()
	if LocalPlayer.Backpack then
		for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
			if item.Name == TOOL_NAME or item.Name == "SnowBallToy2020" then
				pcall(function() item:Destroy() end)
			end
		end
	end

	if LocalPlayer.Character then
		for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
			if item.Name == TOOL_NAME or item.Name == "SnowBallToy2020" then
				pcall(function() item:Destroy() end)
			end
		end
	end

	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name == "SnowballProjectile" or obj.Name == "SnowballImpact" then
			pcall(function() obj:Destroy() end)
		end
	end
end

local function cleanupSnowballRuntime()
	for _, connection in ipairs(runtimeConnections) do
		pcall(function()
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end)
	end

	table.clear(runtimeConnections)

	if tool then
		pcall(function() tool:Destroy() end)
	end

	removeSnowballWorldObjects()
	removeSnowballUI()

	if _G.N4T_SnowballCleanup == cleanupSnowballRuntime then
		_G.N4T_SnowballCleanup = nil
	end
end

_G.N4T_SnowballCleanup = cleanupSnowballRuntime
removeSnowballUI()

if LocalPlayer.Backpack then
	for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item.Name == TOOL_NAME or item.Name == "SnowBallToy2020" then
			item:Destroy()
		end
	end
end

if LocalPlayer.Character then
	for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
		if item.Name == TOOL_NAME or item.Name == "SnowBallToy2020" then
			item:Destroy()
		end
	end
end

for _, obj in ipairs(Workspace:GetChildren()) do
	if obj.Name == "SnowballProjectile" or obj.Name == "SnowballImpact" then
		obj:Destroy()
	end
end

local function getGameEmotesPage()
	local pGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not pGui then return nil end

	local crossPlatform = pGui:FindFirstChild("CrossPlatform")
	if not crossPlatform then return nil end

	local emotes = crossPlatform:FindFirstChild("Emotes") or crossPlatform:FindFirstChild("Emotes", true)
	if not emotes then return nil end

	local emoteWindow = emotes:FindFirstChild("EmoteWindow", true)
	if not emoteWindow then return nil end

	local emoteContainer = emoteWindow:FindFirstChild("EmoteContainer", true)
	if not emoteContainer then return nil end

	local emotePages = emoteContainer:FindFirstChild("EmotePages", true)
	if not emotePages then return nil end

	local gameEmotes = emotePages:FindFirstChild("Game Emotes")
	if gameEmotes and (gameEmotes:IsA("GuiObject") or gameEmotes:IsA("Folder")) then
		return gameEmotes
	end

	return nil
end

local gameEmotesPage = getGameEmotesPage()
if gameEmotesPage then
	for _, child in ipairs(gameEmotesPage:GetChildren()) do
		if child.Name == "SnowballRow" or child:FindFirstChild("SnowballSlot") then
			child:Destroy()
		end
	end
end

tool = Instance.new("Tool")
tool.Name = TOOL_NAME
tool.GripPos = Vector3.new(0.03, -0.24, -0.01)
tool.RequiresHandle = true
tool.TextureId = "rbxthumb://type=Asset&w=150&h=150&id=6123754554"

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Shape = Enum.PartType.Ball
handle.Size = Vector3.new(1, 1, 1)
handle.Material = Enum.Material.Sand
handle.Color = Color3.new(0.956863, 0.968627, 1)
handle.CanCollide = false
handle.Parent = tool

local p1 = Instance.new("ParticleEmitter")
p1.Name = "Effect1"
p1.Texture = "rbxassetid://2346141109"
p1.Enabled = false
p1.Rate = 20.0
p1.Speed = NumberRange.new(4.0, 4.0)
p1.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.1875),
	NumberSequenceKeypoint.new(0.726751, 0),
	NumberSequenceKeypoint.new(1, 0)
})
p1.Parent = handle

local p2 = Instance.new("ParticleEmitter")
p2.Name = "Effect2"
p2.Texture = "rbxassetid://1539332776"
p2.Enabled = false
p2.Rate = 10.0
p2.Speed = NumberRange.new(1.0, 1.0)
p2.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 2.0),
	NumberSequenceKeypoint.new(0.716258, 0.560748),
	NumberSequenceKeypoint.new(1, 0)
})
p2.Parent = handle

local throwAnim = Instance.new("Animation")
throwAnim.AnimationId = "rbxassetid://18324269091"

local debounce = false

local function isShiftlockActive()
	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		return true
	end

	local char = LocalPlayer.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root and Camera then
			local camLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
			local rootLook = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit

			if camLook:Dot(rootLook) > 0.95 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				return true
			end
		end
	end

	return false
end

local function getTargetPosition()
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		local camera = Workspace.CurrentCamera
		if camera then
			local viewportCenter = camera.ViewportSize / 2
			local unitRay = camera:ViewportPointToRay(viewportCenter.X, viewportCenter.Y)
			return unitRay.Origin + (unitRay.Direction * 1000)
		end
	end

	return Mouse.Hit.Position
end

bind(tool.Activated:Connect(function()
	if debounce then return end
	debounce = true

	local char = LocalPlayer.Character
	if not char then
		debounce = false
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if not hum or hum.Health <= 0 or not root then
		debounce = false
		return
	end

	local animator = hum:FindFirstChildOfClass("Animator") or hum
	local track = animator:LoadAnimation(throwAnim)
	track.Priority = Enum.AnimationPriority.Action4
	track:Play()

	task.wait(WINDUP_DELAY)

	if handle then
		handle.Transparency = 1
	end

	if char and char.Parent and hum and hum.Health > 0 and root and root.Parent then
		local targetPos = getTargetPosition()
		local aimOrigin = root.Position + Vector3.new(0, 1.5, 0)
		local rawDir = targetPos - aimOrigin
		local distance = rawDir.Magnitude

		local forwardSpeed, upwardLift

		if isShiftlockActive() then
			forwardSpeed = MAX_FORWARD_SPEED
			upwardLift = MAX_UPWARD_LIFT
		elseif tool.Parent == char then
			forwardSpeed = math.clamp(distance * 2.2, MIN_FORWARD_SPEED, MAX_FORWARD_SPEED)
			upwardLift = math.clamp(distance * 0.25, MIN_UPWARD_LIFT, MAX_UPWARD_LIFT)
		else
			forwardSpeed = MAX_FORWARD_SPEED
			upwardLift = MAX_UPWARD_LIFT
		end

		local flatDir = Vector3.new(rawDir.X, 0, rawDir.Z)

		if flatDir.Magnitude > 0.1 then
			flatDir = flatDir.Unit
		else
			flatDir = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
		end

		local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
		local spawnPos

		if tool.Parent == char and handle then
			spawnPos = handle.Position
		elseif rightHand then
			spawnPos = rightHand.Position
		else
			spawnPos = aimOrigin
		end

		local projectile = Instance.new("Part")
		projectile.Name = "SnowballProjectile"
		projectile.Shape = Enum.PartType.Ball
		projectile.Size = Vector3.new(1.00, 1.00, 1.00)
		projectile.Material = Enum.Material.Sand
		projectile.Color = Color3.new(0.956863, 0.968627, 1)
		projectile.CanCollide = false
		projectile.Anchored = false
		projectile.CFrame = CFrame.new(spawnPos, spawnPos + flatDir)
		projectile.Parent = Workspace
		projectile.AssemblyLinearVelocity = (flatDir * forwardSpeed) + Vector3.new(0, upwardLift, 0)

		local hitConn

		hitConn = bind(projectile.Touched:Connect(function(hit)
			if hit:IsDescendantOf(char) or hit.Name == "SnowballProjectile" then return end

			if hitConn then
				hitConn:Disconnect()
				hitConn = nil
			end

			local impact = Instance.new("Part")
			impact.Name = "SnowballImpact"
			impact.Size = Vector3.new(0.1, 0.1, 0.1)
			impact.Transparency = 1
			impact.Anchored = true
			impact.CanCollide = false
			impact.CFrame = projectile.CFrame
			impact.Parent = Workspace

			local b1 = p1:Clone()
			b1.SpreadAngle = Vector2.new(180, 180)
			b1.Lifetime = NumberRange.new(1.0, 1.0)
			b1.Parent = impact

			local b2 = p2:Clone()
			b2.SpreadAngle = Vector2.new(90, 90)
			b2.Lifetime = NumberRange.new(1.0, 1.0)
			b2.Parent = impact

			b1:Emit(10)
			b2:Emit(1)

			Debris:AddItem(impact, 1.0)
			projectile:Destroy()
		end))

		Debris:AddItem(projectile, 4)

		task.delay(4, function()
			if hitConn then
				hitConn:Disconnect()
				hitConn = nil
			end
		end)
	end

	task.wait(RELOAD_TIME)

	if handle then
		handle.Transparency = 0
	end

	task.wait(COOLDOWN_TIME)
	debounce = false
end))

local function isEmotesMenuOpen()
	local pGui = LocalPlayer:FindFirstChild("PlayerGui")
	if pGui then
		local crossPlatform = pGui:FindFirstChild("CrossPlatform")
		if crossPlatform then
			local emoteWindow = crossPlatform:FindFirstChild("EmoteWindow", true)
			if emoteWindow and emoteWindow:IsA("GuiObject") and emoteWindow.Visible then
				return true
			end
		end
	end

	return false
end

local function closeEmotesMenu()
	if VirtualInputManager then
		pcall(function()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
			task.wait(0.03)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
		end)
	end

	task.delay(0.05, function()
		local pGui = LocalPlayer:FindFirstChild("PlayerGui")
		if pGui then
			local crossPlatform = pGui:FindFirstChild("CrossPlatform")
			if crossPlatform then
				local emoteWindow = crossPlatform:FindFirstChild("EmoteWindow", true)
				if emoteWindow and emoteWindow:IsA("GuiObject") then
					emoteWindow.Visible = false
				end
			end
		end
	end)
end

local function equipSnowballAndCloseMenu()
	if not LocalPlayer.Backpack then return end

	if tool.Parent ~= LocalPlayer.Backpack and tool.Parent ~= LocalPlayer.Character then
		tool.Parent = LocalPlayer.Backpack
	end

	if LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:EquipTool(tool)
		end
	end

	closeEmotesMenu()
end

local snowballSlotNumber = 1
local snowballHotkey = Enum.KeyCode.One
local snowballKeypadHotkey = Enum.KeyCode.KeypadOne

local function setSnowballHotkey(slotNumber)
	snowballSlotNumber = math.clamp(tonumber(slotNumber) or 1, 1, 4)

	local normalKeys = {
		[1] = Enum.KeyCode.One,
		[2] = Enum.KeyCode.Two,
		[3] = Enum.KeyCode.Three,
		[4] = Enum.KeyCode.Four,
	}

	local keypadKeys = {
		[1] = Enum.KeyCode.KeypadOne,
		[2] = Enum.KeyCode.KeypadTwo,
		[3] = Enum.KeyCode.KeypadThree,
		[4] = Enum.KeyCode.KeypadFour,
	}

	snowballHotkey = normalKeys[snowballSlotNumber]
	snowballKeypadHotkey = keypadKeys[snowballSlotNumber]
end

bind(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == snowballHotkey or input.KeyCode == snowballKeypadHotkey then
		if isEmotesMenuOpen() then
			equipSnowballAndCloseMenu()
		end
	end
end))

local MAX_SLOTS_PER_ROW = 4

local function getRows(page)
	local rows = {}

	for _, child in ipairs(page:GetChildren()) do
		if child:IsA("GuiObject") then
			local isRow = child.Name:match("^Row%d+$") ~= nil

			if not isRow then
				for _, slot in ipairs(child:GetChildren()) do
					if slot:IsA("GuiObject") and slot.Name:match("^Emote%d+$") then
						isRow = true
						break
					end
				end
			end

			if isRow then
				table.insert(rows, child)
			end
		end
	end

	table.sort(rows, function(a, b)
		local aNum = tonumber(a.Name:match("^Row(%d+)$"))
		local bNum = tonumber(b.Name:match("^Row(%d+)$"))

		if aNum and bNum and aNum ~= bNum then
			return aNum < bNum
		end

		if a.LayoutOrder ~= b.LayoutOrder then
			return a.LayoutOrder < b.LayoutOrder
		end

		return a.Name < b.Name
	end)

	return rows
end

local function getRowSlots(row)
	local slots = {}

	for _, child in ipairs(row:GetChildren()) do
		if child:IsA("GuiObject") then
			local index = tonumber(child.Name:match("^Emote(%d+)$"))

			if index and index >= 1 and index <= MAX_SLOTS_PER_ROW then
				table.insert(slots, {
					object = child,
					index = index,
					used = child.Visible ~= false,
				})
			end
		end
	end

	table.sort(slots, function(a, b)
		return a.index < b.index
	end)

	return slots
end

local function findFirstFreeSlot(row)
	local used = {}
	local slots = getRowSlots(row)

	for _, info in ipairs(slots) do
		if info.used then
			used[info.index] = true
		end
	end

	for index = 1, MAX_SLOTS_PER_ROW do
		if not used[index] then
			return index, slots
		end
	end

	return nil, slots
end

local function findTemplateSlot(row, wantedIndex, slots)
	for _, info in ipairs(slots) do
		if info.index == wantedIndex then
			return info.object
		end
	end

	for i = #slots, 1, -1 do
		if slots[i].object and slots[i].object.Parent then
			return slots[i].object
		end
	end

	return nil
end

local function styleSnowballSlot(snowballSlot, slotNumber)
	snowballSlot.Name = "SnowballSlot"
	snowballSlot:SetAttribute("N4TSnowballSlot", true)
	snowballSlot:SetAttribute("N4TSlotNumber", slotNumber)

	if snowballSlot:IsA("GuiObject") then
		snowballSlot.Visible = true
		snowballSlot.LayoutOrder = slotNumber
	end

	setSnowballHotkey(slotNumber)

	for _, desc in ipairs(snowballSlot:GetDescendants()) do
		if desc:IsA("TextLabel") then
			local clean = desc.Text:gsub("<.->", ""):gsub("[%s%.]+", "")
			local num = tonumber(clean)

			if num and num >= 0 and num <= 10 then
				desc.RichText = true
				desc.Text = '<font color="#FFFFFF">' .. tostring(slotNumber) .. '</font>'
			end
		end
	end

	local nameLabel = snowballSlot:FindFirstChild("EmoteName")
		or snowballSlot:FindFirstChild("Title")
		or snowballSlot:FindFirstChild("Name")

	if not nameLabel then
		for _, desc in ipairs(snowballSlot:GetDescendants()) do
			if desc:IsA("TextLabel") then
				local clean = desc.Text:gsub("<.->", ""):gsub("[%s%.]+", "")

				if clean ~= "" and tonumber(clean) == nil then
					nameLabel = desc
					break
				end
			end
		end
	end

	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = "Snowball"
	end

	local iconLabel = snowballSlot:FindFirstChildWhichIsA("ImageLabel", true)
		or snowballSlot:FindFirstChildWhichIsA("ImageButton", true)

	if iconLabel then
		iconLabel.Image = "rbxthumb://type=Asset&w=150&h=150&id=6123754554"
	end

	local connectedButtons = {}

	local function connectButton(button)
		if connectedButtons[button] then return end
		connectedButtons[button] = true
		bind(button.MouseButton1Click:Connect(equipSnowballAndCloseMenu))
	end

	if snowballSlot:IsA("GuiButton") then
		connectButton(snowballSlot)
	end

	for _, btn in ipairs(snowballSlot:GetDescendants()) do
		if btn:IsA("GuiButton") then
			connectButton(btn)
		end
	end
end

local function removeDuplicateSnowballs(page)
	local found = {}

	for _, obj in ipairs(page:GetDescendants()) do
		if obj.Name == "SnowballSlot" or obj:GetAttribute("N4TSnowballSlot") == true then
			table.insert(found, obj)
		end
	end

	local keeper = found[1]

	if #found > 1 then
		for i = 2, #found do
			pcall(function() found[i]:Destroy() end)
		end
	end

	for _, obj in ipairs(page:GetDescendants()) do
		if obj.Name == "SnowballOnlyRow" or obj:GetAttribute("N4TSnowballOnlyRow") == true then
			local keepThisRow = keeper and keeper.Parent and keeper:IsDescendantOf(obj)

			if not keepThisRow then
				pcall(function() obj:Destroy() end)
			end
		end
	end

	return keeper
end

local function injectIntoGameEmotes()
	local page = getGameEmotesPage()

	if not page then
		warn("[Snowball System] Game Emotes page folder not found.")
		return false
	end

	local existingSnowball = removeDuplicateSnowballs(page)

	if existingSnowball and existingSnowball.Parent then
		local existingNumber = existingSnowball:GetAttribute("N4TSlotNumber")

		if existingNumber then
			setSnowballHotkey(existingNumber)
		end

		return true
	end

	local rows = getRows(page)

	if #rows == 0 then
		warn("[Snowball System] No existing row found to use as template.")
		return false
	end

	local targetRow
	local freeIndex
	local rowSlots

	for _, row in ipairs(rows) do
		local index, slots = findFirstFreeSlot(row)

		if index then
			targetRow = row
			freeIndex = index
			rowSlots = slots
			break
		end
	end

	if targetRow and freeIndex then
		local template = findTemplateSlot(targetRow, freeIndex, rowSlots)

		if not template then
			warn("[Snowball System] No slot template found in target row.")
			return false
		end

		local snowballSlot = template:Clone()
		styleSnowballSlot(snowballSlot, freeIndex)
		snowballSlot.Parent = targetRow

		print("[Snowball System] Snowball inserted once in existing row at slot " .. tostring(freeIndex) .. ".")
		return true
	end

	local sourceRow = rows[#rows]
	local sourceSlots = getRowSlots(sourceRow)

	if #sourceSlots == 0 then
		warn("[Snowball System] Last row has no slot template.")
		return false
	end

	local newRow = sourceRow:Clone()
	newRow.Name = "SnowballOnlyRow"
	newRow:SetAttribute("N4TSnowballOnlyRow", true)
	newRow.Visible = true
	newRow.LayoutOrder = sourceRow.LayoutOrder + 1

	local templateSlot

	for _, child in ipairs(newRow:GetChildren()) do
		if child:IsA("GuiObject") and child.Name:match("^Emote%d+$") then
			if not templateSlot then
				templateSlot = child
			else
				child:Destroy()
			end
		end
	end

	if not templateSlot then
		newRow:Destroy()
		warn("[Snowball System] Could not build Snowball-only row.")
		return false
	end

	styleSnowballSlot(templateSlot, 1)
	newRow.Parent = page

	print("[Snowball System] Existing rows were full; created one Snowball-only row.")
	return true
end

local function ensureSnowballInjected()
	local page = getGameEmotesPage()

	if page then
		local existing = removeDuplicateSnowballs(page)

		if existing and existing.Parent then
			local slotNumber = existing:GetAttribute("N4TSlotNumber")

			if slotNumber then
				setSnowballHotkey(slotNumber)
			end

			return true
		end
	end

	return injectIntoGameEmotes()
end

task.spawn(function()
	for _ = 1, 20 do
		if ensureSnowballInjected() then
			break
		end

		task.wait(0.5)
	end
end)

bind(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.T then
		task.spawn(function()
			for _, delayTime in ipairs({0.10, 0.25, 0.50, 1.00}) do
				task.wait(delayTime)

				if ensureSnowballInjected() then
					break
				end
			end
		end)
	end
end))
