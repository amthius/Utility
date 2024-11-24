local Players = game:GetService("Players")

local PlayerUtil = {}

local Callbacks = {
    PlayerAdded = {} :: {[number]: (player: Player) -> ()},
    PlayerRemoving = {} :: {[number]: (player: Player) -> ()},
    CharacterAdded = {} :: {[number]: (character: Model?, player: Player) -> ()},
    CharacterRemoving = {} :: {[number]: (character: Model, player: Player) -> ()},
}

local CharacterSignals = {
    added = {} :: {[Player]: RBXScriptConnection},
    removing = {} :: {[Player]: RBXScriptConnection}
}

local function handle_callback(callback: string, ...: any)
    for _, callback in Callbacks[callback] do
        task.spawn(callback, ...) 
    end
end

local function character_hook(player: Player)
    if not CharacterSignals.added[player] then
        CharacterSignals.added[player] = player.CharacterAdded:Connect(function(character)
            handle_callback("CharacterAdded", character, player)
        end)
    end

    if not CharacterSignals.removing[player] then
        CharacterSignals.removing[player] = player.CharacterRemoving:Connect(function(character)
            handle_callback("CharacterRemoving", character, player)
        end)
    end
end

function PlayerUtil.PlayerAdded(callback: (player: Player) -> ())
    table.insert(Callbacks.PlayerAdded, callback)

    for _, player in Players:GetPlayers() do
        task.spawn(callback, player)
    end
end

function PlayerUtil.PlayerRemoving(callback: (player: Player) -> ())
    table.insert(Callbacks.PlayerRemoving, callback)
end

function PlayerUtil.CharacterRemoving(callback: (character: Model, player: Player) -> ())
    table.insert(Callbacks.CharacterRemoving, callback)
end

function PlayerUtil.CharacterAdded(callback: (character: Model?, player: Player) -> ())
    table.insert(Callbacks.CharacterAdded, callback)

    for _, player in Players:GetPlayers() do
        task.spawn(callback, player.Character, player)
        character_hook(player)
    end

end

Players.PlayerAdded:Connect(function(player)
    handle_callback("PlayerAdded", player)

    local character = player.Character

    if character then
        handle_callback("CharacterAdded", character, player)
    end

    character_hook(player)
end)

Players.PlayerRemoving:Connect(function(player)
    handle_callback("PlayerRemoving", player)

    if CharacterSignals.added[player] then
        CharacterSignals.added[player]:Disconnect()
        CharacterSignals.added[player] = nil
    end

    if CharacterSignals.removing[player] then
        CharacterSignals.removing[player]:Disconnect()
        CharacterSignals.removing[player] = nil
    end
end)

return PlayerUtil