--- @class Wanderer : Component
--- @field goal Vector2
--- @overload fun(): Wanderer
local Wanderer = prism.Component:extend "Wanderer"

function Wanderer:__new(cooldown)
   self._cooldown = cooldown
   self.cooldown = cooldown
end

return Wanderer