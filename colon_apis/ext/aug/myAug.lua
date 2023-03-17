function create(self, arg)
    local obj = self or {}

	local oldDraw = obj["draw"]
    function self:draw(x_offset, y_offset)
        oldDraw(x_offset, y_offset)
		self:message("This was written by an augment")
    end
    return self
end

return{
	create=create
	}