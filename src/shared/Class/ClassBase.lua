export type Type = {
	name: string,
	type: string,
	-- localized_description: string,
	-- localized_name: string,
	-- order: number,
}

local ClassBase = {}
ClassBase.__index = ClassBase

-- No constructor because abstract class

return ClassBase
