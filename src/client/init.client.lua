local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Matter = require(Packages.matter)

local world = Matter.World.new()

local loop = Matter.Loop.new(world)

local systems = {}

for _, system in Shared.systems:GetChildren() do
	if system:IsA("ModuleScript") then
		print("Loading system", system.Name)
		table.insert(systems, require(system))
	end
end

print("Loaded systems", #systems)
loop:scheduleSystems(systems)
loop:begin({
	default = RunService.Heartbeat
})

local createItem = require(Shared.createItem)
local placeConveyorBelt = require(Shared.placeConveyorBelt)
placeConveyorBelt(world, Vector2.new(0, 0), Vector2.new(0, 1))
placeConveyorBelt(world, Vector2.new(0, 1), Vector2.new(0, 1))
placeConveyorBelt(world, Vector2.new(0, 2), Vector2.new(0, 1))
placeConveyorBelt(world, Vector2.new(0, 3), Vector2.new(0, 1))
placeConveyorBelt(world, Vector2.new(0, 4), Vector2.new(0, 1))

createItem(world)
task.wait(1)
createItem(world)
