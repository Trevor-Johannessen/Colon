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
	text.width = tonumber(args.width) or text.screen_width
	text.height = tonumber(args.height) or nil
	text.scrollPos = 0
	text.scrollable = args.scrollable or true
	text.lineCount = 0	
	text.strTable = {}
	text.clrTable = {}
	text.bgdTable = {}
	
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
			local newY = 1
			while text.height >= newY and #text.strTable >= newY do
				term.setCursorPos(text.x+x_offset, text.y+newY-y_offset-1)
				term.blit(text.strTable[newY], text.clrTable[newY], text.bgdTable[newY])
				newY = newY + 1
			end
			term.setCursorPos(save_cursor[1], save_cursor[2])
			term.setTextColor(save_text)
			term.setBackgroundColor(save_background)
		end
	end
	
	function text:update(args)
		scroll:draw(obj_args["x_offset"], obj_args["y_offset"])
	end
	
	function text:initalize() -- dry render to populate text tables
		local str, colorString, backgroundString = text:parseColor(text.text)
		while str:len() > 0 do
			-- need to find the amount to increment the cursor by each loop (should be the amount of characters displayed)
			local endPointer = text.width+text.x
			local offset = 1
			local line = str:sub(1, endPointer-text.x)
			if str:len() > text.width - text.x and line:find(' ') then
				endPointer = line:find('[^ ]*$')+1
			end
			if(str:sub(endPointer-text.x+1,endPointer-text.x+1) == " ") then offset = 2 end
			table.insert(text.strTable, str:sub(1,endPointer-text.x))
			table.insert(text.clrTable, colorString:sub(1,endPointer-text.x))
			table.insert(text.bgdTable, backgroundString:sub(1, endPointer-text.x))
			str=str:sub(endPointer-text.x+offset)
			colorString=colorString:sub(endPointer-text.x+offset)
			backgroundString=backgroundString:sub(endPointer-text.x+offset)
			text.lineCount = text.lineCount + 1
		end
		text.height = text.hegiht or text.lineCount
	end

	-- correction to clean inputs
	if sharedFunctions then
		sharedFunctions.corrections(text)
	end
	text:initalize()
	
	return text
end

return{
	create=create
	}