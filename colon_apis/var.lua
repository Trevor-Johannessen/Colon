
function initalize()
	variables = {}
end


function create(args)
	setVariable(args.name, args.value)
end

function setVariable(name, value)
	variables[name] = value
end


function removeVariable(name)
	variables[name] = nil
end


function getVariable(name)
	return variables[name]
end

-- given a string replaces any variables marked in the string
function replaceStr(str)
	local replaceable = {}
	
	--for i, s in string.gmatch(str, "()~.-~()") do
		--print(string.sub(str, i, s))
	while true do
		local i, s = string.gmatch(str, "()~.-~()")()
		if not i and not s then break end
		--[[
		print("i = ", i)
		print("s = ", s)
		print("substring = ", str:sub(i+1, s-2))
		print("first = ", str:sub(1, i-1))
		print("get var = ", getVariable(str:sub(i+1, s-2)))
		print("last = ", str:sub(s+1))
		]]
		str = str:sub(1, i-1) .. getVariable(str:sub(i+1, s-2)) .. str:sub(s+1)
		--print("str = ", str)
	end
	return str
end