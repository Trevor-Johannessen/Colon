

function create(args)
	
	local sprite = {}
	sprite.x = 0
	sprite.y = 0
	sprite.file = "" -- TODO: make default image and place here
	
	if args.image ~= nil then
		sprite.file = args.image
	end
	if args.x ~= nil then
		sprite.x = args.x
	end
	if args.y ~= nil then
		sprite.y = args.y
	end
	
	local f = io.open(sprite.file)
	sprite.height = tonumber(f:read())
	sprite.width = tonumber(f:read())
	sprite.img = f:read()
	io.close(f)
	
	
	function sprite:draw(input)
	
		local firstx, firsty = term.getCursorPos()
		local current_char = 1
		term.setCursorPos(sprite.x, sprite.y)
		
		
		local str = input
		if str == nil then
			str = sprite.img
		end
		
		
		for i = 1, sprite.height do
			term.blit(string.rep(" ", sprite.width), string.rep("1", sprite.width), string.sub(str, current_char, current_char+sprite.width-1 ) )
			current_char = current_char + sprite.width
			term.setCursorPos(sprite.x, sprite.y+i)
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
	
	return sprite
end

