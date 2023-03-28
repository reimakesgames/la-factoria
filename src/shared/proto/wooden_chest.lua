local ReplicatedStorage = game:GetService("ReplicatedStorage")
local factorio_gear = require(ReplicatedStorage.Shared.items.factorio_gear)
local container = require(script.Parent.container)

local wooden_chest = {} :: container.Type
wooden_chest.__index = wooden_chest
setmetatable(wooden_chest, container)

function wooden_chest.new()
	local self = setmetatable({
		Name = "Wooden Chest",

		InventorySize = 16,

		Items = {
			factorio_gear.new(1),
			factorio_gear.new(10),
			factorio_gear.new(95),
			factorio_gear.new(10),
			factorio_gear.new(10),
		},

		Health = 100,
		MaxHealth = 100,
	}, wooden_chest)

	return self
end

return wooden_chest :: container.Type
