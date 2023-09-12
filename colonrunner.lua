colon=require("colon")
args = {...}
if shell.dir() ~= "" then
    colon.run("/" .. shell.dir() .. "/" .. args[1])
else
    if args[1]:sub(1,1) == "/" then
        colon.run(args[1])
    else
        colon.run("/" .. args[1])
    end
end