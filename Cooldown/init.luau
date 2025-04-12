--!strict
local Players = game:GetService("Players")

local Users = {}

Players.PlayerRemoving:Connect(function(player: Player)
	if Users[player] then
		Users[player] = nil
	end
end)

return function (player: Player, name: string, time: number)
	if not Users[player] then
		Users[player] = {[name] = os.clock()}
		return true
	elseif not Users[player][name] then
		Users[player] = {[name] = os.clock()}
		return true
	elseif os.clock() - Users[player][name] > time then
		Users[player][name] = os.clock()
		return true
	end
	return false
end