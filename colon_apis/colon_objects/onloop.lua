template = require("colon_apis/colon_objects/template")

function create(args)
	local loop = template.create()
	loop.name = args.name
	loop.func = args.func
	loop.dynamic = true
	loop.interactive = false
	loop.unplaceable = true
	loop.type = "onloop"
	--loop.func = loadstring("return " .. loop.name)()

	function loop:update(obj_args)
		_G[loop.name][loop.func](obj_args)
	end
	
	return loop
end

return{
	create=create
}