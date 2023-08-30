colorsDict = {
    {hex="0", string="white", int=colors.white},
    {hex="1", string="orange", int=colors.orange},
    {hex="2", string="magenta", int=colors.magenta},
    {hex="3", string="lightBlue", int=colors.lightBlue},
    {hex="4", string="yellow", int=colors.yellow},
    {hex="5", string="lime", int=colors.lime},
    {hex="6", string="pink", int=colors.pink},
    {hex="7", string="gray", int=colors.gray},
    {hex="8", string="lightGray", int=colors.lightGray},
    {hex="9", string="cyan", int=colors.cyan},
    {hex="a", string="purple", int=colors.purple},
    {hex="b", string="blue", int=colors.blue},
    {hex="c", string="brown", int=colors.brown},
    {hex="d", string="green", int=colors.green},
    {hex="e", string="red", int=colors.red},
    {hex="f", string="black", int=colors.black}
}

function convertColor(color, type)
    for i=1, #colorsDict do
        for k, v in next, colorsDict[i] do
            if color == v then return colorsDict[i][type] end
        end
    end
    error("Color " .. color .. " is not supported.")
end

return{
    convertColor=convertColor
}