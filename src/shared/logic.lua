local util = require(script.Parent.util)

local buildings = {}

local CurrentUniqueBuildingId = 0

local logic = {
	world = {}
}

export type Chunk = {
	[number]: number -- unique building id
}

function logic:GetChunk(x, y)
	if self.world[x] then
		return self.world[x][y]
	end
	return nil
end

function logic:NewChunk(x, y)
	if self.world[x] then
		if self.world[x][y] then
			warn("Attempted to create Chunk at <" .. x .. ", " .. y .. ">, but it already exists!")
		end
	end

	if not self.world[x] then
		self.world[x] = {}
	end
	self.world[x][y] = {}
end

function logic:NewTile(x, y, buildingClassModule, associatedModel)
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

function logic:GetBuilding(uniqueBuildingId)
	return buildings[uniqueBuildingId]
end

--[[
	This function will return the building at the tile position.
	It requires the tile position.
]]
function logic:GetTile(x, y)
	-- Index the chunk by doing (y * 32) + x + 1
	-- though get the chunk first

	local chunkX, chunkY, localTile = util:GetChunkAndLocalTileFromXY(x, y)
	local chunk = self:GetChunk(chunkX, chunkY)
	if chunk then
		return chunk[localTile]
	end
	return nil
end

function logic:_LoadChunk(x, y, data)
	if self.world[x] then
		if self.world[x][y] then
			warn("Attempted to load Chunk at <" .. x .. ", " .. y .. ">, but it already exists!")
		end
	end

	-- TODO: load json table into chunk and load its tiles
end

function logic:_SaveChunk(x, y)
	if not self.world[x] then
		warn("Attempted to save Chunk at <" .. x .. ", " .. y .. ">, but it doesn't exist!")
		return
	end
	if not self.world[x][y] then
		warn("Attempted to save Chunk at <" .. x .. ", " .. y .. ">, but it doesn't exist!")
		return
	end

	-- TODO: save chunk to json table and save it to datastore
end

return logic
