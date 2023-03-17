template = require("colon_apis/colon_objects/template")

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
	text.length = string.len(text.text)
	text.width = tonumber(args.width) or text.text:len()
	if text.width > text.screen_width then text.width = text.screen_width end
	text.height = tonumber(args.height) or nil
	text.autoHeight = false -- flag if the text has had its height automatically set
	text.scrollPos = 0
	text.scrollable = args.scrollable or true
	text.strTable = {}
	text.clrTable = {}
	text.bgdTable = {}
	
	function text:draw(x_offset, y_offset)
		local save_cursor = {term.getCursorPos()}
		local save_text = term.getTextColor()
		local save_background = term.getBackgroundColor()
		local clearString = string.rep(text:convertColor(text.background, "hex"), text.width)
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		
		if text.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		if text.y+text.height > y_offset then
			local newY = text.scrollPos+1
			while text.height >= newY-text.scrollPos and #text.strTable >= newY do
				term.setCursorPos(text.x+x_offset, text.y+newY-y_offset-1-text.scrollPos)
				term.blit(clearString, clearString, clearString)
				term.setCursorPos(text.x+x_offset, text.y+newY-y_offset-1-text.scrollPos)
				term.blit(text.strTable[newY], text.clrTable[newY], text.bgdTable[newY])
				newY = newY + 1
			end
			term.setCursorPos(save_cursor[1], save_cursor[2])
			term.setTextColor(save_text)
			term.setBackgroundColor(save_background)
		end
	end
	
	function text:inBounds(args)
		if args["mouse_x"]+args["x_offset"] >= text.x and 
		text.x + text.width > args["mouse_x"]+args["x_offset"] and
		args["mouse_y"]+args["y_offset"] >= text.y and
		text.y + text.height > args["mouse_y"]+args["y_offset"] then
			return true
		end
		return false
	end
	
	function text:update(args)
		if args.event == "mouse_scroll" and text:inBounds(args) then
			text.scrollPos = text:monus(text.scrollPos, -args["event_id"])
			if text.scrollPos > #text.strTable - text.height then text.scrollPos = #text.strTable - text.height end
			text:draw(args["x_offset"], args["y_offset"])
			return {"when", "scroll"}
		end
	end
	
	function text:parseString(input, addition)
		local save_cursor = {term.getCursorPos()}
		local save_text = term.getTextColor()
		local save_background = term.getBackgroundColor()
		local length, saveClr, saveBgd
		term.setTextColor(text:convertColor(text.color, "int"))
		term.setBackgroundColor(text:convertColor(text.background, "int"))
		if addition and #text.strTable > 0 then
			length = text.strTable[#text.strTable]:len() -- first half of incomplete line
			saveClr = text.clrTable[#text.strTable]
			saveBgd = text.bgdTable[#text.strTable]
			input = text.strTable[#text.strTable] .. input
			table.remove(text.strTable)
			table.remove(text.clrTable)
			table.remove(text.bgdTable)
		end	
		local str, colorString, backgroundString = text:parseColor(input)
		if addition and #text.strTable > 0 then
			colorString = saveClr .. colorString:sub(length+1)
			backgroundString = saveBgd .. backgroundString:sub(length+1)
		end
		while str:len() > 0 do
			-- need to find the amount to increment the cursor by each loop (should be the amount of characters displayed)
			local endPointer = text.width
			local offset = 1
			local line = str:sub(1, endPointer)
			if str:len() > text.width and line:find(' ') then
				endPointer = line:find('[^ ]*$')-1
			end
			if(str:sub(endPointer+1,endPointer+1) == " ") then offset = 2 end
			table.insert(text.strTable, str:sub(1,endPointer))
			table.insert(text.clrTable, colorString:sub(1,endPointer))
			table.insert(text.bgdTable, backgroundString:sub(1, endPointer))
			str=str:sub(endPointer+offset)
			colorString=colorString:sub(endPointer+offset)
			backgroundString=backgroundString:sub(endPointer+offset)
		end
		term.setCursorPos(save_cursor[1], save_cursor[2])
		term.setTextColor(save_text)
		term.setBackgroundColor(save_background)
	end
	
	function text:initalize() -- dry render to populate text tables
		text.strTable = {}
		text.clrTable = {}
		text.bgdTable = {}
		text:parseString(text.text)
		if text.height == nil or text.autoHeight then
			text.height = #text.strTable
			text.autoHeight = true
		end
		if #text.strTable > text.height and text.scrollable then text.interactive = true end
	end
	
	function text:add(addition)
		text.text = text.text .. addition
		local beforeSize = #text.strTable
		text:parseString(addition, true)
		if text.height == nil or text.autoHeight then
			text.height = #text.strTable
			text.autoHeight = true
		end
		if #text.strTable > text.height and text.scrollable then text.interactive = true end
		if #text.strTable > beforeSize and #text.strTable > text.height then text.scrollPos = text.scrollPos + 1 end
	end

	function text:backspace()
		text.text = text.text:sub(1, text.text:len()-1)
		if #text.strTable > 0 then
			local beforeSize = #text.strTable
			if text.strTable[#text.strTable]:len() == 0 then
				table.remove(text.strTable)
				table.remove(text.clrTable)
				table.remove(text.bgdTable)
			else
				local length = text.strTable[#text.strTable]:len()
				text.strTable[#text.strTable] = text.strTable[#text.strTable]:sub(1, length-1)
				text.clrTable[#text.clrTable] = text.clrTable[#text.clrTable]:sub(1, length-1)
				text.bgdTable[#text.bgdTable] = text.bgdTable[#text.bgdTable]:sub(1, length-1)
			end
			if beforeSize > #text.strTable and #text.strTable >= text.height then text.scrollPos = text:monus(text.scrollPos, 1) end
		end
	end

	-- correction to clean inputs
	if sharedFunctions then
		sharedFunctions.corrections(text)
	end
	for k, v in next, args["augments"] do
		text=v(text, args)
	end
	
	text:initalize()

	return text
end

return{
	create=create
	}