template = require("colon_apis/colon_objects/template")

function create(args)
	local text = template.create(args)
	block=block:coords(args)
    block=block:dim(args)
    block=block:essentials(args)

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
	
	return text
end

return{
	create=create
	}