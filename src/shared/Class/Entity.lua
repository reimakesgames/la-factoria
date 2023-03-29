local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassBase = require(ReplicatedStorage.Shared.Class.ClassBase)

export type Entity = {

}

local Entity = {}
Entity.__index = Entity
setmetatable(Entity, ClassBase)

-- Abstract class

return Entity
