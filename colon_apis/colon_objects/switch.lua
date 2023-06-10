template = require("colon_apis/colon_objects/template")

function create(args)
    local switch = template.create(args)
    switch.x = tonumber(args.x) or 0
    switch.y = tonumber(args.y) or 0
    switch.width = tonumber(args.width) or 4 -- total width = 0+width, minimum 4
    if switch.width < 4 then switch.width = 4 end
    switch.height = tonumber(args.height) or 2 -- total height = 2+height (height > 0), minimum 3
    if switch.height < 2 then switch.height = 2 end
    switch.name = args.name
    switch.position = 0
    switch.color = switch:correctColor(args.color) or colors.yellow
    switch.background = switch:correctColor(args.background) or colors.blue
    switch.knob_color = switch:correctColor(args.knobColor) or colors.orange
    switch.hidden = args.hidden == "true" or false
    switch.drag_only = args.dragOnly == "true" or false
    switch.configuration = "left"
    switch.dragging = false
    switch.instant = args.instant == "true" or false
    switch.grab_position = 0
    switch.borderless = args.borderless == "true" or false
    switch.character = args.char or " "
    if switch.character:len() > 1 then switch.character = switch.character:sub(1,1) end
    switch.char_color = switch:correctColor(args.charColor) or colors.white
    switch.spacing = tonumber(args.spacing) or 1
    if switch.spacing < 1 then switch.spacing = 1 end
    switch.knob_width = tonumber(args.knobWidth) or 1
    if switch.knob_width < 1 or switch.knob_width >= switch.width-2 then switch.knob_width = 1 end
    switch.colon.log("DragOnly="..tostring(switch.drag_only))

    function switch:draw(x_offset, y_offset)
        --[[
             OOOOOOOOO
            O[] --> []O
             OOOOOOOOO
        ]]
        if switch.hidden then return end
        local inner_width = switch.width-2
        local x, y = switch.x+x_offset, switch.y-y_offset
        if not switch.borderless then switch:drawBoarder(x,y,inner_width) end
        local char_string = string.rep(string.rep(" ", switch.spacing) .. switch.character, math.floor((switch.width-2) / (switch.spacing+1))) .. string.rep(" ", (switch.width-2) % (switch.spacing+1))
        char_string = char_string:sub(1, switch.position) .. string.rep(" ", switch.knob_width) .. char_string:sub(switch.position + switch.knob_width+1)
        --local bg_string = bg_string:sub(1,switch.position) .. string.rep(switch:convertColor(switch.knob_color, 'hex'), switch.knob_width) .. bg_string:sub(inner_width-switch.position-switch.knob_width)
        local bg_string = string.rep(switch:convertColor(switch.background, 'hex'), switch.position) .. string.rep(switch:convertColor(switch.knob_color, 'hex'), switch.knob_width) .. string.rep(switch:convertColor(switch.background, 'hex'), inner_width-switch.position-switch.knob_width)
        term.setBackgroundColor(switch.background)
        for i=1, switch.height-1 do
            term.setCursorPos(x+1,y+i)
            term.blit(char_string, string.rep(switch:convertColor(switch.char_color, 'hex'), inner_width), bg_string)
        end
    end

    function switch:drawBoarder(x, y,inner_width)
        term.setBackgroundColor(switch.color)
        term.setCursorPos(x+1, y)
        io.write(string.rep(" ", inner_width))
        term.setCursorPos(x+1,y+switch.height)
        io.write(string.rep(" ", inner_width))
        for i=1, switch.height-1 do
            term.setCursorPos(x, y+i)
            io.write(string.rep(" ", switch.width))
        end
    end
    
    function switch:update(args)
        if switch.hidden then return end
        if switch.position ~= 0 and switch.position ~= switch.width-2-switch.knob_width then
            local inc = 0
            if switch.configuration == "left" then inc = -1 else inc = 1 end
            switch.colon.log("0 < " .. switch.position .. " < " .. switch.width-2-switch.knob_width .. " mode: " .. switch.configuration)
            switch.position = switch.position + inc
            switch:draw(args.x_offset, args.y_offset)
            return
        end
        if  args.event == "mouse_up" and 
            args.mouse_x >= switch.x and
            args.mouse_x <= switch.x+switch.width and
            args.mouse_y >= switch.y and
            args.mouse_y <= switch.y+switch.height then
            if switch.configuration == "left" then
                switch.configuration = "right"
                switch.position = 1
                if switch.instant then switch.position = switch.width-2-switch.knob_width end
                switch:draw(args.x_offset, args.y_offset)
                return {"when", whenArgs={"triggered", "right"}}
            else
                switch.configuration = "left"
                switch.position = switch.width-2-switch.knob_width-1
                if switch.instant then switch.position = 0 end
                switch:draw(args.x_offset, args.y_offset)
                return {"when", whenArgs={"triggered", "left"}}
            end
        end
    end

    return switch
end

return{
    create=create
}