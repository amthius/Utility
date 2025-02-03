--!strict
type callback = (value: any, vinst: value?) -> ()

type value = {
	value: any,
	listeners: {callback},
}

return {
	state = function(x: any)
		local vinst = {value = x, listeners = {}}
		return vinst :: value
	end,

    destroy = function(v: value)
        table.clear(v)
    end,

	read = function(v: value)
		return v.value
	end,

	write = function(v: value, n: any)
		local original = v.value
		v.value = n

		local listeners = v.listeners
		if #listeners ~= 0 and original ~= n then
			for i = 1, #listeners do
				task.spawn(listeners[i], n, v)		
			end
		end

	end,

	fwrite = function(v: value, n: any)
		v.value = n

		local listeners = v.listeners
		if #listeners ~= 0 then
			for i = 1, #listeners do
				task.spawn(listeners[i], n)		
			end
		end

	end,

	listen = function(v: value, c: callback)
		table.insert(v.listeners, c)
	end,

}