local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Shared.CONSTANTS)
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local components = require(PlayerScripts.Client.components)
local map = require(PlayerScripts.Client.map)
local constructionData = components.constructionData
local Building = components.Building

local function GetTilePlacementPosition(cf, rot, dim)
	local IsXEven = dim.X % 2 == 0
	local IsYEven = dim.Y % 2 == 0
	if rot % 2 == 1 then
		IsXEven, IsYEven = IsYEven, IsXEven
		dim = Vector2.new(dim.Y, dim.X)
	end

	local CenterOffset = Vector3.new(math.floor(dim.X / 2), 0, math.floor(dim.Y / 2)) * CONSTANTS.TILE_SIZE
	local SnappingOffset = Vector3.new(IsXEven and 2 or 0, 0, IsYEven and 2 or 0)
	local MousePosition = cf.Position + SnappingOffset - CenterOffset

	local CenterPositionInStuds = (dim / 2) * CONSTANTS.TILE_SIZE
	local SnappedX = math.floor(MousePosition.X / CONSTANTS.TILE_SIZE) * CONSTANTS.TILE_SIZE + CenterPositionInStuds.X
	local SnappedY = math.floor(MousePosition.Z / CONSTANTS.TILE_SIZE) * CONSTANTS.TILE_SIZE + CenterPositionInStuds.Y
	local SnapPosition = Vector3.new(SnappedX, 0, SnappedY)

	return CFrame.new(SnapPosition) * CFrame.Angles(0, math.rad(rot * 90), 0)
end

return function(world)
	for id, data in world:query(constructionData) do
		local model = data.model:Clone()
		if model then
			local TileCFrame = GetTilePlacementPosition(data.hit, data.rotation, Vector2.new(data.dimX, data.dimY))
			model:SetPrimaryPartCFrame(TileCFrame)
			model.Parent = workspace

			world:insert(id, Building({
				model = model,
				chunkX = math.floor(TileCFrame.Position.X / CONSTANTS.CHUNK_SIZE),
				chunkY = math.floor(TileCFrame.Position.Z / CONSTANTS.CHUNK_SIZE),
				tileX = math.floor(TileCFrame.Position.X / CONSTANTS.TILE_SIZE) % CONSTANTS.TILES_PER_CHUNK,
				tileY = math.floor(TileCFrame.Position.Z / CONSTANTS.TILE_SIZE) % CONSTANTS.TILES_PER_CHUNK,
				dimX = data.dimX,
				dimY = data.dimY,
				rotation = data.rotation,
				id = data.id,
			}))
			model.Parent = workspace
			world:remove(id, constructionData)

			local tileX = math.floor(TileCFrame.X / CONSTANTS.TILE_SIZE)
			local tileY = math.floor(TileCFrame.Z / CONSTANTS.TILE_SIZE)

			map.assignIdToTile(id, tileX, tileY)
			if data.dimX == 1 and data.dimY == 1 then
				continue
			end

			-- ! TODO: fill in the rest of the tiles, if the building is bigger than 1x1
		end
	end
end
