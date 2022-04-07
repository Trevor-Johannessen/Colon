
function create(args)
	
	local button = {}
	
	button.x = tonumber(args.x) or 0
	button.y = tonumber(args.y) or 0
	button.func = args.func or loadstring("term.setCursorPos(1,1) print(\"hello world\")")
	button.locked = args.locked or false
	button.spriteFile = args.sprite
	button.hoverSpriteFile = args.hoverSprite
	button.showingHover = false
	button.dynamic = false
	button.interactive = true
	button.name = args.name
	button.type = "button"
	
	local sprite_args = {}
	sprite_args["x"] = button.x
	sprite_args["y"] = button.y
	sprite_args["src"] = button.spriteFile
	button.sprite = sprite.create(sprite_args)
	button.height = button.sprite.height
	
	-- draws the button
	function button:draw(x_offset, y_offset)
		button.sprite:draw(x_offset, y_offset)
	end
	
	-- implements functionality of button
	function button:update(obj_args)
		if not obj_args["mouse_x"] or not obj_args["mouse_y"] or button.locked then return end
		if button:check_hover(obj_args["mouse_x"], obj_args["mouse_y"], obj_args["y_offset"]) then	-- if the mouse is hovering the button
			if obj_args["event"] == "mouse_up" then -- if the mouse is clicking the button
				button:click()
				if button.showingHover then
					button.sprite:setImage(button.spriteFile)
					button.showingHover = false
				end
				button:draw(obj_args["x_offset"], obj_args["y_offset"])
				return true -- button has been clicked
			elseif not button.showingHover and obj_args["event"] == "mouse_click" then -- if the mouse is hovering the button
				button.sprite:setImage(button.hoverSpriteFile)
				button:draw(obj_args["x_offset"], obj_args["y_offset"])
				button.showingHover = true
			end
		elseif button.showingHover then
			button.sprite:setImage(button.spriteFile)
			button:draw(obj_args["x_offset"], obj_args["y_offset"])
			button.showingHover = false
		end
		return false -- not interacted with
	end
	
	
	
	-- checks if a set of coordinates overlaps the buttons sprite
	function button:check_hover(inX, inY, y_offset)
		if (button.y+button.sprite.height-y_offset) >= 0 and (button.y-y_offset) <= 19 then
			term.setCursorPos(0,0)
			
			--[[
			print("testing if:")
			term.clearLine()
			print("inX: " .. inX .. " > button.x: " .. button.x) 
			term.clearLine()
			print("inX: " .. inX .. " < button.sprite.width+button.x: " .. button.sprite.width+button.x-1)
			term.clearLine()
			print("inY: " .. inY .. " > button.y: " .. button.y-y_offset)
			term.clearLine()
			print("inY: " .. inY .. " > button.sprite.height+button.y-y_offset: " .. button.sprite.height+button.y-y_offset-1)
			
			term.clearLine()
			print("button at: X=", button.x, "-", (button.x+button.sprite.width))
			term.clearLine()
			print("\t\tY=", (button.y-y_offset), "-", (button.y-y_offset+button.sprite.height))
			]]--
			
			if 
			inX >= button.x and
			inX <= button.sprite.width+button.x-1 and
			inY >= button.y - y_offset and
			inY <= button.sprite.height+button.y-y_offset-1
			then
				return true
			else
				return false
			end
		end
	end
	
	
	-- applies the buttons function if not locked
	function button:click()
		button.func()
	end
	
	
	
	
	
	return button
end