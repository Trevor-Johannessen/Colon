template = require("colon_apis/colon_objects/template")

function create(args)
	local text = template.create(args)
	
	function text:draw(x_offset, y_offset)	
	end
	
	function text:update(args)
	end
	
	return text
end

return{
	create=create
	}