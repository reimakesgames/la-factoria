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
