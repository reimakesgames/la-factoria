local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Components = require(Shared.components)
local ItemModel = Components.ItemModel
local ItemConveyorPosition = Components.ItemConveyorPosition
local BuildingModel = Components.BuildingModel
local ConveyorBelt = Components.ConveyorBelt

local function isClose(a, b)
	-- a is our item's position
	-- b is the conveyor's position

	-- check if the x and y are close enough by checking if they are within a range of -2, 2
	-- this is because the conveyor is 4 studs wide, and the item is a stud wide
	-- so we need to check if the item is within 2 studs of the conveyor

	return math.abs(a.X - b.X) <= 2 and math.abs(a.Y - b.Y) <= 2
end

local function conveyorItemsMove(world)
	-- iterate on all conveyors and find items on them
	-- since items are in a -2, 2 range of the conveyor, we can just check the x and y of the conveyor
	-- and use that to find the items

	local itemIds, itemModels, itemPositions = {}, {}, {}
	for id, itemModel, itemPos in world:query(ItemModel, ItemConveyorPosition) do
		table.insert(itemIds, id)
		table.insert(itemModels, itemModel)
		table.insert(itemPositions, itemPos)
	end
	-- move queue to avoid moving items twice
	local moveQueue = {}

	for id, buildingModel, conveyorBelt in world:query(BuildingModel, ConveyorBelt) do
		local conveyorPos = conveyorBelt.position
		local conveyorDir = conveyorBelt.direction

		for i, itemId in itemIds do
			local itemPos = itemPositions[i]

			if isClose(itemPos.position, conveyorPos) then
				-- move item
				local newPos = itemPos.position + ((conveyorDir * 4) / 60)
				table.insert(moveQueue, {
					index = i,
					newPos = newPos
				})
			end
		end
	end

	for _, move in moveQueue do
		local index = move.index
		local newPos = move.newPos

		local itemModel = itemModels[index]
		local itemPos = itemPositions[index]

		world:insert(itemIds[index], itemPos:patch({
			position = newPos
		}))
		itemModel.model:PivotTo(CFrame.new(newPos.X, 0.6, newPos.Y))
	end
end

return conveyorItemsMove
