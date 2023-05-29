template = require("colon_apis/colon_objects/template")

function create(args)
	local hook = template.create()
	hook.name = args.name
	hook.x=0
	hook.y=0
	hook.height=0
	hook.width=0
	hook.func = _G[hook.name][args.func]
	hook.dynamic = true
	hook.interactive = false
	hook.unplaceable = not args.draw == "true"
	hook.staged = args.staged == "true" or false
	hook.type = "hook"
	
	if not hook.unplaceable or hook.staged then
		hook.updated = args.updated == "true"
	else
		hook.updated = args.updated ~= "false"
	end

	if not hook.unplaceable then
		function hook:draw(x_offset, y_offset)
			hook:func{x_offset, y_offset}
		end
	end
	
	if hook.updated then
		function hook:update(obj_args)
			hook:func(obj_args)
		end
	end

	function hook:staged()
		hook:func()
	end
	
	return hook
end

return{
	create=create
}