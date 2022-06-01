function parse_color(str)
		
		local baseTextColor = term.getTextColor()
		local baseBackgroundColor = term.getBackgroundColor()
		
		local monitor_settings
		
		local text = str

		local i = 1 -- while iterator
		local stringTable = mysplit(text) -- string.split of words
		local commandStack = {} -- stack that holds }
		local colorStack = {baseTextColor} -- keeps track of what color we should be
		local backgroundStack = {baseBackgroundColor} -- keeps track of what background we should be
		
		while stringTable[i] ~= nil
		do
			
			
			if(string.sub(tostring(stringTable[i]), 1, 1) == '$')
			then
				-- command found
				--print("substring = " .. string.sub(tostring(stringTable[i]), 2, 5))
				if (string.sub(tostring(stringTable[i]), 2, 6) == "color")
				then
					--print("colorCommand")
										
					local color = string.sub(tostring(stringTable[i]), 8, string.len(stringTable[i])-2)
					--print("stringTable[i] = ", stringTable[i])
					table.insert(commandStack, 1, "COLOR")
					table.insert(colorStack, 1, term.getTextColor())
					--print("color = ", color)
					term.setTextColor(str_to_int(color))
					
				elseif (string.sub(tostring(stringTable[i]), 2, 11) == "background")
				then
					--print("backgroundCommand")
					--print("colorCommand")
										
					local background = string.sub(tostring(stringTable[i]), 13, string.len(stringTable[i])-2)

					table.insert(commandStack, 1, "BACKGROUND")
					table.insert(backgroundStack, 1, term.getBackgroundColor())
					--print("color = ", color)
					term.setBackgroundColor(str_to_int(background))
					
				else
					print("Invalid_Command")
				end
			elseif (string.sub(tostring(stringTable[i]), 1, 1) == '}')
			then
				local command = table.remove(commandStack, 1)
				if command == "COLOR"
				then
					term.setTextColor(table.remove(colorStack, 1))	
					--print("color = ", term.getTextColor())
					if(colorStack[1] == nil)
					then
						table.insert(colorStack, 1)
					end
				elseif command == "BACKGROUND"
				then
					term.setBackgroundColor(table.remove(backgroundStack, 1))	
					--print("color = ", term.getTextColor())
					if(backgroundStack[1] == nil)
					then
						table.insert(backgroundStack, 32768)
					end
					
				end
			else
					io.write(tostring(stringTable[i]) .. " ")
			end
			
			i = i + 1
			
		end
		
	term.setTextColor(baseTextColor)
	term.setBackgroundColor(baseBackgroundColor)
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
end


function message(message)
	local orgx, orgy = term.getCursorPos()
	term.setCursorPos(1, 19)
	term.clearLine()
	io.write(message)
	term.setCursorPos(orgx, orgy)
end















