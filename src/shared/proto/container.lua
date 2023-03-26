local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local LocalPlayer = Players.LocalPlayer
local storage_gui = Assets.storage_gui
local item = Assets.item

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Building = require(script.Parent.Building)
local Item = require(script.Parent.Parent.Item)

local ActiveGui = nil
local Selected = nil

export type Type = {
	InventorySize: number,

	Items: {Item.Type},
}

local container = {} :: Type
container.__index = container
setmetatable(container, Building)

function container.new()
	local self = setmetatable({
		InventorySize = 0,

		Items = {},
	}, container)

	return self
end

function container:SwapItems(index1, index2)
	local item1 = self.Items[index1]
	local item2 = self.Items[index2]
	self.Items[index1] = item2
	self.Items[index2] = item1
end

function container:MergeItems(index1, index2)
	local item1 = self.Items[index1]
	local item2 = self.Items[index2]
	if item1.ItemId == item2.ItemId then
		local quantity = item1.Quantity + item2.Quantity
		if quantity > item1.MaxQuantityInStack then
			item1.Quantity = item1.MaxQuantityInStack
			item2.Quantity = quantity - item1.MaxQuantityInStack
		else
			item1.Quantity = quantity
			self.Items[index2] = nil
		end
	end
end

function container:Rerender()
	if ActiveGui then
		for _, slot in pairs(ActiveGui.Frame.Slots:GetChildren()) do
			if slot:IsA("Frame") then
				slot:Destroy()
			end
		end
		local slot = ActiveGui.Frame.Slots.Grid.Slot
		for i = 1, self.InventorySize do
			local new_slot = slot:Clone()
			local item = item:Clone()
			item.Name = tostring(i)
			if self.Items[i] then
				item.Image.Image = self.Items[i].Sprite
				item.Count.Text = self.Items[i].Quantity
			end
			item.MouseButton1Click:Connect(function()
				if Selected then
					Selected.Image.ImageTransparency = 0
					if self.Items[i] then
						if self.Items[i].ItemId == self.Items[tonumber(Selected.Name)].ItemId then
							self:MergeItems(i, tonumber(Selected.Name))
						else
							self:SwapItems(i, tonumber(Selected.Name))
						end
					else
						self:SwapItems(i, tonumber(Selected.Name))
					end
					Selected = nil
					self:Rerender()
				else
					if self.Items[i] then
						Selected = item
						item.Image.ImageTransparency = 0.5
					end
				end
			end)
			item.Parent = new_slot
			new_slot.Parent = ActiveGui.Frame.Slots
		end
	end
end

function container:Interact()
	ActiveGui = storage_gui:Clone()
	ActiveGui.Parent = PlayerGui
	self:Rerender()
	ActiveGui.Enabled = true
end

function container:Unfocus()
	if ActiveGui then
		ActiveGui:Destroy()
		ActiveGui = nil
	end
end

return container :: Type | Building.Type
