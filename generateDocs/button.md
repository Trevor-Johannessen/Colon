button Object:
===
Description:
---
This object renders a clickable button on screen. When clicked a button will activate a 'when statement' mapped to its name property. Buttons can rendered using either sprites or templates. Sprites are image files that allow visual customization. Templates are solid color blocks that are easier to use. Buttons take in a default image and a hover variant. Hover images are what is displayed when the button is being depressed. 


Arguments:
---
singleClick:
- Description: Boolean value for whether a button can be pressed multiple times.
- Default: false

sprite:
- Description: The sprite displayed on the button.

hoverSprite:
- Description: The sprite displayed on button press.
- Default: args.sprite

useTemplate:
- Description: Boolean value for whether a color template will be used in place of a sprite.
- Default: false


Functions
---
function button:draw(x_offset, y_offset)
* Draws the button to the screen

function button:writeText(x_offset, y_offset)
* Writes the buttons text on top of it's image

function button:drawClicked(obj_args)
* Sets a buttons image to it's 'hover' version when pressed.

function button:redrawBackground(obj_args)
* Sets the buttons image to its 'hover' version.

function button:setDbclick(tick)
* Marks the time the button was last clicked.

function button:update(obj_args)
* Handles button functionality.

function button:check_hover(inX, inY, y_offset)
* Checks if button can be clicked. If possible, it clicks the button.

function button:redraw_background(args)
* Not sure why this is here?

