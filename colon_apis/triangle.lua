function create(args)
	
	local shape = {}
	
	shape.point1 = args.point1 or 1
	shape.point2 = args.point2 or 1
	shape.point3 = args.point3 or 1
	
	
	function shape:draw(x_offset, y_offset)
		
		
		
	end
	
	
	return shape
end