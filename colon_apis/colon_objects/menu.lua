template = require("colon_apis/colon_objects/template")
button = require("colon_apis/colon_objects/button")

function create(args)
	menu = template.create()
	
	menu.x = tonumber(args.x) or 1
	menu.y = tonumber(args.y) or 1
	menu.dynamic = false
	menu.interactive = true
    menu.sticky = args.sticky
	menu.width = args.width or 10
	menu.height = args.height or 10
    menu.optString = args.options -- semicolon delimited string containing all menu item texts
    menu.options = {}
    menu.buttons = {}
    menu.active = false
	menu.selected = 0
    menu.optCount = 0
    menu.name = args.name or ""
    menu.color = menu:correctColor(args.color) or "lightGray"
    menu.textColor = menu:correctColor(args.textColor) or colors.lightGray
    menu.secondaryColor = menu:correctColor(args.secondaryColor) or menu:correctColor(args.selectedColor) or "gray"
    menu.secondaryTextColor = menu:correctColor(args.secondaryTextColor) or menu:correctColor(args.textColor) or colors.black
    menu.selectedColor = menu:correctColor(args.selectedColor) or colors.black
    menu.selectedTextColor = menu:correctColor(args.selectedTextColor) or colors.white
    menu.page = args.page or "Unknown"
    menu.selectedSaveState={}
    
    menu.hardcodeHeight = 1

    function menu:generateButtons()
        local offset = 0
        for k, text in next, menu.options do
            table.insert(menu.buttons, menu:createButton(text, {x=menu.x,y=menu.y+offset}))
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
            height= menu.hardcodeHeight,
            useTemplate="true",
            sprite=colors.bg,
            hoverSprite=menu.selectedColor,
            color=colors.txt,
            hoverColor=menu.selectedTextColor,
            background=colors.bg,
            hoverbackground=menu.selectedColor,
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
        local optItr = string.gmatch(menu.optString, "([^;]*);*")
        for str in optItr do
            table.insert(menu.options, str)
        end
        menu.optCount = #menu.options
    end

    function calculateYOffset(y_offset)
        return y_offset
    end

    function menu:draw(x_offset, y_offset)
        for k, v in next, menu.buttons do
            v:draw(x_offset, calculateYOffset(y_offset))
        end
    end

    function menu:setSelected(newSelector, context)
        if menu.selected ~= 0 then -- restoration policy
            menu.buttons[menu.selected].sprite:setImage(menu.selectedSaveState.color, true)
            menu.buttons[menu.selected].backgroundColor = menu.selectedSaveState.textColorBackground
            menu.buttons[menu.selected].textColor = menu.selectedSaveState.textColor
            menu.buttons[menu.selected]:draw(context.x_offset, context.y_offset)
        end
        -- select new button
        menu.selectedSaveState = {
            color=menu.buttons[newSelector].spriteFile,
            textColor=menu.buttons[newSelector].textColor,
            textColorBackground=menu.buttons[newSelector].backgroundColor
        }
        menu.selected = newSelector
        menu.buttons[menu.selected].sprite:setImage(menu.selectedColor, true)
        menu.buttons[menu.selected].textColor = menu.selectedTextColor
        menu.buttons[menu.selected].backgroundColor = menu.selectedColor
        menu.buttons[menu.selected]:draw(context.x_offset, context.y_offset)
    end

	function menu:update(obj_args)
		-- for clicking on the menu
        local return_args = {}
		if obj_args["mouse_x"] and obj_args["mouse_y"] then 
			if menu.sticky then y_offset = 0 end
			local hit = menu:isClickInMenu(obj_args)
			if hit then
                if menu.active == false and obj_args["event"] == "mouse_up" then -- clicking menu for the first time
                    menu.colon.log("Toggled Menu")
                    menu.active = true
                    if inColon then
                        colon.scrollLock(true)
                    end
                elseif menu.active then -- menu is already selected
                    for k, button in next, menu.buttons do
                        local x = button:update(obj_args)
                        if x then menu:setSelected(k, obj_args) table.insert(return_args, "when"); return_args["whenArgs"] = {menu.selected} end
                    end
                end
                table.insert(return_args, "scroll")
			elseif obj_args.event == "mouse_up" then
                menu.colon.log("Untoggled menu")
				menu.active = false
				colon.scrollLock(false)
			end
		-- for navigating the menu
		elseif menu.active then
            if obj_args["event"] == "key" and obj_args["event_id"] == 265 then -- up arrow
				if menu.selected > 1 then
                    menu:setSelected(menu.selected-1, obj_args)
                    menu.colon.log("Selected = " .. menu.selected)
                end
			elseif obj_args["event"] == "key" and obj_args["event_id"] == 264 then -- down arrow
                if menu.selected ~= menu.optCount then
                    menu:setSelected(menu.selected+1, obj_args)
                    menu.colon.log("Selected = " .. menu.selected)
                end
            elseif obj_args["event"] == "key" and obj_args["event_id"] == 257 then -- enter key
                table.insert(return_args, "when")
                return_args["whenArgs"] = {menu.selected}
            end
		end
        return return_args
	end

    menu:parseOptString()
    menu:generateButtons()

	return menu
end

return{
	create=create
}