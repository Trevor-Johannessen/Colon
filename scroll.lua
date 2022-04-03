

function create(args)
	
	local scroll = {}
	
	
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
	
	if args.direction ~= nil then 
		if string.lower(args.direction) == "right" then
			scroll.direction = -1
			scroll.pointer = string.len(scroll.text)
		end
	end
	
	
	
	function scroll:draw(offset_x, offset_y, screen_height, tick)
		tick = tick or scroll.speed
		if tick % scroll.speed == 0 and scroll.y >= offset_y and scroll.y <= screen_height+offset_y then
			offset_x = offset_x or 0 -- default parameter x = 0
			offset_y = offset_y or 0 -- default parameter y = 0
			term.setCursorPos(scroll.x - offset_x, scroll.y - offset_y)
			io.write(string.sub(scroll.text, scroll.pointer) .. string.sub(scroll.text, 1, scroll.pointer))
		end
	end
	
	
	function scroll:update(obj_args)
		scroll:draw(obj_args["x_offset"], obj_args["y_offset"], obj_args["screen_height"], obj_args["tick"])
		
		scroll.pointer = scroll.pointer + scroll.direction
		if scroll.pointer == string.len(scroll.text) and scroll.direction == 1 then scroll.pointer = 1
		elseif scroll.pointer == 1 and scroll.direction == -1 then scroll.pointer = string.len(scroll.text) end
	end
	
	
	function scroll:swap_direction()
		scroll.direction = scroll.direction * -1
	end
	
	
	
	return scroll
end
