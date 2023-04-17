template = require("colon_apis/colon_objects/template")

function create(args)
	local call = template.create()
	call.name = args.name
	call.func = args.func
	call.dynamic = false
	call.interactive = false
	call.unplaceable = true
	call.type = "call"
	if(not _G[call.name]) then error("Call Error: Name: '" .. call.name .. "' not found.") end
	if(not _G[call.name][call.func]) then error("Call Error: Func: '" .. call.func .. "' not found.") end
	_G[call.name][call.func](args)
	return -1
end

return{
	create=create
}