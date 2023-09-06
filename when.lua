function create(page)

    local dict = {when={}}
    dict.page = page
    
    function dict:put(name, command)
        if not dict.when[name] then
            dict.when[name] = {}
        end
        table.insert(dict.when[name], command)
    end

    function dict:get(name)
        return dict.when[name]
    end

    function dict:contains(name)
        return dict.when[name] ~= nil
    end

    function dict:run(name, args)
        if dict:contains(name) then
            for k, v in next, dict.when[name] do
                local object = parser.parse(v, dict.page)
                args = args or {}
                for k, v in next, args do object[k] = v end
                if object then
                    local item = interpreter.interpret(object, dict.page)
                    if item and type(item.draw) == "function" then item:draw(0 --[[meta.current_page.x_scroll.position]], meta.current_page.y_scroll.position) end
                    --meta.console:addMeta{msg="Adding " .. v}
                end
            end
            return true
        end
        return false
    end

    return dict
end

return{
    create=create
}