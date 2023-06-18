screen_width, screen_height = term.getSize() -- dimensions of screen
object_types = object_types or {}
debugMode = false
pages = pages or {}
currentPage = currentPage or ""

-- open file and lex lines into tables
function run(inArgs)
	args = inArgs
	createConsole()
	initalize(args) -- initalize to load apis
	process_file(args[1])
	interaction_loop()
end

function initalize(args)
	if not fs.exists("/colon/colon_apis/") then error("apis folder does not exist, try reinstalling") end
	if not fs.exists("/colon/colon_apis/colon_objects/") then error("objects folder does not exist, try reinstalling") end
	
	apis = fs.list("/colon/colon_apis/colon_objects/")
	
	for i=1, table.getn(apis) do
		add_log("apis[".. i .. "] = " .. apis[i])
		if not fs.isDir(apis[i]) then
			local noExtension = string.sub(apis[i], 1, -5)
			object_types[noExtension] = require("colon_apis/colon_objects/" .. noExtension)
		end
	end	
end

function createConsole()
	console = require("colon_apis/ext/console")
	console = console.create()
end

function process_file(fileName)
	if fs.getDir(fileName) ~= "" then
		fileName = fs.getDir(fileName) .. "/" .. fileName:match("[^/]*$")
	else
		fileName = fileName:match("[^/]*$")
	end
	if fileName:sub(1,1) ~= "/" then fileName = "/" .. fileName end
	if currentPage == "" then currentPage = fileName end
	initalize_page(fileName)	
	-- open file and get line iterator
	local text = get_file_iterator(fileName)
	pages[fileName]["path"] = "/" .. fs.getDir(fileName) .. "/"
	-- parse lines to create objects and insert them into the objects list
	for str in text do
		interpret_line(str, fileName)
	end
	redraw()
end

function get_file_iterator(fileName)
	if not fs.exists(fileName) then error("file '" .. fileName .. "' not found") end
	return io.lines(fileName)
end

function interpret_line(str, givenPage, whenArgs)
	-- format string to allow for escape character
	str = str:gsub("\\(%d+)", function (m) return string.char(m) end) -- match escape sequences into ascii characters \30 -> V but cool character
	local new_obj = parse(str, givenPage, whenArgs)
	if new_obj ~= -1 then
		if 	not new_obj.draw and 
			new_obj.y+new_obj.height > pages[givenPage].end_of_page then 
				pages[givenPage].end_of_page = new_obj.y+new_obj.height -- adjust total page height
		end
		table.insert(pages[givenPage].objects, new_obj)
		
		-- add to groups table
		for k, group in next, new_obj.groups do
			add_log("Adding " .. group .. " to group")
			add_to_group(new_obj, group, givenPage)
		end
	end
end

function add_to_group(obj, group, givenPage)
	if not givenPage then givenPage = currentPage end
	pages[givenPage].groups[group] = pages[givenPage].groups[group] or {}
	table.insert(pages[givenPage].groups[group], obj)
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
	pages[pageName].groups = {}
	pages[pageName].name = pageName
end

function getObjType(object_type, page)
	local tag
	for tag in next, pages[page].tags do
		if string.sub(object_type, 1, 1) == tag then
			if object_types[string.sub(object_type, 2)] then
				object_type = string.sub(object_type, 2)
				found_tag = tag
				break
			end
		end
	end
	return object_type, tag
end

function parse(text, givenPage, whenArgs)
	local found_tag
	-- find what object type line is
	local colon_pos = string.find(text, ":") -- position of colon used to mark a command
	if not colon_pos then return -1 end -- if a colon is missing then ignore
	
	-- find object_type
	local object_type = string.sub(text, 1, colon_pos-1)
	object_type, tag = getObjType(object_type, givenPage)

	-- create arguments in table
	local args = {}
	text = string.sub(text, colon_pos+1)
	text = trim_input(text)
	text = string.gmatch(text, "([^,]*),*")

	-- turn arguments into parameters for the objects
	for param in text do
		local equals_pos = string.find(param, "=")
		if equals_pos == nil then error("Could not find equals sign in parameter of " .. object_type) end
		local key = string.sub(param, 0, equals_pos-1)
		local value = string.gsub(string.sub(param, equals_pos+1), string.char(9), ",") -- args[var_name] = var_value
		if(value:sub(1, 1) == "\"" and value:sub(-1) == "\"") then 
			value = value:sub(2,-2) 
		end
		args[key] = value
		args.groups = {}
		if key == "groups" then
			for group in value:gmatch("[^ ]+") do
				table.insert(args.groups, group)
			end
		else
			if args[key]:sub(1,2) == "./" then args[key] = pages[givenPage]["path"] .. args[key]:sub(3) end
			if args[key]:sub(1,1) == "/" then args[key] = args[key]:sub(1) end -- file paths should NOT start with a slash!
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
		args["when"] = whenArgs -- delivers whenArgs to objects created from when triggers
		args.page = givenPage
		if object_types[object_type] == nil then error("Object type " .. object_type .. " not found.") end
		local obj = object_types[object_type].create(args)
		if (type(obj) == "table") then -- mandatory attributes for objects.
			obj.groups = obj.groups or args.groups
		end
		return obj
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

