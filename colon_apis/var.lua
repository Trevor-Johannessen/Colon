variables = {}

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
	
	for i in string.gmatch(str, "~.-~") do
		--print(i)
		table.insert(replaceable, i)
	end

	for k, v in pairs(replaceable) do
		--print(v)
		--print(getVariable(string.sub(v, 2, -2)))
		if getVariable(string.sub(v, 2, -2)) then
			str = string.gsub(str, v, tostring(getVariable(string.sub(v, 2, -2))))
		end
	end
end