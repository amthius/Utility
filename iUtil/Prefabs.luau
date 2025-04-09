--!strict

local Prefabs = {}

local Storage = {
	UIElements = {} :: any,
	UIScaleCounter = 0,
}

local Ratios = {
	{
		scale = 0.5,
		max = 500,
	},
	
	{
		scale = 1,
		max = 1085,
	},
	
	{ 
		scale = 1.3333,
		max = 1445,
	},
	
	{ 
		scale = 2,
		max = 2165,
	},

}

local CurrentRatio = nil
local Camera = workspace:WaitForChild("Camera")
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

function Prefabs.ScreenGui(name: string)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = name
	ScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
	ScreenGui.ScreenInsets = Enum.ScreenInsets.None
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui
	return ScreenGui
end

function Prefabs.ContainerFrame()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.Transparency = 1
	return frame
end

function Prefabs.OriginFrame()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0, 0)
	frame.Transparency = 1
	return frame
end

function Prefabs.UIScale(multiplier: number?)
	multiplier = multiplier or 1

	local uiscale = Instance.new("UIScale")
	uiscale:SetAttribute("Multiplier", multiplier)
	table.insert(Storage.UIElements, uiscale)
	return uiscale
end

function Prefabs.UIStroke(multiplier: number?)
	multiplier = multiplier or 1

	local uistroke = Instance.new("UIStroke")
	uistroke:SetAttribute("Multiplier", multiplier)
	table.insert(Storage.UIElements, uistroke)
	return uistroke 
end

local function update_scale(inst: UIScale | UIStroke)
	for i = 1, #Ratios do
		local item = Ratios[i]
		if item.max >= Camera.ViewportSize.Y then
			if inst:IsA("UIScale") then
				inst.Scale = item.scale * inst:GetAttribute("Multiplier") :: any
			elseif inst:IsA("UIStroke") then
				inst.Thickness = item.scale * inst:GetAttribute("Multiplier") :: any
			end
			break
		end
	end
end

game:GetService("RunService").Heartbeat:Connect(function()
	
	local NewRatio = nil
	
	for i = 1, #Ratios do
		local item = Ratios[i]
		if item.max >= Camera.ViewportSize.Y then
			NewRatio = item
			break
		end
	end
	
	if CurrentRatio == NewRatio then return end
	CurrentRatio = NewRatio
	
	local UIScales = Storage.UIElements
	local amount = #UIScales
	
	if Storage.UIScaleCounter ~= amount then
		Storage.UIScaleCounter = amount
		
		for i = #UIScales, 1, -1 do
			local item = UIScales[i]
			if item.Parent == nil then table.remove(UIScales, i); continue end
			update_scale(item)
		end
	end
	
end)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	local UIScales = Storage.UIElements
	
	for i = #UIScales, 1, -1 do
		local item = UIScales[i]
		update_scale(item)
	end
end)

return Prefabs