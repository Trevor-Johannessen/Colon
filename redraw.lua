function redraw(args)
    args = args or {}
    args.pageName = args.pageName or meta.current_page.name
	args.page = meta.pages[args.pageName]
    local x_offset = args.x_offset or 0 -- args.page.x_scroll.position
	local y_offset = args.y_offset or args.page.y_scroll.position
	if not args.y_offset and not args.page then error("Both args y_offset and page y_offset are nil. (" .. args.page.name .. ")" ) end
	fillScreen(args)
    --meta.console:add{msg="Redrawing at " .. x_offset .. ", " .. y_offset}
	for k, v in next, args.page.objects do
		if type(v.draw) == "function" then v:draw(x_offset, y_offset) end
	end
	meta.console:draw(x_offset,y_offset)
	meta.current_page.y_scroll:draw(x_offset,y_offset)
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

function fillScreen(args)
	local x_inital = args.x_inital or 0
	local x_final = args.x_final or screen_width
	local y_inital = args.y_inital or 0
	local y_final = args.y_final or screen_height
	term.setBackgroundColor(meta.pages[args.pageName].background)
	for i = y_inital, y_final do
		term.setCursorPos(x_inital, i)
		io.write(string.rep(" ", x_final - x_inital+1))
	end
end

return {
    redraw=redraw,
    ifAwaiting=redrawIfAwaiting,
    bubble=redrawBubble
}