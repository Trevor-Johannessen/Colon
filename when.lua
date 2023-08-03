function create()

    local dict = {when={}}

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
                local object = parser.parse(v, page)
                args = args or {}
                for k, v in next, args do object[k] = v end
                if object then
                    interpreter.interpret(object, page)
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