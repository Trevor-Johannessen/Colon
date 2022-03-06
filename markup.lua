animate_storage = {} -- storage for the animate function
linked_pages = {} -- linked page file names
linked_page_names = {} -- linked page display names
app_storage = {} -- info for lua apps
variables = {} -- info on variables
printed_lines = {} -- all lines printed with the print or aprint command
displayed_images = {} -- all images shown with the display command
shapes = {} -- all shapes rendered
buttons = {} -- all buttons registered in the page
text_boxes = {} -- all text boxes registered in the program
triggers = {} -- all triggers initialized with the when: statement
background = 32768 -- background colors, default: black
text = 1 -- text colors, default: white
screen_width, screen_height = term.getSize()
arg = {...} -- arguments from command line
loop = true -- loop controler for the animate function
new_page = {false, 1} -- information on newpage
app_size = 6 -- height of lua applet window
app_length = 25 --  length of the applet window
tickrate = 0.05 -- tick rate of the program (20 tps max)
low_resource_mode = false -- an argument for markup, if computer is slow
speaker = nil
page_line = 1
end_of_page = 1
is_API = false

function main()
	print("Last Updated: 11/17/21")
	
	speaker = peripheral.find("speaker")
	term.clear()
	term.setCursorPos(1,1)
	os.loadAPI("powersAPI.lua")
	local file
	
	if arg[1] == "run" then
		file = arg[3]
	elseif arg[1] == nil then
		print("input file")
		file = read()
		term.clear()
		term.setCursorPos(1,1)
	else
		file = arg[1]
	end
	local text = read_file(file)
	local data = lex_table(text)
	
	if arg[2] == "lrm" then
		message("lrm enabled")
		low_resource_mode = true
	end
	
	
	interpret(data)
	--redraw()
	animate()

end


--[[
	lexxes a table of strings
	
	returns:
		a table of lexxed strings (also tables)
]]--
function lex_table(list)
	local output = {}
	for i in pairs(list) do
		output[i] = lex(list[i])
	end
	return output
	
end


--[[
	lexxes a string by seperating by space, CAN handle strings with no spaces
	
	returns:
		a table of all the words in the string
]]--
function lex(str, list, delimiter)
	if delimiter == nil then delimiter = " " end
	if string.find(str, delimiter) == nil then return {str} end
	if list == nil then list = {} end
	return lex_multiple(str, list)
end


--[[
	lexxes a string that has AT LEAST ONE SPACE
	
	returns:
		a table of all words in the string
]]--
function lex_multiple(str, list)
	local n = string.find(str, " ")
	local newstr = string.sub(str, n+1)
	table.insert(list, string.sub(str, 1, n-1))
	if string.find(newstr, " ") ~= nil then
		return lex_multiple(newstr, list)
	else
		table.insert(list, newstr)
		return list
	end
end


--[[
	reads in a file and assembles all its lines into a table
	
	returns:
		table of all text file strings
]]--
function read_file(file)
	local file = io.open(file)
	local continue = true
	local text = {}
	local i = 1
	text[i] = file.read(file)
	while text[i] ~= nil do
		i = i + 1
		text[i] = file.read(file)
	end
	return text
end


--[[
	prints all the contents of a table
	
	parameters:
		arr: table, the array to print
		sub: boolean, print sub table (only 1 layer)
]]--
function printarr(arr, substr)
   for i in pairs(arr) do
      print("arr[" .. i .. "] = ", arr[i])
	  if substr then printarr(arr[i]) end
   end
end


function interpret(list)
	for i in pairs(list) do
		interpret_line(list[i])
	end
end


