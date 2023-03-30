export type Type = {
	type: "item" | "fluid", -- default: "item"
	show_details_in_recipe_tooltip: boolean?, -- default: true

	-- since you can't load a type from a string, we have to do this, which means overloading the type!! i hate this

	name: string,
	amount: number?, -- default: 1
	probability: number?, -- default: 1
	amount_min: number?, -- used if amount is not specified
	amount_max: number?, -- used if amount is not specified
	catalyst_amount: number?, -- default: 0

	temperature: number?, -- default: 15
	fluidbox_index: number?, -- default: 0 means no specific fluidbox
	--[[
		Amount that should not be affected by productivity modules (not yielded from bonus production) and should not be included in the item production statistics.

		If this ItemProductPrototype is used in a recipe, the catalyst amount is calculated automatically based on the ingredients and results.[1]
	]]
	--[[
		in game, there's coal liquefaction, which requires heavy oil to be the catalyst, then it produces light oil and petroleum gas and more heavy oil
		i'm not sure how this works in game, but i'm assuming that the catalyst amount is the amount of heavy oil that is used up in the process
		or a more better explanation is the catalyst (15 units of heavy) doesn't get 'used up' in the process,
		so it's not included in the item production statistics and productivity modules don't affect it
		15 units of input heavy oil, outputs 45 units of heavy oil
		so the input is the catalyst, and the output is output - catalyst

		also the second sentence literally explains the process smh
	]]
}

return {}
