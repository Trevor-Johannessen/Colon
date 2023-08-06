fileLoader = require("file-loader")
pageFunctions = require("page-functions")
parser = require("parser")
interpreter = require("interpreter")
init = require("initalization")
when = require("when")
eventLoop = require("event-loop")
redraw = require("redraw")

meta = {
    object_types = {},
    pages = {},
    console = {},
    scroll = {},
    api = {

    },
}
meta.screen_width, meta.screen_height = term.getSize()

--[[
    Rewrite order:

    Read file
    Parse Lines
    Create objects
    Enter Event Loop
]]
function run(file)
    init.initalize(meta)
    fileLoader.handleFile(file)
    eventLoop.start()
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

function getObjectByName(page, name)
	for key, obj in next, meta.pages[page].objects do
		if obj.name == name then
			return obj
		end
	end
end

function setObjectByName(page, name, newObject)
	for key, obj in next, meta.pages[page].objects do
		if obj.name == name then
			pages[page].objects[key] = newObject
		end
	end
end

-- ACCESS FUNCTIONS
function getObject(args)
	if not args.page then args.page = meta.current_page
    else args.page = meta.pages[args.page] end
	return get_object_by_name(args.page, args.name)
end

function setObject(args)
	if not args.page then args.page = meta.current_page
    else args.page = meta.pages[args.page] end
	set_object_by_name(args.page, args.name, args.obj)
end

-- requires: name, property, value... page is optional
function editObject(args)
	if not args.page then args.page = meta.current_page
    else args.page = meta.pages[args.page] end
	local obj = get_object_by_name(args.page, args.name)
	obj[args.property] = args.value
	obj.awaitingRedraw = true
end

function setCurrentPage(newPage)
	meta.current_page = meta.pages[newPage]
	for i, obj in next, meta.current_page.objects do -- should this go in interpreter?
		if obj.staged then
			obj:staged()
		end
	end
end

function getCurrentPage()
	return meta.current_page
end

function getPage(name)
	return meta.pages[name]
end

function getGroup(name, page)
	if not page then page = meta.currentPage
    else page = meta.pages[page] end
	return page.groups[name]
end

function mapGroup(name, func, page)
	if not page then page = meta.currentPage
    else page = meta.pages[page] end
	for k, obj in next, page.groups[name] do
		func(obj)
	end
end

function addLog(msg)
	if type(msg) == "string" then meta.console:add{msg=msg,x_offset=currentPage.x_offset,y_offset=currentPage.y_offset} end
end

function getBackground(page)
    if not page then page = meta.current_page
    else page = meta.pages[page] end
    return page.background
end

function setBackground(color, page)
    if not page then
        page = meta.current_page
    else
        page = meta.pages[page]
    end
    page.background = color
    if page == meta.current_page then
	    term.setBackgroundColor(page.background)
    end
end

function getColor(page)
    if not page then page = meta.current_page
    else page = meta.pages[page] end
    return page.color
end

function setColor(name)
    if page == nil then
        page = meta.current_page
    else
        page = meta.pages[page]
    end
    page.color = color
    if page == meta.current_page then
    	term.setBackgroundColor(page.color)
    end
end

function scrollLock(bool)
    meta.current_page.scrollLock = bool
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
	getObject=getObject,
	setObject=setObject,
	setCurrentPage=setCurrentPage,
	getPage=getPage,
	setBackground=setBackground,
	setColor=setColor,
    getBackground=getBackground,
    getColor=getColor,
	scrollLock=scrollLock,
	redraw=redraw,
	getCurrentPage=getCurrentPage,
	editObject=editObject,
	message=message,
	log=addLog,
	getLogs=getLogs,
	getGroup=getGroup,
	mapGroup=mapGroup,
	bubbleRedraw=bubbleRedraw,
    redraw=redraw.redraw,
}