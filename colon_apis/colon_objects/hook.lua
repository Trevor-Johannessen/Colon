template = require("colon_apis/colon_objects/template")

function create(args)
	local hook = template.create()
	hook.name = args.name
	hook.func = args.func
	hook.dynamic = true
	hook.interactive = false
	hook.unplaceable = true
	hook.type = "hook"

	function hook:update(obj_args)
		_G[hook.name][hook.func](obj_args)
	end
	
	return hook
end

return{
	create=create
}