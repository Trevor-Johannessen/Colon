screen_width, screen_height = term.getSize() -- dimensions of screen
colon = require("colon")

function create(args)
	colon.setCurrentPage(args.to)
	return -1
end

return{
	create=create
}