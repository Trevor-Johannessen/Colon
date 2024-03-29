template = require("colon_apis/colon_objects/template")
screen_width, screen_height = term.getSize() -- dimensions of screen

function monus(a, b)
	return ((a-b)<0 and 0 or (a-b))
end

function create(args)
	
	local timer = template.create(args)
	args.zone = args.zone or "utc"
	args.text = os.time(args.zone)
	timer.text = text.create(args)
	if args.direction == "left" then timer.direction = -1 else timer.direction = 1 end
	timer.dynamic = true
	timer.interactive = false
	timer.height = text.height
	timer.width = text.width
	timer.name = args.name

	function timer:draw(x_offset, y_offset)
		if timer.hidden then return end
	end

	function timer:update(args)
		if timer.hidden then return end
	end

	return timer
end

return{
	create=create
}