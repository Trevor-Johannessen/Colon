screen_width, screen_height = term.getSize() -- dimensions of screen
template = require("colon_apis/colon_objects/template")



function create(args)
	
	local sprite = template.create()
	sprite.x = tonumber(args.x) or 0
	sprite.y = tonumber(args.y) or 0
	sprite.file = "" -- TODO: make default image and place here
	sprite.dynamic = args.dynamic or false
	sprite.interative = false
	sprite.name = args.name
	sprite.type = "sprite"
	sprite.sticky = args.sticky or false
	sprite.src = args.src
	sprite.template = args.template
	sprite.height = tonumber(args.height)
	sprite.width = tonumber(args.width)

	if args.src == nil and sprite.template == nil then 
		sprite:error("An image or template must be provided to sprite.") end
	
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
			local bgdSeg = string.sub(sprite.img, current_char, current_char+sprite.width-1)
			local spaceCount, charCount = 0, 0
			local spaceStrings = bgdSeg:gmatch("%s+")
			local charStrings = bgdSeg:gmatch("[^%s]+")
			if bgdSeg:sub(1,1) == " " then
				spaceCount = spaceStrings():len()
			end
			local curChars = charStrings()
			while curChars ~= nil do
				term.setCursorPos(sprite.x+x_offset+spaceCount+charCount, sprite.y+i-y_offset-1)
				term.blit(string.rep(" ", curChars:len()), string.rep("1", curChars:len()), curChars)
				charCount = charCount + curChars:len()
				spaceCount = spaceCount + (spaceStrings() or ""):len()
				curChars = charStrings()
			end
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
	
	function sprite:clearTemplate()
		sprite.template = nil
		if sprite.src == nil then
			sprite:error("A sprite's src file must be set before clearing a template.") end
		sprite:loadImage()
	end

	function sprite:setImage(newFile, isTemplate)
		term.setCursorPos(1,9)
		--if isTemplate then isTemplate = "true" else isTemplate = "false" end
		if isTemplate then sprite.template = newFile
		else sprite.src = newFile end
		sprite:loadImage()
	end
	
	function sprite:corrections()
		if sprite.sticky == "true" or not type(sprite.sticky) == "boolean" then
			sprite.sticky = true
		else
			sprite.sticky = false
		end
	end
	
	
	function sprite:parsePGI(f)
		sprite.height = tonumber(f:read())
		sprite.width = tonumber(f:read())
		sprite.img = f:read()
	end

	function sprite:parseNFP(f)
		local content = f:read("a")
		local itr= content:gmatch("[^\n^\r]*\r?\n")
		local row = itr()
		local imgTbl = {}
		sprite.width = 0
		sprite.height = 0
		while row ~= nil do
			row = row:gsub("\r?\n", "")
			if sprite.width < row:len() then sprite.width = row:len() end
			sprite.height = sprite.height + 1
			table.insert(imgTbl,row)
			row = itr()
		end
		sprite.img = ""
		for _, row in next, imgTbl do
			padding = string.rep("-", sprite.width - row:len())
			sprite.img = sprite.img .. row .. padding
		end
	end

	function sprite:loadImageFromTemplate()
		sprite.img = string.rep(sprite:convertColor(sprite.template, "hex"), sprite.width*sprite.height)
	end

	function sprite:loadImageFromFile()
		local f = io.open(sprite.src)
		if f == nil then sprite:error("File " .. sprite.src .. " not found.") end
		if sprite.src:sub(-4) == ".pgi" then
			sprite:parsePGI(f)
		else -- default is nfp
			sprite:parseNFP(f)
		end
		io.close(f)
	end

	function sprite:loadImage()
		if sprite.template == nil then
			sprite:loadImageFromFile()
		else
			sprite:loadImageFromTemplate()
		end
	end
	
	sprite:loadImage()
	sprite:corrections()
	
	return sprite
end

return {
	create=create
	}
