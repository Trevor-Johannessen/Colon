function create(args)
	
	text = {}
	text.x = tonumber(args.x) or 0 -- x coordinate of text
	text.y = tonumber(args.y) or 0 -- y coordinate of text
	text.str = args.text or "default text"
	text.visible = args.visible or true
	text.dynamic = false
	text.interactive = false
	text.height = 1
	text.name = args.name
	text.type = "text"
	
	
	function text:draw(offset_x, offset_y)
		local save_cursor = {term.getCursorPos()}
		offset_x = offset_x or 0 -- default parameter values
		offset_y = offset_y or 0
		
		term.setCursorPos(text.x-offset_x, text.y-offset_y)
		io.write(text.str)
		term.setCursorPos(save_cursor[1], save_cursor[2])
	end
	
	return text
end