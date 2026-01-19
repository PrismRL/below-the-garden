--- @class Snuffable : Component
--- @overload fun(light: ActorName): Snuffable
local Snuffable = prism.Component:extend "Snuffable"

function Snuffable:__new(light)
   self.light = light
end

return Snuffable
