export type Type = {
	BuildingId: number,
	UniqueBuildingId: number,

	ChunkPosition: Vector2,
	Size: Vector2,
	Rotation: number,

	Health: number,
	MaxHealth: number,
}

local Building = {} :: Type
Building.__index = Building

-- _overrideUniqueBuildingId is used for loading buildings from datastore
-- so that they can be assigned the same UniqueBuildingId they had before
function Building.new()
	local self = setmetatable({
		BuildingId = 0, -- an 8-bit number that identifies this building's type
		UniqueBuildingId = 0, -- a 64-bit number that identifies this building's instance

		ChunkPosition = Vector2.new(0, 0), -- 0-31
		Size = Vector2.new(1, 1),
		Rotation = 0, -- 0-3

		Health = 100,
		MaxHealth = 100,

		ConnectedToCircuit = false,
		CircuitId = 0,
	}, Building)

	return self
end

-- creates a pointer to another building, to allow items like an assembler which
-- has a 3x3 size to only have a single UniqueBuildingId and a single entry in
-- the world table. This is used to prevent the assembler from being placed
-- 9 more times during map initialization, and to prevent the assembler from
-- being saved 9 times to datastore.
function Building.newPointer(originalBuilding: Type)
	return {
		Pointer = true, -- used to identify this as a pointer, and lets the game know that it shouldn't be saved to datastore
		UniqueBuildingId = originalBuilding.UniqueBuildingId,
	}
end

function Building:Damage(amount: number)
	self.Health = self.Health - amount
	if self.Health <= 0 then
		self:Destroy()
	end
end
function Building:Repair(amount: number)
	self.Health = self.Health + amount
	if self.Health > self.MaxHealth then
		self.Health = self.MaxHealth
	end
end
function Building:Destroy()
	setmetatable(self, nil)
	table.clear(self)
	-- TODO: remove associated data like storage, power, etc.
end

function Building:__eq(other: Type)
	return self.UniqueBuildingId == other.UniqueBuildingId
end
function Building:__tostring()
	return "Building " .. self.UniqueBuildingId .. " (" .. self.BuildingId .. ")"
end

return Building :: Type
