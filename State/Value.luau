--!strict

export type Struct = {
	Set: (self: Struct, value: any) -> (),
	Get: (self: Struct) -> (),
	Listen: (self: Struct, callback: (value: any) -> ()) -> (),
}

type self = {
	_value: any,
	_callback: (value: any) -> ()
}

local Value = {}
Value.__index = Value

function Value:Get()
	self = self :: self
	return self._value
end

function Value:Set(value: any)
	self = self :: self

	local previous = self._value
	self._value = value    

	if self._callback and self._value ~= previous then
		self._callback(value)
	end
end

function Value:Listen(callback: (value: any) -> ())
	self = self :: self
	self._callback = callback
end

return function(value): Struct
	return setmetatable({
		_value = value,
		_callback = nil,
	}, Value) :: any
end