function interpret_line(list)
	if list[1] == "print:" then
		--[[ 
			Table order
			1: x coordinate
			2: y coordinate
			3: list of words and variables
			4: Hidden (false to show, true to hide)
		]]--
		
		local x, y = term.getCursorPos()
		table.insert(printed_lines, {x, y, list,  false})
		print_line(printed_lines[table.getn(printed_lines)])
		print()
	elseif list[1] == "aprint:" then
		local x = tonumber(list[2])
		local y = tonumber(list[3])
		if y > end_of_page then end_of_page = y+1 end
		table.remove(list, 2)
		table.remove(list, 2)
		table.insert(printed_lines,{x, y, list, false})
		print_line(printed_lines[table.getn(printed_lines)])
	
	elseif list[1] == "display:" then
		local x, y
		if list[3] == nil and list[4] == nil then
			x, y = term.getCursorPos()
		else
			x = tonumber(list[3])
			y = tonumber(list[4])
		end
		local imgx, imgy = get_image_size(list[2])
		if y > end_of_page then end_of_page = y+imgy end
		table.insert(displayed_images, {x, y, list[2]})
		display(x, y, list[2])
	elseif list[1] == "scroll:" then
		list[4] = tonumber(list[4])
		list[3] = tonumber(list[3])
		if list[4] > end_of_page then end_of_page = list[4]+1 end
		scroll(arr_to_string(list, 4), list[2], list[3], list[4])
	elseif list[1] == "gif:" then
		if tonumber(list[3]) > end_of_page then end_of_page = tonumber(list[3])+1 end
		gif(list[2], list[3], list[5], list[4])
	elseif list[1] == "link:" then
		linked_pages[table.getn(linked_pages)+1] = list[2]
		linked_page_names[table.getn(linked_page_names)+1] = arr_to_string(list, 2)
	elseif list[1] == "app:" then
		app(list[2])
	elseif list[1] == "api:" then
		os.loadAPI(list[2])
	elseif list[1] == "unloadapi" then
		os.unloadAPI(list[2])
	elseif list[1] == "var:" then
		local x, y = term.getCursorPos()
		var(list, x, y)
	elseif list[1] == "button:" then
		if tonumber(list[4]) > end_of_page then end_of_page = tonumber(list[4])+1 end
		button(list)
	elseif list[1] == "run:" then
		check_function(replace_variables(list))
	elseif list[1] == "menu:" then
		if tonumber(list[3]) > end_of_page then end_of_page = tonumber(list[3])+1 end
		menu(list)
	elseif list[1] == "textbox:" then
		--[[
			PROPERTIES:
			1: name
			2: x pos
			3: y pos
			4: background color
			5: text color
			6: length
			7: variable name
		]]--
		if tonumber(list[4]) > end_of_page then end_of_page = tonumber(list[4])+1 end
		table.insert(text_boxes, {list[2], tonumber(list[3]), tonumber(list[4]), powersAPI.color_convert(list[5]), powersAPI.color_convert(list[6]), tonumber(list[7]), list[8]})
		draw_text_box(text_boxes[table.getn(text_boxes)])
	elseif list[1] == "background:" then
		background = powersAPI.color_convert(list[2])
		redraw()
	elseif list[1] == "text:" then
		text = powersAPI.color_convert(list[2])
		redraw()
	elseif list[1] == "when:" then
		local name = list[2]
		table.remove(list, 1)
		table.remove(list, 1)
		table.insert(triggers, {name, list})
	elseif list[1] == "newpage:" then
		new_page = {true, list[2]}
	elseif list[1] == "shape:" then
		table.remove(list, 1)
		table.insert(shapes, list)
		shape(list)
	end
	
end


function fill_screen()
	local x, y = term.getCursorPos()
	term.setCursorPos(1,1)
	for i = 1, screen_height do
		print(string.rep(" ", screen_width))
	end
	term.setCursorPos(x, y)
end


function arr_to_string(list, offset)
	if offset == nil then offset = 0 end
	local str = ""
	for i in pairs(list) do
		if i > offset then str = str .. list[i] .. " " end
	end
	str = string.sub(str, 1, string.len(str)-1)
	return str
end


function print_line(list)
	--[[
		List contains
		1: x
		2: y
		3: words
		4: hidden value
	]]--
	local x, y = term.getCursorPos()
	local str = ""
	--term.setCursorPos(list[1], list[2])
	--term.clearLine()
	--term.setCursorPos(screen_width, list[2])
	--io.write("|")
	term.setCursorPos(list[1], list[2])
	str = replace_variables(list[3])
	
	if list[4] then
		io.write(string.rep(" ", string.len(str)))
	else
		powersAPI.parse_color(str)
	end
	term.setCursorPos(x, y)
end


function replace_variables_old(str_in)
	
	if type(str_in) == "string" then
		str_in = lex(str_in)
	end
	
	local str_out = ""
	print("str_in size = ", str_in[1])
	for i in pairs(str_in) do
		if i > 1 then 
			if string.sub(str_in[i], 1, 1) == "~" then
				local var_name = string.sub(str_in[i], 2)
				--message("var_name = ", var_name)
				local var_value = "unknown"
				
				if variables[var_name] ~= nil then
					var_value = variables[var_name]
				end
				str_out = str_out .. var_value .. " "
			else
				str_out = str_out .. str_in[i] .. " "
			end
		end
	end
	print("str_out = " .. str_out)
	return string.sub(str_out, 1, string.len(str_out)-1)
	
end
	
	
function replace_variables(str_in)

	if type(str_in) == "table" then
		str_in = arr_to_string(str_in, 1)
	end

	--print("input = " .. str_in)

	local place = 1
	local output = ""
	
	while place ~= nil do
		place = string.find(str_in, "~")
		if place ~= nil then
			output = output .. string.sub(str_in, 1, place-1)
			str_in = string.sub(str_in, place+1)
			--print("str_in = " .. str_in)
			for i in pairs(variables) do
				if string.len(str_in) >= string.len(i) then
					if string.sub(str_in, 1, string.len(i)) == i then
						str_in = variables[i] .. string.sub(str_in, string.len(i)+1)
					end
				end
				
			end	
		end
	end
	
	output = output .. str_in
	--print("output = " .. output)
	
	return output
end

	
function contains(arr, var) -- var is string name, arr is array of strings
	for i in pairs(arr) do
		--print("checking if " .. arr[i] .. " = " .. var)
		if arr[i] == var then
			return true
		end
	end
	return false
end

	
function change_print_visibility(position, bool)
	
	printed_lines[position][5] = bool
	print_line(printed_lines[position])
	
