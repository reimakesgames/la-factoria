
local fastInstance = {}

function fastInstance.new<T>(name, properties)
	local instance = Instance.new(name)

	local deferredParent = nil

	if type(properties) == "table" then
		for key, value in properties do
			if key == "Children" then
				for childName, childProperties in value do
					local child = fastInstance.new(childName, childProperties)
					child.Parent = instance
				end
			elseif key == "Parent" then
				deferredParent = value
			else
				instance[key] = value
			end
		end
	end

	if deferredParent then
		instance.Parent = deferredParent
	end

	return instance :: T
end

return fastInstance
