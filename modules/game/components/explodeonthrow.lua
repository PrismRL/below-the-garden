--- @class ExplodeOnThrow : Component
--- @overload fun(radius, damage): ExplodeOnThrow
local ExplodeOnThrow = prism.Component:extend "ExplodeOnThrow"

--- @param radius integer
---@param damage integer
function ExplodeOnThrow:__new(radius, damage)
   self.radius = radius
   self.damage = damage
end

return ExplodeOnThrow
