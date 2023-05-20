function create(args)
	loadstring(args.command)()
	return -1
end

return{
	create=create
}