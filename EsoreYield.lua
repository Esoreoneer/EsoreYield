local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local PREFIX = ":"
local TOGGLE_KEY = Enum.KeyCode.RightControl
local GITHUB_COMMANDS_URL = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/commands.lua"

local Flying = false
local FlySpeed = 50
local Noclip = false
local NoclipConnection = nil
local ESPActive = false
local ESPHighlights = {}
local InfJump = false
local GodMode = false
local OriginalSpectateCam = workspace.CurrentCamera.CameraSubject

local function getPlayers(targetStr)
	targetStr = string.lower(targetStr or "")
	local targets = {}
	if targetStr == "@me" or targetStr == "" then
		table.insert(targets, LocalPlayer)
	elseif targetStr == "@all" then
		for _, p in ipairs(Players:GetPlayers()) do table.insert(targets, p) end
	elseif targetStr == "@others" then
		for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(targets, p) end end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if string.sub(string.lower(p.Name), 1, #targetStr) == targetStr or string.sub(string.lower(p.DisplayName), 1, #targetStr) == targetStr then
				table.insert(targets, p)
			end
		end
	end
	return targets
end

local function makeDraggable(frame, handleFrame)
	handleFrame = handleFrame or frame
	local dragging, dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	handleFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	handleFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

local parentGui
pcall(function() parentGui = CoreGui end)
if not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProLocalAdminGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 480, 0, 360)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ PRO LOCAL ADMIN V2"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local minButton = Instance.new("TextButton")
minButton.Name = "MinButton"
minButton.Size = UDim2.new(0, 28, 0, 28)
minButton.Position = UDim2.new(1, -36, 0, 6)
minButton.BackgroundColor3 = Color3.fromRGB(36, 36, 50)
minButton.Text = "-"
minButton.TextColor3 = Color3.fromRGB(220, 220, 240)
minButton.TextSize = 16
minButton.Font = Enum.Font.GothamBold
minButton.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minButton

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -24, 0, 30)
tabBar.Position = UDim2.new(0, 12, 0, 46)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

local pagesFolder = Instance.new("Frame")
pagesFolder.Name = "Pages"
pagesFolder.Size = UDim2.new(1, -24, 1, -132)
pagesFolder.Position = UDim2.new(0, 12, 0, 82)
pagesFolder.BackgroundTransparency = 1
pagesFolder.Parent = mainFrame

local consolePage = Instance.new("ScrollingFrame")
consolePage.Name = "ConsolePage"
consolePage.Size = UDim2.new(1, 0, 1, 0)
consolePage.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
consolePage.BorderSizePixel = 0
consolePage.CanvasSize = UDim2.new(0, 0, 0, 0)
consolePage.ScrollBarThickness = 4
consolePage.AutomaticCanvasSize = Enum.AutomaticSize.Y
consolePage.Visible = true
consolePage.Parent = pagesFolder

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 4)
logLayout.Parent = consolePage

local logPadding = Instance.new("UIPadding")
logPadding.PaddingLeft = UDim.new(0, 8)
logPadding.PaddingRight = UDim.new(0, 8)
logPadding.PaddingTop = UDim.new(0, 6)
logPadding.PaddingBottom = UDim.new(0, 6)
logPadding.Parent = consolePage

local cmdGridPage = Instance.new("ScrollingFrame")
cmdGridPage.Name = "CmdGridPage"
cmdGridPage.Size = UDim2.new(1, 0, 1, 0)
cmdGridPage.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
cmdGridPage.BorderSizePixel = 0
cmdGridPage.CanvasSize = UDim2.new(0, 0, 0, 0)
cmdGridPage.ScrollBarThickness = 4
cmdGridPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
cmdGridPage.Visible = false
cmdGridPage.Parent = pagesFolder

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 105, 0, 32)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.Parent = cmdGridPage

local gridPadding = Instance.new("UIPadding")
gridPadding.PaddingLeft = UDim.new(0, 8)
gridPadding.PaddingTop = UDim.new(0, 8)
gridPadding.Parent = cmdGridPage

