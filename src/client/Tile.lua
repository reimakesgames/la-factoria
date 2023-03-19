local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local map = require(Shared.map)
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

function Tile.new(chunk, tileId, rotation, x, y, sx, sy): Type
	if rotation < 1 or rotation > 4 then
		error("Invalid rotation: " .. rotation)
	end

	sx = sx or 1
	sy = sy or 1

	local self = setmetatable({
		TileId = tileId, -- Type of tile found in tileLookupTable
		Rotation = rotation, -- Rotation of the tile, digestible by the renderer
		Position = Vector2.new(x, y), -- Position of the tile in the chunk
		Size = Vector2.new(sx, sy), -- Size of the tile in the chunk
	}, Tile)


	if rotation == 4 or rotation == 2 then
		local e = false
		for cx = 0, sx - 1 do
			for cy = 0, sy - 1 do
				if map:AccessTile((chunk.Position.X * 32) + x + cx, (chunk.Position.Y * 32) + y + cy) then
					e = true
					break
				end
			end
		end
		if e then
			error("Tile is not empty!")
		end
	elseif rotation == 3 or rotation == 1 then
		local e = false
		for cx = 0, sy - 1 do
			for cy = 0, sx - 1 do
				if map:AccessTile((chunk.Position.X * 32) + x + cx, (chunk.Position.Y * 32) + y + cy) then
					e = true
					break
				end
			end
		end
		if e then
			error("Tile is not empty!")
		end
	end

	for i = 0, sx - 1 do
		for j = 0, sy - 1 do
			local highlihgtPart = Instance.new("Part")
			highlihgtPart.Anchored = true
			highlihgtPart.CanCollide = false
			highlihgtPart.Size = Vector3.new(4, 1, 4)
			highlihgtPart.Transparency = 0.9
			highlihgtPart.Position = Vector3.new(((chunk.Position.X * 32) + (x + i) * 4), 8, ((chunk.Position.Y * 32) + (y + j) * 4)) + Vector3.new(2, 0, 2)
			if i == 0 and j == 0 then
				map:WriteTile((chunk.Position.X * 32) + x + i, (chunk.Position.Y * 32) + y + j, self)
				highlihgtPart.Color = Color3.fromRGB(255, 0, 0)
			else
				map:WriteTile((chunk.Position.X * 32) + x + i, (chunk.Position.Y * 32) + y + j, {
					IsPointer = true,
					PointerTo = self
				})
				highlihgtPart.Color = Color3.fromRGB(255, 127, 0)
			end
			highlihgtPart.Parent = workspace
		end
	end

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

	if not self.IsPointer then
		return
	end

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
