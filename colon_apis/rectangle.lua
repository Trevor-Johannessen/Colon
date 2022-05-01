function create(args)
	
	local shape = {}
	
	shape.x = args.x or 1
	shape.y = args.y or 1.
	shape.length = args.length or 5
	shape.width = args.width or 10
	shape.color = args.color or colors.red
	shape.sticky = args.sticky or false
	
	function shape:draw(x_offset, y_offset)
		local oldx, oldy = term.getCursorPos()
		local save_background = term.getBackgroundColor()
		
		if shape.sticky then 
				y_offset = 0 
				x_offset = 0
		end
		
		term.setBackgroundColor(shape.color)
		for i=1, shape.y do
		
			term.setCursorPos(shape.x-x_offset, shape.y-y_offset+i)
			io.write(term.blit(" ", shape.x))
		end
		
		
		term.setBackgroundColor(save_background)
	end
	
	function rectangle:corrections()
		if type(text.color) == "string" then
			text.color = colors[text.color]
		end 
		
		if shape.sticky == "true" or not type(shape.sticky) == "boolean" then
			shape.sticky = true
		else
			shape.sticky = false
		end
		
	end
	
	return shape
end