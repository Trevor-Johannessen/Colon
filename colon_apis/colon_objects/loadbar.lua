template = require("colon_apis/colon_objects/template")

function create(args)
    
    local loadbar = template.create()
    
    loadbar.x = tonumber(args.x) or 0 -- x coordinate of loadbar
    loadbar.y = tonumber(args.y) or 0 -- y coordinate of loadbar
    loadbar.length = tonumber(args.length) or 10 -- length of loadbar (bar is x characters long)
    loadbar.progress = 0 -- progress of loadbar
    loadbar.text = args.text or "default text" -- default text of loadbar
    loadbar.symbol = args.symbol or string.char(4) -- load symbol 
    loadbar.symbol_color = loadbar:convertColor(args.symbol_color, 'hex') or "0"
    loadbar.background = loadbar:convertColor(args.background, 'hex') or "f"
    loadbar.dynamic = false
	loadbar.interactive = false
	loadbar.name = args.name
	loadbar.type = "loadbar"
	loadbar.sticky = args.sticky or false
	
	if text == "" then loadbar.height = 1 else loadbar.height = 2 end
    
    function loadbar:draw(x_offset, y_offset)
        x_offset = x_offset or 0 -- default parameter values
        y_offset = y_offset or 0
    
		if loadbar.sticky then 
				y_offset = 0 
				x_offset = 0
		end
	
        hold_cursor = {term.getCursorPos()}        -- save cursor position
        
        term.setCursorPos(loadbar.x+x_offset, loadbar.y-y_offset)
        
        term.blit(string.rep(loadbar.symbol, loadbar.progress), string.rep(loadbar.symbol_color, loadbar.progress), string.rep(loadbar.background, loadbar.progress)) -- prints progressed part of loadbar
        -- may need to adjust cursor position here
        term.blit(string.rep(" ", loadbar.length-loadbar.progress), string.rep(" ", loadbar.length-loadbar.progress), string.rep(loadbar.background, loadbar.length-loadbar.progress)) -- prints un-progressed part of loadbar
        
        
        term.setCursorPos(hold_cursor[1], hold_cursor[2]) -- return cursor to original position        
    end
	
	
    function loadbar:increment(in_amount)
        amount = in_amount or 1 -- default increment value is 1
        
        loadbar.progress = loadbar.progress + amount -- add amount to current progress
        
        if loadbar.progress > loadbar.length then -- don't let bar go past max length
            loadbar.progress = loadbar.length
        elseif loadbar.progress < 0 then -- don't let bar go past 0
            loadbar.progress = 0
        end
    end
    
    
    function loadbar:setPrecentage(in_precentage)
        precentage = in_precentage or 0
        
        -- precentage cannot be above 100% or below 0%
        if precentage > 1 then precentage = 0
        elseif precentage < 0 then precentage = 0 end
                
        loadbar.progress = math.ceil(precentage*loadbar.length)
        
    end
	
	
	function loadbar:reset()
		loadbar.progress = 0
	end
	
	-- correction to clean inputs
	function loadbar:corrections()
		-- quick color format correction
		if type(loadbar.symbol_color) == "string" then
			loadbar.symbol_color = colors[loadbar.symbol_color]
		end 
		if type(loadbar.background) == "string" then
			loadbar.background = colors[loadbar.background]
		end 
		
		if loadbar.sticky == "true" or not type(loadbar.sticky) == "boolean" then
			loadbar.sticky = true
		else
			loadbar.sticky = false
		end
		
	end
    return loadbar 
end

return{
	create=create
}