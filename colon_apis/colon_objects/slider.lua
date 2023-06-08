
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
    slider.background = slider:correctColor(args.background) or colors.white
    slider.knob_color = slider:correctColor(args.knobColor) or colors.orange
    slider.hidden = args.hidden == "true" or false
    slider.knob_width = tonumber(args.knobWidth) or 1
    if slider.knob_width < 1 or slider.knob_width >= slider.width-2 then slider.knob_width = 1 end

    function slider:draw(x_offset, y_offset)
        --[[
             OOOOOOOOO
            O[] --> []O
             OOOOOOOOO
        ]]
        if not slider.hidden then
            local inner_width = slider.width-2
            local x, y = slider.x+x_offset, slider.y-y_offset
            slider:drawBoarder(x,y,inner_width)
            term.setBackgroundColor(slider.background)
            local printstring = string.rep(slider:convertColor(slider.background, 'hex'), slider.position) .. string.rep(slider:convertColor(slider.knob_color, 'hex'), slider.knob_width) .. string.rep(slider:convertColor(slider.background, 'hex'), inner_width-slider.position-slider.knob_width)
            for i=1, slider.height-1 do
                term.setCursorPos(x+1,y+i)
                term.blit(string.rep(" ", inner_width), string.rep("a", inner_width), printstring)
            end
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

    return slider
end

return{
    create=create
}