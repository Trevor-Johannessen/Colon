function create(args)
	
	local shape = {}
	
	shape.x = args.x or 1
	shape.y = args.y or 1.
	shape.length = args.length or 5
	shape.width = args.width or 10
	shape.color = args.color or colors.red
	
	
	function shape:draw(x_offset, y_offset)
		local oldx, oldy = term.getCursorPos()
		local save_background = term.getBackgroundColor()
		
		term.setBackgroundColor(shape.color)
		for i=1, shape.y do
			term.setCursorPos(shape.x-offset_x, shape.y-offset_y+i)
			io.write(term.blit(" ", shape.x))
		end
		
		
		term.setBackgroundColor(save_background)
	end
	
	function rectangle:corrections()
	end
	
	return shape
end