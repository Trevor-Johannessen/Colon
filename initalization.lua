function initalize()
    initObjectTypes()
    initScroll()
    initConsole()
    initLogs()
end

function initObjectTypes()
    if not fs.exists("/colon/colon_apis/") then error("apis folder does not exist, try reinstalling") end
	if not fs.exists("/colon/colon_apis/colon_objects/") then error("objects folder does not exist, try reinstalling") end
	
	local apis = fs.list("/colon/colon_apis/colon_objects/")
	
	for k, v in next, apis do
		if not fs.isDir(v) then
	        local noExtension = string.sub(v, 1, -5)
            meta.object_types[noExtension] = require("colon_apis/colon_objects/" .. noExtension)
		end
	end
end

-- NOTE: this causes the text object to be initalized before any page has been loaded. 
-- This means the text:init function cannot log as that relies on a current page.
function initConsole()
    if not fs.exists("/colon/colon_apis/colon_objects/console.lua") then error("Console object does not exist, try reinstalling") end
    meta.console = meta.object_types.console.create()
end

function initScroll()

end

function initLogs()

end

return{
    initalize=initalize
}