--!optimize 2
local Chunk = require(script.Chunk)

local map = {}

local mapIndex: { [string]: Chunk.Type } = {}

function map:AccessTile(x, y)
	local chunkX = math.floor(x / 32)
	local chunkY = math.floor(y / 32)

	local chunk = mapIndex[chunkX .. "," .. chunkY]

	if chunk then
		return chunk:AccessTile(x % 32, y % 32)
	end

	return false
end

function map:WriteTile(x, y, tile)
	local chunkX = math.floor(x / 32)
	local chunkY = math.floor(y / 32)

	local chunk = mapIndex[chunkX .. "," .. chunkY]

	if not chunk then
		chunk = Chunk.new()
		mapIndex[chunkX .. "," .. chunkY] = chunk
	end

	chunk:WriteTile(x % 32, y % 32, tile)
end

return map