template = require("colon_apis/colon_objects/template")
function create(args)
	
	local rectangle = template.create()
	
	rectangle.x = args.x or 1
	rectangle.y = args.y or 1.
	rectangle.width = args.width or 10
	rectangle.height = args.height or 15
	rectangle.color = args.color or colors.red
	rectangle.sticky = args.sticky or false
	rectangle.type = "rectangle"
	
	function rectangle:draw(x_offset, y_offset)
		local oldx, oldy = term.getCursorPos()
		local save_background = term.getBackgroundColor()	
		if rectangle.sticky then 
			y_offset = 0 
			x_offset = 0
		end	 
		term.setBackgroundColor(rectangle.color)
		for i=0, rectangle.height-1 do
		
			term.setCursorPos(rectangle.x-x_offset, rectangle.y-y_offset+i)
			io.write(string.rep(" ", rectangle.width))
		end	
		term.setBackgroundColor(save_background)
	end
	
	function rectangle:corrections()
		if type(rectangle.color) == "string" then
			rectangle.color = colors[rectangle.color]
		end 
		if rectangle.sticky == "true" or not type(rectangle.sticky) == "boolean" then
			rectangle.sticky = true
		else
			rectangle.sticky = false
		end
	end
	rectangle:corrections()
	
	return rectangle
end

return {
	create=create
	}