

function create(args)
	
	local sprite = {}
	sprite.x = tonumber(args.x) or 0
	sprite.y = tonumber(args.y) or 0
	sprite.file = "" -- TODO: make default image and place here
	sprite.dynamic = false
	sprite.interative = false
	sprite.name = args.name
	sprite.type = "sprite"
	
	if args.src ~= nil then
		sprite.src = args.src
	end
	
	local f = io.open(sprite.src)
	sprite.height = tonumber(f:read())
	sprite.width = tonumber(f:read())
	sprite.img = f:read()
	io.close(f)
	
	
	
	function sprite:draw(offset_x, offset_y)
		offset_x = offset_x or 0 -- default parameter values
		offset_y = offset_y or 0
	
		local firstx, firsty = term.getCursorPos()
		local current_char = 1
		term.setCursorPos(sprite.x-offset_x, sprite.y+0-offset_y)
		
		for i = 1, sprite.height do
			term.blit(string.rep(" ", sprite.width), string.rep("1", sprite.width), string.sub(sprite.img, current_char, current_char+sprite.width-1 ) )
			current_char = current_char + sprite.width
			term.setCursorPos(sprite.x-offset_x, sprite.y+i-offset_y)
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
	
	--[[
	--These should not have their own function. For readability use rotate THEN draw.
	function sprite:draw90(input)
	
		local str = input
		if str == nil then
			str = sprite.img
		end
		
		
		
		
		local final_str = ""
		
		for i = 1, sprite.width do
			final_str = final_str .. grab(str, i)
		end
		
		
		term.setCursorPos(sprite.x, sprite.y)
		local current_char = 1
		
		for i = 1, sprite.width do
			term.blit(string.rep(" ", sprite.height), string.rep("1", sprite.height), string.sub(final_str, current_char, current_char+sprite.height-1 ) )
			current_char = current_char + sprite.width
			term.setCursorPos(sprite.x, sprite.y+i)
		end
		
		
		
	end
	
	
	function sprite:draw180()
		sprite:draw(string.reverse(sprite.img))
	end
	
	
	function sprite:draw270()
		sprite:draw90(string.reverse(sprite.img))
	end
	]]--

	
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
	
	
	
	
	return sprite
end

