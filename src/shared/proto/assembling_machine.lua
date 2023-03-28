-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Console = require(ReplicatedStorage.Shared.Console)
-- local util = require(ReplicatedStorage.Shared.util)
local Building = require(script.Parent.Building)

local assembling_machine = {}
assembling_machine.__index = assembling_machine
setmetatable(assembling_machine, Building)

function assembling_machine.new()
	local self = setmetatable({
		input = {},
		output = {},
		recipe = nil,
		progress = 0,

		crafting_speed = 1,

		energy_usage = 0, -- per second (not per tick)
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = 0,
			drain = 0,
		},

		working = false
	}, assembling_machine)

	return self
end

function assembling_machine:Update()
	-- local usage = (self.energy_usage + self.energy_source.drain) / 60
	-- -- Console:Warn("Default", `Usage by second: {util:ToWatts(usage * 60)}`)
	-- self.progress += self.crafting_speed / 60
	-- if self.progress >= 0.5 then
	-- 	Console:Error("Default", `Finished with progress: {self.progress}`)
	-- 	self.progress = 0
	-- end
end

return assembling_machine
