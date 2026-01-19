--- @class Teleporter : Component
--- @overload fun(): Teleporter
local Teleporter = prism.Component:extend "Teleporter"

function Teleporter:__new()
   self.charge = 0
end

return Teleporter
