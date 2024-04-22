--!strict

export type Cooldown<T...> = {
	Check: (self: Cooldown<T...>, Player, Object: string, time: number) -> boolean,
	ResetCooldown: (self: Cooldown<T...>, Player, Object: string) -> (),
	Remove: (self: Cooldown<T...>, Player) -> (),
}

local Cooldown = {}
Cooldown.__index = Cooldown

function Cooldown.new<T...>(): Cooldown<T...>
	local self = setmetatable({}, Cooldown)
	self.users = {}
	return self :: any
end

function Cooldown:Check(player: Player, object: string, time: number): boolean
	self.users[player] = self.users[player] or {}
	self.users[player][object] = self.users[player][object] or 0

	if os.clock() - self.users[player][object] > time then
		self.users[player][object] = os.clock()
		return true
	end
	
	return false
end

function Cooldown:ResetCooldown(player: Player, object: string)
	self.users[player][object] = 0
end

function Cooldown:Remove(player: Player)
	self.users[player] = nil
end

return Cooldown