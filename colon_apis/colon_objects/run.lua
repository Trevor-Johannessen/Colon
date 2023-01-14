function create(args)
	print("args = ", args.command)
	os.sleep(2)
	loadstring(args.command)()
	return -1
end

return{
	create=create
}