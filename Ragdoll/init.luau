-- R15 ONLY AT THE MOMENT! 

export type Struct = {
    Enabled: (self: Struct, value: boolean) -> (),
    Destroy: (self: Struct) -> ()
}

type self = {
    _rigged: {
        motors: {[number]: Motor6D},
        sockets: {[number]: BallSocketConstraint}
    },

    _items: {
        root_part: BasePart,
        upper_torso: BasePart,
        lower_torso: BasePart,
        head: BasePart,
        humanoid: Humanoid,
    },

    _ancestry_connection: RBXScriptConnection,
    _character: Model?
}

local WAIT_TIME = 5

local Ragdoll = {}
Ragdoll.__index = Ragdoll

function Ragdoll:Enabled(value: boolean)
    self = self :: self

    local items = self._items

    items.root_part.CanCollide = not value 
    items.lower_torso.CanCollide = not value 
    items.upper_torso.CanCollide = not value
	items.head.CanCollide = value 

    if value then
        items.humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
        items.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    else
        items.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp, true)
        items.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    end
 
    for _, item in self._rigged.motors do
        item.Enabled = not value
    end

    for _, item in self._rigged.sockets do
        item.Enabled = value
    end

end

function Ragdoll:Destroy()
    self = self :: self & Struct
    if self._character == nil then return end 

    self:Enabled(false)

    if self._character then
        for _, item in self._character:GetDescendants() do
            if item.Name == "__RAGDOLL" then
                item:Destroy()
            end
        end
    end

    if self._ancestry_connection then
        self._ancestry_connection:Disconnect()
    end

    table.clear(self)
end

function Ragdoll:_Destroy()
    self = self :: self & Struct

    if self._ancestry_connection then
        self._ancestry_connection:Disconnect()
    end

    table.clear(self)
end

return function (character: Model): Struct?

    local root_part = character:WaitForChild("HumanoidRootPart", WAIT_TIME) :: BasePart
    local upper_torso = character:WaitForChild("UpperTorso", WAIT_TIME) :: BasePart
    local lower_torso = character:WaitForChild("LowerTorso", WAIT_TIME) :: BasePart
    local head = character:WaitForChild("Head", WAIT_TIME) :: BasePart
    local humanoid = character:WaitForChild("Humanoid", WAIT_TIME) :: Humanoid 

    if not (root_part and upper_torso and lower_torso and head) then return end

    local rigged = {
        motors = {},
        sockets = {},
    }

    for _, item in character:GetDescendants() do
        if item:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint")
            socket.Name = "__RAGDOLL"
            socket.Enabled = false

			if item.Name == "Waist" or item.Name == "Root" then
				socket.TwistLowerAngle = -20
				socket.TwistUpperAngle = 20
			else
				socket.TwistLowerAngle = -30
				socket.TwistUpperAngle = 30
			end

			local attach1 = Instance.new("Attachment")
            local attach2 = Instance.new("Attachment")

            attach1.Name = "__RAGDOLL"
            attach2.Name = "__RAGDOLL"

			attach1.Parent = item.Part0
			attach2.Parent = item.Part1

			socket.Parent = item.Parent
			socket.Attachment0 = attach1
			socket.Attachment1 = attach2

			attach1.CFrame = item.C0
			attach2.CFrame = item.C1

			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = if item.Parent.Name == "LowerTorso" then false else true

            rigged.motors[#rigged.motors + 1] = item
            rigged.sockets[#rigged.sockets + 1] = socket 
        end
    end

    local ancestry_connection: RBXScriptConnection

    local meta = setmetatable({
        _character = character,
        _rigged = rigged,
        _ancestry_connection = ancestry_connection,
        _items = {
            root_part = root_part,
            upper_torso = upper_torso,
            lower_torso = lower_torso,
            head = head,
            humanoid = humanoid
        }
    }, Ragdoll) :: any 

    ancestry_connection = character.AncestryChanged:Connect(function()
        if character.Parent == nil then
            Ragdoll._Destroy(meta) 
        end
    end)

    return meta
end