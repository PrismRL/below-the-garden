--- @class Ignitable : Component
--- @overload fun(light: ActorName): Ignitable
local Ignitable = prism.Component:extend "Ignitable"

function Ignitable:__new(light)
   self.light = light
end

return Ignitable
