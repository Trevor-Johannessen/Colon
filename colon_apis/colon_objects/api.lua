function create(args)
	args.name = args.name or args.path
	if not args.path then return -1 end
	if args.unload == true then
		if string.sub(args.path, -4) == ".lua" then args.path = string.sub(args.path, 1, -5) end
		os.unloadAPI(args.path)
	else
		_G[args.name] = require(args.path)
		--os.loadAPI(args.path)
	end
	return -1
end

return{
	create=create
}