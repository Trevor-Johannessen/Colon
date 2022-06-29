screen_width, screen_height = term.getSize()

--[[ 
	FORMAT:
	{c:color:text} -- color
	{b:color:text} -- background
	they can be nested.
]]
function parseColor(str)
	colorString = string.rep(sharedFunctions.int_to_hex(term.getTextColor()), str:len())
	backgroundString = string.rep(sharedFunctions.int_to_hex(term.getBackgroundColor()), str:len())
	while true do
		a,b = str:find("%b{}") -- get inside block
		if not a and not b then break end
		c = str:sub(a,b) -- get color
		d, e = c:find("%b::")
		if not d and not e then break end
		f = c:sub(e+1,-2) -- the middle of the string = the end of the color substring to the end of the c substring-1
		g = str:sub(a+1,a+1)
		-- I just want to point out that I was doing b-a-1 instead of -2 and I feel bad about that
		
		if g=="c" then
			colorString = colorString:sub(1, a-1) .. string.rep(sharedFunctions.str_to_hex(c:sub(d+1,e-1)), f:len()) .. colorString:sub(b+1) -- build the color string
			backgroundString = backgroundString:sub(1,a-1) .. backgroundString:sub(a+e+1,b-1) .. backgroundString:sub(b)
			
		elseif g=="b" then
			backgroundString = backgroundString:sub(1, a-1) .. string.rep(sharedFunctions.str_to_hex(c:sub(d+1,e-1)), f:len()) .. backgroundString:sub(b+1) -- build the background
			colorString = colorString:sub(1,a-1) .. colorString:sub(a+e+1,b-1) .. colorString:sub(b)
		else
			break
		end
		str = str:sub(1,a-1) .. f .. str:sub(b+1) -- build the string
	end
	--term.blit(str, colorString, backgroundString)
	return str, colorString, backgroundString
end	


function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end	


function str_to_int(str)
	str = string.lower(str)
	
	if tonumber(str) == nil  then
		
		if 	   str == "white" then return colors.white
		elseif str == "orange" then return colors.orange
		elseif str == "magenta" then return colors.magenta
		elseif str == "lightblue" then return colors.lightBlue
		elseif str == "yellow" then return colors.yellow
		elseif str == "lime" then return colors.lime
		elseif str == "pink" then return colors.pink
		elseif str == "gray" then return colors.gray
		elseif str == "lightgray" then return colors.lightGray
		elseif str == "cyan" then return colors.cyan
		elseif str == "purple" then return colors.purple
		elseif str == "blue" then return colors.blue
		elseif str == "brown" then return colors.brown
		elseif str == "green" then return colors.green
		elseif str == "red" then return colors.red
		elseif str == "black" then return colors.black
		end
	end
	
	
	return tonumber(str)
end


function int_to_hex(color)
	if	   color == colors.white 		then return "0"
	elseif color == colors.orange 		then return "1"
	elseif color == colors.magenta 		then return "2"
	elseif color == colors.lightBlue 	then return "3"
	elseif color == colors.yellow 		then return "4"
	elseif color == colors.lime 		then return "5"
	elseif color == colors.pink 		then return "6"
	elseif color == colors.gray 		then return "7"
	elseif color == colors.lightGray 	then return "8"
	elseif color == colors.cyan 		then return "9"
	elseif color == colors.purple 		then return "a"
	elseif color == colors.blue 		then return "b"
	elseif color == colors.brown 		then return "c"
	elseif color == colors.green 		then return "d"
	elseif color == colors.red 			then return "e"
	elseif color == colors.black 		then return "f"
	end
end

function str_to_hex(str)
	str = string.lower(str)
	
		if 	   str == "white"		then return "0"
		elseif str == "orange"      then return "1"
		elseif str == "magenta"     then return "2"
		elseif str == "lightblue"   then return "3"
		elseif str == "yellow"      then return "4"
		elseif str == "lime"        then return "5"
		elseif str == "pink"        then return "6"
		elseif str == "gray"        then return "7"
		elseif str == "lightgray"   then return "8"
		elseif str == "cyan"        then return "9"
		elseif str == "purple"      then return "a"
		elseif str == "blue"        then return "b"
		elseif str == "brown"       then return "c"
		elseif str == "green"       then return "d"
		elseif str == "red"         then return "e"
		elseif str == "black"       then return "f"
		end
end

function corrections(obj)
	if type(obj.color) == "string" then
		obj.color = colors[obj.color]
	end 
	if type(obj.background) == "string" then
		obj.background = colors[obj.background]
	end 
	
	if type(obj.sticky) ~= "boolean" then
		if obj.sticky == "true" then
			obj.sticky = true
		else
			obj.sticky = false
		end
	end
	
	
	-- check for center args x
	if obj.x == "center" then obj.x = screen_width/2 end
	local first, last, middle = string.find(obj.x, "center[+-]()%d*")
	if middle ~= nil then
		local number = string.sub(obj.x, middle-1)
		obj.x = math.ceil(screen_width/2) + tonumber(number)
	end
	
	-- check for center args y
	if obj.y == "center" then obj.y = screen_height/2 end
	local first, last, middle = string.find(obj.y, "center[+-]()%d*")
	if middle ~= nil then
		local number = string.sub(obj.y, middle-1)
		obj.y = math.ceil(screen_height/2) + tonumber(number)
	end	
	
	
end


function message(message)
	local orgx, orgy = term.getCursorPos()
	term.setCursorPos(1, 19)
	term.clearLine()
	io.write(message)
	term.setCursorPos(orgx, orgy)
end


function monus(a, b)
	return ((a-b)<0 and 0 or (a-b))
end











