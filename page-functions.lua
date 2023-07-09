function initalizePage(page_book, name)
	if not page_book then error("Page cannot be initalized. Missing variable: page_book") end
	if not name then error("Page cannot be initalized. Missing variable: name.") end
	if type(page_book) ~= "table" then error("Page cannot be initalized. page_book must be of type table.") end
    new_page = {}
	new_page.when = {}
	new_page.objects = {} -- storage for all objects
	new_page.tags = {}
	new_page.x_offset = 0
	new_page.y_offset = 0
	new_page.end_of_page = 0
	new_page.background = colors.black
	new_page.color = colors.white
	new_page.scroll_lock = false
	new_page.groups = {}
	new_page.name = name
	new_page.path = "/" .. fs.getDir(name) .. "/"
    table.insert(page_book, new_page)
    return new_page
end

return {
	initalizePage=initalizePage
}