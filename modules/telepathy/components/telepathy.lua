--- @class TelepathyOptions
--- @field range integer How far (in tiles) telepathy reaches.

--- @class Telepathy : Component
--- @field private range integer
--- @overload fun(options: TelepathyOptions): Telepathy
local Telepathy = prism.Component:extend("Telepathy")
Telepathy.requirements = { "Senses" }

function Telepathy:getRequirements()
   return prism.components.Senses
end

--- @param options TelepathyOptions
function Telepathy:__new(options)
   self.range = options.range
end

function Telepathy:getRange()
   return self.range
end

return Telepathy
