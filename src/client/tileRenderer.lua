local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Shared = ReplicatedStorage.Shared

local tileLookupTable = require(script.Parent.tileLookupTable)
local Chunk = require(Shared.map.Chunk)

type Tile = {
	TileId: number,
	Rotation: number,
	Position: Vector2,
	Size: Vector2,

	Load: (string) -> (),
	Save: () -> string
}
type TileRenderer = {
	RenderTile: (self: TileRenderer, chunk: Chunk.Type, tile: Tile) -> (),
	GhostTile: (self: TileRenderer, position: Vector2, tileId: number) -> ()
}
local tileRenderer: TileRenderer = {} :: TileRenderer

function tileRenderer:RenderTile(chunk, tile)
	-- For example, you can use tile.Data.TileType to get the type of tile which can be used to get the model from ReplicatedStorage.Assets.buildings
	-- You can also use tile.Data.Rotation to get the rotation of the tile
	-- CFrame.Angles(0, math.rad(90 * tile.Data.Rotation), 0) can be used to rotate the tile

	local chunkPosition = chunk.Position -- by 32x32 tiles
	local tilePosition = tile.Position -- by 4x4 tiles
	local tileRotation = tile.Rotation -- 1-4
	local tileSize = tile.Size -- by 4x4 tiles
	local worldPosition = (chunkPosition * 128) + (tilePosition * 4)

	-- we shift the tile position by 2 because the tile is 4x4 tiles, and we want the center of the tile to be the position
	-- and if we have a tile size of 2x2, we want the center of the tile to be the position 4,4 instead of 2,2
	-- account for rotation
	-- tile rotation 4 is the default size of a 2x1 where 2 is the width and 1 is the height if looking at the tile from the top
	-- so we need to shift the position by 2 to the left
	if tileRotation == 4 or tileRotation == 2 then
		worldPosition = worldPosition + Vector2.new(2 * tileSize.X, 2 * tileSize.Y)
	elseif tileRotation == 3 or tileRotation == 1 then
		worldPosition = worldPosition + Vector2.new(2 * tileSize.Y, 2 * tileSize.X)
	end
	local tileModel = Assets.buildings:FindFirstChild(tileLookupTable[tile.TileId])
	local tileInstance = tileModel:Clone() :: Model
	local _, tileSize = tileInstance:GetBoundingBox()
	tileInstance:PivotTo(CFrame.new(worldPosition.X, tileSize.Y / 2, worldPosition.Y) * CFrame.Angles(0, math.rad(90 * tile.Rotation), 0))
	tileInstance.Parent = workspace
end

return tileRenderer
