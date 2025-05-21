local Prefabs = {}

local TrackedElements = {} :: any

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace:WaitForChild("Camera") :: Camera
local CurrentResolution = 1156 
local ResolutionMax = 1.5
local ResolutionMin = 0.5 

local function HandleScale(multiplier: number)
	return math.clamp((Camera.ViewportSize.Y / CurrentResolution) * multiplier, ResolutionMin, ResolutionMax)
end

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
	uiscale.Scale = HandleScale(multiplier :: any)
	uiscale:SetAttribute("Multiplier", multiplier)

	table.insert(TrackedElements, uiscale)
	return uiscale
end

function Prefabs.UIStroke(multiplier: number?)
	multiplier = multiplier or 1

	local uistroke = Instance.new("UIStroke")
	uistroke.Thickness = HandleScale(multiplier :: any) + 1
	uistroke:SetAttribute("Multiplier", multiplier)
	table.insert(TrackedElements, uistroke)
	return uistroke 
end

local function update_scale(inst: Instance, ratio: number)
	if inst:IsA("UIScale") then
		inst.Scale = ratio
	elseif inst:IsA("UIStroke") then
		inst.Thickness = ratio + 1
	end
end

local function update()
	local UIScales = TrackedElements

	for i = #UIScales, 1, -1 do
		local item = UIScales[i]
		if item.Parent == nil then table.remove(UIScales, i); continue end
		update_scale(item, HandleScale(1))
	end
end

update()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)

return Prefabs