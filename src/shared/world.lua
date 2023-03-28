local util = require(script.Parent.util)

local buildings = {}

local CurrentUniqueBuildingId = 0

local world = {
	map = {}
}

export type Chunk = {
	[number]: number -- unique building id
}

function world:GetChunk(chunkX, chunkY): Chunk?
	if self.map[chunkX] then
		return self.map[chunkX][chunkY]
	end
	return nil
end

function world:NewChunk(chunkX, chunkY): Chunk
	local chunk = self:GetChunk(chunkX, chunkY)
	if chunk then
		warn(`Chunk at {chunkX}, {chunkY} already exists.}`)
		return chunk
	end

	if not self.map[chunkX] then
		self.map[chunkX] = {}
	end
	self.map[chunkX][chunkY] = {}
	return self.map[chunkX][chunkY]
end

function world:NewTile(worldTileX, worldTileY, class, parameters)
	local chunkX, chunkY, localTile = util:GetChunkAndLocalTileFromXY(worldTileX, worldTileY)
	local chunk = self:GetChunk(chunkX, chunkY)
	if not chunk then
		self:NewChunk(chunkX, chunkY)
		chunk = self:GetChunk(chunkX, chunkY)
	end
	local building = require(class).new(parameters)
	buildings[CurrentUniqueBuildingId] = building
	building.UniqueBuildingId = CurrentUniqueBuildingId
	chunk[localTile] = CurrentUniqueBuildingId
	CurrentUniqueBuildingId = CurrentUniqueBuildingId + 1
end

function world:GetBuilding(uniqueBuildingId)
	return buildings[uniqueBuildingId]
end

--[[
	This function will return the building at the tile position.
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

return world
