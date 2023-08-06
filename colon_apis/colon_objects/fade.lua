screen_width, screen_height = term.getSize() -- dimensions of screen
colon = require("colon")

function create(args)
	local to = args.to
	local from = args.from
	local speed = args.speed or 0.05
	local points_per_tick = tonumber(args.points) or 1
	term.setBackgroundColor(colon.getBackground(to))
	
	mask = {}
	for i=1, screen_height*screen_width, 1 do
		mask[i] = i
	end
	local function fisher_yates(t)
		for i = #t, 2, -1 do
			local j = math.random(i)
			t[i], t[j] = t[j], t[i]
		end
	end
	fisher_yates(mask)

	
	colon.setBackground(to)
	for i=1, screen_height * screen_width, points_per_tick do
		if screen_height * screen_width < i+points_per_tick then points_per_tick = screen_height * screen_width - i end
		for j=1, points_per_tick do
			local div = math.ceil(mask[i+j-1] / screen_width)
			term.setCursorPos(mask[i+j-1]%screen_width+1, div)
			io.write(" ")
			term.setCursorPos(1,1)
		end
		os.sleep(speed)
	end
	colon.setCurrentPage(to)
	return -1
end

return{
	create=create
}