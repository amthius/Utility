export type Struct = {
	Enable: (self: Struct, bool: boolean) -> (),
	Destroy: (self: Struct) -> ()
}

type RigidInstances = "Weld" | "Motor6D" | "RigidConstraint" | "WeldConstraint"
type self = {[number]: Instance}

local RigidUtil = {}
RigidUtil.__index = RigidUtil

function RigidUtil:Enable(bool: boolean)
	self = self :: self

	for _, item in self do
		if item:IsA("Attachment") then continue end
		item.Enabled = bool
	end
end

function RigidUtil:Destroy()
	self = self :: self

	for _, item in self do
		item:Destroy()
	end

	table.clear(self)
end

return function(class_name: RigidInstances, root: BasePart, objects: {[number]: BasePart}): Struct
	local storage = {} 

	if class_name == "RigidConstraint" then
		for _, item in objects do
			if not item:IsA("BasePart") or item == root then continue end

			local rigid = Instance.new("RigidConstraint")
			local att0 = Instance.new("Attachment")
			local att1 = Instance.new("Attachment")

			att0.CFrame = root.CFrame:ToObjectSpace(item.CFrame)

			rigid.Attachment0 = att0
			rigid.Attachment1 = att1

			att0.Parent = root 
			att1.Parent = item 
			rigid.Parent = root 

			storage[#storage + 1] = rigid
			storage[#storage + 1] = att0 
			storage[#storage + 1] = att1 
		end
	elseif class_name == "WeldConstraint" then
		for _, item in objects do
			if not item:IsA("BasePart") or item == root then continue end

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root 
			weld.Part1 = item
			weld.Parent = root 

			storage[#storage + 1] = weld 
		end
	else
		for _, item in objects do
			if not item:IsA("BasePart") or item == root then continue end

			local weld = Instance.new(class_name)
			weld.Part0 = root 
			weld.Part1 = item 
			weld.C0 = root.PivotOffset
			weld.C1 = item.CFrame:ToObjectSpace(root.CFrame) * root.PivotOffset
			weld.Parent = root 

			storage[#storage + 1] = weld 
		end
	end

	return setmetatable(storage, RigidUtil) :: any
end