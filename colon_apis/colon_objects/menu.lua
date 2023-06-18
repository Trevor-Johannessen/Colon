template = require("colon_apis/colon_objects/template")
button = require("colon_apis/colon_objects/button")

function create(args)
	local menu = template.create(args)
	
	menu.x = tonumber(args.x) or 1
	menu.y = tonumber(args.y) or 1
	menu.dynamic = false
	menu.interactive = true
    menu.sticky = args.sticky or false
	menu.width = tonumber(args.width) or 10
	menu.height = tonumber(args.height) or 10
    menu.optString = args.options or "EMPTY"-- semicolon delimited string containing all menu item texts
    menu.options = {}
    menu.buttons = {}
    menu.focused = args.focused or false
	menu.selected = 0
    menu.optCount = 0
    menu.name = args.name or ""
    menu.color = menu:correctColor(args.color) or "lightGray"
    menu.textColor = menu:correctColor(args.textColor) or colors.black
    menu.secondaryColor = menu:correctColor(args.secondaryColor) or menu:correctColor(args.selectedColor) or "gray"
    menu.secondaryTextColor = menu:correctColor(args.secondaryTextColor) or menu:correctColor(args.textColor) or colors.black
    menu.selectedColor = menu:correctColor(args.selectedColor) or colors.white
    menu.selectedTextColor = menu:correctColor(args.selectedTextColor) or colors.black
    menu.page = args.page or "Unknown"
    menu.offset=0
    menu.retain = args.retainFocus == "true"

    menu.hardcodeHeight = 1

    function menu:generateButtons()
        menu.buttons = {}
        local offset = 0
        for k, text in next, menu.options do
            local btn = menu:createButton(text, {x=menu.x,y=menu.y+offset})
            btn.meta = {offset=offset}
            table.insert(menu.buttons, btn)
            offset = offset + menu.hardcodeHeight -- TODO: Change this to the height of the text (with word wrap)
        end
    end

    function menu:createButton(name, pos)
        local colors = {bg=menu.color, txt=menu.textColor}
        if #menu.buttons % 2 == 1 then colors={bg=menu.secondaryColor, txt=menu.secondaryTextColor} end
        local button_args = {
            x=pos.x,
            y=pos.y,
            width=menu.width,
            height=menu.hardcodeHeight,
            useTemplate="true",
            sprite=colors.bg,
            hoverSprite=menu.selectedColor,
            color=colors.txt,
            hoverColor=menu.selectedTextColor,
            background=colors.bg,
            hoverBackground=menu.selectedColor,
            sticky=menu.sticky,
            page=menu.page,
            name=menu.name .. "-" .. name,
            text=name
        }
        return button.create(button_args)
    end

    function menu:isClickInMenu(obj_args)
        return obj_args["mouse_x"] >= menu.x and
        obj_args["mouse_x"] <= menu.width+menu.x-1 and
        obj_args["mouse_y"] >= menu.y - obj_args["y_offset"] and
        obj_args["mouse_y"] <= menu.height+menu.y-obj_args["y_offset"]-1
    end

    function menu:parseOptString()
        menu.options = {}
        local optItr = string.gmatch(menu.optString, "([^;]*);*")
        for str in optItr do
            table.insert(menu.options, str)
        end
        menu.optCount = #menu.options
        menu.height = menu.optCount * menu.hardcodeHeight
    end

    function menu:calculateYOffset(y_offset)
        return y_offset+menu.offset
    end

    function menu:draw(x_offset, y_offset)
        if menu.hidden then return end
        for k, v in next, menu.buttons do
            if k > menu.offset and k <= menu.height+menu.offset then
                v.x = menu.x
                v.y = menu.y + v.meta.offset
                v:draw(x_offset, menu:calculateYOffset(y_offset))
            end
        end
    end

    function menu:restoreSelected(index)
        if type(menu.selectedSaveState) ~= "nil" then -- restoration policy
            menu.buttons[menu.selected].sprite:setImage(menu.selectedSaveState.color, true)
            menu.buttons[menu.selected].backgroundColor = menu.selectedSaveState.textColorBackground
            menu.buttons[menu.selected].textColor = menu.selectedSaveState.textColor
        end
    end

    function menu:saveSelected()
        menu.selectedSaveState = {
            color=menu.buttons[menu.selected].spriteFile,
            textColor=menu.buttons[menu.selected].textColor,
            textColorBackground=menu.buttons[menu.selected].backgroundColor
        }
    end

    function menu:colorSelected()
        menu.buttons[menu.selected].sprite:setImage(menu.selectedColor, true)
        menu.buttons[menu.selected].textColor = menu.selectedTextColor
        menu.buttons[menu.selected].backgroundColor = menu.selectedColor
    end

    function menu:setSelected(newSelector, context)
        menu:restoreSelected()
        menu.selected = newSelector
        menu:saveSelected()
        menu:colorSelected()
        if context then 
            menu:draw(context.x_offset, context.y_offset)
        end
    end

	function menu:update(obj_args)
        if menu.hidden then return end
		-- for clicking on the menu
        local return_args = {}
        if menu.focused then return_args = {"nobubble"} end
		if obj_args["mouse_x"] and obj_args["mouse_y"] then 
			if menu.sticky then obj_args.y_offset = 0 end
			local hit = menu:isClickInMenu(obj_args)
			if hit then
                if menu.focused == false and obj_args["event"] == "mouse_up" then -- clicking menu for the first time
                    menu:setFocus(true)
                    menu.buttons[menu.selected]:draw(obj_args.x_offset, obj_args.y_offset)
                    if inColon then
                        colon.scrollLock(true)
                    end
                elseif menu.focused then -- menu is already selected
                    for k, button in next, menu.buttons do
                        local x = button:update(obj_args)
                        if x then menu:setSelected(k, obj_args); return_args = menu:submit(return_args) end
                    end
                end
                table.insert(return_args, "scroll")
			elseif obj_args.event == "mouse_up" and menu.focused then
				menu:setFocus(false)
				colon.scrollLock(false)
			end
		-- for navigating the menu
		elseif menu.focused then
            if obj_args["event"] == "key" and obj_args["event_id"] == 265 then -- up arrow
				if menu.selected > 1 then
                    if menu.selected - menu.offset == 0 then menu.offset = menu.offset-1 end
                    menu:setSelected(menu.selected-1, obj_args)
                    return_args["whenArgs"] = {"selected", menu.selected}
                end
			elseif obj_args["event"] == "key" and obj_args["event_id"] == 264 then -- down arrow
                if menu.selected ~= menu.optCount then
                    if menu.selected >= menu.height+menu.offset then menu.offset = menu.offset+1 end
                    menu:setSelected(menu.selected+1, obj_args)
                    return_args["whenArgs"] = {"selected", menu.selected}
                end
            elseif obj_args["event"] == "key" and obj_args["event_id"] == 257 then -- enter key
                return_args = menu:submit(return_args)
            end
		end
        return return_args
	end 

    function menu:submit(return_args)
        if not menu.retain then menu:setFocus(false) end
        table.insert(return_args, "when")
        return_args["whenArgs"] = {"pressed", menu.options[menu.selected]}
        return return_args
    end

    function menu:setOptions(newOptString)
        menu.optString = newOptString
        menu:parseOptString()
        menu:generateButtons()
    end

    function menu:focus()
        menu:setFocus(true)
    end

    function menu:unfocus()
        menu:setFocus(false)
    end

    function menu:setFocus(new)
        menu.focused = new
        if new then
            menu:colorSelected()
        else
            menu:restoreSelected()
        end
    end

    menu:parseOptString()
    menu:generateButtons()
    if menu.optCount > 0 then menu.selected = 1; menu:saveSelected() end

	return menu
end

return{
	create=create
}