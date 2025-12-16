prism.registerRegistry("nodes", prism.BehaviorTree.Node, false)

--- @class Display : Object
local Display = spectrum.Display

function Display:border(x, y, width, height, config)
   local x1, y1 = x + width - 1, y + height - 1
   self:line(x, y, x1, y, 293, config.color)
   self:line(x, y1, x1, y1, 293, config.color)
   self:line(x, y, x, y1, 276, config.color)
   self:line(x1, y, x1, y1, 276, config.color)
   self:put(x, y, 315, config.cornerColor or config.color)
   self:put(x1, y, 288, config.cornerColor or config.color)
   self:put(x, y1, 289, config.cornerColor or config.color)
   self:put(x1, y1, 314, config.cornerColor or config.color)
end
