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

local SelectionGroup = {} :: Struct
(SelectionGroup :: any).__index = SelectionGroup

function SelectionGroup:Default(value: any)
	local this: self = self :: any 

	this._default = value
end

function SelectionGroup:Add(identifier: IdentifierT, state: Value.Struct)
	local this: self = self :: any
	this._table[identifier] = state
end

function SelectionGroup:Remove(Indexer: any)
	local this: self = self :: any
	this._table[Indexer] = nil
end

function SelectionGroup:Set(Indexer: IdentifierT, value: any)
	local this: self = self :: any
	
	for index, item in this._table :: ItemT do
		if index == Indexer then
			item:Set(value)
			this._selected = {identifier = index, state = item}
		else
			item:Set(this._default)
		end
	end
end

function SelectionGroup:Reset()
	local this: self = self :: any
	
	if this._selected.identifier then
		this._selected.state:Set(this._default)
	end
	
	this._selected = nil :: any
end

function SelectionGroup:Get()
	local this: self = self :: any
	
	if this._selected then
		return this._selected
	else
		return nil
	end
end

return function(tbl: {}): Struct
	return setmetatable({
		_table = tbl,
		_default = nil,
		_selected = nil,
	}, SelectionGroup) :: any
end