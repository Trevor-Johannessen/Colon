file_loader = require("file-loader")
page_functions = require("page-functions")
parser = require("parser")

args = {...}
pages = {}

--[[
    Rewrite order:

    Read file
    Parse Lines
    Create objects
    Enter Event Loop
]]

function run()
    handleFile(args[1])
end

--[[
    reads, parses, and prepares a file for interpretation
]]
function handleFile(file)
    iter = file_loader.openFile(file)
    page = page_functions.initalizePage(pages, file)
    interpretFile(iter, page)
end

function interpretFile(iter, page)
    for line in iter do
        local object = parser.parse(line, page)
    end
end

if args[1] then run() end