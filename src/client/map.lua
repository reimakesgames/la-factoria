local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Shared.CONSTANTS)
local map = {
	worldMap = {}
}

function map.assignIdToTile(id, x, y)
	local chunkX = math.floor(x / CONSTANTS.TILES_PER_CHUNK)
	local chunkY = math.floor(y / CONSTANTS.TILES_PER_CHUNK)
	local tileX = x % CONSTANTS.TILES_PER_CHUNK
	local tileY = y % CONSTANTS.TILES_PER_CHUNK
	if not map.worldMap[chunkX] then
		map.worldMap[chunkX] = {}
	end
	if not map.worldMap[chunkX][chunkY] then
		map.worldMap[chunkX][chunkY] = {}
	end
	map.worldMap[chunkX][chunkY][tileX + (tileY * CONSTANTS.TILES_PER_CHUNK)] = id
end

return map
