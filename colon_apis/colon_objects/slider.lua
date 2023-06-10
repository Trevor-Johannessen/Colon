template = require("colon_apis/colon_objects/template")

function create(args)
    local slider = template.create(args)
    slider.x = tonumber(args.x) or 0
    slider.y = tonumber(args.y) or 0
    slider.width = tonumber(args.width) or 4 -- total width = 0+width, minimum 4
    if slider.width < 4 then slider.width = 4 end
    slider.height = tonumber(args.height) or 2 -- total height = 2+height (height > 0), minimum 3
    if slider.height < 2 then slider.height = 2 end
    slider.name = args.name
    slider.position = 0
    slider.color = slider:correctColor(args.color) or colors.yellow
    slider.background = slider:correctColor(args.background) or colors.red
    slider.knob_color = slider:correctColor(args.knobColor) or colors.orange
    slider.hidden = args.hidden == "true" or false
    slider.drag_only = args.dragOnly == "true" or false
    slider.configuration = "left"
    slider.dragging = false
    slider.grab_position = 0
    slider.borderless = args.borderless == "true" or false
    slider.character = args.char or " "
    if slider.character:len() > 1 then slider.character = slider.character:sub(1,1) end
    slider.char_color = slider:correctColor(args.charColor) or colors.white
    slider.spacing = tonumber(args.spacing) or 1
    if slider.spacing < 1 then slider.spacing = 1 end
    slider.knob_width = tonumber(args.knobWidth) or 1
    if slider.knob_width < 1 or slider.knob_width >= slider.width-2 then slider.knob_width = 1 end
    slider.colon.log("DragOnly="..tostring(slider.drag_only))

    function slider:draw(x_offset, y_offset)
        --[[
             OOOOOOOOO
            O[] --> []O
             OOOOOOOOO
        ]]
        if slider.hidden then return end
        local inner_width = slider.width-2
        local x, y = slider.x+x_offset, slider.y-y_offset
        if not slider.borderless then slider:drawBoarder(x,y,inner_width) end
        local char_string = string.rep(string.rep(" ", slider.spacing) .. slider.character, math.floor((slider.width-2) / (slider.spacing+1))) .. string.rep(" ", (slider.width-2) % (slider.spacing+1))
        char_string = char_string:sub(1, slider.position) .. string.rep(" ", slider.knob_width) .. char_string:sub(slider.position + slider.knob_width+1)
        --local bg_string = bg_string:sub(1,slider.position) .. string.rep(slider:convertColor(slider.knob_color, 'hex'), slider.knob_width) .. bg_string:sub(inner_width-slider.position-slider.knob_width)
        local bg_string = string.rep(slider:convertColor(slider.background, 'hex'), slider.position) .. string.rep(slider:convertColor(slider.knob_color, 'hex'), slider.knob_width) .. string.rep(slider:convertColor(slider.background, 'hex'), inner_width-slider.position-slider.knob_width)
        term.setBackgroundColor(slider.background)
        for i=1, slider.height-1 do
            term.setCursorPos(x+1,y+i)
            term.blit(char_string, string.rep(slider:convertColor(slider.char_color, 'hex'), inner_width), bg_string)
        end
    end

    function slider:drawBoarder(x, y,inner_width)
        term.setBackgroundColor(slider.color)
        term.setCursorPos(x+1, y)
        io.write(string.rep(" ", inner_width))
        term.setCursorPos(x+1,y+slider.height)
        io.write(string.rep(" ", inner_width))
        for i=1, slider.height-1 do
            term.setCursorPos(x, y+i)
            io.write(string.rep(" ", slider.width))
        end
    end

    function slider:hoveringKnob(x)
        return x > slider.x+slider.position and 
            x < slider.x+slider.position+slider.knob_width+1
    end
    
    function slider:update(args)
        if slider.hidden then return end
        if args["mouse_x"] == nil or args["mouse_y"] == nil then return end
        if slider:hoveringKnob(args.mouse_x) and args.event == "mouse_click" then slider.dragging = true; slider.grab_position = args.mouse_x - slider.x - slider.position-1; return end 
        if args.event == "mouse_up" then slider.dragging = false; slider.grab_position = 0 end
        if slider.drag_only and not slider.dragging then return end
        local mx = args["mouse_x"]-slider.x-1-slider.grab_position
        if args.mouse_y < slider.y or args.mouse_y > slider.y+slider.height-1 then return end
        if mx < 0 then return end
        if mx > slider.width-2 then return end
        if mx > slider.width-2-slider.knob_width then mx = slider.width-2-slider.knob_width end
        slider.position = mx
        slider:draw(args.x_offset, args.y_offset)
        if slider.configuration == "left" and slider.position == slider.width-2 then
            slider.configuration = "right"
            return {"when", whenArgs={"triggered", "right"}}
        elseif slider.position == slider.width+1 then
            slider.configuration = "left"
            return {"when", whenArgs={"triggered", "left"}}
        end
        return {"when", whenArgs={"moved", slider.position}}
    end

    return slider
end

return{
    create=create
}