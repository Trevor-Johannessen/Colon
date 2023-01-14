template = require("colon_apis/colon_objects/template")
screen_width, screen_height = term.getSize() -- dimensions of screen

function monus(a, b)
	return ((a-b)<0 and 0 or (a-b))
end

function create(args)
	
	local scroll = template.create()
	
	
	scroll.scrolls_right = 1
	scroll.text = string.sub(args.text, 2, -2) or "default text "
	scroll.speed = tonumber(args.speed) or 3	
	scroll.x = tonumber(args.x) or 1
	scroll.y = tonumber(args.y) or 1
	scroll.pointer = 1
	scroll.direction = 1
	scroll.dynamic = true
	scroll.interactive = false
	scroll.height = 1
	scroll.name = args.name
	scroll.type = "scroll"
	scroll.color = args.color or term.getTextColor()
	scroll.background = args.background or term.getBackgroundColor()
	scroll.sticky = args.sticky or false
	
	if args.direction ~= nil then 
		if string.lower(args.direction) == "right" then
			scroll.direction = -1
			scroll.pointer = string.len(scroll.text)
		end
	end
	
	
	
	function scroll:draw(x_offset, y_offset, tick)
		tick = tick or scroll.speed
		if scroll.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		if tick % scroll.speed == 0 and scroll.y >= y_offset and scroll.y <= screen_height+y_offset then
			x_offset = x_offset or 0 -- default parameter x = 0
			y_offset = y_offset or 0 -- default parameter y = 0
			local pointer = scroll.pointer
			term.setCursorPos(scroll.x + x_offset, scroll.y - y_offset)
			term.setTextColor(scroll.color)
			term.setBackgroundColor(scroll.background)
			local spaceLeft = monus(screen_width-scroll.x, x_offset)
			if spaceLeft < #scroll.text then
				io.write(string.sub(scroll.text, pointer, pointer+spaceLeft))
			else io.write(string.sub(scroll.text, pointer) .. string.sub(scroll.text, 1, pointer)) end
		end
	end
	
	
	function scroll:update(obj_args)
		scroll:draw(obj_args["x_offset"], obj_args["y_offset"], obj_args["tick"])
		
		scroll.pointer = scroll.pointer + scroll.direction
		if scroll.pointer == string.len(scroll.text) and scroll.direction == 1 then scroll.pointer = 1
		elseif scroll.pointer == 1 and scroll.direction == -1 then scroll.pointer = string.len(scroll.text) end
	end
	
	
	function scroll:swap_direction()
		scroll.direction = scroll.direction * -1
	end
	
	return scroll
end

return{
	create=create
}