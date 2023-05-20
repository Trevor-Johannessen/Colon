colon = require("colon")
text = require("colon_apis/colon_objects/text")
screen_width, screen_height = term.getSize()
function create(args)
	local console = template.create()
	console.consolePosition = 0
	console.updateTimer = 10
	console.show = false
	console.height = 7
	if screen_height > 20 then
		console.height = screen_height * 0.33
	end
	console.logs = text.create{
		x=1,
		y=screen_height-console.height+1,
		text="",
		dynamic=true,
		scrollable=true,
		width=screen_width,
		height=console.height,
		sticky=true,
		color="black",
		background="lightGray"
	}
	
	function console:draw(x_offset, y_offset)
		if console.show then
			console.logs:draw(x_offset,y_offset)
		end
	end

	function console:update(args)
		if args["event"] == "key" and args["event_id"] == 301 then 
			console.show = not console.show
			if not console.show then
				console.colon.redraw(args)
				return
			end
			for i=0, console.height-1 do
				term.setCursorPos(1,screen_height-i)
				io.write(string.rep(" ", screen_width))
			end
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