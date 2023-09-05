import sys
import os
import re
from enum import Enum

files = sys.argv[1:]
Blocks = Enum("Blocks", ["FUNCTION", "ARGUMENT", "DESCRIPTION"])

# this is what happens when you're half asleep and take the first solution instead of the good solution.
# not going to rewrite this, its almost never ran and it works fine.

def parseFile(file_path):
    with open(file_path) as file:

        file_name = os.path.basename(file_path)
        obj_type = file_name[:file_name.find(".lua")]
        processing=None
        docs={'functions': {}, 'arguments': {}, 'description': ""}
        for line in file:
            if processing and processing['type']==Blocks.FUNCTION:
                if processing['inComment']:
                    if line.find("]]") != -1:
                        processing=None
                    else:
                        docs['functions'][processing['name']] += line.replace("\t", "")
                else:
                    processing['inComment'] = line.find("--[[") != -1
                    docs['functions'][processing['name']]=""
            elif processing and processing['type']==Blocks.DESCRIPTION:
                if line.find("]]") != -1:
                    processing = None
                else:
                    line=line.replace('\t', '')
                    docs['description'] += f"{line}\n"
            else:
                # not in function, argument, or description.
                processing=None
                pattern = re.compile(f"function {obj_type}:[^\(]+\([^)]*\)")
                func = pattern.search(line)
                if func:
                    processing={'type': Blocks.FUNCTION, 'inComment': False, 'name':func[0]}
                pattern = re.compile(f"{obj_type.upper()} OBJECT")
                func = pattern.search(line)
                if func:
                    processing={'type': Blocks.DESCRIPTION}
                pattern = re.compile(f"args\.([^ ]+).*")
                func = pattern.search(line)
                if func:
                    name = func.group(1)
                    match = re.search(r"(or ?([^ ]+))? -- ?([^\n]+)", line)
                    if match != None:
                        docs['arguments'][name] = {'default': match.group(2), 'desc': match.group(3)}
        with open(f"./{obj_type}.md", "w") as out:
            out.write(f"{obj_type} Object:\n")
            out.write("===\n")
            out.write("Description:\n")
            out.write("---\n")
            out.write(f"{docs['description']}\n")
            out.write("Arguments:\n")
            out.write("---\n")
            for k, v in docs['arguments'].items():
                out.write(f"{k}:")
                out.write(f"\n- Description: {v['desc']}\n")
                if v['default']:
                    out.write(f"- Default: {v['default']}\n")
                out.write("\n")
            out.write("\nFunctions\n")
            out.write("---\n")
            for k, v in docs['functions'].items():
                out.write(k)
                out.write(f"\n* {v}\n")


for file in files:
    parseFile(file)