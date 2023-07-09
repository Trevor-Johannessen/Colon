--[[
    File loader:
    File loader reads a file and returns an iterator over its contents
]]
function openFile(file)
    if not file then error("Could not open file. file is nil") end
    if not fs.exists(file) then error("Could not open file. File: '" .. file .. "' not found") end
    return io.lines(file)
end

return {
    openFile=openFile
}