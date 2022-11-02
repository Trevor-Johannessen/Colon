os.loadAPI("/colon/colon_apis/colon_objects/template.lua")

function create(args)
	
	textbox = template.create()

	textbox.x = tonumber(args.x) or 1
	textbox.y = tonumber(args.y) or 1
	textbox.text = args.text or ""
	textbox.color = args.color or term.getTextColor()
	textbox.background = args.background or term.getBackgroundColor()
	textbox.width = tonumber(args.width) or 10
	textbox.height = tonumber(args.height) or 1
	textbox.sticky = args.sticky or false
	textbox.dynamic = false
	textbox.interactive = true
	textbox.selected = false
	textbox.cursor = 1
	textbox.max_string = textbox.width * textbox.height
	
	
	function textbox:draw(x_offset, y_offset)
		
		local save_cursor = {term.getCursorPos()}
		local save_text = term.getTextColor()
		local save_background = term.getBackgroundColor()
		local characters_remaining = string.len(textbox.text)
		local next_characters_remaining = 0
		local padding = 0
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		
		
		if text.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		
		term.setCursorPos(textbox.x-x_offset, textbox.y-y_offset)
		term.setTextColor(textbox.color)
		term.setBackgroundColor(textbox.background)
		
		for i = 1, textbox.height do
			if textbox.y - y_offset >= 0 and textbox.y - y_offset + i - 1 < 20 then
				
				local string_on_line = string.sub(textbox.text, textbox.width * (i-1) + 1, textbox.width * i)
				io.write(string_on_line .. string.rep(" ", textbox.width - string.len(string_on_line)))
				
			end
			term.setCursorPos(textbox.x-x_offset, textbox.y+i-y_offset)
			
		end
		
		term.setCursorPos(save_cursor[1], save_cursor[2])
		term.setTextColor(save_text)
		term.setBackgroundColor(save_background)
	end
	
	
	function textbox:update(obj_args)
		-- for clicking on the textbox
		if obj_args["mouse_x"] and obj_args["mouse_y"] then 
			if textbox.sticky then y_offset = 0 end
			local hit = obj_args["mouse_x"] >= textbox.x and
				  obj_args["mouse_x"] <= textbox.width+textbox.x-1 and
				  obj_args["mouse_y"] >= textbox.y - obj_args["y_offset"] and
				  obj_args["mouse_y"] <= textbox.height+textbox.y-obj_args["y_offset"]-1
	
		
	
	
	
			if hit and obj_args["event"] == "mouse_up" then
				textbox.active = true
				if inColon then
					colon.scrollLock(true)
				end
			else
				textbox.active = false
				colon.scrollLock(false)
			end
		
		-- for typing in the textbox
		elseif textbox.active then
			if obj_args["event"] == "char" and string.len(textbox.text) < textbox.max_string then
				textbox.text = textbox.text .. obj_args["event_id"]
				place_key(obj_args["event_id"], obj_args["y_offset"])
			elseif obj_args["event"] == "key" and obj_args["event_id"] == 259 and textbox.text ~= "" then -- backspace
				place_key(" ", obj_args["y_offset"])
				textbox.text = string.sub(textbox.text, 1, -2)
			elseif obj_args["event"] == "key" and obj_args["event_id"] == 257 and string.len(textbox.text) < textbox.max_string-textbox.width then -- newline
			end
		end
	end
	
	
	function place_key(key, y_offset)
		local saveText = term.getTextColor()
		local saveBackground = term.getBackgroundColor()
		term.setTextColor(textbox.color)
		term.setBackgroundColor(textbox.background)
		
		
		local xpos = (textbox.x + (string.len(textbox.text)-1) % textbox.width)
		local ypos = textbox.y - y_offset + math.floor((string.len(textbox.text)-1) / textbox.width)
		term.setCursorPos(xpos, ypos)
		io.write(key)
		
		
		
		
		term.setTextColor(saveText)
		term.setBackgroundColor(saveBackground)
	end
	
	
	textbox:corrections(textbox)
	
	return textbox
end

function monus(a, b)
	return ((a-b)<0 and 0 or (a-b))
end