function construct_when(args, givenPage)
	pages[givenPage].when[args.name] = pages[givenPage].when[args.name] or {}
	table.insert(pages[givenPage].when[args.name], args.command)
end

function redrawIfAwaiting(obj, args)
	if obj.awaitingRedraw then 
		obj.awaitingRedraw = false
		obj:draw(args.x_offset, args.y_offset)
	end
end

function formObjArgs(args, tick)
	args["tick"] = tick
	args["x_offset"] = pages[currentPage].x_offset
	args["y_offset"] = pages[currentPage].y_offset
	args["screen_height"] = screen_height
	args["screen_width"] = screen_width
	args["color"] = pages[currentPage].color
	args["background"] = pages[currentPage].background
end

function addEventArgs(args, event)
	args["event"] = event[1]
	args["event_id"] = event[2]
	args["mouse_x"] = event[3]
	args["mouse_y"] = event[4]
end

function handleScrollEvent(event, block_scroll)
	if not pages[currentPage].scroll_lock and not block_scroll then
		if event[2] == -1 and pages[currentPage].y_offset+screen_height < pages[currentPage].end_of_page-1 then -- scroll up
			pages[currentPage].y_offset = pages[currentPage].y_offset + 1
			redraw()
		elseif event[2] == 1 and pages[currentPage].y_offset >= 1 then -- scroll down
			pages[currentPage].y_offset = pages[currentPage].y_offset - 1
			redraw() -- we call redraw twice because it messes with dynamic objects when scrolling at top or bottom of page
		end
	end
end

--[[
	Checks the returned conditions by an objects update function
	@param conditions: An array of strings that describe what functions should be executed after updating.
	@param data: Information on the object that has just returned from update
	@prev_conditions: A table of previous conditions used for conditions that only need to be set once in an update cycle.
]]
function checkReturnConditions(conditions, data, prev_conditions)
	if not conditions then return end
	for k, v in next, conditions do
		if type(v) == "string" then
			if v == "when" then -- activate when statements
				prev_conditions.found_when = prev_conditions.found_when or check_when_statements(data.name, conditions.whenArgs) 
			elseif v == "scroll" then -- take scroll control away from colon enviornemnt
				prev_conditions.block_scroll = true
			elseif v == "nobubble" then -- do not propagate input to any more elements
				prev_conditions.nobubble = true
			elseif v == "redraw" then
				table.insert(prev_conditions.redraw_list, 1, k)
			end
		end
	end
end

 -- INTERPRETING FUNCTIONS
function interaction_loop()
	local tick = 1
	while true do
		-- update interactive elements
		local timer = os.startTimer(0.05)
		local obj_args = {}
		formObjArgs(obj_args, tick)
		while true do
			event = {os.pullEvent()}
			addEventArgs(obj_args, event)
			-- give input to all objects that request it
			local return_conditions = {redraw_list={}}
			-- systems functions
			checkReturnConditions(console:update(obj_args), console, return_conditions)
			-- object functions
			for index, data in pairs(pages[currentPage].objects) do
				redrawIfAwaiting(data, obj_args)
				if type(data.update)=="function" then
					local val = data:update(obj_args) or {}
					checkReturnConditions(val, data, return_conditions)
					if return_conditions.nobubble then break end
				end 
			end
			bubble_redraw(return_conditions.redraw_list)
			if return_conditions.found_when then os.cancelTimer(timer) break end -- time taken to run when statement may cause timer desync
			
			if event[1] == "mouse_scroll" then handleScrollEvent(event,return_conditions.block_scroll) end
			if event[1] == "timer" then break end
		end
		tick = tick + 1
	end
end

function redraw(args)
	local args = args or {}
	args.pageName = args.pageName or currentPage
	local pageName = args.pageName
	local x_offset = args.x_offset or pages[pageName].x_offset
	if not args.y_offset and not pages[pageName] then error("Both args y_offset and page y_offset are nil. (" .. pageName .. ")" ) end
	local y_offset = args.y_offset or pages[pageName].y_offset
	fill_screen(args)
	for index, data in pairs(pages[pageName].objects) do
		if not data.unplaceable then data:draw(x_offset, y_offset) end
	end
