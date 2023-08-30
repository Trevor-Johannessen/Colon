template = require("colon_apis/colon_objects/template")
local colors = require("colon_apis/ext/colors")

function parseBackground(str, default)
	return parseBrackets(str, default, "{}", "[]")
end

function parseColor(str, default)
	return parseBrackets(str, default, "{}", "()")
end

function parseHyperlinks(str)
	return parseBrackets(str, "-", "[]", "()")
end

function parseBrackets(str, default, bracket1, bracket2)
	local set1, set2 = {bracket1:sub(1,1), bracket1:sub(2,2)}
	local set2 = {bracket2:sub(1,1), bracket2:sub(2,2)}
	local pos = 1
	local openers = {}
	local color_stack = {}
	local color_string
	while true do
		local next_bracket_pos = str:sub(pos):find("[%"..set1[1].."%"..set1[2].."]")
		if not next_bracket_pos then
			color_string = string.rep(default, str:len())
			for i=#color_stack, 1, -1 do
				local dict = color_stack[i]
				color_string = color_string:sub(0,dict.start-1) .. string.rep(dict.color, dict.pos+dict.bracket_pos - dict.start) .. color_string:sub(dict.pos+dict.bracket_pos)
			end
			return str, color_string
		elseif str:sub(pos):sub(next_bracket_pos, next_bracket_pos) == set1[1] then -- '('
			-- add position to opened bracket stack
			openers[#openers+1] = pos + next_bracket_pos
		elseif str:sub(pos):sub(next_bracket_pos, next_bracket_pos) == set1[2] then -- ')'
			-- make sure stack isn't empty
			if #openers ~= 0 then
				-- parse color
				local bracket_string = str:sub(pos+next_bracket_pos-2):match("%"..set2[1].."([^"..set2[2].."]*)%"..set2[2].."")
				if bracket_string and bracket_string == 1 then
					-- truncate strings
					str=str:sub(1,pos+next_bracket_pos-2) .. str:sub(pos+next_bracket_pos+bracket_string:len()+2)
					str=str:sub(1,openers[#openers]-2) .. str:sub(openers[#openers])
					pos=pos-2
					-- push to stack
					color_stack[#color_stack+1] = {start=openers[#openers], color=colors.convertColor(bracket_string, "hex"),pos=pos,bracket_pos=next_bracket_pos}
					openers[#openers]=nil
				end
			end
		end
		pos = pos + next_bracket_pos
	end
end

function create(args)
	local text = template.create(args)
	text.x = tonumber(args.x) or 1 -- x coordinate of text
	text.y = tonumber(args.y) or 1 -- y coordinate of text
	text.text = args.text or "default text"
	text.visible = args.visible or true
	text.dynamic = args.dynamic or false
	text.interactive = false
	text.name = args.name
	text.type = "text"
	text.fillBackground = args.fillBackground ~= "false"
	text.color = args.color or term.getTextColor()
	text.background = args.background or term.getBackgroundColor()
	text.sticky = args.sticky or false
	text.length = string.len(text.text)
	text.width = tonumber(args.width) or text.text:len()
	if text.width > text.screen_width then text.width = text.screen_width end
	text.height = tonumber(args.height) or nil
	text.textHeight = 0
	text.autoHeight = text.height == nil -- flag if the text has had its height automatically set
	text.scrollPos = 0
	text.scrollable = type(args.scrollable) == "string" and args.scrollable ~= "false"
	text.background_text = ""
	text.color_text = ""
	text.hyperlink_text = ""


	--[[
		Features:
			Display Text
			Give text color
			Give text background color
			Allow text to be added/deleted (Re-renders the whole text)
			Render a blinking cursor at a specific position (Without re-rendering the whole text)
			Enable highlighting text with mouse drag (Without re-rendering the whole text)
			Enable drag highlighting to highlight text which may be off screen.
			Utilize word-wrap
			Change size of text boundaries
			Print a text background box
			Scroll if text is too large for boundary
			Support hyperlinks (Trigger when statements)
	]]

	function text:draw(x_offset, y_offset)
		if text.hidden then return end
		local save_cursor = {term.getCursorPos()}
		local save_text = term.getTextColor()
		local save_background = term.getBackgroundColor()
		local clearString = string.rep(text:convertColor(text.background, "hex"), text.width)
		local pos = 1
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		
		if text.sticky then 
			y_offset = 0 
			x_offset = 0
		end
		if text.fillBackground then
			text:drawBackground(x_offset,y_offset)
		end
		if text.y+text.height > y_offset then
			local newY = text.scrollPos+1
			pos = text.width * (newY-1)+1
			local projected_height = text:getProjectedHeight()
			while text.height >= newY-text.scrollPos and projected_height >= newY and text.text:sub(pos):len() > 0 do
				local text_line = text.text:sub(pos, pos+text.width)
				local color_line = text.color_text:sub(pos, pos+text.width)
				local background_line = text.background_text:sub(pos, pos+text.width)
				local write_len = text_line:len()
				if text_line:find("\\n") then 
					local newline_pos = text_line:find("\\n")
					text_line = text_line:sub(1, newline_pos)
					color_line = color_line:sub(1, newline_pos)
					background_line = background_line:sub(1, newline_pos)
					pos=pos+2
				end
				term.setCursorPos(text.x+x_offset, text.y+newY-y_offset-1-text.scrollPos)
				term.blit(clearString, clearString, clearString)
				term.setCursorPos(text.x+x_offset, text.y+newY-y_offset-1-text.scrollPos)
				term.blit(text_line, color_line, background_line)
				newY = newY + 1
				pos = pos + text_line:len()
			end
			term.setCursorPos(save_cursor[1], save_cursor[2])
			term.setTextColor(save_text)
			term.setBackgroundColor(save_background)
		end
	end
	
	function text:init()
		text.text, text.background_text = parseBackground(text.text, colors.convertColor(text.background, "hex"))
		text.text, text.color_text = parseColor(text.text, colors.convertColor(text.color, "hex"))
		text.text, text.hyperlink_text = parseHyperlinks(text.text)
		text.textHeight = text:getProjectedHeight()
		if text.autoHeight then text.height = text.textHeight end
	end

	function text:drawBackground(x_offset,y_offset)
		term.setBackgroundColor(text:convertColor(text.background, "int"))
		for i=0, text.height-1 do
			term.setCursorPos(text.x+x_offset, text.y-y_offset+i)
			io.write(string.rep(" ", text.width))
		end	
	end

	function text:getProjectedHeight()
		term.setCursorPos(1,1)
		local effective_height = 0
		local pos = 1
		while true do
			local next_newline = text.text:sub(pos):find("\\n")
			if next_newline then
				effective_height = effective_height + text.text:sub(pos, next_newline-1):len() + (text.text:sub(pos, next_newline-1):len() % text.width)
				pos = pos+next_newline+1
			else
				effective_height = effective_height + text.text:sub(pos):len()
				return math.ceil(effective_height / text.width)
			end
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
		if text.hidden then return end
		if args.event == "mouse_scroll" and text:inBounds(args) and text.textHeight > text.height then
			text.scrollPos = text:monus(text.scrollPos, -args["event_id"])
			if text.scrollPos > text.textHeight - text.height then text.scrollPos = text.textHeight - text.height end
			text:draw(args["x_offset"], args["y_offset"])
			return {"when", "scroll"}
		end
	end

	-- returns table of line cutoffs.
	function text:processWordWrap()
		-- word wrap will just insert newline characters into the text string
		-- don't forget to fill the background and color strings with dummy data.
	end

	function text:append(str)
		local color, background, hyperlinks
		str, background = parseBackground(str, colors.convertColor(text.background, "hex"))
		str, color = parseColor(str, colors.convertColor(text.color, "hex"))
		str, hyperlinks = parseHyperlinks(str)
		text.text = text.text .. str
		text.background_text = text.background_text .. background
		text.color_text = text.color_text .. color
		text.hyperlink_text = text.hyperlink_text .. hyperlinks
		text.textHeight = text:getProjectedHeight()
	end

	function text:insert(str, pos)
	end

	text:init()

	return text
end

return{
	create=create
	}