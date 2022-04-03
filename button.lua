
function create_button(args)
	
	local button = {}
	
	button.x = tonumber(args.x) or 0
	button.y = tonumber(args.y) or 0
	button.func = args.func
	button.locked = args.locked or false
	button.spriteFile = args.sprite
	button.hoverSpriteFile = args.hoverSprite
	button.showingHover = false
	button.sprite = sprite.create_sprite(button.spriteFile, button.x, button.y)
	button.dynamic = false
	button.interacive = true
	button.height = button.sprite.height
	
	
	-- draws the button
	function button:draw(x_offset, y_offset)
		button.sprite:draw(x_offset, y_offset)
	end
	
	-- implements functionality of button
	function button:update(obj_args)
		
		if button:check_hover(obj_args["mouse_x"], obj_args["mouse_y"]) then	-- if the mouse is hovering the button
			if obj_args["event"] == "mouse_up" then -- if the mouse is clicking the button
				button:click()
				button.sprite:setImage(button.spriteFile)
				button:draw()
				button.showingHover = false
			elseif not button.showingHover then -- if the mouse is hovering the button
				button.sprite:setImage(button.hoverSpriteFile)
				button:draw()
				button.showingHover = true
			end
		elseif button.showingHover then
			button.sprite:setImage(button.spriteFile)
			button:draw()
			button.showingHover = false
		end
	end
	
	
	
	-- checks if a set of coordinates overlaps the buttons sprite
	function button:check_hover(inX, inY)
		--[[
		print("testing if:")
		print("inX: " .. inX .. " > button.x: " .. button.x) 
		print("inX: " .. inX .. " < button.sprite.width: " .. button.sprite.width)
		print("inY: " .. inY .. " > button.y: " .. button.y)
		print("inY: " .. inY .. " > button.sprite.height: " .. button.sprite.height)
		]]--
		if 
		inX >= button.x and
		inX < button.sprite.width+button.x and
		inY >= button.y and
		inY < button.sprite.height+button.y
		then
			return true
		else
			return false
		end
	end
	
	
	-- applies the buttons function if not locked
	function button:click()
		if not button.locked then
			button.func()
		end
	end
	
	
	
	
	
	return button
end