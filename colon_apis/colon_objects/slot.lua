template = require("colon_apis/colon_objects/template")


--[[
    NOTE: THIS OBJECT IS MEANT TO WORK TOGETHER WITH THE SLOT OBJECT. BOTH ARE REQUIRED FOR FULL FUNCTIONALITY.
]]
function create(args)
	local slot = template.create(args)
    slot:coords(args)
    slot:dim(args)
    slot:essentials(args)
    slot.empty = true
    slot.color = slot:correctColor(args.color) or colors.orange
    slot.activeColor = slot:correctColor(args.color2) or colors.red
    slot.type="slot"


    function slot:draw(x_offset, y_offset)
        if slot.hidden then return end
        term.setBackgroundColor(slot.color)
        term.setCursorPos(slot.x+x_offset+1, slot.y-y_offset)
        io.write(string.rep(" ", slot.width-2))
        for i=1,slot.height-2 do
            term.setCursorPos(slot.x+x_offset,slot.y-y_offset+i)
            io.write(" ")
            term.setCursorPos(slot.x+slot.width-1+x_offset,slot.y-y_offset+i)
            io.write(" ")
        end
        term.setCursorPos(slot.x+x_offset+1, slot.y-y_offset+slot.height-1)
        io.write(string.rep(" ", slot.width-2))
        if not slot.empty then
            term.setBackgroundColor(slot.activeColor)
            term.setCursorPos(slot.x+x_offset+1, slot.y-y_offset+1)
            io.write(" ")
            term.setCursorPos(slot.x+x_offset+slot.width-2, slot.y-y_offset+1)
            io.write(" ")
            term.setCursorPos(slot.x+x_offset+1, slot.y-y_offset+slot.height-2)
            io.write(" ")
            term.setCursorPos(slot.x+x_offset+slot.width-2, slot.y-y_offset+slot.height-2)
            io.write(" ")
        end
    end
    
    function slot:update(args)

    end
    
	return slot
end

return{
	create=create
}