local activeTabButton = nil
local function createTab(name, targetPage)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.BackgroundColor3 = targetPage.Visible and Color3.fromRGB(45, 45, 65) or Color3.fromRGB(26, 26, 36)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(240, 240, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.Parent = tabBar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	if targetPage.Visible then activeTabButton = btn end

	btn.MouseButton1Click:Connect(function()
		for _, page in ipairs(pagesFolder:GetChildren()) do page.Visible = false end
		for _, tab in ipairs(tabBar:GetChildren()) do
			if tab:IsA("TextButton") then tab.BackgroundColor3 = Color3.fromRGB(26, 26, 36) end
		end
		targetPage.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	end)
end

createTab("Console", consolePage)
createTab("Commands", cmdGridPage)

local cmdBarFrame = Instance.new("Frame")
cmdBarFrame.Name = "CmdBarFrame"
cmdBarFrame.Size = UDim2.new(1, -24, 0, 36)
cmdBarFrame.Position = UDim2.new(0, 12, 1, -44)
cmdBarFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
cmdBarFrame.BorderSizePixel = 0
cmdBarFrame.Parent = mainFrame

local cmdBarCorner = Instance.new("UICorner")
cmdBarCorner.CornerRadius = UDim.new(0, 6)
cmdBarCorner.Parent = cmdBarFrame

local cmdBox = Instance.new("TextBox")
cmdBox.Name = "CmdBox"
cmdBox.Size = UDim2.new(1, -16, 1, 0)
cmdBox.Position = UDim2.new(0, 10, 0, 0)
cmdBox.BackgroundTransparency = 1
cmdBox.PlaceholderText = "Type command or prefix '" .. PREFIX .. "' (Press RightControl to hide UI)..."
cmdBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
cmdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cmdBox.TextSize = 13
cmdBox.Font = Enum.Font.Gotham
cmdBox.TextXAlignment = Enum.TextXAlignment.Left
cmdBox.ClearTextOnFocus = false
cmdBox.Parent = cmdBarFrame

makeDraggable(mainFrame, header)

local isMinimized = false
minButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		mainFrame:TweenSize(UDim2.new(0, 480, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
		minButton.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 480, 0, 360), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
		minButton.Text = "-"
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == TOGGLE_KEY then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

local function addLog(msg, color)
	color = color or Color3.fromRGB(200, 200, 220)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Text = "[" .. os.date("%X") .. "] " .. tostring(msg)
	label.TextColor3 = color
	label.TextSize = 12
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Parent = consolePage
	consolePage.CanvasPosition = Vector2.new(0, 99999)
end

local Commands = {}

local function rebuildCmdButtons()
	for _, child in ipairs(cmdGridPage:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for name, _ in pairs(Commands) do
		local btn = Instance.new("TextButton")
		btn.Text = ":" .. name
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
		btn.TextColor3 = Color3.fromRGB(220, 220, 255)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 11
		btn.Parent = cmdGridPage

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btn

		btn.MouseButton1Click:Connect(function()
			cmdBox.Text = ":" .. name .. " "
			cmdBox:CaptureFocus()
		end)
	end
end

Commands["fly"] = function(args)
	FlySpeed = tonumber(args[1]) or 50
	if Flying then return end
	Flying = true
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart

	local bv = Instance.new("BodyVelocity")
	bv.Name = "AdminFlyVelocity"
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Parent = root

	local bg = Instance.new("BodyGyro")
	bg.Name = "AdminFlyGyro"
	bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bg.Parent = root

	task.spawn(function()
		while Flying and char and root and bv and bg do
			local cam = workspace.CurrentCamera
			local moveVector = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
			bv.Velocity = moveVector * FlySpeed
			bg.CFrame = cam.CFrame
			RunService.RenderStepped:Wait()
		end
		bv:Destroy()
		bg:Destroy()
	end)
	addLog("Fly enabled (Speed: " .. FlySpeed .. ")", Color3.fromRGB(100, 255, 100))
end

Commands["unfly"] = function()
	Flying = false
	addLog("Fly disabled.", Color3.fromRGB(255, 200, 100))
end

Commands["speed"] = function(args)
	local spd = tonumber(args[1]) or 16
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = spd
		addLog("WalkSpeed set to " .. spd, Color3.fromRGB(100, 255, 100))
	end
end

Commands["jump"] = function(args)
	local pwr = tonumber(args[1]) or 50
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = pwr
		addLog("JumpPower set to " .. pwr, Color3.fromRGB(100, 255, 100))
	end
end

Commands["infjump"] = function()
	InfJump = not InfJump
	if InfJump then
		addLog("Infinite Jump enabled.", Color3.fromRGB(100, 255, 100))
	else
		addLog("Infinite Jump disabled.", Color3.fromRGB(255, 200, 100))
	end
end

UserInputService.JumpRequest:Connect(function()
	if InfJump and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

Commands["noclip"] = function()
	if Noclip then return end
	Noclip = true
	NoclipConnection = RunService.Stepped:Connect(function()
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end)
	addLog("Noclip enabled.", Color3.fromRGB(100, 255, 100))
end

Commands["clip"] = function()
	if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
	Noclip = false
	addLog("Noclip disabled.", Color3.fromRGB(255, 200, 100))
end

Commands["god"] = function()
	GodMode = true
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.MaxHealth = math.huge
		hum.Health = math.huge
		addLog("Local Godmode enabled.", Color3.fromRGB(100, 255, 100))
	end
end

Commands["ungod"] = function()
	GodMode = false
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.MaxHealth = 100
		hum.Health = 100
		addLog("Local Godmode disabled.", Color3.fromRGB(255, 200, 100))
	end
end

Commands["tp"] = function(args)
	local targets = getPlayers(args[1])
	if #targets > 0 and targets[1].Character and targets[1].Character:FindFirstChild("HumanoidRootPart") then
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if myRoot then
			myRoot.CFrame = targets[1].Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
			addLog("Teleported to " .. targets[1].Name, Color3.fromRGB(100, 255, 100))
		end
	else
		addLog("Player not found for teleport.", Color3.fromRGB(255, 100, 100))
	end
end

Commands["view"] = function(args)
	local targets = getPlayers(args[1])
	if #targets > 0 and targets[1].Character and targets[1].Character:FindFirstChildOfClass("Humanoid") then
		workspace.CurrentCamera.CameraSubject = targets[1].Character:FindFirstChildOfClass("Humanoid")
		addLog("Viewing " .. targets[1].Name, Color3.fromRGB(100, 255, 100))
	end
end

Commands["unview"] = function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		addLog("Camera reset to local player.", Color3.fromRGB(100, 255, 100))
	end
end

Commands["btools"] = function()
	for _, id in ipairs({Enum.BinType.Grab, Enum.BinType.Clone, Enum.BinType.Hammer}) do
		local bin = Instance.new("HopperBin")
		bin.BinType = id
		bin.Parent = LocalPlayer.Backpack
	end
	addLog("BTools added.", Color3.fromRGB(100, 255, 100))
end

Commands["esp"] = function()
	ESPActive = true
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local hl = Instance.new("Highlight")
			hl.Name = "AdminESP"
			hl.FillColor = Color3.fromRGB(255, 50, 50)
			hl.Parent = player.Character
			ESPHighlights[player] = hl
		end
	end
	addLog("ESP enabled.", Color3.fromRGB(100, 255, 100))
end

Commands["unesp"] = function()
	ESPActive = false
	for _, hl in pairs(ESPHighlights) do if hl and hl.Parent then hl:Destroy() end end
	ESPHighlights = {}
	addLog("ESP disabled.", Color3.fromRGB(255, 200, 100))
end

Commands["rejoin"] = function()
	addLog("Rejoining server...", Color3.fromRGB(255, 255, 100))
	game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end

local function loadGithubCommands()
	addLog("Fetching commands from GitHub...", Color3.fromRGB(150, 150, 255))
	local success, response = pcall(function() return game:HttpGet(GITHUB_COMMANDS_URL) end)
	if success and response then
		local func, err = loadstring(response)
		if func then
			local remoteCmds = func()
			if type(remoteCmds) == "table" then
				for cmdName, cmdFunc in pairs(remoteCmds) do
					Commands[string.lower(cmdName)] = cmdFunc
				end
				addLog("GitHub commands loaded successfully!", Color3.fromRGB(100, 255, 100))
			end
		else
			addLog("Parse error from GitHub: " .. tostring(err), Color3.fromRGB(255, 100, 100))
		end
	else
		addLog("Could not connect to GitHub. Local commands ready.", Color3.fromRGB(255, 150, 100))
	end
	rebuildCmdButtons()
end

local function parseAndExecute(inputStr)
	inputStr = string.gsub(inputStr, "^%s*(.-)%s*$", "%1")
	if inputStr == "" then return end
	if string.sub(inputStr, 1, #PREFIX) == PREFIX then inputStr = string.sub(inputStr, #PREFIX + 1) end

	local args = {}
	for word in string.gmatch(inputStr, "%S+") do table.insert(args, word) end
	if #args == 0 then return end

	local cmdName = string.lower(table.remove(args, 1))
	local cmdFunc = Commands[cmdName]

	if cmdFunc then
		local ok, err = pcall(function() cmdFunc(args) end)
		if not ok then addLog("Error executing ':" .. cmdName .. "': " .. tostring(err), Color3.fromRGB(255, 100, 100)) end
	else
		addLog("Unknown command: '" .. cmdName .. "'", Color3.fromRGB(255, 180, 100))
	end
end

cmdBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local text = cmdBox.Text
		cmdBox.Text = ""
		parseAndExecute(text)
	end
end)

LocalPlayer.Chatted:Connect(function(msg)
	if string.sub(msg, 1, #PREFIX) == PREFIX then parseAndExecute(msg) end
end)

addLog("System initialized.", Color3.fromRGB(255, 255, 255))
addLog("Press 'RightControl' to toggle UI visibility.", Color3.fromRGB(180, 220, 255))
loadGithubCommands()
