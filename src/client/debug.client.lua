--!optimize 2

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local fpsCounter = Assets.fpsCounter:Clone()
fpsCounter.Parent = PlayerGui

local TimeFunction = RunService:IsRunning() and time or os.clock

local LastIteration
local Start
local FrameUpdateTable: { [number]: number? } = {}

local function HeartbeatUpdate()
	LastIteration = TimeFunction()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
	end

	FrameUpdateTable[1] = LastIteration
	local Framerate = math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start))
	local Over60Text = not (Framerate < 62) and "\nPlease limit your FPS to 60" or ""
	fpsCounter.fpsLabel.TextColor3 = Framerate < 56 and Color3.new(1, 0, 0) or Framerate < 62 and Color3.new(1, 1, 1) or Color3.new(1, 0.8, 0.7)
	fpsCounter.fpsLabel.Text = "FPS/UPS: " .. string.format("%02d", Framerate) .. Over60Text
end

Start = TimeFunction()
RunService.Heartbeat:Connect(HeartbeatUpdate)
