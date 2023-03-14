template = require("colon_apis/colon_objects/template")

function create(args)
	local call = template.create()
	call.name = args.name
	call.func = args.func
	call.dynamic = false
	call.interactive = false
	call.unplaceable = true
	call.type = "call"

	_G[call.name][call.func](obj_args)
	return -1
end

return{
	create=create
}