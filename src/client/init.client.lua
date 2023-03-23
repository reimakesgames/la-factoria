local Lighting = game:GetService("Lighting")
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local Assets = ReplicatedStorage.Assets
local Shared = ReplicatedStorage.Shared
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Buildings = Assets.buildings
local AssemblerBase = Buildings.assembler_base
local SplitterBase = Buildings.splitter_base

local constants = require(Shared.constants)
local fastInstance = require(Shared.fastInstance)

local buildingIds = require(script.buildingIds)
local buildingDimensions = require(script.buildingDimensions)

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

local Mouse = LocalPlayer:GetMouse()
local GhostStructure
local SelectedBuildingModel
local SelectedBuildingId
local SelectedBuildingName
local CantPlaceBuilding = false
local t1 = false

local function AddHardHat(character)
	local hat = Assets.hard_hat:Clone()
	local head = character:WaitForChild("Head")
	hat.Handle.CFrame = head.CFrame * CFrame.new(0, 0.25, 0)
	fastInstance.new("WeldConstraint", {
		Parent = hat.Handle,
		Part0 = head,
		Part1 = hat.Handle,
	})
	hat.Parent = character
end

local function UpdateBuildingGui()
	BuildingGui.ViewportFrame.LightDirection = Lighting:GetSunDirection() * -1
	BuildingGui.ViewportFrame.ImageColor3 = if CantPlaceBuilding then Color3.new(1, 0.5, 0.5) else Color3.new(1, 1, 1)
end

local CLOCK_TIME_TO_ADD_PER_TICK = 24 / 25000
local function UpdateTimeOfDay()
	Lighting.ClockTime = Lighting.ClockTime + CLOCK_TIME_TO_ADD_PER_TICK
end

local function GetPlacementCFrame(dim: Vector2)
	local IsXEven = dim.X % 2 == 0
	local IsYEven = dim.Y % 2 == 0
	local CenterOffset = Vector3.new(math.floor(dim.X / 2), 0, math.floor(dim.Y / 2)) * constants.STUDS_PER_TILE
	local SnappingOffset = Vector3.new(IsXEven and 2 or 0, 0, IsYEven and 2 or 0)
	local MousePosition = Mouse.Hit.Position + SnappingOffset - CenterOffset

	local CenterPositionInStuds = (dim / 2) * constants.STUDS_PER_TILE
	local SnappedX = math.floor(MousePosition.X / constants.STUDS_PER_TILE) * constants.STUDS_PER_TILE + CenterPositionInStuds.X
	local SnappedY = math.floor(MousePosition.Z / constants.STUDS_PER_TILE) * constants.STUDS_PER_TILE + CenterPositionInStuds.Y
	local SnapPosition = Vector3.new(SnappedX, 0, SnappedY)

	return CFrame.new(SnapPosition) -- Add rotation
end

local function PlaceBuilding()
	if not SelectedBuildingId then return end

	local NewBuilding = SelectedBuildingModel:Clone()
	NewBuilding:PivotTo(GetPlacementCFrame(buildingDimensions[SelectedBuildingName]))
	NewBuilding.Parent = workspace
end

local function UpdateGhostStructure()
	if not GhostStructure then return end

	GhostStructure:PivotTo(GetPlacementCFrame(buildingDimensions[SelectedBuildingName]))
end

local function ToggleGhostStructure()
	if GhostStructure then
		GhostStructure:Destroy()
		GhostStructure = nil
	end

	if t1 then
		GhostStructure = AssemblerBase:Clone()
	else
		GhostStructure = SplitterBase:Clone()
	end

	GhostStructure:PivotTo(GetPlacementCFrame(buildingDimensions[SelectedBuildingName]))

	-- create a blue floor under the ghost structure
	local buildingSize = buildingDimensions[if t1 then "assembling_machine_1" else "splitter"] * constants.STUDS_PER_TILE
	local floor = fastInstance.new("Part", {
		Name = "GhostStructureFloor",
		Anchored = true,
		BrickColor = BrickColor.new("Bright blue"),
		Material = Enum.Material.Neon,
		Size = Vector3.new(buildingSize.X, 1, buildingSize.Y),
		Parent = GhostStructure,
	})
	floor:PivotTo(CFrame.new(GetPlacementCFrame(buildingDimensions[SelectedBuildingName]).Position) - Vector3.new(0, 0.5, 0))
	GhostStructure.Parent = BuildingGui.ViewportFrame
end


RunService.Heartbeat:Connect(function()
	UpdateTimeOfDay()
	UpdateBuildingGui()
	UpdateGhostStructure()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E then
		t1 = not t1
		SelectedBuildingName = if t1 then "assembling_machine_1" else "splitter"
		SelectedBuildingModel = if t1 then AssemblerBase else SplitterBase
		SelectedBuildingId = buildingIds[SelectedBuildingName]
		ToggleGhostStructure()
	elseif input.KeyCode == Enum.KeyCode.R then
		CantPlaceBuilding = not CantPlaceBuilding
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		PlaceBuilding()
	end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	AddHardHat(newCharacter)
end)
