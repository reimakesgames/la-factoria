local HttpService = game:GetService("HttpService")

local tileRenderer = require(script.Parent.tileRenderer)
local bitTools = require(script.Parent.bitTools)

local tileBitStructure = {
	{ 0, 8 }, -- tile id
	{ 8, 5 }, -- position x
	{ 13, 5 }, -- position y
	{ 18, 2 }, -- rotation
}

export type Type = {
	TileId: number,
	Rotation: number,
	Position: Vector2,

	Load: (string) -> (),
	Save: () -> string
}
local Tile = {}
Tile.__index = Tile

function Tile.new(chunk, tileId, rotation, x, y): Type
	-- find the tile id
	if rotation < 1 or rotation > 4 then
		error("Invalid rotation: " .. rotation)
	end

	local self = setmetatable({
		TileId = tileId, -- Type of tile found in tileLookupTable
		Rotation = rotation, -- Rotation of the tile, digestible by the renderer
		Position = Vector2.new(x, y), -- Position of the tile in the chunk
	}, Tile)

	tileRenderer:RenderTile(chunk, self)
	self:Save()

	return self :: Type
end

function Tile:Save()
	-- generate an int that represents the tile
	-- 00000000 0000RRYY YYYXXXXX IDIDIDID -- 32 bits
	-- RR = rotation which is from 1 to 4
	-- XX = x position which is from 0 to 31
	-- YY = y position which is from 0 to 31
	-- ID = tile id which is from 0 to 255

	bitTools.saveStructure(tileBitStructure, {
		self.TileId,
		self.Position.X,
		self.Position.Y,
		self.Rotation,
	})
end

function Tile:Load(data: string)
	self.Data = HttpService:JSONDecode(data)
end

return Tile
