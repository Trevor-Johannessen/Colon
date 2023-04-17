template = require("colon_apis/colon_objects/template")

function create(args)
	local hook = template.create()
	hook.name = args.name
	hook.x=0
	hook.y=0
	hook.height=0
	hook.width=0
	hook.func = args.func
	hook.dynamic = true
	hook.interactive = false
	hook.unplaceable = not args.draw == "true"
	hook.type = "hook"
	
	function hook:draw(x_offset, y_offset)
		hook:update{x_offset, y_offset}
	end
	
	function hook:update(obj_args)
		_G[hook.name][hook.func](obj_args)
	end
	
	return hook
end

return{
	create=create
}