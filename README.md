# COLON

### Table of Contents:
* Introduction
* Installation
* Syntax
* Objects
* Tags
* Functions
* Transitions
* Extension
* Interfacing


## Introduction:

Colon is a UI markup language I am working on. It's goal is to be able to create complex displays quickly, with easy integration utilizing its API.


## Installation:

Currently there is no installer, to run Colon please paste the files in its own directory and run using *directory*/colonrunner *filename*
I should really make an installer.


## Syntax:

Colon is line seperated so each line should start with the desired object followed by a colon. After the colon parameters can be declared. Parameters are comma delimited and are marked using name=value. Text values should be wrapped in a String but singular words do not need to be. (color=blue 👍, text=llorem ipsum 👎) Parameters involving color should be insensetive to input style, colors.green, 'green', and 'd' are all valid options. Invalid parameters are ignored by objects. Invalid keys will be ignored while invalid values may cause the program to crash.


## Objects:

Currently Colon has 8 native objects:
 *Button
 *Gif
 *Loadbar
 *Rectangle
 *Scroll
 *Sprite
 *Text
 *Textbox

and 1 deprecated item that will be repaired in the future:
 *Menu

For more information on each object please see the wiki (ATTATCH WIKI HERE)


## Tags

Tags are a collection of parameters that are applied to any object the tag is appended to. 

This block will create two lines of text, one colored red and one colored blue.
	tag: tag=*, color=red
	tag: tag=&, color=blue
	*text: x=1, y=20, text="this text is red"
	&text: x=1, y=21, text="this text is blue"

Tags are created using `tag: tag='symbol', param1=val1, param2=val2`
Tags are appended by putting the tag symbol before the object name in the colon segement. 
Like with objects, invalid tag parameters are ignored for objects not applicable. 


## Functions

Functions can be used to declare properties of the page. 

There are 6 functions: 
 * color 
 * background 
 * when 
 * load
 * run
 * api

For more information on each function please see the wiki (ATTATCH WIKI HERE)

## Transitions
Transitions can be used to move between two loaded pages. Transitions are declared as an object with the to= and from= parameters (Ex. `swipe: to=temp.txt, from=temp2.txt`). If from is left blank, a transition should transition from the current page. If a transition is declared without a when: statement it will immediately transition on render.

There is currently 3 transition:
 * swipeLeft
 * swipeRight
 * jumpcut

For more information on each function please see the wiki (ATTATCH WIKI HERE)


## Extension

Colon is designed to be easy to extend, to create a new object/function/transition a file with a unique name must be created in `colon/colon_apis/colon_objects`. 

#### Objects:
TOOD Explain how to add objects

#### Functions:
TODO Explain how to add functions

#### Transitions:
TODO Rewrite this this is trash
Transitions, like functions return a -1 instead of an table. Transitions should take in 3 parameters (to, from, speed) but can take in more if needed. Transitions can utilize the redraw function provided by colon to draw each scene involved in the transition. Further detail can be placed overtop of the two pages. See the wiki for an example on transitions.


## Interfacing
Colon gives complete visibility of rendered objects. Calling `getCurrentPage()` or `getPage(pageName)` will return a table of all of the objects on the requested page. Objects can be `modified using editObject(page, name, property, value)`.