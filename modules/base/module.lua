prism.registerRegistry("nodes", prism.BehaviorTree.Node, false)

--- @class Display : Object
local Display = spectrum.Display

function Display:border(x, y, width, height, config)
   local x1, y1 = x + width - 1, y + height - 1
   self:line(x, y, x1, y, 130, config.color)
   self:line(x, y1, x1, y1, 130, config.color)
   self:line(x, y, x, y1, 129, config.color)
   self:line(x1, y, x1, y1, 129, config.color)
   self:put(x, y, 175, config.cornerColor or config.color)
   self:put(x1, y, 175, config.cornerColor or config.color)
   self:put(x, y1, 175, config.cornerColor or config.color)
   self:put(x1, y1, 175, config.cornerColor or config.color)
end

function Display:itemBorder(x, y, color)
   self:put(x - 1, y - 1, 164, color)
   self:put(x, y - 1, 130, color)
   self:put(x + 1, y - 1, 166, color)
   self:put(x - 1, y, 129, color)
   self:put(x + 1, y, 129, color)
   self:put(x - 1, y + 1, 196, color)
   self:put(x, y + 1, 130, color)
end

--- @class QuickAction : Action
local QuickAction = prism.Action:extend "QuickAction"
QuickAction.abstract = true

prism.register(QuickAction)

local Color4 = prism.Color4
Color4.PURPLE = Color4.fromHex(0x9566ee)
Color4.DARK = Color4.fromHex(0x332e4d)
Color4.GOLD = Color4.fromHex(0xffb81a)
Color4.GREEN = Color4.fromHex(0x58ae67)
Color4.CORNFLOWER = Color4.fromHex(0x8aa1f6)
Color4.RED = Color4.fromHex(0xfe5876)
Color4.TEXT = Color4.fromHex(0x76775b)
Color4.PRISM = (Color4.CORNFLOWER + Color4.PURPLE) / 2
