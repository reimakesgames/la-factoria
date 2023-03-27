local util = require(script.Parent.util)

local buildings = {}

local CurrentUniqueBuildingId = 0

local world = {
	map = {}
}

export type Chunk = {
	[number]: number -- unique building id
}

function world:GetChunk(x, y)
	if self.map[x] then
		return self.map[x][y]
	end
	return nil
end

function world:NewChunk(x, y)
	if self.map[x] then
		if self.map[x][y] then
			warn("Attempted to create Chunk at <" .. x .. ", " .. y .. ">, but it already exists!")
		end
	end

	if not self.map[x] then
		self.map[x] = {}
	end
	self.map[x][y] = {}
end

function world:NewTile(x, y, buildingClassModule, associatedModel)
	local chunkX, chunkY, localTile = util:GetChunkAndLocalTileFromXY(x, y)
	local chunk = self:GetChunk(chunkX, chunkY)
	if not chunk then
		self:NewChunk(chunkX, chunkY)
		chunk = self:GetChunk(chunkX, chunkY)
	end
	local building = require(buildingClassModule).new()
	building.Model = associatedModel
	buildings[CurrentUniqueBuildingId] = building
	building.UniqueBuildingId = CurrentUniqueBuildingId
	chunk[localTile] = CurrentUniqueBuildingId
	CurrentUniqueBuildingId = CurrentUniqueBuildingId + 1
	print("New tile created at <" .. x .. ", " .. y .. "> with building id " .. building.UniqueBuildingId)
end

function world:GetBuilding(uniqueBuildingId)
	return buildings[uniqueBuildingId]
end

--[[
	This function will return the building at the tile position.
	It requires the tile position.
]]
function world:GetTile(x, y)
	-- Index the chunk by doing (y * 32) + x + 1
	-- though get the chunk first

	local chunkX, chunkY, localTile = util:GetChunkAndLocalTileFromXY(x, y)
	local chunk = self:GetChunk(chunkX, chunkY)
	if chunk then
		return chunk[localTile]
	end
	return nil
end

function world:_LoadChunk(x, y, data)
	if self.map[x] then
		if self.map[x][y] then
			warn("Attempted to load Chunk at <" .. x .. ", " .. y .. ">, but it already exists!")
		end
	end

	-- TODO: load json table into chunk and load its tiles
end

function world:_SaveChunk(x, y)
	if not self.map[x] then
		warn("Attempted to save Chunk at <" .. x .. ", " .. y .. ">, but it doesn't exist!")
		return
	end
	if not self.map[x][y] then
		warn("Attempted to save Chunk at <" .. x .. ", " .. y .. ">, but it doesn't exist!")
		return
	end

	-- TODO: save chunk to json table and save it to datastore
end

return world
