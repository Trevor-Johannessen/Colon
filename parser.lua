function parse(line)
    line = escapeCharacters(line)
    local line_type
    line_type, line = getType(line)
    if not line_type then return end
    local args = processArguments(line)
    args.type = line_type
    return args
end

function escapeCharacters(str)
    return str:gsub("\\(%d+)", function (m) return string.char(m) end)
end

function getType(line)
    local colon_pos = string.find(line, ":")
	if not colon_pos then return end
    local obj_type = line:sub(1,colon_pos-1)
    if obj_type ~= "" then return obj_type, line:sub(colon_pos+1) end
    return
end

function processArguments(line)
    local arguments = line:gmatch("[^,]+")
    local args = lexArguments(arguments)
    args = parseArguments(args)
    return args
end

function lexArguments(arguments)
    local args = {}
    local in_quote = false
    local quote_string = ""
    for current in arguments do
        if in_quote then
            quote_string = quote_string .. " " .. current
            if current:find("[^\\]\"") or current=="\"" then
                in_quote = false 
                table.insert(args, quote_string)
            else
                quote_string = quote_string .. ","
            end
        else
            current = removeSpaces(current)
            local quote_pos = current:find("[^\\]\"")
            if quote_pos then
                if not current:sub(quote_pos+1):find("[^\\]\"") then
                    in_quote = true
                    quote_string = current .. ","
                end
            end
            if not in_quote then table.insert(args, current) end
        end
    end
    return args
end

function removeSpaces(line)
    if line:sub(1,1) == " " then line = line:sub(line:find("[^ ]"),-1) end -- remove leading spaces
    if line:sub(#line,#line) == " " then line = line:sub(1, line:find(" +$")-1) end -- remove trailing spaces
    return line
end

function parseArguments(input)
    local args = {}
    for _, arg in next, input do 
        if not arg:find("=") then error("Could not parse argument. Missing '='.") end
        local name = arg:sub(1, arg:find("=")-1)
        local value = arg:sub(arg:find("=")+1)
        if value:sub(1,1) == "\"" then -- this is bad because it assumes strings like ' "one-side ' don't exist, probably.
            value = value:sub(2,-2)
        end
        value = value:gsub("\\\"", "\"")
        --print(name .. " = " .. value)
        --os.sleep(1)
        args[name] = value
    end
    return args
end

return {
    parse=parse
}