print("Running installer v0.0.1")
objects = {
 'action', 'api', 'button', 'gif', 'jumpcut', 'loadbar', 
 'run', 'scroll', 'sprite', 'swipeLeft', 'swipeRight', 
 'template', 'text', 'textbox', 'reactangle',
}
-- download and move object files
for i,obj in next, objects do
    print(string.format("Getting %s.lua...", obj))
    local req = http.get(string.format('https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/colon_apis/colon_objects/%s.lua', obj))
    local file = fs.open(string.format('/colon/colon_apis/colon_objects/%s.lua', obj), 'w')
    file.write(req.readAll())
    file.close()
    print("Done.")
end
-- README
print("Getting README.md...")
req = http.get("https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/README.md")
file = fs.open("/colon/README.md", 'w')
file.write(req.readAll())
file.close()
print("Done.")
-- colon interpreter
print("Getting colon.lua...")
req = http.get("https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/colon.lua")
file = fs.open("/colon/colon.lua", 'w')
file.write(req.readAll())
file.close()
print("Done.")
-- colon runner
print("Getting colonrunner.lua...")
req = http.get("https://raw.githubusercontent.com/Trevor-Johannessen/markup/markup-oo/colonrunner.lua")
file = fs.open("/colon/colonrunner.lua", 'w')
file.write(req.readAll())
file.close()
print("Done.")
print("Installation Complete!")
