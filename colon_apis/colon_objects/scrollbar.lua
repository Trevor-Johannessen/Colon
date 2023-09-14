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
	scrollbar.redraw = args.redraw
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

	function scrollbar:update(obj_args, conditions)
		if scrollbar.hidden then return end
		if scrollbar.lock then return end
		if conditions.block_scroll then return end
		local current_slider_pos = scrollbar.slider.position
		-- mouse scrolling
		if obj_args.event == "mouse_scroll" then
			if (scrollbar.position <= 0 and obj_args.event_id == -1) or (scrollbar.position >= scrollbar.anchor and obj_args.event_id == 1) then return end
			scrollbar.slider.position = math.floor(scrollbar.position / scrollbar.anchor * (scrollbar.slider.height-2))
			scrollbar.colon.log("pos = " .. scrollbar.slider.position)
			scrollbar:setScrollPos(scrollbar.position + obj_args.event_id)
		else
			-- slider drag
			if scrollbar.slider:update(obj_args) then
				if current_slider_pos == scrollbar.slider.position then return end
				local new_pos = math.floor(scrollbar.anchor * (scrollbar.slider.position / (scrollbar.slider.height-1)))
				if new_pos ~= scrollbar.position then
					if obj_args.mouse_y >= scrollbar.height then new_pos = scrollbar.anchor
					elseif obj_args.mousey == 0 then new_pos = 0 end
					scrollbar:setScrollPos(new_pos)
				end
			end
		end
	end

	function scrollbar:setScrollPos(pos)
		scrollbar.position = pos
		scrollbar.redraw()
	end

	function scrollbar:setAnchor(anchor)
		scrollbar.anchor = anchor-meta.screen_height
		scrollbar.colon.log("Setting anchor to " .. anchor-screen_height)
		if anchor < scrollbar.position then
			scrollbar.position = anchor+meta.screen_height
		end
	end


	return scrollbar
end

return {
	create=create
}