local CollectionService = game:GetService("CollectionService")
local TagHandler = {}

function TagHandler.register(tag)
	local self = setmetatable({}, {__index = TagHandler})
	
	self._tag = tag
	self._threads = {}

	return self
end

function TagHandler:Subscribe(func)
	
	for _, tagged in CollectionService:GetTagged(self._tag) do
		self._threads[tagged] = task.spawn(function()
			func(tagged)
		end)
	end
	
	self._added:Connect(CollectionService:GetInstanceAddedSignal(self._tag), function(tagged)
		self._threads[tagged] = task.spawn(function()
			func(tagged)
		end)
	end)

end

function TagHandler:Unsubscribe(func)
	self._removed:Connect(CollectionService:GetInstanceRemovedSignal(self._tag), function(tagged)
		task.cancel(self._threads[tagged])
		
		if func then
			func(tagged)
		end
	end)
	
end

function TagHandler:Destroy()
	for _, tagged in CollectionService:GetTagged(self._tag) do
		tagged:RemoveTag(self._tag)
	end
	
	self._added:Destroy()	
	self._removed:Destroy()
	
	for _, thread in self._threads do
		task.cancel(thread)
	end
	
	table.clear(self)
end

return TagHandler