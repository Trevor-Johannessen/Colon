function create()
    local template = {}
    local screen_width, screen_height = term.getSize()

	local colorsDict = {
		{hex="0", string="white", int=colors.white},
		{hex="1", string="orange", int=colors.orange},
		{hex="2", string="magenta", int=colors.magenta},
		{hex="3", string="lightBlue", int=colors.lightBlue},
		{hex="4", string="yellow", int=colors.yellow},
		{hex="5", string="lime", int=colors.lime},
		{hex="6", string="pink", int=colors.pink},
		{hex="7", string="gray", int=colors.gray},
		{hex="8", string="lightGray", int=colors.lightGray},
		{hex="9", string="cyan", int=colors.cyan},
		{hex="a", string="purple", int=colors.purple},
		{hex="b", string="blue", int=colors.blue},
		{hex="c", string="brown", int=colors.brown},
		{hex="d", string="green", int=colors.green},
		{hex="e", string="red", int=colors.red},
		{hex="f", string="black", int=colors.black}
	}

    --[[ 
        FORMAT:
        {c:color:text} -- color
        {b:color:text} -- background
        they can be nested.
    ]]
    function template:parseColor(str)
        colorString = string.rep(template:convertColor(term.getTextColor(), "hex"), str:len())
        backgroundString = string.rep(template:convertColor(term.getBackgroundColor(), "hex"), str:len())
        while true do
            a,b = str:find("%b{}") -- get inside block
            if not a and not b then break end
            c = str:sub(a,b) -- get color
            d, e = c:find("%b::")
            if not d and not e then break end
            f = c:sub(e+1,-2) -- the middle of the string = the end of the color substring to the end of the c substring-1
            g = str:sub(a+1,a+1)
            -- I just want to point out that I was doing b-a-1 instead of -2 and I feel bad about that

            if g=="c" then
                colorString = colorString:sub(1, a-1) .. string.rep(template:str_to_hex(c:sub(d+1,e-1)), f:len()) .. colorString:sub(b+1) -- build the color string
                backgroundString = backgroundString:sub(1,a-1) .. backgroundString:sub(a+e+1,b-1) .. backgroundString:sub(b)

            elseif g=="b" then
                backgroundString = backgroundString:sub(1, a-1) .. string.rep(template:str_to_hex(c:sub(d+1,e-1)), f:len()) .. backgroundString:sub(b+1) -- build the background
                colorString = colorString:sub(1,a-1) .. colorString:sub(a+e+1,b-1) .. colorString:sub(b)
            else
                break
            end
            str = str:sub(1,a-1) .. f .. str:sub(b+1) -- build the string
        end
        --term.blit(str, colorString, backgroundString)
        return str, colorString, backgroundString
    end	


    function template:mysplit (inputstr, sep)
            if sep == nil then
                    sep = "%s"
            end
            local t={}
            for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                    table.insert(t, str)
            end
            return t
    end	

	-- convert color into "hex", "string", "int"
    function template:convertColor(color, abcdefg)
		for i=1, #colorsDict do
			for k, v in next, colorsDict[i] do
				if color == v then return colorsDict[i][abcdefg] end
			end
		end
    end


    function template:corrections(obj)
        if type(obj.color) == "string" then
            obj.color = colors[obj.color]
        end 
        if type(obj.background) == "string" then
            obj.background = colors[obj.background]
        end 

        if type(obj.sticky) ~= "boolean" then
            if obj.sticky == "true" then
                obj.sticky = true
            else
                obj.sticky = false
            end
        end


        -- check for center args x
        if obj.x == "center" then obj.x = screen_width/2 end
        local first, last, middle = string.find(obj.x, "center[+-]()%d*")
        if middle ~= nil then
            local number = string.sub(obj.x, middle-1)
            obj.x = math.ceil(screen_width/2) + tonumber(number)
        end

        -- check for center args y
        if obj.y == "center" then obj.y = screen_height/2 end
        local first, last, middle = string.find(obj.y, "center[+-]()%d*")
        if middle ~= nil then
            local number = string.sub(obj.y, middle-1)
            obj.y = math.ceil(screen_height/2) + tonumber(number)
        end	


    end


    function template:message(message)
        local orgx, orgy = term.getCursorPos()
        term.setCursorPos(1, 19)
        term.clearLine()
        io.write(message)
        term.setCursorPos(orgx, orgy)
    end


    function template:monus(a, b)
        return ((a-b)<0 and 0 or (a-b))
    end

    return template
end

return{
	create=create
	}