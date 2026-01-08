--- @class GazeMessage : Message
--- @field actor Actor
--- @overload fun(actor: Actor): GazeMessage
local GazeMessage = prism.Message:extend "GazeMessage"

function GazeMessage:__new(actor)
   self.actor = actor
end

return GazeMessage
