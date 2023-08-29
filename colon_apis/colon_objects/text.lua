template = require("colon_apis/colon_objects/template")

function create(args)
	local text = template.create(args)
	text=text:coords(args)
    text=text:dim(args)
    text=text:essentials(args)
	text.text = args.text or ""


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
	end
	
	function text:update(args)
	end
	
	function text:parseString(str)
	end

	function text:parseColor(str)
	end

	function text:parseHyperlinks(str)
	end
	
	function text:parseBrackets(default, bracket1, bracket2)
		local set1, set2 = {bracket1:sub(1,1), bracket1:sub(2,2)}
		local set2 = {bracket2:sub(1,1), bracket2:sub(2,2)}
		local pos = 1
		local openers = {}
		local color_stack = {}
		local color_string
		while true do
			local next_bracket_pos = text.text:sub(pos):find("[%"..set1[1].."%"..set1[2].."]")
			if not next_bracket_pos then
				color_string = string.rep(default, text.text:len())
				for i=#color_stack, 1, -1 do
					local dict = color_stack[i]
					color_string = color_string:sub(0,dict.start-1) .. string.rep(dict.color, dict.pos+dict.bracket_pos - dict.start) .. color_string:sub(dict.pos+dict.bracket_pos)
				end
				return str, color_string
			elseif text.text:sub(pos):sub(next_bracket_pos, next_bracket_pos) == set1[1] then -- '('
				-- add position to opened bracket stack
				openers[#openers+1] = pos + next_bracket_pos
			elseif text.text:sub(pos):sub(next_bracket_pos, next_bracket_pos) == set1[2] then -- ')'
				-- make sure stack isn't empty
				if #openers ~= 0 then
					-- parse color
					local bracket_string = text.text:sub(pos+next_bracket_pos-2):match("%"..set2[1].."([^"..set2[2].."]*)%"..set2[2].."")
					if bracket_string then
						-- truncate strings
						text.text=text.text:sub(1,pos+next_bracket_pos-2) .. text.text:sub(pos+next_bracket_pos+bracket_string:len()+2)
						text.text=text.text:sub(1,openers[#openers]-2) .. text.text:sub(openers[#openers])
						pos=pos-2
						-- push to stack
						color_stack[#color_stack+1] = {start=openers[#openers], color=convertColor(bracket_string, "hex"),pos=pos,bracket_pos=next_bracket_pos}
						openers[#openers]=nil
					end
				end
			end
			pos = pos + next_bracket_pos
		end
	end

	-- returns table of line cutoffs.
	function text:processWordWrap()
		
	end

	return text
end

return{
	create=create
	}