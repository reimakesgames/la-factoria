local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")

local buildingIds = require(ReplicatedStorage.Shared.buildingIds)
local components = require(PlayerScripts.Client.components)

local constructionData = components.constructionData

local Building = components.Building
local Health = components.Health

local id = table.find(buildingIds, "splitter")
local model = ReplicatedStorage.Assets.buildings.splitter

return function(world, hit, rot)
	world:spawn(
		constructionData({
			id = id,
			hit = hit,
			rotation = rot,
			dimX = 2,
			dimY = 1,
			model = model
		}),
		Health({
			health = 170,
			maxHealth = 170,
		})
	)
end
