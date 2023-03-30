local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Console = require(ReplicatedStorage.Shared.Console)
local EntityWithHealth = require(script.Parent.EntityWithHealth)
local wooden_chest = {}
wooden_chest.__index = wooden_chest
setmetatable(wooden_chest, EntityWithHealth)

function wooden_chest.new()
	Console:Print("Default", "wooden_chest.new()")
	local self = setmetatable({
		name = "Wooden Chest",
		type = "wooden_chest",

		max_health = 10,
		healing_per_tick = 0,

		hide_resistances = true,

		repair_sound = nil,
		repair_speed_modifier = 1,

		alert_when_damaged = true,
		create_ghost_on_death = false,
		loot = nil,
	}, wooden_chest)

	self:SetHealth(self.max_health)

	return self
end

return wooden_chest
