local Lighting = game:GetService("Lighting")
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService('UserInputService')

local Assets = ReplicatedStorage.Assets
local Shared = ReplicatedStorage.Shared

local Class = Shared.Class
local Types = Shared.Types

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local wooden_chest = ReplicatedStorage.Shared.Class.wooden_chest
local Console = require(Shared.Console)
local CONSTANTS = require(Shared.CONSTANTS)
local fastInstance = require(Shared.fastInstance)

local World = require(Shared.World)

local Rotation = 0

local CanPlace = true

local BuildingGui = fastInstance.new("ScreenGui", {
	Name = "BuildingGui",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,

	Parent = PlayerGui,

	Children = {
		ViewportFrame = {
			Name = "ViewportFrame",
			BackgroundTransparency = 1,
			LightColor = Color3.new(1, 1, 1),
			LightDirection = Lighting:GetSunDirection() * -1,
			Ambient = Color3.new(0.25,0.25,0.25),
			ImageTransparency = 0.5,

			Size = UDim2.new(1, 0, 1, 0),
			CurrentCamera = Camera,
		}
	}
})

local function AddHardHatToCharacter()
	local hat = Assets.hard_hat:Clone()
	local head = Character:WaitForChild("Head")
	hat.Handle.CFrame = head.CFrame * CFrame.new(0, 0.25, 0)
	fastInstance.new("WeldConstraint", {
		Parent = hat.Handle,
		Part0 = head,
		Part1 = hat.Handle,
	})
	hat.Parent = Character
end

local function UpdateBuildingGui()
	BuildingGui.ViewportFrame.LightDirection = Lighting:GetSunDirection() * -1
	BuildingGui.ViewportFrame.ImageColor3 = if CanPlace then Color3.new(0, 1, 0) else Color3.new(1, 0, 0)
end

local function FindTileUnderMouse()
end



local function GetMouseTilePosition()
	return math.floor(Mouse.Hit.Position.X / CONSTANTS.TILE_SIZE), math.floor(Mouse.Hit.Position.Z / CONSTANTS.TILE_SIZE)
end

local function GetMouseTilePositionInStuds()
	return math.floor(Mouse.Hit.Position.X / CONSTANTS.TILE_SIZE) * CONSTANTS.TILE_SIZE, math.floor(Mouse.Hit.Position.Z / CONSTANTS.TILE_SIZE) * CONSTANTS.TILE_SIZE
end

local function GetTilePlacementPosition(dim: Vector2)
	local IsXEven = dim.X % 2 == 0
	local IsYEven = dim.Y % 2 == 0

	local CenterOffset = Vector3.new(math.floor(dim.X / 2), 0, math.floor(dim.Y / 2)) * CONSTANTS.TILE_SIZE
	local SnappingOffset = Vector3.new(IsXEven and 2 or 0, 0, IsYEven and 2 or 0)
	local MousePosition = Mouse.Hit.Position + SnappingOffset - CenterOffset

	local CenterPositionInStuds = (dim / 2) * CONSTANTS.TILE_SIZE
	local SnappedX = math.floor(MousePosition.X / CONSTANTS.TILE_SIZE) * CONSTANTS.TILE_SIZE + CenterPositionInStuds.X
	local SnappedY = math.floor(MousePosition.Z / CONSTANTS.TILE_SIZE) * CONSTANTS.TILE_SIZE + CenterPositionInStuds.Y
	local SnapPosition = Vector3.new(SnappedX, 0, SnappedY)

	return CFrame.new(SnapPosition) * CFrame.Angles(0, math.rad(Rotation * 90), 0)
end



local function UpdateTimeOfDay()
	Lighting.ClockTime += CONSTANTS.CLOCK_TIME_TO_ADD_PER_TICK
end



local function UpdateGhostPosition()
end
local function CreateGhost()
end
local function DestroyGhost()
end



local function PickBuilding()
end
local function DeselectBuilding()
end
local function PlaceBuilding()
	local worldTileX, worldTileY = GetMouseTilePosition()

	local class = wooden_chest

	local building = World:NewTile(worldTileX, worldTileY, class)

	local v = Assets.buildings[class.Name]:Clone()
	v:PivotTo(GetTilePlacementPosition(Vector2.new(1, 1)))
	v.Parent = workspace
	building.__model = v
end
local function CopyBuildingProperties()
end
local function PasteBuildingProperties()
end
local function OpenBuilding()
	local worldTileX, worldTileY = GetMouseTilePosition()
	local Tile = World:GetTile(worldTileX, worldTileY)
	Tile:Damage(1)
end

RunService.Heartbeat:Connect(function()
	UpdateTimeOfDay()
	UpdateBuildingGui()
	FindTileUnderMouse()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.R then
		Rotation += if input:IsModifierKeyDown(Enum.ModifierKey.Shift) then 1 else -1
		if Rotation > 3 then
			Rotation = 0
		elseif Rotation < 0 then
			Rotation = 3
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		PlaceBuilding()
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		OpenBuilding()
	end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter

	AddHardHatToCharacter()
end)

AddHardHatToCharacter()

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

Console:Print("Default", "Welcome to the game!")
Console:Print("Default", "You can toggle this console by pressing the '`' key.")
