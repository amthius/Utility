-- Credits: https://github.com/Fraktality/Destructor

local Destructor = {}
Destructor.__index = Destructor

local function destroy_table(tbl: any)
	local method = tbl.Destroy or tbl.destroy
	
	if method then
		method()
	end
	
	for _, v in tbl do
		if typeof(v) == "table" then
			destroy_table(v)
		end
	end
end

local function destroy_connection(connection)
	connection:Disconnect()
end

local finalizers = {
	["thread"] = task.cancel,
	["function"] = task.spawn,
	["Instance"] = game.Destroy,
	["RBXScriptConnection"] = destroy_connection,
	["table"] = destroy_table
}

function Destructor:Add(item: any)
	if typeof(item) ~= "table" then
		self[item] = finalizers[typeof(item)]
	else
		for _, v in item do
			self[v] = finalizers[typeof(v)]
		end
	end
end

function Destructor:Remove(item: any)
	self[item] = nil
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
