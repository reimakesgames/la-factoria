local constants = require(script.Parent.constants)
export type Type = {
	GetTileFromV3: (Type, position: Vector3) -> (number, number),
	GetChunkFromXY: (Type, x: number, y: number) -> (number, number),
	GetLocalTileFromXY: (Type, x: number, y: number) -> number,
	GetChunkAndLocalTileFromXY: (Type, x: number, y: number) -> (number, number, number),

	ToWatts: (Type, watt: number) -> number,
}

local util = {}

--[[
	Converts a Vector3 position to a tile position.
	(12, X, 16) -> (3, 4)
]]
function util:GetTileFromV3(position)
	return math.floor(position.X / constants.TILE_SIZE), math.floor(position.Z / constants.TILE_SIZE)
end

--[[
	Converts a tile position to a chunk position.
	(3, 4) -> (0, 0)
	(34, 4) -> (1, 0)
	(34, 34) -> (1, 1)
]]
function util:GetChunkFromXY(x, y)
	return math.floor(x / constants.TILES_PER_CHUNK), math.floor(y / constants.TILES_PER_CHUNK)
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
function util:GetLocalTileFromXY(x, y)
	return ((y % constants.TILES_PER_CHUNK) * constants.TILES_PER_CHUNK) + (x % constants.TILES_PER_CHUNK) + 1
end

--[[
	Converts a tile position to a chunk position and a local tile position.
	(3, 4) -> (0, 0, 13)
	(34, 4) -> (1, 0, 14)
	(34, 34) -> (1, 1, 45)
]]
function util:GetChunkAndLocalTileFromXY(x, y)
	local chunkX, chunkY = util:GetChunkFromXY(x, y)
	local localTile = util:GetLocalTileFromXY(x, y)
	return chunkX, chunkY, localTile
end

local wattSuffixes = {"", "k", "M", "G", "T", "P", "E", "Z", "Y"}

function util:ToWatts(watt)
    for i = 1, #wattSuffixes do
        watt = watt / 1000
        if watt < 1000 then
            return watt .. wattSuffixes[i + 1] .. "W"
        end
    end
	return watt .. "W"
end

return util :: Type
