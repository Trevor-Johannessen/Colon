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

    return dict
end

return{
    create=create
}