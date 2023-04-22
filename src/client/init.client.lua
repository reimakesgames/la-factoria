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
	print(map)
	local _, e = pcall(function()
		for _, chunk in map.worldMap[0] do
			for i = 1, CONSTANTS.TILES_PER_CHUNK ^ 2 do
				local tile = chunk[i]
				if not tile then
					continue
				end
				local display = Instance.new("Part")
				display.Anchored = true
				display.Transparency = 0.5
				display.Size = Vector3.new(4, 1, 4)
				display.Position = Vector3.new(
					((i - 1) % CONSTANTS.TILES_PER_CHUNK) * 4,
					0,
					math.floor((i - 1) / CONSTANTS.TILES_PER_CHUNK) * 4
				) + Vector3.new(2, 4, 2)
				display.Parent = folder
			end
		end
	end)
	print(e)
end
