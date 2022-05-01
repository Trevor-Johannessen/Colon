args = {...}
objects = {} -- storage for all objects
when = {}
tags = {}
object_types = {}
screen_width, screen_height = term.getSize() -- dimensions of screen
x_offset = 0
y_offset = 0
end_of_page = 0
background = colors.black
color = colors.white

-- open file and lex lines into tables

function main()
	-- initalize to load apis
	initalize()
	
	-- open file and get line iterator
	local text = get_file_iterator()

	-- parse lines to create objects and insert them into the objects list
	
	for str in text do
		interpret_line(str)
	end
	
	redraw()
	interaction_loop()
end


function get_file_iterator()
	if not fs.exists(args[1]) then error("file not found") end -- if file doesn't exist, error
	return io.lines(args[1])
end

function interpret_line(str)
	local new_obj = parse(str)
	if new_obj ~= -1 then
		if new_obj.y+new_obj.height > end_of_page then end_of_page = new_obj.y+new_obj.height end -- adjust total page height
		table.insert(objects, new_obj)
	end
end


function parse(text, line_num)
	local found_tag
	--os.sleep(1)
	-- find what object type line is
	local colon_pos = string.find(text, ":") -- position of colon used to mark a command
	if not colon_pos then return -1 end -- if a colon is missing then ignore
	
	
	-- find object_type
	local object_type = string.sub(text, 1, colon_pos-1)
	for tag in next, tags do
		--print("object_type = ", object_type)
		--print("trimmed type", string.sub(object_type, 2))
		--print("tag = ", string.sub(object_type, 1, 1))
		if string.sub(object_type, 1, 1) == tag then
			if object_types[string.sub(object_type, 2)] then
				object_type = string.sub(object_type, 2)
				found_tag = tag
				break
			end
			
		end
		
		
	end
	
	text = string.sub(text, colon_pos+1)
	
	-- create arguments in table
	local args = {}
	
	text = trim_input(text)
	

	text = string.gmatch(text, "([^,]*),*")

	-- turn arguments into parameters for the objects
	for term in text do
			--print("term = ", term)
			local equals_pos = string.find(term, "=")
			args[string.sub(term, 0, equals_pos-1)] = string.gsub(string.sub(term, equals_pos+1), string.char(9), ",") -- args[var_name] = var_value
			--print("arg = ", string.sub(term, 0, equals_pos-1))
			--print("tag = ", args[string.sub(term, 0, equals_pos-1)])
	end
	
	
	
	-- if when command
	if object_type == "when" then
		
		for k, v in next, args do
			print(k .. ": " .. v)
		end
		--os.sleep(1000)
		construct_when(args)
		return -1
		
		
	-- if regular object
	elseif object_type == "tag" then
		print("args[tag] = ", args["tag"])
		tags[args["tag"]] = args
		return -1
	elseif object_type == "background" then
		background = colors[args["color"]]
		term.setBackgroundColor(background)
		return -1
	elseif object_type == "color" then
		color = colors[args["color"]]
		term.setTextColor(color)
		return -1
	else
		local obj = loadstring("return " .. object_type .. ".create")()(args)
		if found_tag then
			for k, v in next, tags[found_tag] do 
				-- add all tag attributes to object here
				obj[k] = v
			end
		end
		print("type = ", obj.type)
		obj:corrections()
		return obj
	end
end


-- removes spaces from arguments (ignores spaces and removes commas inside quotes)
function trim_input(text)
	-- I want to find a way to do this with regex
	
	local in_quotes = false
	
	for i=0, string.len(text) do
		if string.sub(text, i, i) == "\"" and string.sub(text, i-1, i-1) ~= "\\" then in_quotes = not in_quotes -- check if in quotes
		elseif string.sub(text, i, i) == " " and not in_quotes then text = string.sub(text, 0, i-1) .. string.sub(text, i+1) -- remove spaces
		elseif string.sub(text, i, i) == "," and in_quotes then text = string.sub(text, 0, i-1) .. string.char(9) .. string.sub(text, i+1) end -- remove commas
	end
	return text
end


function initalize()
	if not fs.exists("/colon_apis/") then error("apis folder does not exist, try reinstalling") end
	
	apis = fs.list("/colon_apis/")
	
	for i=1, table.getn(apis) do
		--print("apis[".. i .. "] = ", apis[i])
		if not fs.isDir(apis[i]) then
			os.loadAPI("/colon_apis/" .. apis[i])
			object_types[string.sub(apis[i], 1, -5)] = true
		end
	end
end


function construct_when(args)
	--print("construct = ", string.sub(args.command, 2, -2))
	--os.sleep(2)
	when[args.name] = string.sub(args.command, 2, -2)
end

 -- INTERPRETING FUNCTIONS
 
function interaction_loop()
	local tick = 1
	local event, event_id, x, y
	local obj_args = {}
	
	
	
	
	
	while true do
		obj_args["tick"] = tick
		
		
		-- update interactive elements
		local timer = os.startTimer(0.05)
		while true do
			event, event_id, x, y = os.pullEvent()

			obj_args["event"] = event
			obj_args["event_id"] = event_id
			obj_args["mouse_x"] = x
			obj_args["mouse_y"] = y
			obj_args["x_offset"] = x_offset
			obj_args["y_offset"] = y_offset
			obj_args["screen_height"] = screen_height
			
			-- give input to all objects that request it
			--message("x = " .. tostring(x) .. "\ty = " .. tostring(y))
			for index, data in ipairs(objects) do
				if data.interactive and data:update(obj_args) then check_when_statements(data.name) end -- the update function for interactive objects should return a boolean for true if triggered, false it not
				if data.dynamic then data:update(obj_args) end
			end
			
			-- handels scrolling of page
			if event == "mouse_scroll" then
				if event_id == -1 and y_offset+screen_height < end_of_page-1 then -- scroll up
					y_offset = y_offset + 1
					redraw()
				elseif event_id == 1 and y_offset >= 1 then -- scroll down
					y_offset = y_offset - 1
					redraw() -- we call redraw twice because it messes with dynamic objects when scrolling at top or bottom of page
				end
				obj_args["y_offset"] = y_offset
				--message("y_offset = " ..  y_offset .. "\t" .. "end_page = " .. end_of_page)
			end
			
			if event == "timer" then break end
		end
		
		tick = tick + 1
	end
end


function redraw()
	
	fill_screen()
	
	for index, data in pairs(objects) do
		term.setCursorPos(1, 9+index)
		--print("printing: ", data.type)	
		data:draw(x_offset, y_offset, screen_height)
	end
end


function fill_screen()
	local x, y = term.getCursorPos()
	local keep_background_color = term.getBackgroundColor()
	term.setBackgroundColor(background)
	term.setCursorPos(1,1)
	for i = 1, screen_height do
		print(string.rep(" ", screen_width))
	end
	term.setCursorPos(x, y)
	term.setBackgroundColor(keep_background_color)
end

function check_when_statements(name)
	for k, v in next, when do
		if k == name then
			term.clear()
			interpret_line(string.gsub(v, "\\", ""))
			redraw()
		end
	end
end


-- HELPER FUNCTIONS
function printarr(arr, substr)
   for i in pairs(arr) do
      print("arr[" .. i .. "] = ", arr[i])
	  if substr then printarr(arr[i]) end
   end
end


function message(message)
	local orgx, orgy = term.getCursorPos()
	term.setCursorPos(1, screen_height)
	term.clearLine()
	io.write(message)
	term.setCursorPos(orgx, orgy)
end

main()