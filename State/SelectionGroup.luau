--!strict

local Value = require(script.Parent.Value)
type ItemT = {[any]: Value.Struct}
type IdentifierT = string | Instance | number

export type Struct = {
	Default: (self: Struct, value: any) -> (),
	Reset: (self: Struct) -> (),
	Add: (self: Struct, identifier: IdentifierT, state: Value.Struct) -> (),
	Remove: (self: Struct, Indexer: IdentifierT) -> (),
	Set: (self: Struct, Indexer: any, value: any) -> (),
	Get: (self: Struct) -> {identifier: IdentifierT, state: Value.Struct}?,
}

type self = {
	_table: {},
	_default: any?,
	_selected: {identifier: string, state: Value.Struct}
}

local SelectionGroup = {}
SelectionGroup.__index = SelectionGroup

function SelectionGroup:Default(value: any)
	self = self :: self
	self._default = value
end

function SelectionGroup:Add(identifier: IdentifierT, state: Value.Struct)
	self = self :: self
	self._table[identifier] = state
end

function SelectionGroup:Remove(Indexer: any)
	self = self :: self
	self._table[Indexer] = nil
end

function SelectionGroup:Set(Indexer: IdentifierT, value: any)
	self = self :: self
	
	for index, item in self._table :: ItemT do
		if index == Indexer then
			item:Set(value)
			self._selected = {identifier = index, state = item}
		else
			item:Set(self._default)
		end
	end
end

function SelectionGroup:Reset()
	self = self :: self
	
	if self._selected.identifier then
		self._selected.state:Set(self._default)
	end
	
	self._selected = nil :: any
end

function SelectionGroup:Get()
	self = self :: self

	if self._selected then
		return self._selected
	else
		return nil :: any
	end
end

return function(tbl: {}): Struct
	return setmetatable({
		_table = tbl,
		_default = nil,
		_selected = nil,
	}, SelectionGroup) :: any
end
