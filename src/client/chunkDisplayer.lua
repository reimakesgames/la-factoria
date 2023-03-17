--!optimize 2
-- display a chunk which is a 32x32 grid of 4x4 tiles

-- chunk 0,0 is the chunk at 0,0 to 31,31
-- chunk 1,0 is the chunk at 32,0 to 63,31

-- x goes right
-- y goes down

-- factorio base movement speed is 8.9 tiles per second

local chunkDisplayer = {}

local function uhhh(x, y)
	local part = Instance.new("Part")
	part.Size = Vector3.new(128, 4, 128)
	-- position the part at the specified chunk parameters
	part.Position = Vector3.new((x * 128) + 64, 0, (y * 128) + 64)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 0.75
	part.Name = "chunk<" .. x .. "," .. y .. ">"

	--TODO: add surface gui ontop of the chunk displayer to show chunk coordinates
	-- as opposed to seeing it in the explorer
	part.Parent = workspace
end

uhhh(0, 0)
-- gah zamn checkerboard pattern
uhhh(2, 0)
uhhh(0, 2)
uhhh(2, 2)
uhhh(1, 1)

return chunkDisplayer
