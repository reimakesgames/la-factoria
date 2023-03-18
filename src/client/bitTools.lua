local BYTE_SIZE = 8

--[[
	Note that the naming schema for these constants are based on the
	way that it is stored or printed, so for example, the first byte
	is the least significant byte, and the fourth byte is the most
	significant byte.

	So for example, the first byte would be placed in the rightmost position,
	and the fourth byte would be placed in the leftmost position.

	00000000 00000000 00000000 00000000
	^ fourth byte ^ third byte ^ second byte ^ first byte
]]
local FIRST_BYTE = 0
local SECOND_BYTE = 8
local THIRD_BYTE = 16
local FOURTH_BYTE = 24

local function get8bitBin(n)
	local str = ""
	for i = 1, BYTE_SIZE do
		local bit = bit32.extract(n, i - 1)
		str = bit .. str
	end
	return str
end

local bitTools = {}

function bitTools.condense4(n1, n2, n3, n4)
	return bit32.bor(n1, bit32.lshift(n2, SECOND_BYTE), bit32.lshift(n3, THIRD_BYTE), bit32.lshift(n4, 24))
end

function bitTools.extract4(n)
	return bit32.extract(n, FIRST_BYTE, BYTE_SIZE), bit32.extract(n, SECOND_BYTE, BYTE_SIZE), bit32.extract(n, THIRD_BYTE, BYTE_SIZE), bit32.extract(n, FOURTH_BYTE, BYTE_SIZE)
end

-- a function that lets you get sections of a 32bit number and returns them as a tuple
function bitTools.loadStructure(n, structure)
	local tuple = {}
	for i = 1, #structure do
		local number = bit32.extract(n, structure[i][1], structure[i][2])
		table.insert(tuple, number)
	end
	return table.unpack(tuple)
end

function bitTools.saveStructure(structure, data)
	local n = 0
	for i = 1, #structure do
		n = bit32.bor(n, bit32.lshift(data[i], structure[i][1]))
	end

	return n
end

function bitTools.representStructure(structure)
	-- this function is used to represent bitwise structures
	-- example we just want to use the first 4 bits of a 32bit number,
	-- we can give it a table of {0, 4} to represent the first 4 bits
	-- or we can give it a table of {28, 4} to represent the last 4 bits

	local bits = ""
	local labels = ""
	-- strucutre is a table of tables that contains the start and length of the bit we want to extract
	-- though this is just a function to represent the structure, it is not a function to extract the bits
	for i = 1, #structure do
		local start = structure[i][1]
		local length = structure[i][2]
		for j = 1, length do
			bits = "X" .. bits
		end
		if type(start) == "string" then
			labels = labels .. start
		end
		labels = labels .. " "
		bits = " " .. bits
	end

	return labels, bits
end

function bitTools.to8bitBin(n)
	return get8bitBin(n)
end

function bitTools.to32bitBin(n)
	local str = ""
	str = str .. get8bitBin(bit32.extract(n, FOURTH_BYTE, BYTE_SIZE)) .. " "
	str = str .. get8bitBin(bit32.extract(n, THIRD_BYTE, BYTE_SIZE)) .. " "
	str = str .. get8bitBin(bit32.extract(n, SECOND_BYTE, BYTE_SIZE)) .. " "
	str = str .. get8bitBin(bit32.extract(n, FIRST_BYTE, BYTE_SIZE))
	return str
end

return bitTools