end
	
	
function message(message)
	local orgx, orgy = term.getCursorPos()
	term.setCursorPos(1, screen_height)
	term.clearLine()
	io.write(message)
	term.setCursorPos(orgx, orgy)
end


function display(x, y, fileName)
	--[[
		open file
		check length of each line
		for number of bits in line, display a pixel
	--]]
	
	local file = io.open(fileName)
	local color
	local height = tonumber(file:read())
	local width = tonumber(file:read())
	local str = file:read()
	local current_char = 1
	local firstx, firsty = term.getCursorPos()
	term.setCursorPos(x, y-page_line+1)
	--message("str = " .. string.sub(str, current_char, current_char+width-1 ))
	
	for i = 1, height do
		if y+i >= page_line and y+i <= page_line + screen_height then
		term.blit(string.rep(" ", width), string.rep("1", width), string.sub(str, current_char, current_char+width-1 ) )
		term.setCursorPos(x, y+i-page_line+1)
		end
		current_char = current_char + width
	end
	
	--[[
	--There's a bug here where when scrolling the image unfolds like a banner, could be useful later. 
	for i = 1, height do
		if y+i+1 > page_line and y+i <= page_line + screen_height then
		message("y+i+1 = " .. (y+i+1) .. ", page_line = " .. page_line)
		term.blit(string.rep(" ", width), string.rep("1", width), string.sub(str, current_char, current_char+width-1 ) )
		current_char = current_char + width
		term.setCursorPos(x, y+i-page_line+1)
		end
	end
	
	]]--
	
	
	file:close()
	term.setCursorPos(firstx, firsty)
end


-- returns max width and height of an image
function get_image_size(fileName)
	local file = io.open(fileName)
	local height = tonumber(file:read())
	local width = tonumber(file:read())
	file:close()
	
	return width, height
end


function scroll(str, in_tickrate, x, y)
	--[[
		Memory List:
		1: "scroll"
		2: scroll text
		3: y position
		4: cursor position
		5: tickrate (ms)
		6: x pos
	]]--
	table.insert(animate_storage, {"scroll", str, y, 1, in_tickrate, x})
end


function gif(x, y, path, tickrate)
	if x == nil or y == nil then
		x, y = term.getCursorPos()
	else
		x = tonumber(x)
		y = tonumber(y)
	end
	--local file = io.open(path .. "/1")
	--[[
		Memory List:
		1: "gif"
		2: path
		3: x position
		4: y position
		5: frame
		6: tickrate (ms)
		
	]]--
	
	
	table.insert(animate_storage, {"gif", path, x, y, 1, tickrate})
	
	local imgx, imgy = get_image_size(path .. "/1")
	display(x, y, path .. "/1")
	
end


function app(name)
	--[[
		Memory List:
		1: "app"
		2: y position
		3: coroutine for app
		4: table of past prints
	]]--
	
	local x, y = term.getCursorPos()
	table.insert(animate_storage, {"app", y+1, coroutine.create(loadstring(name)), {"", "", "", "", ""}})
	
	io.write("---------------------------\n")
	for i = 1, app_size do
		io.write("|                         |\n")
	end
	io.write("---------------------------\n")
	
end


function app_print(statement, in_y, animate_pos)
	
	local x, y = term.getCursorPos()
	
	term.setCursorPos(1, in_y+1)
	for i = 1, app_size-2 do
		io.write("|" .. string.rep(" ", app_length) .. "|\n")
	end
	
	if type(statement) == "string" then
		if statement ~= ("" and nil) then
			table.remove(animate_storage[animate_pos][4], 1)
			table.insert(animate_storage[animate_pos][4], statement)
		end
	elseif type(statement) == "table" then
		for i = 1, app_size do
			animate_storage[animate_pos][4][i] = statement[i]
		end
	end
	
	for i = 1, app_size do
		term.setCursorPos(2, in_y+i-1)
		io.write(string.rep(" ", app_length))
		term.setCursorPos(2, in_y+i-1)
		if animate_storage[animate_pos][4][i] ~= nil then
			io.write(animate_storage[animate_pos][4][i])
		end
		term.setCursorPos(2, in_y+i-1)
	end
	
end


function app_shift_up(in_y, animate_pos)
	
	for i = 1, app_size-1 do
		animate_storage[animate_pos][4][i] = animate_storage[animate_pos][4][i+1]
	end
	
	animate_storage[animate_pos][4][app_size] = ""
		
		
	for i = 1, app_size do
		term.setCursorPos(2, in_y+i-1)
		io.write("                         ")
		term.setCursorPos(2, in_y+i-1)
		if animate_storage[animate_pos][4][i] ~= nil then
			io.write(animate_storage[animate_pos][4][i])
		end
		term.setCursorPos(2, in_y+i-1)
	end
	
end


function var(list)
	--[[
		parameters:
		2: name
		4: value or "function"
		5: function
	]]--
	local str = ""
	local i = 4
	if list[4] == "function" then
		local func = loadstring("return " .. list[5])
		list[4] = func()
	elseif type(list[4]) == "string" then
		while i <= table.getn(list) do
			if type(list[i]) == "string" then
				str = str .. list[i] .. " "
			end
			i = i + 1
		end
		list[4] = string.sub(str, 1, string.len(str)-1)
	end
	variables[list[2]] = list[4]
