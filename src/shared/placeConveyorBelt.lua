local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Assets = ReplicatedStorage.Assets

local conveyor_1 = Assets.buildings.conveyor_1

local Components = require(Shared.components)
local BuildingModel = Components.BuildingModel
local ConveyorBelt = Components.ConveyorBelt

local function placeConveyorBelt(world, pos: Vector2, dir: Vector2)
	local model = conveyor_1:Clone()
	model.PrimaryPart = model.root
	model:PivotTo(CFrame.new(pos.X * 4, 0.25, pos.Y * 4) * CFrame.Angles(0, math.atan2(dir.X, dir.Y), 0))
	model.Parent = workspace

	world:spawn(
		BuildingModel({
			model = model
		}),
		ConveyorBelt({
			position = pos,
			direction = dir
		})
	)
end

return placeConveyorBelt
