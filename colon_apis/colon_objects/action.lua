template = require("colon_apis/colon_objects/template")
function create(args)
	action = template.create()
	action.name = args.name
	action.event = args.event
	action.unplaceable = true
	action.interactive = true

	function action:update(obj_args)
		if obj_args["event"] == action.event then return {"when"} end
		return
	end
	
	return action
end

return {
	create=create
}