end


function update_variable(var) -- var is string name of variable

	for i in pairs(printed_lines) do
		if variables[var] ~= nil then
			print_line(printed_lines[i])
		end
	end
	
	for i in pairs(buttons) do
		if variables[var] ~= nil then
			draw_button(buttons[i])
		end
	end
	
end


function button(list)
	local properties = {}
	local x, y
	
	if fs.exists(list[5]) then
		x, y = get_image_size(list[5])
	else
		x = 1
		y = 1
	end
	--[[
		PROPERTIES:
		1: name
		2: x pos
		3: y pos
		4: button image
		5: function
		6: text color
		7: background color
		8: text
		9: image x
		10: image y
		11: button id *not manually set*
	]]--
	properties[1] = list[2]
	properties[2] = tonumber(list[3])
	properties[3] = tonumber(list[4])
	properties[4] = list[5]
	properties[5] = list[6]
	if properties[5] == nil then
		properties[5] = ""
	end
	properties[6] = list[7]
	properties[7] = list[8]
	properties[8] = arr_to_string(list, 8)
	if properties[8] == nil then
		properties[8] = ""
	end
	properties[9] = properties[2] + x
	properties[10] = properties[3] + y
	properties[11] = table.getn(buttons)+1
	table.insert(buttons, properties)
	
	local orgx, orgy = term.getCursorPos()
	term.setCursorPos(properties[2], properties[3])
	--table.insert(displayed_images, {properties[1], properties[2], properties[3]})
	--display(properties[3])
	draw_button(properties)
	term.setCursorPos(orgx, orgy)
	
end

 
function draw_button(button)
	local x, y = term.getCursorPos()
	local old_text_color = term.getTextColor()
	local old_background_color = term.getBackgroundColor()
	local width, height
	
	
	
	
	--term.setCursorPos(button[2], button[3])
	if fs.exists(button[4]) then
		width, height = get_image_size(button[4])
		display(button[2], button[3], button[4])
	else
		width = 1
		height = 1
	end
	
	local text_x
	local text_y = button[3] + math.floor(height / 2)
	
	if button[8] ~= (nil or "") then
		
		term.setTextColor(powersAPI.color_convert(button[6]))
		term.setBackgroundColor(powersAPI.color_convert(button[7]))
		
		
		if string.sub(button[8], 1, 1) == "~" then
			text_x = button[2] + (width / 2) - math.floor((string.len(tostring(variables[string.sub(button[8], 2)])) / 2))
			term.setCursorPos(text_x, text_y-page_line+1)
			io.write(variables[string.sub(button[8], 2)])
		else
			text_x = button[2] + (width / 2) - math.floor((string.len(button[8]) / 2))
			term.setCursorPos(text_x, text_y-page_line+1)
			io.write(button[8])
		end
		
		
		--message(button[7])
		--message("cursor pos = (" .. text_x .. ", " .. text_y .. ")")
		term.setTextColor(old_text_color)
		term.setBackgroundColor(old_background_color)
	end
end


function draw_text_box(text_box)
	local x, y = term.getCursorPos()
	term.setCursorPos(text_box[2], text_box[3]-page_line+1)
	term.setBackgroundColor(text_box[4])
	term.setTextColor(text_box[5])
	
	io.write(string.rep(" ", text_box[6]))
	if text_box[8] ~= nil then
		term.setCursorPos(text_box[2], text_box[3]-page_line+1)
		io.write(text_box[8])
	end
	term.setBackgroundColor(background)
	term.setTextColor(text)
end


