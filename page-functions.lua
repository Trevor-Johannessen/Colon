local when = require("when")
local scroll = require("colon_apis/colon_objects/scrollbar")

function initalizePage(name)
	if not meta.pages then error("Page cannot be initalized. Missing variable: meta.pages") end
	if not name then error("Page cannot be initalized. Missing variable: name.") end
	if type(meta.pages) ~= "table" then error("Page cannot be initalized. meta.pages must be of type table.") end
	-- WARNING: THIS MAY BE FLAWED FOR FILES THAT CREATE A CIRCLE IN WHERE TWO POINTS ARE IN DIFFERENT DIRECTORIES
	for k, v in next, meta.pages do if v.name == fs.getName(name) then return end end -- do not include pages which have already been included. (No circular includes)
    
	local new_page = {}
	new_page.when = when.create(new_page)
	new_page.objects = {} -- storage for all objects
	new_page.tags = {}
	--new_page.x_scroll = scroll:create{}
	new_page.y_scroll = initScrollbar()
	new_page.end_of_page = 0
	new_page.background = colors.black
	new_page.color = colors.white
	new_page.scroll_lock = false
	new_page.groups = {}
	new_page.name = fs.getName(name)
	new_page.path = "/" .. fs.getDir(name) .. "/"

    --table.insert(meta.pages, new_page)
	meta.pages[name] = new_page
	if not meta.current_page then meta.current_page = new_page end

    return new_page
end

function initScrollbar()
    return scroll.create{
		anchor=0,
		knobPercent=.10,
		x=meta.screen_width-1,
		y=1,
		width=1,
		height=meta.screen_height,
		redraw=meta.redraw
	}
end

return {
	initalizePage=initalizePage
}