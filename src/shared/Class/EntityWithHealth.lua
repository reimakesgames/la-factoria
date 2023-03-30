local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Entity = require(ReplicatedStorage.Shared.Class.Entity)
local Console = require(ReplicatedStorage.Shared.Console)
local Loot = require(ReplicatedStorage.Shared.Types.Loot)
local World = require(ReplicatedStorage.Shared.World)

export type Type = {
	max_health: number, -- defaults to 10
	healing_per_tick: number?, -- defaults to 0

	hide_resistances: boolean?, -- defaults to true

	repair_sound: Sound?, -- defaults to the default repair sound
	repair_speed_modifier: number?, -- defaults to 1

	alert_when_damaged: boolean?, -- defaults to true
	create_ghost_on_death: boolean?, -- defaults to true
	loot: Loot.Type?, -- items that are dropped to the floor when the entity dies

	-- attack_reaction: AttackReaction, -- no docs explaining what these are
	-- dying_explosion: string?, -- unnecessary for this project (for now)
	-- corpse: string, -- unnecessary for this project (for now)
	-- damaged_trigger_effect: Trigger, -- no docs explaining what these are
	-- dying_trigger_effect: Trigger, -- no docs explaining what these are
	-- random_corpse_variation: boolean?, -- unnecessary for this project (for now)
} & Entity.Type

local EntityWithHealth = {}
EntityWithHealth.__index = EntityWithHealth
setmetatable(EntityWithHealth, Entity)

function EntityWithHealth:Destroy()
	-- !important: this is a temporary demo implementation, a more robust implementation will be needed in the future
	self.__destroying = true
	if self.__model then
		self.__model:Destroy()
		self.__model = nil
	end

	World:RemoveTileByUniqueId(self.__uniqueBuildingId)
	table.clear(self)
end

function EntityWithHealth:Damage(value)
	local health = self:GetHealth()
	local newHealth = health - value
	Console:Print("Default", newHealth)

	if self.alert_when_damaged then
		self:Alert()
	end

	if newHealth <= 0 then
		self:Die()
	else
		self:SetHealth(newHealth)
	end
end

function EntityWithHealth:GetHealth()
	return self.health
end

function EntityWithHealth:SetHealth(value)
	self.health = value
end

function EntityWithHealth:Die()
	if self.create_ghost_on_death then
		self:CreateGhost()
	end

	if self.loot then
		self:DropLoot()
	end

	ReplicatedStorage.Assets.audio.place:Play()

	self:Destroy()
end

function EntityWithHealth:Alert()
	ReplicatedStorage.Assets.audio.warn:Play()
end

return EntityWithHealth
