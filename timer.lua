

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
	--a = loadstring("return sprite.create_sprite({file=\"water.pgi\"})")()
	a = sprite.create({image="button.pgi", x=5, y=3})
	--a.rotate90()
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
	print("time = " .. (stop - start))
	
	

end




--timer_image()
timer_button()

	while true do
	event, event_id, x, y = os.pullEvent()
			if event == "mouse_click" then
				a:update(x, y, event)
			elseif event == "mouse_up" then
				a:update(x, y, event)
			end
	end