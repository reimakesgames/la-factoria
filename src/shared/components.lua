local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Matter = require(Packages.matter)

return {
	ItemModel = Matter.component(),
	ItemConveyorPosition = Matter.component(),

	BuildingModel = Matter.component(),
	ConveyorBelt = Matter.component(),
}
