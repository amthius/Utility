--!strict

export type Struct = {
	Set: (self: Struct, value: any, force: boolean?) -> (),
	Get: (self: Struct) -> (),
	Listen: (self: Struct, callback: (value: any) -> ()) -> (),
}

type self = {
	_value: any,
	_callbacks: {[number]: (value: any) -> ()}
}

local Value = {}
Value.__index = Value

function Value:Get()
	self = self :: self
	return self._value
end

function Value:Set(value: any, force: boolean?)
	self = self :: self
	force = force or false

	local previous = self._value
	self._value = value    

	if self._value ~= previous or force then
		for _, item in self._callbacks do
			task.spawn(function()
				item(value)
			end)
		end
	end

end

function Value:Listen(callback: (value: any) -> ())
	self = self :: self
	local callbacks = self._callbacks

	callbacks[#callbacks + 1] = callback
end

return function(value): Struct
	return setmetatable({
		_value = value,
		_callbacks = {},
	}, Value) :: any
end
