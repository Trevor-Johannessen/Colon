colon = require("colon")
text = require("colon_apis/colon_objects/text")
screen_width, screen_height = term.getSize()
function create(args)
	
	local console = template.create()
	
	
	console.consolePosition = 0
	console.updateTimer = 10
	console.show = false
	local height = 7
	if screen_height > 20 then
		height = screen_height * 0.33
	end
	console.logs = text.create{
		x=1,
		y=screen_height-height+1,
		text="",
		dynamic=true,
		scrollable=true,
		width=screen_width,
		height=height,
		sticky=true
	}
	
	function console:draw(x_offset, y_offset)
		if console.show then
			console.logs:draw(x_offset,y_offset)
		end
	end

	--[[
	function console:draw(x_offset, y_offset)
		if console.show then
			local saveColor = term.getTextColor()
			local saveBackground = term.getBackgroundColor()
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.gray)
			local height = 7
			if screen_height > 20 then
				height = screen_height * 0.33
			end
			for i=1, height do
				term.setCursorPos(1, screen_height-i+1) -- move bottom to top
				if logs[i] then
					if type(logs[i]) ~= "string" then logs[i] = "error: Log not string." end
					local width = string.len(logs[i])
					io.write(logs[i] .. string.rep(" ", screen_width - width))
				else
					io.write(string.rep(" ", screen_width))
				end
			end
			term.setTextColor(saveColor)
			term.setBackgroundColor(saveBackground)
		end
	end
	]]

	function console:update(args)
		if args["event"] == "key" and args["event_id"] == 301 then 
			console.show = not console.show 
			--colon.redraw()
			console:draw(args.x_offset, args.y_offset)
		else
			console.logs:update(args)
		end
		
	end

	function console:add(args)
		console.logs:add(args.msg .. "\\n")
		console:draw(args.x_offset, args.y_offset)
	end

	return console
	
end

return{
	create=create
}