function select_text_box(text_box)
	local x, y = term.getCursorPos()
	term.setCursorPos(text_box[2], text_box[3]-page_line+1)
	term.setBackgroundColor(text_box[4])
	term.setTextColor(text_box[5])
	local str = ""
	local character = ""
	local length = 0
	--local str = io.read()
	while true do
		character = get_focused_input()
		if length < text_box[6] and character >= 20 and character <= 126 then
			character = string.lower(string.char(character))
			io.write(character)
			str = str .. character
			length = length + 1
		elseif length > 0 and character == 259 then -- backspace
			str = string.sub(str, 1, length-1)
			length = length - 1
			term.setCursorPos(text_box[2] + length, text_box[3]-page_line+1)
			io.write(" ")
			term.setCursorPos(text_box[2] + length, text_box[3]-page_line+1)
		elseif character == 257 then -- enter
			--[[
			if not fs.exists(str) and fs.exists("fileTransferClient.lua") then
				message("str = " .. str)
				os.loadAPI("fileTransferClient.lua")
				str = fileTransferClient.main(str)
				message("str = " .. str)
			end
			
			check_function(text_box[6], str
			]]--
			
			variables[text_box[7]] = str
			text_box[8] = str
			break
			
		end
		--message(str)
	end
	--message("str = " .. str)
	
	
	term.setBackgroundColor(background)
	term.setTextColor(text)
end


function menu(list)
	-- menu, x, y, list, function
	local pos
	
	for i in pairs(list) do
		if string.sub(list[i], 1, 1) == "~" then
			list[i] = variables[string.sub(list[i], 2)]
			--print("substituting list[" .. i .. "] with " .. list[i])
		end
	end

	pos = menu_select(list[4], tonumber(list[2]), tonumber(list[3]), list[6], list[7], list[8], list[9])
	
	if list[5] ~= nil then
		if string.find(list[5], ",") == nil then
			list[5] = string.sub(list[5], 1, string.len(list[5])-1) .. pos .. ")"
		else
			list[5] = string.sub(list[5], 1, string.len(list[5])-1) .. ", " .. pos .. ")"
		end
		check_function(list[5])
	end
end


function menu_select(choices, x_offset, y_offset, in_background_color, in_text_color, in_selected_background_color, in_selected_text_color)
	
	local top_visible = 1
	
	local background_color = tonumber(in_background_color)
	local text_color = tonumber(in_text_color)
	local selected_background_color = tonumber(in_selected_background_color)
	local selected_text_color = tonumber(in_selected_text_color)
	
	if tonumber(in_background_color) == nil then
		--print("setting background")
		background_color = colors.black
	end
	if tonumber(in_text_color) == nil then
		--print("setting text")
		text_color = colors.white
	end
	if tonumber(in_selected_background_color) == nil then
		--print("setting selected background")
		selected_background_color = colors.white
	end
	if tonumber(in_selected_text_color) == nil then
		--print("setting selected text")
		selected_text_color = colors.black
	end
	
	if x_offset == nil then x_offset = 1 end
	if y_offset == nil then y_offset = 1 end
	
	for i = 1, y_offset do print() end
	
	local posx, posy
	
	local choice_num = table.getn(choices)
	
	if choices[choice_num] ~= "exit" then
		choices[choice_num+1] = "exit"
		choice_num = choice_num + 1
	end
	
	local max_choices = screen_height - y_offset
	
	local continue = true -- whether to continue from the title screen or not (until a player selects something)
	local position = top_visible
	
	while continue do
		
		term.setCursorPos(x_offset, y_offset) -- center the menu here
		posx, posy = term.getCursorPos()
		-- print the songs along with whatever the highlight is on
		--message("table size = " .. choice_num)
		
		for i = 1, choice_num do 							-- for each choice
			if i == position then 										-- if the choice is selected
				term.setBackgroundColor(selected_background_color)
				term.setTextColor(selected_text_color)
				io.write(choices[i])
				term.setBackgroundColor(background_color)
				term.setTextColor(text_color)
				posy = posy+1
				term.setCursorPos(x_offset, posy)
			else
				if i >= top_visible then
					io.write(string.rep(" ", screen_width - x_offset))
					term.setCursorPos(x_offset, posy)
					io.write(choices[i])
					posy = posy+1
					term.setCursorPos(x_offset, posy)
				end
			end
			
		end
		
		posy = posy - choice_num							-- reset the Y position
		local event, key_id = os.pullEvent("key")
		--term.clear()
		--print("key_id = ", key_id)
		if key_id == 265 then -- up arrow
			
			if position ~= 1 then 
				position = position - 1
				
				if position == top_visible then
					if top_visible ~= 1 then
						top_visible = top_visible - 1
					end	
				end
				
			end
			
		elseif key_id == 264 then -- down arrow
			
			if position ~= choice_num then 
				position = position + 1
				
				if position == top_visible + 20 - y_offset then
					if top_visible + screen_height - y_offset ~= choices_num then
						top_visible = top_visible + 1
					end
				end
			end
		
		elseif key_id == 257 then -- enter
			continue = false
			return position
		
		else -- if no acceptable key
			if speaker ~= nil then
				speaker.playNote("harp", 3, 24)
			end
		end
		
	end
	
end


function draw_page_manager()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	local xPos = screen_width
	
	for i = 1, 15 do
		for j = 1, screen_height do
			--if i > 1 then
				for k = 1, screen_height do
					term.setCursorPos(xPos-i+1,k)
					io.write(" ")
				end
			--end
			term.setCursorPos(xPos-i,j)
			io.write("|")
		end
		if i % 2 == 0 and not low_resource_mode then
			os.sleep(.05)
		end
	end
	
	term.setCursorPos(38,2)
	io.write("Page Manager")
	
	page_manager()
	
end


function destroy_page_manager(quick)
	
	if low_resource_mode then
		quick = true
	end
	
	local xPos = screen_width
	local background_str = powersAPI.color_to_hex(background)
	local text_str = powersAPI.color_to_hex(text)
	for i = 1, 15 do
		for j = 1, screen_height do
			if i < 15 then
				for k = 1, screen_height do
					term.setCursorPos(xPos-(15-i)+1,k)
					term.blit("|", text_str, background_str)
					--io.write("|")
				end
			end
			term.setCursorPos(xPos-(15-i)-1,j)
			term.blit(" ", text_str, background_str)
		end
		if i % 2 == 0 and not quick then
			os.sleep(.05)
		end
	end
	redraw()
	

end


function page_manager()
	local output = menu_select(linked_page_names,38,3)
	
	if output == (table.getn(linked_pages)+1) then -- if 'exit' is selected
		destroy_page_manager()
		
	else
		-- create a function to trash this webpage and open another webpage
		--linked_pages[output] -- this would be the parameter
		new_page = {true, linked_pages[output]}
		loop = false
	end
	
end


function refresh()
	animate_storage = {}
	linked_pages = {}
	linked_page_names = {}
	printed_lines = {}
	displayed_images = {}
	buttons = {}
	text_boxes = {}
	triggers = {}
	variables = {}
	background = colors.black
	text = colors.white
	term.setBackgroundColor(background)
	term.setTextColor(text)
	fill_screen()
	arg = {}
	loop = true
	new_page = {false, 1}
end


function shape(list)
	
	if list[1] == "circle" then
		--[[
			Arguments:
				1: X pos
				2: Y pos
				3: Color
				4: Radius
				
		]]--
		circle(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]), tonumber(list[5]))
			
	elseif list[1] == "circle_outline" then
		circle_outline(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]), tonumber(list[5]))
		
	elseif list[1] == ("box" or "square" or "rectangle") then
		--[[
			Arguments:
			2: X pos
			3: Y pos
			4: Color
			5: Length
			6: Width
			
		]]--
		
		rectangle(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]), tonumber(list[5]), tonumber(list[6]))
		
	
	elseif list[1] == "boarder" then
	
		boarder(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]), tonumber(list[5]), tonumber(list[6]))
	
	elseif list[1] == "triangle" then
		--[[
			Arguments:
			2: x
			3: y
			4: base
			5: height
		]]--
		
		triangle(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]) 	, tonumber(list[5]), tonumber(list[6]))
	
	elseif list[1] == "left_triangle" then
		left_triangle(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]), tonumber(list[5]), tonumber(list[6]))
	
	elseif list[1] == "right_triangle" then
		right_triangle(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]), tonumber(list[5]), tonumber(list[6]))
	
	elseif list[1] == "point" then
		point(tonumber(list[2]), tonumber(list[3]), powersAPI.color_convert(list[4]))
	end
	
	
