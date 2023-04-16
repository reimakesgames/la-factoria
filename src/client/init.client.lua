local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages

local CONSTANTS = require(ReplicatedStorage.Shared.CONSTANTS)
local splitter = require(ReplicatedStorage.Shared.buildings.splitter)
local matter = require(Packages.matter)
local components = require(script.components)
local map = require(script.map)

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local world = matter.World.new()
local loop = matter.Loop.new(world)

local systems = {
	require(script.systems.addModel),
	require(script.systems.machinesWork),
}
loop:scheduleSystems(systems)
loop:begin({
	default = RunService.Heartbeat
})

local rotation = 0 -- 0 = 0, 1 = -90, 2 = -180, 3 = -270

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		splitter(world, Mouse.Hit, rotation)
		print("spawned")
	elseif input.KeyCode == Enum.KeyCode.R then
		rotation = (rotation + if input:IsModifierKeyDown(Enum.ModifierKey.Shift) then 1 else -1) % 4
	end
end)

local folder = Instance.new("Folder")
folder.Name = "preview"
folder.Parent = workspace
while true do
	task.wait(1)
	folder:ClearAllChildren()
	pcall(function()
		for y, stuff in map.jimmy[0] do
			for num, id in stuff do
				local x = num % CONSTANTS.TILES_PER_CHUNK
				local y = math.floor(num / CONSTANTS.TILES_PER_CHUNK)
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new(4, 1, 4)
				part.Position = Vector3.new(x * 4, 4, y * 4) + Vector3.new(2, 0, 2)
				part.Transparency = 0.5
				part.Parent = folder
			end
		end
	end)
end
