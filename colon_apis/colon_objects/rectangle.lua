template = require("colon_apis/colon_objects/template")
function create(args)
	
	local rectangle = template.create()
	
	rectangle.x = tonumber(args.x) or 1
	rectangle.y = tonumber(args.y) or 1.
	rectangle.width = tonumber(args.width) or 10
	rectangle.height = tonumber(args.height) or 15
	rectangle.color = args.color or colors.red
	rectangle.sticky = args.sticky or false
	rectangle.type = "rectangle"
	rectangle.name = args.name
	rectangle.hollow = args.hollow or false
	rectangle.character=args.char or " "
	rectangle.characterColor = args.charColor or colors.white
	
	if rectangle.characterColor then rectangle.characterColor = rectangle:convertColor(rectangle.characterColor, "int") end
	if rectangle.character:len() > 1 then rectangle:error("Character must be a single character long.") end

	function rectangle:draw(x_offset, y_offset)
		local oldx, oldy = term.getCursorPos()
		local save_background = term.getBackgroundColor()	
		if rectangle.sticky then 
			y_offset = 0 
			x_offset = 0
		end	 
		term.setTextColor(rectangle.characterColor)
		term.setBackgroundColor(rectangle.color)
		for i=0, rectangle.height-1 do
		
			term.setCursorPos(rectangle.x+x_offset, rectangle.y-y_offset+i)
			if rectangle.hollow and i ~= 0 and i ~= rectangle.height-1 then
				io.write(rectangle.character)
				term.setCursorPos(rectangle.x+x_offset+rectangle.width-1, rectangle.y-y_offset+i)
				io.write(rectangle.character)
			else
				io.write(string.rep(rectangle.character, rectangle.width))
			end
		end	
		term.setBackgroundColor(save_background)
	end

	rectangle:corrections(rectangle)
	
	return rectangle
end

return {
	create=create
	}