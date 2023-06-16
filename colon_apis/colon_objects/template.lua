function create(args)
    local template = {}

    if args then
        template.hidden = args.hidden == "true"
    end

    template.screen_width, template.screen_height = term.getSize()
    template.colon = require("colon")
	template.colorsDict = {
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

    function template:boolArgument(arg)
        if type(arg) == "boolean" then
            return arg
        end
        return arg == "true"
    end

	-- convert color into "hex", "string", "int"
    function template:convertColor(color, type)
		for i=1, #template.colorsDict do
			for k, v in next, template.colorsDict[i] do
				if color == v then return template.colorsDict[i][type] end
			end
		end
        template:error("Color " .. color .. " is not supported.")
    end
	
	function template:correctColor(color)
		if type(color) == "string" then
            if colors[color] == nil then template:error("correctColor - " .. color .. " is not a valid color.") end
            return colors[color]
        elseif type(color) == "number" then
            return color
        elseif type(color) == "nil" then
            return nil
        end
        template:error("correctColor - A non-(number or string) was provided. (provided " .. type(color) .. ")")
	end

    function template:corrections(obj)
        if not tonumber(obj.color) then
            obj.color = colors[obj.color]
        end 
        if not tonumber(obj.background) then
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
        if obj.x == "center" then obj.x = template.screen_width/2 end
        local first, last, middle = string.find(obj.x, "center[+-]()%d*")
        if middle ~= nil then
            local number = string.sub(obj.x, middle-1)
            obj.x = math.ceil(template.screen_width/2) + tonumber(number)
        end

        -- check for center args y
        if obj.y == "center" then obj.y = template.screen_height/2 end
        local first, last, middle = string.find(obj.y, "center[+-]()%d*")
        if middle ~= nil then
            local number = string.sub(obj.y, middle-1)
            obj.y = math.ceil(template.screen_height/2) + tonumber(number)
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
	
	function template:augment(obj, args)
		for k, v in next, args["augments"] do
			obj=v(obj, args)
		end
	end

    function template:error(str)
        if not template.page then template.page = "nopage" end
        if not template.name then template.name = "noname" end
        error(template.page .. "-" .. template.name .. ": " .. str)
    end

    function template:colors(args)
        for k, v in next, args do
            if  k:match("colors?[0-9]*") == k or
                k:match("textColors?[0-9]*") == k or
                k:match("backgrounds?[0-9]*") == k
            then
                template[k] = v
            end
        end
    end
    function template:essentials(args)
        template.name = args.name or ""
        if args.hidden then args.hidden = args.hidden:lower() end
        template.hidden = args.hidden == "true"
        if args.sticky then args.sticky = args.sticky:lower() end
        template.sticky = args.sticky == "true"
        return template
    end

    function template:coords(args)
        return template:coordinate(args)
    end
    function template:coordinate(args)
        template.x = tonumber(args.x) or 0
        template.y = tonumber(args.y) or 0
        return template
    end

    function template:dim(args)
        return template:dimensions(args)
    end
    function template:dimensions(args)
        template.height = tonumber(args.height) or 0
        template.width = tonumber(args.width) or 0
        return template
    end

    function template:sprite(args)
        sprite = require("colon_apis/colon_objects/sprite")
        local sprite_args = {
            x=args.x,
			y=args.y,
			width=args.width,
			height=args.height
		}
		local dest = "src"
		if args.usingTemplate == "true" then dest = "template" end
		sprite_args[dest] = args.spriteFile
		template.sprite = sprite.create(sprite_args)
        return template
    end

    function template:inBounds(args)
        return  args.mouse_x >= template.x+args.x_offset and 
            args.mouse_x < template.x+template.width+args.x_offset and
            args.mouse_y >= template.y-args.y_offset and
            args.mouse_y < template.y+template.height-args.y_offset
    end

    return template
end

return{
	create=create
	}