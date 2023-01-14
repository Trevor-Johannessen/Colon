template = require("colon_apis/colon_objects/template")

function create(args)
    
    local menu = template.create()
    
    
    -- draws the current rendition of menu
    function menu:draw(x_offset, y_offset)
        local old_pos = {term.getCursorPos()} -- save current cursor pos
        local old_text_color = term.getTextColor() -- save text color
		local old_background_color = term.getBackgroundColor() -- save background color
		x_offset = x_offset or 0 -- default parameter values
		y_offset = y_offset or 0
		
        term.setCursorPos(menu.x, menu.y)
        local y_pos = menu.y -- y position for as we print list 
        
        if menu.title then -- add title if not nil
            io.write(menu.title)
            y_pos = y_pos+1
        end
        
        y_pos = menu.y -- y position for as we print list 
        for i = menu.top_visible, menu.top_visible+menu.length, 1 do -- for values in list from the current top visible to whats allowed given visible_length
            term.setCursorPos(menu.x - x_offset, y_pos-y_offset) -- set cursor to 1 down
            y_pos = y_pos + 1 -- increment y position
			if i == menu.pos then -- if we are printing the selected line
				term.setTextColor(menu.selected_text_color)
				term.setBackgroundColor(menu.selected_background_color)
				
				
				io.write(menu.list[i] .. string.rep(" ", menu.width-string.len(menu.list[i]))) -- write selected menu item
				
				-- reset colors to original menu color
				term.setBackgroundColor(menu.background_color)
				term.setTextColor(menu.text_color)
			else
				io.write(menu.list[i] .. string.rep(" ", menu.width-string.len(menu.list[i]))) -- write non-selected menu item
			end
		end
        
		-- restore old values
        term.setCursorPos(old_pos[1], old_pos[2]) -- reset cursor to original pos
		term.setTextColor(old_text_color)
		term.setBackgroundColor(old_background_color)
    end
	
    
    -- given input from program, executes what the menu should do
    function menu:update(obj_args)
    
        -- maybe add selectable option where the menu only becomes interactable when you click on it
        -- would need selectable boolean
        -- this value would change here is action = mouse_up
        -- allow selectable to be on by default
        -- allow menu to be mouse independent by automatically selecting
    
    
        -- if arrow up call moveUp()
        -- if arrow down call moveDown()
		if obj_args["event"] == "key" and obj_args["event_id"] == 265 then menu:moveUp() menu:draw() 
		elseif obj_args["event"] == "key" and obj_args["event_id"] == 264 then menu:moveDown() menu:draw()
		elseif obj_args["event"] == "key_up" and obj_args["event_id"] == 257 then menu:select() return 1 end -- select and return true
    end
    
    
    -- decrements the position of the menu down 1
    function menu:moveUp()
        if menu.pos > 1 then menu.pos = menu.pos - 1 end
		if menu.pos < menu.top_visible then menu.top_visible = menu.pos end    
    end
    
    
    -- increments the position of the menu up 1
    function menu:moveDown()
		--decrement position if not at bottom of list
		if menu.pos+1 <= #menu.list then
			menu.pos = menu.pos + 1
		end
		
		-- adjust the top visible if we go off the bottom
		if menu.pos > menu.top_visible + menu.length then 
			menu.top_visible = menu.top_visible + 1 
		end
    end
    
    
    -- selects an option from the menu
    function menu:select()
        loadstring(menu.func)()
    end
    
    
    function longest(list)
		local long = 0
		for i=1, #list do
			if long < string.len(list[i]) then long = string.len(list[i]) end	
		end
		return long
	end
    
	function menu:corrections()
	end
	
	
	
	menu.list = args.list or {}
	menu.width = longest(menu.list)
    menu.pos = 1
    menu.x = tonumber(args.x) or 0
    menu.y = tonumber(args.y) or 0
    menu.text_color = args.text_color or colors.white
    menu.selected_text_color = args.selected_text_color or colors.black
    menu.background_color = args.background_color or colors.black
    menu.selected_background_color = args.selected_background_color or colors.white
    menu.top_visible = 1 -- index of the top most visible option
    menu.length = tonumber(args.length) or 7 -- the number of options shown at any given time
    menu.title = args.title
	menu.func = args.func or function() print("Selected: " .. menu.list[menu.pos]) end
	menu.dynamic = false
	menu.interactive = true
	menu.height = menu.length+1
	menu.name = args.name
	menu.type = "menu"
	
    return menu
end

return{
	create=create
}