function create(args)
	
	local text = {}
	
	text.x = tonumber(args.x) or 0 -- x coordinate of text
	text.y = tonumber(args.y) or 0 -- y coordinate of text
	text.str = string.sub(args.text, 2, -2) or "default text"
	text.visible = args.visible or true
	text.dynamic = false
	text.interactive = false
	text.height = 1
	text.name = args.name
	text.type = "text"
	text.color = args.color or term.getTextColor()
	text.background = colors[args.background] or term.getBackgroundColor()
	text.sticky = args.sticky or false
	
	function text:draw(x_offset, y_offset)
	
		local save_cursor = {term.getCursorPos()}
		local save_text = term.getTextColor()
		local save_background = term.getBackgroundColor()
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		
		
		if text.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		
		term.setCursorPos(text.x-x_offset, text.y-y_offset)
		term.setTextColor(text.color)
		term.setBackgroundColor(text.background)
		--io.write(var.replaceStr(text.str))
		sharedFunctions.parse_color(text.str)
		--io.write(text.str)
		term.setCursorPos(save_cursor[1], save_cursor[2])
		term.setTextColor(save_text)
		term.setBackgroundColor(save_background)
	end
	
	-- correction to clean inputs
	function text:corrections()
		-- quick color format correction
		if type(text.color) == "string" then
			text.color = colors[text.color]
		end 
		if type(text.background) == "string" then
			text.background = colors[text.background]
		end 
		
		if text.sticky == "true" or not type(text.sticky) == "boolean" then
			text.sticky = true
		else
			text.sticky = false
		end
		
	end
	
	return text
end