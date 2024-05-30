local Defaults = require(script.Defaults)

return function (class: string)
    local new = Instance.new(class) 

    if Defaults[class] then
        for property, value in Defaults[class] do
            new[property] = value
        end
    end

    return new
end