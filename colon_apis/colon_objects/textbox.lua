colon = require("colon")
template = require("colon_apis/colon_objects/template")
text = require("colon_apis/colon_objects/text")

function create(args)
	local textbox = template.create(args)
	
	textbox.x = tonumber(args.x) or 1
	textbox.y = tonumber(args.y) or 1
	textbox.color = args.color or term.getTextColor()
	textbox.background = args.background or term.getBackgroundColor()
	textbox.width = tonumber(args.width) or 10
	textbox.height = tonumber(args.height) or 1
	textbox.sticky = args.sticky or false
	textbox.dynamic = false
	textbox.interactive = true
	textbox.selected = args.selected or false
	textbox.cursor = 1
	textbox.max_string = textbox.width * textbox.height
	textbox.name = args.name
	textbox.text = text.create(args)
	
	function textbox:drawBackground(x_offset, y_offset)
		local oldx, oldy = term.getCursorPos()
		local save_background = term.getBackgroundColor()	
		if textbox.sticky then 
			y_offset = 0 
			x_offset = 0
		end	 
		term.setBackgroundColor(textbox.background)
		for i=0, textbox.height-1 do
			term.setCursorPos(textbox.x+x_offset, textbox.y-y_offset+i)
			io.write(string.rep(" ", textbox.width))
		end	
		term.setBackgroundColor(save_background)
		term.setCursorPos(oldx, oldy)
	end
	
	function textbox:draw(x_offset, y_offset)
		if textbox.hidden then return end
		local save_cursor = {term.getCursorPos()}
		local save_text = term.getTextColor()
		local save_background = term.getBackgroundColor()
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		if textbox.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		textbox:drawBackground(x_offset, y_offset)
		textbox.text:draw(x_offset, y_offset)
		term.setCursorPos(save_cursor[1], save_cursor[2])
		term.setTextColor(save_text)
		term.setBackgroundColor(save_background)
	end
	
	function textbox:update(obj_args)
		if textbox.hidden then return end
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
			if obj_args["event"] == "char" then
				textbox.text:add(obj_args["event_id"])
				textbox.text:draw()
			elseif obj_args["event"] == "key" and obj_args["event_id"] == 259 then -- backspace
				textbox.text:backspace()
				textbox.text:draw()
			elseif obj_args["event"] == "key" and obj_args["event_id"] == 257 then -- newline
			end
		end
		if textbox.text.interactive then return textbox.text:update(obj_args) end
	end
	
	textbox:corrections(textbox)
	return textbox
end

return {
	create=create
}