local components = require(script.Parent.Parent.components)
local Health = components.Health

local function machinesWork(world)
	for id, health in world:query(Health) do
		local newHealth = health.health - 1
		if newHealth <= 0 then
			world:despawn(id)
			print("Entity", id, "died!")
			continue
		end
		world:insert(id, health:patch({
			health = newHealth,
		}))
	end
end

return machinesWork
