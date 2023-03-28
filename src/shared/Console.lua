local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local fastInstance = require(script.Parent.fastInstance)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local EMIT_TO_ROBLOX_CONSOLE = true

export type LogType = "Print" | "Warn" | "Error" | "Info"

export type ConsoleTab = {
	TabName: string
}

export type Console = {
	Tabs: { [string]: ConsoleTab },

	CreateTab: (self: Console, tabName: string) -> (),

	_Log: (self: Console, topic: string, message: string, logType: LogType) -> (),

	Print: (self: Console, topic: string, message: string) -> (),
	Warn: (self: Console, topic: string, message: string) -> (),
	Error: (self: Console, topic: string, message: string) -> (),
	Info: (self: Console, topic: string, message: string) -> (),
}

local consoleGui = fastInstance.new("ScreenGui", {
	Name = "Console",
	ResetOnSpawn = false,
	DisplayOrder = 1000,
	IgnoreGuiInset = true,
	AutoLocalize = false,
	Enabled = true,

	Parent = PlayerGui,
})

local ActiveConsole: Console
local ForceGoToNewLine = true

local tab = {}
tab.__index = tab

function tab.new(tabName: string)
	local self = setmetatable({
		TabName = tabName,
		TabInstance = fastInstance.new("ScrollingFrame", {
			Name = tabName,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -64, 1, -64),
			Position = UDim2.new(0, 32, 0, 32),
			BackgroundColor3 = Color3.fromRGB(31, 31, 31),

			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 4,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			VerticalScrollBarInset = Enum.ScrollBarInset.None,

			Parent = consoleGui,
		})
	}, tab)

	fastInstance.new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Parent = self.TabInstance,
	})

	self.TabInstance.ChildAdded:Connect(function()
		if ForceGoToNewLine then
			self.TabInstance.CanvasPosition = Vector2.new(0, 999_999_999_999)
		end
	end)

	return self
end

function tab:Log(message: string, logType: LogType)
	if EMIT_TO_ROBLOX_CONSOLE then
		print(self.TabName .. ": " .. message)
	end

	local logColor = Color3.fromRGB(255, 255, 255)
	if logType == "Warn" then
		logColor = Color3.fromRGB(255, 255, 0)
	elseif logType == "Error" then
		logColor = Color3.fromRGB(255, 0, 0)
	elseif logType == "Info" then
		logColor = Color3.fromRGB(0, 255, 255)
	end

	fastInstance.new("TextLabel", {
		Name = "Log",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Text = message,
		TextColor3 = logColor,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = self.TabInstance,
	})
end

local console = {}
console.__index = console

function console.new()
	if ActiveConsole then
		return ActiveConsole
	end

	local self = setmetatable({
		Tabs = {}
	}, console)

	ActiveConsole = self

	return self
end

function console.CreateTab(tabName: string)
	local newTab = tab.new(tabName)
	ActiveConsole.Tabs[tabName] = newTab
	newTab:Log(`Console: {tabName}`, "Info")
end

function console:_Log(topic: string, message: string, logType: LogType)
	local tab = ActiveConsole.Tabs[topic] or ActiveConsole.Tabs["Default"]
	if tab then
		tab:Log(message, logType)
	end
end

function console:Print(topic: string, message: string)
	ActiveConsole:_Log(topic, message, "Print")
end

function console:Warn(topic: string, message: string)
	ActiveConsole:_Log(topic, message, "Warn")
end

function console:Error(topic: string, message: string)
	ActiveConsole:_Log(topic, message, "Error")
end

function console:Info(topic: string, message: string)
	ActiveConsole:_Log(topic, message, "Info")
end

console.new()
console.CreateTab("Default")

UserInputService.InputBegan:Connect(function(inputObject)
	if inputObject.KeyCode == Enum.KeyCode.Backquote then
		consoleGui.Enabled = not consoleGui.Enabled
		ForceGoToNewLine = true
	end
end)

UserInputService.InputChanged:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		ForceGoToNewLine = false
	end
end)

return console
