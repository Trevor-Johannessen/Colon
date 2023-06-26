template = require("colon_apis/colon_objects/template")


--[[
    NOTE: THIS OBJECT IS MEANT TO WORK TOGETHER WITH THE SLOT OBJECT. BOTH ARE REQUIRED FOR FULL FUNCTIONALITY.
]]
function create(args)
	local block = template.create(args)
    block:coords(args)
    block:dim(args)
    block:essentials(args)
    block:sprite(args)
    block.dragging = false
    block.grab_position = {0,0}

    function block:draw(x_offset, y_offset)
        if block.hidden then return end
        block.sprite:draw(x_offset, y_offset)
    end
    
    function block:setPos(x,y)
        block.x = x
        block.y = y
        block.sprite.x = x
        block.sprite.y = y
    end



    -- snap to any near slot 
    -- if snap is successful, return when statements
    function block:snap(args)
    end

    function block:update(args)
        if block.hidden then return end
        if not block.dragging and args.event == "mouse_click" and block:inBounds(args) then
            block.grab_position = {args.mouse_x - block.x, args.mouse_y - block.y}
            block.dragging = true
        elseif block.dragging and args.event == "mouse_click" then
            block:setPos(args.mouse_x-block.grab_position[1], args.mouse_y-block.grab_position[2])
            block.colon.redraw()
            block.dragging = false
        elseif block.dragging and args.event == "mouse_drag" then
            block:setPos(args.mouse_x-block.grab_position[1], args.mouse_y-block.grab_position[2])
            block.colon.redraw()
        elseif args.event == "mouse_up" then
            block.dragging = false
            return "when"
        end

    end
    
	return block
end

return{
	create=create
}