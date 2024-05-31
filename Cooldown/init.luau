--!strict

export type Struct = {
	Check: (self: Struct, Player: Player, Object: string, time: number) -> boolean,
	ResetCooldown: (self: Struct, Player: Player, Object: string) -> (),
	Remove: (self: Struct, Player: Player) -> (),
}

type self = {
	_users: {}
}

local Cooldown = {}
Cooldown.__index = Cooldown

function Cooldown:Check(player: Player, object: string, time: number): boolean
	self = self :: self

	self._users[player] = self._users[player] or {}
	self._users[player][object] = self._users[player][object] or 0

	if os.clock() - self._users[player][object] > time then
		self._users[player][object] = os.clock()
		return true
	end
	
	return false
end

function Cooldown:ResetCooldown(player: Player, object: string)
	self = self :: self
	self._users[player][object] = 0
end

function Cooldown:Remove(player: Player)
	self = self :: self
	self._users[player] = nil
end

return function (): Struct
	return setmetatable({
		_users = {}
	}, Cooldown) :: any  
end
