type Flags = "not-rotatable" | "placeable-player" | "placeable-neutral" | "placeable-enemy" | "placeable-off-grid" |
	"player-creation" | "building-direction-8-way" | "filter_directions" | "fast-replaceable-no-build-while-moving" |
	"breaths-air" | "not-repairable" | "not-on-map" | "not-blueprintable" | "not-deconstructable" | "hidden" |
	"hide-alt-info" | "fast-replaceable-no-cross-type-while-moving" | "not-flammable" | "no-automated-item-removal" |
	"no-automated-item-insertion" | "no-copy-paste" | "not-selectable-in-game" | "not-upgradable" | "not-in-kill-statistics" |
	"not-in-made-in"

export type Type = {
	[number]: Flags
}

return {}
