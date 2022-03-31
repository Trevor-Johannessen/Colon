

function timer()

	os.loadAPI(arg[1])
	local start = os.clock()
	
	print(loadstring(arg[2])())
		
	local stop = os.clock()
	
	print("time = " .. (stop - start))
	
end


function timer_image()
	term.clear()
	os.loadAPI("sprite.lua")
	local start = os.clock()
	
	--a = loadstring("return sprite.create_sprite(\"water.pgi\")")()
	a = loadstring("return sprite.create({image=\"water.pgi\"})")()
	a.rotate180()
	a.draw()
	
	local stop = os.clock()
	
	--term.clear()
	print("time = " .. (stop - start))
end


function timer_button()
	term.clear()
	os.loadAPI("sprite.lua")
	os.loadAPI("button.lua")
	local start = os.clock()
	
	a = button.create({image="button2.pgi", hoverImage="button.pgi", x=5, y=3})
	a:draw()
	
	local stop = os.clock()
	
	--term.clear()
	--print("time = " .. (stop - start))
	
	

end

function timer_scroll()
	term.clear()
	os.loadAPI("scroll_text.lua")
	
	a = scroll_text.create({speed=2, text="this scrolls left ", x=10, direction="left"})
	b = scroll_text.create({speed=2, text="this scrolls right ", x=10, direction="right"})
	
	
	tick = 0
	while true do
		a:print(5, 5, tick)
		b:print(5, 6, tick)
		tick = tick + 1
		os.sleep(.05)
	end
	
	
	
	while true do
	event, event_id, x, y = os.pullEvent()
			if event == "mouse_click" then
				a:update(x, y, event)
			elseif event == "mouse_up" then
				a:update(x, y, event)
			end
	end
end


function message(message)
	local orgx, orgy = term.getCursorPos()
	term.setCursorPos(1, 19)
	term.clearLine()
	io.write(message)
	term.setCursorPos(orgx, orgy)
end


function timer_loadbar()
	os.loadAPI("loadbar.lua")
	
	a = loadbar.create({x=5, y=5, text="loading bar"})
	
	
	while true do
	event, event_id, x, y = os.pullEvent()
			if event == "mouse_up" then
				a:increment()
				a:draw()
				message("increment")
			elseif event_id == 265 then
				a:reset()
				a:draw()
				message("reset")
			end
	end
end


function timer_menu()
	os.loadAPI("menu.lua")
	
	
	a = menu.create({list={"red", "blue", "yellow", "green", "purple", "pink", "aqua", "magenta"}, length=5,x=5,y=5})
	
	while true do
		event, event_id = os.pullEvent()
		a:handle(event, event_id)
	end
	
	
end

--timer_image()
--timer_button()
--timer_scroll()
--timer_loadbar()
timer_menu()
