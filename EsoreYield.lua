local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local PREFIX = ":"
local TOGGLE_KEY = Enum.KeyCode.RightControl
local GITHUB_COMMANDS_URL = "https://raw.githubusercontent.com/Esoreoneer/EsoreYield/refs/heads/main/EsoreYield.lua"

local Flying = false
local FlySpeed = 50
local Noclip = false
local NoclipConnection = nil
local ESPActive = false
local ESPHighlights = {}
local InfJump = false

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
screenGui.Name = "UltraLocalAdminGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 380)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 55, 75)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✨ APEX LOCAL ADMIN"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local minButton = Instance.new("TextButton")
minButton.Name = "MinButton"
minButton.Size = UDim2.new(0, 28, 0, 28)
minButton.Position = UDim2.new(1, -36, 0, 7)
minButton.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
minButton.Text = "—"
minButton.TextColor3 = Color3.fromRGB(200, 210, 230)
minButton.TextSize = 12
minButton.Font = Enum.Font.GothamBold
minButton.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minButton

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -28, 0, 32)
tabBar.Position = UDim2.new(0, 14, 0, 50)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 8)
tabLayout.Parent = tabBar

local pagesFolder = Instance.new("Frame")
pagesFolder.Name = "Pages"
pagesFolder.Size = UDim2.new(1, -28, 1, -148)
pagesFolder.Position = UDim2.new(0, 14, 0, 90)
pagesFolder.BackgroundTransparency = 1
pagesFolder.Parent = mainFrame

local consolePage = Instance.new("ScrollingFrame")
consolePage.Name = "ConsolePage"
consolePage.Size = UDim2.new(1, 0, 1, 0)
consolePage.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
consolePage.BorderSizePixel = 0
consolePage.CanvasSize = UDim2.new(0, 0, 0, 0)
consolePage.ScrollBarThickness = 3
consolePage.AutomaticCanvasSize = Enum.AutomaticSize.Y
consolePage.Visible = true
consolePage.Parent = pagesFolder

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 4)
logLayout.Parent = consolePage

local logPadding = Instance.new("UIPadding")
logPadding.PaddingLeft = UDim.new(0, 10)
logPadding.PaddingRight = UDim.new(0, 10)
logPadding.PaddingTop = UDim.new(0, 8)
logPadding.PaddingBottom = UDim.new(0, 8)
logPadding.Parent = consolePage

local cmdGridPage = Instance.new("Frame")
cmdGridPage.Name = "CmdGridPage"
cmdGridPage.Size = UDim2.new(1, 0, 1, 0)
cmdGridPage.BackgroundTransparency = 1
cmdGridPage.Visible = false
cmdGridPage.Parent = pagesFolder

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, 0, 0, 28)
searchBox.Position = UDim2.new(0, 0, 0, 0)
searchBox.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
searchBox.PlaceholderText = "🔍 Search commands..."
searchBox.PlaceholderColor3 = Color3.fromRGB(100, 115, 140)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 12
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.Parent = cmdGridPage

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

local cmdScroll = Instance.new("ScrollingFrame")
cmdScroll.Name = "CmdScroll"
cmdScroll.Size = UDim2.new(1, 0, 1, -34)
cmdScroll.Position = UDim2.new(0, 0, 0, 34)
cmdScroll.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
cmdScroll.BorderSizePixel = 0
cmdScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
cmdScroll.ScrollBarThickness = 3
cmdScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
cmdScroll.Parent = cmdGridPage

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 116, 0, 32)
gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
gridLayout.Parent = cmdScroll

local gridPadding = Instance.new("UIPadding")
gridPadding.PaddingLeft = UDim.new(0, 8)
gridPadding.PaddingTop = UDim.new(0, 8)
gridPadding.Parent = cmdScroll

local settingsPage = Instance.new("Frame")
settingsPage.Name = "SettingsPage"
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
settingsPage.BorderSizePixel = 0
settingsPage.Visible = false
settingsPage.Parent = pagesFolder

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 8)
settingsCorner.Parent = settingsPage

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1, -20, 0, 30)
keybindLabel.Position = UDim2.new(0, 10, 0, 10)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Toggle Menu Keybind:  [ RightControl ]"
keybindLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
keybindLabel.TextSize = 13
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = settingsPage

local destroyBtn = Instance.new("TextButton")
destroyBtn.Size = UDim2.new(0, 160, 0, 32)
destroyBtn.Position = UDim2.new(0, 10, 0, 50)
destroyBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
destroyBtn.Text = "🗑️ Destroy Admin UI"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.TextSize = 12
destroyBtn.Parent = settingsPage

local dCorner = Instance.new("UICorner")
dCorner.CornerRadius = UDim.new(0, 6)
dCorner.Parent = destroyBtn

destroyBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local activeTab = nil
local function createTab(name, targetPage)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 110, 1, 0)
	btn.BackgroundColor3 = targetPage.Visible and Color3.fromRGB(35, 45, 65) or Color3.fromRGB(20, 25, 36)
	btn.Text = name
	btn.TextColor3 = targetPage.Visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 165, 190)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = tabBar

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		for _, page in ipairs(pagesFolder:GetChildren()) do page.Visible = false end
		for _, tab in ipairs(tabBar:GetChildren()) do
			if tab:IsA("TextButton") then
				tab.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
				tab.TextColor3 = Color3.fromRGB(150, 165, 190)
			end
		end
		targetPage.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
end

createTab("Console", consolePage)
createTab("Commands", cmdGridPage)
createTab("Settings", settingsPage)

local cmdBarFrame = Instance.new("Frame")
cmdBarFrame.Name = "CmdBarFrame"
cmdBarFrame.Size = UDim2.new(1, -28, 0, 38)
cmdBarFrame.Position = UDim2.new(0, 14, 1, -48)
cmdBarFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 36)
cmdBarFrame.BorderSizePixel = 0
cmdBarFrame.Parent = mainFrame

local cmdBarCorner = Instance.new("UICorner")
cmdBarCorner.CornerRadius = UDim.new(0, 8)
cmdBarCorner.Parent = cmdBarFrame

local cmdBarStroke = Instance.new("UIStroke")
cmdBarStroke.Color = Color3.fromRGB(45, 55, 75)
cmdBarStroke.Thickness = 1
cmdBarStroke.Parent = cmdBarFrame

local cmdBox = Instance.new("TextBox")
cmdBox.Name = "CmdBox"
cmdBox.Size = UDim2.new(1, -20, 1, 0)
cmdBox.Position = UDim2.new(0, 10, 0, 0)
cmdBox.BackgroundTransparency = 1
cmdBox.PlaceholderText = "Type command here or click from Commands tab..."
cmdBox.PlaceholderColor3 = Color3.fromRGB(100, 115, 140)
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
		mainFrame:TweenSize(UDim2.new(0, 520, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
		minButton.Text = "+"
	else
		mainFrame:TweenSize(UDim2.new(0, 520, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
		minButton.Text = "—"
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == TOGGLE_KEY then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

local function addLog(msg, color)
	color = color or Color3.fromRGB(200, 210, 230)
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

local function rebuildCmdButtons(filterText)
	filterText = string.lower(filterText or "")
	for _, child in ipairs(cmdScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for name, _ in pairs(Commands) do
		if filterText == "" or string.find(string.lower(name), filterText) then
			local btn = Instance.new("TextButton")
			btn.Text = ":" .. name
			btn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
			btn.TextColor3 = Color3.fromRGB(220, 230, 255)
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 11
			btn.Parent = cmdScroll

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 6)
			bCorner.Parent = btn

			local bStroke = Instance.new("UIStroke")
			bStroke.Color = Color3.fromRGB(40, 50, 70)
			bStroke.Thickness = 1
			bStroke.Parent = btn

			btn.MouseButton1Click:Connect(function()
				cmdBox.Text = ":" .. name .. " "
				cmdBox:CaptureFocus()
			end)
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	rebuildCmdButtons(searchBox.Text)
end)

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

Commands["btools"] = function()
	for _, id in ipairs({Enum.BinType.Grab, Enum.BinType.Clone, Enum.BinType.Hammer}) do
		local bin = Instance.new("HopperBin")
		bin.BinType = id
		bin.Parent = LocalPlayer.Backpack
	end
	addLog("BTools added.", Color3.fromRGB(100, 255, 100))
end

Commands["rejoin"] = function()
	addLog("Rejoining server...", Color3.fromRGB(255, 255, 100))
	game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end

local function loadGithubCommands()
	addLog("Fetching commands from GitHub...", Color3.fromRGB(130, 170, 255))
	local success, response = pcall(function() return game:HttpGet(GITHUB_COMMANDS_URL) end)
	if success and response then
		local func, err = loadstring(response)
		if func then
			local remoteCmds = func()
			if type(remoteCmds) == "table" then
				for cmdName, cmdFunc in pairs(remoteCmds) do
					Commands[string.lower(cmdName)] = cmdFunc
				end
				addLog("GitHub commands synchronized successfully!", Color3.fromRGB(100, 255, 100))
			end
		else
			addLog("Parse error from GitHub: " .. tostring(err), Color3.fromRGB(255, 100, 100))
		end
	else
		addLog("Could not connect to GitHub. Built-in commands loaded.", Color3.fromRGB(255, 150, 100))
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

addLog("Apex Admin System ready.", Color3.fromRGB(255, 255, 255))
addLog("Press 'RightControl' to toggle UI visibility.", Color3.fromRGB(170, 200, 255))
loadGithubCommands()
