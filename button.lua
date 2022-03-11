

function create(args) 
--[[
	args:
		args.x
		args.y
		args.func
		args.image
		args.hoverImage
]]--
	local button = {}
	
	--default values
	button.x = 0
	button.y = 0
	button.func = function () end -- default function here
	button.locked = false
	button.image = "" -- TODO: Make default image and add here
	button.hoverImage = "" -- TODO: make default image 2 and add here
	button.showingHover = false
	
	if args.x ~= nil then button.x = args.x end
	if args.y ~= nil then button.y = args.y end
	if args.func ~= nil then button.func = args.func end
	if args.locked ~= nil then button.locked = args.locked end
	if args.image ~= nil then button.image = args.image end
	if args.hoverImage ~= nil then button.hoverImage = args.hoverImage end
	
	button.sprite = sprite.create({image=button.image, x=button.x, y=button.y})
	
	if button.locked == nil then
		button.locked = false
	end
	
	
	-- draws the button
	function button:draw(offset_x, offset_y)
		button.sprite:draw(offset_x, offset_y)
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
	
	
	-- implements functionality of button
	function button:update(clickX, clickY, action)
		if button:check_hover(clickX, clickY) then	-- if the mouse is hovering the button
			if action == "mouse_up" then -- if the mouse is clicking the button
				button:click()
				button.sprite:setImage(button.image)
				button:draw()
				button.showingHover = false
			elseif not button.showingHover then -- if the mouse is hovering the button
				button.sprite:setImage(button.hoverImage)
				button:draw()
				button.showingHover = true
			end
		elseif button.showingHover then
			button.sprite:setImage(button.image)
			button:draw()
			button.showingHover = false
		end
	end
	
	return button
end
