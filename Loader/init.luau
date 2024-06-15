return function(parent: Instance)
    for _, item in parent:GetDescendants() do
        if not item:IsA("ModuleScript") then continue end
        require(item)
    end
end