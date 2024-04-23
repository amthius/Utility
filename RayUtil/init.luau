local RayUtil = {}
local DISTANCE_MAX = 1000 

function RayUtil.Raycast(origin: Vector3, location: Vector3, params: RaycastParams, distance: number?): RaycastResult
    local direction = (location - origin).Unit * (distance or DISTANCE_MAX)
    return workspace:Raycast(origin, direction, params)
end

function RayUtil.ValidPosition(result: RaycastResult, position: Vector3): Vector3
    return if result and result.Position then result.Position else position
end

return RayUtil