--- @class Wanderer : Component
--- @field goal Vector2
--- @overload fun(): Wanderer
local Wanderer = prism.Component:extend "Wanderer"

function Wanderer:__new(cooldown, period)
   self._cooldown = cooldown
   self.cooldown = cooldown
   self.period = period or 30
end

return Wanderer