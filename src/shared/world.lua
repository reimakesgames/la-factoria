local RunService = game:GetService("RunService")

local Console = require(script.Parent.Console)
local CONSTANTS = require(script.Parent.CONSTANTS)

local Buildings = {}

local CurrentUniqueBuildingId = 0

local World = {
	Map = {}
}

export type Chunk = {
	[number]: number -- unique building id
}

--[[
	Converts a Vector3 position to a tile position.
	(12, X, 16) -> (3, 4)
]]
function World:GetTileFromV3(position)
	return math.floor(position.X / CONSTANTS.TILE_SIZE), math.floor(position.Z / CONSTANTS.TILE_SIZE)
end

--[[
	Converts a tile position to a chunk position.
	(3, 4) -> (0, 0)
	(34, 4) -> (1, 0)
	(34, 34) -> (1, 1)
]]
function World:GetChunkFromTilePosition(x, y)
	return math.floor(x / CONSTANTS.TILES_PER_CHUNK), math.floor(y / CONSTANTS.TILES_PER_CHUNK)
end

--[[
	Converts a tile position to a local tile position.
	It assumes that the tile position is not in a chunk.
	Useful for getting the tile position in a chunk.

	(0, 0) -> 1
	(1, 0) -> 2
	(0, 1) -> 33
	(1, 1) -> 34
]]
function World:GetLocalTileFromTilePosition(x, y)
	return ((y % CONSTANTS.TILES_PER_CHUNK) * CONSTANTS.TILES_PER_CHUNK) + (x % CONSTANTS.TILES_PER_CHUNK) + 1
end



function World:NewChunk(chunkX, chunkY): Chunk
	local chunk = World:GetChunk(chunkX, chunkY)
	if chunk then
		Console:Warn("Default", `Attempted to create a chunk at {chunkX}, {chunkY} but it already exists.`)
		warn(`Chunk at {chunkX}, {chunkY} already exists.}`)
		return chunk
	end

	if not World.Map[chunkX] then
		World.Map[chunkX] = {}
	end
	if not World.Map[chunkX][chunkY] then
		World.Map[chunkX][chunkY] = {}
	end
	return World.Map[chunkX][chunkY]
end

function World:GetChunk(chunkX, chunkY): Chunk?
	if World.Map[chunkX] then
		return World.Map[chunkX][chunkY] or nil
	end
	return nil
end

function World:NewTile(worldTileX, worldTileY, class, parameters)
	local chunkX, chunkY = World:GetChunkFromTilePosition(worldTileX, worldTileY)
	local localTile = World:GetLocalTileFromTilePosition(worldTileX, worldTileY)
	local chunk = World:GetChunk(chunkX, chunkY)
	if not chunk then
		World:NewChunk(chunkX, chunkY)
		chunk = World:GetChunk(chunkX, chunkY)
	end
	local building = require(class).new(parameters)
	Buildings[CurrentUniqueBuildingId] = building
	building.UniqueBuildingId = CurrentUniqueBuildingId
	chunk[localTile] = CurrentUniqueBuildingId
	CurrentUniqueBuildingId = CurrentUniqueBuildingId + 1
end

--[[
	This function will return the building at the tile position.
]]
function World:GetTile(x, y)
	-- Index the chunk by doing (y * 32) + x + 1
	-- though get the chunk first

	local chunkX, chunkY = World:GetChunkFromTilePosition(x, y)
	local localTile = World:GetLocalTileFromTilePosition(x, y)
	local chunk = World:GetChunk(chunkX, chunkY)
	if chunk then
		return chunk[localTile]
	end
	return nil
end

function World:GetBuildingByUniqueId(uniqueBuildingId)
	return Buildings[uniqueBuildingId]
end

RunService.Heartbeat:Connect(function()
	for _, building in pairs(Buildings) do
		if building["Update"] then
			building:Update()
		end
	end
end)

return World
