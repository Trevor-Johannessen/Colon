screen_width, screen_height = term.getSize() -- dimensions of screen
colon = require("colon")

function printColumn(index, str)
	for i=1, screen_height do
		term.setCursorPos(index, i)
		io.write(str)
	end
	
end

function create(args)
	local to = args.to
	local from = args.from
	local speed = args.speed or 0.05
	for i=0, screen_width, 3 do
		term.clear()
		
		colon.redraw{pageName=from, x_offset=-i, x_inital=0, x_final=screen_width-i}
		colon.redraw{pageName=to, x_offset=screen_width-i, x_inital=screen_width-i, x_final=screen_width}
		colon.setBackground(to)
		colon.setColor(to)
		printColumn(screen_width - i, "|")
		os.sleep(speed)
	end
	colon.setCurrentPage(to)
	return -1
end

return{
	create=create
}