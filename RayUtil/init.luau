--!strict

local UserInputService = game:GetService("UserInputService")
local Camera = workspace:WaitForChild("Camera") :: Camera

local RayUtil = {}

function RayUtil.Raycast(
    origin: Vector3,
    direction: Vector3,
    max_distance: number,
    params: RaycastParams?
)
    local result = workspace:Raycast(
        origin, 
        direction * max_distance, 
        params or RaycastParams.new()
    )

    if result then
        return result
    else
        return {Position = origin + direction * max_distance}
    end

end

function RayUtil.RayFromView(distance: number, params: RaycastParams?)
    local mouse_pos = UserInputService:GetMouseLocation()
    local viewport_ray = Camera:ViewportPointToRay(mouse_pos.X, mouse_pos.Y)

    return RayUtil.Raycast(
        viewport_ray.Origin,
        viewport_ray.Direction, 
        distance, 
        params)
end

return RayUtil