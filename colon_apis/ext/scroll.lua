colon = require("colon")
text = require("colon_apis/colon_objects/text")
screen_width, screen_height = term.getSize()

--[[
    Scroll object, each page should get it's own scroll object.
]]
function create(args)
	local scroll = template.create()
	scroll.position = 0
    scroll.lock = false

	function console:update(args)
		if args.event ~= "mouse_scroll" then return end
        if scroll.position == 0 or scroll.position > MAXIMUM_HEIGHT then return end
        if args.no_scroll then return end
        position = position + args.event_id
        scroll.colon.redraw()
	end

	return scroll
end

return{
	create=create
}