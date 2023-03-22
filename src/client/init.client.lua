local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Shared = ReplicatedStorage.Shared
local Buildings = Assets.buildings
local AssemblerBase = Buildings.assembler_base
local SplitterBase = Buildings.splitter_base

local constants = require(Shared.constants)
local buildingIds = require(script.buildingIds)
local buildingDimensions = require(script.buildingDimensions)

local LocalPlayer = Players.LocalPlayer

local Mouse = LocalPlayer:GetMouse()
local GhostStructure
local t1 = false

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

end

local function UpdateGhostStructure()
	if not GhostStructure then return end

	GhostStructure:PivotTo(GetPlacementCFrame(buildingDimensions[if t1 then "assembling_machine_1" else "splitter"]))
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

	for _, v in pairs(GhostStructure:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 0.5
		end
	end

	GhostStructure:PivotTo(GetPlacementCFrame(buildingDimensions[if t1 then "assembling_machine_1" else "splitter"]))
	GhostStructure.Parent = workspace
end


RunService.Heartbeat:Connect(UpdateGhostStructure)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.E then
		t1 = not t1
		ToggleGhostStructure()
	end
end)
