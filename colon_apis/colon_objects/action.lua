
function create(args)
	action = {}
	action.name = args.name
	action.event = args.event
	action.unplaceable = true
	action.interactive = true

	function action:update(obj_args)
		if obj_args["event"] == action.event then return true end
		return false
	end
	
	return action
end


