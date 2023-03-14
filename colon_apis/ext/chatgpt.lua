-- phrase object for conversation, phrases are made up of a role and content
function gpt()
	local gpt = {}
	gpt.key = ""
	
	function gpt.setKey(key)
		gpt.key = key
	end
	
	function gpt.conversation(priorConversation)
		local convo = {}
		convo.logs = priorConversation or {}
		-- purges user promps from the history to save on tokens
		function convo.shorten()
		
		end
		
		-- adds a new verse to the conversation
		function convo.add(verse)
			table.insert(convo.logs, 1, verse)
		end
		
		function convo.query()
			local headers = {}
				headers["Authorization"]= "Bearer " .. gpt.key
				headers["Content-Type"]="application/json"
			local body = {}
				body["model"]="gpt-3.5-turbo"
				body["max_tokens"]=150
				body["messages"]=convo.logs
			body = textutils.serializeJSON(body)
			local response, msg, code = http.post{url="http://localhost:5000/cc/chatgpt", headers=headers, body=body}
			return response
		end
		
		-- submit reply to chatgpt and query for a response.
		function convo.say(verse)
			if(verse==nil) then return end
			if(type(verse) == "string") then verse={role="user", content=verse} end
			convo.add(verse)
			local response = textutils.unserializeJSON(convo.query():readAll())["choices"]
			convo.add(response[#response]["message"])
			return response[#response]["message"]["content"]
		end
		return convo
	end
	return gpt
end
return {
	gpt=gpt
}