end


function circle(x, y, color, radius)
	local new_background_color = powersAPI.color_to_hex(color)
	
	term.setCursorPos(x-radius, y-radius)
	
	for i = -radius, radius do
		
		for j = -radius, radius do
			if ((i)^2) + ((j)^2) <= radius^2 then
				term.blit(" ", "a", new_background_color)
			else
			    term.setCursorPos(x+j+1, y+i)
			end
    	end
	    --print()
		term.setCursorPos(x-radius, y+i+1)
		--term.setCursorPos(x, y+i+1)
	end
end


function circle_outline(x, y, color, radius)
	local new_background_color = powersAPI.color_to_hex(color)
	
	term.setCursorPos(x-radius, y-radius)
	
	for i = -radius, radius do
		for j = -radius, radius do
			if ((i)^2) + ((j)^2) >= radius^2 then
				term.blit(" ", "a", new_background_color)
			else
			    term.setCursorPos(x+j+1, y+i)
			end
    	end
	    term.setCursorPos(x-radius, y+i+1)
	end
end


function rectangle(x, y, color, length, width)
	term.setCursorPos(x, y)
	term.setBackgroundColor(color)
	for i = 1, tonumber(width) do
		print(string.rep(" ", length))
		term.setCursorPos(x, y+i-1)
	end
		
	term.setBackgroundColor(background)
end


function boarder(x, y, color, width, height)
    
    local new_background_color = powersAPI.color_to_hex(color)
    
    for i = 1, height do
        term.setCursorPos(x, y+i-1)
        term.blit(" ", "a", new_background_color)
    end
    
    for i = 1, height do
        term.setCursorPos(x+width, y+i-1)
        term.blit(" ", "a", new_background_color)
    end
    
    for i = 1, width do
        term.setCursorPos(x+i-1, y)
        term.blit(" ", "a", new_background_color)
    end
    
    for i = 1, width+1 do
        term.setCursorPos(x+i-1, y+height)
        term.blit(" ", "a", new_background_color)
    end
    
end


function triangle(x, y, color, base, height)

	term.setCursorPos(x, y)
	
	local new_background_color = powersAPI.color_to_hex(color)
    local slope = height/(base/2)

    for i = 1, height do
        for j = 1, base do
            if (j < (i/slope)+base/2) and (j > (i/-slope)+base/2) then
                term.blit(" ", "a", new_background_color)
			else
			    term.setCursorPos(x+j, y+i)
            end
        end
        term.setCursorPos(x, y+i+1)
    end
end


function right_triangle(x, y, color, base, height)
    term.setCursorPos(x, y)
	local new_background_color = powersAPI.color_to_hex(color)
	
    local slope = height/(base)
    
    for i = 1, height do
        for j = 1, base do
            if (j > (i/-slope)+base) then
                term.blit(" ", "a", new_background_color)
			else
			    term.setCursorPos(x+j, y+i)
            end
        end
        term.setCursorPos(x, y+i+1)
    end
