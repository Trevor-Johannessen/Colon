fileLoader = require("file-loader")
pageFunctions = require("page-functions")
parser = require("parser")
interpreter = require("interpreter")
init = require("initalization")
when = require("when")
eventLoop = require("event-loop")
redraw = require("redraw")

meta = {
    object_types = {},
    pages = {},
    console = {},
    scroll = {},
    api = {

    },
}
meta.screen_width, meta.screen_height = term.getSize()

--[[
    Rewrite order:

    Read file
    Parse Lines
    Create objects
    Enter Event Loop
]]
function run(file)
    init.initalize(meta)
    fileLoader.handleFile(file)
    eventLoop.start()
end

return {
    run=run
}