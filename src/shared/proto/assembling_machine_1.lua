local assembling_machine = require(script.Parent.assembling_machine)

local assembling_machine_1 = {}
assembling_machine_1.__index = assembling_machine_1
setmetatable(assembling_machine_1, assembling_machine)

function assembling_machine_1.new()
	local self = setmetatable({

	}, assembling_machine_1)

	self.energy_usage = 75_000 -- watts
	self.energy_source.drain = 2_500 -- watts

	return self
end

return assembling_machine_1
