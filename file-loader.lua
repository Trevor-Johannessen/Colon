--[[
    File loader:
    File loader reads a file and returns an iterator over its contents
]]
function openFile(file)
    if not file then error("Could not open file. file is nil") end
    if not fs.exists(file) then error("Could not open file. File: '" .. file .. "' not found") end
    return io.lines(file)
end

function interpretFile(file, page)
    local iter = openFile(file)
    for line in iter do
        local object = parser.parse(line, page)
        if object then
            interpreter.interpret(object, page)
        end
    end
end

function handleFile(file, page)
    file = completePath(file, page)
    local page = pageFunctions.initalizePage(file)
    interpretFile(file, page)
end

function completePath(path, page)

    if not page then return path end
    new_path = page.path .. "/"
    if path:sub(1,1) == "/" then
        new_path = "/"
    end
    return new_path .. "/" .. path
end

return {
    openFile=openFile,
    interpretFile=interpretFile,
    handleFile=handleFile,
}