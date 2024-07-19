export type Struct = {
    Subscribe: (self: Struct, func: (tagged: Instance) -> (), can_initialize: boolean?) -> (),
    Unsubscribe: (self: Struct, func: (tagged: Instance) -> ()) -> (),
    Destroy: (self: Struct, call_unsubscribe: boolean?) -> (),
    Tagged: (self: Struct, item: Instance) -> boolean,
    Assign: (self: Struct, item: Instance) -> (),
    Remove: (self: Struct, item: Instance) -> (),
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

function TagHandler:Subscribe(func: (tagged: Instance) -> (), can_initialize: boolean?)
    self = self :: self
    can_initialize = can_initialize or false


    if not self._added_rbxsignal then
        self._added_rbxsignal = CollectionService:GetInstanceAddedSignal(self._tag):Connect(function(tagged: Instance) 
            self._threads[tagged] = task.spawn(function()
                func(tagged)
            end)
        end)
    end

    if not can_initialize then return end

    for _, tagged in CollectionService:GetTagged(self._tag) do
        self._threads[tagged] = task.spawn(function()
            func(tagged)
        end)
    end

end

function TagHandler:Unsubscribe(func: (tagged: Instance) -> ())
    self = self :: self

    if not self._removed_rbxsignal then
        self._removed_rbxsignal = CollectionService:GetInstanceRemovedSignal(self._tag):Connect(function(tagged: Instance) 
            self._threads[tagged] = task.spawn(function()
                func(tagged)
            end)
        end)
    end

    self._callback_unsubscribe = func

end

function TagHandler:Destroy(call_unsubscribe: boolean?)
    self = self :: self

    if self._added_rbxsignal and typeof(self._added_rbxsignal) == "RBXScriptConnection" then
        self._added_rbxsignal:Disconnect()
    end

    if self._removed_rbxsignal and typeof(self._added_rbxsignal) == "RBXScriptConnection" then
        self._removed_rbxsignal:Disconnect()
    end

    if call_unsubscribe then
        for _, tagged in CollectionService:GetTagged(self._tag) do
            tagged:RemoveTag(self._tag)

            if self._callback_unsubscribe then
                self._callback_unsubscribe(tagged)
            end

        end
    end

    for _, thread in self._threads do
        if typeof(thread) == "thread" then
            task.cancel(thread)
        end
    end

end

function TagHandler:Tagged(item: Instance)
    self = self :: self
    return CollectionService:HasTag(item, self._tag)
end

function TagHandler:Assign(item: Instance)
    self = self :: self
    return CollectionService:AddTag(item, self._tag)
end

function TagHandler:Remove(item: Instance)
    self = self :: self
    return CollectionService:RemoveTag(item, self._tag)
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