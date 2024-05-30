
--!strict

--[=[
-- Example.
local ProbabilityTbl = require(PATH_TO_MODULE)

-- This would be best inside a module.
-- ! Its important that a new table is returned each time, since the module will write and modify it each use.

local function ExampleTbl()
    return {
        {
            name = "Common",
            value = 1 / 5,
        },
    
        {
            name = "Uncommon",
            value = 1 / 10,
        },
    
    } :: ProbabilityTbl.TableStruct
end

local Total = {}

-- Simple roll function utilizing the module.
local function Roll(x: number)
    for i = 1, x do
        local result = ProbabilityTbl(ExampleTbl(), 1, nil)

        if result then
            if not Total[result.name] then
                Total[result.name] = {
                    name = result.name,
                    amount = 0,
                    probability = result.probability
                }
            end
            Total[result.name].amount += 1
        end
    end

    for name, data in Total do
        print(`{name}: 1 in {1 / data.probability} (x{data.amount})`)
    end

end

Roll(10)
]=]--

export type TableStruct = {
    [number]: {
        name: string,
        value: number,
    }
} 

type result = {
    name: string,
    value: number,
    probability: number,
}

return function (tbl: TableStruct, luck: number, min_lockout: number?): result?

    for i = 1, #tbl do
        (tbl :: any)[i].probability = tbl[i].value

        local countdown = (#tbl + 1) - i        

        if min_lockout and tbl[i].value > min_lockout then
            continue
        end
        
        tbl[i].value = tbl[i].value * (luck ^ (1 / countdown))
    end

    local total = 0

    for _, item in tbl do
        total = total + item.value
    end

    for index, item in tbl do
        tbl[index].value = item.value / total 
    end

    local cumulative = {}
    local sum = 0

    for _, item in tbl do
        sum = sum + item.value
        cumulative[#cumulative + 1] = sum
    end

    local roll = math.random()

    for index, probability in cumulative do
        if roll < probability then
            return tbl[index] :: result
        end
    end

    return
end