colon = require("/colon/colon")
screen_width, screen_height = term.getSize()
function create(args)
	
	local console = template.create()
	
	
	console.consolePosition = 0
	console.logs = {}
	console.updateTimer = 10
	console.show = false
	
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
				term.setCursorPos(1, screen_height - height + i) -- move top to bottom
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
	
	function console:update(args)
		if args["event"] == "key" and args["event_id"] == 301 then 
			console.show = not console.show 
			colon.redraw()
		end
	
		if args["tick"] % console.updateTimer == 0 then
			console.logs = colon.getLogs()
		end
		console:draw(args.x_offset, args.y_offset)
	end
	
	return console
	
end

return{
	create=create
}