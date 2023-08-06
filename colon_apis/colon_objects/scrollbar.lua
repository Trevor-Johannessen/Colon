template = require("colon_apis/colon_objects/template")

function create(args)
	local scrollbar = template.create(args)
    scrollbar=scrollbar:coords(args)
    scrollbar=scrollbar:dim(args)
    scrollbar=scrollbar:essentials(args)
	
	function scrollbar:draw(x_offset, y_offset)
	end
	
	function scrollbar:update(obj_args)
	end

	return scrollbar
end

return {
	create=create
}