end


function left_triangle(x, y, color, base, height)
    term.setCursorPos(x, y)
	local new_background_color = powersAPI.color_to_hex(color)
	
    local slope = height/(base)
    
    for i = 1, height do
        for j = 1, base do
            if (j < (i/slope)) then
                term.blit(" ", "a", new_background_color)
			else
			    term.setCursorPos(x+j, y+i)
            end
        end
        term.setCursorPos(x, y+i+1)
    end
end


function point(x, y, color)
	
	term.setCursorPos(x, y)
	term.blit(" ", "a", powersAPI.color_to_hex(color))
	
end


function redraw()
	term.setBackgroundColor(background)
	term.setTextColor(text)
	fill_screen()
	local x, y = term.getCursorPos()
	for i in pairs(printed_lines) do
		--message("y = " .. printed_lines[i][2])
		if printed_lines[i][2] >= page_line and printed_lines[i][2] < page_line + screen_height then
			--print("array = ", arr_to_string(printed_lines[i][3], 1))
			--print_line(printed_lines[i][3], 1)
			print_line({printed_lines[i][1], printed_lines[i][2]-page_line+1, printed_lines[i][3], printed_lines[i][4]})
		end
	end
	
	for i in pairs(displayed_images) do
		display(displayed_images[i][1], displayed_images[i][2], displayed_images[i][3])
	end
	
	for i in pairs(buttons) do
		draw_button(buttons[i])
	end
	
	for i in pairs(text_boxes) do
		draw_text_box(text_boxes[i])
	end
	
	for i in pairs(shapes) do
		shape(shapes[i])
	end
	
	if not is_API then
		for i = 1, screen_height do
			term.setCursorPos(screen_width, i)
			io.write("|")
		end
	end
	
	term.setCursorPos(x, y)
end


function get_focused_input()
	local myTimer = os.startTimer(2048)
	while true do
		event, event_id = os.pullEvent()		
		if event == "key" then
			return event_id
		end
	end
end


-- finds if key pressed is related to a function, returns true if is, false if isn't
function find_keys(key)
	
	if event_id == 80 then -- P
		draw_page_manager()
		return true
	elseif event_id == 75 then -- K
		page_line = page_line - 1
		redraw()
	elseif event_id == 76 then -- L
		page_line = page_line + 1
		redraw()
	end

	return false
end


function check_cursor(x, y)
	local str
	local command = powersAPI.check_links(x,y)
	--message("cursor at " .. x .. ", " .. y)
	for i in pairs(buttons) do
		if (x >= buttons[i][2] and x < buttons[i][9]) and (y >= buttons[i][3]-page_line+1 and y < buttons[i][10]-page_line+1) then
			message("before check function")
			print(buttons[i][5])
			check_function(buttons[i][5])
			message("past check function")
			check_trigger(buttons[i])
			message("past check trigger")
			--check_function(buttons[i][4], {buttons[i][10]})
		end
	end
	
	for i in pairs(text_boxes) do
		if y == text_boxes[i][3]-page_line+1 and x >= text_boxes[i][2] and text_boxes[i][2]+text_boxes[i][6] >= x then
			--message("selecting box " .. i)
			select_text_box(text_boxes[i])
			check_trigger(text_boxes[i])
		end
	end
end


function check_trigger(var)
	for i in pairs(triggers) do
		if triggers[i][1] == var[1] then
			--message("found trigger: ", triggers[i][1])
			interpret_line(triggers[i][2])
		end
	end
end


function check_function(input)
	input = replace_variables(input)
	
	if string.sub(input, 1, 7) == "search:" then
		new_page = {true, string.sub(input, 8)}
	elseif string.sub(input, 1, 4) == "ping" then
		message("ping")
	else
		local func = loadstring("return " .. input)
		str = func()
		
		if type(str) == "string" then str = {str}
		elseif type(str) == "nil" then str = {} end
		
		for i in pairs (str) do
			if str[i] ~= nil then
				if string.sub(str[i], 1, 4) == "set:" then
					local list = lex(str[i])
					
					if list[3] == "!list" then
						variables[list[2]] = parse_string(list[4])
						--print("set " .. list[2] .. " as ", variables[list[2]])
					else
						-- set variable to value
						if table.getn(list) > 3 then
							variables[list[2]] = arr_to_string(list, 2)
						else
							variables[list[2]] = list[3]
						end
						update_variable(list[2])
					end
				elseif string.sub(str[i], 1, 7) ==  "search:" then
					new_page = {true, string.sub(str[i], 9)}
				end
			end
		end
	end
	
end


function parse_string(str)
	local list = {}
	local pos = 0
	pos = string.find(str, "::")
	while pos ~= nil do
		table.insert(list, string.sub(str, 1, pos-1))
		str = string.sub(str, pos+2)
		pos = string.find(str, "::")
	end
	table.insert(list, str)
	
	return list
	
end


