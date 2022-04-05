function create(args)
    
    local loadbar = {}
    
    loadbar.x = tonumber(args.x) or 0 -- x coordinate of loadbar
    loadbar.y = tonumber(args.y) or 0 -- y coordinate of loadbar
    loadbar.length = tonumber(args.length) or 10 -- length of loadbar (bar is x characters long)
    loadbar.progress = 0 -- progress of loadbar
    loadbar.text = args.text or "default text" -- default text of loadbar
    loadbar.symbol = args.symbol or string.char(4) -- load symbol 
    loadbar.symbol_color = args.symbol_color or "0"
    loadbar.background = args.background or "f" -- background color of loadbar
    loadbar.dynamic = false
	loadbar.interactive = false
	loadbar.name = args.name
	loadbar.type = "loadbar"
	
	if text == "" then loadbar.height = 1 else loadbar.height = 2 end
    
    function loadbar:draw(offset_x, offset_y)
        offset_x = offset_x or 0 -- default parameter values
        offset_y = offset_y or 0
    
        hold_cursor = {term.getCursorPos()}        -- save cursor position
        
        term.setCursorPos(loadbar.x+offset_x, loadbar.y-offset_y)
        
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
	
    
    return loadbar
    
end