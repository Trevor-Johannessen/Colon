screen_width, screen_height = term.getSize() -- dimensions of screen
object_types = object_types or {}
debugMode = false

pages = pages or {}
currentPage = currentPage or ""

-- open file and lex lines into tables
function run(inArgs)
	args = inArgs
	initalize(args) -- initalize to load apis
	process_file(args[1])
	interaction_loop()
end

function process_file(fileName)
	-- open file and get line iterator
	local text = get_file_iterator(fileName)

	-- parse lines to create objects and insert them into the objects list
	for str in text do
		interpret_line(str, fileName)
	end
	redraw()
end

function get_file_iterator(fileName)
	if not fs.exists(fileName) then error("file '" .. fileName .. "' not found") end -- if file doesn't exist, error
	return io.lines(fileName)
end

function interpret_line(str, givenPage, whenName)
	local new_obj = parse(str, givenPage, whenName)
	if new_obj ~= -1 then
		if 	not new_obj.unplaceable and 
			new_obj.y+new_obj.height > pages[givenPage].end_of_page then 
				pages[givenPage].end_of_page = new_obj.y+new_obj.height -- adjust total page height
		end 
		if new_obj.name ~= nil then
			pages[givenPage].objects[new_obj.name] = new_obj
		else
			table.insert(pages[givenPage].objects, new_obj)
		end
	end
end

function initalize_page(pageName)
	pages[pageName] = {}
	pages[pageName].when = {}
	pages[pageName].objects = {} -- storage for all objects
	pages[pageName].tags = {}
	pages[pageName].x_offset = 0
	pages[pageName].y_offset = 0
	pages[pageName].end_of_page = 0
	pages[pageName].background = colors.black
	pages[pageName].color = colors.white
	pages[pageName].scroll_lock = false
end


function parse(text, givenPage, whenName)

	local found_tag
	-- find what object type line is
	local colon_pos = string.find(text, ":") -- position of colon used to mark a command
	if not colon_pos then return -1 end -- if a colon is missing then ignore
	
	-- find object_type
	local object_type = string.sub(text, 1, colon_pos-1)
	for tag in next, pages[givenPage].tags do
		if string.sub(object_type, 1, 1) == tag then
			if object_types[string.sub(object_type, 2)] then
				object_type = string.sub(object_type, 2)
				found_tag = tag
				break
			end
		end
	end
	
	-- create arguments in table
	local args = {}
	text = string.sub(text, colon_pos+1)
	text = trim_input(text)
	text = string.gmatch(text, "([^,]*),*")

	-- turn arguments into parameters for the objects
	for term in text do
		local equals_pos = string.find(term, "=")
		local key = string.sub(term, 0, equals_pos-1)
		args[key] = string.gsub(string.sub(term, equals_pos+1), string.char(9), ",") -- args[var_name] = var_value
		if(args[key]:sub(1, 1) == "\"" and args[key]:sub(-1) == "\"") then 
			args[key] = args[key]:sub(2,-2) 
		end
	end
	if debugMode then print(object_type) end
	-- if when command
	if object_type == "when" then
		construct_when(args, givenPage)
		return -1
	-- if regular object
	elseif object_type == "tag" then
		if debugMode then print("args[tag] = ", args["tag"]) end
		pages[givenPage].tags[args["tag"]] = args
		return -1
	elseif object_type == "background" then
		pages[givenPage].background = colors[args["color"]]
		term.setBackgroundColor(pages[givenPage].background)
		return -1
	elseif object_type == "color" then
		pages[givenPage].color = colors[args["color"]]
		term.setTextColor(pages[givenPage].color)
		return -1
	elseif object_type == "load" then
		initalize_page(args["file"])
		process_file(args["file"])
		return -1
	else
		if found_tag then
			for k, v in next, pages[givenPage].tags[found_tag] do 
				-- add all tag attributes to object here
				if debugMode then print("arg[", k, "] = ", args[k]) end
				if args[k] == nil then
					args[k] = v
				end
			end
		end
		args["when"] = whenName -- delivers whenName to objects created from when triggers
		return object_types[object_type].create(args)
	end
end

-- removes spaces from arguments (ignores spaces and removes commas inside quotes)
function trim_input(text)
	local in_quotes = false
	for i=0, string.len(text) do
		if string.sub(text, i, i) == "\"" and string.sub(text, i-1, i-1) ~= "\\" then in_quotes = not in_quotes -- check if in quotes
		elseif string.sub(text, i, i) == " " and not in_quotes then text = string.sub(text, 0, i-1) .. string.sub(text, i+1) -- remove spaces
		elseif string.sub(text, i, i) == "," and in_quotes then text = string.sub(text, 0, i-1) .. string.char(9) .. string.sub(text, i+1) end -- remove commas
	end
	return text
end

