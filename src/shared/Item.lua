export type Type = {
	ItemId: number,
	Quantity: number,
	MaxQuantityInStack: number,

	Placeable: boolean,
	AssociatedBuildingId: number,
	DamagedBuildings: {number},

	Consumable: boolean,
}

local Item = {} :: Type
Item.__index = Item

function Item.new()
	local self = setmetatable({
		ItemId = 0,
		Quantity = 0,
		MaxQuantityInStack = 0,

		Sprite = "",

		Placeable = false,
		AssociatedBuildingId = 0,
		DamagedBuildings = {},
		-- an array that contains health of picked up damaged buildings
		-- so if you were to place a building, it first places the lowest health in the array,
		-- then the next lowest, and so on. This is so that the player can't just pick up a
		-- damaged building and place it somewhere else to repair it.

		Consumable = false,
	}, Item)

	return self
end

return Item :: Type
