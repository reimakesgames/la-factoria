local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Item = require(ReplicatedStorage.Shared.Item)
local factorio_gear = {}
factorio_gear.__index = factorio_gear
setmetatable(factorio_gear, Item)

function factorio_gear.new(quantity)
	local self = setmetatable({
		ItemId = 0,
		Quantity = quantity,
		MaxQuantityInStack = 100,

		Sprite = "rbxassetid://10257203640",
	}, factorio_gear)

	return self
end

return factorio_gear
