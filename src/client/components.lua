local ReplicatedStorage = game:GetService("ReplicatedStorage")
local matter = require(ReplicatedStorage.Packages.matter)

return {
	constructionData = matter.component("constructionData", {
		id = 0,
		hit = nil,
		model = nil,
		dimX = 0,
		dimY = 0,
	}),
	Building = matter.component("Building", {
		model = nil,

		chunkX = 0, -- The chunk the building is in
		chunkY = 0,
		tileX = 0, -- 0-31, 0 is leftmost
		tileY = 0, -- 0-31, 0 is topmost

		id = 0, -- The id of the building
		dimX = 0, -- The dimensions of the building
		dimY = 0,
	}),
	Health = matter.component("Health", {
		health = 100,
		maxHealth = 100,
	}),
}
