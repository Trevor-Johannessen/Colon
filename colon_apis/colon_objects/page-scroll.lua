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

	function scroll:update(args, conditions)
		if args[1] ~= "mouse_scroll" then return end
        if scroll.position == 0 and args[2] == -1 or scroll.position >= scroll.anchor and args[2] == 1 then return end
        if conditions.no_scroll then return end
        scroll.position = scroll.position + args[2]
		--meta.console:add{msg="scroll pos = " .. scroll.position .. " dir = " .. args[2],x_offset=0,y_offset=0}
        colon.redraw()
	end

	function scroll:setAnchor(anchor)
		scroll.anchor = anchor
		--meta.console:add{msg="Anchor has been set to "..scroll.anchor}
		if anchor < scroll.position then
			scroll.position = anchor
		end
	end

	return scroll
end

return{
	create=create
}