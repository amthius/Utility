--!strict

local RayUtil = {}
local DISTANCE_MAX = 1000 

function RayUtil.Raycast(origin: Vector3, direction: Vector3, params: RaycastParams, distance: number?): RaycastResult | Vector3
    direction = direction * (distance or DISTANCE_MAX)

    local result = workspace:Raycast(origin, direction, params)
    local intersection = result and result.Position or origin + direction

    return if result then result else intersection 
end

function RayUtil.Position(raycast: RaycastResult | Vector3): Vector3
    return if typeof(raycast) == "RaycastResult" then raycast.Position else raycast
end

return RayUtil