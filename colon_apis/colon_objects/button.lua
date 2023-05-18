screen_width, screen_height = term.getSize() -- dimensions of screen
sprite = require("colon_apis/colon_objects/sprite")
template = require("colon_apis/colon_objects/template")

function create(args)
	
	local button = template.create()
	
	button.x = tonumber(args.x) or 0
	button.y = tonumber(args.y) or 0
	pcall(function () button.func = loadstring(args.func) end)
	button.locked = args.locked or false
	button.singleClick = args.singleClick or false
	button.spriteFile = args.sprite
	button.hoverSpriteFile = args.hoverSprite or args.sprite
	button.usingTemplate = args.useTemplate == "true" or false
	button.showingHover = false
	button.dynamic = false
	button.width = tonumber(args.width)
	button.height = tonumber(args.height)
	button.interactive = true
	button.name = args.name or ""
	button.type = "button"
	button.text = args.text or ""
	button.textColor = button:correctColor(args.color) or colors.black
	button.backgroundColor = button:correctColor(args.background) or colors.white
	button.hoverTextColor = button:correctColor(args.hoverColor) or colors.white
	button.hoverBackgroundColor = button:correctColor(args.hoverBackground) or colors.black
	button.sticky = args.sticky == "true" or false
	button.hoverVisible = not (args.hoverVisible == "false")
	button.transparent = args.transparent == "true" or false
	if button.transparent and args.hoverVisible ~= "true" then button.hoverVisible = false end
	button.propagate = not args.propagate == "false" or true
	button.dbclick = args.dbclick == "true" or false
	button.dbclickTimeout = tonumber(args.dbclickTimeout) or 20
	button.lastClick = 0
	button.page = args.page or "Unknown"

	if button.transparent then
		button.width =  args.width or 0
		button.height = args.height or 0
		if button.hoverVisible and button.hoverSpriteFile == nil then
			button:error("Must provide a hover sprite file when using transparent with hoverSpriteFile set to false.")
		end
	else
		if not button.spriteFile then
			button:error("Must provide sprite a sprite file or template.")
		end
	end
	if button.usingTemplate then
		if not button.width then
			button:error("Must give button a width when using a template.")
		elseif not button.height then
			button:error("Must give button a height when using a template.")
		end
	end
	if button.spriteFile or button.transparent and button.hoverVisible then
		local sprite_args = {
			x=button.x,
			y=button.y,
			width=args.width,
			height=args.height
		}
		local dest = "src"
		if button.usingTemplate then dest = "template" end
		sprite_args[dest] = button.spriteFile

		if button.transparent and button.hoverVisible then sprite_args["src"] = button.hoverSpriteFile end
		button.sprite = sprite.create(sprite_args)
		button.width = button.sprite.width 
		button.height = button.sprite.height
	end
	
	-- draws the button
	function button:draw(x_offset, y_offset)
		if not button.transparent or button.transparent and button.hoverVisible and button.showingHover then
			x_offset = x_offset or 0
			y_offset = y_offset or 0
			
			if button.sticky then 
				x_offset = 0
				y_offset = 0 
			end
			
			button.sprite:draw(x_offset, y_offset)
			button:writeText(x_offset, y_offset)
		end
	end

	function button:writeText(x_offset, y_offset)
		local midpoint = math.floor(button.height / 2)
		term.setCursorPos(math.floor(button.x + x_offset + (button.width - string.len(button.text))/2), button.y+midpoint-y_offset)
		if button.showingHover then
			term.setTextColor(button.hoverTextColor)
			term.setBackgroundColor(button.hoverBackgroundColor)
		else
			term.setTextColor(button.textColor)
			term.setBackgroundColor(button.backgroundColor)
		end
		if(x_offset + button.x + #button.text <= screen_width) then io.write(button.text) end
	end
	
	function button:drawClicked(obj_args)
		if (not button.transparent) or (button.transparent and button.hoverVisible) then 
			if button.hoverVisible then button.sprite:setImage(button.spriteFile, button.usingTemplate) end -- dont need to mess with images for hoverOnly buttons
			button:draw(obj_args["x_offset"], obj_args["y_offset"])
		end
	end

	function button:redrawBackground(obj_args)
		if not button.transparent or button.transparent and button.hoverVisible then 
			if not button.hoverVisible then button.sprite:setImage(button.spriteFile, button.usingTemplate) end -- dont need to mess with images for hoverOnly buttons
			button:draw(obj_args["x_offset"], obj_args["y_offset"])
		end
	end

	function button:setHoverImage()
		if button.hoverVisible then
			button.sprite:setImage(button.hoverSpriteFile, button.usingTemplate) -- dont need to mess with images for hoverOnly buttons
		end
	end

	function button:setDbclick(tick)
		if button.dbclick then button.lastClick = tick end
	end

	-- implements functionality of button
	function button:update(obj_args)
		if button.sticky then 
			obj_args["x_offset"] = 0
			obj_args["y_offset"] = 0 
		end
		obj_args["x_offset"] = obj_args["x_offset"] or 0
		obj_args["y_offset"] = obj_args["y_offset"] or 0
		
		if not obj_args["mouse_x"] or not obj_args["mouse_y"] or button.locked then return end -- check that given action is mouse (and button is not locked)
		if button:check_hover(obj_args["mouse_x"], obj_args["mouse_y"], obj_args["y_offset"]) then	-- if the mouse is hovering the button
			if obj_args["event"] == "mouse_up" and button.showingHover then -- if the mouse is clicking the button	
				local returnArgs = {}
				if not button.propagate then table.insert(returnArgs, "nobubble") end 
				button.showingHover = false
				button:setDbclick(obj_args.tick)
				button:drawClicked(obj_args)
				button:redrawBackground(obj_args)
				if button:click(obj_args) then table.insert(returnArgs, "when") end
				return returnArgs -- button has been clicked
			elseif not button.showingHover and obj_args["event"] == "mouse_click" then -- if the mouse is hovering the button
				button.showingHover = true
				button:setHoverImage()
				button.colon.log("Mouse down on " .. button.name)
				button:draw(obj_args["x_offset"], obj_args["y_offset"])
				return -- button is being hovered
			end
		elseif button.showingHover and button.hoverVisible then
			if not button.hoverVisible then button.sprite:setImage(button.spriteFile, button.usingTemplate) end -- dont need to mess with images for hoverOnly buttons
			button:draw(obj_args["x_offset"], obj_args["y_offset"])
			button.showingHover = false
		end
	end
	
	-- checks if a set of coordinates overlaps the buttons sprite
	function button:check_hover(inX, inY, y_offset)
		if (button.y+button.height-y_offset) >= 0 and (button.y-y_offset) <= 19 then
			if button.sticky then y_offset = 0 end
			if 
			inX >= button.x and
			inX <= button.width+button.x-1 and
			inY >= button.y - y_offset and
			inY <= button.height+button.y-y_offset-1
			then
				return true
			else
				return false
			end	
		end
	end
	
	-- applies the buttons function if not locked
	function button:click(args)
		if button.locked == false then 
			if button.singleClick then button.locked = true end
			if button.func ~= nil then button.func() end
			if button.dbclick and button.lastClick - args.tick > button.dbclickTimeout then return false end
			if button.dbclick then button.tick = args.tick end
			return true
		end
		return false
	end
	
	function button:redraw_background(args)
		term.setBackgroundColor(args.background)
		for i=0, button.height-1 do
			term.setCursorPos(button.x-args.x_offset, button.y-args.y_offset+i)
			io.write(string.rep(" ", button.width))
		end
	end
	
	button:corrections(button)
	
	return button
end


return{
	create=create
}