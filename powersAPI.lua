hyperlinks = {}

last_update = "Last Updated: 11/17/21"

function parse_color(str)
		
		local baseTextColor = term.getTextColor()
		local baseBackgroundColor = term.getBackgroundColor()
		
		local monitor_settings
		
		local text = str

		local isHypertext = false
		local current_hypertext = {}
	
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
					term.setTextColor(color_convert(color))
					
				elseif (string.sub(tostring(stringTable[i]), 2, 11) == "background")
				then
					--print("backgroundCommand")
					--print("colorCommand")
										
					local background = string.sub(tostring(stringTable[i]), 13, string.len(stringTable[i])-2)

					table.insert(commandStack, 1, "BACKGROUND")
					table.insert(backgroundStack, 1, term.getBackgroundColor())
					--print("color = ", color)
					term.setBackgroundColor(color_convert(background))
					
				elseif (string.sub(tostring(stringTable[i]), 2, 10) == "hypertext")
					local x, y = term.getCursorPos()
					isHypertext = true
					
					local link = string.sub(tostring(stringTable[i]), 12, string.len(stringTable[i])-2)
					table.insert(curent_hypertext, 1, link)
					
					table.concat(current_hypertext, x)
					table.concat(current_hypertext, y)
					
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
				elseif command == "HYPERTEXT"
				then
					local x, y = term.getCursorPos()
					table.concat(current_hypertext, x)
					table.concat(current_hypertext, y)
				
				
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


function check_cursor(x, y)
	for link in pairs (hyperlinks) do
		local command = link.remove(1)
		
		if (link[2] == link[4] and y == link[2] and x >= link[1] and x <= link[3]) -- checks for 1 line hyperlinks
		or (y > link[2] and  y < link[3]) -- checks for inbetween lines for paragraph hyperlinks
		or (y == link[2] and x >= link[1]) -- checks first line for paragraph hyperlinks
		or (y == link[4] and x <= link[3]) -- checks last line for paragraph hyperlinks
			return command
		end
		--[[
		elseif (y > link[2] and  y < link[3]) -- checks for inbetween lines for paragraph hyperlinks
		
		elseif (y == link[2] and x >= link[1]) -- checks first line for paragraph hyperlinks
		
		elseif (y == link[4] and x <= link[3]) -- checks last line for paragraph hyperlinks
		]]--
	end
	
	return false
end
