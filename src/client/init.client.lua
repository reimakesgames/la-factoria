local Lighting = game:GetService("Lighting")
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService('UserInputService')

local Assets = ReplicatedStorage.Assets
local Shared = ReplicatedStorage.Shared
local Proto = Shared.proto
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Console = require(ReplicatedStorage.Shared.Console)
local world = require(ReplicatedStorage.Shared.world)
local util = require(Shared.util)
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
local HoverHighlight = fastInstance.new("Highlight", {
	Name = "HoverHighlight",
	Parent = BuildingGui,
	Adornee = nil,
	FillTransparency = 1,
	OutlineTransparency = 0,
	FillColor = Color3.new(1, 0.6, 0),
	OutlineColor = Color3.new(1, 0.6, 0),
})
local SelectedHighlight = fastInstance.new("Highlight", {
	Name = "SelectedHighlight",
	Parent = BuildingGui,
	Adornee = nil,
	FillTransparency = 0.5,
	OutlineTransparency = 0,
	FillColor = Color3.new(1, 0.6, 0),
	OutlineColor = Color3.new(1, 0.6, 0),
})

local Mouse = LocalPlayer:GetMouse()
local GhostStructure
local SelectedInventorySlot = nil
local SelectedBuildingModel
local SelectedBuildingId
local SelectedBuildingName
local CantPlaceBuilding = false

local BuildingUnderMouse = nil
local UniqueBuildingIdUnderMouse = nil

local RecentInteraction = nil

local Inventory = {
	{
		Name = "wooden_chest",
		Count = 7,
	},
	{
		Name = "wooden_chest",
		Count = 2,
	}
}

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

local function FindTileUnderMouse()
	local tx, ty = util:GetTileFromV3(Mouse.Hit.Position)
	local tile = world:GetTile(tx, ty)
	UniqueBuildingIdUnderMouse = tile
	BuildingUnderMouse = world:GetBuilding(tile)
end

local function HighlightBuildingUnderMouse()
	if BuildingUnderMouse and RecentInteraction ~= BuildingUnderMouse then
		HoverHighlight.Adornee = BuildingUnderMouse.Model
	else
		HoverHighlight.Adornee = nil
	end
end

local CLOCK_TIME_TO_ADD_PER_TICK = 24 / 25000
local function UpdateTimeOfDay()
	Lighting.ClockTime = Lighting.ClockTime + CLOCK_TIME_TO_ADD_PER_TICK
end

local function GetPlacementCFrame(dim: Vector2)
	local IsXEven = dim.X % 2 == 0
	local IsYEven = dim.Y % 2 == 0
	local CenterOffset = Vector3.new(math.floor(dim.X / 2), 0, math.floor(dim.Y / 2)) * constants.TILE_SIZE
	local SnappingOffset = Vector3.new(IsXEven and 2 or 0, 0, IsYEven and 2 or 0)
	local MousePosition = Mouse.Hit.Position + SnappingOffset - CenterOffset

	local CenterPositionInStuds = (dim / 2) * constants.TILE_SIZE
	local SnappedX = math.floor(MousePosition.X / constants.TILE_SIZE) * constants.TILE_SIZE + CenterPositionInStuds.X
	local SnappedY = math.floor(MousePosition.Z / constants.TILE_SIZE) * constants.TILE_SIZE + CenterPositionInStuds.Y
	local SnapPosition = Vector3.new(SnappedX, 0, SnappedY)

	return CFrame.new(SnapPosition) -- Add rotation
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

	if not SelectedBuildingId then return end
	GhostStructure = SelectedBuildingModel:Clone()

	GhostStructure:PivotTo(GetPlacementCFrame(buildingDimensions[SelectedBuildingName]))

	-- create a blue floor under the ghost structure
	local buildingSize = buildingDimensions[SelectedBuildingName] * constants.TILE_SIZE
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

local function DeselectBuilding()
	SelectedBuildingId = nil
	SelectedBuildingName = nil
	SelectedBuildingModel:Destroy()
	SelectedBuildingModel = nil

	ToggleGhostStructure()
end

local function PlaceBuilding()
	if not SelectedBuildingId then return end

	local tx, ty = util:GetTileFromV3(Mouse.Hit.Position)

	Inventory[SelectedInventorySlot].Count -= 1
	Console:Print("Default", `Placed a building! {Inventory[SelectedInventorySlot].Count} left`)
	local NewBuilding = SelectedBuildingModel:Clone()
	NewBuilding:PivotTo(GetPlacementCFrame(buildingDimensions[SelectedBuildingName]))
	world:NewTile(tx, ty, Proto[SelectedBuildingName], NewBuilding)
	NewBuilding.Parent = workspace
	if Inventory[SelectedInventorySlot].Count < 1 then
		Console:Warn("Default", `You ran out of {SelectedBuildingName}!`)
		DeselectBuilding()
		table.clear(Inventory[SelectedInventorySlot])
		return
	end
end

RunService.Heartbeat:Connect(function()
	UpdateTimeOfDay()
	UpdateBuildingGui()
	UpdateGhostStructure()
	FindTileUnderMouse()
	HighlightBuildingUnderMouse()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- get the slot number from the key pressed from 1 to 0 in keyboard
	local slotNumber
	if input.KeyCode.Value >= 48 and input.KeyCode.Value <= 57 then
		slotNumber = input.KeyCode.Value - 48
		-- since 0 is 48 and not 57, we need to do this
		if slotNumber == 0 then
			slotNumber = 10
		end
		if SelectedInventorySlot == slotNumber then
			slotNumber = nil
			SelectedInventorySlot = nil

			SelectedBuildingId = nil
			SelectedBuildingName = nil
			if SelectedBuildingModel then
				SelectedBuildingModel:Destroy()
			end
			SelectedBuildingModel = nil
			ToggleGhostStructure()
		else
			SelectedInventorySlot = slotNumber
		end
	end

	if slotNumber then
		Console:Print("Default", `Selected slot {slotNumber}`)
		local buildingItem = Inventory[slotNumber]
		if not buildingItem then return end
		local buildingId = buildingIds[buildingItem.Name]
		Console:Print("Default", `Selected {buildingItem.Name}!`)
		if buildingId then
			SelectedBuildingId = buildingId
			SelectedBuildingName = buildingItem.Name
			SelectedBuildingModel = Assets.buildings[buildingItem.Name]:Clone()
			ToggleGhostStructure()
		end
	end

	if input.KeyCode == Enum.KeyCode.R then
		CantPlaceBuilding = not CantPlaceBuilding
	elseif input.KeyCode == Enum.KeyCode.E then
		if RecentInteraction then
			RecentInteraction:Unfocus()
		end
		RecentInteraction = nil
		SelectedHighlight.Adornee = nil
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if SelectedBuildingId then
			PlaceBuilding()
		else
			if BuildingUnderMouse then
				Console:Print("Default", `Clicked on {BuildingUnderMouse.Name}!`)
				if BuildingUnderMouse["Interact"] then
					Console:Warn("Default", `Interacting with {BuildingUnderMouse.Name}!`)
					if RecentInteraction then
						RecentInteraction:Unfocus()
					end
					BuildingUnderMouse:Interact()
					RecentInteraction = BuildingUnderMouse
					SelectedHighlight.Adornee = BuildingUnderMouse.Model
				end
			end
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	AddHardHat(newCharacter)
end)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

Console:Print("Default", "Welcome to the game!")
Console:Print("Default", "You can toggle this console by pressing the '`' key.")
