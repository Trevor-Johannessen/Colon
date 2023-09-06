template = require("colon_apis/colon_objects/template")
slider = require("colon_apis/colon_objects/slider")
function create(args)
	local scrollbar = template.create(args)
    scrollbar=scrollbar:coords(args)
    scrollbar=scrollbar:dim(args)
    scrollbar=scrollbar:essentials(args)
	scrollbar.knob_percent=args.knobPercent -- percentage of space the knob should take up (0-1, max 1)
	scrollbar.anchor = args.anchor -- the total amount of lines it is possible to scroll.
	scrollbar.lock = false
	scrollbar.position = 0
	if scrollbar.knob_percent > 1 then scrollbar.knob_percent=1 end
	scrollbar.slider = slider.create{
		knobColor="gray",
		background="lightGray",
		height=scrollbar.height+1,
		width=1,
		vertical="true",
		knob_width=math.floor(scrollbar.height * scrollbar.knob_percent),
		x=scrollbar.x,
		y=scrollbar.y-1,
		sticky="true",
		borderless="true",
	}
	
	function scrollbar:draw(x_offset, y_offset)
		if not scrollbar.hidden then
			scrollbar.slider:draw(x_offset,y_offset)
		end
	end

	function scrollbar:update(obj_args)
		if scrollbar.lock then return end
		-- activate the update function with the current scroll position
		if obj_args[1] == "mouse_scroll" then
			if scrollbar.position == 0 and obj_args[2] == -1 or scrollbar.position >= scrollbar.anchor and obj_args[2] == 1 then return end
			scrollbar.position = scrollbar.position + obj_args[2]
			scrollbar.slider.position = math.floor(scrollbar.position/scrollbar.anchor*scrollbar.slider.height)
			--meta.console:add{msg="scroll pos = " .. scroll.position .. " dir = " .. args[2],x_offset=0,y_offset=0}
			colon.redraw()
		else
			if scrollbar.slider:update(obj_args) then
				local new_pos = math.floor(scrollbar.anchor / scrollbar.height)*scrollbar.slider.position
				if new_pos ~= scrollbar.position then
					scrollbar.position = new_pos
					colon.redraw()
				end
			end
		end
	end

	function scrollbar:setAnchor(anchor)
		scrollbar.anchor = anchor
		--meta.console:add{msg="Anchor has been set to "..scroll.anchor}
		if anchor < scrollbar.position then
			scrollbar.position = anchor
		end
	end

	return scrollbar
end

return {
	create=create
}