--- @class Ignitable : Component
--- @overload fun(light: ActorName, x?: integer, y?: integer): Ignitable
local Ignitable = prism.Component:extend "Ignitable"

function Ignitable:__new(light, x, y)
   self.light = light
   self.x = x
   self.y = y
end

return Ignitable
