print("Running installer v0.0.1")
objects = {
 'action', 'api', 'block', 'button', 'call', 'dropdown', 'fade', 'flex', 'gif', 'hook', 'jumpcut', 'loadbar', 'menu', 'rectangle',
 'run', 'scroll', 'slider', 'slot', 'sprite', 'swipeLeft', 'swipeRight', 'switch', 
 'template', 'text', 'textbox', 'time'
}

function writeFile(path, content)
    local file, msg = fs.open(path, 'w')
    if not file then
        print("File could not be written: " .. msg)
        print("Uninstalling...")
        uninstall()
        error("Colon could not be installed: " .. msg)
    end
    file.write(content.readAll())
    file.close()
end

function uninstall()
    for i,obj in next, objects do
        fs.delete(string.format('/colon/colon_apis/colon_objects/%s.lua', obj))
    end
    fs.delete("/colon/README.md")
    fs.delete("/colon/colon.lua")
    fs.delete("/colon/colonrunner.lua")
    fs.delete("/colon/colon_apis/colon_objects")
    fs.delete("/colon/colon_apis")
    fs.delete("/colon")
    print("Colon uninstalled!")
end

-- download and move object files
for i,obj in next, objects do
    print(string.format("Getting %s.lua...", obj))
    local req = http.get(string.format('https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/colon_apis/colon_objects/%s.lua', obj))
    writeFile(string.format('/colon/colon_apis/colon_objects/%s.lua', obj), req)
    print("Done.")
end
-- README
print("Getting README.md...")
req = http.get("https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/README.md")
writeFile("/colon/README.md", req)
print("Done.")
-- console
print("Getting console.lua...")
req = http.get("https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/colon_apis/ext/console.lua")
writeFile("/colon/colon_apis/ext/console.lua", req)
print("Done.")
-- colon interpreter
print("Getting colon.lua...")
req = http.get("https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/colon.lua")
writeFile("/colon/colon.lua", req)
print("Done.")
print("Installation Complete!")
