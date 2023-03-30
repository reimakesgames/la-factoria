local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassBase = require(ReplicatedStorage.Shared.Class.ClassBase)
local EntityClassFlags = require(ReplicatedStorage.Shared.Types.EntityClassFlags)
local ItemToPlace = require(ReplicatedStorage.Shared.Types.ItemToPlace)
local MinableProperties = require(ReplicatedStorage.Shared.Types.MinableProperties)

export type Type = {
	tile_height: number,
	tile_width: number,
	allow_copy_paste: boolean,
	additional_pastable_properties: {[number]: string},
	emissions_per_second: number,
	flags: EntityClassFlags.Type,

	alert_icon_scale: number,
	alert_icon_shift: Vector2,

	build_grid_size: number, -- uint8
	created_smoke: ParticleEmitter,
	fast_replaceable_group: string,
	next_upgrade: string,
	placeable_by: ItemToPlace.Type | {[number]: ItemToPlace.Type},
	minable: MinableProperties.Type,

	map_color: Color3,
	enemy_map_color: Color3,
	friendly_map_color: Color3,
	selectable_in_game: boolean,
	shooting_cursor_size: number,

	build_sound: Sound,
	open_sound: Sound,
	close_sound: Sound,
	rotated_sound: Sound,

	vehicle_impact_sound: Sound,
	working_sound: Sound,
	mined_sound: Sound,
	mining_sound: Sound,

	-- autoplace: AutoplaceSpecification, -- commented out because it's only used in map generation, (which is unnecessary for this project to work)
	-- build_base_evolution_requirement: number, -- factorio docs doesn't have this documented but is included in the wiki
	-- collision_box: BoundingBox, -- commented out because models have their own collision boxes, and this game is 3D and has jumping
	-- collision_mask: CollisionMask, -- smh C++ requires u to do this, skill issue roblox ontop tbh
	-- created_effect: Trigger -- no docs explaining what these are
	-- drawing_box: BoundingBox,
	-- hit_visualization_box: BoundingBox, -- no thank you
	-- map_generator_bounding_box: BoundingBox, -- no thank you
	-- protected_from_tile_building: boolean, -- lol no tiles for u dumbass
	-- radius_visualisation_specification: RadiusVisualisationSpecification, -- wtf??
	-- remains_when_mined: string | {[number]: string},
	-- remove_decoratives: string,
	-- selection_box: BoundingBox,
	-- selection_priority: number,
	-- sticker_box: BoundingBox,
	-- subgroup: string,
} & ClassBase.Type

local Entity = {}
Entity.__index = Entity
setmetatable(Entity, ClassBase)

-- Abstract class

return Entity
