-- Credits: https://github.com/Fraktality/Destructor
local Destructor = {}
Destructor.__index = Destructor

local finalizers = {
	["thread"] = task.cancel,
	["function"] = task.spawn,
	["Instance"] = game.Destroy,
	["RBXScriptConnection"] = (function(connection) connection:Disconnect() end),
}

function Destructor:Add(item: any)
	self[item] = finalizers[typeof(item)]
	return item
end

function Destructor:Remove(item: any)
	self[item] = nil
	return item
end

function Destructor:Destroy()
	for item, finalizer in self do
		finalizer(item)
	end
	table.clear(self)
end

return function()
	return setmetatable({}, Destructor)
end