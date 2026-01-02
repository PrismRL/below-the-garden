--- @class LastSeen : Component
--- @field position Vector2?
--- @field duration integer?
--- @overload fun(): LastSeen
local LastSeen = prism.Component:extend "LastSeen"

function LastSeen:__new(...)
   self.components = { ... }
end

return LastSeen
