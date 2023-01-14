
function create(args)
	if not args.api then return -1 end
	if args.unload == true then
		if string.sub(args.api, -4) == ".lua" then args.api = string.sub(args.api, 1, -5) end
		os.unloadAPI(args.api)
	else
		os.loadAPI(args.api)
	end
	return -1
end

return{
	create=create
}