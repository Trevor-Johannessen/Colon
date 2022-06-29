function monus(a, b)
	return ((a-b)<0 and 0 or (a-b))
end

function create(args)
	
	local text = {}
	
	text.x = tonumber(args.x) or 1 -- x coordinate of text
	text.y = tonumber(args.y) or 1 -- y coordinate of text
	text.str = string.sub(args.text, 2, -2) or "default text"
	text.visible = args.visible or true
	text.dynamic = false
	text.interactive = false
	text.name = args.name
	text.type = "text"
	text.color = args.color or term.getTextColor()
	text.background = args.background or term.getBackgroundColor()
	text.sticky = args.sticky or false
	text.screen_width, text.screen_height = term.getSize()
	text.length = string.len(text.str)
	text.start = tonumber(args.start) or text.x
	text.finish = tonumber(args.finish) or text.screen_width
	text.full_lines = math.floor(text.length / (text.finish - text.start))
	text.partial_lines = monus(1, text.length - (text.finish - text.start)*text.full_lines)
	text.height = text.full_lines + text.partial_lines + 1
	
	function text:draw(x_offset, y_offset)
	
		local save_cursor = {term.getCursorPos()}
		local save_text = term.getTextColor()
		local save_background = term.getBackgroundColor()
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		
		
		if text.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		
		local printable_str = text.str

		if text.y+text.height > y_offset then
			term.setCursorPos(text.x-x_offset, text.y-y_offset)
			term.setTextColor(text.color)
			term.setBackgroundColor(text.background)
			
			if varInstalled then
				printable_str = var.replaceStr(printable_str)
			end
			
			if sharedFunctions then
				str, colorString, backgroundString = sharedFunctions.parseColor(printable_str)
				local newY = text.y
				
				while str:len() > 0 do
					term.setCursorPos(text.start, newY-y_offset)
					-- need to find the amount to increment the cursor by each loop (should be the amount of characters displayed)
					term.blit(str:sub(1,text.finish-text.start), colorString:sub(1,text.finish-text.start), backgroundString:sub(1,text.finish-text.start))
					str=str:sub(text.finish-text.start+1)
					colorString=colorString:sub(text.finish-text.start+1)
					backgroundString=backgroundString:sub(text.finish-text.start+1)
					newY = newY + 1
				end
			else
				io.write(text.str)
			end
			term.setCursorPos(save_cursor[1], save_cursor[2])
			term.setTextColor(save_text)
			term.setBackgroundColor(save_background)
		end
	end
	
	-- correction to clean inputs
	if sharedFunctions then
		sharedFunctions.corrections(text)
	end
	
	return text
end