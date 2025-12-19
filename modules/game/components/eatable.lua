--- @class Eatable : Component
--- @field healing integer
--- @overload fun(healing): Eatable
local Eatable = prism.Component:extend "Eatable"

function Eatable:__new(healing)
   self.healing = healing
end

return Eatable
