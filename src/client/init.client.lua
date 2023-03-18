--!optimize 2

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Assets = ReplicatedStorage.Assets
local Shared = ReplicatedStorage.Shared

local map = require(Shared.map)
local bitTools = require(script.bitTools)
local Tile = require(script.Tile)
local tileLookupTable = require(script.tileLookupTable)

local SlotNumber = nil
local SelectedItem = nil -- a pointer to a class
local SelectedItemModel
local SelectedItemModelHeight = 0 -- the height of the model, must be set when an item is selected
local GhostItem = nil -- the ghost item that will be placed
local Rotation = 4

-- the shortcut of items
-- TODO: make this a table of classes instead
local ShortcutBar: { [number]: number } = {
	1
}

-- this is the function that will be called every frame
local Mouse = LocalPlayer:GetMouse()

local function GetTilePositionFromMouse(): Vector2
	local MouseHit = Mouse.Hit
	local x = math.floor((MouseHit.Position.X) / 4)
	local z = math.floor((MouseHit.Position.Z) / 4)
	return Vector2.new(x, z)
end

local function PlacementCFrame(): CFrame
	local MouseHit = Mouse.Hit
	local x = math.floor((MouseHit.Position.X) / 4) * 4
	local z = math.floor((MouseHit.Position.Z) / 4) * 4
	return CFrame.new(x + 2, SelectedItemModelHeight / 2, z + 2) * CFrame.Angles(0, math.rad(Rotation * 90), 0)
end

local function PlaceObject(selectedItem)
	local tilePosition = GetTilePositionFromMouse()
	local chunk = map:GetChunk(tilePosition)
	local tilePositionInChunk = tilePosition - (chunk.Position * 32)
	if chunk:AccessTile(tilePositionInChunk.X, tilePositionInChunk.Y) then
		warn("There is already a tile here!")
		return
	end

	local tile = Tile.new(chunk, selectedItem, Rotation, tilePositionInChunk.X, tilePositionInChunk.Y)
	map:WriteTile(tilePosition.X, tilePosition.Y, tile)
end

local function Deselect()
	SlotNumber = nil
	SelectedItem = nil
	SelectedItemModelHeight = 0
end

local function Pick()
	--TODO: add the position to find the item in the world

	-- if the hit position is 'empty' then deselect
	-- else select the hovered item alongside it's rotation

	local tilePosition = GetTilePositionFromMouse()

	print("picking tile at " .. tilePosition.X .. ", " .. tilePosition.Y)
	local tile = map:AccessTile(tilePosition.X, tilePosition.Y)
	if tile then
		-- find the item in the shortcut bar by comparing names
		print(tile.TileId)
		for i, item in ShortcutBar do
			if item == tile.TileId then
				SlotNumber = i
				SelectedItem = item
				SelectedItemModel = Assets.buildings:FindFirstChild(tileLookupTable[SelectedItem]) :: Model
				local _ItemCFrame, ItemSize = SelectedItemModel:GetBoundingBox()
				SelectedItemModelHeight = ItemSize.Y
				print("Selected item: " .. tileLookupTable[SelectedItem])
				return
			end
		end
	else
		Deselect()
	end
end

RunService.Heartbeat:Connect(function()
	if SelectedItem then
		if not GhostItem then
			GhostItem = SelectedItemModel:Clone()
			GhostItem.Parent = workspace
			for _, part in GhostItem:GetDescendants() do
				if part:IsA("BasePart") then
					part.Transparency = 0.5
				end
			end
		end

		GhostItem:PivotTo(PlacementCFrame())
	else
		if GhostItem then
			GhostItem:Destroy()
			GhostItem = nil
		end
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and SelectedItem then
		PlaceObject(SelectedItem)
	end

	if input.KeyCode == Enum.KeyCode.R then
		Rotation = Rotation + if input:IsModifierKeyDown(Enum.ModifierKey.Shift) then 1 else -1
		if Rotation > 4 then
			Rotation = 1
		elseif Rotation < 1 then
			Rotation = 4
		end
	elseif input.KeyCode == Enum.KeyCode.Q then
		Pick()
	end

	-- KeyCode 0-9 or 48-57
	if input.KeyCode.Value >= 48 and input.KeyCode.Value <= 57 then
		local index = input.KeyCode.Value - 48
		if index == 0 then
			index = 10
		end

		-- Deselection
		if SlotNumber == index then
			Deselect()
			return
		end

		-- Selection
		local Item = ShortcutBar[index]
		print("Selected item: " .. tileLookupTable[Item])
		if not Item then
			return
		end
		SlotNumber = index

		SelectedItemModel = Assets.buildings:FindFirstChild(tileLookupTable[Item]) :: Model
		local _ItemCFrame, ItemSize = SelectedItemModel:GetBoundingBox()
		SelectedItemModelHeight = ItemSize.Y
		SelectedItem = ShortcutBar[index]
		print("Selected item: " .. tileLookupTable[SelectedItem])
		-- TODO: fire a signal here
	end
end)

require(script.chunkDisplayer)
