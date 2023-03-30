local ProductClass = require(script.Parent.ProductClass)

export type Type = {
	mining_time: number,

	results: {[number]: ProductClass.Type}?,

	result: string?, -- only used if results is not specified
	count: number?, -- only used if results is not specified

	mining_particle: string?,

	required_fluid: string?,
	fluid_amount: number?,

	-- mining_trigger: Trigger, -- no docs explaining what these are
}

return {}
