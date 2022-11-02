os.loadAPI("/colon/colon_apis/colon_objects/template.lua")

function create(args)
	gif = template.create()
	
	gif.x = tonumber(args.x) or 1
	gif.y = tonumber(args.y) or 1
	gif.dynamic = true
	gif.interactive = false
	gif.gifLocation = args.src
	gif.images = {}
	gif.frame = tonumber(args.frame) or 1
	gif.replay = args.replay or true
	gif.height = 1
	gif.speed = tonumber(args.speed) or 1
	-- height then width
	
	-- build a table of sprite objects for each frame of the gif
	if fs.exists(args.src) then
		imageArgs = {}
		imageArgs["x"] = gif.x
		imageArgs["y"] = gif.y
		imageArgs["sticky"] = gif.sticky
		
		for _, path in ipairs(fs.list(args.src)) do
			imageArgs["src"] = gif.gifLocation .. "/" .. path
			local sprite = sprite.create(imageArgs)
			if gif.height < sprite.height then gif.height = sprite.height end
			table.insert(gif.images, sprite)
		end
		
	end
	
	function gif:draw(x_offset, y_offset)
		gif.images[gif.frame]:draw(x_offset, y_offset)
	end
	
	function gif:update(objArgs)
		if objArgs["tick"] % gif.speed == 0 and gif.y+gif.height >= objArgs["y_offset"] and gif.y <= objArgs["screen_height"]+objArgs["y_offset"] then
			gif:draw(objArgs["x_offset"], objArgs["y_offset"]) -- draw current frame
			gif.frame = gif.frame + 1 -- increment to next frame
			if gif.frame > #gif.images and gif.replay then gif.frame = 1 end -- loop gif if over
		end
	end
	
	
	gif:corrections(gif)
	
	return gif
end