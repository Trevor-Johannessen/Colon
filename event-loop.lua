local redraw = require("redraw")

function start()
    local tick = 1
    redraw.redraw()
    while true do
        local timer = os.startTimer(0.05)
        local update_args = {}
        formUpdateArgs(update_args, tick)
        local event
        while not event do
            event={os.pullEvent()}
        end
        addEventArgs(update_args, event)
        local return_conditions = {redraw_list={}}
        -- system objects
        checkReturnConditions(meta.console:update(update_args), meta.console, return_conditions)
        -- page objects
        for k, v in next, meta.current_page.objects do
            if return_conditions.nobubble then break end
            if type(v.update) == "function" then
                local update_params = v:update(update_args) or {}
                checkReturnConditions(update_params, v, return_conditions)
            end
        end
        -- bubble redraw here
        
        if return_conditions.found_when then os.cancelTimer(timer) end
        if event[1] == "mouse_scroll" then meta.current_page.y_scroll:update(event, return_conditions) end
        tick = tick + 1
    end
end

function formUpdateArgs(args,tick)
    args.tick = tick
	args.x_offset = meta.current_page.x_scroll.position
	args.y_offset = meta.current_page.y_scroll.position
	args.screen_height = meta.screen_height
	args.screen_width = meta.screen_width
	args.color = meta.current_page.color
	args.background = meta.current_page.background
    args.height = meta.current_page.height
    args.page = meta.current_page
end
    
function addEventArgs(args, event)
    args.event = event[1]
    args.event_id = event[2]
    args.mouse_x = event[3]
    args.mouse_y = event[4]
end

function checkReturnConditions(conditions, data, prev_conditions)
	if not conditions then return end
	for k, v in next, conditions do
		if type(v) == "string" then
			if v == "when" then -- activate when statements
				prev_conditions.found_when = prev_conditions.found_when or check_when_statements(data.name, conditions.whenArgs) 
			elseif v == "scroll" then -- take scroll control away from colon enviornemnt
				prev_conditions.block_scroll = true
			elseif v == "nobubble" then -- do not propagate input to any more elements
				prev_conditions.nobubble = true
			elseif v == "redraw" then
				table.insert(prev_conditions.redraw_list, 1, k)
			end
		end
	end
end

return {
    start=start,
}