colon = require("colon")
text = require("colon_apis/colon_objects/text")
screen_width, screen_height = term.getSize()

--[[
    Scroll object, each page should get it's own scroll object.
]]
function create(args)
	local scroll = template.create()
	scroll.position = 0
	scroll.anchor = 0
    scroll.lock = false

	function scroll:update(args)
		if args.event ~= "mouse_scroll" then return end
        if scroll.position == 0 or scroll.position > scroll.anchor then return end
        if args.return_conditions.no_scroll then return end
        position = position + args.event_id
        colon.redraw()
	end

	function scroll:setAnchor(anchor)
		scroll.anchor = anchor
		if anchor > scroll.position then
			scroll.position = anchor
		end
	end

	return scroll
end

return{
	create=create
}