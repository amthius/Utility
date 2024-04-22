--!strict

local MathUtil = {}

function MathUtil.RotatedTranslation(angle: number, offset: number): Vector3
	return CFrame.Angles(0, math.rad(angle), math.rad(angle)) * CFrame.new(0, offset, 0).Position
end

function MathUtil.Normalize(min: number, max: number, val: number): number
    return (val - min) / (max - min)
end

return MathUtil