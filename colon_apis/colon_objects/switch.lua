template = require("colon_apis/colon_objects/template")

function create(args)
    local slider = template.create(args)
    slider.x = tonumber(args.x) or 0
    slider.y = tonumber(args.y) or 0
    slider.width = tonumber(args.width) or 4 -- total width = 0+width, minimum 4
    if slider.width < 4 then slider.width = 4 end
    slider.height = tonumber(args.height) or 3 -- total height = 2+height (height > 0), minimum 3
    if slider.height < 3 then slider.height = 3 end
    slider.name = args.name
    slider.position = 0
    slider.color = slider:correctColor(args.color) or colors.yellow
    slider.background = slider:correctColor(args.background) or colors.blue
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
    
    function slider:update(args)
        if slider.hidden then return end
        if slider.position ~= 0 and slider.position ~= slider.width-2-slider.knob_width then
            local inc = 0
            if slider.configuration == "left" then inc = -1 else inc = 1 end
            slider.colon.log("0 < " .. slider.position .. " < " .. slider.width-2-slider.knob_width .. " mode: " .. slider.configuration)
            slider.position = slider.position + inc
            slider:draw(args.x_offset, args.y_offset)
            return
        end
        if  args.event == "mouse_up" and 
            args.mouse_x >= slider.x and
            args.mouse_x <= slider.x+slider.width and
            args.mouse_y >= slider.y and
            args.mouse_y <= slider.y+slider.height then
            if slider.configuration == "left" then
                slider.configuration = "right"
                slider.position = 2
                return {"when", whenArgs={"triggered", "right"}}
            else
                slider.configuration = "left"
                slider.position = slider.width-2-slider.knob_width-1
                return {"when", whenArgs={"triggered", "left"}}
            end
        end
    end

    return slider
end

return{
    create=create
}