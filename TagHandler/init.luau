export type Struct = {
    Subscribe: (self: Struct, func: (tagged: Instance) -> (), can_initalize: boolean?) -> (),
    Unsubscribe: (self: Struct, func: (tagged: Instance) -> ()) -> (),
    Destroy: (call_unsubscribe: boolean?) -> (),
}

type self = {
    _tag: string,
    _threads: {[Instance]: thread},
    _added_rbxsignal: RBXScriptConnection?, 
    _removed_rbxsignal: RBXScriptConnection?, 
    _callback_unsubscribe: (tagged: Instance) -> ()?
}

local CollectionService = game:GetService("CollectionService")

local TagHandler = {}
TagHandler.__index = TagHandler 

function TagHandler:Subscribe(func: (tagged: Instance) -> (), can_initalize: boolean?)
    can_initalize = can_initalize or false

    local this: self = self 

    if not this._added_rbxsignal then
        this._added_rbxsignal = CollectionService:GetInstanceAddedSignal(this._tag):Connect(function(tagged: Instance) 
            this._threads[tagged] = task.spawn(function()
                func(tagged)
            end)
        end)
    end

    if not can_initalize then return end

    for _, tagged in CollectionService:GetTagged(this._tag) do
        this._threads[tagged] = task.spawn(function()
            func(tagged)
        end)
    end

end

function TagHandler:Unsubscribe(func: (tagged: Instance) -> ())
    local this: self = self 

    if not this._removed_rbxsignal then
        this._removed_rbxsignal = CollectionService:GetInstanceRemovedSignal(this._tag):Connect(function(tagged: Instance) 
            this._threads[tagged] = task.spawn(function()
                func(tagged)
            end)
        end)
    end

    this._callback_unsubscribe = func

end

function TagHandler:Destroy(call_unsubscribe: boolean?)
    local this: self = self

    if this._added_rbxsignal and typeof(this._added_rbxsignal) == "RBXScriptConnection" then
        this._added_rbxsignal:Disconnect()
    end

    if this._removed_rbxsignal and typeof(this._added_rbxsignal) == "RBXScriptConnection" then
        this._removed_rbxsignal:Disconnect()
    end

    if call_unsubscribe then
        for _, tagged in CollectionService:GetTagged(this._tag) do
            tagged:RemoveTag(this._tag)

            if this._callback_unsubscribe then
                this._callback_unsubscribe(tagged)
            end

        end
    end

    for _, thread in this._threads do
        if typeof(thread) == "thread" then
            task.cancel(thread)
        end
    end

end

return function (tag: string): Struct
    return setmetatable({
        _tag = tag,
        _threads = {},
        _added_rbxsignal = nil,
        _removed_rbxsignal = nil,
        _callback_unsubscribe = nil
    }, TagHandler) :: any
end