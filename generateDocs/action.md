action Object:
===
Description:
---
This object hooks into the event listener via the update function.

It triggers the when statement with its given name when a specified event occurs. 


Arguments:
---
name:
- Description: the name used in it's corresponding when statement

event:
- Description: the action to be listening for


Functions
---
function action:update(obj_args)
* Checks on each event update to see if the given action has been triggered.

