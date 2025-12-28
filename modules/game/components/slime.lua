--- @class Slime : Component
--- @overload fun(): Slime
local Slime = prism.Component:extend "Slime"

function Slime:__new(lifetime)
   self.lifetime = 6
end

return Slime
