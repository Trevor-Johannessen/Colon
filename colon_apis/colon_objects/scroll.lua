template = require("colon_apis/colon_objects/template")
screen_width, screen_height = term.getSize() -- dimensions of screen

function monus(a, b)
	return ((a-b)<0 and 0 or (a-b))
end

function create(args)
	
	local scroll = template.create(args)
	
	scroll.scrolls_right = 1
	scroll.text = args.text or "default text "
	scroll.speed = tonumber(args.speed) or 3	
	scroll.x = tonumber(args.x) or 1
	scroll.y = tonumber(args.y) or 1
	scroll.pointer = 1
	if args.direction == "left" then scroll.direction = -1 else scroll.direction = 1 end
	scroll.dynamic = true
	scroll.interactive = false
	scroll.height = 1
	scroll.width = tonumber(args.width) or string.len(scroll.text)
	scroll.name = args.name
	scroll.type = "scroll"
	scroll.color = args.color or term.getTextColor()
	scroll.background = tonumber(args.background) or term.getBackgroundColor()
	scroll.sticky = args.sticky or false
	
	if args.direction ~= nil then 
		if string.lower(args.direction) == "right" then
			scroll.direction = -1
			scroll.pointer = string.len(scroll.text)
		end
	end
	if string.len(scroll.text) < scroll.width then
		scroll.text = scroll.text .. string.rep(" ", scroll.width - string.len(scroll.text))
	end
	
	function scroll:draw(x_offset, y_offset)
		if scroll.hidden then return end
		if scroll.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		if scroll.y >= y_offset and scroll.y <= screen_height+y_offset then
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
		if scroll.hidden then return end
		if obj_args["tick"] % scroll.speed == 0 then
			scroll:draw(obj_args["x_offset"], obj_args["y_offset"])
			
			scroll.pointer = scroll.pointer + scroll.direction
			if scroll.pointer == string.len(scroll.text) and scroll.direction == 1 then scroll.pointer = 1
			elseif scroll.pointer == -string.len(scroll.text) and scroll.direction == -1 then scroll.pointer = string.len(scroll.text) end
		end
		return {"redraw"}
	end
	
	
	function scroll:swap_direction()
		scroll.direction = scroll.direction * -1
	end
	return scroll
end

return{
	create=create
}