function initalize(args)
	if not fs.exists("/colon/colon_apis/") then error("apis folder does not exist, try reinstalling") end
	if not fs.exists("/colon/colon_apis/colon_objects/") then error("objects folder does not exist, try reinstalling") end
	
	apis = fs.list("/colon/colon_apis/colon_objects/")
	
	for i=1, table.getn(apis) do
		if debugMode then print("apis[".. i .. "] = ", apis[i]) end
		if not fs.isDir(apis[i]) then
			local noExtension = string.sub(apis[i], 1, -5)
			object_types[noExtension] = require("colon_apis/colon_objects/" .. noExtension) 
		end
	end
	initalize_page(args[1])
	currentPage = args[1]
end


function construct_when(args, givenPage)
	if debugMode then print("construct = ", args.command) end
	pages[givenPage].when[args.name] = args.command
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
			obj_args["x_offset"] = pages[currentPage].x_offset
			obj_args["y_offset"] = pages[currentPage].y_offset
			obj_args["screen_height"] = screen_height
			obj_args["screen_width"] = screen_width
			
			-- give input to all objects that request it
			local foundWhen = false
			for index, data in pairs(pages[currentPage].objects) do
				if data.awaitingRedraw then 
					data.awaitingRedraw = false
					data:draw(obj_args.x_offset, obj_args.y_offset)
				end
				if data.dynamic then data:update(obj_args)
				elseif data.interactive and data:update(obj_args) then foundWhen = foundWhen or check_when_statements(data.name) end -- the update function for interactive objects should return a boolean for true if triggered, false it not
			end
			if foundWhen then os.cancelTimer(timer) break end -- time taken to run when statement may cause timer desync
			
			-- handels scrolling of page
			if event == "mouse_scroll" and not pages[currentPage].scroll_lock then
				if event_id == -1 and pages[currentPage].y_offset+screen_height < pages[currentPage].end_of_page-1 then -- scroll up
					pages[currentPage].y_offset = pages[currentPage].y_offset + 1
					redraw()
				elseif event_id == 1 and pages[currentPage].y_offset >= 1 then -- scroll down
					pages[currentPage].y_offset = pages[currentPage].y_offset - 1
					redraw() -- we call redraw twice because it messes with dynamic objects when scrolling at top or bottom of page
				end
				obj_args["y_offset"] = y_offset
			end
			
			if event == "timer" then break end
		end
		tick = tick + 1
	end
end


function redraw(args)
	term.setCursorPos(1,1)
	local args = args or {pageName=currentPage}
	local pageName = args.pageName
	local x_offset = args.x_offset or pages[pageName].x_offset
	local y_offset = args.y_offset or pages[pageName].y_offset
	fill_screen(args)
	for index, data in pairs(pages[pageName].objects) do
		if not data.unplaceable then data:draw(x_offset, y_offset) end
	end
end

function fill_screen(args)
	local x_inital = args.x_inital or 0
	local x_final = args.x_final or screen_width
	local y_inital = args.y_inital or 0
	local y_final = args.y_final or screen_height
	
	term.setBackgroundColor(pages[args.pageName].background)
	for i = y_inital, y_final do
		term.setCursorPos(x_inital, i)
		io.write(string.rep(" ", x_final - x_inital+1))
	end
end

function check_when_statements(name)
	local matched = false
	for k, v in next, pages[currentPage].when do
		if debugMode then print(k, " ", v) end
		if k == name then
			matched = true
			interpret_line(string.gsub(v, "\\", ""), currentPage, name)
			redraw()
		end
	end
	return matched
end

-- HELPER FUNCTIONS
function printarr(arr, substr)
   for i in pairs(arr) do
      print("arr[" .. i .. "] = ", arr[i])
	  if substr then printarr(arr[i]) end
   end
end

function get_object(args)
	if(args.page == nil) then args.page = currentPage end
	return pages[args.page].objects[args.name]
end

function set_object(args)
	if(args.page == nil) then args.page = currentPage end
	pages[args.page].objects[args.obj.name] = args.obj
end

-- requires: name, property, value... page is optional
function edit_object(args)
	if(args.page == nil) then args.page = currentPage end
	pages[args.page].objects[args.name][args.property] = args.value
	pages[args.page].objects[args.name].awaitingRedraw = true
end

function set_current_page(newPage)
	currentPage = newPage
end

function get_current_page()
	return pages[currentPage]
end

function get_page(name)
	return pages[name]
end

function set_background(name)
	term.setBackgroundColor(pages[name].background)
end

function set_color(name)
	term.setTextColor(pages[name].color)
end

function scrollLock(bool)
	pages[currentPage].scrollLock = bool
end

function message(message)
	local orgx, orgy = term.getCursorPos()
	term.setCursorPos(1, screen_height)
	term.clearLine()
	io.write(message)
	term.setCursorPos(orgx, orgy)
end

return{
	run=run,
	getObject=get_object,
	setObject=set_object,
	setCurrentPage=set_current_page,
	getPage=get_page,
	setBackground=set_background,
	setColor=set_color,
	scrollLock=scrollLock,
	redraw=redraw,
	getCurrentPage=get_current_page,
	editObject=edit_object,
	message=message
}