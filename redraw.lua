function redraw(args)
    args = args or {}
	args.page = meta.pages[args.pageName] or meta.current_page
	local x_offset = args.x_offset or args.page.x_scroll.position
	local y_offset = args.y_offset or args.page.y_scroll.position
	if not args.y_offset and not args.page then error("Both args y_offset and page y_offset are nil. (" .. args.page.name .. ")" ) end
	fillScreen(args.page.background)
	for k, v in next, args.page.objects do
		if type(v.draw) == "function" then v:draw(x_offset, y_offset) end
	end
end

function redrawIfAwaiting(args, obj)
    if obj.awaiting_redraw then
        obj.awaiting_redraw = false
        obj:draw(args.x_offset, args.y_offset)
    end
end

-- TODO: implement this
function redrawBubble(args)
    redraw(args)
end

function fillScreen(color)
    term.setBackgroundColor(color)
    term.setCursorPos(1,1)
	for i = 1, meta.screen_height do
		print(string.rep(" ", meta.screen_width))
	end
end

return {
    redraw=redraw,
    ifAwaiting=redrawIfAwaiting,
    bubble=redrawBubble
}