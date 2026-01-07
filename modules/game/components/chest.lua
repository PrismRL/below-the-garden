--- @class Chest : Component
--- @overload fun(factory: ActorFactory): Chest
local Chest = prism.Component:extend "Chest"

function Chest:__new(factory)
   self.toSpawn = factory
end

return Chest