end

-- redraw all updated objects that wish to be redrawn, as well as all objects that cover the redrawn object
function bubble_redraw(redrawList) -- redrawList should already be sorted
	if #redrawList == 0 then return end
	objList = pages[currentPage].objects
	local index = redrawList[1]
	local redrawIndex = 2
	for k, v in next, objList do
		if redrawList[redrawIndex] and redrawList[redrawIndex] == k then 
			index = k
			redrawIndex = redrawIndex + 1
		end
		if  k > index and
			objList[k].width and
			objList[k].height and
			not (objList[index].x > objList[k].x-objList[k].width  	and -- Al > Br
				objList[index].x+objList[index].width < objList[k].x  	and -- Ar < Bl
				objList[index].y > objList[k].y+objList[k].height 	and -- At > Bb
				objList[index].y+objList[index].height < objList[k].y) 	then
			objList[k]:draw(pages[currentPage].x_offset, pages[currentPage].y_offset)
		end
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

function check_when_statements(name, args)
	local matched = false
	for k, v in next, pages[currentPage].when do
		if k == name then
			for k2,v2 in next, pages[currentPage].when[k] do
				matched = true
				if args == nil then args = {} end
				args.name = name
				interpret_line(string.gsub(v2, "\\", ""), currentPage, args)
			end
			redraw()
		end
	end
	return matched
end

-- HELPER FUNCTIONS
function printarr(arr, substr)
	local x,y = term.getCursorPos()
	if type(arr) == "nil" then print("arr[] = nil") return end
	for i in next, arr do
		term.setCursorPos(x,y)
		if type(arr[i]) == "number" or type(arr[i]) == "string" then
			io.write("arr[" .. i .. "] = ", arr[i])
		else
			io.write("arr[" .. i .. "] = type(", type(arr[i]) .. ")")
		end
		y=y+1
		if substr then printarr(arr[i]) end
	end
end

function subarray(arr, start, stop)
	local arr = {}
	for k in next, arr do
		if type(k) == "number" and k >= start and k <= stop then
			table.insert(arr, k)
		end
	end
	return arr
end

function get_object_by_name(page, name)
	for key, obj in next, pages[page].objects do
		if obj.name == name then
			return obj
		end
	end
end

function set_object_by_name(page, name, newObject)
	for key, obj in next, pages[page].objects do
		if obj.name == name then
			pages[page].objects[key] = newObject
		end
	end
end

-- ACCESS FUNCTIONS
function get_object(args)
	if(args.page == nil) then args.page = currentPage end
	return get_object_by_name(args.page, args.name)
end

function set_object(args)
	if(args.page == nil) then args.page = currentPage end
	set_object_by_name(args.page, args.name, args.obj)
end

-- requires: name, property, value... page is optional
function edit_object(args)
	if(args.page == nil) then args.page = currentPage end
	local obj = get_object_by_name(args.page, args.name)
	obj[args.property] = args.value
	obj.awaitingRedraw = true
end

function set_current_page(newPage)
	currentPage = newPage
	if pages[currentPage] == nil then error("Error setting page: " .. tostring(currentPage) .. " does not exist.") end
	for i, obj in next, pages[currentPage].objects do
		if obj.staged then
			obj:staged()
		end
	end
end

function get_current_page()
	print("Current page = " .. currentPage)
	return pages[currentPage]
end

function create_page(name, obj_list)
	initalize_page(name)
	pages[name].objects = obj_list
	return pages[name]
end

function destroy_page(name)
	pages[name] = nil
end

function get_page(name)
	return pages[name]
end

function get_group(name, page)
	if not page then page = currentPage end
	return pages[page].groups[name]
end

function map_group(name, func, page)
	if not page then page = currentPage end
	for k, obj in next, pages[page].groups[name] do
		func(obj)
	end
end

function add_log(msg)
	if type(msg) == "string" then console:add{msg=msg,x_offset=currentPage.x_offset,y_offset=currentPage.y_offset} end
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
	object_types=object_types,
	run=run,
	getObject=get_object,
	setObject=set_object,
	setCurrentPage=set_current_page,
	createPage=create_page,
	destroyPage=destroy_page,
	getPage=get_page,
	setBackground=set_background,
	setColor=set_color,
	scrollLock=scrollLock,
	redraw=redraw,
	getCurrentPage=get_current_page,
	editObject=edit_object,
	message=message,
	log=add_log,
	getLogs=get_logs,
	getGroup=get_group,
	mapGroup=map_group,
	bubbleRedraw=bubble_redraw,
	printarr=printarr
}