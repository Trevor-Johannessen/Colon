

function create(args)
	
	local scroll = {}
	
	
	scroll.scrolls_right = 1
	scroll.text = "default text "
	scroll.speed = 10
	scroll.x = 1
	scroll.y = 1
	scroll.pointer = 1
	
	if args.direction ~= nil then 
		if string.lower(args.direction) == "right" then
			scroll.direction = -1
			scroll.pointer = string.len(scroll.text)
		else
			scroll.direction = 1
		end
	end
	
	print("direction = " .. scroll.direction)
	
	if args.text ~= nil then scroll.text = args.text end
	if args.speed ~= nil then scroll.speed = args.speed end
	if args.x ~= nil then scroll.x = args.x end
	if args.y ~= nil then scroll.y = args.y end
	
	
	function scroll:print(offset_x, offset_y, tick)
		if tick % scroll.speed == 0 then
			offset_x = offset_x or 0 -- default parameter x = 0
			offset_y = offset_y or 0 -- default parameter y = 0
			term.setCursorPos(scroll.x + offset_x, scroll.y + offset_y)
			io.write(string.sub(scroll.text, scroll.pointer) .. string.sub(scroll.text, 1, scroll.pointer))
			scroll.pointer = scroll.pointer + scroll.direction
			
			if scroll.pointer == string.len(scroll.text) and scroll.direction == 1 then scroll.pointer = 1
			elseif scroll.pointer == 1 and scroll.direction == -1 then scroll.pointer = string.len(scroll.text) end
		end
	end
	
	function scroll:swap_direction()
		scroll.direction = scroll.direction * -1
	end
	
	
	
	return scroll
end
