--!optimize 2

-- local CHUNK_MAXIMUM_ENTITY_BEFORE_AUTOMATIC_RESIZE = 64
local CHUNK_SIZE = 32

export type Type = {
	--TODO change model type to a different one
	Tiles: { [number]: Model },
	Position: Vector2,
	-- Entities: Array<Entity>,

	AccessTile: (self: Type, x: number, y: number) -> {
		TileId: number,
		Rotation: number,
		Position: Vector2,
	},
	WriteTile: (self: Type, x: number, y: number, tile: Model) -> nil,
}
local Chunk = {}
Chunk.__index = Chunk

function Chunk.new(position: Vector2): Type
	local self = setmetatable({
		Tiles = table.create(CHUNK_SIZE * CHUNK_SIZE),
		-- Entities = table.create(CHUNK_MAXIMUM_ENTITY_BEFORE_AUTOMATIC_RESIZE)
		Position = position,
	}, Chunk)

	return self :: Type
end

function Chunk:AccessTile(x, y)
	return self.Tiles[(y * CHUNK_SIZE) + x + 1]
end

function Chunk:WriteTile(x, y, tile)
	self.Tiles[(y * CHUNK_SIZE) + x + 1] = tile
end

return Chunk
