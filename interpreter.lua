pageFunctions = require("page-functions")
fileLoader = require("file-loader")

function interpret(args, page)
    --[[
        find special "in-house" data types
            initalizePage
            processFile
            object_types

        check for tags (maybe should include classes, similar to groups but for styles)

        check what groups the object is apart of
    ]]

    if args.type == "when" then
        page.when:put(args.name, args.command)
        return
    elseif args.type == "class" then
        --args.tags[args["tag"]] = args
        -- add class here
        return
    elseif args.type == "background" then
        page.background = colors[args.color]
        if page == meta.current_page then term.setBackgroundColor(page.background) end
        return
    elseif args.type == "color" then
        page.color = colors[args.color]
        if page == meta.current_page then term.setTextColor(page.color) end
        return
    elseif args.type == "load" then -- takes file, initalizes new page
        fileLoader.handleFile(args.file, page)
        return
    end
    if meta.object_types[args.type] == nil then error("Object type " .. args.type .. " not found.") end
    local obj = meta.object_types[args.type].create(args)
    if (type(obj) == "table") then -- if an actual object vs instance object
        obj.groups = obj.groups or args.groups
        if obj.y and obj.height then
            if obj.y+obj.height-1 > page.y_scroll.anchor then page.y_scroll:setAnchor(obj.y+obj.height-1) end
        end
        table.insert(page.objects, obj)
        return obj
    end
end

function constructWhen()

end



return{
    interpret=interpret
}