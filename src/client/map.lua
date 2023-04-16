local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Shared.CONSTANTS)
local map = {
	jimmy = {}
}

function map.assignIdToTile(id, x, y)
	warn(map.jimmy)
	local chunkX = math.floor(x / CONSTANTS.TILES_PER_CHUNK)
	local chunkY = math.floor(y / CONSTANTS.TILES_PER_CHUNK)
	print(chunkX, chunkY)
	local tileX = x % CONSTANTS.TILES_PER_CHUNK
	local tileY = y % CONSTANTS.TILES_PER_CHUNK
	if not map.jimmy[chunkX] then
		warn(chunkX)
		warn("chunkX not found")
		map.jimmy[chunkX] = {}
	end
	warn("chunkX found")
	if not map.jimmy[chunkX][chunkY] then
		map.jimmy[chunkX][chunkY] = {}
	end
	map.jimmy[chunkX][chunkY][tileX + (tileY * CONSTANTS.TILES_PER_CHUNK)] = id
end

return map
