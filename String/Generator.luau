--!native

local chars = {}

for i = 48, 57 do 
	table.insert(chars, string.char(i))
end

for i = 65, 90 do 
	table.insert(chars, string.char(i))
end

for i = 97, 122 do 
	table.insert(chars, string.char(i))
end

return function (length: number)
	if length < 20 then
		local str = ""
		local all = #chars

		for i = 1, length do
			str = str..chars[math.random(all)]
		end

		return str
	else
		local result = {}

		for _ = 1, length do
			local rand = math.random(1, #chars)
			table.insert(result, chars[rand])
		end

		return table.concat(result)
	end
end
