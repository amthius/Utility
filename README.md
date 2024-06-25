# Utility
Collection of useful utility for my projects.

# Installer for studio 
## ⚠️ Before installing ⚠️
- The default location is [ReplicatedStorage](https://create.roblox.com/docs/reference/engine/classes/ReplicatedStorage)
- Default name of folder is `Utility`
- If you have a folder in the default location with the same name as default, then change `StorageName` to something else.
- I do not recommend placing anything inside of the generated folder as there is a chance of your stuff being deleted/overwritten! However manually added instances wont be deleted (_and its children_). As long as its not a [ModuleScript](https://create.roblox.com/docs/reference/engine/classes/ModuleScript)
## Installation steps
1. Enable the command bar if its not already.
2. Paste the code below inside of it.
```luau
local Location = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")

HttpService.HttpEnabled = true
local StorageName = "Utility"

local RepositoryName = "amthius/Utility"
local Branch = "main"
local Repository = HttpService:JSONDecode(HttpService:GetAsync(`https://api.github.com/repos/{RepositoryName}/git/trees/{Branch}?recursive=1`)).tree
local RawUrl = `https://raw.githubusercontent.com/{RepositoryName}/main/`

local Storage = (Location:FindFirstChild("Utility") or Instance.new("Folder"))
Storage.Name = StorageName
Storage.Parent = Location

local Whitelisted = {}

for _, item in Storage:GetChildren() do
	if item:IsA("ModuleScript") then
		item:Remove()
	else
		Whitelisted[item] = true
	end
end

local Directory

local function build (path, index)
	local result: string = path[index]

	if not result then return end

	if result:find(".luau") then
		local instance_type = Instance.new("ModuleScript")
		instance_type.Name = result

		if Directory and result:find("init.") then
			local copy = Directory:Clone()

			for _, item in copy:GetChildren() do
				item.Parent = instance_type
			end

			instance_type.Name = Directory.Name
			instance_type.Parent = Directory.Parent
			copy:Remove()
			Directory:Remove()
		else
			instance_type.Name = instance_type.Name:gsub(".luau", "")
			instance_type.Parent = Directory
		end
		
		local rebuilt = ""
		
		for _, item in path do
			rebuilt = rebuilt .. `{item}/`
		end
		
		local result = HttpService:GetAsync(RawUrl..rebuilt:sub(1, -2))
		
		ScriptEditorService:UpdateSourceAsync(instance_type, function()
			return result
		end)
	
	elseif result then
		local instance_type = (Storage:FindFirstChild(result) or Instance.new("Folder"))
		instance_type.Name = result
		instance_type.Parent = Storage
		Directory = instance_type
	end

	local next = index + 1	
	build(path, next)
end

for _, item in Repository do
	local paths = item.path:split("/")
	build(paths, 1)
end

for _, item in Storage:GetChildren() do
	if Whitelisted[item] then continue end
	if item:IsA("Folder") and #item:GetChildren() == 0 then
		item:Remove()
	end
end
```
