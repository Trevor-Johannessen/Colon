template = require("colon_apis/colon_objects/template")
menu = require("colon_apis/colon_objects/menu")
button = require("colon_apis/colon_objects/button")
text = require("colon_apis/colon_objects/text")

function formatSelectedText(str, width)
    return str .. string.rep(" ", width-str:len()-1) .. "V"
end

function create(args)
	local dropdown = template.create(args)
	dropdown.name = args.name or ""
    dropdown.x = tonumber(args.x)
    dropdown.y = tonumber(args.y)
    dropdown.dynamic = false
    dropdown.interactive = true
    dropdown.optString = args.options
    dropdown.height = args.height or 10
    dropdown.width = args.width or 10 
    dropdown.color = dropdown:correctColor(args.color) or "lightGray"
    dropdown.textColor = dropdown:correctColor(args.textColor) or colors.black
    dropdown.secondaryColor = dropdown:correctColor(args.secondaryColor) or dropdown:correctColor(args.selectedColor) or "gray"
    dropdown.secondaryTextColor = dropdown:correctColor(args.secondaryTextColor) or dropdown:correctColor(args.textColor) or colors.black
    dropdown.selectedColor = dropdown:correctColor(args.selectedColor) or colors.white
    dropdown.selectedTextColor = dropdown:correctColor(args.selectedTextColor) or colors.black
    dropdown.page = args.page or "Unknown"
    dropdown.defaultOption = args.defaultOptions or "default"
    dropdown.selected = false
    dropdown.selected_string = text.create{
        text=formatSelectedText(dropdown.defaultOption, dropdown.width),
        x=dropdown.x,
        y=dropdown.y,
        width=dropdown.width,
        height=1,
        color=dropdown.textColor,
        background=dropdown.color
    }
    args.y = args.y+1
    args.focused = true
    dropdown.menu = menu.create(args)
    dropdown.button = button.create{
        x=dropdown.x,
        y=dropdown.y,
        transparent="true",
        height=1,
        width=dropdown.width
    }

    function dropdown:draw(x_offset, y_offset)
        if dropdown.hidden then return end
        dropdown.selected_string:draw(x_offset, y_offset)
        if dropdown.selected then
            dropdown.menu:draw(x_offset, y_offset)
        end
    end

    function dropdown:checkBounds(obj_args)
        return obj_args["mouse_x"] >= dropdown.x and
        obj_args["mouse_x"] <= dropdown.width+dropdown.x-1 and
        obj_args["mouse_y"] >= dropdown.y - obj_args["y_offset"] and
        obj_args["mouse_y"] <= dropdown.height+dropdown.y-obj_args["y_offset"]-1
    end

    function dropdown:close(args)
        dropdown.selected=false
        dropdown.menu:unfocus()
        dropdown.colon.redraw(args)
    end

    function dropdown:update(args)
        if dropdown.hidden then return end
        local clicked = dropdown.button:update(args)
        if clicked ~= nil then
            if dropdown.selected then
                dropdown.close(args)
            else
                dropdown.selected = true
                dropdown.menu:focus()
                dropdown:draw(args.x_offset, args.y_offset)
            end
        elseif dropdown.selected then
            if args.event == "mouse_up"and not dropdown:checkBounds(args) then
                dropdown:close(args)
                return
            end
            local menuOutput = dropdown.menu:update(args)
            if menuOutput.whenArgs and menuOutput.whenArgs[1] == "pressed" then
                dropdown.selected_string:set(formatSelectedText(menuOutput.whenArgs[2], dropdown.width))
                dropdown:close(args)
            end
            return menuOutput
        end
    end
    
	return dropdown
end

return{
	create=create
}