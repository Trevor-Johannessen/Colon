function create(args)
	
	local shape = {}
	
	shape.x = args.x or 1
	shape.y = args.y or 1.
	shape.width = args.width or 10
	shape.height = args.height or 15
	shape.color = args.color or colors.red
	shape.sticky = args.sticky or false
	shape.type = "rectangle"
	
	function shape:draw(x_offset, y_offset)
		local oldx, oldy = term.getCursorPos()
		local save_background = term.getBackgroundColor()
		
		if shape.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		
		term.setBackgroundColor(shape.color)
		for i=0, shape.height-1 do
		
			term.setCursorPos(shape.x-x_offset, shape.y-y_offset+i)
			io.write(string.rep(" ", shape.width))
		end
		
		
		term.setBackgroundColor(save_background)
	end
	
	function shape:corrections()
		if type(shape.color) == "string" then
			shape.color = colors[shape.color]
		end 
		
		if shape.sticky == "true" or not type(shape.sticky) == "boolean" then
			shape.sticky = true
		else
			shape.sticky = false
		end
		
	end
	
	
	return shape
end