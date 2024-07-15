local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerUtil = {}

local Callbacks = {
    PlayerAdded = {} :: {[number]: (player: Player) -> ()},
    PlayerRemoving = {} :: {[number]: (player: Player) -> ()},
    CharacterAdded = {} :: {[number]: (character: Model?) -> ()},
    LocalCharacterAdded = {} :: {[number]: (character: Model?) -> ()}
}

local Characters = {} :: {[Player]: RBXScriptConnection}

local function handle_callback(callback: string, instance: Model | Player)
    for _, callback in Callbacks[callback] do
        task.spawn(callback, instance) 
    end
end

local function character_hook(player: Player)
    if not Characters[player] then
        Characters[player] = player.CharacterAdded:Connect(function(character)
            handle_callback("CharacterAdded", character)
        end)
    end
end

function PlayerUtil.PlayerAdded(callback: (player: Player) -> ())
    Callbacks.PlayerAdded[#Callbacks.PlayerAdded + 1] = callback

    for _, player in Players:GetPlayers() do
        task.spawn(callback, player)
    end
end

function PlayerUtil.PlayerRemoving(callback: (player: Player) -> ())
    Callbacks.PlayerRemoving[#Callbacks.PlayerRemoving + 1] = callback
end

function PlayerUtil.CharacterAdded(callback: (character: Model?) -> ())
    Callbacks.CharacterAdded[#Callbacks.CharacterAdded + 1] = callback

    for _, player in Players:GetPlayers() do
        task.spawn(callback, player.Character)
        character_hook(player)
    end

end

function PlayerUtil.LocalCharacterAdded(callback: (character: Model?) -> ())
    assert(RunService:IsClient(), "LocalCharacterAdded only works for client.")
    local player = Players.LocalPlayer

    Callbacks.LocalCharacterAdded[#Callbacks.LocalCharacterAdded + 1] = callback

    local character = player.Character

    if character then
        task.spawn(callback, character)
    end
end

Players.PlayerAdded:Connect(function(player)
    handle_callback("PlayerAdded", player)

    if player.Character then
        handle_callback("CharacterAdded", player.Character)
    end

    character_hook(player)
end)

Players.PlayerRemoving:Connect(function(player)
    handle_callback("PlayerRemoving", player)

    if Characters[player] then
        Characters[player]:Disconnect()
        Characters[player] = nil
    end
end)

if RunService:IsClient() then
    Players.LocalPlayer.CharacterAdded:Connect(function(player)
        handle_callback("LocalCharacterAdded", player)
    end)
end

return PlayerUtil