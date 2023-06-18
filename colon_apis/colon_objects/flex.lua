template = require("colon_apis/colon_objects/template")

function createKeyString()
    local str = ""
    for i=1, 5 do
        str = str .. string.char(math.random(1,255))
    end
    return str
end

function create(args)
	local flex = template.create(args)
	flex:coords(args)
    flex:dim(args)
    flex:essentials(args)
    flex.old_x = flex.x
    flex.old_y = flex.y
    flex.direction = args.dir
    flex.direction = args.direction or "col"
    flex.dimensions = {}
    flex.type="flex"
    args.managing = args.managing or ""
    flex.managing = {}
    flex.key=createKeyString()
    if flex.direction ~= "row" and flex.direction ~= "col" then
        flex:error("Flex direction takes \"row\" or \"col\"")
    end
    for group in args.managing:gmatch("[^ ]+") do
        table.insert(flex.managing, group)
    end
    flex.colon.log("Flex is managing:")
    for k, group in next, flex.managing do
        flex.colon.log("  " .. group)
    end

    function flex:move(obj,offset)
        if flex.direction == "row" then 
            obj.x = flex.x + offset.x
            obj.y = flex.y
        else 
            obj.x = flex.x
            obj.y = flex.y + offset.y 
        end
    end

    function flex:adjustOffset(obj,offset)
        if flex.direction == "row" then
            if obj.width then offset.x = offset.x + obj.width end
            if obj.height and obj.height > offset.y then offset.y = obj.height end
        else
            if obj.width and obj.width > offset.x then offset.x = obj.width end
            if obj.height then offset.y = offset.y + obj.height end
        end
    end

    function flex:checkObjDimChange(obj)
        local dim = flex.dimensions[obj[flex.key]]
        if not dim then return true end
        if dim.width == obj.width and dim.height == obj.height then
            return false
        end
        return true
    end

    function flex:checkPosChange()
        if flex.x ~= flex.old_x or flex.y ~= flex.old_y then
            flex.old_x = flex.x
            flex.old_y = flex.y
            return true
        end
        return false
    end

    function flex:checkChange()
        local checked = {}
        if flex:checkPosChange() then return true end
        for k, group_name in next, flex.managing do
            local group = flex.colon.getGroup(group_name)
            if not group then return end
            for k, obj in next, group do
                if not checked[obj] then
                    if flex:checkObjDimChange(obj) then return true end
                    checked[obj] = true
                end
            end
        end
        return false
    end

    function flex:registerDimensions(obj)
        -- changes of collision are near 0, ignoring for performance
        if not obj[flex.key] then -- obj has no registered domain, generate new key
            obj[flex.key] = createKeyString()
        end
        flex.dimensions[obj[flex.key]] = {width=obj.width, height=obj.height}
    end

    -- place's all of the objects in the flex's group
    function flex:place()
        local placed = {}
        local offset = {x=0,y=0}
        for k, group_name in next, flex.managing do
            local group = flex.colon.getGroup(group_name)
            if not group then return end
            for k, obj in next, group do
                flex:registerDimensions(obj) 
                flex.colon.log(group_name .. "("..obj.width..","..obj.height..")")
                if not placed[obj] and flex[flex.key] ~= obj[flex.key] then 
                    flex:move(obj,offset) 
                    flex:adjustOffset(obj, offset)
                end
                placed[obj] = true
            end
        end
        flex.width = offset.x
        flex.height = offset.y
    end

    function flex:draw()
        flex:update()
    end

    function flex:update()
        if flex:checkChange()then
            flex:place()
            flex.colon.redraw()
        end
    end

	return flex
end

return{
	create=create
}