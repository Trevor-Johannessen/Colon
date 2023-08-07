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
	
	function text:parseString(text)
		local text, color, background = text:praseColor(text)
		local hyperlinks = text:parseHyperlinks(text)
	end

	function text:parseHyperlinks(str)
		local hyperlink_locations = {}
		while true do
			local s,e = str:find("%[[^%]]*%]%([^%)]*%)")
			if not s then break end
			local bracket_string = str:sub(s+1,e):match("[^]]*")
			local hyperlink = str:sub(s+1,e):match("%(([^)]*)")
			str=str:sub(1,s-1) .. bracket_string .. str:sub(e+1)
			table.insert(hyperlink_locations, {s,s-1+bracket_string:len(), hyperlink})
		end
		return hyperlink_locations
	end

	return text
end

return{
	create=create
	}