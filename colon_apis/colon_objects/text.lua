template = require("colon_apis/colon_objects/template")

function monus(a, b)
	return ((a-b)<0 and 0 or (a-b))
end
function create(args)
	local text = template.create()
	
	text.x = tonumber(args.x) or 1 -- x coordinate of text
	text.y = tonumber(args.y) or 1 -- y coordinate of text
	text.text = args.text or "default text"
	text.visible = args.visible or true
	text.dynamic = false
	text.interactive = false
	text.name = args.name
	text.type = "text"
	text.color = args.color or term.getTextColor()
	text.background = args.background or term.getBackgroundColor()
	text.sticky = args.sticky or false
	text.screen_width, text.screen_height = term.getSize()
	text.length = string.len(text.text)
	text.finish = tonumber(args.finish) or text.screen_width
	text.full_lines = math.floor(text.length / (text.finish - text.x))
	text.partial_lines = monus(1, text.length - (text.finish - text.x)*text.full_lines)
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
		if text.y+text.height > y_offset then
			term.setTextColor(text:convertColor(text.color, "int"))
			term.setBackgroundColor(text:convertColor(text.background, "int"))
			str, colorString, backgroundString = text:parseColor(text.text)
			local newY = text.y
			while str:len() > 0 do
				term.setCursorPos(text.x+x_offset, newY-y_offset)
				-- need to find the amount to increment the cursor by each loop (should be the amount of characters displayed)
				term.blit(str:sub(1,text.finish-text.x), colorString:sub(1,text.finish-text.x), backgroundString:sub(1,text.finish-text.x))
				str=str:sub(text.finish-text.x+1)
				colorString=colorString:sub(text.finish-text.x+1)
				backgroundString=backgroundString:sub(text.finish-text.x+1)
				newY = newY + 1
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

return{
	create=create
	}