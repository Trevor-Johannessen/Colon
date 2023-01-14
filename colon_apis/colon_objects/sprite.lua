screen_width, screen_height = term.getSize() -- dimensions of screen

function create(args)
	
	local sprite = {}
	sprite.x = tonumber(args.x) or 0
	sprite.y = tonumber(args.y) or 0
	sprite.file = "" -- TODO: make default image and place here
	sprite.dynamic = false
	sprite.interative = false
	sprite.name = args.name
	sprite.type = "sprite"
	sprite.sticky = args.sticky or false
	
	
	if args.src ~= nil then
		sprite.src = args.src
	end
	
	print("src = ", sprite.src)
	local f = io.open(sprite.src)
	sprite.height = tonumber(f:read())
	sprite.width = tonumber(f:read())
	sprite.img = f:read()
	io.close(f)
	
	
	
	function sprite:draw(x_offset, y_offset)
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		
		if sticky then 
			x_offset = 0 
			y_offset = 0
		end
		
		local firstx, firsty = term.getCursorPos()
		local current_char = 1
		term.setCursorPos(sprite.x+x_offset, sprite.y-y_offset)
		
		if sprite.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		
		for i = 1, sprite.height do
			term.blit(string.rep(" ", sprite.width), string.rep("1", sprite.width), string.sub(sprite.img, current_char, current_char+sprite.width-1 ) )
			current_char = current_char + sprite.width
			term.setCursorPos(sprite.x+x_offset, sprite.y+i-y_offset)
		end
		
		term.setCursorPos(firstx, firsty)
	
	end
	
	
	-- grabs each 'step' letter in string
	function grab(str, offset)
		-- step = width
		-- returns string of length height
		local output = ""
		
		for i = offset, string.len(str), sprite.width do
			output = output .. string.sub(str, i, i)
		end
		
		return output
	end
	
	function sprite:rotate270()
		
		local final_str = ""
		
		for i = 1, sprite.width do
			final_str = final_str .. string.reverse(grab(sprite.img, i))
		end
		
		local hold = sprite.height
		sprite.height = sprite.width
		sprite.width = hold
		sprite.img = final_str
	end
	
	
	function sprite:rotate180()
		sprite.img = string.reverse(sprite.img)
	end
	
	
	function sprite:rotate90()
		sprite:rotate270()
		sprite:rotate180()
	end
	
	
	function sprite:vmirror()
	
		local new_str = ""
		
		for i = 1, string.len(sprite.img), sprite.width do
			new_str = new_str .. string.reverse(string.sub(sprite.img, i, i + sprite.width-1))
		end
		
		sprite.img = new_str
	end
	
	
	function sprite:hmirror()
		sprite:vmirror()
		sprite:rotate180()
	end
	
	
	function sprite:setImage(newFile)
		local f = io.open(newFile)
		sprite.height = tonumber(f:read())
		sprite.width = tonumber(f:read())
		sprite.img = f:read()
		io.close(f)
	end
	
	function sprite:corrections()
		if sprite.sticky == "true" or not type(sprite.sticky) == "boolean" then
			sprite.sticky = true
		else
			sprite.sticky = false
		end
	end
	
	
	sprite:corrections()
	
	return sprite
end

return {
	create=create
	}
