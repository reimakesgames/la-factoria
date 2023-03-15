local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Assets = ReplicatedStorage.Assets

local iron_plate = Assets.world_items.iron_plate

local Components = require(Shared.components)
local ItemModel = Components.ItemModel
local ItemConveyorPosition = Components.ItemConveyorPosition

local function createItem(world)
	local model = iron_plate:Clone()
	model.PrimaryPart = model.root
	model.Parent = workspace

	world:spawn(
		ItemModel({
			model = model
		}),
		ItemConveyorPosition({
			position = Vector2.new(0, 0)
		})
	)
end

return createItem
