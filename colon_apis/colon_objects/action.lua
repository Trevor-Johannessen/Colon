template = require("colon_apis/colon_objects/template")
--[[
	ACTION OBJECT
	This object hooks into the event listener via the update function.
	It triggers the when statement with its given name when a specified event occurs. 
]]
function create(args)
	action = template.create()
	action.name = args.name -- the name used in it's corresponding when statement
	action.event = args.event -- the action to be listening for
	action.unplaceable = true
	action.interactive = true

	function action:update(obj_args)
		--[[
			Checks on each event update to see if the given action has been triggered.
		]]
		if obj_args["event"] == action.event then return {"when"} end
		return
	end
	
	return action
end

return {
	create=create
}