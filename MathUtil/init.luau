--!strict

local MathUtil = {}

function MathUtil.RotatedTranslation(angle: number, offset: number): Vector3
	return CFrame.Angles(0, math.rad(angle), math.rad(angle)) * CFrame.new(0, offset, 0).Position
end

function MathUtil.Normalize(min: number, max: number, val: number): number
    return (val - min) / (max - min)
end

function MathUtil.Reflect(vector: Vector3, normal: Vector3)
	return -2 * vector:Dot(normal) * normal + vector
end 

return MathUtil