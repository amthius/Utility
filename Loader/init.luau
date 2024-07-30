return function(parent: Instance)
    for _, item in parent:GetDescendants() do
        if not item:IsA("ModuleScript") then continue end
        local success = pcall(require, item)

        if not success then
            error(`{item} failed to load`)
        end
    end
end