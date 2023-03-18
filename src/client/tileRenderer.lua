local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Shared = ReplicatedStorage.Shared

local tileLookupTable = require(script.Parent.tileLookupTable)
local Chunk = require(Shared.map.Chunk)

type Tile = {
	TileId: number,
	Rotation: number,
	Position: Vector2,

	Load: (string) -> (),
	Save: () -> string
}
type TileRenderer = {
	RenderTile: (self: TileRenderer, chunk: Chunk.Type, tile: Tile) -> (),
	GhostTile: (self: TileRenderer, position: Vector2, tileId: number) -> ()
}
local tileRenderer: TileRenderer = {} :: TileRenderer

function tileRenderer:RenderTile(chunk, tile)
	-- tile.Data is a table of data that you can use to render the tile

	-- For example, you can use tile.Data.TileType to get the type of tile which can be used to get the model from ReplicatedStorage.Assets.buildings
	-- You can also use tile.Data.Rotation to get the rotation of the tile
	-- CFrame.Angles(0, math.rad(90 * tile.Data.Rotation), 0) can be used to rotate the tile

	local chunkPosition = chunk.Position -- by 32x32 tiles
	local tilePosition = tile.Position -- by 4x4 tiles
	local worldPosition = (chunkPosition * 128) + (tilePosition * 4) + Vector2.new(2, 2)

	local tileModel = Assets.buildings:FindFirstChild(tileLookupTable[tile.TileId])
	local tileInstance = tileModel:Clone() :: Model
	local _, tileSize = tileInstance:GetBoundingBox()
	tileInstance:PivotTo(CFrame.new(worldPosition.X, tileSize.Y / 2, worldPosition.Y) * CFrame.Angles(0, math.rad(90 * tile.Rotation), 0))
	tileInstance.Parent = workspace
end

return tileRenderer
