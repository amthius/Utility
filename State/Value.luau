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

local Value = {} :: Struct
(Value :: any).__index = Value

function Value:Get()
	local this: self = self :: any

	return this._value
end

function Value:Set(value: any)
	local this: self = self :: any

	local previous = this._value
	this._value = value    

	if this._callback and this._value ~= previous then
		this._callback(value)
	end
end

function Value:Listen(callback: (value: any) -> ())
	local this: self = self :: any

	this._callback = callback
end

return function(value): Struct
	return setmetatable({
		_value = value,
		_callback = nil,
	}, Value) :: any
end