function animate()
	local tick = 1
	local myTimer
	local event, eventID, x, y
	local focus = true
	local statement
	local success -- if resume was successful or not
	local last_input = "placeholder"
	local get_raw_input = false
	
	-- adds the cool bar thing on the side
	for i = 1, screen_height do
		term.setCursorPos(screen_width,i)
		io.write("|")
	end
	term.setCursorPos(1,1)
	
	while loop do
		--message(tick)
		
		for i = 1, table.getn(animate_storage) do
			--os.sleep(.5)
			
			if animate_storage[i][1] == "scroll" and (tick % animate_storage[i][5]) == 0 then
				local str = animate_storage[i][2]
				local cursor_pos = animate_storage[i][4]
				
				if animate_storage[i][3] >= page_line and animate_storage[i][3] <= page_line + screen_height then
				
					term.setCursorPos(animate_storage[i][6], animate_storage[i][3] - page_line+1)
					--term.clearLine()
					io.write(string.sub(animate_storage[i][2], cursor_pos+1) .. string.sub(animate_storage[i][2], 1, cursor_pos))
					
				end
				animate_storage[i][4] = cursor_pos + 1
				if cursor_pos == string.len(str) then
					animate_storage[i][4] = 1
				end
				
			elseif animate_storage[i][1] == "gif" and (tick % animate_storage[i][5]) == 0 then
				local frame = animate_storage[i][5]
				local path = animate_storage[i][2]
				frame = frame + 1
				if not fs.exists(path .. "/" .. frame) then
					frame = 1
				end
				display(animate_storage[i][3], animate_storage[i][4], path .. "/" .. frame)
				
				animate_storage[i][5] = frame
				
			
			elseif animate_storage[i][1] == "app" then
				
				--[[
					Current Commands:
					"get_string_input" - halts program activity using read() and prompts input
					"get_input" - passes whatever input the program picks up to the app
					"get_focused_input" - halts program activity and waits for input (much more accurate)
				]]--
				
				if coroutine.status(animate_storage[i][3]) == "dead" then
					table.remove(animate_storage, i)
				else
					focus = true
					local x,y = term.getCursorPos()
					
					term.setCursorPos(2, animate_storage[i][2])
					
					while focus do
					
						success, statement, focus = coroutine.resume(animate_storage[i][3], last_input)
		
						if focus == nil then focus = false end
						
						if statement == "get_string_input" then
							get_raw_input = false
							term.setCursorPos(2, animate_storage[i][2]+app_size-1)
							last_input = read()
							app_print(last_input, animate_storage[i][2], i)
							
						elseif statement == "get_input" then
							get_raw_input = true
							
						elseif statement == "get_focused_input" then
							get_raw_input = false
							last_input = get_focused_input()
							
						elseif statement == "set_var" then
							local success, name, assignment = coroutine.resume(animate_storage[i][3])
							--[[
							for j in pairs(variables) do
								if variables[j][1] == name then
									variables[j][2] = assignment
									update_variable(name)
								end
							end
							]]--
							variables[name] = assignment
							update_variable(name)
						elseif statement == "get_var" then
							local success, name = coroutine.resume(animate_storage[i][3])
							local value
							--[[
							for j in pairs (variables) do
								if variables[j][1] == name then
									value = variables[j][2]
								end
							end
							]]--
							value = variables[name]
							coroutine.resume(animate_storage[i][3], value)
						
						elseif statement == "set_visibility" then
							local success, position, value = coroutine.resume(animate_storage[i][3])
							change_print_visibility(position, value)
						
						elseif statement == "get_visibility" then
							local success, position = coroutine.resume(animate_storage[i][3])
							term.setCursorPos(1, 15)
							--print("success = " .. tostring(success))
							--print("position = " .. position)
							coroutine.resume(animate_storage[i][3], printed_lines[position][5])
						elseif statement ~= "" and type(statement) == "string" then
							app_print(statement, animate_storage[i][2], i)
							
						elseif type(statement) == "table" then
							app_print(statement, animate_storage[i][2], i)
						end
					end
				end	
				
				
			end
			
		end	
		
		myTimer = os.startTimer(tickrate)
		while true do
			event, event_id, x, y = os.pullEvent()
			if get_raw_input then last_input = event_id end			
			if event == "key" then
				--message(event_id) 
				find_keys(event_id)
				break
			elseif event == "mouse_click" then
				
				check_cursor(x, y)
				break
			
			elseif event == "mouse_scroll" then
				if event_id == -1 and page_line > 1 then
					page_line = page_line - 1
					redraw()
					--message("End of page: " .. end_of_page .. "\t page_line: " .. page_line)
				elseif event_id == 1 and page_line+screen_height < end_of_page then
					page_line = page_line + 1
					redraw()
					--message("End of page: " .. end_of_page .. "\t page_line: " .. page_line)
				end
			elseif event == "timer" and event_id == myTimer then break end
		end
		
		if new_page[1] then
			local hold = new_page[2]
			refresh()
			arg[1] = hold -- if i try to assign arg[1] new_page[2] it becomes 1 for some reason
			main()
			break
		end
		
		
		tick = tick + 1
	end
	

end

if arg[1] ~= nil then
	main()
else
	is_API = true
end
